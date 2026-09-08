# F4-H — o corte honesto: o publicador limita a projeção, a face limita a apresentação

**Papel:** FORA DO APP (Fable 5.1). **Worktree:** `volta-f5-fora-do-app`, sobre `0beddcb`. **Aparelho:** iPhone 17 Pro (teste 4) `A1DF082C-FC87-4DF9-9F56-F2DA1C084DED`, ligado por mim e devolvido desligado.
**Skills:** `design-router` carregada antes de tocar em SwiftUI — rota "ajuste local de componente", diagnóstico já feito pelo G4 (Ancorar: G4 da F4-F, parecer do conselho e a decisão de sete pontos; Sistema: `Tema` sem token novo; Construir; Mover: nada se mexe, nenhuma animação tocada; Julgar: capturas abaixo; Portão: tokens conferidos, uma cápsula só). `curva-zero` não foi carregada: o roteiro de um toque não mudou, mudou o DESTINO do toque, e isso está na ADR.
**Instrumento:** todo `xcodebuild`, `xcodebuild test` e toda sessão de `orca emulator` passaram por `ferramentas/orca/com-trava.sh` — segurei a trava em cada uma. Nenhum toque no mouse do dono. Capturas por `xcrun simctl io <UDID> screenshot` via `f5-fotografar.sh` (só dada por boa com o OCR lendo o texto esperado). Nada de maestro.

## O que mudou, em uma linha por ponto da decisão

| ponto | onde | o quê |
|---|---|---|
| 1 teto do publicador, na projeção | `SuperficieFora.swift`, `DestaqueDoDia.swift` | `Superficie.Destaque.teto = 140` grafemas aplicado em `DestaqueDoDia.projecao`, que `publicar` e `reconciliar` compartilham; `estadoVivo` monta o `ContentState` da Ilha a partir da MESMA projeção (teste `projecaoEAtividadeComOMesmoContrato`) |
| 2 três estados | `SuperficieFora.swift`, `Atividades.swift` | `inteira: Bool?` → `integridade` (.inteira/.trecho/.desconhecida); documento antigo decodifica `nil` (teste); "…" literal do autor dentro do teto é inteira (teste) |
| 3 grafemas, fronteira de palavra | `Superficie.Destaque.trecho` | `Character`; prefere espaço se guarda metade do orçamento, senão grafema; testado com 200 bandeiras 🇧🇷, 300 letras sem espaço, 299 chars em palavras |
| 4 regra do corte honesto | ADR 08i | com as palavras da decisão; promessa da 08g corrigida para "trecho fiel e legível, com omissão reconhecível" |
| 5 corpo do papel, sem fração | `FraseDoAutor`, `Encolhe` | `ViewThatFits` sobre `lineLimit(n)` no corpo cheio, sem `minimumScaleFactor`; `Encolhe.frase` apagado; no pequeno em AX o círculo sobe uma linha para a frase ter 123 pt |
| 6 ordem de sacrifício | `Sacrificio` em `Relogio.swift`, `destaqueQueCabe` | candidatos (n linhas, com/sem rótulo) em ordem; rótulo só entra se não custa linha; `LinhasDoDestaque.noMedio(comAgenda:)` — sem agenda o layout decide (o teto de 2 com rodapé deixava 3 linhas vazias) |
| 7 promessa verdadeira | `Intencoes.swift`, `destino` | **escolhi fazer o destino corresponder:** `traco://nota/<id>` → `Destino.nota` (rota da 05u, revalida selo); rótulo "Abrir a nota"; provado com nota real (abaixo) |
| VoiceOver | `Destaque.emVoz` | "Trecho: … Continua no Traço." só quando `.trecho`; a Live Activity usa o mesmo |
| dívidas do G4 | quadros, `CapsulaViva` | terceira oferta "Recordar" (nunca desenhada) saiu dos dois quadros e a ADR diz onde ela continua; uma cápsula só (18/38; 14/32 na Ilha), tinta de quem veste |

