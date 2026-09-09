# B2 — estados inalcançáveis e rotas que calam

Branch `Vitorepf/volta-b2-silencio`. ADR `2026-09-09q`. Aparelho: **`34CC3F94` (teste 3)**,
que **encontrei ligado** e deixei como achei. **No `B91C8DEF` (o da conta) não toquei** —
nem install, nem captura, nem teste.

**Linha do ciclo (G0).** Multiplicar a mente: o autor não perde tempo com o que a
ferramenta esconde. Depois desta volta, um botão que não vai responder **diz por quê no
lugar onde ele tocou**, em vez de vibrar.

---

## 1. O que eu procurei, e como

Duas caças, cada uma com o seu método.

**Estados inalcançáveis.** Varredura de **todos os `enum`** de `Traco/` e `TracoWidget/`
(54 declarações, 268 `case`), procurando `case` que a produção **nunca constrói** — a
assinatura do `EstadoAcao` que a auditoria de 07/09 achou em `Trabalho.swift:39-44`. O script
está em `/tmp` e a receita é curta: para cada `case X`, contar as ocorrências de `.X` que
**não** estão em posição de `case .X` (casamento), em `Traco/**` e em `TracoTests/**`
separadamente.

**Rotas que calam.** Todos os `} catch`, todos os `return nil` de rota de IA, e — o que deu
o resultado — a lista de quem CHAMA `Sabia.*`/`Grok.*`/`AnaliseRemota.*` fora de
`Traco/Analise`, cruzada com quem MOSTRA a frase de `Politica.semProvedor`.

## 2. Estados inalcançáveis: **nenhum**, e a conferência caso a caso

A varredura levantou oito candidatos. **Todos os oito são alcançáveis** — o script erra em
duas formas que a conferência manual desfez:

| candidato | veredito | por quê |
|---|---|---|
| `DocumentoTrabalho.ResultadoObservado.funcionou` | **alcançável** | `CaseIterable`; `TrabalhoView.swift:1118` faz `ForEach(ResultadoObservado.allCases)` — o autor toca a pílula |
| `Politica.Operacao.classificar` | **alcançável** | `CaseIterable`; `PerfilView.reprovadas` e as duas listas irmãs iteram `allCases`, e a rota de classificação em `Sessao.swift:179` faz Grok→bordo, que é exatamente a regra da linha |
| `IntercambioTrabalho.Erro.tamanho` | **alcançável** | `throw Erro.tamanho` em `IntercambioTrabalho.swift:62` e `:67` — o script só vê `.tamanho`, não `Erro.tamanho` |
| `AvaliacaoIA.Falha.arquivoInvalido` | **alcançável** | `throw Falha.arquivoInvalido` em quatro pontos (`:64`, `:71`, `:75`, `:84`) |
| `AvaliacaoIA.Falha.entradaAusente` | **alcançável** | `throw Falha.entradaAusente(campo)` em `:153` |

**Conclusão:** a E1 fechou a família. Não há irmã do `EstadoAcao` viva no código. Isto é a
segunda das três provas que a tarefa pede — a prova de que **não existe** —, e ela vale
tanto quanto um achado.

**O inalcançável desta volta não era `enum`.** `Politica.semProvedor(_:)` tem uma frase de
tela para cada uma das **dezesseis** operações. `TracoTests/PoliticaTests.swift:12` guarda
desde a 08q que **nenhuma está vazia**. Contei quantas alguma tela mostra: **seis**. Os
outros **dez ramos do `switch`** eram código que nenhuma rota do autor alcançava — motor sem
superfície, com um teste verde por cima.

## 3. Rota que cala: **Lente · Instigar** e **Lente · Contrapor**

**O defeito.** `LenteView.instigar()` e `LenteView.contrapor()` perguntavam a
`Sabia.disponivel` — que responde `true` quando há conta Grok **ou** Apple Intelligence. Mas
as duas operações são `indisponivelPorQualidade` desde a ADR 08q: `Politica.provedor`
devolve `nil` **independentemente da conta**, e `Sabia.chamar` volta `nil` na primeira linha.
O autor toca o botão e recebe **`Toque.aviso()`** — uma vibração. Nada na tela.

