# Esteira de qualidade do Traço

Vale para toda volta do laço. Nota por dimensão de 0 a 10, dada pelo revisor independente com evidência anexada. Nenhuma volta mescla em main com dimensão abaixo de 9. Dimensão que não se aplica à volta recebe "n/a" com o motivo, nunca nota de cortesia.

## Portões, na ordem

| portão | quando | quem | o que prova |
|---|---|---|---|
| G0 contrato | antes de editar | orquestrador | linha da volta (ciclo, intenção, obstáculo, evidência), escopo de arquivos, critérios verificáveis, prova esperada; volta visual passa por design-router: Ancorar e Sistema fechados aqui |
| G1 instrumento | ao terminar de editar | implementador, via com-trava.sh | build sem aviso, suíte integral verde no simulador de teste, testes novos para cada comportamento novo |
| G2 jornada | após G1 | implementador | capturas simctl de cada tela alterada nos estados: normal, vazio, carregando, falha, sem permissão, Dynamic Type grande; vídeo simctl quando há movimento |
| G3 revisão | após G2 | Fable revisor em sessão própria | scorecard abaixo preenchido com evidência; achado alto volta ao dono da área; revisão nunca corrige |
| G4 design | só volta visual, após G3 | segundo Fable, papel de julgar do design-router | fases Mover, Julgar e Portão; compara captura antes e depois; recusa acabamento que compensa fluxo confuso |
| G5 merge | tudo ≥ 9 | orquestrador | merge sem conflito, ADR, EVOLUCAO, LACO, RUMO atualizados, worktree removido |

Duas recusas seguidas na mesma volta abrem consulta ao conselho (Astra) antes da terceira tentativa. O conselho é para você decidir, não para o dono decidir: o parecer é insumo, a decisão é do orquestrador (DIRETRIZ §6).

## Skills obrigatórias por portão

Ordem do dono (06/09): usar cada vez mais `design-router`, `curva-zero` e `gate-loop`. Não é sugestão; é parte do portão. O worker carrega a skill ANTES de escrever qualquer código e cita no relato a fase em que estava.

| skill | quem carrega | quando | o que o relato tem de citar |
|---|---|---|---|
| `gate-loop` | orquestrador, em toda volta | no G0, para fixar resultado, escopo, critérios e provas; e a cada recusa, para decidir a próxima ação | contrato da volta e o critério que falhou |
| `design-router` | todo worker que toca view, Tema, componente, movimento ou copy | antes da primeira linha de SwiftUI; redesenho começa na fase de auditar antes de tocar | as seis fases: Ancorar, Sistema, Construir, Mover, Julgar, Portão |
| `curva-zero` | worker de jornada, formulário, onboarding, folha, primeiro uso, ou tela com nota de Simplicidade abaixo de 9 | ao desenhar o roteiro, antes do layout | jornada, resultado verificável, atrito observado, recuperação |

Volta visual sem as fases do `design-router` citadas no relato é recusada no G4, mesmo que o código esteja certo. Volta de jornada sem `curva-zero` é recusada na dimensão Simplicidade. O revisor confere a citação contra o que está na tela, não aceita a menção sozinha.

## Lei do instrumento — o maestro não isola (achado de 06/09, com prova)

`maestro --device` / `--udid` **NÃO isola**: o driver residente de outro simulador segura a porta 7001 e o maestro passa a ler a **hierarquia do vizinho**. Provado às 16h54 de 06/09 pelo revisor da F3b, que teve o maestro jurando que "Gravando." não estava na tela enquanto o `simctl` do próprio UDID mostrava "Gravando." no mesmo instante.

Consequência, e é dura: **com mais de um simulador ligado na máquina, nenhuma nota, achado ou veredito pode se apoiar em evidência do maestro** — nem `assertVisible`, nem `assertNotVisible`, nem `hierarchy`. Prova de tela é `xcrun simctl io booted screenshot` e o conteúdo do contêiner do próprio UDID. Quem precisar mesmo de maestro garante ser o único simulador ligado naquele instante, e escreve no relato que garantiu. Fluxo que falha de um jeito que não faz sentido é **instrumento**, e não desconta nota.

A mesma máquina, com seis ou sete simuladores, derruba simulador sozinha por pressão de memória — o iPhone 17 do dono caiu assim, sem ninguém o tocar. Ligue só o seu, desligue ao terminar.

