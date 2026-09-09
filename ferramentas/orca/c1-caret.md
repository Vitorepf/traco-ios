# Volta C1 — o caret do Caderno em AX XXXL, no aparelho onde a invariante falhava

Implementador (Opus 5), 08/09/2026. Simulador **iPhone 17e
`C7341E64-3A33-4ADD-AF6C-9296215FAD09`** — ligado por mim, usado só ele,
desligado ao fim. Todo `xcodebuild`, `xcodebuild test` e toda sessão de
`orca emulator` passou por `ferramentas/orca/com-trava.sh`: **segurei a trava em
cada passada**. Prova de tela é `xcrun simctl io C7341E64… screenshot`, nunca
`io booted` (havia cinco simuladores de pé). Nenhum maestro. Nenhuma voz,
nenhuma Siri, nenhum VoiceOver, nenhum ditado, nenhum iPad. Não toquei no mouse
nem no teclado do Mac.

## G0 — a linha do ciclo

**Ciclo:** multiplicar a mente. **Intenção:** a pessoa vê o que está escrevendo,
em qualquer tamanho de letra e em qualquer aparelho. **Obstáculo:** a invariante
da escrita visível (ADR 08f) falhava no 17e em AX XXXL — o único vermelho da
suíte integral naquele aparelho, e a V13 provou pré-existente.
**Evidência pedida:** o vermelho reproduzido, a causa nomeada, o verde no mesmo
aparelho e no mesmo tamanho.

## 1. Reproduzir primeiro (a auditoria é datada)

Não comecei por consertar. A primeira passada foi o teste sozinho, na árvore
como estava:

```
✘ Test aLinhaAtivaEOCaretFicamNaAreaLivreDoPapel(tamanho:) with 2 test cases failed after 24.718 seconds with 18 issues.
✘ Test run with 1 test in 1 suite failed after 24.721 seconds with 18 issues.
```

**18 issues, as mesmas 18 da V13.** O defeito estava vivo. As 18 são todas de
**AX5**; `large` passou inteiro. Três formas, lidas do `xcresult`:

| forma | amostra | leitura |
|---|---|---|
| fim do documento | `linha 118–185, papel 122–192` | 4 pt de letra acima da borda, e `papel offset 2270 == teto 2270` — a rolagem estava **no batente**, não havia para onde ir |
| aviso e toast | `linha 92–159, papel 122–166` | papel de **44 pt** para uma linha de **67**: impossível por construção |
| meio da nota | `linha 100–167, papel 122–192` | 22 pt acima da borda **com rolagem de sobra** — o seguidor convergiu no lugar errado |

## 2. A causa, medida antes de tocar no código

Sonda temporária em `CadernoView.tetoDoEncaixe`, no 17e, AX XXXL, teclado de pé:

```
SONDA teto: altura 413,67  pe 274,67  piso 259,33 -> teto 69,50  papel 69,50
SONDA teto: altura 413,67  pe 326,67  piso 259,33 -> teto 43,50  papel 43,50
ESCRITA teclado AX5: de software, na tela 308 pt, topo do teclado 536 pt
```

Em `large`, a mesma sonda: `papel 92` em toda situação — por isso o `large`
sempre passou.

**Duas causas, as duas em função compartilhada** (procurei os chamadores antes
de editar: `seguirCaret` tem três chamadas em `CadernoView` e todas passam pela
mesma função; `tetoDoEncaixe` é a única concessora de área):

1. **O contêiner concedia menos de uma linha.** `papel = min(piso, sobra/2)`
   dava 69,5 e 43,5 pt para uma linha de 67. O pé toma 274,67 dos 413,67 pt.
2. **O seguidor perseguia o caret, não a linha.** `caretRect` tem 45 pt onde a
   linha tem 67 (a entrelinha fica por cima), e a `folga` pedida inteira
   empurrava a linha para fora do papel curto.

## 3. O conserto — na causa, não no teste

