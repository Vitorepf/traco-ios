# Volta 2 — correções dos achados (implementador)

## Prova
- `xcodebuild -scheme Traco -destination 'generic/platform=iOS Simulator' -derivedDataPath build-v2 build` → `** BUILD SUCCEEDED **`, 0 warnings.
- Suíte integral no UDID de teste 6033B043-F436-41F9-B4F8-2D9E67761980, `-derivedDataPath build-v2`:
  - `✔ Suite CalendarioTrabalhoTests passed after 0.061 seconds.`
  - `✔ Suite AvisoDaAcaoTests passed after 0.367 seconds.`
  - `✔ Test run with 576 tests in 120 suites passed after 6.873 seconds.`
  - simulador de teste desligado ao fim (`simctl list devices booted` não o mostra).
- Flow `maestro/trabalho-acao-aviso.yaml` no iPhone 17 do dono (1A46B6D3, único booted no momento da corrida): saída 0, todos os passos, três capturas.
- Capturas simctl: `ferramentas/orca/v2-acao-aviso-reaberto-corrigido.png` (folha reaberta) e `v2-acao-aviso-depois-corrigido.png` (logo após guardar).

## P1 — estado ao abrir (corrigido)
`OficinaTrabalho.lerAvisos(agora:)` lê o centro de notificações (`Revisoes.acoesPendentes()`) e a permissão de hoje (`Avisos.estado()`) e preenche `avisos` + `permissaoNegada`. Ordem: pendente → `.agendado`; senão negado → `.semPermissao`; senão hora vencida → `.passou`; senão `.semAviso`. Chamado em `abrir()` e ao voltar a cena `.active` (TrabalhoView).

A folha passou a mostrar **uma** linha só (`AgendamentoAcaoView.linhaDoAviso`): enquanto a escolha na tela difere do disco (`alterado`), a promessa do que Guardar vai fazer; depois, o estado do motor/centro. Nunca as duas. A promessa só diz "Toca …" quando a permissão não está negada; negada, a mesma linha vira "O iPhone está com os avisos do Traço desligados — nada vai tocar." + "Abrir os Ajustes".

Capturas: no "depois" a linha vermelha aparece **sozinha** (a volta 2 tinha "Toca … às 14:11" quatro linhas abaixo); na folha reaberta aparece "A hora do aviso já passou — esta ação ficou sem alarme.", sem promessa nenhuma.

Limite honesto da captura: `.semPermissao` na folha REABERTA não é encenável em simulador. `xcrun simctl privacy booted revoke notifications app.traco` responde `Operation not permitted / Failed to set access`, e `requestAuthorization` no simulador não resolve — o status fica `.notDetermined`, nunca `.denied`. Por isso a folha reaberta cai no ramo honesto seguinte (`.passou`). O ramo `.semPermissao` está provado (a) renderizado de verdade na captura "depois" e (b) no teste `aoAbrirAFolhaLeOEstadoRealDoAvisoENaoOQuePediu`, que injeta `lerPermissao = { .negado }`.

## P2 — selar/queimar/apagar cala no ato (corrigido)
`AcessoTrabalho.derivados(daNota:no:)` acha os Trabalhos cujo `notaOrigemID` é a nota, decodificando só o `Vinculo` (nunca o conteúdo). `Sessao.calarAcoesDerivadas(de:no:)` chama `Revisoes.cancelarAcoes(doTrabalho:)` para cada um, nas três rotas: `salvar(trancar:)` (Sessao.swift:1003), `queimar` (:1536) e `apagar` (:1653).

Teste `selarQueimarOuApagarAOrigemCalaOAvisoDaAcaoNoAto` percorre as três rotas com uma `Sessao` de verdade e observa a costura `Revisoes.calarTrabalho`; confere também que um Trabalho de outra origem **não** é calado junto e que o Trabalho derivado fica restrito.

Expressiva vencida (`trancarExpressivasVencidas`) ficou de fora de propósito: `AcessoTrabalho` já recusa `gesto == .expressiva`, logo um Trabalho dessa origem nunca chegou a armar.

## P3 — feitos
- Flow autossuficiente: aceita "Abrir com Traço?" depois de `openLink` (`runFlow when visible: "Abrir"`), não toca mais em data literal (a promessa é "Toca hoje às …"), e ganhou o trecho que **reabre** o Trabalho e fotografa a folha reaberta. Dois `assertNotVisible: "Toca hoje às.*"` guardam a contradição de voltar.
- `CalendarioTrabalho.eventos` voltou a ser projeção pura: o `cancelarAcoes` por refresh saiu. Quem cala é o ato (Sessao) e a revalidação da Oficina.
- `Revisoes.acaoDaNotificacao` expira em `validadeDoToque` (300 s): guardado com instante, ignorado depois. Teste `toqueNaNotificacaoExpiraENaoAbreOTrabalhoHorasDepois`.
- "Avisar" ganhou `Tema.chrome`/`Tema.tinta`, o mesmo peso do rótulo irmão "Dia e hora" do DatePicker.

## Fora (registrado)
- "Liberar a origem não re-arma" continua fora, mas agora é visível: a folha reaberta mostra `.semAviso` com "Este aviso não está marcado no iPhone — guarde o horário de novo."
- Não existe rota de apagar Trabalho; quando nascer, precisa do mesmo gancho.
- `agendarAcao` devolve `.semPermissao` também para `.naoPerguntado` (o pedido não resolveu). Em iPhone de verdade o diálogo resolve; em simulador não. Não mexido.
