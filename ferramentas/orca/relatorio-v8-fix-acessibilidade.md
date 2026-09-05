# Volta 8 — correções do G3 (alvos, leitura única, cartão em AX5)

Data: 05/09/2026. Branch `Vitorepf/volta-8-acessibilidade`, sobre fd1a189. Papel: front-end SwiftUI (Claude Fable 5.1). Instrumento: simulador de teste iPhone 17 Pro **C2416CBC** (liguei, usei, desliguei; tamanho de texto encontrado em `medium` e restaurado a `medium`; "Reduzir movimento" ligado por `defaults write` + reboot e restaurado a 0 + reboot). Nenhum outro simulador tocado. Tudo por `ferramentas/orca/com-trava.sh`.

## O que o G3 mediu e o que mudou

| Achado do G3 | Raiz | Correção |
|---|---|---|
| Alvos de 13–24 pt (régua 31×13, "Notas" 45×20, "Concluir" 64×20, linhas `nota-notas` 400×24, `busca-notas` 348×24, "Revelar" 59×21, "hoje não" 58×18, "Entrar com a conta Grok" 185×20, barra 94×38) | `.frame(minHeight: 44)` POR FORA do Button só reserva espaço; o dedo e o VoiceOver medem o `contentShape`. Prova no próprio dump do G3: "Como contexto" (frame + contentShape por fora) media 44×44; "Notas" (só frame) media 45×20 | `View.alvo()` em `Tema.swift` = frame + contentShape. Os 38 `.frame(minHeight: Tema.alvo)` das minhas pastas viraram `.alvo()`. Quem vive apertado usa `alvo(folgaH:folgaV:)`: chips da régua e "Todas" (folga 9 de cada lado), pílulas de 38 da barra (`BarraBotaoStyle`, folga 3), linhas de 24 das Notas (folga 10). `PressaoDiscreta` ganha `contentShape` no rótulo; `PrimarioStyle` (Revelar), `CompactoStyle` e `CartaoBotaoStyle` (cartão) idem |
| Chip do dia/semana lido em dobro | `accessibilityLabel` num VStack propaga à letra e ao número | `.accessibilityElement(children: .ignore)` em `CalendarioChipDia` |
| Ano: ~500 números no rotor | 42 `Text` por mês dentro do Button | `mesMini` é UM elemento: `children: .ignore`, rótulo "setembro de 2026", valor "N compromissos", `selected` no mês da âncora |
| AX5: "Deixar como nota" três páginas abaixo (`ax5.yaml` falhava) | ações dentro do ScrollView do cartão com teto de 380 | Em tamanhos AX o cartão rola o TEXTO e prende as AÇÕES no pé (uma por linha, `fixedSize` para não comprimir — a primeira tentativa dava "Abrir os ca…"); teto 480 em AX. Em tamanhos normais o cartão é o que era: `corpoCartao` acrescenta `acoes` no fim, na mesma ordem |
| `gaveta`/`cartao` com 0,18 s; Calendário com lei própria | dois valores para a mesma lei | `Tema.gaveta` devolve `Tema.animacao(...)`; `Tema.cartao` estava sem uso desde 31/ago (a25dbd1) e foi apagado; `CalendarioTema.morph`/`desdobra`, `CamposFormaView`, `ConfirmacaoView` e `RecordarView` passam por `Tema.animacao`/`transicao`. A ADR diz a verdade: duas leis nomeadas, um valor |
| Aviso `EditorBlocoView:271` | toolchain | tentei `@MainActor` no parâmetro (sem `@Sendable`): o swift-frontend crasha como no caso documentado. Fica, com a nota de 05/09 no comentário |

## Prova

### Aparência intacta em `large` (diff de pixels antes/depois, mesmo simulador, mesma jornada por rotas)
Build de HEAD fd1a189 (`git archive`, pasta isolada) contra o build deste commit; `simctl status_bar` fixa 09:41; `TRACO_SEM_MODELO=1`; permissão de calendário gravada no TCC (o diálogo do sistema tapava o calendário).

| Tela | pixels diferentes | o que é |
|---|---|---|
| Página (régua visível, teclado) | 26 px (0,001 %) | região do teclado do sistema (`lado-pagina.png`: chips Título/Seção/Lista no mesmo lugar) |
| Notas | 0 | — |
| Calendário dia | 1,811 % | só a linha "agora" (19:38 → 19:45), `v8-fix-diff-calendario-dia.png` |
| Calendário semana | 0,030 % | só a marca "agora" na barra do dia |
| Calendário mês | 0 | — |
| Calendário ano | 0 | — |
| Recordar | 0 | — |
| Página com cartão da forma vestida (WOOP, campos abaixo) | 0 | texto colado pelo menu "Colar" do editor nos dois builds |

### AX5 (`accessibility-extra-extra-extra-large`), capturas `simctl` em `ferramentas/orca/v8-fix-ax5-*.png`
- `pagina-cartao`: cartão WOOP com "Abrir os campos" e "Deixar como nota" inteiros, à vista, no pé; o texto rola acima.
- `notas`, `calendario-dia`, `calendario-semana`, `calendario-ano`, `recordar` ("Revelar" e "hoje não" à vista), `perfil` ("Entrar com a conta Grok").
- Texto da página entrou por colagem (`simctl pbcopy` + ⌘V na janela do simulador de teste); Perfil por clique na aba via System Events, na janela do C2416CBC (única janela do Simulator.app).

