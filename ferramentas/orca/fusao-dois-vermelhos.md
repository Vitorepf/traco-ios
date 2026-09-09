# FUSÃO — os dois vermelhos que só apareceram com C1, R1, S1 e M1 juntas

**Branch:** `Vitorepf/fusao-c1r1s1` (não mesclei; quem mescla é o orquestrador).
**ADR:** `2026-09-09j`, reservada em `ferramentas/orca/LETRAS-ADR.md` no mesmo ato.

## Instrumento, declarado

**Aparelho de trabalho: `34CC3F94-FDB5-4575-A4F5-80271829A18B` (iPhone 17 Pro,
teste 3).** Eu o liguei (`simctl boot`) no começo e o **desliguei ao fim da mesma
corrida** (`simctl shutdown` do meu UDID; nunca `orca emulator kill`). Build e as
três corridas de suíte foram só nele.

**No `B91C8DEF` (aparelho da conta) eu não encostei** — nada instalado, nada
apagado, nada relançado, nenhum `xcodebuild` apontado para ele. Ele ficou ligado
o tempo todo, como estava.

**Todo `xcodebuild` passou por `ferramentas/orca/com-trava.sh`** — segurei a
trava nas três corridas e só nelas.

**Uma mudança de estado no aparelho de trabalho, declarada:**
`DevicePreferences.34CC3F94….ConnectHardwareKeyboard` de `1` para `0`. É a
**pré-condição escrita da suíte** (cabeçalho de `EscritaVisivelTests.swift`): com
o teclado de hardware ligado o teclado de software não sobe e a medida vira
emulada. **Deixei em `0`** — é o estado que a suíte pede nesse aparelho.

Sem maestro, sem mouse, sem computer-use, sem voz, sem VoiceOver, sem Siri, sem
iPad. Nenhuma captura de tela: o que esta volta mede é geometria por quadro na
Página real, e a prova é a medida colada, não o pixel.

## Vermelho 1 — a gaveta deixava quadro fora em `large`

**O vermelho, reproduzido no meu aparelho antes de tocar em nada:**

```
GAVETA large, cartão a chegar:            85 quadros, 0 fora do papel, 0 cobertos
GAVETA large, aviso no lugar do cartão:   87 quadros, 0 fora do papel, 0 cobertos
GAVETA large, toast por cima do encaixe:  86 quadros, 3 fora do papel, 2 cobertos;
   fora de +0.317 s a +0.350 s = 0.050 s de linha cortada, pior corte 1 pt
GAVETA   fora +0.317 s: linha 258–284, papel 118–283, corte 1 pt | modelo: papel 118–275, offset 454.0
GAVETA   fora +0.333 s: linha 249–276, papel 118–275, corte 1 pt | modelo: papel 118–267, offset 462.3
GAVETA   fora +0.350 s: linha 241–267, papel 118–267, corte 1 pt | modelo: papel 118–259, offset 470.3
✘ EscritaVisivelTests.swift:530  (totalFora → 3) == 0
✘ EscritaVisivelTests.swift:531  (totalCoberto → 2) == 0
```

**A suspeita do despacho era a etiqueta de origem. A medida diz que não é ela:**
o `Cenario` neutraliza `origemDaPagina = .autor` no `init`, e este caso nunca a
levanta — a etiqueta não está em cena em quadro nenhum da GAVETA. Além disso o
caso da GAVETA corre **antes** do da etiqueta na suíte serializada.

**O que a medida diz que é.** As três cenas do mesmo caso, no mesmo aparelho, na
mesma corrida, sobre a mesma linha: as **duas de cartão** deram **0 e 0**; só a
do **toast** sangrou. A diferença entre elas está em três linhas de
`PaginaView.swift`:

```swift
.animation(…, value: sessao.toast)                              // sem guarda
.animation(focoPagina ? nil : Tema.gaveta(…), value: sessao.cartao)      // com
.animation(focoPagina ? nil : Tema.gaveta(…), value: sessao.analisando)  // com
```