Nenhuma asserção foi afrouxada, nenhum aparelho excluído da medida. O teste
`EscritaVisivelTests` está **byte a byte igual** ao que era.

| onde | o quê |
|---|---|
| `CadernoView.tetoDoEncaixe` | o piso do papel nunca desce abaixo de **uma linha** (`piso/3`); quando nem uma cabe, o papel toma a sobra e o encaixe cede |
| `EscritaVisivel.linhaDoCaret` (nova) | mede a **linha visual** pelo TextKit 2 — o fragmento de linha unido ao caret. Medida de novo aqui, não lida do teste |
| `EscritaVisivel.seguirCaret` | segue essa linha, e a **folga cede** (`min(folga, (vista − linha)/2)`) quando o papel é curto |
| `TracoTests/TemaTests.oPapelTemPiso` | a expectativa antiga (`apertado == 73`) era a que descrevia o defeito; agora cita os números medidos no 17e |

Uma tentativa intermediária ficou registrada porque errei e o instrumento
apanhou: ancorar a linha encolhida pelo TOPO deixou **29 issues** em vez de 18 —
a folga de 25 pt continuava a empurrar 5 pt de letra para debaixo do encaixe. A
correção foi encolher a folga simetricamente, não a linha.

## 4. Prova de fecho

**Vermelho antes e verde depois, no mesmo aparelho e no mesmo tamanho:**

```
ANTES (17e, AX5 e large)
✘ Test aLinhaAtivaEOCaretFicamNaAreaLivreDoPapel(tamanho:) with 2 test cases failed after 24.718 seconds with 18 issues.
✘ Test run with 1 test in 1 suite failed after 24.721 seconds with 18 issues.
ESCRITA AX5: 31 amostras, 13 com a linha do caret na área livre do papel

DEPOIS (17e, AX5 e large)
ESCRITA teclado AX5: de software, na tela 308 pt (2 tentativa(s)), papel 241–484 pt, topo do teclado 536 pt, inset extra 274 pt
ESCRITA AX5: 31 amostras, 31 com a linha do caret na área livre do papel; teclado real 308 pt
ESCRITA large: 44 amostras, 44 com a linha do caret na área livre do papel; teclado real 308 pt
✔ Test run with 1 test in 1 suite passed after 24.644 seconds.
```

**Suíte integral no 17e**, `com-trava.sh`, `-parallel-testing-enabled NO`:

```
✔ Test run with 949 tests in 153 suites passed after 54.668 seconds.
```

**949 verdes, 0 vermelhos.** A linha de base da V13 era 18 issues no mesmo
aparelho: **restaram 0.** `grep -c warning:` no log da suíte: **0**.

**Capturas** (`ferramentas/orca/c1/`, todas `simctl io C7341E64…`, 17e em
AX XXXL, teclado de software de 308 pt na tela):

| arquivo | o que mostra |
|---|---|
| `c1-01-abertura-ax5.png` | o aparelho em AX XXXL, papel e régua, antes de escrever |
| `c1-02-caret-borda-inferior-ax5.png` | papel de 87 pt (122–209), a linha `tenho preguica│` **inteira dentro do papel**, encostada na borda de baixo, régua logo abaixo, **nada por cima** |
| `c1-03-caret-borda-superior-ax5.png` | a mesma faixa com a linha `ficar na │` na outra ponta do papel |
| `c1-05-papel-alto-caret-no-pe.png` | papel alto (sem cartão), `pensar.│` na borda de baixo, acima da régua |
| `c1-06-arvore-ax.json` + `c1-06-arvore-ax-instante.png` | a árvore de AX e a captura do MESMO instante |
| `c1-07-restaurado-medium.png` | `content_size medium` restaurado, conferido na tela |

