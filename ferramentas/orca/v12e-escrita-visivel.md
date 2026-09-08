# V12-E — o autor não escreve às cegas: a invariante da escrita visível

Claude Fable 5.1, 08/09/2026, 14h–17h. Worktree `volta-v12b-pagina`, topo de
partida `b49ee0f`. Simulador **iPhone 17 Pro Max `6033B043`**, o meu.
`TRACO_SEM_MODELO=1` por `launchctl setenv` no aparelho (motor local, nada gasto
na conta de ninguém). **Toda prova de tela é `xcrun simctl io 6033B043`**
(screenshot, ou `recordVideo` com quadros nativos extraídos por `ffmpeg` e
carimbo de tempo do `ffprobe`). Todo `xcodebuild` sob `ferramentas/orca/com-trava.sh`;
toda sessão de `orca emulator` também — e **declaro que segurei a trava**.
Nenhum maestro, nenhum mouse, nenhum simulador proibido tocado.

Estado do aparelho no fim: `large`, `ReduceMotionEnabled = 0`, "Connect
Hardware Keyboard" devolvido a `1` (era `1`; desliguei-o para ter o teclado de
software, como o G4 fez), helper morto, `TRACO_SEM_MODELO` some no próximo boot.

## Skills e as seis fases

`design-router` carregada ANTES da primeira linha de SwiftUI; `curva-zero`
porque a volta toca a jornada de escrever e a folha dos campos.

| fase | o que foi feito |
|---|---|
| **Ancorar** | Lido inteiro: brief, AGENTS, VISAO-PRODUTO, ESTEIRA, o G4 final (`g4-v12-design-final.md`), o parecer do conselho (`consulta-v12-invariante.md`, `83ca4d5`), a ADR 08f e o código de `CadernoView`, `PaginaView`, `CartaoAnaliseView`, `CadernoHitchesTests`. Pessoa e situação: o autor a escrever depressa, teclado de pé, o texto passa da altura do papel. Resultado observável: a linha que ele digita e o caret ficam na tela, em todo tamanho. Restrições vigentes (não se toca): o vão e o salto de 176 pt fechados, AX5 com cartão e teclado (item 2), a `Pilula` 5,04:1, tokens e portão do movimento |
| **Sistema** | Nenhum token novo, `Tema.swift` intacto. Nada de curva, duração ou `withAnimation`. O único material novo é um tipo utilitário (`EscritaVisivel`, `enum` sem estado) e um gancho `#if DEBUG` em `PaginaView` para o teste hospedado |
| **Construir** | A lei no contêiner (`CadernoView.body` vira pilha de irmãos), o seguidor do caret (`Traco/Caderno/EscritaVisivel.swift`), o corte do encaixe ao abrir a folha e a régua por corte (`PaginaView`, `CadernoView`), o teste hospedado (`EscritaVisivelTests`) e o condutor da prova de tela (`TracoUITests`, esquema próprio) |
| **Mover** | Filmado nos dois modos, quadros nativos: "Abrir os campos" ANTES do corte do encaixe (par legível ~100 ms, sem e com RM — igual ao que o G4 mediu) e DEPOIS (números abaixo) |
| **Julgar** | Travessia `curva-zero` abaixo; medi na tela o que o G4 mediu, no mesmo estado (texto acima da altura do papel, teclado de software de pé), com o mesmo método (pixels de caret no ciclo do piscar) |
| **Portão** | Suíte integral verde, build sem aviso, plantas vermelhas coladas; o que ficou de fora está em "Limites honestos" |

## A travessia da `curva-zero`

**Jornada:** o autor escreve depressa → o texto passa da altura do papel → a
forma veste sozinha → ele CONTINUA a escrever, no fim ou no meio → abre os
campos quando quiser.
**Resultado verificável:** a linha do caret está na tela em todo instante em
que a Página recebe escrita, em `large` e AX5, com o encaixe vazio, com o cartão
e com o aviso; e o gesto de abrir a folha não mostra o encaixe em duas
geometrias nem texto do papel por trás dele.
**Atrito observado (G4 final, reproduzido por mim no topo `b49ee0f` pela leitura
do frame: `Página` até 0,667 em AX5, 77 pt dentro do cartão em `large`):** 0
pixels de caret em 11 amostras; as linhas novas entravam por baixo do encaixe.
**Recuperação:** nada muda no que o autor pode fazer — "Deixar como nota"
continua a um toque (à vista em `large`, no menu da linha em AX5), o texto
nunca muda, a folha continua a nascer inteira. Toques: **1 em `large`, 2 em
AX5 — empate com o antes**; a volta moveu geometria, não controles.