**`booted` é ambíguo e outra sessão instala por cima de você** (achado de 08/09, 11h04, com prova). O worker da F4-F viu o contêiner do app trocar de bundle sozinho no simulador dele (`17814799` → `A6548AD8`) e o dylib instalado voltar a ser o código de `main` — sem que ele instalasse nada. Perdeu ~25 min perseguindo um "cache do `chronod`" que não existia: a casa mostrava o código velho porque **outra sessão reinstalou por cima**, usando `booted` com vários simuladores ligados.

Lei: **nunca `booted` e nunca `-destination generic` para instalar**. Sempre `xcodebuild -destination id=<UDID>` e `xcrun simctl install <UDID>`; captura sempre `xcrun simctl io <UDID> screenshot`. E a defesa que o próprio worker inventou, que vale para todos: **quando a tela mostrar comportamento antigo que você jura ter consertado, confira os símbolos do dylib instalado (`nm` no binário do contêiner) antes de caçar cache** — pode ser outra sessão em cima do seu aparelho, não um bug seu. Simulador que outra sessão declarou como dela é dela: leia o que as sessões vizinhas escreveram antes de escolher o seu.

**Ninguém toca no mouse do dono (lei de 08/09, ordem do dono).** Nenhum worker controla o mouse ou o teclado do Mac — nem `cliclick`, nem computer-use, nem `AXRaise`, nem AppleScript de clique. O dono trabalha na mesma máquina e em 08/09 viu vários agentes disputando o cursor ao mesmo tempo; além disso o clique por coordenada cai na janela do simulador vizinho. O instrumento é o controle de simulador do Orca, que toca o aparelho pelo UDID sem passar pelo cursor: `orca emulator attach <UDID> --json` uma vez; `orca emulator ax --device <UDID> --json` para achar o elemento (frames normalizados 0..1, origem no canto superior esquerdo; tocar no centro, x+w/2 e y+h/2); `orca emulator tap <x> <y> --device <UDID> --json`; `orca emulator type "texto" --device <UDID>` (só ASCII); `orca emulator button home --device <UDID>`; `orca emulator kill --device <UDID>` ao terminar. Evidência continua sendo `xcrun simctl io <UDID> screenshot`. Quem muda orientação, tamanho de letra ou aparência do simulador restaura ao fim da passada e confere por captura. Esta lei vai no spec de todo worker.

**O helper do `orca emulator` é UM SÓ na máquina** (três achados independentes em 08/09, e é o limite do instrumento novo). O revisor da P1 viu o `ax` perder a árvore de acessibilidade **assim que o Traço abre** (`ERR_CONNECTION_REFUSED` / `ERR_EMPTY_RESPONSE`), recuperando-a na tela inicial e perdendo-a de novo ao abrir o app. A volta L2 perdeu duas capturas porque o helper é global. E o revisor da L2, **depois de anexar explicitamente o seu UDID, viu o helper voltar a apontar para o aparelho de OUTRA volta** e as chamadas seguintes perderem o aparelho — o que o impediu de repetir uma medição de geometria de forma independente.

O juiz do G4 da F4-F acrescentou o quarto dado, e é o mais claro: **`orca emulator attach` é por worktree**, e cada reatamento dele pode ter tirado o aparelho do revisor que trabalhava em paralelo.

**E o pior deles, achado pelo juiz do G4 da V12 em 08/09:** `tap --device` **recusa** quando o helper está noutro aparelho, mas **`ax --device` lê a árvore do VIZINHO sem avisar**. Quer dizer: uma medida de geometria feita pela árvore de acessibilidade pode ser do aparelho errado e **parecer certa**. Regra: toda medida pela árvore de AX é conferida contra uma captura `simctl io` do mesmo UDID no mesmo instante (texto e estado batendo), ou não vale; duas medidas independentes que concordam valem mais que uma sozinha.

Consequências, enquanto o instrumento for assim: **toda sessão de `orca emulator` passa por `ferramentas/orca/com-trava.sh`**, como build e teste, porque o helper é recurso único da máquina; quem for medir geometria ou dirigir tela **declara no relato que segurou a trava**; e medição que o revisor não conseguiu repetir por causa do helper é **limite de instrumento, não confirmação** — não se vende como segunda prova. Prova de tela continua sendo `xcrun simctl io <UDID> screenshot`, que não depende do helper.

