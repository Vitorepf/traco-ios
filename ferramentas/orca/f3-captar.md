# F3 — Captar pensamento em um toque (ADR 2026-09-05w)

Worker: Fable 5.1 (trilha Fora do app), 06/09/2026, worktree `fora-3-captar` sobre main `59e5833`. Simulador: iPhone Air `64F7B8B4` (ligado, usado, restaurado, desligado por esta volta). Instrumento: `com-trava.sh` para build/test; `cliclick` + AXRaise para a Central e o editor da tela bloqueada (sem maestro); `xcrun simctl io` para toda captura.

Linha da volta: ciclo MULTIPLICAR; intenção: uma frase na rua entra no Traço em um toque, sem abrir o app, ou abrindo já em ditado; obstáculo: só Siri/Atalhos e `traco://anotar`, sem controle nem botão de Ação; evidência: controle na Central e no editor da bloqueada, app aberto em captura (quente, frio, coberto, AX5), log do contexto de execução, 3 testes.

## O que entrou

1. `Traco/App/Intents/Compartilhado/CapturarIntent.swift` — intent de abertura compartilhado; `executar(noApp:)` decide pelo alvo (teste passa `false` e prova a recusa).
2. `TracoWidget/TracoWidget.swift` — `AnotarControle: ControlWidget` (`app.traco.controle.anotar`), `Label("Anotar", systemImage: "text.append")`, `tint(Tema.ambar)`; entra no `WidgetBundle`.
3. `Rota.Destino.captura(ditado:)` e `Rota.consumir()` (uma vez); `Rota.anunciar` é a costura que o teste de arranque frio cala — a suíte roda dentro do app vivo e a `PaginaView` real consumia a rota na hora (foi assim que o primeiro teste falhou).
4. `PaginaView.seguirRota(.captura)`: `irPara(.escrever)`, salvar, `novaPagina`, foco false → true no ciclo seguinte, toast "Toque no microfone do teclado para ditar." quando `ditado`.
5. `TracoAtalhos`: NADA novo — o 11.º App Shortcut é recusado pelo `appintentsmetadataprocessor` ("each app may have at most 10"); documentado no arquivo e na ADR.
6. Testes: `rotaPendenteUmaVez`, `capturarSoNoApp`, e `anotarHonesto` ganhou a prova de que `perform()` na falha não deposita.

## Prova

- Build dos dois alvos: `** BUILD SUCCEEDED **`, `grep -c warning:` = 0 (os dois avisos pré-existentes de `ConferenciaTrabalhoTests.swift:381` continuam só no alvo de testes).
- Suíte integral no Air: `✔ Test run with 710 tests in 125 suites passed after 7.192 seconds.` / `** TEST SUCCEEDED **` (710 = 707 de main + 3).
- Contexto de execução (`f3-log-intent.txt`): chronod "Performing control action with the intent" → `Traco[78325]` "Invoking CapturarIntent.perform()" (app quente) e `Traco[30032]` (arranque frio, PID novo) → "Action success".
- Capturas: `f3-galeria-controle.png` (galeria da Central com "Traço › Anotar"), `f3-central-controle.png` e `f3-central-controle-escuro.png` (Central com o controle), `f3-app-captura-quente.png`, `f3-app-captura-frio.png`, `f3-app-captura-vindo-das-notas.png` (coberto pela camada Notas: cai na Página), `f3-app-captura-ax5.png` (AX XXXL), `f3-bloqueada-editor-controle.png` (editor da tela bloqueada com o controle no slot direito), `f3-bloqueada-simulador-sem-controles.png` (trancada: o simulador não renderiza nem a Lanterna).

## Limites ditos

- O iOS não tem API para disparar o ditado do teclado: "ditado solicitado" = editor com foco, teclado levantado, microfone a um toque. O ditado próprio (áudio primeiro) é a próxima superfície e entra por `.captura(ditado: true)`.
- O simulador não tem microfone: a tecla do microfone aparece, mas ditar não é capturável aqui.
- A tela bloqueada trancada do simulador não desenha controles; o editor prova o slot. Tema escuro do app segue o papel (D11, pré-existente).
- Instrumento: digitar pelo teclado do Mac num simulador liga "Connect Hardware Keyboard" e o teclado de software some em todo o aparelho — foi isso, e não o código, que escondeu o teclado na primeira jornada; desligado pelo menu I/O e a jornada repetida. Alguém reescala as janelas do Simulator durante a sessão; o helper repõe Point Accurate antes de cada toque.
