# Revisão G3 — volta 8, acessibilidade real (ADR 2026-09-05t)

Revisor: Claude Fable 5.1, sessão independente, 05/09/2026. Branch `Vitorepf/volta-8-acessibilidade` (fd1a189 sobre main 41b2605). Instrumento: simulador de teste iPhone 17 Pro Max **6033B043-F436-41F9-B4F8-2D9E67761980** (ligado por mim, desligado ao fim; tamanho de texto restaurado a `large`, "Reduzir movimento" restaurado a 0). Tudo via `ferramentas/orca/com-trava.sh`. O iPhone 17 do dono (1A46B6D3) não foi tocado. Nenhum código editado.

## Veredito: CORRIGIR ANTES

Sete dimensões ficam abaixo de 9. A lei de movimento reduzido funciona (vídeo) e nada mudou para quem vê (diff de pixels contra main). O que falha é a dimensão central: alvos de toque de 13 a 24 pt nas telas que a volta diz ter passado ponta a ponta, chips do calendário lidos em dobro pelo VoiceOver, ano com ~500 números soltos no rotor, e o cartão da forma em AX5 com a ação principal atrás de três páginas de rolagem dentro do cartão — o próprio `maestro/ax5.yaml` da volta falha em AX5.

## Scorecard

| dimensão | nota | evidência |
|---|---|---|
| Visão | 9 | Linha "Direção visual e uso simples" do EVOLUCAO cita a lacuna "VoiceOver real, movimento reduzido" e a volta fecha a segunda e parte da primeira; diff do EVOLUCAO coerente com o diff do código |
| Contrato | 8 | ADR 05t diz "uma lei de movimento num lugar só" e "toda animação e transição custom passa por elas"; no código o Calendário mantém a própria lei (`CalendarioTema.morph/desdobra`), ficam cinco fades locais de 0,18 s (`Tema.gaveta`, `Tema.cartao`, `CamposFormaView:38`, `ConfirmacaoView:82`, `RecordarView:447`) contra `fadeReduzido` = 0,15 s, e `NotasView:71-73` segue com `reduceMotion ? nil : …`. A prova da ADR não diz o resultado do `ax5.yaml`, que falha em AX5 (abaixo). Frase a corrigir, não arquitetura |
| Correção | 7 | Suíte integral no 6033B043: `✔ Test run with 623 tests in 122 suites passed` (`TemaTests.movimentoReduzidoViraFadeCurto` passou; primeira tentativa morreu em "test runner hung before establishing connection" logo após o boot, repetida limpa). Build fresco em pasta nova: `BUILD SUCCEEDED` com **1 aviso pré-existente** (`EditorBlocoView.swift:271 passing non-Sendable parameter 'ao'`, o mesmo em main:270). `maestro/ax5.yaml` com o build do branch: **passa em `large`, falha em AX5** no passo `Assert "Deixar como nota" is visible` — a captura `v8-rev-ax5-cartao-inalcancavel.png` mostra o cartão WOOP com kicker, frase e pergunta ocupando o cartão inteiro (368×380 pt, rolagem interna "3 páginas"); os botões não entram na tela. Os passos 04 e 05 que a volta acrescentou nunca rodam em AX5. `TemaTests` cobre `animacao`, `gaveta` e `cartao`; `transicao` não (AnyTransition não é Equatable), aceitável |
| Jornada real | 7 | Conferi o conteúdo das dez capturas do implementador (não só o arquivo): coerentes com o relato. Faltam os estados do G2: o cartão da forma em AX5 (onde mora o defeito) não foi capturado — `v8-ax5-pagina.png` é a página vazia; nenhum estado de falha/carregando da sábia; e **nenhum vídeo simctl** apesar de a volta ser sobre movimento (fiz os meus, abaixo). Capturas "normais" do implementador estão em `medium`; o padrão do iOS é `large` |
| Design | 9 | Nada mudou para quem vê: mesmo fluxo (`clearState` → texto → Notas → Calendário → Perfil → Recordar) no build do branch e num build fresco de main 2eb26a0, no mesmo simulador, em `large`: Notas 0,000 %, Calendário 0,000 %, Perfil 0,000 % de pixels diferentes; Página 0,058 % (cursor do campo) e Recordar 0,416 % (região do teclado do sistema) — `v8-rev-diff-main-*.png`. Em AX o menu de ordem troca nome por símbolo do sistema com `Tema.meta`; tetos em `xxxLarge` seguem a regra das barras do sistema |
| Simplicidade | 10 | Nenhum passo, decisão ou tela a mais; ações de rotor são adicionais; o toque longo em Analisar continua existindo |
| Movimento | 9 | Vídeo simctl com "Reduzir movimento" ligado por `defaults write com.apple.Accessibility ReduceMotionEnabled` + reboot do 6033B043 (o arranque do app já vem em fade, prova de que o ajuste pegou): abrir o arquivo pela borda corta seco (`v8-rev-rm-reduzido-camadas-abre.png`, linha 4, quadro 1→2) contra o deslize com posições intermediárias no normal (`v8-rev-rm-normal-camadas-abre.png`, linha 3); fechar por "Escrever" corta seco (`…-camadas-fecha.png`); Dia→Semana→Mês→Dia viram crossfade sem morph (`…-calendario-escalas.png`); barra de ações entra por fade. Fica: `Tema.gaveta(reduzido:)` ainda anima a altura em 0,18 s (movimento curto, aceitável) e as duas durações de "fade reduzido" (0,15 e 0,18) |
| Componentes | 8 | A lei nova está num lugar (`Tema.animacao/transicao/fadeReduzido`), sem componente novo. Duplicata de conceito: `Tema.gaveta(reduzido: true)` e `Tema.cartao(reduzido: true, …)` cravam `.easeOut(duration: 0.18)` em vez de devolver `fadeReduzido` — dois valores para a mesma lei que a ADR diz ser uma. Correção de duas linhas |
| Acessibilidade | 6 | `maestro hierarchy` nas cinco telas (`v8-rev-hierarquias/*.txt`). **Certo:** rótulos em pt-BR sem "botão"; `selected` em escalas, modo, filtros e chip do dia; valor "N compromissos" no mês; "Ordenar por Mais recentes"; "Buscar ou perguntar" com valor "vazio"; Perfil com estados nomeados; anúncios sem duplicar a Sessão (`.vestida` lá, `.vestido` aqui); cartão da sábia com `.contain`. **Errado, nas telas que a volta declara passadas:** (a) chip do dia e da semana lidos em dobro — `accessibilityText='Domingo, 30 de agosto, Domingo, 30 de agosto'` em todos os `dia-chip-*` e `semana-chip-*`: o `accessibilityLabel` está num VStack e o SwiftUI o propaga à letra e ao número (`CalendarioView.swift:486`); falta `.accessibilityElement(children: .ignore)`. (b) Alvos abaixo de 44 pt: chips da régua **31×13** (o `.frame(minHeight: Tema.alvo)` fica fora do `Button` e `PressaoDiscreta` não tem `contentShape`, logo a área de toque é o texto), "Notas" 45×20, "Concluir" 64×20, linhas `nota-notas` 400×24, `busca-notas` 348×24, "Revelar" 59×21, "hoje não" 58×18, "Entrar com a conta Grok" 185×20, barra Analisar/Recordar/Anexar/Lente 94×38. (c) Escala Ano: os ~500 números de dia são elementos individuais (hierarquia de 570 KB; 42 por mês) — a árvore esperada previa só "setembro de 2026". (d) AX5: no cartão da forma vestida a ação principal fica atrás de três páginas de rolagem dentro do cartão (captura acima). (e) Ações de rotor (Dia/Semana/Mês/Ano seguinte/anterior; Ligar/Desligar análise automática) e hints **não são expostos por maestro nem por XCTest**; conferidas só no código. No calendário estão num VStack contêiner; o mesmo mecanismo de propagação de (a) sugere que aparecem em cada filho, mas só um passe humano com VoiceOver prova. Menores: no mês, "7" e "Independência do Brasil" são lidos de novo depois do rótulo da célula; `aba-arquivo` "Abrir as notas" fica exposto com o arquivo já aberto |
| Performance | n/a | A volta não toca lista, editor de blocos, parser nem rolagem; acrescenta `onChange` sobre enums Equatable e troca curvas de animação. Sem trace |
| Privacidade e autoria | 10 | Diff lido inteiro: nenhum selo, origem ou rota protegida tocada; nada publica, gasta ou envia; os anúncios são locais (VoiceOver) e repetem texto que já está na tela; `Sessao.swift` intacto (conferido: `.vestida` anunciado na Sessão, `.vestido` na página, sem dobro) |
| Estado honesto | 9 | Anúncios distinguem pensando / respondeu / não respondeu / sem modelo / sem conta, e a falha vira "Repetir pergunta disponível"; só provado no código — com `TRACO_SEM_MODELO` a sábia não corre na jornada |
| Complexidade | 9 | `28 files changed, 316 insertions(+), 45 deletions(-)`; código Swift ≈ +150 líquidas, um arquivo de teste novo, zero dependências; três `andar()` repetidos por escala (mesma forma, unidades distintas) são aceitáveis. Dez PNGs (≈8,6 MB) entram no repositório — padrão da casa, mas pesa |
| Relato | 8 | Relatório legível e árvore esperada útil; falta o resultado do fluxo maestro que a volta estendeu, falta a captura do cartão em AX5 que a ADR dá por "fechado", e "restaurei para medium" confunde com o padrão `large` |

