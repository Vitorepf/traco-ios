# Revisão G3 — volta F1 (auditoria fora do app)

Revisor: Fable 5.1 em sessão própria, 05/09/2026. Branch `Vitorepf/fora-1-auditoria` (fb407e4) sobre main d4d98da; merge-tree contra main 5ccf5e7 limpo (árvore d1e2598, sem conflito). Simulador do revisor: iPhone Air 64F7B8B4 (ligado, usado, desligado; `appearance`/`content_size` não alterados). Nenhum arquivo do branch editado. Capturas do revisor: `ferramentas/orca/f1-rev-*.png` (não commitadas).

Veredito: **CORRIGIR ANTES** (lista mínima ao fim, só texto do relatório; nada de código).

## Scorecard da volta

| dimensão | nota | evidência |
|---|---|---|
| Visão | 9 | Linha da volta presente (ciclo MULTIPLICAR, intenção, obstáculo, evidência). F1 está no RUMO (linha 19) e a lacuna "widget/Ilha da ação" está nomeada no EVOLUCAO (linha 12). Não fecha lacuna de produto porque é auditoria: o que fecha é a ausência de inventário e nota, exatamente o que o RUMO pediu. |
| Contrato | 9 | Inventário bate 100% com o código: 12 `AppIntent`/`LiveActivityIntent` (10 em `Intencoes.swift` + 2 em `TracoWidget/`), 10 `AppShortcut(`, 1 `AppShortcutsProvider`, 2 `StaticConfiguration` com 4 famílias cada e 2 `ActivityConfiguration`, 5 rotas em `Rota` (nova/""/notas/calendario/recordar/anotar), zero `CSSearchableItemActionType`/`onContinueUserActivity`, zero `categoryIdentifier`, zero `Relevance`, 39 `.system(size:)` fixos em `TracoWidget.swift`. A correção ao brief (12 intents e 10 atalhos, não o contrário) está certa. Único erro de contrato: a causa "provável" de D1 (dylib de depuração) não se confirma — ver abaixo; o relatório a marcou como não confirmada, o que salva a nota. |
| Jornada real | 8 | Abri as 24 capturas. 21 mostram exatamente o que a tabela diz. Três são evidência fraca: (1) `fora1-inicio-widgets-escuro.png` é indistinguível da clara (mesmo fundo, mesmos rótulos brancos): a captura não prova que o modo escuro estava ligado; a prova do "papel fixo" vem do código (`containerBackground(Tema.fundo)`), não da tela. (2) `fora1-standby-nao-disponivel-simulador.png` é só a tela bloqueada em retrato, e mostra um fato que o relatório não registra: o cartão do CompromissoVivo exibe "18:20" (timer) às 19:14, enquanto às 19:12 e 19:16 o mesmo cartão exibia "20 minutos" e "16 minutos" (relativo) — o flip timer/relativo do D7 acontece também no cartão da tela bloqueada, não só na Ilha (`contando()` é decidido na renderização; `TracoWidget.swift:351-354, 385-389`). (3) `fora1-inicio-proximo-apagado-widget-desatualizado.png` mostra "Dentista 19:33" às 19:23 com a Ilha vazia, coerente com D6, mas a imagem não prova que o App Group estava vazio; aceito pelo código da política `.after`. Os não capturados (accessory na bloqueada, StandBy, Ilha mínima, Siri por voz, banner) estão declarados literalmente, com a captura do impedimento quando havia. |
| Fora do app | 9 | Toda superfície existente foi vista na tela real, não em preview: início (4 widgets), bloqueada (2 atividades), Ilha compacta e expandida (2 atividades), galeria, rotas, Spotlight, Atalhos. Um toque faz uma coisa: o feito do Destaque marcou sem abrir o app (`fora1-inicio-destaque-feito-*.png`). Selo conferido por leitura da query (abaixo). Falta só o que o simulador não dá (mínima, accessory, StandBy), com motivo. |
| Privacidade e autoria | 9 | Li as queries: `DestaqueDoDia.gravar` só com `!nota.fechada` (`Sessao.swift:1102-1114`); trancar passa por `salvar(trancar: true)` → `aplicarDestaque` → `apagar` (`Sessao.swift:1620, 987, 1114`); apagar nota chama `DestaqueDoDia.apagar` (`:1652`); `Holofote.sai` exclui fechada e expressiva em curso (`Holofote.swift:12-14`); `Calendario.deixa` exclui fechada e expressiva (`Calendario.swift:247`); `proximaFatia` exclui deixas e ações de Trabalho (`Calendario.swift:962`); banners sem corpo. Nada foi publicado, gasto ou enviado; os dados plantados são inofensivos. Fica 9 e não 10 porque D6 mostra que a linha do tempo arquivada do widget pode servir conteúdo já removido até a recarga — uma nota trancada segue o mesmo caminho se o `reloadTimelines` falhar (o conselho diz o mesmo: cache do iOS não tem revogação garantida). |
| Estado honesto | 9 | O relatório distingue visto / não capturável / só código (legenda n/c), transcreve o alerta de D1 literalmente e marca a causa como não confirmada. A tabela de notas não dá nota de cortesia. Desconto único: a nota "2 (no simulador)" em Atalhos e Intents é nota de instrumento vestida de nota de produto (ver ajuste). |
| Relato | 8 | Relatório de 235 linhas, legível e com evidência por linha. Falta o fecho em seis linhas para quem não abre terminal (ESTEIRA "Relato"), e a prova do defeito mais alto (alerta de D1) ficou "em /tmp, não versionada". A minha `f1-rev-atalhos-release-alerta.png` supre a captura. |
| Correção, Design, Simplicidade, Movimento, Componentes, Acessibilidade, Performance, Complexidade | n/a | Volta sem código: nada a testar, construir ou medir. As notas dessas dimensões aparecem por superfície na seção seguinte, como nota base, não como nota da volta. |