**Sobre a árvore de AX, e a lei de 08/09:** a árvore expõe `Grupo 'Página'` com
o frame `[0,357 → 0,541]` e a `Régua de formas` em `0,546` — e **não expõe caret
nem linha de texto**. Ausência na árvore não é prova de ausência na tela: quem
prova que a linha está inteira e descoberta é a **captura**, não a árvore. A
árvore serviu só para confirmar que eu estava a ler o aparelho certo (rótulos e
geometria batendo com a captura do mesmo instante).

**Sobre a borda de cima e a de baixo, dito com honestidade:** em AX XXXL, com o
encaixe de pé, o papel do 17e passa a ter 87 pt para uma linha de 67. **As duas
bordas ficam a 10 pt uma da outra** — a linha toca as duas ao mesmo tempo, e é
por isso que a invariante era impossível antes. As duas capturas mostram a linha
nas duas pontas dessa faixa; não há, neste aparelho e neste tamanho, uma "borda
de cima" distante da de baixo para fotografar.

## 5. Resíduo declarado, não corrigido

`c1-04-residuo-gaveta-cartao.png`: durante a **gaveta do cartão a chegar**, um
quadro (~0,11 s numa varredura de 220) mostra a linha ativa **cortada ao meio**
pela borda do cartão — a altura do encaixe já cresceu e o seguidor ainda não
correu. O mecanismo não foi alterado por esta volta e a suíte não o apanha
(mede em pontos discretos). **Não afirmo que seja pré-existente: não o medi em
`HEAD`.** Está na ADR 09d e vai para o RUMO.

## 6. Limites do instrumento (fatos, não desculpas)

- **`orca emulator tap`/`type` deixou de entregar toque ao app no meio da
  passada** (funcionou às 21h22, parou às 21h27; é a falha de helper único da
  máquina, já na ESTEIRA). Sem ele não consegui dirigir a tela à mão para
  produzir a captura. **A saída foi melhor que a original:** rodei a suíte da
  escrita visível e varri a tela com `simctl io` em laço durante os 25 s do
  teste — 220 quadros reais do aparelho enquanto a **Página real** era escrita
  com o **teclado de software real**. As capturas acima são quadros dessa
  varredura, não montagens.
- **`traco://anotar?texto=…` não pôs texto na página** com o app já em primeiro
  plano (tentado uma vez, `simctl openurl`). Não investiguei — fora do escopo.
- O ditado, a voz e o VoiceOver **não foram exercitados, por ordem do dono**.
  Fica como limite declarado, não como nota.
- `ConnectHardwareKeyboard` do 17e foi mexido para tentar a captura à mão e
  **restaurado ao valor original (`true`)**. As passadas de teste que contam
  (antes, depois e suíte integral) correram todas com ele em `true`, como estava
  quando peguei o aparelho.

## 7. Scorecard (preenchido por mim; a nota final é do revisor)

| dimensão | nota | evidência |
|---|---|---|
| Correção | 9 | 18 → 0 issues no mesmo aparelho e tamanho; suíte integral 949/949; causa medida por sonda antes de editar |
| Instrumento | 9 | trava em toda passada; UDID explícito; 220 quadros reais; erro intermediário (29 issues) registrado em vez de escondido |
| Simplicidade | 9 | 3 arquivos, +1 função; nenhuma abstração nova; nenhum parâmetro novo em `tetoDoEncaixe` (uma linha é `piso/3`, que o próprio comentário já definia) |
| Honestidade | 9 | resíduo da gaveta declarado com captura e com o que NÃO provei; limites do helper e da voz escritos |
| Componentes / Design | n/a | volta de geometria e invariante; nenhum token, cor, tipo ou movimento novo — nada para o `design-router` julgar |
| Jornada (curva-zero) | n/a | nenhuma decisão nova para o autor; a tela é a mesma, com a linha à vista |

**O que fica para o RUMO:** a barra de baixo em tamanhos de acessibilidade toma
275 dos 414 pt do 17e. Enquanto ela não encolher, é o cartão que cede quando a
tela não dá para os dois. Isso é decisão desta ADR, e é dívida.