**A prova, na tela viva.** `34CC3F94`, sem conta Grok, com Apple Intelligence disponível
(sonda: `SystemLanguageModel.default.availability = available`, logo `Sabia.disponivel ==
true` e a guarda antiga passava). Toque dado pela árvore de AX, não por coordenada cega — o
helper imprime onde tocou:

```
toquei 'Lente da língua' em 0.846,0.930
toquei 'Instigar' em 0.500,0.388
APOS INSTIGAR: ['Traço', 'Capturador de Folhas', 'Lente', 'Pronto',
 '27 palavras · 2 frases · nada a apontar', 'DECISÃO', 'a forma desta nota', 'De onde vem',
 'INSTIGAR', 'perguntas sobre o que falta — nunca respostas', 'Instigar',
 'CONTRAPOR', ... ]
toquei 'Contrapor' em 0.500,0.531
APOS CONTRAPOR: [ ...a MESMA lista, palavra por palavra... ]
```

Seis segundos depois do toque, **a árvore de acessibilidade é idêntica à de antes do
toque**. Nenhum rótulo novo. Capturas:

- `b2-01-lente-antes.png` — a Lente aberta, com Instigar e Contrapor.
- `b2-02-instigar-calou.png` — 6 s depois de tocar **Instigar**: a tela não mudou.
- `b2-03-contrapor-calou.png` — 5 s depois de tocar **Contrapor**: a tela não mudou.

**Onde a explicação morava.** A duas telas de distância. O Perfil já lista, na terceira
seção, `instigar — devolveu o vocabulário interno do app` e `contrapor — sustentou o
contraponto em fato inventado` (lido na árvore de AX do Perfil na mesma corrida). O autor
que toca o botão não tem como saber que precisa ir lá.

**O conserto.** Uma linha em `Politica`:

```swift
static func aviso(_ op: Operacao, contaLigada:, bordo:) -> String? {
    provedor(op, ...) == nil ? semProvedor(op) : nil
}
```

`nil` = há quem responda, a rota segue. Texto = é isto que a tela diz. A Lente reusa
`LinhaDeEstado` (o mesmo componente que `RecordarView`, `RedeView` e `PadroesView` já usam
para exatamente isto) e o `Toque.aviso()` mudo do caminho de falha ganhou a frase
"a sábia não respondeu.". **Nenhum token, nenhuma cor, nenhuma medida nova** — por isso não
passei pelo `design-router`, e digo isso aqui em vez de deixar a omissão calada.

**Depois, na mesma tela, com os mesmos toques:**

- `b2-04-instigar-diz.png` — "Instigar pela IA está indisponível: na medida de 08/09 ela
  devolveu o vocabulário interno do app em vez de uma pergunta sobre o que você escreveu. As
  perguntas do método continuam na página."
- `b2-05-contrapor-diz.png` — "Contrapor pela IA está indisponível: na medida de 08/09 ela
  sustentou o contraponto em fato inventado. O Steelman e a Inversão continuam no catálogo,
  escritos por você."

O toque nas MESMAS coordenadas produz a frase — o que fecha a única brecha da prova de
silêncio ("e se o toque não tivesse pegado?").

**Um defeito que a própria captura pegou.** A primeira versão guardava um `aviso: String?` só
para a folha inteira, e o aviso do Instigar aparecia TAMBÉM na seção do Contrapor (a árvore
de AX da corrida das 17:38 mostra a frase duas vezes). O estado passou a carregar a operação
dona; a corrida seguinte mostra uma frase numa seção só.

## 4. Rota que mente: **Caderno · Perguntar à sábia**

`responder` também é `indisponivelPorQualidade` (08q; a 09n a tirou da lista e o G3 a
devolveu no mesmo dia). O toast dizia **"a sábia não respondeu. tente de novo."** — convite a
repetir o que nunca vai dar certo. Agora, quando a tabela diz que ninguém responde, a rota
nem gira o laço: a pergunta volta ao cartão `.pergunta`, como no cancelamento da 09n (o que
ele escreveu não se perde), e o toast é a frase honesta. O caminho de falha TRANSITÓRIA
continua dizendo "tente de novo", que ali é verdade.

**Limite declarado:** a captura desta rota **não foi obtida**. O `34CC3F94` está disputado
(a volta F6 e uma corrida de `TracoUITests` entraram no meio), e o helper de AX devolveu
árvore vazia em três tentativas seguidas depois de um `launch` — o mesmo "ok sem mover a
tela" que o preâmbulo avisa. O conserto está guardado pelo portão e pela mesma mecânica que a
Lente provou na tela; a captura fica como dívida de evidência, minha, nomeada.

