# V17-B — a garantia sai da tela e vira invariante do documento

A revisão independente da V17 (`revisao-v17-artefato.md`) passou nos **sete
pontos** do contrato e reprovou por dois P1 com a **mesma doença**: a garantia
existia na TELA e não no agregado. Esta volta move as duas para onde ninguém as
contorna, e paga a dívida de Simplicidade na ordem que o revisor exigiu.

## Os três consertos

### 1. [P1] A unicidade e a semântica da leitura são do documento

Antes: `OficinaTrabalho.conferirEAdaptar` impedia a repetição
(`OficinaTrabalho.swift:372`) e `DocumentoTrabalho.validarAjuste` só conferia que
o `conferenciaID` **existia** na tentativa. Uma segunda rota, uma importação ou
uma regressão de chamador criavam a N+2 da mesma leitura.

Agora, em `validarAjuste` — que roda em `iniciarPedido` **e** em `validar()`,
portanto também na leitura do disco:

- `necessidadePercebida` exige **critério apontado** (`!criterioIDs.isEmpty`):
  "percebi" sem dizer o quê não é percepção;
- a leitura citada tem de estar **concluída**, e **cada critério citado tem de
  ser divergência nela** — critério que a leitura deu por atendido não sustenta
  reescrita;
- o mesmo `conferenciaID` **não aparece em dois** `Pedido.ajuste`.

A **contestação** é checada em `iniciarPedido`, e não em `validar`, de propósito:
uma contestação chega DEPOIS da versão que ela explica, e recusar o documento
inteiro por isso apagaria a história. O ajuste NOVO apoiado numa leitura
contestada é recusado; a versão que já nasceu dela continua guardada e explicada.

Teste da **N+2 recusada** (colado abaixo, junto do resultado).

### 2. [P1] O documento não troca debaixo de quem edita

Duas metades, porque uma só seria de novo guarda de tela:

- **Na folha:** `preparacaoEmCurso` passou a contar `adaptando` — entre a leitura
  da tentativa e a versão seguinte **não existe `pedidoAtivo`**, e era por essa
  fresta que "Editar esta versão" abria. Tocar leva ao progresso em curso, como
  toda ação que compete com ele. O mesmo guarda cobre a preparação comum, que
  tinha a mesma corrida e ninguém tinha visto.
- **No documento:** `guardarVersaoHumana(_:base:)` recusa guardar sobre uma base
  que já não é a versão vigente. Um texto escrito sobre a N não é guardado como
  resposta à N+1. `nil` = base não declarada (importação, registro antigo) — e aí
  ninguém reconstrói o que a pessoa estava lendo.

A outra ponta da corrida já estava fechada e continua: `receber` exige o pedido
`preparando` e a base igual à versão vigente, e `guardarVersaoHumana` cancela o
pedido — é o que `editarIntencaoOuVersaoDuranteEsperaRecusaEntregaObsoleta`
(TrabalhoTests) prova desde antes.

### 3. [Simplicidade 7] Primeiro a causa do autor, depois o corte

O revisor achou o defeito da minha proposta anterior: "Adaptar o próximo
exercício" era o **único chamador de UI** que criava
`Pedido.ajuste(gatilho: .pedidoDoAutor)`. Cortá-la teria apagado a via.

Na ordem: **primeiro** `TrabalhoView.causaDoPedidoEscrito` dá ao pedido que o
autor ESCREVE a mesma causa explícita — gatilho `pedidoDoAutor`, motivo = o texto
dele, **sem apontar evidência nenhuma** (ele escreveu um pedido, não disse a qual
tentativa responde; deduzir seria inventar causalidade). Vale nas duas rotas do
campo ("Preparar exercício com IA" e "Adaptar exercício aos relatos"), dentro da
prática e com exercício vigente — preparar não é ajustar, e a primeira versão não
nasce de ajuste nenhum.

**Depois** a cápsula enlatada saiu. A seção Praticar volta de **quatro para três**
cápsulas (`v17b-a-tres-capsulas.png`) e o anúncio da versão diz "A pedido seu."
seguido do que o autor escreveu (`v17b-b-a-pedido-seu.png`).

Blast radius contido de propósito: fora da prática o campo continua chamando
`gerar` **sem** ajuste. Transformar toda preparação em ajuste mudaria a montagem
do contexto de todo Trabalho delegado e faria um histórico longo cair em
`ajusteIndisponivel` onde hoje ele trunca — regressão que ninguém pediu.

## Prova

```
** BUILD SUCCEEDED **                     (0 warning:)
✔ Test run with 912 tests in 145 suites passed after 9.933 seconds.
** TEST SUCCEEDED **
```
Antes desta volta: 909 testes em 145 suítes. Três testes novos, todos em
`TracoTests/AjusteDoExercicioTests.swift`:

```
AjusteDoExercicioTests/aMesmaLeituraNaoSustentaUmSegundoAjusteNoProprioDocumento()  Passed
AjusteDoExercicioTests/editarDuranteAAdaptacaoNaoTrocaODocumentoDebaixoDaPessoa()   Passed
AjusteDoExercicioTests/oPedidoEscritoPeloAutorRegistraAPropriaCausa()               Passed
```

```
$ git diff --shortstat
 5 files changed, 281 insertions(+), 24 deletions(-)
```