| estado | o que vi, no build entregue |
|---|---|
| `large`, cartão vestido, teclado de pé, 480 caracteres | oito linhas de papel, o caret na última, **acima do cartão** (`v12e-large-cartao-fim.png`; caret 464 px em 2 de 4 amostras no ciclo do piscar, 0 nas outras 2 — o piscar; com RM idem, `v12e-large-cartao-fim-rm.png`) |
| o mesmo, três letras no MEIO (toque no alto do papel) | o caret na linha tocada, à vista (`v12e-large-cartao-meio.png`) |
| `large`, encaixe vazio, 400 caracteres sem forma | o caret na última linha acima da régua, e no meio (`v12e-large-vazio-fim.png`, `-meio.png`) |
| **AX5**, cartão vestido (menu "•••"), teclado de pé | três linhas de papel, o caret depois de "pensar.", cartão, "Trabalhar nisto" e "Mais ações da nota" INTEIROS acima do teclado (`v12e-ax5-cartao-fim.png`) |
| **AX5**, encaixe vazio, teclado de pé | três linhas de papel, o caret na última, régua e as duas ações acima do teclado (`v12e-ax5-vazio-fim.png`) |
| "Abrir os campos", sem e com RM | quadros nativos abaixo |
| a folha | nasce inteira, como antes (`v12e-large-folha-campos.png`) |

Tira dos estados: `v12e-estados-large.png` (fim, meio, folha) e
`v12e-estados-ax5-e-vazio.png`.

## O que mudou, e por quê

1. **A lei mora no contêiner.** `CadernoView.body` deixa de pendurar o encaixe
   num `.safeAreaInset` e passa a ser um `VStack` de dois irmãos: o papel
   recebe o que sobra, o encaixe fica abaixo, **sem pixel em comum**. Era o
   `.safeAreaInset` que deixava o `ScrollView` do papel correr por baixo do
   encaixe — o `TextEditor` julgava o caret visível num frame que o pé e o
   cartão cobriam. Teto e piso (05y) continuam iguais.
2. **O papel rola de verdade até o caret.** `EscritaVisivel.seguirCaret`
   corre quando o texto muda, quando o foco muda e quando a janela do
   `ScrollView` muda (`onScrollGeometryChange`: teclado, cartão, aviso, pé),
   acha o editor focado, mede o caret e põe o offset mínimo que traz a linha
   inteira (caret mais a folga entre linhas) para dentro da área visível. Só
   com foco. Duas coisas que custaram medida e ficam escritas no código: o
   `ScrollView` do SwiftUI **ignora `scrollRectToVisible`**; e o seguidor
   corre por `RunLoop.main.perform`, não pela fila principal do GCD, porque um
   runloop aninhado (o `RunLoop.main.run(until:)` de um teste hospedado) não
   esvazia a fila — o seguidor só corria depois de o teste acabar, e a suíte
   via offset 0 em toda amostra. O SwiftUI segue o caret sozinho em parte dos
   casos (73 de 75 amostras sem o seguidor), mas deixa a linha ~10 pt sob o pé
   e não reage ao cartão a chegar; o seguidor garante a linha inteira em todos.