## Os dois casos que derrubaram a volta, refotografados no teste 4 (build deste worktree, instalado por `f5-instalar.sh` e conferido por símbolo `Sacrificio CapsulaViva destaqueQueCabe`)

Todas com cenário `curto` do `f5-semear.sh` (o "Desatualizado." vem sozinho em ~4 min) e o OCR lendo "Desatualizado" ×4 nas velhas.

| captura | caso | o que mostra |
|---|---|---|
| `f4h-media-fresca-normal.png` / `f4h-media-fresca-ax5.png` | 103 chars, fresco | pequeno: 5 linhas a 17 pt e "…" (normal) × **3 linhas a ~24 pt** e "…" (AX5) — o corpo cresceu com a categoria; sem rótulo "Abrir a nota" porque a frase precisava das linhas |
| `f4h-media-velha-normal.png` / `f4h-media-velha-ax5.png` / `f4h-media-velha-ax5-escuro.png` | 103 chars, velho | rodapé "Desatualizado." nas duas faces; AX5 pequeno com círculo em cima e duas linhas de 123 pt, sem hífen; médio 3 linhas + "…" + rodapé, sem buraco |
| `f4h-longa-fresca-normal.png` / `f4h-longa-fresca-ax5.png` | 247 chars, fresco | o publicador cortou em 129 grafemas ("…entregar sem…", `inteira: false` no `superficie.json`); a face corta de novo no que cabe; Ilha compacta "Acordei pens…" |
| `f4h-longa-velha-normal.png` / `-escuro.png` / `-ax5.png` / `-ax5-escuro.png` | 247 chars, velho | as quatro combinações com "Desatualizado."; médio normal com 4 linhas + "…" (antes: 2 linhas e três vazias); AX5 pequeno "Acordei / pensando…" a ~24 pt |
| `f4h-curta-fresca-normal.png` | 43 chars (acervo), nota real | pequeno: frase inteira em 4 linhas **e** o rótulo "Abrir a nota" — o rótulo só entra quando não custa linha |
| `f4h-toque-pequeno-abre-a-nota.png` | toque no pequeno (`orca emulator tap 0.27 0.20`, por `com-trava.sh`) | o app abriu **"A nota real da prova do toque"** (nota criada por `traco://anotar`, id semeado com `ID=` no `f5-semear.sh`), lido por OCR |
| `f4h-bloqueada-viva.png` | tela bloqueada, 247 chars | Live Activity com o trecho do publicador e o corte da face em duas linhas |


**O que eu vi e declaro.** (a) Em AX5 no pequeno o SwiftUI partia "termi-/nar" e "pen-/sando" em sílaba na coluna de 90 pt ao lado do círculo; o círculo passou a subir uma linha em tamanho de acessibilidade e as capturas finais não têm hífen — palavras acima de ~10 letras ainda podem ser partidas em sílaba a 24 pt em 123 pt, e isso é quebra tipográfica, não corte. (b) No pequeno normal velho sobra ~1 linha entre a frase e o rodapé: o candidato de 5 linhas não coube com o rodapé; não é corte evitável de meio cartão, é o resto de uma divisão inteira. (c) Widgets na casa escalam Dynamic Type ~1,4× em AX5 (o G4 já tinha medido), então "crescer com a categoria" é 17 → ~24 pt.

## Live Activity e tela bloqueada com o mesmo contrato (ponto 1)
Por construção e por teste: `reconciliar` passou a usar `estadoVivo`, que nasce de `projecao` — o teste grava 252 caracteres e confere que `superficie.json` e o `ContentState` carregam o mesmo trecho e `inteira == false`. Na tela: `f4h-bloqueada-viva.png` (aparelho trancado por `orca emulator button lock`, sob a trava) mostra a Live Activity do Destaque com a MESMA linha de 247 caracteres já cortada pelo publicador e, por cima, o corte da face em duas linhas ("…ontem com a Ana sobre o prazo…"); a Ilha compacta aparece nas capturas da casa ("Acordei pens…", "terminar o ca…"). A permissão de Atividades ao Vivo foi pedida pelo sistema na primeira trancada e aceita por toque no simulador.

