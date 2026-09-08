# V12-G — o pé em AX5 sob o teclado, e o que ficou por rodar

Claude Fable 5.1, 08/09/2026, 17h50–18h25. Worktree `volta-v12b-pagina`, topo de
partida `e4ea756`. Simulador **iPhone 17 Pro (teste 2) `B91C8DEF`**, o meu
(402×874 pt). Todo `xcodebuild` (build-for-testing, test-without-building e a
suíte integral) e toda condução sob `ferramentas/orca/com-trava.sh` — **declaro
que segurei a trava** em cada passada. Nenhum `orca emulator`, nenhum maestro,
nenhum mouse: o condutor é o alvo `TracoUITests` preso ao UDID, a prova de tela
é `xcrun simctl io B91C8DEF` (screenshot e recordVideo, quadros por `ffmpeg`,
tempo por `ffprobe`). `C2416CBC` (conta Grok) e os outros quatro simuladores
ligados intocados; nenhum simulador alheio desligado. `main` não tocado.

`design-router` foi carregado no início e a volta é visual (uma linha de layout
em `CadernoView`): as fases estão citadas no fim. `curva-zero`: a jornada não
mudou (nenhum toque a mais ou a menos), a régua é a travessia do re-G4.

## O que o re-G4 apanhou, e o que a sonda mostrou

O juiz mediu por pixel: em AX5 com cartão e teclado, "Mais ações da nota" com a
segunda linha 15 pt sob o teclado no Pro Max, o botão 36 pt mais baixo que em
`b49ee0f` — e o relato da V12-E dizia "INTEIROS" sobre uma foto que mostrava o
corte. Reproduzi no meu aparelho ANTES de tocar no código, com a asserção nova
do condutor: **VERMELHO** — `"o pé entra 8 pt sob o teclado (fim)"` (régua
ainda em `app.keyboards`, que começa 44 pt abaixo do topo real; contra o
`inputView` eram 52,7 pt). Captura: `v12g-antes-ax5-cartao-pe-cortado.png` —
"da nota" cortado pelo teclado E a linha do cartão ("isto é um…") coberta pela
barra de "Trabalhar nisto".

Pus uma sonda de geometria temporária (`onGeometryChange`, frame global, em
corpo/papel/encaixe/acima/pé; removida antes do commit — os números estão em
`v12g-sonda-geometria.txt`):

| topo `e4ea756` | pt |
|---|---|
| corpo (topbar → teclado) | 137,3–539,0 (401,7) |
| papel | 137,3–338,2 (**200,8**) |
| encaixe | 338,2–539,0 (**200,8**) |
| acima (cartão recolhido + 12) | 338,2–447,8 (109,7) |
| pé, frame | 447,8–539,0 (**91,2**) — conteúdo mede **212,7** |

A pilha do corpo dividia a tela **a meio**. Causa: ao virar irmão do papel
(V12-E), o pé passou a receber uma proposta de altura, e o
`.frame(minHeight: 54)` do rodapé aceita qualquer proposta acima do mínimo —
o encaixe inteiro ficou flexível, e um `VStack` com dois filhos flexíveis
reparte igual. O pé (212,7, `fixedSize` só no `bottomBar` por dentro) não cabia
em 91,2 e transbordava 60,7 pt para cima e 60,7 para baixo. Dentro do
`.safeAreaInset` a proposta era nula e o pé valia o ideal — por acidente. Em
`large` o pé cabia na metade e ninguém viu.

## O conserto (uma linha, no lugar certo)

`Traco/Caderno/CadernoView.swift`, `peDoEncaixe`: `.fixedSize(horizontal:
false, vertical: true)`. O pé declara a rigidez que o inset lhe dava de graça; a
pilha do corpo fica com UM filho flexível, o papel. Nada da pilha de irmãos, do
`seguirCaret`, do portão hospedado ou das pré-condições foi desfeito.

| depois | pt |
|---|---|
| papel | 137,3–231,8 (94,5) |
| acima | 231,8–326,3 (94,5 = teto) |
| pé | 326,3–539,0 (212,7), encostado no teclado |
| XCUITest: "Trabalhar nisto" | 331,3–400,7 |
| XCUITest: "Mais ações da nota" | 405,7–**531,0**; `inputView` a **539** → **8 pt de ar** |

Conferi a captura antes de escrever a frase: `v12g-ax5-cartao-pe-inteiro.png`
mostra "Trabalhar nisto", "Mais ações" e "da nota" inteiros, ar até a barra
"Não / O / E", caret à vista em "pensar. abc|". Com RM, `v12g-ax5-cartao-pe-inteiro-rm.png`,
os mesmos números ao décimo.

**Custo que a foto também mostra, com número:** o teto do encaixe (05y: nunca
mais de metade da sobra) dá 94,5 pt ao cartão recolhido, que pede 109,7 — o
recorte do encaixe come **15 pt do topo do cartão** (o recuo de 16; a linha e o
"•••" ficam inteiros, o canto de cima fica reto). O papel fica com 94,5 pt: uma
linha e meia de AX5. No Pro Max (956 pt) a sobra é maior e cabe tudo. Não mexi
na regra: é contrato da 05y e teste de `CadernoTetoTests`; mudar o teto para
"o cartão ganha do piso" é outra decisão, e fica dita, não escondida. Em
`b49ee0f` o mesmo teto já cortava o mesmo cartão neste aparelho.

## Régua nova no condutor (`TracoUITests/EscritaVisivelUITests.swift`)