## Achados por severidade

**Alta**
1. Alvos de toque de 13–24 pt nos elementos que a volta rotulou (régua, barra da página, linhas de notas, Recordar, Perfil). Raiz: `.frame(minHeight:)` fora do `Button` + `PressaoDiscreta` sem `contentShape`. Evidência: bounds em `v8-rev-hierarquias/pagina-texto.txt`, `notas.txt`, `recordar.txt`, `perfil.txt`.
2. AX5: cartão da forma com "Abrir os campos"/"Deixar como nota" fora da tela, atrás de rolagem interna de três páginas; `maestro/ax5.yaml` falha no passo 8 em AX5. Evidência: `v8-rev-ax5-cartao-inalcancavel.png`, `~/.maestro/tests/2026-09-05_185919/`.
3. Chips do dia e da semana lidos em dobro pelo VoiceOver. Evidência: `calendario-dia.txt`, `calendario-semana.txt`.

**Média**
4. Escala Ano expõe ~500 números como elementos individuais. Evidência: `calendario-ano.txt`.
5. Duas durações para o fade reduzido (0,15 em `fadeReduzido`, 0,18 em `gaveta`/`cartao`); ADR diz "um lugar só" e o Calendário tem lei própria.
6. Sem vídeo simctl e sem captura do cartão em AX5 no G2 do implementador.