## D1 reproduzido: é do instrumento, não do produto (mas ainda não provado no aparelho)

Reproduzi no iPhone Air com build Debug e com build Release (`-configuration Release`, sem `Traço.debug.dylib` no pacote).

- Debug: o toque em "Destaque de hoje" no app Atalhos (maestro, `tapOn` no texto) não deixou alerta na captura única; em Release, tocando no ícone com rajada de capturas, o alerta apareceu igual ao do relatório: **"Não foi possível executar o atalho do app"** (`f1-rev-atalhos-release-alerta.png`, 19:37).
- Log do `linkd` no mesmo instante (Release): `Failed to generate bundleIdentity: Unable to get teamId from app.traco PID [25978]` → `Rejecting invalid client due to requiresValidBundle ... com.apple.linkd.autoShortcut`. Idêntico ao que o worker viu em Debug.
- Causa: o pacote do simulador sai com `Signature=adhoc`, `TeamIdentifier=not set`; a seção de entitlements embutida tem `application-identifier W28WF9A5A2.app.traco` e o App Group, mas **não** `com.apple.developer.team-identifier`. O `linkd` exige teamId para executar App Shortcuts. O dylib de depuração não tem nada a ver: Release falha igual.
- Consequência: no aparelho do dono, assinado com o time, é muito provável que os 10 atalhos executem. Não está provado. Para o simulador servir de instrumento da trilha, F2 precisa de uma das duas: prova no aparelho (captura do Atalhos executando "Destaque de hoje" e "Anotar") ou build de simulador que embuta `com.apple.developer.team-identifier` (candidato: a chave no `Traco.entitlements` só para o SDK do simulador; testar).
- `shortcuts://run-shortcut?name=…` não serve para App Shortcuts ("O arquivo não existe", `f1-rev-atalhos-url-nao-existe.png`): não é caminho de prova.

