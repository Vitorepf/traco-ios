# Volta C1-B — a gaveta que cortava a linha ativa, e as provas que o G3 nomeou

Implementador (Opus 5), 09/09/2026, sobre `4898703`. Aparelho principal:
**iPhone 17e `C7341E64-3A33-4ADD-AF6C-9296215FAD09`**. Aparelho da prova do Pro
Max: **iPhone 17 Pro Max `6033B043-F436-41F9-B4F8-2D9E67761980`**, avisado no
comentário do worktree antes de usar (a F5b também o usa), só `xcodebuild test`
— nenhum `erase`, `uninstall` ou `install`. Não toquei no `C2416CBC`.

Todo `xcodebuild test` passou por `ferramentas/orca/com-trava.sh`: **segurei a
trava em cada passada**. Sempre `-destination id=<UDID>`, nunca `booted` (havia
cinco simuladores de pé). Nenhum maestro, nenhum `orca emulator`, nenhum mouse,
nenhuma voz, Siri, VoiceOver, ditado ou iPad. Não desliguei simulador nenhum.

## G0 — a linha do ciclo

**Ciclo:** multiplicar a mente. **Intenção:** o autor vê o que escreve **em cada
quadro**, que é como a 08f está escrita. **Obstáculo:** a C1 fechou a invariante
nos pontos discretos e deixou um resíduo declarado — a gaveta do cartão cortando
a linha ativa. **Evidência pedida:** o resíduo reproduzido e carimbado, a causa
nomeada, e o verde no mesmo instrumento nos dois aparelhos.

## 1. O instrumento antes do conserto

O re-G3 travou a mescla em duas coisas ao mesmo tempo: a violação existe, e a
medida dela (`~0,11 s numa varredura de 220`) não era verificável. As duas se
resolvem com o mesmo instrumento, e ele veio primeiro.

`aLinhaFicaNoPapelEmCadaQuadroDaGaveta(tamanho:)` põe um `CADisplayLink` a medir
a 08f **em cada quadro entregue**, com o instante de cada um, enquanto a Página
real recebe as três gavetas que encolhem o papel. Duas diferenças em relação ao
teste discreto que já havia:

- mede as **camadas de apresentação**, não o modelo (a 08f fala do quadro
  apresentado, e o apresentado é — medido — sempre o modelo do anterior);
- devolve **quadros e segundos**, com a cadência ao lado (16,7 ms = 60 Hz, sem
  quadro perdido) e o custo da própria sonda (0,2–0,5 ms/quadro), para o leitor
  saber que o instrumento não se está a medir a si mesmo (a lição da V12-D).

**O vermelho, no pai `4898703`, 17e** (`c1/c1b-quadros-vermelho.txt`):

```
GAVETA AX5,   cartão a chegar: 85 quadros em 1,42 s (cadência 16,7 ms), 6 fora; de +0,268 s a +0,350 s = 0,098 s, pior corte 32 pt
GAVETA large, cartão a chegar: 86 quadros em 1,42 s (cadência 16,7 ms), 6 fora; de +0,267 s a +0,350 s = 0,100 s, pior corte 13 pt
GAVETA AX5/large, aviso e toast: 0 fora
```

**Duas correções ao que a C1 escreveu, as duas contra nós:**

| a C1 disse | a medida diz |
|---|---|
| ~0,11 s | **0,098 s** (AX5) e **0,100 s** (`large`), 6 quadros cada |
| resíduo do 17e em AX XXXL | **também em `large`**, com o mesmo número de quadros |
| "numa varredura de 220" | a varredura não tinha tempo; a conta agora é do `CADisplayLink` |

## 2. A causa, medida antes de tocar no código

Sonda temporária em `tetoDoEncaixe` e na geometria do papel, quadro a quadro:

- **`large`:** a altura do papel é ANIMADA e desce 378 → 366 → 352 → 334 → 314
  → 295 → 283 pt, **até 21 pt por quadro**. O aviso da geometria chega em dia
  (`onScrollGeometryChange`: 275,0 → 262,8 → 248,6 → 231,3 → 210,7 → …), o
  seguidor corre a cada quadro — e a linha fica **sempre um passo atrás**. O
  corte de cada quadro é o passo daquele quadro.
