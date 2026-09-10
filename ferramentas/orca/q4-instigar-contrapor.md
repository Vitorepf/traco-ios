# Q4 — `instigar` e `contrapor`: o andaime é nosso

**ADR:** 2026-09-09i (SPEC.md) · **Branch:** `Vitorepf/volta-q4-instigar`, sem mesclar
**Ciclo:** melhorar a mente · **Intenção:** a sábia provoca o autor a pensar melhor —
perguntando sobre o que ELE escreveu, e contrapondo com o que se sustenta.

## ⚠️ Esta passada NÃO correu no aparelho — ela PREPARA a corrida em lote

Nada foi medido contra a rede. Não instalei nada no `B91C8DEF` (aparelho da conta),
não chamei o Grok, não rodei a sonda. **A fixture está pronta:**

```
prova/q4-instigar-contrapor-casos.json   — 12 casos (6 instigar, 6 contrapor), 3 repetições = 36 execuções
```

## O defeito, e por que são um só

A medida de 08/09 com a conta ligada reprovou as duas com **1 de 6** cada:

- `instigar` devolveu **o nosso vocabulário de andaime** em vez de perguntar sobre o texto;
- `contrapor` sustentou o contraponto em **fato inventado**, sempre no `outroCampo`.

São a mesma coisa: **o modelo enche o espaço com material que não veio do autor.**

## A causa do `instigar`, achada e não suposta

O pedido montava, num texto só, o rascunho DELE e o nosso andaime — `Forma: nota`,
`O MÉTODO desta forma…` e `DEGRAU 0 — primeira vez nesta forma. Cobre o MOVIMENTO
básico do método: o passo que se pula.` O que está ao lado do rascunho é **citável**:

| o autor escreveu | voltou (`prova/q-qualidade-avaliacoes.jsonl`, 08/09) |
|---|---|
| "praticar espanhol… quinze minutos" | "Qual é o **movimento básico que se pula** ao esperar ter uma hora livre?" |
| "Não deu certo de novo." | "Qual é o **movimento básico** que foi pulado?" |
| "…parei no primeiro parágrafo" | "**A forma 'nota'** já foi usada em capítulos anteriores?" |
| (o rascunho do espanhol) | "Como a nota '**DEGRAU 0**' se relaciona com **o método** que você menciona?" |

**O que aponta o dedo:** os dois casos **com método** (`decisao`) NÃO vazaram — deram
critério, evidência e custo de errar falando do aluguel e do limite de R$ 1.000.
Vazaram os quatro **sem método**, onde a instrução de degrau era o único texto de
esteio e, sendo meta, virou assunto. **O defeito é nosso, não do provedor.**

## O conserto

**`instigar` — o andaime sai do texto citável (3 movimentos, todos deleção ou mudança de lugar):**

1. Método (03n) e degrau (04j) passam para a mensagem de **SISTEMA**; o pedido leva o
   rascunho e o retrato — só o que veio do autor.
2. O rótulo `Forma: <nome>` **saiu inteiro**: o método já se apresenta pelo nome, e
   sozinho ele só dava uma palavra para citar.
3. `Degraus.instrucaoDeInstigar` reescrita **sem nome citável** — o degrau continua
   mudando o que se cobra (passo básico → relação → evidência → custo → limite) e
   deixou de ser assunto.

**`contrapor` — contrato de sustentação, irmão do que a Q2 provou em `sistemaResponder`:**
proibido número, porcentagem, preço, data, estudo, pesquisa, metanálise, fonte ou
declaração de terceiro que ela não deu; o caso de outro campo **admite `""` por
escrito** (era exigido em toda chamada, e essa exigência é que fabricava a precisão).
O defeito oposto entrou junto: calar nos três só quando a nota não deixa nada a
examinar.

**A guarda que se prova sem o aparelho — relativa ao autor:**

```swift
Sabia.vazaAlheio(frase, termos:, texto:)   // cai se a frase tem o termo e o texto do autor não
```

`parsePerguntas(_:texto:)` derruba a pergunta com `degrau`, `método`, `sábia`,
`rascunho`, `movimento básico` ou `passo que se pula` **que o autor não escreveu**;
`parseContraparte(_:texto:)` derruba o campo com `%`, `metanálise`, `segundo
estudo/pesquisa` ou `dados mostram` nas mesmas condições. A relatividade é o ponto:
**quem escreveu "método" na própria nota ouve uma pergunta sobre o método dele.**

