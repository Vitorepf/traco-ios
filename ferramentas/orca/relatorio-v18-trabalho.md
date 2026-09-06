# Volta 18 — o Trabalho (relatório do implementador)

Branch `Vitorepf/volta-18-trabalho`, base `44b2dcd`, commit `3b512ec`.
Simulador: iPhone 17 Pro (teste 2) `B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9`,
ligado e desligado por esta volta. Todo `xcodebuild` e `maestro` por
`ferramentas/orca/com-trava.sh`; toda captura por `xcrun simctl io … screenshot`.

## As seis fases do design-router

**1. Ancorar.** Li AGENTS, VISAO-PRODUTO, SPEC (§ do Trabalho), SISTEMA-CLARO,
ESTEIRA e a §6 inteira da `auditoria-frontend.md`. Contrato: pessoa com uma
intenção, iPhone, uma mão; tarefa = intenção → versão preparada → próximo ato
com horário → relato; resultado observável = versão guardada, ato agendado,
relato registrado. Restrições: pt-BR, só iPhone, consumir `Traco/Componentes`
e `Tema` sem editá-los, não tocar em Modelo/Análise/Intercâmbio.

**2. Auditar antes de tocar (redesenho).** Percorri o fluxo no build de
`44b2dcd` e capturei o estado inicial (`v18-antes-*.png`). Confirmei na tela os
seis defeitos da §6 e achei um sétimo que a auditoria não nomeia: em AX5 a
folha do Trabalho já sangrava pelos DOIS lados
(`v18-antes-ax5-trabalho.png` — "Apresentar a" começa em x=0 e o "i" de
"ideia" está cortado), porque um filho de largura mínima grande empurra o
`VStack` para fora da tela. O que funciona e foi preservado: cada frase de
estado honesto ("Realização ainda não confirmada", "Não avaliado", "o modelo do
aparelho não devolveu revisão válida"), o spinner com "Cancelar preparação"
(o estado de carga mais honesto do app), a preservação de rascunhos e a cópia
de recuperação, e todas as rotas de acesso/selo.

**3. Sistema.** Nada de token novo. Consumi `CabecalhoDeFolha`, `Cartao`
(`.papel`/`.campo`), `Pilula` (`.larga`, `.filtro`), `LinhaQueAbre`, `Rotulo`,
`BotaoPrimario`/`BotaoCompacto`, `PressaoDiscreta`, e os tokens de espaço,
duração e mola de `Tema`. Escrevi a lei de cor da folha antes de construir:
**carvão avança, âmbar salva** — cápsula carvão para a ação que produz algo na
seção, âmbar só como saída de um problema, `Pilula.filtro` para todo o resto.

**4. Construir.** Ordem de leitura do ciclo; trilho de apoio; família visual;
desabilitado com motivo; `PromessaDoAviso`. Detalhe por defeito abaixo.

**5. Mover.** Três animações, todas pela lei de `Tema`: a versão que chega
(`.deslocamento`, `Mola.camada`, transição `move(.bottom)+opacity`), a troca do
trilho de apoio (`.escala`, `Mola.escala` → sob Reduzir Movimento o estado vira
sem quadro) e a gaveta de "Rever a intenção" / "Escrever minha própria versão"
(`Tema.gaveta`). Vídeo com e sem Reduzir Movimento: `v18-movimento-normal.mp4`
(97 quadros distintos em 14,7 s) e `v18-movimento-reduzido.mp4` (28 quadros em
12,2 s) — a diferença de quadros É a assinatura da lei funcionando.

**6. Julgar e Portão.** Julguei contra as capturas e corrigi três coisas na
própria volta: (a) rótulo de campo em caixa alta empilhado com o rótulo de
seção — duas caixas altas gritando sem hierarquia, virou caixa normal;
(b) a ação principal virava fantasma com o campo vazio, virou foco no campo +
motivo escrito; (c) o cabeçalho fixo por `VStack` irmão fazia a rolagem propor
a largura IDEAL do conteúdo e o AX5 voltava a sangrar — virou `safeAreaInset`.
O portão: build sem aviso, suíte integral verde, estados capturados, limites
declarados no fim deste arquivo.

## Curva-zero

- **Jornada.** Pessoa com uma intenção quer um artefato utilizável e um ato
  marcado. Estado → ação → retorno: lista → escreve a intenção → "Começar" →
  documento → escolhe o apoio (já marcado) → escreve o pedido → "Preparar com
  IA" → versão chega → escreve o ato → "Preparar este ato" → escolhe horário →
  "Marcar no calendário" → relato.
- **Resultado verificável.** Versão 1 guardada no documento com produtor
  declarado (`v18-versao.png`), ato com horário e o estado do aviso vindo do
  motor (`v18-agendado.png`).
- **Atrito observado (antes → depois).** Intenção → versão preparada: **6
  toques e 2 digitações → 5 toques e 2 digitações** (o toque que sobrava era
  abrir o disclosure para chegar ao apoio; hoje o apoio está no caminho e o
  padrão já vem marcado, custando 0 toques a quem não quer decidir). Telas de
  rolagem do documento com versão e ato: **5 → 3**. `DisclosureGroup`:
  **8 → 5**, e nenhum aninhado. A decisão de apoio: **escondida → visível**.
  O caminho principal cabe numa tela só (`v18-trabalho-novo.png`), onde antes
  a ação primária ficava a 80 % da primeira tela, atrás de "Dificuldade"
  (`v18-antes-trabalho-novo.png`).
- **Recuperação.** Desabilitado sempre diz por quê e por onde sair; campo vazio
  não desabilita a ação principal — leva o foco ao campo
  (`v18-foco-em-vez-de-fantasma.png`). Preparação interrompida/falhada/cancelada
  continua com "Retomar esse pedido". Rascunhos voltam ao reabrir. A cópia de
  recuperação continua copiável e apagável. O aviso desligado no iPhone leva
  aos Ajustes em vez de virar beco.

## Os seis defeitos da §6

| defeito | o que era | o que ficou | prova |
|---|---|---|---|
| D1 Design 5 | formulário do sistema, chips e chevrons, "Preparar com IA" cinza antes e cápsula marrom escura depois | `CabecalhoDeFolha`, rótulo de seção, campo em névoa, cartão de papel; a MESMA cápsula carvão antes e depois da primeira versão | `v18-trabalho-novo.png` × `v18-versao.png` |
| D2 Simplicidade 5 | 5 telas, 8 disclosures, botão desabilitado que não parecia | 3 telas, 5 disclosures; campo vazio foca o campo, bloqueio real desabilita COM motivo | `v18-preparando.png`, `v18-foco-em-vez-de-fantasma.png` |
| D3 curva-zero | 6 toques; apoio escondido; "Dificuldade" antes de "Preparar" | 5 toques; trilho de apoio no caminho; dificuldade no fim | `v18-trabalho-novo.png` |
| D4 Componentes 4 | `AcaoTrabalhoStyle` próprio, "Voltar" em cápsula de 30 pt só aqui, cabeçalho centrado só aqui | estilo apagado; `CabecalhoDeFolha`, `Pilula`, `Cartao`, `Rotulo`, `LinhaQueAbre` | diff |
| D5 Acessibilidade 7 | alvo por reserva, sem `contentShape` | alvo dos componentes (`View.alvo()`); AX5 sem clipe, trilho empilhado | `v18-ax5-trabalho.png`, `v18-ax5-preparar.png` × `v18-antes-ax5-trabalho.png` |
| D6 Estado honesto 8 | promessa de alarme com avisos desligados | `PromessaDoAviso` sobre `Avisos.Estado`: concedido / não perguntado / negado / leitura pendente | `v18-agendar.png`, `v18-agendado.png`, 5 testes |

## Instrumento

- Build sem aviso: `xcodebuild build` limpo, 0 linhas `warning:`.
- Suíte integral: `✔ Test run with 720 tests in 126 suites passed after 7.188 seconds.` → `** TEST SUCCEEDED **`
- `git diff --shortstat` do código: **4 arquivos, +592/−364** (com evidência e
  documentos, 36 arquivos, +736/−372). Código sem comentário: 1119 → 1247.
  **A volta NÃO é líquido-negativa**, e o motivo está na ADR: as correções
  acrescentam controle (trilho), estado (tri-estado da promessa) e texto de
  recuperação (motivo do desabilitado). Apagados: `AcaoTrabalhoStyle`, dois
  `NavigationStack` com toolbar, três `DisclosureGroup`, o `Picker` de apoio,
  um `@State`, cinco `HStack{…Spacer}` supérfluos.

## O que NÃO foi possível provar

1. **Promessa no estado *negado*.** O simulador de teste estava
   `naoPerguntado`; depois de conceder, o iOS não deixa revogar sem os Ajustes,
   e `simctl privacy` não cobre notificações. O caso vive no teste
   (`negadoNaoPromete`), não numa captura.
2. **Chegada da versão da IA em vídeo.** O modelo do aparelho leva ~90 s, acima
   do teto de 20 s. O vídeo usa a versão escrita pela pessoa, que dispara a
   MESMA animação (o driver é `documento.artefatos.count`).
3. **Falha da IA.** Não encenável sem cortar a rede do simulador; a preparação
   usou o modelo do aparelho e saiu. Estado não capturado.
4. **Comportamento observado, não corrigido:** o alerta de permissão do iOS,
   na única vez em que aparece, cicla o `scenePhase`, recolhe a gaveta do
   horário e rola a folha ao topo. Reproduzido três vezes; NÃO acontece em
   nenhum salvamento seguinte (`v18-reguardado.png`, com a gaveta aberta e a
   posição preservada).
5. **VoiceOver com pessoa.** Só inspeção: rótulos, `accessibilityLabel`,
   `isHeader` e alvos foram lidos no código e na árvore (`maestro hierarchy`),
   sem leitor de tela ligado em aparelho real.
6. **Maestro instável neste aparelho.** `tapOn: {id:}` falhou por
   "Element not found" em elementos que o `maestro hierarchy` lista como
   presentes, habilitados e dentro da tela (`trabalho-agendar`,
   `trabalho-conferencia`) — e passou na tentativa seguinte, sem mudança de
   código. Não é regressão de identificador; é o driver. Vale para quem for
   rodar `maestro/trabalho-acao-aviso.yaml`.

## Dívida nomeada para a volta dos Componentes (V12 é dona)

- `Pilula` desabilitada perde a cápsula (fundo `.clear`): a ação secundária
  desabilitada some da grade em vez de ficar apagada.
- `Pilula.larga` não tem recuo horizontal: em AX5 o texto encosta na borda da
  cápsula (`v18-ax5-preparar.png`).
- Falta uma `Secao` (rótulo + conteúdo) — hoje copiada da ficha do calendário
  para cá.
- Falta a "linha que abre um BLOCO" (a variante prometida em
  `LinhaQueAbre`): os cinco `DisclosureGroup` restantes ainda são do sistema,
  com `tint` do tema por fora.
- `Vazio` traz a margem de tela embutida e não serve dentro de um contêiner já
  recuado.
- `OficinaTrabalho.permissaoNegada` ficou sem leitor externo (a view lê a
  permissão sozinha). Decisão do implementador do Trabalho, não desta volta.