O `toast` vive no **mesmo encaixe** que o cartão (`acimaDoPe`) e muda a **mesma
altura**, mas a guarda da **ADR 08x** — *com o foco na Página a altura do encaixe
muda por CORTE, a gaveta não corre sobre a linha do autor* — nunca foi copiada
para ele. A prova de que é isso está no próprio relato do quadro: a borda de
baixo do papel desceu **8 pt por quadro** (283 → 275 → 267 → 259) e o `modelo`
do seguidor ficou **8 pt atrás** da borda real — um quadro de atraso, 1 pt de
letra cortada, três quadros seguidos.

**Conserto (uma linha):** a mesma guarda de `focoPagina` na animação do `toast`.

**O verde, no mesmo aparelho:**

```
GAVETA AX5:   teclado real 308 pt, 0 quadro(s) fora do papel, 0 com outra superfície sobre ela
GAVETA large: teclado real 308 pt, 0 quadro(s) fora do papel, 0 com outra superfície sobre ela
```

E a **sonda adversarial da mesma corrida continua acusando** (35 de 52 quadros
com a camada plantada), então o zero não é cegueira da sonda.

## Vermelho 2 — o empate é legítimo; a asserção é que estava errada

**O vermelho:**

```
ETIQUETA AX5: papel 86 -> 86 pt (a cápsula tomou 0 pt)
✘ EscritaVisivelTests.swift:598  (papelComEtiqueta → 86.333…) < (papelSemEtiqueta → 86.333…)
```

**Das duas hipóteses do despacho, a medida escolhe a segunda: existe caminho
legítimo em que a etiqueta não come papel — e ela está desenhando.** A altura
antiga só via metade do movimento. Medida a **rect inteira**:

```
ETIQUETA AX5:   papel 137–223 (86 pt) -> 197–283 (86 pt); topo desceu 60 pt, altura −0
ETIQUETA large: papel 118–327 (209 pt) -> 143–327 (183 pt); topo desceu 25 pt, altura −25
```

Em AX XXXL, com o aviso e o toast de pé, **o papel já está no piso da ADR 09g**
(`pisoDoPapel / 3`, uma linha de corpo = **86,3 pt**). A `tetoDoEncaixe` é
explícita sobre isso: `min(max(min(piso, sobra/2), piso/3), sobra)` — abaixo de
`piso/3` o papel **não cede mais, por lei**, e quem cede é o encaixe. É
exatamente o que se vê: a cápsula desce a `CadernoView` inteira 60 pt, o papel
desce 60 pt **sem encolher**, e os 60 saem do encaixe. Em `large` há folga, e aí
a altura conta o movimento inteiro (−25).

**Portanto a etiqueta não deixou de desenhar** (o topo do papel desceu nos dois
tamanhos, 60 e 25 pt) **e o teste não estava a apanhar defeito de produto** — a
altura do papel é que não pode ser o portão no piso.

**O que o portão passou a afirmar,** que é o que ele sempre quis dizer:

```swift
#expect(comEtiqueta.minY > semEtiqueta.minY)   // a cápsula é ACIMA do editor: desce o topo sempre que desenha
#expect(comEtiqueta.height <= semEtiqueta.height)  // e o papel nunca cresce com ela em cena
```

**Não troquei `<` por `<=` para ficar verde.** O `<=` está lá só como direção; o
**portão** é o `minY >`, estrito, e uma etiqueta que não desenhasse continuaria
a reprovar o caso por prova vazia — que é a única coisa que a asserção antiga
existia para impedir.

## Suíte integral na árvore mesclada

`com-trava.sh`, `-parallel-testing-enabled NO`, iPhone 17 Pro (teste 3)
`34CC3F94`, **árvore inteira, é a que vai para o `main`**:

```
✔ Test run with 990 tests in 160 suites passed after 88.684 seconds.
** TEST SUCCEEDED **
grep -c "warning:"  ->  0
```

São os **mesmos 990 em 160** que o orquestrador viu com 5 falhas: **nenhum caso
foi acrescentado, nenhum removido, nenhum desligado.** As duas asserções da
etiqueta viraram duas outras no mesmo caso.

Da mesma corrida:

```
GAVETA AX5:   teclado emulado 318 pt, 0 fora do papel, 0 com outra superfície sobre ela
GAVETA large: teclado real 308 pt,    0 fora do papel, 0 com outra superfície sobre ela
ETIQUETA AX5:   papel 137–223 (86 pt) -> 197–283 (86 pt)
ETIQUETA large: papel 118–327 (209 pt) -> 143–327 (183 pt)
ESCRITA AX5:   39 amostras, 39 com a linha do caret na área livre do papel
ESCRITA large: 52 amostras, 52 com a linha do caret na área livre do papel
```

(O AX5 da GAVETA caiu no teclado **emulado de 318 pt** nesta corrida da suíte
integral, como já acontecia no 17e da C1-D. Não muda conclusão: 318 > 308, papel
menor é estritamente mais difícil para uma invariante de continência, e a área
segura é aplicada de verdade. Na corrida só desta suíte o AX5 teve teclado
**real de 308**, e deu 0 e 0 também.)

## O que deixei em pé, como dívida com dono

Três, escritas em `ferramentas/orca/RUMO.md`, "Dívida vinda dos portões de hoje":

1. **A etiqueta toma 60 pt onde o autor tem 86 (uma linha)** em AX XXXL. Não é
   vermelho — a 08f fica verde, 39/39 dentro. É pergunta de produto. **Dono: a
   volta da Página (V12).**
2. **A renumeração `09d` -> `09g` da C1 parou no `SPEC.md`** — sobraram onze
   referências em código e teste (inclusive o nome de um teste) apontando para a
   ADR da S1-B, que é outra coisa. Não varri de propósito: é área da C1 e um
   `sed` em onze pontos alarga o diff de dois vermelhos. **Dono: a C1.**
3. **A 08x não tem portão** — a guarda `focoPagina` é copiada à mão em cada
   `.animation`, e foi por isso que o `toast` ficou de fora três voltas. Sobra
   `CadernoView.swift:281` (`esconderRegua`), hoje **medido em zero** porque
   cresce o papel em vez de encolher, mas é a mesma classe. **Dono: a volta do
   item 7 do RUMO** (o portão que impede `withAnimation` fora de `Tema`), que já
   é um teste que varre o repositório.

`EVOLUCAO.md` **não** foi tocado: esta volta não fecha lacuna nenhuma — conserta
um defeito e uma asserção.

## Scorecard (preenchido por mim; a nota é do revisor)

| dimensão | nota | por quê |
|---|---:|---|
| Causa raiz, não sintoma | 9 | O vermelho 1 foi diagnosticado pela diferença entre três cenas do MESMO caso, não pela suspeita do despacho — que a medida derrubou (a etiqueta nem está em cena ali). O conserto é a guarda que faltava, no lugar onde as irmãs já a tinham |
| Vermelho antes do verde | 9 | Os dois reproduzidos no meu aparelho antes de qualquer edição, com a linha colada; os dois verdes depois, na mesma suíte |
| Asserção honesta | 9 | O `<` não virou `<=` de conveniência: o portão continua estrito, mudou a grandeza medida, e a medida diz qual das duas hipóteses do despacho é a verdadeira |
| Escopo (§8, ponytail) | 9 | Uma linha de produção, um bloco de asserção no teste. Nada de arquivo novo, nada de abstração, nada de configuração |
| Prova na árvore mesclada | 9 | 990/160 verdes, 0 avisos, mesmo número de casos que a corrida vermelha do orquestrador |
| Estado honesto | 9 | O teclado emulado do AX5 dito e explicado em vez de escondido; a mudança de `ConnectHardwareKeyboard` declarada; as duas pontas viraram dívida com dono em vez de segurar a volta |

**Limites, ditos.** (1) Um aparelho só, o 17 Pro — a C1-D mediu no 17e e lá os
dois casos davam verde; é a diferença de aparelho que os expôs, e não repeti no
17e. (2) Sem captura nem vídeo: o que muda aqui é um quadro de animação de 1 pt
e a geometria de um retângulo, e nenhum dos dois se lê num PNG. (3) Não mesclei.