## Prova (colada)

**Vermelho ANTES** — guarda desligada (`return false`), material = as saídas reais de 08/09:

```
✘ Expectation failed: (Sabia.parsePerguntas(json, texto: rascunho) → ["Qual é o movimento básico que se pula ao esperar ter uma hora livre?", "O que exatamente significa praticar espanhol em quinze minutos?"]) == ["O que exatamente significa praticar espanhol em quinze minutos?"]
✘ Expectation failed: (Sabia.parseContraparte(cru, texto: "Vou aceitar a proposta.") → Contraparte(contra: "A comissão de 12% cobre o custo de hoje, …", foraDaLista: "", outroCampo: "")) == nil
✘ Test run with 7 tests in 1 suite failed after 0.023 seconds with 12 issues.
```

**Verde DEPOIS** — suíte integral, `34CC3F94` (teste 3):

```
✔ Test run with 1007 tests in 162 suites passed after 89.239 seconds.
** TEST SUCCEEDED **
```

Build: `** BUILD SUCCEEDED **` (`xcodebuild -scheme Traco -destination 'generic/platform=iOS Simulator' build`).
Aviso restante na árvore: `NotasView.swift:806 '+' was deprecated` — **não é meu** (área da D1).

## Instrumento

- **Trava:** todo `xcodebuild` passou por `ferramentas/orca/com-trava.sh`. Declarado.
- **`34CC3F94` (teste 3):** build e suíte. **Encontrei-o LIGADO por outra volta**
  (`simctl boot` respondeu `Unable to boot device in current state: Booted`) e
  **deixei como achei** — não desliguei o que não liguei.
- **`B91C8DEF` (conta):** **não toquei**. Nenhum install, nenhum launch, nenhuma
  chamada de rede, `ContaGrok` intacta.
- **Primeira corrida:** `The test runner hung before establishing connection` — outra
  volta (PID 91131) rodava `xcodebuild test` no MESMO UDID. Repetida depois da trava,
  conectou e deu a linha acima. As duas saídas estão neste relato.
- Sem mouse, sem maestro, sem voz, sem VoiceOver, sem iPad.

## O que muda se o vencedor da Q2-F for outro modelo

**Nada no código.** O conserto é redação de pedido e guarda de parser — não passa
modelo nem esforço, e nenhuma das duas rotas pede `esforco`, então herda o
`Grok.esforcoMinimo` seja ele qual for. O que muda é a **taxa**: a separação
sistema/usuário depende de o modelo tratar instrução como instrução, e um modelo
que confunde os dois papéis vaza mais e a guarda derruba mais perguntas — o sintoma
seria `instigar` devolvendo `nil` com frequência, não vazamento na tela. Se isso
aparecer na corrida, o caso `q4-instigar-texto-magro` é o que acusa.

## Scorecard (preenchido por mim; a nota é do revisor)

| dimensão | nota | evidência |
|---|---|---|
| Visão | 8 | entra no ciclo "melhorar a mente" e ataca duas linhas cortadas, mas **não fecha lacuna do EVOLUCAO**: conserto escrito ≠ conserto medido. Por isso não toquei o EVOLUCAO. |
| Contrato | 9 | ADR 2026-09-09i em SPEC.md, coerente com `Politica` (as duas linhas passam a "em correção, com conserto nomeado") |
| Correção | 9 | vermelho antes com 12 issues, verde depois 1007/162/0; a guarda é o que separa os dois |
| Jornada real | n/a | esta passada não corre no aparelho por ordem do dispatch; a captura da resposta real é do fecho da corrida |
| Design | n/a | motor puro, nenhuma view tocada (implementador.md: "motor puro dispensa design-router") |
| Simplicidade | 9 | nenhum passo, tela ou decisão novo para o autor; o `conserto` na tela do Perfil está em linguagem de pessoa |
| Movimento | n/a | sem animação |
| Componentes | n/a | sem componente de UI |
| Acessibilidade | n/a | sem superfície nova |
| Performance | 9 | duas comparações de `String.contains` por frase, em cima de uma chamada de rede de dezenas de segundos |
| Privacidade e autoria | 9 | menos material nosso sai e nada novo entra; o texto do autor só é LIDO pela guarda, nunca gravado nem enviado |
| Estado honesto | 9 | as linhas ficam `indisponivelPorQualidade` porque a medida não existe; o `conserto` diz "falta medir"; guarda que derruba tudo devolve `nil` e a página cai nas perguntas do método |
| Complexidade | 9 | **+71 linhas líquidas em `Traco/`, e ~13 são lógica** — o resto é prompt e doc; um arquivo novo só (a fixture); nenhuma dependência |
| Fora do app | n/a | sem superfície fora do app |
| Relato | 9 | este arquivo, com as duas saídas do instrumento e a fixture nomeada |