**Baixa**
7. Aviso de build pré-existente `EditorBlocoView.swift:271` (main também).
8. Mês: "7" e nome do feriado lidos de novo após o rótulo da célula; `aba-arquivo` exposto com o arquivo aberto.

## Lista mínima para subir a 9

- Acessibilidade: `.accessibilityElement(children: .ignore)` em `CalendarioChipDia` (e no chip da semana); `contentShape`/`frame` dentro do rótulo dos botões de `PressaoDiscreta` ou na régua/barra/linhas para 44 pt; `mesMini` do ano com `children: .ignore` mantendo "setembro de 2026"; cartão da forma em AX5 com a ação alcançável (ações fixas no pé do cartão ou cartão sem teto em tamanhos AX) — ou custo assumido explícito na ADR, decisão do dono.
- Correção/Relato: `ax5.yaml` passando em AX5 (ou o cartão corrigido) e o resultado colado na prova da ADR.
- Jornada real: captura do cartão em AX5 e vídeo com movimento reduzido (podem ser os `v8-rev-*` desta revisão).
- Componentes/Contrato: `gaveta`/`cartao` reduzidos devolvem `fadeReduzido`; ADR diz "as animações novas passam por Tema; o Calendário mantém `CalendarioTema`".

## Merge

`git merge-tree --write-tree 2eb26a0 HEAD` → árvore `498d4709…`, sem linhas de conflito.

## Arquivos desta revisão

