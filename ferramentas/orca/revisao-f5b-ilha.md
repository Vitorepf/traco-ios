# re-G3 F5b — a prova reprodutível da Ilha

**Veredito: CORRIGIR ANTES.** A prova que recusara passou: o teste agora morde o `ActivityContent` publicado, a semeadura percorre a rota real e os pares `large`/AX5 têm captura e log versionados. A volta ainda não pode fechar porque a tela bloqueada corta conteúdo em AX5 e o relato não entrega as seis fases exigidas pelo portão para esta dimensão visual.

**Escopo revisado:** `abd09b0...0abdc4c`, ADR 2026-09-08v, no worktree `volta-f5b-ilha`. Revisei e rodei só no iPhone 17 Pro Max `6033B043-F436-41F9-B4F8-2D9E67761980`, sob `ferramentas/orca/com-trava.sh`; avisei no comentário compartilhado que a C1-B também usa o aparelho. Não toquei no Pro do Grok `C2416CBC`, nem usei Siri, voz, ditado, VoiceOver, iPad ou maestro.

## Achados que impedem o G5

### [P1] Dynamic Type AX5 ainda corta o cartão bloqueado

`ferramentas/orca/f5bb-ax5-bloqueada.png` mostra o prazo como **"39 minut…"**; em `f5bb-large-bloqueada.png` o mesmo campo é **"39 minutos"**. É o estado igual, com o compromisso no topo, amarrado ao mesmo par pelo `f5bb-log-ax5.log`; logo não é inferência de árvore de acessibilidade. Isso fica abaixo do mínimo de Acessibilidade (`ESTEIRA.md:101`).

**Para fechar:** eliminar o corte no cartão bloqueado em AX5 e refazer o par com o mesmo estado e log. A fala do VoiceOver permanece proibida e não entra como desconto; a árvore de AX devolve 503 nessas superfícies, portanto nenhuma ausência na árvore foi usada como prova de ausência na tela.

### [P1] O relato da re-G3 não contém as seis fases obrigatórias do `design-router`

`ferramentas/orca/f5b-b-prova.md:4` declara que não registrará as fases. A regra pede no relato **Ancorar, Sistema, Construir, Mover, Julgar e Portão** (`ESTEIRA.md:20-28`; scorecard `:97`), e o pedido desta re-G3 explicitou essa exigência para Fora do app. Não basta mencionar que não houve redesenho.

**Para fechar:** registrar as seis fases como foram aplicadas à prova e confrontá-las com as capturas atuais, inclusive o corte AX5. Isso é documentação verificável, não justificativa para inventar uma mudança visual.

## As três provas reexecutadas

1. **O teste morde o wiring.** `ProximoCompromisso.conteudo(de:recado:)` é a origem única do conteúdo usado por `request`, `update` e recado (`Traco/Modelo/ProximoCompromisso.swift:212-240,262-266`). `ForaDoAppTests.aIlhaEDoCompromisso` lê o conteúdo construído, incluindo o update (`TracoTests/ForaDoAppTests.swift:312-334`). Eu removi temporariamente somente `relevanceScore: relevanciaNaIlha` da publicação: no resultado `Test-Traco-2026.09.09_04-47-30--0300.xcresult`, 24 passaram e 1 falhou com `Expectation failed: (compromisso.relevanceScore -> 0.0) > (destaque.relevanceScore -> 0.0)`. Restaurei a linha e a repetição verde deu `Test run with 25 tests in 1 suite passed after 0.219 seconds.` e `** TEST SUCCEEDED **`.
2. **A semeadura publica pela rota real.** Em DEBUG, o arranque chama a mesma `ProximoCompromisso.publicar(eventos, cal:)` da agenda, editor e intent (`Traco/TracoApp.swift:37-49`; chamadores em `CalendarioAgenda.swift:350`, `Intencoes.swift:235`, `Sessao.swift:815`). Rodei `f5b-semear.sh` de estado limpo do cenário, com o binário candidato já instalado: `semeado: Dentista revisor em +40 min por 60 min, destaque (04:49:06); 2 atividade(s) a subir no liveactivitiesd`; a projeção passou a conter `"titulo":"Dentista revisor"`, o log fresco traz dois `Starting activity` às 04:49:05-06, e a captura `/tmp/f5b-revisor-ilha.png` mostra calendário e `39:51`. Logo, qualquer pessoa reproduz com os quatro comandos versionados em `f5b-b-prova.md:31-40`, desde que instale o candidato DEBUG indicado ali.
3. **Pares e log versionado.** Confirmei que os nove artefatos `f5bb-*` estão versionados. `f5bb-large-ilha-compacta.png`/`f5bb-ax5-ilha-compacta.png` mostram a Ilha do compromisso (`39:50`/`37:59`); `f5bb-large-bloqueada.png`/`f5bb-ax5-bloqueada.png` mostram o cartão do compromisso por cima. `f5bb-log-large.log` registra as duas atividades da semeadura; `f5bb-log-ax5.log` fixa a janela das seis capturas e declara que nenhuma atividade subiu ou caiu entre elas. A prova de prioridade é visual: o daemon não contém `relevanceScore`.