### Movimento reduzido — `ferramentas/orca/v8-fix-rm.mp4` (18 s, 604 px, 0,2 MB)
`ReduceMotionEnabled=1` confirmado após reboot (`defaults read` → 1). Estado limpo (uninstall/install). Sequência: Página → Camadas abre (Notas, corte seco) → fecha (Escrever) → Dia → Semana → Mês → Ano (crossfade, sem morph) → Página → menu "Colar" → texto → "lendo…" → cartão da forma vestida entra por fade. O `recordVideo` só grava quadro quando a tela muda e o app solta o foco ao vestir, logo o último quadro é o cartão; os 2 s finais são o mesmo quadro segurado (`tpad`) para dar tempo de olhar. Folha de contato: `v8-fix-rm-folha.png`.

### Build e suíte
- Build genérico em pasta limpa (`-derivedDataPath` novo): `** BUILD SUCCEEDED **`, **1 aviso**, o pré-existente `EditorBlocoView.swift:272 passing non-Sendable parameter 'ao'` (era :271; a linha desceu com a nota no comentário). Nenhum aviso novo.
- Suíte integral no C2416CBC: `✔ Test run with 624 tests in 122 suites passed after 7.271 seconds.` / `** TEST SUCCEEDED **` — 623 + 1 (`TemaTests.gavetaECalendarioSeguemAMesmaLei`).

### `maestro/ax5.yaml`
`maestro/ax5.yaml` rodado pelo orquestrador (via `com-trava.sh`, `--device C2416CBC`, build deste commit): **PASSOU em `accessibility-extra-extra-extra-large`** (exit 0, 16 passos COMPLETED, inclusive "Assert that Deixar como nota is visible" e as capturas 01–05) e **PASSOU em `large`** (exit 0). O revisor refaz no re-G3.

## Autoavaliação (14 dimensões, alvo ≥ 9)

| dimensão | nota | evidência |
|---|---|---|
| Visão | 9 | a lacuna "VoiceOver real" fecha mais um pedaço: alvos, leitura única e o cartão em AX5; linha do EVOLUCAO atualizada |
| Contrato | 9 | ADR 05t diz o que é: duas leis nomeadas (`gaveta`, `CalendarioTema.morph`) devolvendo o MESMO `fadeReduzido`; item (6) explica frame × contentShape; custo assumido explícito |
| Correção | 9 | suíte 624/0 em 122 suítes; build limpo com 1 aviso pré-existente; `ax5.yaml`: ver resultado acima (o revisor confirma) |
| Jornada real | 9 | sete capturas AX5 no meu simulador, com o cartão vestido e as ações à vista; vídeo com movimento reduzido; diff antes/depois em `large` nas sete telas |
| Design | 9 | 0 pixels diferentes em Notas, mês, ano, Recordar e cartão; página 26 px de teclado; dia/semana só o "agora". Em AX o cartão muda (ações no pé, uma por linha) — decisão, não acidente |
| Simplicidade | 9 | nenhum passo novo; `View.alvo()` substitui 38 frames sem contentShape por um nome só |
| Movimento | 9 | `Tema.cartao` morto removido; um valor de fade reduzido; vídeo prova corte seco e crossfade |
| Componentes | 9 | `alvo()`/`alvo(folgaH:folgaV:)` em `Tema`; `corpoCartao` acrescenta `acoes` uma vez para todos os cartões; sem componente novo |
| Acessibilidade | 9 | chips do dia lidos uma vez; ano por mês com valor; alvos com contentShape nas cinco telas; "Deixar como nota" à vista em AX5. Fica: `maestro hierarchy` do revisor para os números literais; folga fixa dos chips (42 abaixo de `large`) |
| Performance | n/a | contentShape e frames não mudam custo; `mesMini` soma compromissos por mês (12 × ≤42 lookups no dicionário) |
| Privacidade e autoria | 10 | nada de rede, selo ou rota tocada |
| Estado honesto | 9 | o aviso de `EditorBlocoView` fica, com a nota da tentativa de 05/09 no comentário; a ADR diz o que ficou fora |
| Complexidade | 9 | `git diff --stat` abaixo; sem dependência; um teste a mais |
| Relato | 9 | este relatório, `worker_done` em seis linhas, capturas nomeadas como pedido |


## Fora / custo assumido
- Folga fixa de 9 pt nos chips da régua: em `large` o menor ("Lista") mede 44; abaixo de `large`, 42.
- "pular" (Recordar) e a aba do arquivo (`Camadas`, 23 pt de largura) seguem estreitos; `Confirmação`, `Padrões` e `Trabalho` ainda usam o idioma `frame` sem `contentShape` (não são das jornadas desta volta nem das minhas pastas).
- `maestro hierarchy` e o passe com VoiceOver em aparelho real são do revisor/humano.
