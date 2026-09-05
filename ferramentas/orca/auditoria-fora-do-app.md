# Auditoria fora do app — volta F1 da trilha Fora do app

Worker: Fable 5.1 (trilha Fora do app), 05/09/2026, worktree `fora-1-auditoria` sobre main `d4d98da`. Nenhum arquivo de código editado. Simulador de teste: iPhone Air `64F7B8B4` (tem Ilha), ligado e desligado por esta volta. Capturas: `ferramentas/orca/fora1-*.png` (todas por `xcrun simctl io <udid> screenshot`, nenhuma de preview do Xcode) e, do revisor G3 (`ferramentas/orca/revisao-f1-auditoria.md`), `ferramentas/orca/f1-rev-*.png`. Corrigido após o G3 em 05/09: D1 reclassificado, notas de Atalhos/Intents, D7 no cartão, captura escura, F2 conforme o conselho, fecho ao fim.

Linha da volta: ciclo MULTIPLICAR; intenção: saber com captura real o que cada superfície fora do app entrega hoje e quanto vale; obstáculo: widgets, Live Activities, atalhos e intents sem inventário nem nota; evidência: este arquivo + capturas.

Correção ao brief: o brief diz "12 AppShortcuts e 10 AppIntents". O código tem **10 AppShortcuts** (`TracoAtalhos`, `Intencoes.swift:54-117`) e **12 AppIntents** (10 em `Intencoes.swift` + 2 em `TracoWidget/`). Os números estavam trocados.

## 1. Inventário

### 1.1 Widgets (WidgetKit) — `TracoWidget/TracoWidget.swift`

| superfície | família | arquivo:linha | mostra | toque | abre | selo |
|---|---|---|---|---|---|---|
| TracoWidget "Traço" | systemSmall | `TracoWidget.swift:93-137` | rótulo TRAÇO; Destaque de hoje com círculo (ou nada, se não há Destaque); "Nova nota" (âmbar) e "Recordar" empilhados | círculo/linha → `DestaqueFeitoIntent` (alterna feito, sem abrir o app); "Nova nota" → `traco://nova`; "Recordar" → `traco://recordar` | página em branco / Recordar da nota mais recente | linha vem de `DestaqueDoDia` (App Group); só entra se `!nota.fechada` (`Sessao.swift:1102-1114`); nunca expressiva (a forma Destaque não é expressiva) |
| TracoWidget "Traço" | systemMedium | `TracoWidget.swift:127-133` | idem, atalhos lado a lado | idem | idem | idem |
| TracoWidget "Traço" | accessoryRectangular | `TracoWidget.swift:56-85` | rótulo DESTAQUE + linha, círculo/check | linha inteira → `DestaqueFeitoIntent` | não abre | idem; sem Destaque mostra só "Traço" |
| TracoWidget "Traço" | accessoryInline | `TracoWidget.swift:54-55` | a linha do Destaque ou "Traço" | abre o app (padrão) | página | idem |
| TracoProximoWidget "Próximo compromisso" | systemSmall | `TracoWidget.swift:293-329` | PRÓXIMO, título, "hoje às 14:30", sino com a hora do aviso; ou "nada marcado" | widget inteiro → `traco://calendario` | Calendário no dia | só `EventoCalendario` do autor e do iPhone; deixa de nota e ação de Trabalho não entram (`Calendario.swift:948-976`) |
| TracoProximoWidget | systemMedium | idem | idem (mesma view, mais largura) | idem | idem | idem |
| TracoProximoWidget | accessoryRectangular | `TracoWidget.swift:267-284` | PRÓXIMO, título, quando | abre o app (widgetURL) | Calendário | idem |
| TracoProximoWidget | accessoryInline | `TracoWidget.swift:265-266` | "14:30 · Dentista" ou "Traço" | abre o app | Calendário | idem |
| accessoryCircular | — | não existe | — | — | — | — |

Orçamento: `ProvedorTraco.getTimeline` (`:19-24`) — 1 entrada, `.after(meia-noite)`. `ProvedorProximo.getTimeline` (`:241-249`) — 1 entrada, `.after(min(fim, início+60s))`, recarga forçada por `WidgetCenter.reloadTimelines` a cada `gravar` (`DestaqueDoDia.swift:110-114`, `ProximoCompromisso.swift:120-124`). Nenhuma `TimelineEntryRelevance` nem `WidgetRelevance` declarada (Smart Stack não tem como priorizar). Fundo: `containerBackground(Tema.fundo)` fixo em papel claro (`:90`, `:289`).

### 1.2 Live Activities (ActivityKit)