**Com quatro simuladores ligados, `xcodebuild test` pendura** em `test runner hung before establishing connection` (achado da F4-I, duas vezes seguidas em 08/09). **A clonagem do teste paralelo é o que pendura:** `-parallel-testing-enabled NO` resolve de primeira. Use-o sempre que houver mais de dois simuladores de pé.

**A galeria de widgets trava.** A folha "Adicionar Widget" para de paginar e depois trava de vez — três sessões seguidas de revisão da F4 esbarraram nisso, e já custou replantio de widget em três revisões. Some com o Simulator reiniciado, às vezes. Quando travar: é instrumento, não desconta nota, e a saída é usar as capturas de quem conseguiu plantar, conferindo o conteúdo e o relógio delas. A Live Activity do Destaque também engole o toque no botão "Editar" da galeria.

## Scorecard

| dimensão | mínimo 9 significa | evidência |
|---|---|---|
| Visão | a volta entra num dos dois ciclos e fecha uma lacuna nomeada do EVOLUCAO | linha G0 + diff do EVOLUCAO |
| Contrato | ADR curta, SPEC e EVOLUCAO coerentes com o código | diff dos três |
| Correção | comportamento novo coberto por teste; suíte verde; sem regressão nos fluxos maestro tocados | linhas de resultado coladas |
| Jornada real | todos os estados do G2 vistos na tela, conteúdo conferido, não só o arquivo | capturas nomeadas |
| Design | Ancorar, Sistema, Construir, Mover, Julgar, Portão cumpridos; tokens de Tema.swift, nada solto | relato do G4 |
| Simplicidade | curva-zero: caminho comum evidente, passos, decisões e telas não crescem; poder avançado continua encontrável | contagem antes/depois |
| Movimento | toda animação tem propósito, é interrompível, respeita movimento reduzido, duração e curva coerentes com o sistema | vídeo simctl + reduce motion |
| Componentes | reutilizável, um lugar só em Traco/Componentes, estados completos, preview, nome em pt, sem duplicata | diff + preview |
| Acessibilidade | VoiceOver com rótulos e ordem certa, Dynamic Type até XXL sem clipe, contraste, alvo ≥ 44 pt | captura AX + Dynamic Type |
| Performance | sem hitch em rolagem e digitação nas telas tocadas; Instruments quando toca lista, editor ou parser | trace ou medida |
| Privacidade e autoria | selo, origem e rotas protegidas intactos; nada publica, gasta ou envia sem gesto | teste + leitura do diff |
| Estado honesto | produzido, agendado, executado e observado distintos na tela; falha visível, nunca escondida | captura da falha |
| Complexidade | linhas líquidas, arquivos e dependências não crescem sem lacuna que justifique; simplificação conta como entrega | shortstat |
| Fora do app | superfície entregue com captura real em todos os estados (início, bloqueada, Ilha compacta/expandida/mínima, StandBy), um toque faz uma coisa, nada protegido exposto, orçamento de atualização respeitado | capturas por estado + vídeo |
| Relato | fecho em seis linhas com evidência, legível por quem não abre terminal | LACO |

## Conselho de arquitetura (Astra)

O Astra é o interlocutor de altíssimo nível do orquestrador, não implementador. Usar para: estrutura e arquitetura, contratos difíceis, direção do sistema de design e de componentes, empacotamento, trade-offs de concorrência e dados, e revisão de rumo. Até duas consultas por volta e uma revisão de rumo por dia sobre o LACO e o RUMO. Parar em 90% da cota semanal do Codex. Cada consulta fica gravada em ferramentas/orca/consulta-*.md com a pergunta e a recomendação.

## Rumo

O orquestrador mantém ferramentas/orca/RUMO.md: lista ordenada das próximas voltas com valor, esforço, ciclo e lacuna, atualizada a cada fecho. As três primeiras já trazem a linha G0 pronta. Volta que não está no RUMO não abre. O dono lê o RUMO para saber o que vem, e o LACO para saber o que veio.

## Frente de front-end

Antes de multiplicar voltas visuais, uma volta de auditoria (design-router, fase de auditar antes de tocar) percorre as telas principais e dá nota base no scorecard para cada uma. Em seguida uma volta de fundação: tokens em Tema.swift, pasta Traco/Componentes com previews, biblioteca de movimento com curvas e durações nomeadas. Só depois as voltas por tela, cada uma subindo a nota da tela até 9 ou mais. Tela abaixo de 9 no RUMO tem prioridade sobre função nova de mesma lacuna.