## Provas de máquina (todas por `com-trava.sh`)
- `xcodebuild build -scheme TracoWidget -destination id=A1DF082C…`: `** BUILD SUCCEEDED **`, **0 `warning:`**.
- `xcodebuild build -scheme Traco`: `** BUILD SUCCEEDED **`, **0 `warning:`**.
- `xcodebuild test -scheme Traco -destination id=A1DF082C…`: `✔ Test run with 909 tests in 148 suites passed after 10.377 seconds.` / `** TEST SUCCEEDED **` (eram 893 em 145: +16 testes, +3 suítes — `TrechoPublicoTests`, `SacrificioTests`, e `LinhasDoDestaqueTests`/`EncolheTests` reescritas).
- `git diff --shortstat` antes do commit: `11 files changed, 456 insertions(+), 161 deletions(-)` (sem contar ADR, EVOLUCAO e este relato; 14 capturas novas).

## Instrumento — o que aprendi
- `orca emulator attach` + `tap --device` funcionaram à primeira sob a trava; `ax` não foi tentado (a ESTEIRA já diz que recusa na casa) — o alvo veio da captura (0..1).
- `f5-semear.sh` ganhou `ID=` opcional: sem uma nota real o toque só pode provar o recado "Essa nota não está disponível."; com ela prova a continuação.
- zsh não separa `"a b c"` num `for`: uma rodada de quatro capturas saiu toda em claro/normal com nomes errados antes de eu notar. Refeitas.
- `orca emulator button side_button` não tranca o simulador; `orca emulator button lock` tranca, e `button home` destranca.

## Scorecard (preenchido por mim; a nota é do revisor)

| dimensão | nota | por quê |
|---|---|---|
| Visão | 9 | a única coisa de hoje legível a quem pediu letra grande, e o toque leva à continuação — ciclo 1 |
| Contrato | 9 | ADR 08i com a regra nas palavras da decisão e a promessa corrigida; EVOLUCAO |
| Correção | 9 | 16 testes novos (teto, grafemas, projeção = Ilha, documento antigo, rota, ordem de sacrifício); suíte 909 verde |
| Jornada real | 9 | 103 e 247 nos dois tamanhos, claro e escuro, fresco e velho; 43 com rótulo; toque com nota real |
| Design | 9 | corpo do papel em toda categoria; rótulo cede antes da frase; buraco do médio fechado; hífen em AX resolvido no pequeno |
| Simplicidade | 9 | "Recordar" dito; rótulo só quando cabe; sem tela nova |
| Movimento | 9 | nada se mexe; nada tocado |
| Componentes | 8 | `CapsulaViva` uma só; `FraseDoAutor` segue no arquivo do widget sem preview próprio (dívida antiga) |
| Acessibilidade | 9 | corpo cresce com a categoria; VoiceOver distingue trecho; círculo sobe em AX |
| Performance | n/a | widget estático; `ViewThatFits` com ≤16 candidatos numa face |
| Privacidade e autoria | 9 | o estado guarda o texto inteiro; a projeção só corta; rota da nota revalida selo (`PaginaView`) |
| Estado honesto | 9 | trecho declarado nos três estados; "Desatualizado." nunca cede |
| Complexidade | 8 | +295 líquidas, das quais ~60% comentários e testes; `Encolhe.frase` e `alturaDaLinha` apagados |
| Fora do app | 9 com lacuna dita | widget, Ilha e bloqueada com um contrato; bloqueada trancada não fotografada (instrumento) |
| Relato | 9 | este arquivo |