| atividade | estado | arquivo:linha | mostra | toque | termina | selo |
|---|---|---|---|---|---|---|
| DestaqueVivo (tela bloqueada) | linha do dia | `TracoWidget.swift:154-189` | ponto âmbar + DESTAQUE; círculo + linha 19pt | linha inteira → `DestaqueFeitoIntent` | `marcarFeito` encerra (`DestaqueDoDia.swift:80-85`); `staleDate` meia-noite (`:53-55`); `apagar` encerra | só linha do autor, `!fechada` |
| DestaqueVivo | stale (passou da meia-noite) | `:174` | "Traço" no lugar da linha | ainda é botão que marca | não termina sozinha: `staleDate` só marca `isStale`, não encerra | — |
| DestaqueVivo Ilha | compacta | `:210-217` | sparkle âmbar + linha (96pt) | abre o app | — | — |
| DestaqueVivo Ilha | expandida | `:192-209` | círculo 44pt + linha | círculo → `DestaqueFeitoIntent` | — | — |
| DestaqueVivo Ilha | mínima | `:218-221` | sparkle âmbar | abre o app | — | — |
| CompromissoVivo (tela bloqueada) | longe (>1h) | `:373-448` | PRÓXIMO, "em 3 h" relativo, título 21pt, hora, botão "Lembrar em 10 min" | botão → `LembrarDepoisIntent` | `staleDate = fim`; `atualizarAtividade` encerra quando fim < agora ou sem próximo (`ProximoCompromisso.swift:135-137`) | só compromisso do autor/iPhone |
| CompromissoVivo | contando (≤1h) | `:385-386` | timer h:mm:ss | idem | idem | — |
| CompromissoVivo | soneca pedida | `:418-421` | "lembro às 11:07" (âmbar) no lugar do botão | — | — | — |
| CompromissoVivo | sem permissão | `:414-417` | "avisos desligados no iPhone" (vermelho `Tema.aviso`) | — | — | — |
| CompromissoVivo | dia inteiro | `:383`, `:405` | sem relógio, só título | — | — | — |
| CompromissoVivo Ilha | compacta | `:497-515` | calendar âmbar + hora / timer / título | abre `traco://calendario` | — | — |
| CompromissoVivo Ilha | expandida | `:451-496` | calendar, timer, título, botão "Lembrar em 10 min" ou recado | botão → intent | — | — |
| CompromissoVivo Ilha | mínima | `:516-519` | calendar âmbar | abre o app | — | — |

Janela da Ilha do compromisso: só quando começa em ≤ 6 h (`ProximoCompromisso.swift:130`). Quem dispara: `ProximoCompromisso.publicar` (ao gravar no calendário e a cada `CalendarioAgenda:350`), e `DestaqueDoDia.gravar` ao salvar a nota (`Sessao.swift:1103`).

### 1.3 App Intents — `Traco/App/Intencoes.swift` e `TracoWidget/`

| intent | linha | abre o app | escreve | devolve | selo |
|---|---|---|---|---|---|
| NovaNotaIntent | `:7-18` | sim (`Rota.pendente = .novaPagina`) | não | — | — |
| AnotarIntent | `:22-39` | não | sim: `Entrada.depositar` em `entrada/` | diálogo "anotado." | import jamais tranca (ADR 05a) |
| AbrirNotasIntent | `:41-52` | sim | não | — | — |
| DestaqueDeHojeIntent | `:139-148` | não | não | linha do Destaque / "Sem destaque hoje." | linha do App Group |
| CompromissosDeHojeIntent (Meu dia) | `:150-176` | não | não | compromissos do dia, um por linha (inclui deixas do "Se") | deixa de nota trancada ou expressiva não entra (`Calendario.swift:247` guarda `!fechada, gesto != .expressiva`) |
| LinhasDeSentidoIntent | `:178-196` | não | não | N linhas de sentido | filtra `nuncaSai` |
| CorpusComoContextoIntent | `:198-211` | não | não | corpus Markdown inteiro | `FatiaCorpus`/`Corpus.corpoDoCorpus` aplicam o selo do export |
| EstaSemanaIntent | `:213-230` | não | não | revisão da semana em texto | idem |
| TrajetoriaIntent | `:233-247` | não | não | trajetória em texto | idem |
| MarcarCompromissoIntent | `:255-296` | não | sim: grava no calendário, agenda aviso, publica no App Group | "Dentista, sexta às 14:30. Eu te aviso." | — |
| DestaqueFeitoIntent (`LiveActivityIntent`) | `TracoWidget/DestaqueFeitoIntent.swift:15-28` | não | sim: alterna `destaqueFeitoEm` | — | — |
| LembrarDepoisIntent (`LiveActivityIntent`) | `TracoWidget/LembrarDepoisIntent.swift:20-72` | não | sim: aviso `soneca-<id>` +10 min; atualiza a Live Activity | — | — |

### 1.4 AppShortcuts (frases de Siri) — `Intencoes.swift:54-117`

| atalho | frases | intent |
|---|---|---|
| Nova nota | "Nova nota no Traço", "Escrever no Traço" | NovaNotaIntent |
| Anotar | "Anotar no Traço", "Anota no Traço" | AnotarIntent |
| Notas | "Minhas notas no Traço" | AbrirNotasIntent |
| Destaque de hoje | "Destaque de hoje no Traço", "Qual é o meu destaque no Traço" | DestaqueDeHojeIntent |
| Meu dia | "Meu dia no Traço", "O que tenho hoje no Traço" | CompromissosDeHojeIntent |
| Linhas de sentido | "Linhas de sentido do Traço" | LinhasDeSentidoIntent |
| Esta semana | "Minha semana no Traço", "Esta semana no Traço" | EstaSemanaIntent |
| Trajetória | "Minha trajetória no Traço" | TrajetoriaIntent |
| Marcar | "Marcar no Traço", "Marcar compromisso no Traço" | MarcarCompromissoIntent |
| Como contexto | "Contexto do Traço", "Minhas notas como contexto no Traço" | CorpusComoContextoIntent |

Sem atalho: DestaqueFeito e LembrarDepois (só botões de widget/Ilha). Nenhum `AppEntity`, nenhum `ControlWidget`, nenhuma extensão de compartilhar, nenhuma doação de intent, nenhum `AppShortcutsProvider.shortcutTileColor`.

### 1.5 Rotas `traco://` — `Intencoes.swift:333-356`, consumidas em `PaginaView.swift:210-215, 575-596`