## Dívida nomeada e limites

1. **`Sabia.montarInstigar`/`montarContrapor`** (caminho do aparelho) continuam com o
   andaime na carga. A `Politica` não deixa estas duas descerem ao aparelho; o dia em
   que deixar, a separação tem de ir junto. Não mexi: churn de teste em caminho morto.
2. **A guarda de `contrapor` cobre a FORMA da evidência medida**, não toda invenção:
   "produzem ganhos equivalentes em VO2 máx", sem número e sem fonte, passa pela
   guarda e depende do contrato. Deliberado — guarda que julga verdade cala o
   contraponto honesto, que é o defeito oposto.
3. **Achado colateral, não meu para consertar:** o `conserto` de `responder` na tabela
   diz "**o prompt** já mata a invenção de número", e esse texto vai **inteiro para a
   tela do autor** (`PerfilView.restoDa`). "Prompt" é jargão nosso na tela dele. Uma
   linha, dona: quem tocar a Q2-F.
4. **Casos escritos e lidos por quem implementa.** A leitura de casos cegos é do revisor.

## Para o orquestrador juntar as três fixtures

`prova/q4-instigar-contrapor-casos.json` roda como está: `AvaliacaoIA` aceita as
operações `instigar` e `contrapor`, e ambas precisam de
`TRACO_AVALIAR_LIBERAR=instigar,contrapor` (ADR 08z) para alcançar o provedor —
sem isso a sonda bate em `nil` antes da rede.

## Para a Q3 (`N1T1`), avisado no comentário do worktree `main`

O defeito é irmão e resolvi assim, para as duas voltas não divergirem:
(1) o que é NOSSO vai na mensagem de sistema, o pedido leva só o que veio do autor;
(2) guarda de saída **relativa ao autor**, `Sabia.vazaAlheio`. Se a Q3 for filtrar
`N1T1`/`N2T1` no texto, **chame `vazaAlheio` com os IDs dos trechos** em vez de
escrever outra guarda.


---

# Q4-B — o G3 reprovou as duas, e a guarda tinha comprado mudez

**Candidato anterior:** `aec62d4`. **Revisão:** `ferramentas/orca/revisao-q4-instigar.md`
(`511b7e2`). **Medida lida:** `prova/lote09-instigar-contrapor.jsonl` (36 execuções,
6 casos × 3 por operação, `grok-4.3`, 22:21:13Z–22:25:58Z de 09/09, sem erro de
transporte). **Aparelho de trabalho:** `34CC3F94-FDB5-4575-A4F5-80271829A18B`,
encontrado LIGADO (não fui eu quem ligou) e deixado como achei — a lei do preâmbulo
manda não desligar o que não se ligou. **Não encostei no `B91C8DEF`**, não instalei,
não lancei sonda, não usei voz, VoiceOver nem iPad. Toda corrida por
`ferramentas/orca/com-trava.sh`; segurei a trava três vezes, e só isso.

## O que o candidato anterior ganhou, e não é pouco

O andaime **não voltou em nenhuma das 18 execuções** do `instigar`; a evidência
fabricada **não voltou em nenhuma das 18** do `contrapor`. O diagnóstico de 08/09
estava certo. O que caiu foi a conclusão de que ele bastava.

## O ponto 2 primeiro: a guarda estava inocente, a redação é que calou

O caso `q4-instigar-o-autor-escreve-metodo` diz, na voz do autor: *"Sigo um método
de estudo em degraus e travei no segundo degrau: consigo ler, mas não consigo
escrever nada sem consultar a gramática."* As três saídas, lidas do JSONL:

```
rep 1  O que exatamente você consegue ler sem consultar a gramática?
       Por que a escrita exige consulta enquanto a leitura não?  (+2)
rep 2  Como conseguir ler se relaciona com não conseguir escrever…?  (+2)
rep 3  O que impede a leitura de ajudar na escrita…?  (+2)
```

Nenhuma toca o método dele nem o segundo degrau dele.

**Medi de quem era a culpa antes de escrever.** `vazaAlheio` compara com o texto do
autor, e o texto tem "método" e "degrau": a guarda **não derrubou nada** neste caso —
`t.contains("degrau")` e `t.contains("método")` são verdadeiros. Quem comprou a mudez
foi `sistemaInstigar`, que proibia **por nome**: *"Não pergunte sobre o método, sobre
o degrau, sobre a forma da nota"*. O modelo obedeceu — contra o vocabulário da pessoa.

**Conserto:** a proibição passa a ser **por procedência**, que é o que a guarda já era.
O contrato não lista mais palavra proibida; diz *a palavra que ELA escreveu na nota é
DELA, seja qual for* e *proibida é só a palavra que existe aqui neste pedido e não está
na nota dela*.

**E a guarda tinha, sim, um buraco de procedência — o acento.** Autor que digita
"metodo" sem agudo perdia a pergunta sobre o próprio método, porque a lista tinha as
duas grafias e o texto dele só uma. `Sabia.dobrada` dobra acento e caixa antes de
comparar. No mesmo ato **"sábia" saiu da lista**: dobrada ela vira "sabia", verbo de
todo dia — calar *"Como você sabia disso?"* é a recusa covarde que esta guarda existe
para não comprar.

**Os dois lados, em prova** (`aGuardaDerrubaONossoENaoEncostaNoDele`): a mesma pergunta
sobre "o seu método no segundo degrau" **passa** com a nota dele (com e sem acento) e
**cai** com a nota do espanhol, que não tem a palavra.

## O degrau: chega, mas não mandava

A pergunta do dispatch era *não serve ou não chega?*. **Chega:** a sonda passa `degrau`
(`AvaliacaoIA.swift:211` → `Sabia.instigar`) e ele entra na mensagem de sistema em toda
chamada. O JSONL confirma `"entrada":{"degrau":4,…}` no caso. As saídas 0 e 4 do mesmo
texto, lado a lado:

```
degrau 0  O que exatamente você vai fazer nesses quinze minutos…?
degrau 4  O que exatamente você faria nos quinze minutos que tem hoje?
degrau 4  O que pode dar errado se você tentar praticar espanhol com tão pouco tempo?
```

O degrau vinha **solto no fim** de uma lista fixa de buracos — *"buracos, dependências,
termos ambíguos, o que falta decidir, o que pode dar errado"* — que serve igual em
qualquer degrau. O modelo cumpria a lista. *"O que pode dar errado"* estava **escrito no
contrato**, e é literalmente o que o degrau 4 devolveu.

**Conserto:** a lista fixa **saiu**; o bloco vem com rótulo (`O QUE ESTAS PERGUNTAS
COBRAM:`) e por último; o contrato diz que ele **manda** (duas perguntas o cumprem ao pé
da letra); e cada nível diz também **o que NÃO conta como cumprido** — o 4 rejeita por
escrito as três perguntas que devolvia no lugar do limite. `Sabia.sistemaDeInstigar`
existe para provar isso **sem aparelho**: dois degraus, duas mensagens.

## Os outros três

| # | conserto |
|---|---|
| 3 · episódio suposto | o contrato proíbe fato suposto **dentro** da pergunta e manda pedir que ela nomeie |
| 4 · nega a razão sustentada | requisito, restrição e motivo dela são **DADO, não opinião**; nenhuma alternativa pode violá-los, e o contraponto vira o **limite real** da razão dela |
| 5 · renda inventada | `numeroAlheio` (todo número da frase tem de estar no texto dele) + `salario` na lista; `renda`, `juros` e `inflação` ficam **de fora** de propósito — são propriedade geral do mundo, e calá-las é a covardia de novo |

O 5 era **dívida declarada** na ADR anterior. O G3 mostrou a dívida na tela do autor,
e dívida que a pessoa vê não é dívida: é defeito. Fechada.

## O instrumento

**Vermelho** (três mutações no candidato: `numeroAlheio` sempre `false`, `dobrada` sem
dobrar o acento, degrau 4 na redação antiga):