- **AX5:** o mesmo, mais um **estouro de 52 pt**: o cartão entra por CORTE e a
  régua saía por GAVETA, então por ~0,3 s o encaixe tinha os dois — 52 pt a mais
  do que antes E do que depois — e o papel caía a **35 pt para uma linha de
  67**. Nenhuma rolagem cabe aí.

**A ablação que fecha a causa** (mesmo aparelho, mesmo teste, um a um):

| o que estava no lugar | AX5 | `large` |
|---|---|---|
| pai `4898703` (seguidor adiado, gaveta de pé) | 6 quadros, 0,098 s, corte 32 pt | 6 quadros, 0,100 s, corte 13 pt |
| seguidor **síncrono** no aviso da geometria | 5 quadros | **6 quadros — os mesmos offsets, ao pt** |
| síncrono + altura anunciada + adiantar um passo | 3 quadros | **6 quadros — os mesmos offsets, ao pt** |
| … + mirar no piso da 08w | 4 quadros | **6 quadros — os mesmos offsets, ao pt** |
| **corte** com o seguidor ADIADO | 0 | **1 quadro, 0,017 s, corte 115 pt** |
| **corte + seguidor síncrono com a altura anunciada** | **0** | **0** |

A linha do meio é o achado: **de fora do layout não há corrida a ganhar.** Três
seguidores diferentes deram os mesmos offsets ao ponto, porque a correção da
rolagem e a mudança da altura não cabem no mesmo quadro quando a altura é
animada. E a penúltima linha mostra que o corte sozinho também não basta: sem o
seguidor síncrono sobra o quadro único, e ele é o pior de todos (115 pt).

## 3. O conserto — nas duas causas, e no mínimo

Escolhi **(a) consertar**. A razão: a exceção que a 08f teria de abrir não seria
estreita — ela cobriria *toda* mudança animada de altura com o autor a escrever,
nos dois tamanhos e nos dois aparelhos, e é justamente a superfície que a 08f
existe para proteger. Contratualizar isso seria abrir espaço para o que hoje
falha, que é o que o re-G3 proibiu por escrito.

| onde | o quê |
|---|---|
| `PaginaView` | `.animation(focoPagina ? nil : Tema.gaveta(…), value: sessao.cartao)` e o mesmo para `analisando` — **nenhuma gaveta corre sobre a linha do autor**. É a lei que a 08f já aplicara duas vezes no mesmo encaixe (a régua CORTA; o encaixe sai por corte ao abrir os campos), estendida ao ocupante que faltava |
| `EscritaVisivel.seguirCaretAgora(folga:altura:)` | quem chama é `onScrollGeometryChange`: corre **agora**, e com a **altura anunciada** — nessa passada o `bounds` ainda é o da anterior. Ganha a corrida contra uma mudança de UM passo, que é o que o corte produz |
| `CadernoView.seguirAoMudarAJanela` | passa a altura adiante |

`seguirCaret(folga:)` — o de texto e foco — **não mudou**: ali o layout ainda
não assentou e o adiamento pelo runloop continua a ser a razão certa.

**O que NÃO entrou, e por quê:** o adiantamento de um passo, a mira no piso da
08w e a remoção da gaveta de `esconderRegua` foram implementados, medidos e
**revertidos** — a ablação mostrou que nenhum deles muda um offset depois do
corte. Três funções e um parâmetro a menos no diff final.

## 4. A prova de fecho

**iPhone 17e `C7341E64`** — teclado de software real de 308 pt nos dois tamanhos:

```
GAVETA AX5,   cartão a chegar: 84 quadros em 1,42 s (cadência 16,7 ms, sonda 0,3 ms/quadro), 0 fora
GAVETA AX5,   aviso no lugar do cartão: 87 quadros, 0 fora
GAVETA AX5,   toast por cima do encaixe: 87 quadros, 0 fora
GAVETA large, cartão a chegar: 84 quadros, 0 fora
GAVETA large, aviso no lugar do cartão: 87 quadros, 0 fora
GAVETA large, toast por cima do encaixe: 88 quadros, 0 fora
ESCRITA AX5: 31 amostras, 31 com a linha do caret na área livre do papel; teclado real 308 pt
ESCRITA large: 44 amostras, 44 com a linha do caret na área livre do papel; teclado real 308 pt
✔ Test run with 2 tests in 1 suite passed after 51.303 seconds.
```