| rota | destino | o que faz |
|---|---|---|
| `traco://nova`, `traco://` | `.novaPagina` | salva a página atual e abre uma em branco |
| `traco://notas` | `.notas` | aba Notas |
| `traco://calendario[/dia|semana|mes|ano]` | `.calendario` | aba Calendário na escala |
| `traco://recordar` | `.recordar` | Recordar da nota mais recente |
| `traco://anotar?texto=…` | `.anotar` | deposita em `entrada/` e recolhe na hora ("1 nota veio de fora.") |
| `traco://file/<uuid>` | — | não é rota do app: é o marcador de anexo dentro do texto |

### 1.6 Spotlight — `Traco/Notas/Holofote.swift`

Indexa até 5000 notas abertas (`:32`), só título e 120 caracteres do corpo; selada, queimada e expressiva em curso nunca entram (`:12-14`), reindexa em salvar/apagar/selar (`Sessao.swift:1214, 1271, 1407, 1539, 1660`). **Toque no resultado: nenhum handler** — não há `onContinueUserActivity(CSSearchableItemActionType)` nem `NSUserActivity` em lugar nenhum do app. O resultado abre o app na página em que estava, não na nota.

### 1.7 Notificações — `Traco/Recordar/Revisoes.swift`

| aviso | identificador | quando | nível | toque leva a | consumidor |
|---|---|---|---|---|---|
| Recordar (fila do dia) | `fila-do-dia` / `fila-dia-<i>` | hora da âncora, diário (`:123-164`) | normal | `abrirFila` | `PaginaView.swift:224` |
| Esta semana | `revisao-semanal` | domingo, âncora da noite (`:183-204`) | normal | `abrirSemana` | `:227` |
| Aviso do Se | `gatilho-<uuid>` | hora escrita no "Se" (`:207-226`) | time-sensitive | `abrirGatilho` | `:236` |
| Compromisso | `compromisso-<id>[-weekday]` | antecedência escolhida (`:248-299`) | time-sensitive | `abrirCompromisso(id)` | `:242` |
| Soneca da tela bloqueada | `soneca-<id>` | +10 min (`LembrarDepoisIntent.swift:47-51`) | time-sensitive | `abrirCompromisso(id)` | `:242` |
| Ação do Trabalho | `acao-<id>` | horário da ação (`:324-346`) | time-sensitive | `abrirCompromisso` + `acaoDaNotificacao` | `:242` |
| Série expressiva | `serie-<uuid>-<dia>` | dias 2-4 (`:392-412`) | normal | `abrirSerie` | `:231` |
| Revisão da nota | `uuid` | escada 3/7/21/60/180/365 | normal | `abrirRevisao` | `:216` |

Nenhum aviso tem `categoryIdentifier`: **nenhuma ação no banner** (não dá para "Lembrar em 10 min" ou "Feito" sem abrir o app a partir do aviso). Corpo sempre vazio (só título): nada de conteúdo de nota vaza no banner.

### 1.8 O que NÃO existe hoje

Controle da Central de Controle / tela bloqueada (`ControlWidget`), botão de Ação dedicado (só via atalho genérico), `accessoryCircular`, widget configurável (`AppIntentConfiguration`), `AppEntity` de nota/compromisso/trabalho, extensão de compartilhar, ditado fora do app, Focus filter, sugestões de Siri por horário (`IntentDonation`/`WidgetRelevance`), Live Activity da ação de Trabalho (EVOLUCAO já lista como lacuna), ações no banner do aviso.

## 2. Captura real no simulador (iPhone Air, iOS 26.5)

Dados plantados: nota com três linhas curtas (motor local, `TRACO_SEM_MODELO=1`) que o app vestiu como DESTAQUE ("correr antes do café") e compromisso "Dentista hoje às 19:33" pela prosa do calendário (`fora1-app-destaque-vestido.png`, `fora1-app-ficha-compromisso.png`). Nada protegido.

