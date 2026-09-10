# G4 — a conversa com a sábia (ADR 10f, candidato `caec065`)

**PASSA.** Os seis itens que o dono reprovou às 13h58 estão consertados na tela e provados abaixo, item a item. A dedupe por texto é conserto, não mentira: ela corre ANTES do pedido viajar. Fica UMA dívida que o dono vai ver e que não é desta tela: a linha "Referência:" cita a nota inteira quando a nota não tem título. Está nomeada, com o conserto de uma linha e o dono dele.

Juiz: Fable 5.1, sessão própria, teste 4 `A1DF082C` (o de suíte; nada instalado em aparelho de conta). Binário meu: build incremental de `caec065`, `cmp` do instalado antes e depois da medida: **É O MEU**. Letra `large` antes e depois (`simctl ui content_size: large`), tema e orientação intocados. Contagem de warning não vale (incremental): só o herdado (`NotasView.swift:835`) recompilou.

## Os seis itens, com a prova

| o que ele viu | conferido | prova |
|---|---|---|
| cartão "a sábia pensa…" só com Fechar | **tempo, cancelar e a pergunta visível** | `05-pensando-large.png`: pergunta como título, "a sábia pensa…", "Parar de esperar"; relógio do 4º s em diante e ANDANDO: `testAEsperaNasNotasMostraPensandoTempoEParar passed (10.930 s)` |
| CAIXA ALTA com jargão | **a pergunta dela, em letra de gente** | `07-resposta-large.png`; o teste afirma `label BEGINSWITH 'A SÁBIA'` ausente |
| "CONTINUA" | **inteira, sem dobra** | `07`/`08`: a resposta toda; `aRespostaNaoTemTeto() passed` (zero `.frame(maxHeight:)` nos dois arquivos, com sonda irmã) |
| a mesma nota três vezes | **uma linha "leu N notas suas", abre em títulos tocáveis, uma vez cada** | `09-fontes-large.png`; teste: 4 fontes → 4 botões `fonte-sabia-notas` |
| "serviu / não serviu" soltos | **um controle, fio com ar, alvos de 44 pt** | `g4-cauda-topo-large.png` (MEU binário — a captura do autor às 15h40 ainda mostrava o fio colado; o conserto está no candidato) |
| dois Fechar | **um só, na topbar** | os dois testes de UI contam `label == 'Fechar'` == 1 |

## A avaliação sobrevive à troca de aba — confirmado por mutação

Mutei `NotasView` para guardar `avaliadas` num `@State` da view (3 usos trocados) e rodei só o teste: **vermelho na linha certa** — `EsperaComEstadoUITests.swift:103: XCTAssertFalse failed - trocar de aba ofereceu o retorno de novo`, `** TEST FAILED **`. Revertido (`git checkout`), árvore igual a `caec065`.

## A dedupe por texto: conserto, e a tela diz a verdade

A premissa "três viajaram, uma aparece" **não se sustenta no código**: `Sessao.semRepetida` é aplicada em `contextoDasNotas` (`Sessao.swift:678`), ANTES de o pacote ser montado. O pacote leva `pacote.fontes`, devolve-as em `enviadas` (`FonteNotas.swift:187`), e a tela mostra exatamente `retorno.enviadas` (`Sessao.swift:726`). Logo "leu 2 notas suas" = 2 viajaram. O contrato do `responder` em `main` (a divulgação corresponde ao que viajou) está cumprido. As dependências ficam só na nota enviada: editar uma gêmea não enviada não recolhe a resposta — correto. `aMesmaNotaTresVezesViraUma() passed`, com a irmã que não acusa. O "(edição <data>)" do `interpretar` resolve outro caso — títulos iguais com textos diferentes — e ali as duas notas continuam viajando e aparecendo, cada uma na sua linha.

## A cauda: o número

Teto do PEDIDO: o texto do modelo tem ≤ 900 grafemas (`FonteNotas.swift:145`); somam-se "Referência:" com os títulos e até três avisos fixos (88, 126 e 114 grafemas). A folha vive num `ScrollView` (`NotasView.swift:161`): **rola; nada empurra a lista, porque a lista não está na tela**. Medido no teste 4, `large`, com a resposta mais longa das 18 corridas (568 grafemas, 4 fontes fechadas): cabe numa tela com o controle de retorno inteiro acima da linha do pé; rolada ao fim sobram ~30 pt (`g4-cauda-topo/fim-large.png`). Com as fontes abertas o retorno cai abaixo da dobra e o teste rola até ele. O único sem-teto real é o TÍTULO da fonte, que é a primeira linha da nota — o item seguinte.

## O que fica nomeado

1. **"Referência:" cita a nota inteira** quando a nota não tem linha de título (`tituloNaLista` = primeira linha, sem teto). Em `07`/`09` o mesmo parágrafo aparece três vezes: paráfrase, "Referência: “…”" e a fonte (cortada em 2 linhas). É a tela citando TEXTO onde devia citar NOTA — não nesta linha das fontes, mas na de cima. O conserto é uma linha (`VozDoAutor.truncar` sobre `fonte.titulo` em `interpretar`, `FonteNotas.swift:170`), na rota do `responder` (IA/arquiteto), não neste front. **Fechar antes de o dono ver de novo.**
2. **O controle de retorno pesa mais do que diz**: `BotaoCompacto` põe `Tema.barra` no rótulo e vence o `Tema.meta` do `HStack` — na captura "serviu | não serviu" é maior e mais pesado que "leu 4 notas suas". O autor escreveu "a cor é a do texto de apoio: o retorno é opcional"; o peso desmente. Uma linha (`font` no estilo ou `.discreto`).
3. `LETRAS-ADR.md` diz "Próxima livre: 10f" com 10f já escrita — corrigir junto do próximo código, sem commit só de doc.
4. "Guardar como nota": a segunda metade ("some") está cumprida — Fechar zera trocas, fontes e avaliação (`ConversaNotas.fechar`); a primeira espera `OrigemNota` (arquiteto). Aceito como dívida: `textSelection` já dá o caminho do autor (ADR 02o).
5. Lente, Página e Perfil só herdaram a superfície e não foram fotografados. Aceito como escopo declarado; **nenhuma dessas rotas volta ao Perfil por este G4** — cada uma passa aqui com a sua captura.
6. Astra no G0 não entrou: limite de instrumento, não desconta. A suíte de `main` roda um caso em XXXL (`EscritaVisivelTests`, herdado de `423789e`): fora deste candidato, mas contra a §12.

## Instrumento

Suíte integral no teste 4: `✔ Test run with 1033 tests in 164 suites passed after 152.061 seconds.` / `** TEST SUCCEEDED **`, árvore própria provada por `aRespostaNaoTemTeto`, `oModoDePerguntarNasceDoGestoOuDaConversa`, `aMesmaNotaTresVezesViraUma`. UI: `Executed 4 tests, with 0 failures` (`EsperaComEstadoUITests` 2/2, `PerguntaSobreviveUITests` 2/2). Tudo sob `com-trava.sh`. A árvore de AX do `orca emulator ax` veio vazia (0 elementos, duas vezes) — a medida da cauda é por captura e pelo teste de UI, que lê frames.

**Se passar, as operações com mérito aprovado podem voltar — com a dívida 1 fechada antes, porque é ela que o dono vai ler primeiro.**
