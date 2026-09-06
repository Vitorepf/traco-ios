# G3 — Revisão da volta F3 (captar pensamento em um toque, ADR 2026-09-05w)

Revisor: Fable 5.1 em sessão própria, 06/09/2026 04:45–05:10. Worktree `fora-3-captar`, commit `8afb691` sobre main `59e5833`. Simulador do revisor: iPhone Air `64F7B8B4` (ligado 04:45, Dynamic Type e aparência restaurados a `medium`/`light`, desligado 05:08; o controle "Anotar" ficou adicionado à Central do Air). Instrumento: `com-trava.sh` para build e teste; `cliclick` + AXRaise para a Central (maestro n/c: `maestro/varrer.sh` recusa com 2+ simuladores ligados e os três ligados são de outros). Nenhum arquivo do branch editado; só este relatório e as capturas `f3-rev-*.png` (todas ≤ 210 KB).

## Veredito

**CORRIGIR ANTES (lista mínima, uma linha de teste)** e depois INTEGRAR após rebase sobre V10. **G4 não se aplica**: nenhum pixel foi desenhado pela volta — o controle é do sistema (glifo, círculo, rótulo), a tela que abre é a Página de sempre e o recado usa o toast existente de `Sessao`.

Lista mínima:
1. **Correção (8).** A suíte integral no Air hoje dá **709/710**: `ForaDoAppTests.sonecaRecusada` falha na linha 336 porque o teste assume permissão de aviso `notDetermined` e o Air está **autorizado** (o `LembrarDepoisIntent` real agendou soneca `lembrarEm = 04:56` e o aviso "RELEVANTE · Dentista" foi de fato entregue às 04:56 — visto na tela). Não é código da F3: é teste da F2 dependente do estado do simulador. Linha do tempo que explica: suíte do implementador 04:13 (710/0), jornada 04:14 com alerta dispensado (`01-pos-alerta.png`, a permissão entrou aí), commit 04:42, minha suíte 04:46. Correção mínima, dona da trilha Fora do app: o trecho "pelo intent, sem centro de mentira" deve usar `Centro.fake(estado: .negado)` ou pular com motivo quando `UNUserNotificationCenter` já está autorizado. Reteste após a correção: `-only-testing:TracoTests/ForaDoAppTests` (22 testes, 0,3 s).

## Scorecard

| dimensão | nota | evidência |
|---|---|---|
| Visão | 9 | Ciclo multiplicar; G0 F3 no RUMO; EVOLUCAO fecha "controles e ditado (F3)" e abre F3b (ditado próprio com áudio preservado). Metade do G0 ("abrindo já em ditado", "áudio preservado antes da transcrição") vira "teclado pronto, microfone a um toque" — dito na ADR e no EVOLUCAO, não escondido. A linha F3 do RUMO ainda diz "abre o app já em ditado": ajustar no G5. |
| Contrato | 9 | ADR 05w com 37 linhas, coerente com o código: `CapturarIntent` só executa sob `TRACO_APP` e `ForaDoAlvo.recusar()` fora; `Rota.captura(ditado:)` tipada; `Rota.consumir()` uma vez; `openAppWhenRun = true`. Botão de Ação sem 11.º atalho documentado nos dois lugares que o dono lê (ADR e cabeçalho de `TracoAtalhos.swift`, `grep -c 'AppShortcut('` = 10). SPEC/EVOLUCAO/pbxproj coerentes; `project.yml` não precisou mudar (`Compartilhado/` já entra por pasta). |
| Correção | **8** | Build do scheme (app + TracoWidget) `** BUILD SUCCEEDED **`, `grep -c warning:` = 0 em `build.log`. Suíte no Air: `✘ Test run with 710 tests in 125 suites failed after 7.529 seconds with 1 issue` (só `sonecaRecusada`, ver lista mínima); reteste isolado `22 tests … 1 issue`, determinístico. Os 3 testes novos passam: `rotaPendenteUmaVez` (guardada sem ouvinte, consumida uma vez, última vence), `capturarSoNoApp` (recusa sem rota; `perform()` deixa `.captura(ditado: true)`), `anotarHonesto` ganhou "falha não deposita". Arranque frio real só pelo log (n/a de teste com motivo: o intent corre antes da cena; o teste cala `Rota.anunciar` e prova a espera). Maestro n/c (varrer.sh recusa com 2+ booted; nenhum é meu). |
| Jornada real | 9 | Reproduzido no Air, conteúdo conferido: galeria "Traço › Anotar" (`f3-rev-galeria`), Central clara e escura com o controle (`f3-rev-central`, `f3-rev-central-escuro`), toque → Página em branco, teclado, tecla do microfone, recado "Toque no microfone do teclado para ditar." quente vindo do Calendário (`f3-rev-app-quente`), frio (`f3-rev-app-frio`, PID novo 97340, 1,1 s), coberto pela camada Notas (`f3-rev-notas-antes` → `f3-rev-app-vindo-das-notas`), escuro (`f3-rev-app-escuro`), AX5 frio (`f3-rev-app-ax5`, PID 7286). Capturas do implementador abertas e batem com o que dizem; editor da bloqueada com o controle no slot direito conferido na captura dele (não reproduzi); trancada n/c (o simulador não desenha controle nem lanterna, captura dele prova). |
| Design | 9 | Nada desenhado pela volta: controle do sistema com `Label("Anotar", systemImage: "text.append")` e `tint(Tema.ambar)` (o âmbar só aparece no estado pressionado/Botão de Ação; em repouso o sistema desenha cinza — correto para botão). Custo visível: em AX5 o toast cobre o caret e ~60 % da página por 2,5 s (captura dele `f3-app-captura-ax5`); é o toast existente, dívida nomeada da V15. G4 não se aplica. |
| Simplicidade | 10 | Um toque faz uma coisa; zero tela nova; passos do caminho comum: Central → toque → escrever/ditar (antes: Siri ou URL). Poder avançado (Anotar por Siri sem abrir) intacto. |
| Movimento | n/a | Nenhuma animação da volta; abertura do app e do teclado são do sistema. |
| Componentes | n/a | Nenhum componente criado; reutiliza `Sessao.mostrarToast` (não o `Componentes/Toast.swift` que a V10 apagou — sem cruzamento). |
| Acessibilidade | 9 | Rótulo VoiceOver do controle = "Anotar" (Label do sistema); alvo do sistema ≥ 44 pt; AX5: página abre, data quebra em duas linhas sem clipe, teclado sobe (`f3-rev-app-ax5`). Contra: toast cobre o caret em AX5 (acima). |
| Performance | n/a | Nenhuma lista, editor ou parser tocado; arranque frio até `perform()` 1,1–1,3 s no log. |
| Privacidade e autoria | 10 | Extensão não lê superfície, não conta, não mostra conteúdo; `grep AVAudio|Speech` em `TracoWidget/` e `Compartilhado/` = 0; sem chave de microfone no Info.plist; `ForaDoAlvo` recusa na extensão (teste); `seguirRota(.captura)` salva o que estava em voo antes de `novaPagina` (nada se perde); rotas de entidade com selo intocadas. |
| Estado honesto | 9 | O recado diz o limite real (o iOS não expõe API para disparar o ditado; o teclado sobe e o microfone está a um toque — conferido). "anotado" só após depósito (teste da falha não deposita). Ressalva baixa: se `irPara(.escrever)` não trocar de aba (confirmação/fecho pendente), a rota é consumida e o toque fica mudo — a página protegida tem prioridade, aceitável, mas sem recado. |
| Complexidade | 10 | `git diff --shortstat` Swift: app+widget +96 −3, testes +42, 1 arquivo novo (`CapturarIntent.swift`, 42 linhas); pbxproj gerado. |
| Fora do app | 9 | Superfície com captura real: galeria, Central clara/escura, editor da bloqueada; um toque faz uma coisa; nada protegido; controle estático (sem orçamento de atualização). Ilha/StandBy não pertencem a esta superfície; bloqueada trancada e Botão de Ação só no aparelho (dito). **Baixo:** `f3-bloqueada-editor-controle.png` 600 KB e `f3-bloqueada-simulador-sem-controles.png` 482 KB ultrapassam os 400 KB da regra do RUMO (G5 recusa): `sips -Z 1000` antes de mesclar. |
| Relato | 9 | `f3-captar.md` diz o que entrou, a prova e os limites (hardware keyboard, janelas reescaladas) em linguagem legível; PIDs 78325/22110/30032 no log provam quente e frio. LACO fica para o G5. |