## 5. Rota que calava: **Vestir tudo**

`Sessao.vestirTudo()`: sem conta, quando o motor local não mexia em nada, o autor ouvia
"nada a vestir aqui."; **com** conta, se `Sabia.vestir` voltasse `nil` (rede, 400, JSON que
não casa), a rota voltava calada — toque sem consequência e sem palavra. Agora, quando o
motor local não mexeu em nada, a rota diz qual dos dois foi: "a sábia não respondeu. o texto
ficou como estava." ou "nada a vestir aqui.". Sem captura pelo mesmo motivo da §4.

## 6. O portão

`TracoTests/PortaoDaRotaQueCalaTests.swift`, no espírito do `PortaoDoTryBangTests`: **tabela
congelada** de quem mostra a frase (dez) e quem não mostra (seis), esta com o julgamento
escrito ao lado. Varre os fontes com o `codigoVisivel` do `PortaoDoMovimento` — comentário e
string **não** contam como superfície — e tem sonda dos dois sentidos
(`aVarreduraAindaEnxerga`).

**Vermelho antes do verde, medido.** Com `Politica.aviso` no lugar e as duas rotas como
estavam:

```
✔ Test avisoEhAFraseExatamenteQuandoNinguemResponde() passed after 0.001 seconds.
✔ Test contaLigadaNaoRessuscitaOperacaoCortadaPorQualidade() passed after 0.001 seconds.
✔ Test aVarreduraAindaEnxerga() passed after 0.106 seconds.
✘ Test nenhumaOperacaoPerdeuASuaSuperficie() recorded an issue: Expectation failed:
  (semSuperficie → ["instigar — nenhuma tela mostra `Politica.aviso(.instigar)`",
                    "responder — nenhuma tela mostra `Politica.aviso(.responder)`",
                    "contrapor — nenhuma tela mostra `Politica.aviso(.contrapor)`"]).isEmpty → false
✘ Test run with 5 tests in 1 suite failed after 0.451 seconds with 1 issue.
```

Exatamente as três rotas, e nenhuma outra. Depois do conserto:

```
✔ Test run with 5 tests in 1 suite passed after 0.455 seconds.
```

**A varredura também pegou um erro meu**: na primeira redação eu procurava
`RevisaoTrabalho.semProvedor` como superfície da `revisar`, e o portão acusou — a superfície
real é `RevisaoTrabalho.oferta()`, em `TrabalhoView.swift:965`. O portão funcionou contra
quem o escreveu.

## 7. Suíte integral

`com-trava.sh xcodebuild test -scheme Traco -destination id=34CC3F94 -parallel-testing-enabled NO`:

```
✔ Test run with 1005 tests in 162 suites passed after 145.920 seconds.
```

Zero falha, zero warning novo. (Eram 1000 em 161 suítes no `f9f2292`; os cinco novos são o
portão desta volta.)

## 8. O que fica, com dono

| dívida | dono |
|---|---|
| **`responderNasNotas` tem o mesmo defeito da `responder`**: `NotasView.swift:190` diz "a sábia não respondeu." com "Repetir" ao lado, para uma operação que a 08q cortou. Não entrou aqui porque a tela das Notas está sendo reescrita pela 09k. | frente das Notas (D) |
| **Captura de tela das rotas `responder` e `vestir`** — o conserto está feito e guardado pelo portão; falta o registro na tela viva. | minha, na próxima volta B |
| **A letra `09i` está reservada para a Q4, "instigar e contrapor"** — quem abrir a Q4 vai encontrar `LenteView` com o gate em `Politica.aviso` e `LinhaDeEstado` no lugar do `Text` cru. Não é conflito, é aviso. | Q4 |

## 9. Instrumento — o que eu fiz no aparelho, e o que deu errado

- **`34CC3F94` (teste 3):** encontrei **ligado**, usei, **deixei ligado** — não desliguei o
  que não liguei. Build, suíte, install e capturas.
- **`B91C8DEF` (o da conta): não toquei.** Nenhum comando meu o alcançou.
- **Trava:** `com-trava.sh` em todo `xcodebuild`, todo `install`, todo `launch` e — depois do
  erro abaixo — em **toda** a sequência de toques.