3. **A1: o encaixe sai por corte antes de a folha subir.** Os quadros nativos
   com a pilha ainda mostravam o par (`v12e-antes-abrir-*`): no toque, o
   teclado desce, o `UIScrollView` do papel recebe o frame FINAL de imediato
   enquanto o cartão e o pé (desenho do SwiftUI) descem animados — e por ~100
   ms os rótulos dos campos, que são conteúdo do papel, ficavam legíveis entre
   o cartão e "Trabalhar nisto", sem e com RM. Agora `PaginaView.abrirCampos`
   tira o encaixe inteiro (cartão e pé) numa transação sem animação e SÓ DEPOIS
   põe a folha a subir; ao descer a folha, o encaixe volta por corte. Segunda
   bissecção pelos quadros: com o cartão e o pé cortados, a RÉGUA ficava —
   porque o foco NÃO cai quando a folha sobe (o teclado desce sem o SwiftUI
   soltar o `FocusState`) — e descia com o teclado deixando o "Todas" legível
   sobre "OBSTÁCULO INTERNO" por ~100 ms nos dois modos; `folhaEmCena` corta a
   régua também. E a régua passa a entrar e sair por corte fora da transação
   em que o foco muda (`reguaEmCena`), fechando o resíduo que a V12-D tinha
   medido "sobre o fundo da barra" — com o papel agora dono da faixa, ficaria
   sobre texto.
4. **O teste hospedado** (`TracoTests/EscritaVisivelTests.swift`) e **o
   condutor** (`TracoUITests/EscritaVisivelUITests.swift`, esquema
   `TracoUITests`, fora da suíte integral) — abaixo.

## O teste geométrico, hospedado

Monta a Página REAL do app hospedeiro (a `Sessao` viva é publicada por
`PaginaView.sessaoViva`, só em DEBUG), espera o editor focado e o TECLADO DE
SOFTWARE, apaga o texto, e digita em pedaços de ~24 caracteres mais do que cabe
no papel; a cada pedaço mede, na mesma coordenada da janela:

- **E** — a linha visual ativa pelo layout do TextKit 2 (o fragmento de linha
  que contém o caret), unida ao retângulo do caret;
- **P** — os bounds do `ScrollView` do papel menos o inset, recortados por todo
  ancestral que recorta, e sem o teclado;
- **O** — toda camada da janela À FRENTE do editor (ordem de irmãos e
  `zPosition` pela árvore de `CALayer`, porque o SwiftUI desenha texto e cor sem
  `UIView`; a primeira versão, por views, deixou passar a camada plantada),
  visível, cujo retângulo visível toque E.

Aprova só se E ⊆ P e O ∩ E = ∅, em `large` e AX5 (`traitOverrides` na janela),
com o encaixe vazio, o cartão `.vestida` e o aviso (`.aviso` mais o toast),
inserção no fim e no meio. O teste NÃO rola o papel. Antes de escrever, exige
papel limpo (a suíte inteira corre no mesmo processo e `CalendarioTrabalhoTests`
deixa o app no calendário: o teste volta à Página e falha nomeando a superfície,
não a medida).

```
ESCRITA teclado AX5: de software, na tela 318 pt (2 tentativa(s)), papel 256–586 pt, topo do teclado 638 pt, inset extra 284 pt
ESCRITA AX5: 31 amostras, 31 com a linha do caret na área livre do papel; teclado real 318 pt
ESCRITA teclado large: de software, na tela 318 pt (2 tentativa(s)), papel 118–480 pt, topo do teclado 638 pt, inset extra 284 pt
ESCRITA large: 44 amostras, 44 com a linha do caret na área livre do papel; teclado real 318 pt
** TEST SUCCEEDED **
```

**Vermelho com as plantas** (`v12e-teste-linhas.txt`, plantas removidas):

```
# planta 1 — .overlay(alignment: .bottom) { Text("INTRUSA")…frame(height: 120).background(Color.red.opacity(0.6)) } sobre o papel
ESCRITA AX5: 31 amostras, 2 com a linha do caret na área livre do papel; teclado real 318 pt
ESCRITA large: 44 amostras, 14 com a linha do caret na área livre do papel; teclado real 318 pt
amostras reprovadas: 59
↳ … AX5, encaixe vazio, fim: linha 326–392 pt, papel 150–408 pt, intrusos CALayer 0,288 440×120 | CGDrawingLayer 112,317 216×63
# planta 2 — o encaixe .overlay(alignment: .top) { Tema.fundo.frame(height: 120).offset(y: -120) }: uma superfície do encaixe 120 pt para cima, sobre o papel
ESCRITA AX5: 31 amostras, 2 com a linha do caret na área livre do papel; teclado real 318 pt
ESCRITA large: 44 amostras, 14 com a linha do caret na área livre do papel; teclado real 318 pt
amostras reprovadas: 59
↳ … AX5, encaixe vazio, fim: linha 321–387 pt, papel 145–400 pt, intrusos CALayer 0,280 440×120
```