| superfície | estado | captura | visto |
|---|---|---|---|
| Widget Traço systemSmall + systemMedium, Próximo systemSmall + systemMedium | claro | `fora1-inicio-widgets-claro.png` | os quatro na tela de início; o pequeno corta a linha em "correr antes…" (uma linha, não duas); médio do Próximo é o pequeno com espaço vazio |
| idem | escuro | `fora1-inicio-widgets-escuro.png` | **a captura não distingue o escuro**: o fundo de tela e os widgets são iguais aos da clara, porque o widget usa papel fixo (`containerBackground(Tema.fundo)`, sem variante) e o fundo de tela do simulador não muda com `appearance dark`. O modo escuro fica provado por código (D11), não pela tela; captura com prova visível (galeria em escuro ao lado) fica para o aparelho em F4/F5 |
| idem | Dynamic Type accessibility-extra-large | `fora1-inicio-widgets-dynamic-type-axl.png` | nenhum texto do widget cresce (fontes fixas `.system(size:)`); os rótulos do iOS ao lado crescem |
| Widget Traço | Destaque feito (toque no círculo) | `fora1-inicio-destaque-feito-ilha-compacta-compromisso.png` | check + tinta fraca, ~4 s para o widget refletir; o risco (`strikethrough`) não se vê |
| Galeria de widgets | 4 páginas | `fora1-galeria-widget-traco.png`, `fora1-galeria-proximo-vazio-nada-marcado.png` | descrição "O Destaque do dia na tela bloqueada. Na casa: uma página ou Recordar." e "nada marcado" |
| Widget Próximo | compromisso apagado | `fora1-inicio-proximo-apagado-widget-desatualizado.png` | widget readicionado mostrou "Dentista 19:33" com o App Group já vazio: linha do tempo arquivada (`.after(19:34)`) serviu conteúdo velho |
| Rotas do widget | Nova nota / Próximo | `fora1-rota-widget-nova-nota.png`, `fora1-rota-widget-proximo-calendario.png` | página em branco com cursor; Calendário no dia |
| Tela bloqueada | DestaqueVivo | `fora1-bloqueada-destaque-vivo-pilha.png` | ponto âmbar, DESTAQUE, círculo + linha; o CompromissoVivo existia (log) mas ficou na pilha atrás, invisível |
| Tela bloqueada | CompromissoVivo com botão | `fora1-bloqueada-compromisso-vivo-botao-lembrar.png` | "PRÓXIMO · 16 minutos · Dentista 19:33 · Lembrar em 10 min" |
| Tela bloqueada | CompromissoVivo após o toque sem permissão | `fora1-bloqueada-compromisso-vivo-avisos-desligados.png`, `fora1-bloqueada-compromisso-vivo.png` | "avisos desligados no iPhone" em vermelho; sem caminho para os Ajustes |
| Ilha compacta | DestaqueVivo | `fora1-ilha-compacta-destaque.png` | sparkle + "correr antes d…" |
| Ilha compacta | CompromissoVivo contando | `fora1-inicio-destaque-feito-ilha-compacta-compromisso.png` | "21:34" (contagem mm:ss que se lê como hora do relógio); noutro momento "14 min…" cortado |
| Ilha expandida | DestaqueVivo | `fora1-ilha-expandida-destaque.png` | círculo + linha; regiões leading/trailing/center vazias |
| Ilha expandida | CompromissoVivo | `fora1-ilha-expandida-compromisso.png` | calendário, "21:15", Dentista, botão "Lembrar em 10 min" |
| Ilha expandida | após o toque sem permissão | `fora1-ilha-expandida-avisos-desligados.png` | "avisos desligados no iPhone" no lugar do botão |
| Ilha mínima | duas atividades | NÃO CAPTURADA | as duas atividades são do mesmo app: o iOS mostra só uma na Ilha (o Destaque) e empilha a outra na tela bloqueada; a mínima só aparece com atividade de OUTRO app, e o simulador não tem Relógio/Timer para gerar uma |
| Live Activity termina sozinha | apagar o compromisso | `fora1-inicio-proximo-apagado-widget-desatualizado.png` (Ilha vazia) | CompromissoVivo encerrou no apagar; DestaqueVivo encerrou no "feito" |
| Tela bloqueada: accessoryRectangular / accessoryInline | — | NÃO CAPTURADA: `fora1-bloqueada-editor-sem-controles-simulador.png` | o toque longo na tela bloqueada do simulador abre a galeria de fundos sem os botões "Personalizar"/"+"; não há como adicionar widget accessory no simulador. A galeria de widgets do sistema confirma que as famílias existem (código `:147`, `:339`) |
| StandBy | paisagem + bloqueado | NÃO DISPONÍVEL: `fora1-standby-nao-disponivel-simulador.png` | a tela bloqueada do simulador não gira nem entra em StandBy (exige carga + paisagem em aparelho); o StandBy mostra o systemSmall, cuja captura está acima. A captura registra outra coisa: às 19:14 o cartão do CompromissoVivo mostra "18:20" (timer), enquanto às 19:12 e 19:16 (`fora1-bloqueada-compromisso-vivo-botao-lembrar.png`, `fora1-bloqueada-compromisso-vivo.png`) o mesmo cartão mostra "20 minutos" e "16 minutos" (relativo). O flip timer/relativo de D7 acontece no cartão da tela bloqueada, não só na Ilha (`contando()` decidido na renderização, `TracoWidget.swift:351-354, 385-389`) |
| Spotlight | busca "correr" | `fora1-spotlight-resultado.png` | seção Traço com título e trecho da nota |
| Spotlight | toque no resultado | `fora1-spotlight-toque-cai-no-calendario.png` | o app abre onde estava (Calendário), não na nota |
| Atalhos (app) | lista | `fora1-atalhos-lista.png` | os 10 App Shortcuts com ícone e título |
| Atalhos (app) | executar "Destaque de hoje" e "Meu dia" | `f1-rev-atalhos-release-alerta.png` (revisor, build Release, 19:37); `f1-rev-atalhos-url-nao-existe.png` | **"Não foi possível executar o atalho do app"**, em Debug e em Release. Log do `linkd`: `Failed to generate bundleIdentity: Unable to get teamId from app.traco` → `Rejecting invalid client due to requiresValidBundle`. Causa (revisor, confirmada): o pacote de simulador sai com assinatura adhoc, `TeamIdentifier=not set`, e os entitlements embutidos não têm `com.apple.developer.team-identifier`; o `linkd` exige teamId para executar App Shortcuts. Não é o dylib de depuração (Release falha igual). **Defeito do instrumento**, não do produto; no aparelho, assinado com o time, fica **não provado**. `shortcuts://run-shortcut?name=…` não serve para App Shortcuts ("O arquivo não existe") |
| Siri | frases | tabela 1.4 | `xcrun simctl` não fala; frases documentadas, não ouvidas |
| Notificação | banner + toque | NÃO CAPTURADA | `xcrun simctl push` com `userInfo compromisso` foi aceito ("shouldPresentAlert: YES") mas nenhum banner apareceu na tela bloqueada; a permissão de avisos nunca foi pedida na tela durante o fluxo (o alerta do sistema não apareceu ao marcar pela prosa) — ver defeito D5 |
| Vídeo simctl | — | nenhum | não há transição própria do app nas superfícies (a Ilha abre/fecha com o movimento do sistema); o `recordVideo` ficou fora |

Restaurações: `content_size` estava em `large` antes e voltou para `large` (o brief pedia "medium", mas o valor original do aparelho era `large`, e restaurar é devolver o que estava); `appearance` voltou para `light`; simulador desligado ao fim.