Capturas `ferramentas/orca/v8-rev-*.png` (normais nas cinco telas e nas quatro escalas, AX5 do cartão e do Recordar, folhas de contato dos vídeos com movimento normal e reduzido, diffs contra main), hierarquias achatadas em `ferramentas/orca/v8-rev-hierarquias/`. Vídeos brutos (`normal.mp4`, `reduzido.mp4`, ~30 MB cada) ficaram fora do repositório, no scratch da sessão.

---

# Re-G3 — volta 8 após as correções (9f9e2b2 sobre fd1a189)

Revisor: Claude Fable 5.1, sessão independente, 05/09/2026, ~20h. Instrumento: iPhone 17 Pro **C2416CBC** (encontrado desligado, texto `medium`, Reduce Motion 0; ligado por mim, usado, restaurado a `medium`/0 e desligado ao fim). Tudo por `com-trava.sh`; nenhum outro simulador tocado; nenhum código editado. Build e suíte em `-derivedDataPath` novo no scratch da sessão.

## Veredito: INTEGRAR — segue ao G4 design, **depois de rebasear em main**

Os três achados altos do G3 estão fechados e medidos por mim: alvos de 44 pt reais (frame no dump E toque na borda que dispara a ação), chips do dia e da semana lidos uma vez, ano com 12 elementos com valor, `ax5.yaml` verde em AX5 e em `large` no meu simulador. Sem achado alto novo. O que impede o merge hoje não é a volta: main avançou (e51550e) e há dois conflitos de conteúdo em documentos (abaixo).

## Scorecard final