- **Install por cima: três vezes** (binário antes do conserto, binário depois, e o binário do
  conserto do aviso por seção). Cada uma justificada por uma captura que precisava do
  binário daquele estado. Sem `erase`, sem `clearState`, sem `uninstall`.
- **ERRO MEU, escalado na hora.** Segurei a trava para instalar e lançar, mas **não** para
  dirigir. Dois toques cegos meus (17:27) caíram na tela da volta **F6**, que tinha acabado
  de trancar o aparelho: um deles respondeu **"Permitir"** ao diálogo "Permitir Atividades ao
  Vivo do app Traço?" — não era meu para responder. E uma sequência cega posterior (17:34)
  caiu no Perfil e tocou **"Entrar com a conta Grok"**, que abriu `accounts.x.ai` no Safari
  do simulador. **Nenhuma credencial foi digitada e nenhuma conta foi ligada**; o app foi
  encerrado e o Safari fechado. Escalado ao orquestrador em `msg_1d5cac16b074`. A partir daí
  toda a navegação passou a ser **por rótulo na árvore de AX, com asserção**, e o helper
  imprime a coordenada onde tocou.
- **Limite do instrumento:** o helper de AX devolveu `[]` (árvore vazia) em três tentativas
  seguidas logo depois de um `launch`, e `simctl io screenshot` devolveu "Timeout waiting for
  screen surfaces" uma vez. O contorno foi reatar o helper em laço até a árvore voltar. É a
  causa da dívida de captura da §4 — fato registrado, não desculpa.
- Nada de voz, nada de VoiceOver, nada de iPad. Nada de `orca emulator kill`. Aparelho
  devolvido com orientação, tamanho de letra e movimento como estavam (não mexi em nenhum).

## Scorecard (preenchido por mim; a nota final é do revisor)

| dimensão | nota | por quê |
|---|---:|---|
| Visão | 9 | fecha uma classe inteira da §8 ("rota que cala em vez de dizer") com uma linha, e resolve de uma vez as três rotas com botão; o que sobrou está nomeado com dono |
| Contrato | 9 | ADR `2026-09-09q` no SPEC, letra registrada em `LETRAS-ADR.md` no mesmo ato; a tabela do portão é o contrato executável de quem tem superfície |
| Correção | 9 | 1005 verdes em 162 suítes; vermelho do portão colado, com as três rotas nomeadas; o portão acusou um erro do próprio autor |
| Jornada real | 9 | dois botões que o autor toca hoje deixaram de vibrar e passaram a explicar; provado na tela viva, com o toque impresso e a árvore de AX antes e depois |
| Design | 8 | reusei `LinhaDeEstado` e a frase que já existia — zero token, zero cor, zero medida nova —, e por isso não abri o `design-router`; a decisão é minha e está escrita, mas quem revisar pode discordar dela |
| Simplicidade | 9 | o autor deixa de precisar ir ao Perfil para descobrir por que o botão não fez nada: a resposta chega onde ele tocou |
| Movimento | n/a | nenhuma animação tocada |
| Componentes | 9 | nenhum componente novo; o `Text` cru da Lente virou o `LinhaDeEstado` que as outras três telas já usavam — menos divergência, não mais |
| Acessibilidade | 8 | a frase é `Text` real, entra na árvore de AX (provado: aparece nos rótulos da corrida "depois") e tem identificador por seção; **não** verifiquei em AX5 nem em Dynamic Type grande — declarado como limite |
| Performance | n/a | `Politica.aviso` é um `switch` sobre `enum` por toque de botão |
| Privacidade e autoria | 9 | a mudança REDUZ ida à rede (a rota sem executor nem chama) e nada do texto do autor mudou de caminho; no Caderno a pergunta dele volta ao cartão em vez de sumir |
| Estado honesto | 9 | as duas capturas que faltam estão declaradas como dívida minha, o erro do mouse está no relato com hora e mensagem, e o "nenhum estado inalcançável" está apresentado como resultado da busca, não como ausência de busca |
| Complexidade | 9 | um arquivo novo (o portão, que é teste), uma função de uma linha, zero dependência, zero abstração; o `Bool` `semConta` da Lente foi DELETADO |
| Fora do app | n/a | nada fora do app |
| Relato | 9 | este documento, com as linhas de resultado coladas, as capturas abertas e descritas, e o comando que qualquer um repete |
