# MERGE-RESPONDER — os sete consertos entram em `main`, e o sétimo ganha guarda

**Linha do ciclo.** É o **G5** da rodada de prompt do `responder`. Serve à intenção
*"a IA responde ou diz por que não — nunca some, nem responde a pergunta errada"*;
reduz o obstáculo *"sete consertos aprovados e parados em branch"*; e prova-se por
**`origin/main` com os sete dentro** e pela suíte verde com prova de árvore própria.

**Aparelho.** Um só: **`A1DF082C-FC87-4DF9-9F56-F2DA1C084DED`** (teste 4, o de SUÍTE).
**Nos dois aparelhos de CONTA (`B91C8DEF`, `34CC3F94`) não toquei** — nenhum boot,
nenhum install, nenhum `simctl` de escrita, nenhuma sonda, nenhuma leitura de conta.
Uma leitura de arquivo houve, e está declarada na §2: os dylibs mortos que o
`containermanagerd` do `B91C8DEF` guarda em cache, de onde os dois pedidos
reprovados foram recuperados. É leitura de disco do Mac, não uso do aparelho: nada
foi lançado, instalado nem desligado.
**Nenhum `orca emulator kill`. Nenhum simulador criado, apagado ou desligado.**
**Voz, VoiceOver e iPad: nenhum acionado.** **Letra de acessibilidade (§12):
nenhuma — nada foi fotografado nesta volta.**

---

## 1. A mescla — o que conflitou, e como ficou

Trouxe o `main` **para dentro da volta primeiro** (`git merge --no-ff origin/main`,
`3ad638b`), para que o conflito fosse resolvido e a suíte rodasse na árvore que vai
mesclar, não na que foi medida. **Sem reescrever história:** os SHA que os relatórios e
as ADRs citam continuam alcançáveis.

| SHA | o que é | alcançável de `HEAD` |
|---|---|---|
| `5d16beb` | RESPONDER — os sete consertos e a medida das duas reescritas | ✓ |
| `9e45605` | RESPONDER — a linha do Perfil vista em `large` | ✓ |
| `cf72447` | G3-RESPONDER — o veredito do revisor | ✓ |
| `95845ae` | G3-RESPONDER — os quatro acertos deste fecho | ✓ |

**Conflitaram dois arquivos, os dois por texto apensado no mesmo fim — nenhum código:**

- **`SPEC.md`** — `main` apensou a **09y** (P0-CRLF) e a **10a** (TEMPO, o teto como
  piso observado); a volta apensou a **10b**. Fiquei com **as três**, na ordem
  cronológica de apensação: 09y, 10a, 10b. Nada foi descartado.
- **`ferramentas/orca/LETRAS-ADR.md`** — a volta tinha só a linha da **10b**; `main`
  tinha a 10b ainda *"reservada"* mais **10c, 10d, 10e e 10f**. **As reservas de
  `main` venceram** (são o que os outros workers leem) e a linha da 10b passou a
  **`em main`**, o molde que a 09y e a 09z usam — dizer *"reservada, volta viva"* de
  uma ADR que está no spec seria o registro mentindo. Conferido: **cada letra aparece
  uma vez só** (`10a`…`10f`, uma ocorrência cada; nenhuma da série 09 duplicada).

`EVOLUCAO.md`, `Traco/Analise/Grok.swift` e `TracoTests/GrokContratoTests.swift`
mesclaram sozinhos — o último é o encontro das duas voltas no mesmo arquivo: os testes
de teto da **10a** (`Grok.teto == 300`, `esperaObservada == 241`) e a guarda nova do
bruto convivem sem se tocar.

---

## 2. Os quatro acertos que o G3 pediu

### 2.1 Os dois pedidos reprovados voltaram a ser legíveis

O revisor: *"sha identifica — não deixa ler"*. O produto desta volta é **"a próxima
tentativa não repete estas duas"**, e quem for escrever a terceira precisa das duas em
palavras.