## 3. Notas por superfície (0-10, evidência = captura)

| superfície | Fora do app | Design | Simplicidade | Movimento | Acessib. | Privacidade | Estado honesto | evidência |
|---|---|---|---|---|---|---|---|---|
| Widget Traço (casa, small/medium) | 6 | 5 | 7 | n/a | 3 | 9 | 6 | `fora1-inicio-widgets-*.png`, `fora1-inicio-destaque-feito-*.png` |
| Widget Próximo (casa) | 5 | 5 | 8 | n/a | 3 | 9 | 5 | `fora1-inicio-widgets-claro.png`, `fora1-inicio-proximo-apagado-*.png` |
| Widget Traço accessory (bloqueada) | n/c | n/c | n/c | n/a | n/c | 9 (código) | n/c | não capturável no simulador |
| Widget Próximo accessory (bloqueada) | n/c | n/c | n/c | n/a | n/c | 9 (código) | n/c | idem |
| DestaqueVivo (tela bloqueada) | 7 | 7 | 8 | 6 | 5 | 9 | 6 | `fora1-bloqueada-destaque-vivo-pilha.png` |
| DestaqueVivo (Ilha) | 6 | 5 | 8 | 6 | 5 | 9 | 7 | `fora1-ilha-compacta-destaque.png`, `fora1-ilha-expandida-destaque.png` |
| CompromissoVivo (tela bloqueada) | 7 | 7 | 8 | 6 | 5 | 9 | 4 | `fora1-bloqueada-compromisso-vivo*.png`, `fora1-standby-nao-disponivel-simulador.png`: o próprio cartão alterna "20 minutos" / "18:20" / "16 minutos" em três capturas (D7) |
| CompromissoVivo (Ilha) | 6 | 6 | 8 | 5 | 5 | 9 | 4 | `fora1-ilha-expandida-compromisso.png`, `fora1-inicio-destaque-feito-ilha-compacta-compromisso.png` |
| App Shortcuts / Siri | n/c (instrumento) | 7 | 8 | n/a | 6 | 8 | n/c (instrumento) | `fora1-atalhos-lista.png`, `f1-rev-atalhos-release-alerta.png`; o build de simulador não tem team-identifier e o `linkd` recusa (D1): nota de produto só com prova no aparelho |
| Intents que escrevem (Anotar, Marcar) | n/c (instrumento) | n/a | 8 | n/a | n/a | 9 | n/c | não executáveis pelo app Atalhos no simulador (D1, mesmo motivo); `traco://anotar` executou pela rota (linha Rotas) |
| Rotas traco:// | 8 | n/a | 9 | n/a | n/a | 9 | 8 | `fora1-rota-widget-*.png`, fluxo `maestro/anotar-de-fora.yaml` |
| Spotlight | 3 | n/a | 2 | n/a | n/a | 9 | 3 | `fora1-spotlight-*.png` |
| Notificações (toque) | 5 | n/a | 6 | n/a | n/a | 9 | 5 | código `Revisoes.swift:471-511`; banner não visto |

Legenda: n/a = não se aplica; n/c = não capturável no simulador (nota fica pendente de aparelho); n/c (instrumento) = a superfície existe e falhou por defeito do build de simulador, não do produto (D1); nota só com prova no aparelho.

Por que cada nota:

- **Widget Traço.** Um toque marca o Destaque sem abrir o app (6 em Fora do app, não mais porque o feito demora ~4 s e o "Nova nota" abre o app quando poderia ditar/anotar ali). Design 5: fontes em pontos fixos em vez dos degraus de `Tema` (`TracoWidget.swift:36, 71, 96, 109`), papel fixo em modo escuro, e "Recordar" cinza ao lado de "Nova nota" âmbar sem hierarquia clara. Acessibilidade 3: Dynamic Type ignorado, alvo do círculo 14 pt (o botão cobre a linha inteira, mas o affordance é o círculo). Estado honesto 6: feito mostra check, mas o `strikethrough` não aparece; sem Destaque o widget simplesmente esconde a linha, sem dizer "sem destaque hoje" nem oferecer escrever um.
- **Widget Próximo.** Mostra hora do aviso (bom, ADR 04a), mas promete "🔔 19:33" enquanto a Live Activity diz "avisos desligados" (Estado honesto 5); a linha do tempo arquivada serviu compromisso apagado ao readicionar (D6). Medium é o small esticado (Design 5). Toque abre o Calendário, nada resolve ali (Simplicidade 8 porque é uma coisa só, mas sem ação).
- **DestaqueVivo.** Tela bloqueada é a superfície mais bem resolvida: tipografia, ponto âmbar, um toque marca e o cartão sai (ADR 04f cumprida). Ilha expandida usa só a região `.bottom`: círculo + linha num retângulo vazio (Design 5). Acessibilidade 5: rótulo "Marcar como feito" existe, mas 19 pt fixos. Estado honesto 6: `isStale` troca a linha por "Traço" mas mantém o botão que marca uma linha que não se vê (`:174`).
- **CompromissoVivo.** Botão que vira texto (ADR 04f) funciona nos dois lugares e o recado vermelho é honesto. Mas: a contagem "21:34"/"20:59" na Ilha compacta se lê como hora do relógio (Estado honesto 4); "14 min…" saiu cortado; o mesmo estado apareceu como "20 minutos" (relativo) no cartão e "20:59" (timer) na Ilha, e o próprio cartão da tela bloqueada alternou "20 minutos" → "18:20" → "16 minutos" em três capturas seguidas (Estado honesto 4 também na bloqueada); "avisos desligados" não leva aos Ajustes (ADR 03e, beco); o recado some em qualquer republicação (`publicar` grava `recado: nil`, `ProximoCompromisso.swift:141`) e o botão volta, para falhar de novo.
- **App Shortcuts.** Estrutura boa (10 atalhos, frases em português, ícones), mas no simulador nenhum executa pelo app Atalhos por falta de team-identifier no build (D1, instrumento). Sem prova no aparelho, a nota de produto fica n/c. Sem `shortcutTileColor`, sem `updateAppShortcutParameters`.
- **Spotlight.** Indexa bem (título + trecho, selo respeitado), mas o toque abre o app onde estava (D2): ADR 04a, motor sem superfície.
- **Rotas.** Levam ao lugar certo com estado pronto (`Nova nota` chega com cursor). Primeiro uso pede "Abrir com Traço?" (do sistema, aceitável).
- **Notificações.** Rotas de toque cobertas no código para as oito famílias; sem ações no banner; banner não observado nesta volta.