```
✘ Test oDegrauSobeComAPratica() … .contains("NÃO cumpre isto")
✘ Test aPerguntaSobreONossoAndaimeNaoVolta() failed after 0.006 seconds with 4 issues.
✘ Test oContrapontoNaoSeApoiaEmEvidenciaFabricada() failed … with 2 issues.
✘ Test oContrapontoNaoInventaRendaNemNumero() failed … with 2 issues.
✘ Test run with 11 tests in 2 suites failed after 0.015 seconds with 9 issues.
** TEST FAILED **
```

**Verde**, restaurado, suíte integral:

```
✔ Test run with 1010 tests in 162 suites passed after 88.786 seconds.
** TEST SUCCEEDED **
```

Sem aviso novo de compilação (o único aviso do build é o pré-existente de
`NotasView.swift:806`, `Text` + `String`, que não é meu).

## A medida que falta, e por que a fixture não mudou

`prova/q4-instigar-contrapor-casos.json` fica **igual**, de propósito: a régua não
muda entre a reprovação e o conserto, e os 12 casos × 3 trazem **a linha de base
junto** — nenhum caso que já passava pode piorar em silêncio. Roda com
`TRACO_AVALIAR_LIBERAR=instigar,contrapor` (ADR 08z). **Não corri no aparelho**, por
ordem do dispatch: a corrida entra na próxima janela em lote.

## Scorecard desta passada (preenchido por mim; a nota é do revisor)

| dimensão | nota | evidência |
|---|---|---|
| Visão | 8 | ataca os cinco P1 do G3 e devolve a voz do autor; não fecha lacuna do EVOLUCAO — conserto escrito ≠ conserto medido, e por isso não toquei o EVOLUCAO |
| Contrato | 9 | emenda da ADR 09i em SPEC.md, com os cinco defeitos, a causa medida de cada um e o que fica de dívida; `Politica` reescrita com o motivo de 09/09 |
| Correção | 9 | vermelho 9 issues em 11 provas por três mutações atribuíveis; verde 1010/162/0 |
| Jornada real | n/a | esta passada não corre no aparelho por ordem do dispatch |
| Design | n/a | motor puro, nenhuma view tocada |
| Simplicidade | 9 | nenhum passo novo para o autor; `motivo` e `conserto` do Perfil em linguagem de pessoa (64 e 58 caracteres) |
| Movimento | n/a | sem animação |
| Componentes | n/a | sem componente de UI |
| Acessibilidade | n/a | sem superfície nova |
| Performance | 9 | uma varredura de dígitos e duas de `contains` por frase, sobre uma chamada de rede de dezenas de segundos |
| Privacidade e autoria | 9 | o texto do autor só é LIDO pelas guardas; nada novo é gravado ou enviado; a mudança devolve ao autor palavras que eram dele |
| Estado honesto | 9 | as duas linhas seguem `indisponivelPorQualidade` com o motivo novo; o `conserto` diz "falta medir" |
| Complexidade | 9 | **+63 linhas líquidas em `Traco/`, ~14 de lógica** — e dessas, **8 são novas** (`dobrada` 3, `numeroAlheio` 4, o call site 1); `sistemaDeInstigar` é montagem **movida** de dentro do `instigar` para que o degrau se prove sem aparelho. O resto é prompt e doc; **nenhum arquivo novo**, nenhuma dependência, nenhuma abstração sem segundo caso |
| Fora do app | n/a | sem superfície fora do app |
| Relato | 9 | este arquivo, com as saídas reais do JSONL citadas e as duas linhas do instrumento coladas |

## Dívida nomeada, com dono

1. **`montarInstigar`/`montarContrapor`** (caminho do aparelho) continuam com o andaime
   na carga. A `Politica` não deixa estas duas descerem ao aparelho. Dono: quem mudar
   essa linha da tabela.
2. **`fatoQueEleNaoDeu` é lista de termos MEDIDOS**, não teoria da invenção. Se a
   corrida seguinte pegar invenção por outra palavra, é ali que ela entra. Dono: quem
   ler a próxima medida.
3. **O `conserto` de `responder` na tabela diz "prompt" na tela do autor** — jargão
   nosso. Continua de pé, não é meu. Dono: quem tocar a Q2-F.
4. **Casos escritos e lidos por quem implementa.** A leitura de casos cegos é do revisor.