**Eles tinham sido apagados de verdade.** A costura que selecionava o braço nunca
chegou a um commit (`git log -S` em `*.swift` devolve só o comentário), o
`prova/10b*/janela.log` guarda o sha e não o texto, e o dylib do `B91C8DEF` já havia
sido reinstalado por outra volta às 15:11. Onde eles estavam:

| texto | de onde veio | caracteres | sha256 | confere com |
|---|---|---:|---|---|
| candidato 1 | `Sabia.swift.bom`, cópia de trabalho de 12:20 — **e** o dylib morto da janela 1 | 3.065 | `20a0b7af694c…` | `pedidoResponderSHA256` das 120 linhas de `prova/10b/10b-candidato.jsonl` |
| candidato 2 | dylib morto da janela 2, recortado por bytes | 3.632 | `72840c9a4c70…` | idem `prova/10b2/10b2-candidato.jsonl` |

Os dylibs mortos ficam em
`…/Devices/B91C8DEF…/data/Library/Caches/com.apple.containermanagerd/Dead/`, que é
onde o simulador guarda o pacote substituído por um install por cima. O recorte foi
por **bytes** (não `strings`, que trunca no acento — lição da volta anterior): achei o
início do literal e varri o comprimento até o sha256 casar com o das corridas. Os dois
casaram **exatamente**, então o que está em git é o texto que as 240 saídas mediram, e
não uma reconstrução parecida.

Ficam em `prova/10b/pedido-candidato-1.txt` e `prova/10b/pedido-candidato-2.txt`,
**sem cabeçalho nosso** — de propósito: `shasum -a 256` no arquivo tem de devolver o
mesmo sha que o JSONL, ou a prova não fecha.

### 2.2 O botão morto saiu do medidor — e não em silêncio

`lote-ia-09d-janela.sh:49` exportava `SIMCTL_CHILD_TRACO_AVALIAR_PEDIDO`, e **nenhum
Swift lê essa variável**. Apagar só a linha deixaria o 6º campo de uma corrida
**aceito e ignorado** — o mesmo defeito com outra roupa: quem o usasse mediria o
pedido ATUAL achando que mediu o anterior. Então o campo **para a corrida**:

```
$ c="x:y:::600:cand2"; IFS=: read -r _s _f _l _m _t _p <<<"$c"; [ -n "${_p:-}" ] && { echo "GUARDA MORDEU: $c"; exit 3; }
GUARDA MORDEU: x:y:::600:cand2          rc=3
$ c="x:y:::600";       IFS=: read -r _s _f _l _m _t _p <<<"$c"; [ -n "${_p:-}" ] && { ... }
corrida de 5 campos PASSA: x:y:::600    rc=0
```

A mensagem diz o que fazer (*"devolva o seletor antes de usá-lo"*) e o cabeçalho do
script aponta para os dois textos guardados, porque é o que a próxima pessoa vai
querer.

### 2.3 A comparação sem base foi corrigida

O relatório dizia que a pergunta real era *"o único lugar onde o candidato 2 é
claramente melhor que a base"* — e a base **nunca foi rodada** nessa pergunta: a
coluna dela é `—` na própria tabela. O que os seis registros comparam é **candidato 2
contra candidato 1** (2 de 3 contra 0 de 3). O 2 de 3 fica; a comparação com a base,
não — e a correção diz em voz alta que a frase anterior estava errada, em vez de
apagá-la.

### 2.4 A guarda que faltava — e por que ela guarda FORMA, não comportamento

O revisor apagou `diagnostico.bruto = msg` e **a suíte inteira passou**, 1038 de 1038.
Não foi descuido de quem escreveu os 13 testes: **o corpo de `Grok.responder` é
inalcançável da suíte por desenho.** `Motores.desligados` é `true` em todo processo de
teste (`XCTestConfigurationFilePath` no ambiente), e é ele que impede a suíte de gastar
a assinatura do autor — função, não defeito. Não há seam entre `textoCompleto(dados)` e
a linha do bruto: sem conta no chaveiro e sem rede, `Grok.responder` devolve `nil` na
primeira linha.

