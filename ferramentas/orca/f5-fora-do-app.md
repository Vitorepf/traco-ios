# F5 — fora do app: o Destaque que não corta, e o dia que cabe no médio

Implementador: Claude Opus 5, 08/09/2026, 10h20–11h40. Worktree
`volta-f5-fora-do-app` sobre `8e3a1a5`. Simulador de teste: **iPhone 17 Pro
(teste 3)** `34CC3F94-FDB5-4575-A4F5-80271829A18B` — ligado por mim.
O **`B91C8DEF` (teste 2) não foi tocado**: não instalei, não desliguei, não
capturei nada dele. Todo `xcodebuild` por `ferramentas/orca/com-trava.sh`.
**Nenhum maestro** — nenhuma linha deste relato se apoia em hierarquia; prova
de tela é `xcrun simctl io <MEU UDID> screenshot`, sempre com o UDID explícito.
Usei `cliclick` em três toques antes de conhecer a proibição de 08/09; está
declarado na seção de instrumento.

## G0 — a linha da volta

**Ciclo:** multiplicar. **Intenção:** o autor olha a tela de início e sabe o
que o dia pede, inteiro, sem frase cortada e sem promessa falsa.
**Obstáculo:** a dívida da F4 (item 2 da limpeza de 07/09 no RUMO), mesclada em
main sem o último portão. **Evidência:** capturas `simctl` por estado, suíte
verde, build sem aviso.

## Auditoria antes de tocar em Swift (a lei de que auditoria é datada)

Reproduzi os quatro pontos na tela viva, com o código de `main`, ANTES de
editar. Metade do que o RUMO descrevia **já não era verdade**, e isso mudou o
conserto:

| ponto do RUMO | o que a tela de 08/09 disse |
|---|---|
| 1. Destaque longo corta com o rodapé "Desatualizado." | **Verdade, mas só em AX5.** Em tamanho normal a frase sai inteira nos dois tamanhos (`f5-antes-normal-desatualizado.png`). Em AX5 corta nos dois (`f5-antes-ax5-desatualizado.png`) |
| 2. o quadro de ofertas lê como lista de Ajustes | **Verdade** (`f5-antes-vazio-claro.png`) |
| 3. bloqueada, StandBy e Ilha sem captura | **Verdade** |
| 4. o médio mostra UMA linha de agenda | **Pior:** mostra ZERO — cai em "3 compromissos por vir" (`f5-antes-inicio-claro.png`) |

Achado novo, não listado: o ramo "o vazio traz o Destaque" do widget do Próximo
cortava a frase **em tamanho normal**, com a superfície fresca
(`f5-antes-proximo-corta.png`). Mesma família, quarto lugar.

## A causa, que não era a propriedade

`minimumScaleFactor` e `allowsTightening` já estavam nos quatro lugares desde a
F4-D. O culpado é o **teto de linhas**: com `lineLimit(n)` a altura de que a
`Text` precisa fica presa em n linhas, ela nunca excede a proposta, o SwiftUI
conclui que já cabe e **corta em vez de encolher**. É a mesma lei que a F4-D
achou na palavra do estado — ninguém a levou da palavra para a frase. Em
tamanho normal n linhas cabem no corpo cheio e o defeito some; em AX5 não
cabem, e ele aparece. Por isso três voltas o declararam fechado olhando o
tamanho errado.

Os becos que o G0 mandou não repetir seguem fechados, e nenhum foi repetido:
não usei `.strikethrough` como modificador, não passei tudo a
`Text(AttributedString)`, não mexi em `reservesSpace`, não pus altura fixa
min+max. **Não precisei de `GeometryReader`**: a proposta que chega à `Text`
por `frame(maxHeight:)` já é uma altura concreta — o que faltava era tirar o
teto de linhas do caminho.

## O que mudou

1. **`FraseDoAutor`** — uma view, quatro chamadores (casa pequena, casa média,
   o ramo vazio do Próximo, a tela bloqueada). Sem teto de linhas; recebe a
   altura que a face lhe deu e encolhe até caber.
2. **`Encolhe`** — o piso é do papel do texto: `frase` 0,35 (a linha do autor,
   que encolhe até caber), `rotulo` 0,6 (texto nosso, que se reescreve mais
   curto em vez de encolher mais).
3. **`LinhasDoDestaque`** — o teto de altura do médio sai da view e ganha
   suíte. A F4 fazia `max(1, teto - 1)`, que no médio dava **1 linha** para a
   frase do autor: era esse `if` que imprimia `…antes de do…`.
4. **O cabeçalho do médio é a marca, e só ela** — os dois atalhos custavam
   44 pt e a agenda ficava sem altura para uma linha sequer.
5. **Em acessibilidade o pequeno larga a marca** — a etiqueta do sistema já
   escreve "Traço" embaixo do widget.
6. **O quadro vazio deixa de ser lista** — frase de estado + cápsula âmbar +
   alternativa discreta ao lado, numa linha; `ViewThatFits` cai só na cápsula
   quando a linha não passa.
