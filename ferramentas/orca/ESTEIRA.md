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

Duas recusas seguidas na mesma volta abrem consulta ao conselho (Astra) antes da terceira tentativa.

## Skills obrigatórias por portão

Ordem do dono (06/09): usar cada vez mais `design-router`, `curva-zero` e `gate-loop`. Não é sugestão; é parte do portão. O worker carrega a skill ANTES de escrever qualquer código e cita no relato a fase em que estava.

| skill | quem carrega | quando | o que o relato tem de citar |
|---|---|---|---|
| `gate-loop` | orquestrador, em toda volta | no G0, para fixar resultado, escopo, critérios e provas; e a cada recusa, para decidir a próxima ação | contrato da volta e o critério que falhou |
| `design-router` | todo worker que toca view, Tema, componente, movimento ou copy | antes da primeira linha de SwiftUI; redesenho começa na fase de auditar antes de tocar | as seis fases: Ancorar, Sistema, Construir, Mover, Julgar, Portão |
| `curva-zero` | worker de jornada, formulário, onboarding, folha, primeiro uso, ou tela com nota de Simplicidade abaixo de 9 | ao desenhar o roteiro, antes do layout | jornada, resultado verificável, atrito observado, recuperação |

Volta visual sem as fases do `design-router` citadas no relato é recusada no G4, mesmo que o código esteja certo. Volta de jornada sem `curva-zero` é recusada na dimensão Simplicidade. O revisor confere a citação contra o que está na tela, não aceita a menção sozinha.

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