Um teste existente teve o DADO corrigido, não o julgamento: a causa de
`aCausaQueNaoCabeDeixaOAjusteIndisponivelEPreservaOExercicio` passou a apontar o
critério divergente, como a fábrica de produção sempre fez. O teste continua
sendo sobre orçamento.

### Capturas

Todas por `xcrun simctl io B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9 screenshot`,
sobre um documento **plantado** e o app lançado com `-ensaio-oferta-da-pratica`.

| arquivo | o que prova |
|---|---|
| `v17b-a-tres-capsulas.png` | a seção Praticar com **três** cápsulas: "Conferir minha tentativa", "Conferir e adaptar o exercício", "Nova tentativa". A enlatada saiu |
| `v17b-b-a-pedido-seu.png` | "Nesta versão" de uma versão nascida do pedido ESCRITO: "A pedido seu. Quero um exercício mais curto, com uma frase só, ainda sobre me apresentar." |
| `v17b-c-campo-do-pedido.png` | a via que substituiu a cápsula: o campo "O que você quer praticar?" e "Preparar exercício com IA" |

## Instrumento — o que foi limite, e o que não foi

- **Segurei a trava** (`ferramentas/orca/com-trava.sh`) em todo build, teste e em
  **toda** sessão de `orca emulator`. Helper solto ao fim
  (`orca emulator kill --device B91C8DEF`). O simulador ficou ligado — não fui eu
  quem o ligou.
- **Só o B91C8DEF.** O `C2416CBC` (conta Grok do dono) não foi tocado: nem
  `erase`, nem `install`, nem teste, nem captura.
- **Toda medida por árvore de AX foi conferida contra `simctl io` do mesmo UDID**,
  no mesmo instante — as três capturas são a conferência das três leituras.
- **Rolagem realimentada.** O ganho do arrasto no `orca emulator` mediu **15 a 28
  vezes** o deslocamento pedido nesta folha, e muda com o conteúdo: rolei medindo
  o alvo pela árvore a cada passo (`/tmp/rolar.sh`, descartável). Confirma o
  achado de 08/09.
- **O bloqueio da edição NÃO se fotografa neste aparelho.** Sem conta Grok,
  `adaptando` dura milissegundos e um pedido ativo é **interrompido na abertura**
  do documento (`OficinaTrabalho.init`), então não existe estado estável a
  capturar. Está provado por teste e por código, não por captura. Isto é limite do
  instrumento, e está declarado na ADR.
- **Documento plantado, não gerado** — o mesmo caminho da V17: um teste
  descartável montou o `DocumentoTrabalho` pelos mutadores REAIS (inclusive
  `causaDoPedidoEscrito`), o JSON foi para o `default.store` do App Group, e o
  teste foi apagado antes do commit. Portanto esta volta **não** afirma nada sobre
  a qualidade semântica do exercício adaptado.
- **Não trouxe `main`** e não mesclei nada. Não toquei em `Traco/Caderno/**`,
  `Traco/Pagina/**`, `TracoWidget/**`, `Traco/Perfil/**` nem `Traco/Tema.swift`.
- Nada de maestro. Nenhuma rotação, nenhum tamanho de letra alterado.

## Scorecard (preenchido por mim; a nota final é do revisor)

| dimensão | nota | por quê |
|---|---:|---|
| Visão | 9 | não muda a visão: paga a dívida que a revisão apontou e mantém a lacuna do provedor real declarada onde já estava |
| Contrato | 9 | ADR 08k curta e específica; o invariante recusa N+2, leitura inconclusiva, critério atendido e leitura contestada — e diz por que a contestação é checada no nascimento e não em `validar` |
| Correção | 9 | 912 verdes, 0 avisos; os dois P1 têm teste que **morde** (tirar o guarda derruba o teste), e a corrida da edição é exercida de ponta a ponta |
| Jornada real | 8 | três capturas da tela viva sobre documento plantado; o bloqueio da edição não se fotografa neste aparelho e está declarado. A jornada com provedor real segue sendo da frente Q |
| Design | 9 | a folha perdeu uma cápsula concorrente e não ganhou nenhuma; o anúncio da causa do autor usa a seção que já existia |
| Simplicidade | 9 | quatro cápsulas viraram três, o corte veio DEPOIS da via; o guarda da edição reusa `preparacaoEmCurso` em vez de criar outro caminho |
| Movimento | n/a | nenhuma animação nova |
| Componentes | 9 | nenhum componente, tela ou dependência nova; `causaDoPedidoEscrito` é `static` para ser exercida sem SwiftUI |
| Acessibilidade | 9 | o bloqueio **anuncia** o motivo (`anunciar`) antes de rolar ao progresso, como as outras rotas travadas; nenhum controle novo |
| Performance | n/a | não toca lista, parser nem editor |
| Privacidade e autoria | 9 | a causa registrada do pedido do autor é o texto DELE; nenhuma evidência é apontada por dedução |
| Estado honesto | 9 | o limite do instrumento está dito na ADR e aqui; o teste que teve dado corrigido está nomeado |
| Complexidade | 9 | +281/-24 em cinco arquivos, e a mudança é de guarda de tela para invariante — menos autoridade espalhada, não mais |
| Fora do app | n/a | nada de widget, Intent ou Live Activity |
| Relato | 9 | tudo que afirmo aqui tem linha de teste, captura ou arquivo citado |
