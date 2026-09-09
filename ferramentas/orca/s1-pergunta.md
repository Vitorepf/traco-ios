# S1 — a pergunta interrompida não some sem dizer nada

**Branch:** `Vitorepf/volta-s1-pergunta` · **ADR:** 2026-09-09c ·
**Aparelho:** iPhone 17 Pro (teste 4) `A1DF082C-FC87-4DF9-9F56-F2DA1C084DED`,
único da volta, ligado por mim e desligado por `simctl shutdown` no fim.
**Trava:** todo `xcodebuild`, `xcodebuild test` e toda sessão de `orca emulator`
passou por `ferramentas/orca/com-trava.sh`.

## Linha do ciclo (G0)

**Ciclo:** multiplicar a mente — o autor pergunta e continua a vida.
**Intenção:** a pessoa não perde o que estava esperando sem que nada diga.
**Obstáculo:** a pergunta interrompida some ao trocar de aba, porque `RaizView`
recria a `NotasView`. **Lacuna do RUMO:** linha 193, fechada nesta volta.

## O defeito estava VIVO — conferido na tela antes de tocar em código

A auditoria é datada, então a primeira coisa foi a tela viva, com o binário de
`cce6beb` (o HEAD do branch, sem conserto nenhum), instalado por
`simctl install` no meu UDID:

| passo | captura |
|---|---|
| perguntar nas Notas → cartão com "o que eu aprendi ontem / a sábia não respondeu / **Repetir pergunta**" | `s1-01-antes-cartao-na-tela.png` |
| Calendário → Notas: **não sobrou nada** — nem cartão, nem pergunta, nem busca | `s1-02-antes-sumiu-ao-voltar.png` |

A árvore de AX do mesmo instante da segunda captura não trouxe
`Repetir pergunta`, `Cartão da sábia` nem `a sábia não respondeu` — e a captura
do mesmo instante confirma a ausência na tela, que é o que fecha a prova
(ausência na árvore sozinha não prova nada).

**O defeito não tinha caído sozinho.** Não é o caso da R1.

## Vermelho antes do verde, no mesmo aparelho

`TracoUITests/PerguntaSobreviveUITests.swift` (novo, 2 testes) toca a tela de
verdade: abre as Notas, escreve, pergunta, vai ao Calendário e volta.

**Antes do conserto** (`-only-testing:TracoUITests/PerguntaSobreviveUITests`):

```
Test Case '-[TracoUITests.PerguntaSobreviveUITests testBuscaEmEdicaoSobreviveATrocaDeAba]' started.
.../PerguntaSobreviveUITests.swift:58: error: ... XCTAssertEqual failed: ("Optional("vazio")") is not equal to ("Optional("o que eu aprendi ontem")") - o que a pessoa estava escrevendo sumiu ao trocar de aba
Test Case '-[TracoUITests.PerguntaSobreviveUITests testBuscaEmEdicaoSobreviveATrocaDeAba]' failed (12.718 seconds).
Test Case '-[TracoUITests.PerguntaSobreviveUITests testCartaoDaPerguntaSobreviveATrocaDeAba]' started.
.../PerguntaSobreviveUITests.swift:78: error: ... XCTAssertTrue failed - o cartão da sábia sumiu ao trocar de aba — a pessoa perdeu o que esperava sem que nada dissesse
Test Case '-[TracoUITests.PerguntaSobreviveUITests testCartaoDaPerguntaSobreviveATrocaDeAba]' failed (19.748 seconds).
```

**Depois do conserto**, mesmo comando, mesmo aparelho:

```
Test Case '-[TracoUITests.PerguntaSobreviveUITests testBuscaEmEdicaoSobreviveATrocaDeAba]' passed (12.235 seconds).
Test Case '-[TracoUITests.PerguntaSobreviveUITests testCartaoDaPerguntaSobreviveATrocaDeAba]' passed (13.269 seconds).
	 Executed 2 tests, with 0 failures (0 unexpected) in 25.503 (25.505) seconds
```

### Um verde que não valia, apanhado no meio do caminho

A **primeira** corrida do teste do cartão passou verde **sem visitar o lugar do
defeito**: com o campo de busca em foco, `tecladoAberto` esconde a barra de
navegação inteira, e o toque em `aba-calendario` caiu numa **tecla** (o texto
digitado voltou como `"...ontem**td**"`). O teste passou a **arrastar a lista**
para soltar o teclado e a **exigir `calendario-titulo` na tela** como
pré-condição: se a aba não trocou, o teste é vermelho e diz isso.

## O conserto: 3 linhas, na `Sessao`

