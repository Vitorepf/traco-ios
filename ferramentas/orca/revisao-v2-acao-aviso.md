# Revisão da volta 2 — a ação do Trabalho avisa (ADR 2026-09-05n proposta)

Revisor: Claude Fable 5.1, sessão independente. Nada corrigido; só reportado.

## Veredito: CORRIGIR ANTES (lista mínima no fim)

## Provas executadas
- Build limpo: `xcodebuild build … -destination id=1A46B6D3 … -derivedDataPath build` → BUILD SUCCEEDED, 0 warnings (strict concurrency complete, default MainActor).
- Suíte integral no UDID de teste 6033B043 (iPhone 17 Pro Max), `-derivedDataPath build-v2`:
  `✔ Test run with 566 tests in 120 suites passed after 7.112 seconds.` — inclui `Suite AvisoDaAcaoTests passed`, `Suite CalendarioTrabalhoTests passed`. 0 warnings. Simulador de teste desligado ao fim (o iPhone 17 Pro C2416CBC apareceu booted por outra sessão; não toquei).
- Flow `./maestro/varrer.sh maestro/trabalho-acao-aviso.yaml` com só o iPhone 17 do dono booted e build recompilado (o binário em `build` era das 13:24, anterior às fontes das 14:13): `FALHAS: nenhuma`. Captura simctl ao fim: estado vermelho "O iPhone está com os avisos do Traço desligados — nada vai tocar." + "Abrir os Ajustes" + abaixo "Toca sexta-feira, 11 de set. às 14:11 · 30 min antes."
- Capturas do implementador conferidas (conteúdo real): `v2-acao-aviso-antes.png` (cápsula "🔔 30 min antes ⌄", promessa "Toca sexta-feira, 11 de set. às 13:55 · 30 min antes.") e `v2-acao-aviso-depois.png` (estado vermelho + Ajustes + picker + promessa "Toca … às 14:02"). `v2-acao-aviso-depois-sem-permissao.png` citada no spec NÃO existe.
- Captura nova: `ferramentas/orca/v2-acao-aviso-reaberto.png` (UDID de teste): folha reaberta depois do commit — horário "11 de set. de 2026, 14:46", NENHUMA linha de estado do aviso, e a promessa "Toca sexta-feira, 11 de set. às 14:16 · 30 min antes." num aparelho com permissão negada.
- Captura "Aviso marcado" NÃO obtida. Literalmente por quê: (a) `xcrun simctl privacy` não lista `notifications` entre os serviços; (b) no simulador de teste o diálogo "Permitir" nunca aparece — `requestAuthorization` volta negado sem prompt; (c) Ajustes › Apps › Traço nesse simulador não tem a linha "Notificações" (rolado até o fim: termina em "Dados Celulares"/"Permitir Rastreamento"), logo não há toggle a ligar; (d) "Abrir os Ajustes" no simulador abre a RAIZ dos Ajustes, não a página do app. O estado `.agendado` segue provado só pelo teste com motor injetado.

## Contratos conferidos (OK)
- Notificação nunca vira EventoCalendario no disco: `EventoCalendario.encode` lança para `origemTrabalho != nil` (Calendario.swift:130) e o teste `projecaoLevaOAvisoEContinuaSoLeitura` cobre; widget/Ilha filtram `origemTrabalho == nil` (Calendario.swift:962).
- Chave ausente → nil: `Acao.avisoMinutos: Int?` com Codable sintetizado; teste `chaveAusenteDecodificaComoSemAlertaEV4Continua`.
- Commit precede: `guardar()` chama `sincronizarAvisos()` só após `persistir(context)` (OficinaTrabalho.swift:94); teste `mudarHorarioReagendaEFalhaDeCommitNaoArma`.
- Executar/cancelar/retirar/mudar desarmam num ponto só (`sincronizarAvisos`); testes cobrem.
- Namespace `acao-<uuid>` ≠ `compromisso-…`/`gatilho-…`/`revisao-…`; `cancelarCompromisso` não alcança.
- Rota do toque revalida a origem: `aoAbrirTrabalho` em CalendarioView.swift:82 checa `AcessoTrabalho.permitido`.
- Título da notificação = `acao.texto` (escrito no Trabalho), não lê a nota de origem.
- Concorrência: build sem warnings; `isolated deinit`, `MainActor.assumeIsolated` no observer, `Revisoes` estático isolado ao MainActor por padrão do projeto.

## Achados