**Limite do instrumento, escrito.** Sob `xcodebuild test` o teclado de
software nasce FORA da tela (frame em y = 956, `isInHardwareKeyboardMode = 0`)
e o hospedeiro do SwiftUI não desvia dele mesmo depois de ele subir. O teste o
levanta pelo UIKit (soltar e pedir o foco de novo, até 8 vezes) e repõe o
desvio por `additionalSafeAreaInsets` — a mesma coisa, pela porta do UIKit —,
conferindo que o papel ficou acima do teclado antes de medir. **Rodado
sozinho, o teclado real subiu nos dois tamanhos** (linhas acima). **Dentro da
suíte integral ele ficou fora da tela** (8 tentativas) e a altura foi reservada
com a etiqueta "EMULADO" na linha: a geometria medida é a mesma, mas o teclado
não estava na tela — está dito, não escondido. Um caminho com a Página
hospedada à parte (janela própria, depois `present` em tela cheia) foi tentado
e descartado: dava dois editores focados no mesmo processo e não recebia a
área segura do teclado.

## A1 — quadros nativos do gesto, com e sem Reduzir Movimento

**Antes do corte do encaixe (a pilha sozinha):** `v12e-antes-abrir-sem-rm.mp4`
(tira `v12e-antes-abrir-sem-rm-quadros-31-40.png`, `-41-50.png`): q32 → q37
(2,330 → 2,402 s) com o rótulo "OBSTÁCULO INTERNO (O SEU HÁBITO/MEDO)" legível
entre a linha do cartão e "Trabalhar nisto", cartão e pé parados enquanto o
papel já era mais alto — **~100 ms**. Com RM (`v12e-antes-abrir-com-rm.mp4`,
tiras `-21-30.png`, `-31-40.png`): q26 → q34 (2,263 → 2,365 s), **~100 ms**. É
o mesmo par que o G4 mediu, pela mesma causa: o `UIScrollView` recebe o frame
final na hora e o desenho do SwiftUI desce com o teclado.

**Depois (encaixe por corte, régua por corte):** `v12e-abrir-sem-rm.mp4`
(tiras `v12e-abrir-sem-rm-quadros-21-30.png`, `-31-40.png`): q27 (2,133 s) é o
último quadro com o encaixe — cartão, régua e pé; q28 (2,153 s) já não tem
nada dele: o papel ocupa a faixa inteira com o seu texto e os seus campos, o
teclado desce de q28 a q35 e a folha sobe a partir de q34. **0 quadros com
duas superfícies na mesma faixa em 73 quadros** (uma tomada, ~60 fps). Com RM
(`v12e-abrir-com-rm.mp4`, tiras `-21-30.png`, `-31-40.png`): q27 (2,207 s) o
último com encaixe, q28 (2,233 s) sem ele, folha a partir de q35 — **0 quadros
em 70**. O que se vê entre o corte e a folha é o papel a crescer para dentro da
faixa que o teclado libera, com os rótulos dos campos que sempre foram dele.
Filmes intermediários guardados como bissecção: `v12e-antes-*` (só a pilha,
par de ~100 ms) — e, entre eles e o final, o encaixe cortado mas a régua ainda
em cena deixava o "Todas" sobre "OBSTÁCULO INTERNO" por ~100 ms nos dois
modos (não guardado; o conserto é `folhaEmCena` na régua).

**A prova é amostrada** (quadros nativos a ~60 fps, uma tomada por modo), e
não certifica "nenhum quadro possível". O oráculo de pixels sobre a composição
nativa é volta própria e vai para o RUMO, como o conselho e a decisão pedem.

## Instrumento — o que aconteceu e fica registrado