`RaizView` monta o arquivo num `switch` de `sessao.abaArquivo`
(`Traco/App/RaizView.swift:34`), e trocar de aba **destrói** a `NotasView`. Com
ela morria o `@State private var conversaNotas = ConversaNotas()`.

A intenção certa já estava escrita no próprio `ConversaNotas.interromper()` —
*"sair da tela não perde o pedido interrompido nem o rascunho seguinte"*. Era o
`@State` que a desmentia: guardava a pergunta em `.interrompida(pergunta)` num
objeto que morria no quadro seguinte.

```swift
// Traco/App/Sessao.swift
let conversaNotas = ConversaNotas()

// Traco/Notas/NotasView.swift
private var conversaNotas: ConversaNotas { sessao.conversaNotas }
...
text: Bindable(conversaNotas).entrada,
```

**Uma guarda no lugar certo, não uma por caminho.** Todo o estado da conversa
veio junto — pergunta guardada, trocas já respondidas, aviso de "sem conta",
títulos citados e a busca em edição. Remendar só o caminho do relato teria
deixado as irmãs quebradas.

## Prova viva depois do conserto

Capturas por `simctl io` do meu UDID, **filmadas durante a corrida do XCUITest**
(o helper do `orca emulator` perde a árvore de AX ao dirigir o Traço; a captura
não depende dele):

| quadro | o que mostra |
|---|---|
| `s1-03-depois-cartao-na-tela.png` | Notas com o cartão: pergunta + "Repetir pergunta" |
| `s1-04-depois-calendario.png` | Calendário na tela — **a aba trocou de verdade** |
| `s1-05-depois-continua-ao-voltar.png` | de volta nas Notas: o cartão **continua lá**, idêntico |

## Honestidade: preservar foi possível em todos os caminhos

A régua admitia dois desfechos — a pergunta sobrevive, ou a tela **diz** que se
perdeu. Preservar foi possível em todos os caminhos, então nada precisa ser
dito, e **nenhum pixel novo entrou**. A tela depois da volta é idêntica à de
antes de sair.

## O que mais a recriação apaga, medido e declarado

Procurei todos os estados que morrem com a view, não só o que o relato citou:

| estado | some? | entrou nesta volta? |
|---|---|---|
| `conversaNotas` (pergunta, trocas, "sem conta", títulos, busca em edição) | **sim** | **sim** — o conserto |
| `filtro` (chip), `filtroDominio`, `ordem`, `escolhidas` (lote) | sim (medido na tela: o chip volta a "Todas") | **não** — outra classe: a tela **mostra** que voltaram ao padrão no mesmo quadro, o chip aceso é visível. Não é "sumir sem dizer nada". Anotados. |
| `peloSentido`, `tarefaSentido`, `haMaisChips`, `avaliada` | sim | não — derivados, recalculam sozinhos |
| `versoesDe`, `redeDe`, `serieDe`, `contextoURL`, `mostrarTrabalhos`, `confirmarLote` | sim | não — folhas fechadas, sem estado esperado por trás |

**Achado colateral, registrado e não consertado** (fora do escopo, e a área do
teclado não é minha): com o campo de busca em foco, a barra de navegação some
inteira e **não há como trocar de aba sem antes soltar o teclado**.

## Suíte integral

Primeira corrida **não é resultado** — runner travado antes de conectar:

```
Testing failed:
	Traco (15021) encountered an error (The test runner hung before establishing connection.)
** TEST FAILED **
```

Repetida (mesmo comando, `-parallel-testing-enabled NO`, depois de reciclar o
simulador):

```
✔ Test run with 973 tests in 156 suites passed after 54.417 seconds.
** TEST SUCCEEDED **
```

`grep -c warning:` na saída colada: **0**.

## Design — as seis fases (DIRETRIZ §7)

Rota do `design-router`: **ajuste local**, começando pela **fase 5, auditar antes
de tocar**, porque a tela existe. Nenhum pixel, token ou componente novo.

1. **Ancorar** — pessoa: o autor perguntou e foi viver a vida. Tarefa: retomar o
   que pediu. Resultado observável: o cartão continua no lugar. Restrição: a
   tela não pode mudar de forma; o defeito é de estado.
2. **Sistema** — nada criado. `Tema` e `Traco/Componentes` intocados; o cartão
   da sábia e o campo de busca são exatamente os que já existiam.
3. **Construir** — 3 linhas, no stack existente, sem wrapper e sem dependência.
   `+14 −2` linhas em dois arquivos de produção.