## 4. Defeitos, por severidade (lei citada)

**Alta**
- **D1 — App Shortcuts não executam no simulador: defeito do INSTRUMENTO** (reclassificado no G3). "Não foi possível executar o atalho do app" em Debug e em Release (`f1-rev-atalhos-release-alerta.png`). Causa confirmada pelo revisor: o build de simulador sai com assinatura adhoc, sem `com.apple.developer.team-identifier` nos entitlements embutidos, e o `linkd` recusa (`Unable to get teamId from app.traco`). O dylib de depuração não tem relação. Produto no aparelho: **não provado** (provável que execute, assinado com o time). Continua em Alta porque, enquanto o instrumento não executa intents, Siri, Atalhos e botão de Ação não têm prova nesta trilha. Saída em F2: prova no aparelho do dono (captura do Atalhos executando "Destaque de hoje" e "Anotar") ou build de simulador com `com.apple.developer.team-identifier` embutido (candidato: chave no `Traco.entitlements` só para o SDK do simulador; testar). `Intencoes.swift:54`.
- **D2 — Spotlight sem destino**: toque no resultado abre o app na tela anterior. Não existe `onContinueUserActivity(CSSearchableItemActionType)`. ADR 04a (motor sem superfície), design-router auditar: "quando abre, chega direto na tela certa". `Holofote.swift`, `PaginaView.swift`.
- **D3 — Dynamic Type ignorado em todos os widgets e Live Activities**: tudo em `.system(size:)` fixo (`TracoWidget.swift:36-516`). ESTEIRA Acessibilidade (Dynamic Type até XXL). Captura `fora1-inicio-widgets-dynamic-type-axl.png`.
- **D4 — Promessa contraditória entre superfícies**: widget "🔔 19:33" e ficha "Toca hoje às 19:33" enquanto a Live Activity diz "avisos desligados no iPhone". `Aviso.instante` não consulta a autorização; `mudo` só cobre a recusa no instante de agendar (`Calendario.swift:964`). ADR 04a pergunta 2 (como ele sabe que aconteceu ou por que não).

**Média**
- **D5 — Permissão de avisos não pedida na tela ao marcar pela prosa**: no fluxo automatizado o alerta do sistema nunca apareceu e o intent viu "não autorizado". Reproduzir manualmente no aparelho antes de fechar (pode ser artefato do simulador). ADR 03e/04a.
- **D6 — Linha do tempo arquivada serve conteúdo apagado**: widget readicionado mostrou "Dentista" com o App Group vazio, até a política `.after(inicio+60s)` vencer. Mitigação: `reloadAllTimelines` no `gravar(nil)` ou política `.atEnd` com entrada de ausência. ADR 04a ("deixar o de ontem na tela bloqueada é mentira barata", `ProximoCompromisso.swift:73`).
- **D7 — Contagem lida como relógio e flip timer/relativo, na Ilha e no cartão**: "21:34" na Ilha compacta no lugar onde o iOS mostra horas, "14 min…" truncado (`TracoWidget.swift:506-515`, `frame(maxWidth: 52)`); e o cartão da tela bloqueada alterna "20 minutos" (19:12) → "18:20" (19:14) → "16 minutos" (19:16), porque `contando()` é decidido na renderização (`:351-354, 385-389`). Estado honesto 4 nas duas superfícies; design-router julgar.
- **D8 — Recado "avisos desligados" é beco**: sem link para os Ajustes na Live Activity (`:414-417`, `:470-473`). ADR 03e "nenhuma permissão negada é um beco".
- **D9 — Duas atividades do mesmo app**: o iOS mostra só uma na Ilha e empilha na tela bloqueada; o Destaque escondeu o compromisso que estava a 37 min. Ordem de prioridade não é controlada (ambas `Activity.request` sem `relevanceScore`). Fora do app.
- **D10 — Sem `TimelineEntryRelevance`/`WidgetRelevance`**: Smart Stack não sabe quando subir o Próximo (por exemplo, na hora do compromisso). Orçamento/relevância declarada, brief da trilha.
- **D11 — Papel fixo no widget em modo escuro** e sem tratamento de `widgetRenderingMode` (tinted/accented do iOS 18+): `containerBackground(Tema.fundo)` (`:90`, `:289`). ADR 02h decide mundo claro no app; no widget o fundo do sistema é escuro e o cartão vira bloco branco — decisão de design a tomar no F2 (design-router Sistema).