**iPhone 17 Pro Max `6033B043`** — a prova que faltava, teclado real de 318 pt:

```
ESCRITA teclado AX5: de software, na tela 318 pt, papel 256–586 pt, topo do teclado 638 pt
GAVETA AX5, cartão a chegar: 84 quadros, 0 fora    GAVETA large, cartão a chegar: 84 quadros, 0 fora
GAVETA AX5, aviso: 86 quadros, 0 fora              GAVETA large, aviso: 87 quadros, 0 fora
GAVETA AX5, toast: 88 quadros, 0 fora              GAVETA large, toast: 88 quadros, 0 fora
ESCRITA AX5: 31 amostras, 31 …; teclado real 318 pt
ESCRITA large: 44 amostras, 44 …; teclado real 318 pt
LINHA: 61 offsets varridos, 0 em que a linha visual difere do caret; menor linha 63 pt, maior 65 pt
✔ Test run with 7 tests in 2 suites passed after 51.763 seconds.
```

**Runner pendurado, dito porque não é resultado:** as duas primeiras corridas no
Pro Max morreram com `The test runner hung before establishing connection`
(354 s e 361 s), com onze `xcodebuild` na máquina. `TemaTests` sozinho conectou
e passou (14/14, 0,087 s) no mesmo aparelho, e a terceira corrida do alvo
inteiro passou. Nem vermelho nem verde: repetido e mostrado, como manda a lei.

**Suíte integral no 17e**, `com-trava.sh`, `-parallel-testing-enabled NO`:

```
✔ Test run with 956 tests in 154 suites passed after 81.350 seconds.
grep -c warning:  ->  0
ESCRITA AX5: 31 amostras, 31 …; teclado real 308 pt
ESCRITA large: 44 amostras, 44 …; teclado real 308 pt
```

A linha de base da C1 era **949 em 153**. Os 7 novos são a sonda da gaveta, as
cinco bordas do TextKit 2 e a varredura do piso. E, ao contrário da corrida
integral da C1, **esta teve teclado de software REAL (308 pt) nos dois tamanhos
dentro da suíte inteira** — a prova principal deixa de depender da corrida
isolada, que era o limite escrito no relato do revisor.

**Vermelho antes do verde, em tudo que toquei:**

| prova | o vermelho | o verde |
|---|---|---|
| gaveta por quadro | 6 quadros fora em AX5 e 6 em `large`, no pai | 0 nas seis cenas, nos dois aparelhos |
| bordas do TextKit 2 | com `linhaDoCaret` a devolver só o `caretRect`: **3 de 5 casos vermelhos, 6 ocorrências** (linha vazia, quebra e fim do documento) | 5 de 5 |
| piso com folga sobrando | (aritmética; o lado apertado do `#expect` é o que a 05y reprovava) | 3.025 combinações, 2.687 com folga e 338 apertadas |

## 5. O resto do que o G3 nomeou