| dimensão | nota | evidência |
|---|---|---|
| Visão | 9 | Linha "Direção visual e uso simples" do EVOLUCAO ganha "Correções do G3 (05/09): alvo = frame + contentShape, chips lidos uma vez, ano por mês, cartão com ações no pé em AX"; coerente com o diff |
| Contrato | 9 | ADR 05t agora diz o que o código faz: `Tema.gaveta` e `CalendarioTema.morph/desdobra` devolvem o MESMO `fadeReduzido` (`TemaTests.gavetaECalendarioSeguemAMesmaLei` prova); `Tema.cartao` apagado (grep: zero usos); item (6) explica frame × contentShape; custo assumido lista o que fica (chips 42 abaixo de `large`, "pular", aba do arquivo, Confirmação/Padrões/Trabalho); a prova traz o resultado do `ax5.yaml`. Fica uma frase larga: "toda animação e transição custom das jornadas principais passa por elas" — o grep acha ~25 `withAnimation`/`.animation` fora da lei (Recordar 225/363/403/451, Caderno 231/290, Página 105/305/306/372, Notas 388/474/811, Rede 51, Calendário 143/433/434); são fades/ease de opacidade sem deslocamento, neutros ao movimento reduzido, mas a frase deveria dizer "toda animação que desloca, escala ou desdobra" |
| Correção | 9 | Suíte no C2416CBC: `✔ Test run with 624 tests in 122 suites passed after 8.477 seconds.` / `** TEST SUCCEEDED **`. Build do mesmo comando: 3 avisos, todos pré-existentes e idênticos a main — `EditorBlocoView.swift:272 passing non-Sendable parameter 'ao'` e dois `var never mutated` em `TracoTests/ConferenciaTrabalhoTests.swift:381` (arquivo intocado pela volta, igual a main). `maestro/ax5.yaml` rodado por mim com `clearState`: **AX5 exit 0, 16 passos COMPLETED** (inclusive `Assert "Deixar como nota" is visible`); **`large` exit 0, 16 COMPLETED**. Toque na borda do alvo (fora do texto): (35,389) no chip Título (alvo 49×44 @(11,385), texto ≈397–417) virou "abc" em `portal-titulo` (`v8-reg3-toque-borda-regua-antes/depois.png`); (42,69) em "Notas" (45×44 @(20,66), texto ≈78–98) abriu as Notas (`v8-reg3-toque-borda-notas.png`). O alvo é real, não só reservado |
| Jornada real | 9 | Conferi conteúdo, não arquivo: `v8-fix-ax5-pagina-cartao.png` mostra WOOP com "Abrir os campos" e "Deixar como nota" inteiros no pé; `v8-fix-ax5-recordar.png` com "Revelar" e "hoje não"; `v8-fix-rm-folha.png` coerente com o vídeo. Vídeo `v8-fix-rm.mp4` (604×1314, 248 quadros, 17,8 s) aberto quadro a quadro: Página→Notas sem posição intermediária (fade), Notas→Página corte, Dia→Semana→Mês→Ano em crossfade com títulos sobrepostos e sem morph, cartão entra por fade. Minhas capturas AX5 das cinco telas do `ax5.yaml`: `v8-reg3-ax5-01..05.png`. **Nota:** na minha captura do cartão em AX5 com o teclado ainda aberto (`v8-reg3-ax5-02-forma.png`, o instante real da jornada), "Abrir os campos" está inteiro e "Deixar como nota" fica meio sob o teclado (metade de cima visível e tocável); a captura do implementador é sem teclado. Não é o defeito do G3 (três páginas de rolagem interna), mas o G4 deve olhar |
| Design | 9 | Em `large` nada se moveu: hierarquias mostram os chips da régua no mesmo x do texto (Título em x=20 com alvo em x=11), barra 84/85×44 no lugar da pílula; capturas `large` iguais às do G3 a olho. Em AX o cartão muda de propósito (ações no pé, uma por linha). Para o G4: no vídeo com movimento reduzido, ao abrir o arquivo há 1–2 quadros (≈40–80 ms) de tela cinza cheia — a página escurece de imediato (`fracao` salta com o corte da posição) enquanto o arquivo ainda está em opacidade 0 (`Camadas.swift:55-56`) |
| Simplicidade | 10 | Nenhum passo, decisão ou tela a mais; `View.alvo()` substitui 38 `frame(minHeight:)` por um nome |
| Movimento | 9 | Um valor de fade reduzido (`fadeReduzido` 0,15 s) em `gaveta`, `morph`, `desdobra`, Campos, Confirmação e Recordar:449; `Tema.cartao` morto removido; vídeo prova corte e crossfade. Fica o quadro cinza acima (G4) |
| Componentes | 9 | `alvo()`/`alvo(folgaH:folgaV:)` num lugar só (`Tema.swift`), com o padding negativo devolvendo o espaço ao layout; `PressaoDiscreta`, `PrimarioStyle`, `CompactoStyle`, `CartaoBotaoStyle` com `contentShape` no rótulo; `corpoCartao` acrescenta `acoes` uma vez para os nove cartões, mesma ordem de antes (conferi caso a caso). Sobram `Tema.cartaoEntra`/`cartaoSai` (linhas 111 e 114) sem nenhum uso desde que `Tema.cartao` saiu — duas constantes órfãs |
| Acessibilidade | 9 | `maestro hierarchy` em `large` (`v8-reg3-hierarquias/*.txt`): régua `regua-titulo` 49×44, `seccao` 52×44, `lista` 44×44, `numerada` 75×44, `tarefa` 52×44, `citacao` 60×44, `codigo` 57×44, `tabela` 54×44, `todas` 51×44; "Notas" 45×44, "Concluir" 64×44; barra Analisar 84×44, Recordar 85×44, Anexar 84×44, Lente 85×44; Notas: `abrir-trabalhos` 91×45, filtros 66–122×44, `nota-notas` 362×48, `busca-notas` 362×44, `ordem-notas` 139×44; Recordar: "Revelar" 362×44, `hoje não` 58×44, Voltar 59×44; Perfil: `entrar-conta` 185×44, `abrir-ajustes` 199×44. Chips: `dia-chip-*` e `semana-chip-*` com `accessibilityText` único ("Domingo, 30 de agosto"), 44×44, `selected` no dia. Ano: 12 elementos `calendario-ano-*` 115×116 com rótulo "janeiro de 2026", valor "2 compromissos" e `selected` em setembro; zero números soltos (antes ~500). AX5: `abrir-campos` 315×125 e `soltar-forma` 250×126 dentro do cartão de 363×513, no dump e na tela. Toque na borda dispara a ação (Correção). Fica: `calendario-prosa` (campo de texto) 264×22, fora da lista do G3; "pular" não aparece neste modo; ações de rotor e hints continuam sem prova por maestro (VoiceOver real é do humano) |
| Performance | n/a | contentShape e padding não mudam custo; `mesMini` soma ≤42 lookups por mês |
| Privacidade e autoria | 10 | Diff inteiro lido: nenhum selo, origem, rota ou rede tocada; `Sessao` intacta |
| Estado honesto | 9 | Nada escondido; o aviso de `EditorBlocoView` fica declarado com a nota da tentativa de 05/09 no comentário |
| Complexidade | 9 | `git diff --shortstat fd1a189..9f9e2b2 -- Traco TracoTests`: 21 arquivos, +201/−132 (≈+69 líquidas em Swift), zero dependências, um teste a mais; 43 `.alvo(` entram e 38 `frame(minHeight: Tema.alvo)` saem. Pesa: 9,6 MB de PNG/MP4 só neste commit (três capturas AX5 do calendário com 2,2 MB cada), sobre os 8,6 MB do commit anterior |
| Fora do app | n/a | a volta não toca widget, Ilha, StandBy nem intents |
| Relato | 9 | `relatorio-v8-fix-acessibilidade.md` bate com o que medi (624/0, 1 aviso do app, ax5 verde nos dois tamanhos, cartão no pé); "restaurado a `medium`" está certo para o C2416CBC (encontrei-o em `medium`). Faltou dizer que a captura do cartão em AX5 é sem teclado |