`medirPe(_:fase:)` na fase `fim`: escreve os frames de `pagina`,
`cartao-recolhido`, `trabalhar-nisto`, `mais-acoes-da-nota`, `abrir-lente` e
`regua` em `medidas-fim.txt` e **falha** se a união deles passar do topo do
teclado. O topo é o **`inputView`** (barra preditiva incluída): `app.keyboards`
começa nas teclas, 44 pt abaixo, e com essa régua o corte do re-G4 passava —
foi a primeira coisa que a asserção me ensinou. Vermelho provado no topo
anterior; verde nos quatro casos depois.

## O que ficou por rodar, rodado

| caso | resultado | pé vs. `inputView` (539) |
|---|---|---|
| `testAX5ComCartao` sem RM | passed (45,3 s) | 531,0 → 8 pt |
| `testAX5ComCartao` **com RM** | passed (45,5 s) | 531,0 → 8 pt |
| `testLargeComCartao` sem RM | passed (42,4 s) | barra "Analisar…Lente" 490–534 → 5 pt |
| `testLargeComCartao` com RM | passed (41,8 s) | idem |
| `testAX5EncaixeVazio` (nunca rodado) | passed (30,6 s) | régua 278, pé 331–531 → 8 pt |
| `testLargeEncaixeVazio` (nunca rodado) | passed (30,6 s) | 490–534 → 5 pt |

Linhas coladas em `v12g-teste-linhas.txt`; frames em `v12g-medidas.txt`;
capturas `v12g-large-cartao-pe.png`, `v12g-ax5-vazio-pe.png`, `v12g-large-vazio-pe.png`
(conferidas: papel, régua, pé e teclado, nada cortado).

## AX5 com Reduzir Movimento, refilmado (`v12g-ax5-abrir-com-rm.mp4`, 79 quadros)

Em AX5 "Abrir os campos" vive no menu da linha do cartão, e abrir o menu
derruba o teclado: o papel já mostra os seus rótulos ("RESULTADO…") atrás do
menu desde antes do toque. Lido quadro a quadro (`v12g-ax5-com-rm-quadros-30-44.png`,
`-45-59.png`, tempos em `v12g-pts-ax5-cartao-rm.txt`):

- q38 (2,355 s): o pé some atrás do menu num quadro — o corte do encaixe;
- q40–q44 (2,377–2,433 s, **~60 ms, 5 quadros**): o **menu do sistema** dissolve
  (só opacidade, RM) sobre "OBSTÁCULO INTERNO (O SEU HÁBITO/MEDO)" do papel;
- q46+: a folha ("voltar", "WOOP") cobre.

Sem RM (`v12g-ax5-abrir-sem-rm.mp4`, 90 quadros, `-quadros-30-44/45-59`): pé
some em q35 (2,242 s); menu encolhe e dissolve sobre os rótulos de q37 a q44
(2,257–2,320 s, **~65 ms, 8 quadros**), resíduo quase invisível até q48; folha
a partir de q45. **Esse par não é do encaixe**: cartão, régua e pé não estão em
nenhum quadro com os campos; o que dissolve é a `UIMenu` do UIKit, cujo
desvanecer o app não controla (RM tira a escala, não o fade), sobre um papel
que tem os rótulos por desenho. Digo com o número em vez de insistir. `large`
não mudou: sem RM q26 último com encaixe, q27 sem, folha q35; com RM
q26/q27/q34 (`v12g-large-*-quadros-*.png`) — 0 pares, os números da V12-F.

## Suíte integral (`v12g-suite-linhas.txt`)

`xcodebuild test -scheme Traco -destination id=B91C8DEF -parallel-testing-enabled NO`
sob a trava, 18h11: **TEST SUCCEEDED — 892 testes, 891 passaram, 1 pulado, 0
falhas**. `EscritaVisivelTests`: AX5 31/31 (teclado EMULADO, limite já escrito
na 08f), `large` 44/44 (teclado de software real).

## Estado do aparelho no fim

`ConnectHardwareKeyboard = 1` (lido), `ReduceMotionEnabled = 0` (lido),
`Booted`; o tamanho de letra é argumento de launch do teste, o aparelho segue
em `large`. Reiniciei só o meu UDID (três vezes: teclado de software, RM on,
RM off).

## design-router

Ancorar: o pé é desenho do dono (05f), inteiro acima do teclado em todo
tamanho. Sistema: nenhum token novo, nenhuma cor, fonte, padding ou duração;
`Tema` intacto. Construir: uma linha em `CadernoView`. Mover: nenhuma curva
nova; o corte segue a 08f; RM refilmado. Julgar: capturas e quadros lidos por
mim antes de cada frase; o custo dos 15 pt do cartão está dito. Portão: o
condutor falha se o pé voltar a entrar sob o teclado.

## Scorecard (meu; a nota é do revisor)

| dimensão | nota | por quê |
|---|---|---|
| Contrato | 9 | ADR V12-G na 08f, EVOLUCAO, código e teste dizem a mesma coisa; custo com número |
| Correção | 9 | vermelho no topo anterior, verde nos seis casos, suíte 891/892; asserção mede contra o topo real |
| Jornada real | 9 | seis estados vistos e conferidos (AX5/large × cartão/vazio, RM) |
| Design | 8 | o pé fechou; o cartão recolhido perde 15 pt do topo no 874 pt pela regra da metade — dito, não escondido |
| Movimento | 9 | 0 pares do encaixe nos dois tamanhos e modos; o par que resta é a `UIMenu` do sistema, ~60–65 ms, medido |
| Acessibilidade | 9 | AX5 com e sem cartão, com e sem RM: pé inteiro, caret à vista |
| Estado honesto | 9 | a foto do antes e a sonda estão no acervo; o "inteiros" falso da V12-E tem agora um teste que o apanha |
| Complexidade | 9 | +9 linhas no app (1 de código, 8 de comentário), +30 no teste |