- **`orca emulator attach` relança (ou derruba) o app da frente.** Provado por
  bissecção: app vivo → `attach` → 3 s depois `pgrep` vazio, sem relatório de
  crash, `runningboardd` só registra o exit. Foi isso que apagou o texto
  digitado às 15h44 (a Página voltou vazia) e derrubou o app às 16h16, com o
  helper disputado por três voltas (cada `attach` alheio roubava o meu, e o
  `ax --device` chegou a me devolver a árvore do `A1DF082C`). Por isso o
  condutor da prova de tela passou a ser um **alvo XCUITest** (`TracoUITests`,
  esquema próprio; toques e teclado reais pelo XCTest, `launchArguments`
  `-UIPreferredContentSizeCategoryName` para AX5), sincronizado com `simctl io`
  por arquivos-sinal em `/tmp/v12e/`. Reproduzível por quem tiver o worktree:
  `xcodebuild test -scheme TracoUITests -destination id=<UDID> -only-testing:TracoUITests/EscritaVisivelUITests/testLargeComCartao`
  com `conduzir.sh` (no relato) a fotografar nas fases.
- **O teclado físico do simulador** só se desliga na preferência
  (`DevicePreferences.<UDID>.ConnectHardwareKeyboard = 0`) com reboot do
  aparelho; `orca emulator type` entra pelo teclado físico e com ele ligado o
  teclado de software não aparece. O texto digitado pelo físico não sobreviveu
  ao reboot (o app só grava ao ir para o fundo).
- **`xcrun simctl launch --console-pty`** amarra a vida do app ao terminal:
  matar o `launch` mata o app. Foi uma das quedas.
- Os toques na barra de espaço do teclado de software pelo helper não
  produziram espaço (as palavras saíram coladas nas primeiras capturas,
  `v12e-04-*`); pelo XCUITest o texto sai inteiro.

## Limites honestos

- O teclado de software dentro da suíte integral (acima). VoiceOver e
  Instruments não medidos; a sábia não exercitada (`TRACO_SEM_MODELO=1`).
- A prova temporal do A1 é amostrada por quadros nativos, uma tomada por
  modo; a asserção universal exige o oráculo de pixels (RUMO).
- O `CadernoHitchesTests` (opt-in) não foi refeito nesta volta; o inset
  inferior que ele imprime passa a ser ~0 (o encaixe é irmão, não inset).
- A `curva-zero` conta toques; uma pessoa real não escreveu com o app.

## Scorecard (preenchido por mim; a nota final é do revisor)

| dimensão | nota | por quê |
|---|---|---|
| Visão | 9 | multiplicar: a porta de entrada da escrita deixa de esconder a linha que o autor escreve |
| Contrato | 9 | ADR 08f corrigida onde mentia, seção V12-E com a invariante palavra por palavra, EVOLUCAO |
| Correção | 9 | teste hospedado novo, verde no candidato e vermelho com as duas plantas; suíte integral verde |
| Jornada real | 9 | os estados do G4 (large com cartão, AX5 com encaixe vazio, fim e meio) refeitos na tela com teclado de software |
| Design | 9 | seis fases; tokens intactos; a lei no contêiner, como o conselho pediu |
| Simplicidade | 9 | empate de toques; o caret sempre à vista é o que faltava para 9 |
| Movimento | 9 | nenhuma curva nova; par legível de ~100 ms medido ANTES nos dois modos e 0 quadros DEPOIS, amostrado; custo assumido: o encaixe sai e volta por corte em volta da folha |
| Componentes | 9 | nada novo em Componentes; `EscritaVisivel` é utilitário do Caderno |
| Acessibilidade | 9 | AX5 com e sem cartão, caret à vista, ações inteiras acima do teclado |
| Performance | n/a | nenhuma medida nova; o seguidor corre uma vez por tecla, offset mínimo |
| Complexidade | ver `git diff --shortstat` no fecho | app cresce pelo seguidor e pelo corte; o teste e o condutor são instrumento |
| Estado honesto | 9 | teclado EMULADO etiquetado; prova amostrada dita como amostrada |