D2, D3, D4 confirmados na tela: Spotlight cai no Calendário (`fora1-spotlight-toque-cai-no-calendario.png` + zero handler no código); nenhum texto do widget cresce em AXL enquanto os rótulos do iOS crescem (`fora1-inicio-widgets-dynamic-type-axl.png`); a ficha diz "Toca hoje às 19:33" e o widget "🔔 19:33" enquanto a Live Activity diz "avisos desligados no iPhone" (`fora1-app-ficha-compromisso.png` × `fora1-bloqueada-compromisso-vivo-avisos-desligados.png`). Médios: D6, D7, D8, D9 vistos nas capturas citadas; D5 tem `Avisos.pedirSePreciso` no caminho de agendar (`Revisoes.swift:257`), então o pedido existe no código e a ausência do alerta é estado do simulador até prova no aparelho; D11 confirmado por código. D18 confirmado: build Debug e Release com exatamente 1 aviso (`EditorBlocoView.swift:270`).

## Notas base por superfície, ajustadas

| superfície | Fora do app | Design | Simplic. | Movim. | Acessib. | Privac. | Estado honesto | ajuste e motivo |
|---|---|---|---|---|---|---|---|---|
| Widget Traço (casa) | 6 | 5 | 7 | n/a | 3 | 9 | 6 | mantidas; defensáveis pelas capturas e por ADR 04a/04f |
| Widget Próximo (casa) | 5 | 5 | 8 | n/a | 3 | 9 | 5 | mantidas |
| Widgets accessory (bloqueada) | n/c | n/c | n/c | n/a | n/c | 9 (código) | n/c | mantidas; pendente de aparelho |
| DestaqueVivo (bloqueada) | 7 | 7 | 8 | 6 | 5 | 9 | 6 | mantidas |
| DestaqueVivo (Ilha) | 6 | 5 | 8 | 6 | 5 | 9 | 7 | mantidas |
| CompromissoVivo (bloqueada) | 7 | 7 | 8 | 6 | 5 | 9 | **4** (era 5) | o próprio cartão alterna "20 minutos" / "18:20" / "16 minutos" em três capturas; D7 vale para o cartão, não só para a Ilha |
| CompromissoVivo (Ilha) | 6 | 6 | 8 | 5 | 5 | 9 | 4 | mantidas |
| App Shortcuts / Siri | **n/c (simulador)** (era 2) | 7 | 8 | n/a | 6 | 8 | **n/c** (era 3) | a falha é de assinatura do build de simulador, não do produto; nota de produto só com prova no aparelho |
| Intents que escrevem | **n/c (simulador)** (era 2) | n/a | 8 | n/a | n/a | 9 | n/c | idem |
| Rotas traco:// | 8 | n/a | 9 | n/a | n/a | 9 | 8 | mantidas |
| Spotlight | 3 | n/a | **n/a** (era 2) | n/a | n/a | 9 | 3 | o defeito é destino (D2), não passos; Simplicidade não mede isso |
| Notificações (toque) | 5 (código) | n/a | 6 | n/a | n/a | 9 | **n/c** (era 5) | banner não visto; nota de estado honesto sem tela é nota de código |

## Lacunas F2-F11 e o parecer do conselho

A lista F2-F11 cobre o brief inteiro (captar em um toque, widget interativo, Ilha completa, accessoryCircular, controle Recordar, configurável, Spotlight, compartilhar, sugestões de Siri). Falta um item que o brief exige e a tabela não nomeia: **"Live Activity termina sozinha e nunca fica órfã"** — o relatório prova que encerra no apagar e no feito, mas D15 e o conselho mostram que `staleDate` não encerra; entra em F5 (ou F2, ver abaixo).