### P1
1. **Estado desonesto depois do commit e ao reabrir (ADR 04a, pergunta 2).** `OficinaTrabalho.avisos` nasce vazio a cada abertura; a folha reaberta não diz se o aviso está armado, e a promessa "Toca …" aparece mesmo com o iPhone negando avisos (captura `v2-acao-aviso-reaberto.png`). No próprio estado "depois", a linha vermelha "nada vai tocar" convive com "Toca sexta-feira … às 14:11" quatro linhas abaixo (`v2-acao-aviso-depois.png` e captura do flow). O texto antigo "sem alerta" era pobre, mas não contradizia a si mesmo. Correção mínima: ao abrir a Oficina, ler o centro uma vez (`pendingNotificationRequests` contém `acao-<id>` → `.agendado(instanteDaAcao)`; senão, `Avisos.estado() == .negado` → `.semPermissao`; senão `.semAviso`) e preencher `avisos`; e a promessa, quando o último resultado for semPermissao/semEspaco/passou, não afirmar "Toca" (ex.: "Tocaria … — os avisos do Traço estão desligados"). Isto também resolve o limite "liberar a origem não re-arma": passa a ser visível.

### P2
2. **Selar/queimar/apagar a nota de origem não cala o aviso no ato (ADR 05j).** `Sessao` cancela gatilho e revisão da nota (Sessao.swift:1062-1072, 1525, 1630-1631) mas nada chama `Revisoes.cancelarAcoes(doTrabalho:)`; `grep Trabalho Sessao.swift` vazio. O aviso só cala quando o calendário refaz `CalendarioTrabalho.eventos` ou a Oficina revalida. Até lá, o texto da ação do Trabalho restrito toca na tela bloqueada. A ADR diz "a proteção da origem cala pelo userInfo" — infla: cala na próxima revalidação, não no ato. Correção mínima: no ponto único de proteger/apagar nota, buscar Trabalhos com `notaOrigemID == nota.uuid` e cancelar; ou, mais barato, um passe no arranque que cancele avisos `acao-*` de Trabalhos não permitidos.
3. **Limite "liberar a origem NÃO re-arma"**: aceitável como decisão só com o P1 corrigido (o autor vê "sem alarme" e Guardar re-arma). Sem o P1, é estado desonesto: a folha mostra "Toca …" e nada está armado.

### P3
4. `CalendarioTrabalho.eventos` deixou de ser projeção pura: para cada Trabalho restrito (inclusive `.indisponivel`), a cada refresh (onAppear, onChange de conteudoJSON, scenePhase) dispara uma Task que enumera todas as pendentes. Deduplicar ou mover para onde a restrição é detectada.
5. `Revisoes.acaoDaNotificacao` não expira: no arranque a frio o post `abrirCompromisso` pode sair antes de PaginaView montar o `onReceive` (delegate instalado em TracoApp.swift:15); o par fica guardado e dispara horas depois na primeira abertura do calendário. Guardar com instante e ignorar depois de poucos minutos.
6. Design (fases julgar/portão): cápsula igual ao precedente ChipDominio/NotasView — `Tema.chip`, `PressaoDiscreta`, alvo 44 no Menu, sem retângulo (ADR 05f) ✔; promessa em hora real e pt-BR ✔; estado negado em `Tema.aviso` com "Abrir os Ajustes", sem cartaz ✔. Contra: rótulos irmãos com peso diferente — "Dia e hora" (body, tinta) e "Avisar" (meta, tintaSuave) na mesma coluna (law-of-similarity). Densidade: saiu uma frase, entrou um controle + uma linha; carga igual ou levemente maior, com informação acionável — o que pesa é a contradição do achado 1, não a quantidade.
7. Flow `maestro/trabalho-acao-aviso.yaml` não é autossuficiente em aparelho novo: `openLink` dispara "Abrir com Traço?" e o flow para em `abrir-trabalhos` (falhou 2× no UDID de teste; passa no do dono, que já aceitou). Um `runFlow: when: visible: "Abrir"` após o link resolve. E toca "5 de set. de 2026"/"11": quebra amanhã.
8. Teste `toqueNaNotificacaoUsaARotaDaProjecao` posta `abrirCompromisso` dentro do app hospedeiro; PaginaView reage e navega para o calendário durante a suíte. Passou, mas é efeito colateral em suíte compartilhada.
9. "Não existe rota de apagar Trabalho": correto hoje (nenhum `delete` de Trabalho), logo sem aviso órfão por essa via; registrar como gancho obrigatório quando a rota nascer.
10. ADR proposta: descreve o código com uma inflação (item 2) e um "provado" que é só teste unitário (toque na notificação; nunca exercitado no simulador porque a permissão está negada nos dois). Nomeia re-armar e fila de prioridade como fora; não nomeia "selar cala só na revalidação" nem "apagar Trabalho sem gancho". Linha de EVOLUCAO honesta nos números (26 nas suítes tocadas; integral 566/120), e nomeia a captura "marcado" pendente.

## Lista mínima para INTEGRAR
1. Ler o estado do aviso ao abrir a Oficina e preencher `avisos`; promessa coerente com semPermissao/semEspaco/passou (achado 1).
2. Cancelar `acao-*` no ato de proteger/apagar a nota de origem, ou passe no arranque (achado 2); ajustar a frase da ADR.
3. Flow: aceitar "Abrir com Traço?" após `openLink` (achado 7).