## Achados por severidade

- **MÉDIO — Correção:** suíte 709/710 no Air (teste da F2 `sonecaRecusada` depende da permissão de aviso do simulador). Não é a F3, mas o branch não está verde no simulador de teste. Correção de uma linha no teste, dona: trilha Fora do app.
- **BAIXO — G5:** dois PNGs acima de 400 KB (regra do RUMO desde a V10).
- **BAIXO — RUMO/LACO:** a linha F3 promete "já em ditado"; a entrega é "teclado pronto, microfone a um toque"; o áudio preservado ficou para F3b. Ajustar o texto ao fechar.
- **BAIXO — Design/AX5:** toast cobre o caret; custo justo até a V15 (Toast em Componentes).
- **BAIXO — Estado honesto:** rota `.captura` consumida em silêncio quando a Página não pode trocar de aba.
- **INFO:** o teste `capturarSoNoApp` chama `CapturarIntent().perform()` real dentro do app de teste — funciona porque a suíte roda no processo do app (TEST_HOST); se um dia a suíte sair do app, o `#if TRACO_APP` some e o teste quebra com mensagem clara.

## Merge

- Contra main `59e5833`: `git merge-tree --write-tree` limpo.
- Contra V10 topo `71db7b1` (`volta-10-fundacao`): **conflitos em `SPEC.md`** (as duas voltas acrescentam ADR no fim do arquivo: manter as duas, 05v antes de 05w) e **`Traco.xcodeproj/project.pbxproj`** (V10 adiciona `Componentes/*`, F3 adiciona `CapturarIntent.swift`): resolver por `xcodegen generate` — `project.yml` não conflita. `Traco/Pagina/PaginaView.swift` e `EVOLUCAO.md` mesclam sozinhos (V10 muda `BarraBotaoStyle` e raios; F3 muda `seguirRota` e o consumo da rota). Sem cruzamento semântico: F3 usa `sessao.mostrarToast` (Sessao.swift, que a V10 não toca).

## Ambiente (para quem repetir)

- A janela do Air é reescalada por outra sessão durante o trabalho (194 px de largura): toques cegos caem no desktop. Antes de cada gesto: `activate` no Simulator, AXRaise da janela, menu Window › Point Accurate, posição {1150, 60}.
- `cliclick t:` liga "Connect Hardware Keyboard" e o teclado de software some em todo o aparelho (a primeira captura quente saiu sem teclado por isso): desligar em I/O › Keyboard antes da jornada.
- Na Central, o controle responde a `press` (dd/du) com o app atrás e a `tap` (c:) na tela de início; a posição muda com o tamanho de conteúdo em que a Central abriu (78,217 em medium; 84,214 ou 78,300 em AX5 conforme o bloco de status). Um toque de calibração deixou uma nota "Q" no Air.