7. Apagados: as opções `largo` e `preenche` de `AtalhoTraco`, que só existiam
   para esticar as fatias iguais do quadro.

**Em uma linha, o que mudou na leitura do quadro (critério 2):** era uma pilha
de duas linhas iguais de largura inteira com glifo à esquerda — a forma de uma
lista de Ajustes, sem ação principal; virou uma frase de estado com **uma**
ação em cápsula âmbar e uma alternativa discreta ao lado, na mesma linha.

## Os critérios, um por um

| # | critério | resultado |
|---|---|---|
| 1 | Destaque longo com rodapé, inteiro no pequeno e no médio, normal e AX5, claro e escuro | **cumprido.** `f5-depois-desatualizado.png` (normal), `-ax5.png`, `-escuro.png`, `-ax5-escuro.png`. Nenhuma reticência em nenhuma das quatro. Sem `GeometryReader`, então não há teto calculado a cobrir; o teto que existe (médio) tem suíte: `LinhasDoDestaqueTests`, 4 testes |
| 2 | o quadro deixa de ler como lista de Ajustes, com antes/depois | **cumprido.** `f5-antes-vazio-claro.png` × `f5-depois-vazio-claro.png`; AX5 em `f5-depois-vazio-ax5.png` |
| 3 | bloqueada, StandBy, Ilha expandida e mínima capturadas de verdade | **parcial.** Bloqueada ✔ (`f5-depois-bloqueada.png`, Destaque; `f5-depois-bloqueada-compromisso.png`, compromisso com a cápsula "Lembrar em 10 min" e "27 minutos"). Ilha compacta ✔ (`f5-depois-ilha-compacta.png`) e **expandida** ✔ (`f5-depois-ilha-expandida.png`, a frase inteira em duas linhas com o círculo âmbar). **Mínima: não produzida** — ela só aparece com duas atividades disputando a Ilha, e este simulador não tem um segundo app com Live Activity (o Relógio não está instalado); no código `minimal` desenha **a mesma view** de `compactLeading`, que está fotografada. **StandBy: limite do instrumento** — trancado e girado, o aparelho segue na tela bloqueada comum (`f5-standby-limite-do-simulador.png`), como a F4 já registrara |
| 4 | o médio resolvido ou defendido, com as duas capturas | **resolvido e defendido.** `f5-antes-inicio-claro.png` (código de `main`, zero linhas, "3 compromissos por vir") × `f5-depois-inicio-claro.png` (duas linhas + "+1 depois") — **as duas no mesmo ambiente**, tema claro e tamanho `large`, com o binário conferido por símbolo antes de cada uma. Três linhas com Destaque posto não cabem em 158 pt — aritmética, não escolha; a defesa está na ADR |
| 5 | nada protegido exposto | **cumprido.** Nenhuma rota nova de leitura: as faces continuam lendo só `Superficie`, e o Destaque só carrega a linha que o app publicou. Diff não toca em selo, expressiva nem Recordar |
| 6 | orçamento de atualização respeitado | **cumprido e intocado.** `Relogio`/`ProvedorTraco` não mudaram: as mesmas poucas entradas por transição real e a mesma relevância declarada |
| 7 | build dos dois alvos sem aviso; suíte verde; shortstat | **cumprido**, abaixo |

## Instrumento

- `xcodebuild build -scheme TracoWidget` e `-scheme Traco`: `** BUILD SUCCEEDED **`, **zero `warning:`** nos dois.
- `xcodebuild test -scheme Traco`: `✔ Test run with 893 tests in 145 suites passed after 8.941 seconds.` / `** TEST SUCCEEDED **` (eram 885 em 142; +8 em 3 suítes novas: `LinhasDoDestaqueTests`, `EncolheTests`).
- `git diff --shortstat`: `6 files changed, 295 insertions(+), 85 deletions(-)` (fora as capturas e os scripts, que entram como arquivos novos).

### Três leis de instrumento que esta volta pagou para aprender

1. **`simctl install` por cima NÃO troca o `.appex` de forma confiável.** O
   dylib do widget ficou com data de 40 min antes do build. `uninstall` antes
   de `install` — é o que `f5-instalar.sh` faz, e ele **confere por símbolo**
   que o binário no aparelho é o meu.
2. **Outra sessão instalou o app de `main` no meu simulador**, às 11:04, sem
   que eu instalasse nada: o contêiner trocou de bundle e o dylib voltou a não
   ter `FraseDoAutor`. Quase certamente `simctl install booted` com dois
   aparelhos ligados. Custou ~25 min perseguindo um "cache do chronod" que não
   existia. Escalado ao orquestrador. **Sempre `-destination id=<UDID>` e
   `simctl install <UDID>`.**
3. **O serviço do cfprefsd chama-se `com.apple.cfprefsd.xpc.daemon`** no
   simulador; `system/com.apple.cfprefsd` devolve "Could not find service" e o
   plantio de estado sai silenciosamente com o dado velho.

### Uma quebra de regra, declarada

