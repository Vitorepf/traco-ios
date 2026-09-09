# G3 independente — F5b, a Ilha do compromisso vivo

**Veredito: CORRIGIR ANTES.** Revisei `05acc35` no worktree `volta-f5b-ilha`, sem alterar código de produto. O mecanismo escolhido é o correto: a Apple define `ActivityContent.relevanceScore` como o critério que escolhe a Live Activity do mesmo app na Ilha e ordena a tela bloqueada ([documentação](https://developer.apple.com/documentation/activitykit/activitycontent/relevancescore)). Mas a prova e o teste não sustentam ainda que o candidato o aplique no caminho alegado.

## Instrumento e alcance

- Li o relato F5b inteiro, ADR 2026-09-08v, `VISAO-PRODUTO.md`, `SPEC.md`, `EVOLUCAO.md`, `ESTEIRA.md`, `AGENTS.md` e o brief de revisor. A tentativa de bootstrap Atlas foi emulada: este repositório iOS não contém `artisan` nem o documento de governança apontado pelo `AGENTS.md`.
- Usei somente o iPhone 17 Pro Max `6033B043-F436-41F9-B4F8-2D9E67761980`, que liguei e desligarei ao final. Segurei `ferramentas/orca/com-trava.sh` para build/teste e `f5b-emu.sh` para AX; não usei maestro, Siri, voz, ditado, VoiceOver ou iPad.
- `xcodebuild test -project Traco.xcodeproj -scheme Traco -destination id=6033B043… -derivedDataPath /tmp/traco-f5b-g3-dd -parallel-testing-enabled NO`: resultado XCResult **Passed**, 949 testes no total, 948 passados, 1 ignorado, 0 falhas. Isto prova a suíte, não a ordem visual da Ilha.

## Achados que impedem o portão

### P1 — o teste não falha se a integração de `relevanceScore` for removida

`ForaDoAppTests.aIlhaEDoCompromisso` só avalia `ProximoCompromisso.relevanciaNaIlha > DestaqueDoDia.relevanciaNaIlha`. Ele fica verde se forem apagados os três argumentos `relevanceScore:` de `DestaqueDoDia.swift:156` e `ProximoCompromisso.swift:215,258`, desde que as duas constantes permaneçam. Portanto é teste de prioridade declarada, não do contrato ActivityKit request/update que a entrega afirma proteger. A correção deve provar que request **e** update carregam a prioridade; não aceite apenas a comparação das constantes.

Há um segundo risco no mesmo caminho: uma atividade já viva só recebe `conteudo` se `ContentState` mudar (`DestaqueDoDia.swift:166`, `ProximoCompromisso.swift:227`). Uma atualização de versão que só introduz/muda a relevância deixa a atividade antiga com o score anterior. A documentação da Apple pede acompanhar e poder mudar a relevância a cada update; essa transição não está coberta.

### P1 — minha reprodução do instrumento não criou as duas atividades alegadas

Depois da suíte, executei `f5b-semear.sh 6033B043… 40 60 destaque 'Revisão G3'`, fui à casa pelo wrapper travado e capturei `/tmp/f5b-g3-duas-vivas.png`. A Ilha mostrou o **Destaque**, não o compromisso. O log do próprio simulador registrou só uma `Starting activity` (`C5E2545A…`) e agendou stale à meia-noite, isto é, o Destaque; o `superficie.json` continuou contendo o `Dentista` anterior.

A causa do instrumento é rastreável: o script grava `Documents/Traço/calendario.json`, mas `TracoApp.aoAbrir` apenas chama `DestaqueDoDia.reconciliar()` e `ProximoCompromisso.reconciliar()`, que relê a projeção já publicada. Ele não chama `ProximoCompromisso.publicar` para o arquivo semeado. A própria condição final do script verifica apenas se `superficie.json` é mais novo que o plist, permitindo falso positivo com uma projeção antiga. Isto não demonstra por si só defeito no fluxo normal de salvar pelo calendário, mas invalida a repetição independente da principal prova F5b; a jornada precisa ser refeita pelo caminho que publica a projeção, com ids/staleDate preservados no artefato.

### P1 — a evidência AX5 não sustenta retirar a dívida do RUMO

`f5b-ax5-ilha-compacta-destaque.png`, inspecionada no arquivo, não mostra o texto compacto nem uma Ilha completa para comparar: a parte superior está fora da imagem. Logo não demonstra que a compacta AX5 é “pixel a pixel” igual à large nem que o `t` desapareceu. A captura `f5b-ax5-ilha-compacta-compromisso.png` mostra um timer, mas não traz a contraparte com o mesmo conteúdo/configuração. Não é lícito apagar o RUMO com esse par; refaça large e AX5 com o mesmo estado, Ilha inteira visível e configuração registrada.

### P2 — uma das duas recusas visuais não é provada pela própria imagem

`f5b-instrumento-fixedsize-expandida-vazia.png` confirma a primeira recusa: só o ícone leading permanece. Porém `f5b-instrumento-alinhada-corta.png` que acompanha o relato mostra `29:48` legível por inteiro, não `29:4|8`; ela não sustenta o corte alegado. O código final sem alinhamento à direita pode continuar sendo a escolha mínima, mas a recusa precisa de uma recaptura fiel ou de texto reduzido a hipótese.

## O que foi confirmado e o que permanece limitado

- **Instrumento certo, ligação incompleta:** `relevanceScore` é o instrumento de plataforma correto para Ilha e pilha; os três sites de `ActivityContent` da árvore atual o recebem. As capturas históricas `f5b-antes-ilha-compacta-destaque-esconde.png` e `f5b-depois-ilha-compacta-compromisso-vence.png` mostram o antes e o depois declarados, mas não substituem a repetição acima nem o teste de wiring.
- **Mínima:** `f5b-ilha-minima-compromisso.png` mostra os dois círculos de apps distintos; `ferramentas/orca/f5b-outra/` é um projeto separado sob ferramentas, não é referenciado por `project.yml` do Traço. É instrumento descartável, não produto. Confirmado.
- **Acabamento:** a expandida final em `f5b-depois-ilha-expandida.png` mostra `29:07` inteiro; `f5b-fim-2-expandida-acabou-depois.png` mostra “acabou” sem a curva comer o primeiro glifo. Confirmados, com a ressalva da recusa de alinhamento acima.
- **Fim e honestidade:** `f5b-fim-3-bloqueada-acabou-14min.png` tem relógio 21:43 e cartão 21:29, sustentando a permanência aos 14 min. `staleDate` só torna o conteúdo stale; não agenda `end`. Assim, dizer “acabou” enquanto o cartão espera reconciliação é honesto, mas a permanência é uma dívida de produto explícita para medir/decidir no aparelho real, não um fim garantido. A captura de Ilha vazia em menos de 12 min é observação de um simulador, não SLA.
- **AX e log:** na minha sessão, `orca emulator ax` não devolveu 503: devolveu a árvore da casa, sem a Ilha, enquanto a captura do mesmo estado a mostrava. Isso confirma a lei de que ausência na árvore não prova ausência na tela. Não há transcript de `liveactivitiesd` versionado junto às capturas históricas; portanto não pude auditar a alegada correlação histórica entre ids, `staleDate` e cada screenshot. Meu log de reprodução só confirma a única atividade acima.
- **Design-router / curva-zero:** as seis fases estão citadas e correspondem ao escopo local observado (prioridade, dois ajustes de layout e estados). A dispensa de `curva-zero` é válida: não houve jornada, formulário ou novo toque; a superfície continuou de um toque. O problema é de evidência do estado, não de complexidade introduzida.
- **Simulador:** o relato F5b registra ter encontrado `6033B043` já ligado às 20:38 e o ter desligado; tratei isso como incidente de posse declarado, não falha de autoria da volta.

## Scorecard G3

| dimensão | nota | evidência e julgamento |
|---|---:|---|
| Visão | 9 | Priorizar o compromisso vivo serve à ação imediata sem fazer o Destaque desaparecer do produto. |
| Contrato | 8 | ADR é clara, mas o contrato de atualização de atividade já viva não está fechado. |
| Correção | 8 | Suíte verde; teste novo não protege o wiring ActivityKit e há risco em atividade existente. |
| Jornada real | 8 | A semeadura atual não publicou o compromisso na repetição independente. |
| Design | 9 | Correções locais visíveis; sem redesenho especulativo. |
| Simplicidade | n/a | Nenhuma jornada ou decisão adicional de pessoa. |
| Movimento | 9 | Sistema é dono da animação; não encontrei curva/duração nova no diff. |
| Componentes | n/a | Nenhum componente novo. |
| Acessibilidade | 8 | AX5 do cartão existe, mas a prova da Ilha compacta está fora de quadro; VoiceOver foi corretamente proibido/declarado. |
| Performance | n/a | Sem caminho de lista, parser ou IO novo mensurável. |
| Privacidade e autoria | 9 | A mínima auxiliar é isolada em ferramentas; não há nova exposição de conteúdo. |
| Estado honesto | 9 | “acabou” é verdadeiro; a permanência sem end é declarada como dívida, não disfarçada. |
| Complexidade | 9 | Diff produtivo curto; app auxiliar não entra no target. |
| Fora do app | 8 | Mecanismo correto, porém a evidência/reprodução da prioridade e AX5 não fecha. |
| Relato | 7 | Forte cobertura de estados, mas a captura de alinhamento contradiz o texto e AX5 não prova o que diz. |

Nenhuma mescla: há dimensões abaixo de 9. Para reabrir G3, entregue uma reprodução que publique o compromisso de verdade, log versionado com ids/staleDate correspondente às capturas, teste que falhe ao retirar o wiring e pares large/AX5 enquadrados; então refaça esta revisão sem corrigir por inferência.