4. **Mover** — nenhuma animação nova. As duas `.animation(...)` do cartão
   continuam ligadas a `conversaNotas.estado`/`.semModelo`, com `Tema.corte` e
   `reduzido: reduceMotion` intactos. **Ganho de movimento:** o cartão que antes
   desaparecia sem transição ao voltar agora simplesmente **não desaparece**.
5. **Julgar (auditar antes de tocar)** — a auditoria veio primeiro: defeito
   confirmado vivo na tela (`s1-01`/`s1-02`) e o inventário dos outros estados
   que a recriação apaga, na tabela acima.
6. **Portão** — vermelho→verde no mesmo aparelho, prova viva em três quadros,
   suíte integral verde com 0 warnings.

### Curva-zero, medida em TOQUES E GESTOS

Tarefa: *retomar a pergunta feita antes de sair da tela*.

| | antes | depois |
|---|---|---|
| toques para retomar | **2** (campo + enviar) | **1** ("Repetir pergunta") |
| redigitação | a frase inteira (23 caracteres) | **nenhuma** |
| memória exigida | **lembrar o que perguntou** — a tela não guardava rastro | nenhuma: a pergunta está escrita no cartão |
| gestos novos | — | **nenhum** |

Nenhum toque, gesto, passo, decisão ou tela foi acrescentado em qualquer
caminho. Poder avançado ("Fechar" descarta a conversa) continua no mesmo lugar.

## Scorecard (preenchido por mim; a nota é do revisor independente)

| dimensão | como está | evidência |
|---|---|---|
| Visão | fecha a lacuna nomeada do RUMO 193, ciclo "multiplicar a mente" | linha G0 + diff do RUMO |
| Contrato | ADR 2026-09-09c no SPEC, letra reservada no LETRAS-ADR, RUMO fechado | diff dos três |
| Correção | 2 XCUITest vermelhos antes / verdes depois no mesmo aparelho; suíte 973/973 | linhas coladas acima |
| Jornada real | os três estados vistos na tela (cartão, Calendário, volta com cartão) | `s1-01`…`s1-05` |
| Design | seis fases citadas acima; nenhum token, componente ou pixel novo | seção Design |
| Simplicidade | 2 toques + redigitação → 1 toque; nada acrescentado | tabela curva-zero |
| Movimento | nenhuma animação nova; as existentes intactas com `reduceMotion` | diff |
| Componentes | nenhum componente criado nem duplicado | `+14 −2` em dois arquivos |
| Acessibilidade | **n/a — nenhum elemento, rótulo ou layout mudou**. Os anúncios de VoiceOver da conversa (`.onChange(of: conversaNotas.estado)`) continuam ligados ao mesmo estado, e agora sobrevivem à volta junto com ele. VoiceOver falado não foi acionado: é limite declarado, por ordem do dono | diff + árvore de AX das capturas |
| Performance | um objeto a mais na `Sessao`; nenhuma lista, editor ou parser tocado | diff |
| Privacidade e autoria | nenhuma rota de IA, selo ou origem tocada; nada envia nem gasta | diff |
| Estado honesto | **é a dimensão da volta**: o que a pessoa esperava parou de sumir em silêncio | `s1-02` (antes) vs `s1-05` (depois) |
| Complexidade | **+14 −2** em produção; nenhum arquivo ou dependência nova (o arquivo novo é de teste) | `git diff --shortstat` |
| Fora do app | n/a — nenhuma superfície fora do app tocada | — |
| Relato | este arquivo | — |

## O que mudou na NOTA das dimensões tocadas

- **Estado honesto** — subiu, e é o coração da volta: o único estado que sumia
  **sem rastro na tela** parou de sumir, provado por captura antes e depois no
  mesmo aparelho, e por dois testes que ficam vermelhos sem o conserto.
- **Simplicidade** — subiu: menos um toque e menos uma redigitação inteira para
  a tarefa mais comum depois de uma pergunta interrompida, sem acrescentar nada
  em nenhum outro caminho.
- **Correção** — subiu: um caminho que não tinha teste nenhum passou a ter dois
  que tocam a tela de verdade, com pré-condição que reprova o falso verde.
- **Complexidade** — praticamente parada: +14 −2 linhas de produção, três delas
  de código, o resto comentário que explica por que o estado mora ali.

## Fronteiras respeitadas

Não toquei em `Traco/Caderno/*`, `Traco/Trabalho/*` nem `TracoWidget/`. Não
mesclei nada. Não instalei nada no `C2416CBC`. Não usei maestro, voz, VoiceOver,
Siri nem iPad. O simulador `A1DF082C` foi desligado por `simctl shutdown` —
nunca `orca emulator kill`, que ontem derrubou o aparelho de outra volta.