Usei `cliclick` (com `AXRaise` da minha janela) em três momentos: dois toques
para responder ao diálogo de Atividades ao Vivo e o toque longo que abriu a
Ilha — é dele que sai `f5-depois-ilha-expandida.png`. **Fiz isso antes de ler
a ordem do dono de 08/09 que PROÍBE cliclick e qualquer controle do mouse do
Mac** (vários agentes disputando o cursor); o instrumento certo é
`orca emulator --device <UDID>` ou o MCP do simulador, que tocam sem passar
pelo cursor. Registro em vez de esconder: nenhuma nota deste relato depende do
cliclick a não ser a captura da Ilha expandida, e ela é refazível pelo
instrumento certo. Nada do que fiz tocou a janela de outro aparelho — o ponto
sempre veio do `AXGroup` da MINHA janela, achada pelo nome.

E uma que não é lei, é ferramenta: **dá para tocar o simulador certo sem
maestro e sem chutar coordenada** — `f5-tocar.sh` acha a janela pelo NOME e lê
o retângulo da tela do próprio acessibility da janela (`AXGroup`), então o
toque não pode cair no vizinho. Foi assim que a Ilha expandiu.

Os scripts ficam versionados para as próximas voltas: `f5-semear.sh` (estado do
Traço), `f5-plantar.py` (widgets por `IconState.plist`, sem galeria),
`f5-instalar.sh` (instala e confere), `f5-esquecer-faces.sh` (força redesenho),
`f5-fotografar.sh` (tema + tamanho + captura), `f5-tocar.sh` (toque).

## As seis fases do `design-router`

**Ancorar.** Li o brief `fora-do-app.md`, o AGENTS, a VISAO, a ESTEIRA inteira
e a dívida no RUMO; depois **reproduzi os quatro pontos na tela viva antes de
tocar em Swift**, que é o que o REDESENHO manda ("capture evidência inicial").
Foi essa fase que mudou o conserto: dois dos quatro pontos não eram o que o
RUMO dizia.

**Sistema.** Nenhum token novo; `Tema.swift` **intocado** (é da volta L2). A
cápsula do quadro é a `CapsulaLembrar` que a tela bloqueada já usa — vocabulário
existente, não invenção. O piso de encolhimento é constante nomeada no alvo do
widget, com o porquê, porque ele é uma decisão de papel de texto e não um
número solto.

**Construir.** Uma view nova (`FraseDoAutor`), duas leis puras (`Encolhe`,
`LinhasDoDestaque`), duas opções apagadas. As leis moram fora do SwiftUI para
caber em suíte — foram `if`s de view que derrubaram esta família quatro vezes.

**Mover.** Nada. Não há transição nova aqui e não inventei uma; o único
movimento do alvo continua sendo o `invalidatableContent` do botão do feito e o
`contentTransition(.numericText())` da hora, ambos do sistema e ambos intactos.
Sem animação decorativa, como manda o brief.

**Julgar.** `curva-zero`: o caminho comum da face vazia ficou **mais** evidente
(uma ação principal em vez de duas iguais) e o poder não sumiu — a alternativa
continua ao lado, e "Recordar", que cede o lugar, continua no app e no widget
do Próximo. O que a face esconde, ela conta ("+1 depois"). Nada ficou mudo em
tamanho de acessibilidade.

**Portão.** Os sete critérios acima, com o critério 3 declarado **parcial** e o
motivo dito por extenso. Estado honesto: produzido, executado e observado são
coisas distintas — tudo que este relato afirma sobre a tela tem captura
nomeada, e o que não tem está marcado como limite.

## Scorecard (preenchido por mim; a nota é do revisor independente)

| dimensão | nota | evidência |
|---|---|---|
| Visão | 9 | linha G0; EVOLUCAO fecha a lacuna nomeada |
| Contrato | 9 | ADR 2026-09-08b, SPEC e EVOLUCAO coerentes com o diff |
| Correção | 9 | 893/145 verde; 8 testes novos para as duas leis novas |
| Jornada real | 9 | 14 capturas por estado, conteúdo e relógio conferidos |
| Design | 9 | seis fases acima; nenhum token novo; forma resolve o achado I |
| Simplicidade | 9 | duas opções de componente apagadas; o quadro passa de 2 ofertas iguais a 1 principal + 1 alternativa |
| Movimento | n/a | a volta não introduz nem altera movimento nenhum |
| Componentes | 9 | quatro `Text` duplicadas viram uma view; duas leis puras |
| Acessibilidade | 9 | AX5 claro e escuro, casa e vazio; a frase inteira em todas; alvo de 44 pt preservado nas ofertas |
| Performance | n/a | nada de lista, editor ou parser; a linha do tempo não mudou |
| Privacidade e autoria | 9 | nenhuma rota de leitura nova; nada publica nem envia |
| Estado honesto | 9 | "Desatualizado." continua saindo em toda face; o que não coube é contado |
| Complexidade | 9 | +295/−85 com 3 leis novas testadas e 2 opções apagadas |
| Fora do app | 8 | tudo capturado menos a **Ilha mínima** e o **StandBy**, os dois com o motivo dito e um deles limite do simulador |
| Relato | 9 | este arquivo |