Havia prova de **corrida** (180 de 180 chamadas com `bruto` no JSONL) e nenhuma prova
de **árvore**. A guarda que escrevi é a mais barata que ainda morde: na **janela** do
fonte entre o conteúdo aceito (`let msg = textoCompleto(dados)`) e a memoização
(`memoGrava(chave, msg)`), o desfecho completo e o bruto têm de ser escritos **juntos**.
Fora dessa janela, um campo declarado e nunca escrito é exatamente o defeito — por isso
a regra é por janela e não um `grep` no arquivo.

**E o vigia prova que enxerga na própria execução.** O teste aplica a mutação a si
mesmo: pega a mesma fonte, remove a linha, roda a mesma regra, e exige que ela
**reprove**. Sem isso, um portão que mudou de forma e deixou de achar código passaria
calado — que é o defeito que ele guarda. Duas linhas, e elas fecham a porta pela qual
este mesmo tipo de portão já saiu verde antes (lição do "portão conta a forma certa").

`TracoTests/GrokContratoTests.swift`, `oPortaoPreservaORetornoBrutoQuandoOConteudoVemCompleto`.

---

## 3. O ramo `.semConta`: fechou, e era o mais percorrido do app

O G3: a suíte alcançava **47 das 49** linhas de `perguntarASabia`, e as duas que
faltavam eram `cartao = .semConta` e o `return nil` dela — *"o único ramo que um autor
SEM conta Grok alcança hoje"*. Cabia em pouco, então fechou: desde a 10b `disponivel`
chega por parâmetro, de modo que o ramo é um argumento, não um aparelho.

O teste vale mais do que uma linha de cobertura porque guarda a **ordem**: o `aviso`
que passei é o da **produção** (`Politica.aviso(.responder)`, que hoje não é nil), e
mesmo assim o cartão tem de ser `.semConta`. Sem conta, o autor lê *"sem conta"* — não
o aviso de qualidade de uma operação que ele não pode nem tentar. Nenhuma tarefa abre e
o modelo não é chamado por caminho nenhum (`Issue.record` no executor, que não dispara).

**49 de 49.** `TracoTests/RespostaNaPaginaTests.swift`, `semContaOCartaoDizSemConta`.

---

## 4. O que NÃO entrou, de propósito

- **A regra não mudou.** `responder` continua `indisponivelPorQualidade`. Nenhuma
  linha de `Politica` foi tocada nesta volta.
- **O caso cego NOVO do revisor não foi aberto, não foi rodado e não foi comitado.**
  Ele segue em `~/orca/prova-restrita/responder/g3-cegos-revisor.json`, modo 600,
  sha256 `330e43fd…` — conferido sem abrir o arquivo. Ele vale por ser inédito, e
  gastá-lo aqui seria queimar a prova da próxima rodada.
- **Nenhuma janela de aparelho de conta.** Os dois estavam ocupados (`instigar` e o
  vídeo da superfície) e esta volta não precisa de nenhum: tudo o que ela mede é
  árvore.
- **A dívida de redação do relatório fica nomeada, não consertada.** O achado 5 do G3
  — `ferramentas/orca/responder.md` cita no corpo o título de duas notas reais do
  aparelho da conta, contra a régua que o próprio relatório aplicou ao JSONL — **não
  estava entre as três coisas que esta volta recebeu**, e mexer nele por conta própria
  seria alargar escopo numa mescla. Está escrito na emenda da ADR, na §4 do
  `SPEC.md`, para quem abrir o arquivo. Risco baixo (é o caderno do próprio dono, no
  repositório do próprio dono), mas é dívida.

---

## 5. Instrumento

**Build LIMPO**, na árvore JÁ MESCLADA (`3ad638b`), começou 18:35:39Z:

```
$ ferramentas/orca/com-trava.sh xcodebuild -scheme Traco \
    -destination 'generic/platform=iOS Simulator' clean build
** BUILD SUCCEEDED **
```