## Achados por severidade

**Alta** — nenhum.

**Média**
1. **Merge:** `git merge-tree --write-tree --merge-base=41b2605 main HEAD` → exit 1, `CONFLICT (content)` em **EVOLUCAO.md** (linhas "Direção visual e uso simples" alterada pela volta e "Privacidade e autoria em todas rotas" alterada pela V7/05s em main, adjacentes) e em **SPEC.md** (a ADR 05s de main e a 05t da volta entram no mesmo ponto, após a 05r). `Traco/Perfil/PerfilView.swift` funde sozinho (`Auto-merging`, os 7 `.alvo()` da volta e as 7 linhas da V7 não se tocam); `project.pbxproj` idem. Passo: no worktree, `git rebase main`, resolver os dois documentos mantendo as duas versões (a linha da volta em "Direção visual" + a linha de main em "Privacidade"; ADR 05s antes de 05t), rodar a suíte via `com-trava.sh` de novo, então G4.
2. **AX5 com teclado aberto:** no instante em que o cartão aparece, "Deixar como nota" fica meio sob o teclado (`v8-reg3-ax5-02-forma.png`); "Abrir os campos" inteiro. Melhor que as três páginas de rolagem do G3 e o `ax5.yaml` passa; decisão do G4 (ou custo assumido explícito na ADR).

**Baixa**
3. Frase da ADR "toda animação e transição custom das jornadas principais passa por elas" é mais larga que o código (~25 fades locais fora da lei, listados em Contrato); ajustar a frase para "toda animação que desloca, escala ou desdobra".
4. `Tema.cartaoEntra` e `Tema.cartaoSai` órfãs (`Tema.swift:111,114`).
5. Movimento reduzido: 1–2 quadros de cinza cheio ao abrir o arquivo (página escurece antes do arquivo aparecer); para o G4.
6. 9,6 MB de binários neste commit; capturas AX5 do calendário poderiam ser recortadas ou comprimidas.
7. `calendario-prosa` 264×22 (campo; pré-existente, fora do escopo declarado).

## Arquivos desta revisão

`ferramentas/orca/v8-reg3-ax5-01..05.png` (jornada do `ax5.yaml` em AX5 no meu simulador), `v8-reg3-ax5-cartao-hierarquia.png` (tela do dump AX5), `v8-reg3-toque-borda-regua-antes/depois.png` e `v8-reg3-toque-borda-notas.png` (prova do alvo pelo toque), `v8-reg3-hierarquias/*.txt` (dumps achatados: página com régua, notas, dia, semana, ano, perfil, recordar, cartão AX5). Logs de build/suíte, `ax5` e frames do vídeo ficaram no scratch da sessão.