**Baixa**
- **D12 — Widget pequeno corta o Destaque em uma linha** ("correr antes…"), `lineLimit(2)` sem espaço por causa dos dois atalhos. Simplicidade/Design.
- **D13 — Próximo medium = small esticado**; regiões leading/trailing/center vazias na Ilha expandida do Destaque. Design (composição).
- **D14 — Ausência muda**: sem Destaque, o widget da casa só esconde a linha e o accessory diz "Traço"; não diz "sem destaque hoje" nem oferece escrever um (curva-zero: o próximo passo evidente).
- **D15 — Feito não restaura a Live Activity** ao desmarcar (`desmarcarFeito` não chama `atividade`, `DestaqueDoDia.swift:87-91`); `isStale` mantém botão sem linha (`TracoWidget.swift:174`).
- **D16 — `strikethrough` do feito invisível** na captura; o estado lê só pelo check e pela tinta.
- **D17 — Nenhuma ação no banner do aviso** (`categoryIdentifier` ausente): "Lembrar em 10 min" só existe na Live Activity; no banner o único gesto é abrir o app. ADR 04f.
- **D18 — Build com 1 aviso** (`EditorBlocoView.swift:270`, closure não-Sendable), fora da área da trilha mas o G1 exige zero.

## 5. O que falta em relação ao brief (F2-F11)

| volta | existe hoje | onde | falta |
|---|---|---|---|
| F2 Fundação | 12 intents soltos no app; App Group por `UserDefaults` com chaves soltas (`DestaqueDoDia`, `ProximoCompromisso`); widget compila 4 fontes do app por cópia (`project.yml:63-67`); `ProvedorProximo` pede reload a cada minuto após início+60s | `Intencoes.swift`, `Traco/Modelo/*` | conforme o conselho (`consulta-fora-intents.md`, main): **sem framework nem package**; `Traco/App/Intents/` compilado nos dois alvos só onde preciso, tipos e nomes preservados; entidades mínimas (NotaEntity, CompromissoEntity, TrabalhoEntity com `AcessoTrabalho`), não o catálogo inteiro; snapshot Codable versionado e atômico no App Group no lugar das chaves soltas, com "Atualizado há…/Desatualizado" (resolve D6 e o reload por minuto); os dois `LiveActivityIntent` com identidade do item (UUID+dia / UUID+ocorrência), feito=true em vez de toggle, soneca só confirma após sucesso, **stale neutraliza ação** (D15); tokens do widget vindos de `Tema` (D3); prova de instrumento para D1 |
| F3 Captar pensamento em um toque | `AnotarIntent` (texto por Siri/Atalhos), `traco://anotar`, `NovaNotaIntent` abre página em branco | `Intencoes.swift:22-39`, `:333-356` | `ControlWidget` na tela bloqueada/Central, botão de Ação dedicado, abrir já em ditado, ditado que salva áudio antes de transcrever, `AnotarIntent` executável (D1) |
| F4 Widget "próxima volta" interativo | Destaque com botão feito (widget e Live Activity) | `TracoWidget.swift:103-120`, `DestaqueFeitoIntent.swift` | conceito "próxima volta" (ação de Trabalho/fila do Recordar) não existe fora do app; EVOLUCAO já lista "widget/Ilha da ação" como lacuna; Dynamic Type (D3); ausência com próximo passo (D14) |
| F5 Ilha do compromisso, estados completos | compacta/expandida/mínima, timer ≤1h, soneca, sem permissão, dia inteiro; encerra no apagar e no feito | `TracoWidget.swift:363-523` | estado "começou/em curso", "atrasado", "acabou"; contagem legível e sem flip timer/relativo (D7); beco dos Ajustes (D8); prioridade entre Destaque e compromisso (D9); recado que sobrevive a republicação; **Live Activity órfã ou stale não encerra sozinha**: `staleDate` só marca `isStale`, não chama `end`; falta reconciliar atividades ativas com o estado persistido no arranque, no retorno e nos comandos, e encerrar quando executando (o brief exige "termina sozinha e nunca fica órfã") |
| F6 accessoryCircular + inline do dia | accessoryInline e Rectangular dos dois widgets | `:54-85`, `:265-284` | `accessoryCircular` (não existe), captura real em aparelho (simulador não deixa adicionar) |
| F7 Controle da Central para Recordar | `traco://recordar` e `AbrirNotasIntent` | `Intencoes.swift:41-52` | `ControlWidget` + `OpenIntent` para Recordar |
| F8 Widget configurável por pasta/método | nenhum (`StaticConfiguration`) | `:142`, `:334` | `AppIntentConfiguration` com `AppEntity` de pasta/método (depende de F2) |
| F9 Spotlight com notas e trabalhos | notas abertas indexadas (título + 120 caracteres) | `Holofote.swift` | destino do toque (D2), Trabalhos no índice, `IndexedEntity`/`CSSearchableItem` com `userActivity` |
| F10 Extensão de compartilhar | nenhuma; ADR 05a adia (app group + provisionamento) | — | target Share Extension gravando em `entrada/` com origem preservada (texto, link, imagem) |
| F11 Sugestões de Siri por horário | nenhuma doação; `AppShortcutsProvider` sem parâmetros | — | `IntentDonation`/`AppShortcut` com `AppEntity`, `WidgetRelevance` por âncora (manhã/tarde/noite) |

Transversal, antes de qualquer F: D1 (instrumento: prova no aparelho ou team-identifier no build de simulador), D3 (tipografia de `Tema` no widget) e D4/D6 (uma fonte de verdade para "vai avisar").

## 6. Consulta ao conselho

Pergunta em `ferramentas/orca/consulta-fora-intents-pergunta.md`; resposta do conselho (Astra) em `ferramentas/orca/consulta-fora-intents.md`, em main. Decisões que entram em F2: sem framework/package; `Traco/App/Intents/` nos dois alvos só onde preciso; app como único escritor de domínio; snapshot Codable versionado no App Group; entidades mínimas com selo revalidado em `perform()`; `staleDate` não encerra, stale neutraliza ação; captação por Siri continua em `AnotarIntent` → `Entrada.depositar`, ditado próprio fica para F3.