- **As dívidas estão no RUMO** (`ferramentas/orca/RUMO.md`, "Vindas do fecho da
  C1"): a barra de baixo em tamanhos de acessibilidade, o oráculo de pixels
  sobre a composição nativa, e a terceira que esta volta mediu — **o seguidor
  não ganha de uma altura animada**, com os três seguidores e os offsets iguais,
  para ninguém a redescobrir. O achado do caret na lista da V13 ficou marcado
  como FECHADO.
- **A prova do Pro Max** está acima, e a pergunta que a acompanhava — *o que
  muda onde havia folga sobrando?* — foi respondida por **varredura, não por
  aparelho**: `TemaTests.ondeHaviaFolgaSobrandoA08wNaoMudaNada` mostra que, onde
  meia sobra já dava uma linha, a 08w devolve **o mesmo número** da 05y. Vale
  para o Pro Max e para os aparelhos que ainda não existem; a corrida no Pro Max
  confirma a aritmética na tela.
- **As bordas do TextKit 2** têm suíte (`LinhaDoCaretTests`): vazio, linha vazia
  depois de `\n`, quebra por palavra, fim do documento e a borda do `NSMaxRange`
  varrida em todos os offsets.

## 6. Limites do instrumento, escritos

- **`caretRect` já é a linha visual num `UITextView` nu.** Com a entrelinha do
  papel e a fonte de corpo em AX XXXL, a linha e o caret coincidem ao ponto em
  **0 de 61 offsets**. A distância de 45 para 67 pt que a 08w mediu é do editor
  da **Página**, não do TextKit 2 em geral. Por isso as bordas não cobram "a
  linha é mais alta que o caret" — seria uma asserção que passa por acidente —,
  e sim o que protege o seguidor em qualquer editor. **A união com o fragmento
  continua justificada** pelo teste hospedado, que é onde a diferença aparece.
- **A sonda por quadro alcança a geometria, não o pixel.** Uma camada que
  desenhe por cima com a mesma geometria passa por ela. A varredura de camadas
  (`intrusos`) cobre esse caso na medida discreta e não corre por quadro porque
  custa a árvore inteira. Está no RUMO.
- **O vermelho está carimbado, não filmado.** O vídeo versionado
  (`c1/c1b-gaveta-consertada.mp4`) é da gaveta já consertada; o resíduo do pai
  ficou na sequência carimbada (`c1/c1b-quadros-vermelho.txt`), que é a
  alternativa que o G3 admitiu. Filmar o vermelho exigiria reverter o conserto
  para gravar, e a sequência tem mais informação do que o vídeo teria.
- **Voz, VoiceOver, ditado e iPad não foram exercitados**, por ordem do dono.
  Limite declarado, não nota.
- **`traitOverrides` na janela** é como os dois tamanhos entram, e não
  `simctl ui content_size`: não mexi no tamanho de letra de nenhum aparelho, e
  por isso não há nada a restaurar. `ConnectHardwareKeyboard` do 17e ficou como
  estava (`1`), e o teclado de software subiu mesmo assim, nos dois aparelhos.

## 7. Scorecard (preenchido por mim; a nota final é do revisor)

| dimensão | nota | evidência e limite |
|---|---:|---|
| Visão | 10 | A escrita às cegas some do ciclo de multiplicar a mente, agora também nos quadros em que a tela se mexe. |
| Contrato | 9 | A 08f volta a valer como está escrita — sem exceção — e a 08x diz por quê e o que custou; as três dívidas foram ao RUMO. |
| Correção | 9 | 6 → 0 quadros nos dois tamanhos e nos dois aparelhos; 956/154 verde; ablação de cinco variantes atribui cada quadro. |
| Jornada real | 9 | Página real, teclado de software real (308 e 318 pt) nos dois aparelhos; as três gavetas que o autor vê. |
| Design | n/a | Nenhum token, cor, tipo ou superfície nova. |
| Simplicidade | 9 | Três pontos de código, +1 função e +1 parâmetro; quatro tentativas medidas e revertidas por não mudarem offset nenhum. |
| Movimento | 9 | Uma gaveta a menos num estado (com foco), pela razão que a 08f já usava duas vezes; portão do movimento continua vazio; o custo está na pré-mortem. |
| Componentes | n/a | Nenhum componente criado ou alterado. |
| Acessibilidade | 9 | AX XXXL e `large` medidos nos dois aparelhos, por quadro e por amostra; VoiceOver falado continua limite declarado. |
| Performance | 9 | Cadência de 16,7 ms sem quadro perdido nas 12 gravações; sonda de 0,2–0,5 ms/quadro dita na linha. |
| Privacidade e autoria | n/a | O diff não toca conteúdo, origem, acesso ou envio. |
| Estado honesto | 10 | Duas medidas da volta anterior corrigidas contra nós (0,098 s e não 0,11; `large` também falhava); o limite do seguidor escrito no RUMO em vez de escondido. |
| Complexidade | 9 | +1 função e +1 parâmetro no app; o resto é teste e sonda. Nenhuma dependência, nenhuma abstração. |
| Fora do app | n/a | Sem superfície fora do app. |
| Relato | 9 | Ablação em tabela, runner pendurado mostrado, e a premissa do TextKit desmentida pela própria medida. |