## Julgamento da dispensa de `curva-zero`

**Válida, portanto Simplicidade = n/a.** Esta re-G3 não criou jornada, formulário, primeiro uso, folha nem novo toque: só testou e semeou a superfície que já tinha o gesto de um toque. `ESTEIRA.md:26` limita `curva-zero` a essas jornadas ou a Simplicidade abaixo de 9; o script é instrumento de QA e não caminho de produto. Isso não dispensa o `design-router` exigido acima nem encobre o corte de AX5.

## Scorecard do revisor

| dimensão | nota | evidência e julgamento |
|---|---:|---|
| Visão | 9 | O compromisso próximo se anuncia sem abrir o app; `EVOLUCAO.md` e ADR 08v coerentes. |
| Contrato | 9 | `ActivityContent.difere` atualiza também mudança de relevância; construtores centralizam request/update/recado. |
| Correção | 9 | Mutação própria vermelha (24/25) e restauração verde (25/25) no `6033B043`. |
| Jornada real | 9 | Semeadura fresca publicou `Dentista revisor`, projeção, log e captura conferidos. |
| Design | 8 | Falta o registro verificável das seis fases, requisito explícito do portão. |
| Simplicidade | n/a | Dispensa de `curva-zero` válida: nenhum caminho de produto mudou. |
| Movimento | n/a | Esta re-G3 não mudou movimento. |
| Componentes | n/a | Nenhum componente novo nesta re-G3. |
| Acessibilidade | 8 | AX5 corta `39 minutos` para `39 minut…`; VoiceOver não foi exercitado por proibição, sem desconto adicional. |
| Performance | n/a | Não tocou lista, editor ou parser. |
| Privacidade e autoria | 9 | A prova usa calendário local em DEBUG; nenhuma nota/expressiva entra na superfície. |
| Estado honesto | 9 | Log, captura e o limite da árvore AX estão declarados sem inferência indevida. |
| Complexidade | 9 | Um construtor por atividade reduz os sites de publicação e o gancho é DEBUG de instrumento. |
| Fora do app | 9 | A dimensão tocada está provada: prioridade reproduzida na captura fresca e nos pares versionados, com logs da mesma janela. |
| Relato | 8 | Provas técnicas são legíveis, mas a ausência deliberada das seis fases impede o fecho exigido. |

## Limites de instrumento

O `liveactivitiesd` prova subida, estabilidade da janela e `staleDate`; ele não registra `relevanceScore`, por isso a prioridade foi conferida na captura. A árvore AX 503 da casa/bloqueada não prova nem desmente elementos visuais; as conclusões de presença e do corte vêm exclusivamente das capturas no mesmo UDID. O bootstrap Atlas pedido pelo `AGENTS.md` não pôde ser executado neste checkout: não há `artisan` nem `docs/engineering-knowledge-base/atlas-ai-knowledge-governance-system.md`.