**324 ações `SwiftCompile`** (é limpo, não incremental), **0 erros**, **2 linhas de
warning** — as duas o herdado conhecido `Traco/Notas/NotasView.swift:814:30`
(`'+' was deprecated in iOS 26.0`). **Nenhum warning novo.**

**Suíte INTEGRAL no teste 4** (`A1DF082C-FC87-4DF9-9F56-F2DA1C084DED`), 18:36:08Z:

```
$ ferramentas/orca/com-trava.sh xcodebuild test -scheme Traco \
    -destination 'platform=iOS Simulator,id=A1DF082C-FC87-4DF9-9F56-F2DA1C084DED' \
    -parallel-testing-enabled NO
✔ Test run with 1043 tests in 164 suites passed after 153.382 seconds.
** TEST SUCCEEDED **
```

`✘` no log: **0**. `Test … failed`: **0**. `recorded an issue`: **0**.

### A prova de árvore própria — por CONTAGEM e por NOME

**Auditado por NOME, não só por contagem.** `git diff cf72447..HEAD -- TracoTests`
lista **cinco** `@Test` novos desde o candidato que o G3 aprovou, e os cinco aparecem
um a um no log:

| teste novo | de quem | no log da corrida |
|---|---|---|
| `oPortaoPreservaORetornoBrutoQuandoOConteudoVemCompleto` | **meu** — a guarda do bruto | `✔ … passed after 0.001 seconds` |
| `semContaOCartaoDizSemConta` | **meu** — o ramo `.semConta` | `✔ … passed after 0.002 seconds` |
| `oTetoDoPedidoGanhaDoTetoDaSessao` | da **10a** (TEMPO), veio no `main` | `✔ … passed after 6.021 seconds` |
| `arquivoSoSaiDaEntradaQuandoOAppLeuTudo` | da **09y** (P0-CRLF), veio no `main` | `✔ … passed` |
| `oQueOAppLeuInteiroContinuaPodendoSairDaEntrada` | da **09y** (P0-CRLF) | `✔ … passed` |

E a contagem fecha dos dois lados: `@Test` **declarados na árvore** são **1038 em
`cf72447`** e **1043 em `HEAD`** — o mesmo 1038 → 1043 que o executor contou. Declarado
e executado batem, que é a diferença entre "a suíte passou" e "a MINHA suíte passou".

Por suíte: `RespostaNaPaginaTests` executou **14** testes (eram 13), todos `✔`; e
`GrokContratoTests` fechou verde com a guarda nova e os testes de teto da 10a no MESMO
arquivo — o ponto exato onde as duas voltas se tocam, e que ninguém tinha medido junto.

### As duas guardas novas, provadas por MUTAÇÃO, com as irmãs ao lado

Mesma trava, mesmo teste 4, 18:45:08Z–18:46:29Z. *Vigia que reporta zero tem de provar
que enxerga* — estes dois acusaram, e acusaram sozinhos.

| mutação | quem acusou | irmãs verdes |
|---|---|---:|
| `diagnostico.bruto = msg` **apagada** de `Grok.swift` | `oPortaoPreservaORetornoBrutoQuandoOConteudoVemCompleto`, com **duas** issues | 5 de 5 em `GrokContratoTests` |
| `cartao = .semConta` vira `cartao = .pergunta(q)` em `Sessao.swift` | `semContaOCartaoDizSemConta` | 13 de 13 em `RespostaNaPaginaTests` |
| árvore restaurada, as duas suítes | — | **20 de 20 verdes** |

As linhas coladas do log:

```
✘ Test oPortaoPreservaORetornoBrutoQuandoOConteudoVemCompleto() recorded an issue at
  GrokContratoTests.swift:161:9: Expectation failed: (saida → " else { return nil } …
✘ Test oPortaoPreservaORetornoBrutoQuandoOConteudoVemCompleto() recorded an issue at
  GrokContratoTests.swift:165:9: Expectation failed: (mutante.count → 16895) < (fonte.count → 16895)
✘ Test run with 6 tests in 1 suite failed after 6.034 seconds with 2 issues.

✘ Test semContaOCartaoDizSemConta() recorded an issue at
  RespostaNaPaginaTests.swift:236:9: Expectation failed: (s.cartao → .pergunta("Qual é o prazo?")) == .semConta
✘ Test run with 14 tests in 1 suite failed after 0.105 seconds with 1 issue.

✔ Test run with 20 tests in 2 suites passed after 6.125 seconds.   ← árvore restaurada
```

**A segunda issue da mutação 1 é a autoconferência funcionando**, e vale dizer por quê:
com a linha real já apagada, a mutação que o teste aplica a si mesmo **não acha nada
para remover** — `mutante.count == fonte.count` — e ele diz isso em voz alta em vez de
concluir *"o portão está ok"*. É a diferença entre um vigia que não achou nada porque
não há nada e um que não achou nada porque parou de olhar.

---

## 6. A mescla em `main`

```
$ git -C /Users/vitorepf/develop/traco-ios merge --no-ff Vitorepf/responder
```

`--no-ff` mesmo sendo possível avançar reto, porque o `main` já tinha sido trazido para
dentro da volta: a mescla é o registro de que estes quatro commits entraram juntos, e
sem ele a rodada inteira desapareceria na linha do `main`.

**Os quatro commits que entram**, lidos um a um antes de empurrar:

| SHA | o que é |
|---|---|
| `5d16beb` | RESPONDER — a medida das duas reescritas e os sete consertos de rota |
| `9e45605` | RESPONDER — a linha do Perfil, vista em `large`, sem o `conserto` |
| `cf72447` | G3-RESPONDER — o veredito: os sete passam por mutação, o placar confere |
| `95845ae` | G3-RESPONDER — os quatro acertos deste fecho |
| `3ad638b` | MERGE — o `main` das 15h20 trazido para dentro da volta |

---

## 7. Estado honesto, e o que esta volta NÃO é

**Não há scorecard das cinco dimensões de IA aqui, e não é omissão:** esta volta **não
mediu nenhuma saída de modelo**. Ela não abriu janela de aparelho de conta, não fez
chamada ao provedor e não leu resposta nova. O scorecard de IA desta rodada é o do G3
(`ferramentas/orca/revisao-responder.md`, §2) e continua valendo palavra por palavra:
**nenhuma dimensão chega a 9 em nenhum braço**, e `responder` fica cortada.

O que esta volta entrega é de engenharia, e cabe em quatro linhas:

| | estado |
|---|---|
| os sete consertos de rota | **em `main`**, com a suíte integral verde na árvore mesclada |
| o sétimo, que não tinha guarda | **guardado**, e a guarda provada por mutação |
| o ramo `.semConta` | **fechado** — `perguntarASabia` sai de 47 para **49 de 49** |
| os dois pedidos reprovados | **legíveis em git**, com sha que confere com as corridas |

**Produzido, executado e observado.** *Executado* e *observado*: o build, a suíte, as
duas mutações e o `git diff` de nomes — tudo colado acima. *Não observado nesta volta:*
nenhuma tela. Não houve captura porque não há superfície nova — a linha do Perfil que
mudou já foi fotografada em `large` na volta anterior
(`ferramentas/orca/10b-perfil-responder-fica-na-lista-large.png`) e nada nesta mescla a
altera. **Motor sem tela não conta como entregue; guarda de suíte não tem tela para
ter, e é isso que ela é.**

**Limite do instrumento, declarado e sem desconto de nota.** A guarda do bruto vigia a
**forma** do portão, não o comportamento em execução — porque o comportamento é
inalcançável da suíte por um desenho que existe para proteger a conta do autor. Quem
quiser a guarda comportamental precisa de um seam de transporte em `Grok.responder`
(um `URLProtocol` de teste, ou a injeção do token), e isso é volta própria com risco
próprio. **Fato a registrar, não nota a descontar** — e agora, ao menos, apagar a linha
fica vermelho.