## 7. O que não foi possível, literalmente

- Widgets `accessoryRectangular`/`accessoryInline` na tela bloqueada: o simulador não expõe "Personalizar" (captura `fora1-bloqueada-editor-sem-controles-simulador.png`).
- StandBy: o simulador não entra (não gira a tela bloqueada, não tem estado de carga).
- Ilha mínima: exige Live Activity de outro app; o simulador não tem Relógio.
- Siri por voz: `simctl` não fala; e os App Shortcuts falharam pelo app Atalhos por defeito do instrumento (D1, build de simulador sem team-identifier), então nenhum intent foi executado de fora nesta volta; produto não provado.
- Banner de notificação e seu toque: permissão nunca chegou a ser concedida na tela (D5); `simctl push` aceito mas sem banner.
- Vídeo: não há transição própria do app nestas superfícies; não gravado.

## 8. Fecho (seis linhas)

1. O que veio: inventário completo do que o Traço faz sem o app aberto (4 famílias de widget em 2 widgets, 2 Live Activities, 12 intents, 10 atalhos, 5 rotas, Spotlight, 8 famílias de aviso), com 24 capturas reais no iPhone Air e nota 0-10 por superfície.
2. O que vale: o Destaque na tela bloqueada é a superfície mais bem resolvida (um toque marca e o cartão sai); as rotas `traco://` chegam com estado pronto; nada fora do app expõe nota selada, queimada ou expressiva (queries conferidas pelo revisor).
3. O que falta: Dynamic Type em todo o widget (D3), Spotlight sem destino (D2), promessa "🔔 19:33" contraditória com "avisos desligados" (D4), widget que serve compromisso apagado (D6), contagem que se lê como hora e alterna timer/relativo no cartão e na Ilha (D7), Live Activity stale que não encerra sozinha.
4. D1 com a causa certa: os App Shortcuts não executam no simulador porque o build sai sem `com.apple.developer.team-identifier` e o `linkd` recusa; é defeito do instrumento, o produto no aparelho fica não provado, e Atalhos/Intents recebem n/c em vez de nota.
5. Capturas: `ferramentas/orca/fora1-*.png` (worker) e `ferramentas/orca/f1-rev-*.png` (revisor: alerta em Release, lista em Debug, `shortcuts://` que não serve); não capturáveis no simulador: accessory na bloqueada, StandBy, Ilha mínima, Siri por voz, banner.
6. Próxima volta: F2 Fundação conforme o conselho, sem framework; catálogo em `Traco/App/Intents/`, snapshot versionado, dois `LiveActivityIntent` com identidade e stale neutralizado, entidades mínimas; e prova de instrumento para D1 antes de qualquer nota de Siri.

Linha proposta para o LACO:

- 2026-09-05 · F1 auditoria fora do app · inventário de widgets, Live Activities, 12 intents, 10 atalhos, rotas, Spotlight e avisos com nota por superfície; 18 defeitos (D2 Spotlight sem destino, D3 Dynamic Type, D4 promessa contraditória, D6 widget serve apagado, D7 flip timer/relativo); D1 reclassificado como instrumento (build de simulador sem team-identifier, `linkd` recusa), produto não provado; lacunas F2-F11 com F2 fixada pelo conselho (sem framework, snapshot versionado, stale neutraliza) · ferramentas/orca/auditoria-fora-do-app.md + 24 capturas fora1-*.png + 3 f1-rev-*.png; revisão G3 Fable em revisao-f1-auditoria.md: 0 achados de código, 6 correções de texto feitas; consulta Astra em consulta-fora-intents.md · <commit> · cotas a preencher pelo orquestrador

## 9. G0 de F2, revisado (≤ 8 linhas)

1. Ciclo MULTIPLICAR · intenção: o mesmo comando produz o mesmo estado confirmado em qualquer entrada (widget, Ilha, Siri, URL) sem expor nota protegida · obstáculo: 12 intents soltos, chaves soltas no App Group, dois intents que confirmam sem persistir · evidência: testes sem UI + capturas por estado.
2. Escopo: `project.yml`, `Traco/App/Intents/` (novo, tipos e nomes preservados), `Intencoes.swift`/`Rota`, `TracoWidget/`, `DestaqueDoDia`/`ProximoCompromisso` → snapshot versionado, pontos de commit em `Sessao`/`Calendario`, `Tema.swift` para tipografia do widget (D3: degraus de `Tema` no lugar de 39 tamanhos fixos).
3. Critérios: build dos dois alvos com zero avisos (inclui D18); persistência recusada não confirma; repetição não duplica nem inverte; item velho não altera novo; snapshot truncado/expirado mostra "Desatualizado"; stale sem botão ativo; widget readicionado nunca mostra compromisso apagado (D6).
4. Prova de instrumento: App Shortcuts executando "Destaque de hoje" e "Anotar" pelo app Atalhos no aparelho do dono OU no simulador com `team-identifier` embutido; captura obrigatória; sem isso, nenhuma nota de produto para Siri/Atalhos.
5. Fora do escopo de F2: D2 (Spotlight → F9), D7/D8/D9 e o encerrar da atividade órfã (Ilha → F5), D11 papel escuro (decisão de design em G0 de F4/F5), controles e ditado (F3).
6. Divisão: se catálogo + snapshot + dois intents + entidades mínimas não fecha numa volta, entidades mínimas viram F2b; não declarar fundação sem prova.