O parecer do conselho (main 5ccf5e7) muda o conteúdo de F2, não a ordem:
- descarta framework/package (a tabela do relatório ainda oferece "framework ou target compartilhado"): fica `Traco/App/Intents/` compilado nos dois alvos só onde preciso;
- entidades mínimas (NotaEntity, CompromissoEntity, TrabalhoEntity com `AcessoTrabalho`), não o catálogo inteiro;
- snapshot Codable versionado no App Group substitui as chaves soltas, com "Atualizado há…/Desatualizado" — isso resolve D6 e o reload por minuto do `ProvedorProximo`;
- os dois `LiveActivityIntent` mudam de contrato: identidade do item (UUID+dia / UUID+ocorrência), feito=true em vez de toggle, soneca só confirma após sucesso, stale neutraliza ação (D15);
- F2 se divide se o escopo crescer; controles, ditado, configurável e Spotlight de Trabalho ficam depois.

Linha G0 recomendada para F2 (≤ 8 linhas):
1. Ciclo MULTIPLICAR · intenção: o mesmo comando produz o mesmo estado confirmado em qualquer entrada (widget, Ilha, Siri, URL) sem expor nota protegida · obstáculo: 12 intents soltos, chaves soltas no App Group, dois intents que confirmam sem persistir · evidência: testes sem UI + capturas por estado.
2. Escopo: `project.yml`, `Traco/App/Intents/` (novo, tipos e nomes preservados), `Intencoes.swift`/`Rota`, `TracoWidget/`, `DestaqueDoDia`/`ProximoCompromisso` → snapshot versionado, pontos de commit em `Sessao`/`Calendario`, `Tema.swift` para tipografia do widget (D3: degraus de `Tema` no lugar de 39 tamanhos fixos).
3. Critérios: build dos dois alvos com zero avisos (inclui D18); persistência recusada não confirma; repetição não duplica nem inverte; item velho não altera novo; snapshot truncado/expirado mostra "Desatualizado"; stale sem botão ativo; widget readicionado nunca mostra compromisso apagado (D6).
4. Prova de instrumento: App Shortcuts executando "Destaque de hoje" e "Anotar" pelo app Atalhos no aparelho do dono OU no simulador com `team-identifier` embutido — captura obrigatória; sem isso, nenhuma nota de produto para Siri/Atalhos.
5. Fora do escopo de F2: D2 (Spotlight → F9), D7/D8/D9 (Ilha → F5), D11 papel escuro (decisão de design em G0 de F4/F5), controles e ditado (F3).
6. Divisão: se (catálogo + snapshot + dois intents + entidades mínimas) não fecha numa volta, entidades mínimas viram F2b; não declarar fundação sem prova.

## CORRIGIR ANTES (mínimo, só o relatório)

1. D1: trocar a causa. Não é o dylib de depuração; Release falha igual. Causa: assinatura adhoc do simulador sem `com.apple.developer.team-identifier`; `linkd` recusa (`Unable to get teamId`). Classificar como defeito do instrumento com prova de produto pendente no aparelho, e anexar `f1-rev-atalhos-release-alerta.png` como evidência versionada.
2. Notas base de App Shortcuts e Intents: de "2 (no simulador)" para n/c com motivo, como acima.
3. Registrar que o flip timer/relativo (D7) ocorre no cartão da tela bloqueada (três capturas: 19:12 "20 minutos", 19:14 "18:20", 19:16 "16 minutos") e ajustar Estado honesto do CompromissoVivo (bloqueada) para 4.
4. Captura escura: ou refazer com prova visível do modo escuro (galeria de widgets aberta em escuro, ou Ajustes ao lado) ou reescrever a linha como "provado por código, captura não distingue".
5. Fecho em seis linhas no topo do relatório (o que veio, o que vale, o que falta, D1 com a causa certa, capturas, próxima volta) e a linha do LACO.
6. Na tabela F2, trocar "framework ou target compartilhado" pelo que o conselho decidiu (sem framework; `Traco/App/Intents/` nos dois alvos) e acrescentar "Live Activity órfã / stale neutraliza" como lacuna nomeada.

Depois disso: INTEGRAR. Nenhum achado é de código nem de privacidade.
