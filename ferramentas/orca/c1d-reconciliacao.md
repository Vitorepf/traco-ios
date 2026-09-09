# C1-D — a C1 reconciliada com o `main`

**Aparelhos:** iPhone 17e `C7341E64` (suíte integral) e iPhone 17 Pro Max
`6033B043` (prova por quadro). **Não toquei no `C2416CBC`** (conta Grok do dono
caída) — nada instalado, nada apagado, nada relançado nele.

**Instrumento, declarado.** Todo `xcodebuild` passou por
`ferramentas/orca/com-trava.sh` — segurei a trava e ela aparece em
`/tmp/traco-instrumento.lock/dono` com o meu pid nas três corridas. Sem maestro,
sem mouse, sem computer-use, sem voz, sem VoiceOver, sem Siri, sem iPad. Os dois
aparelhos ficaram **ligados** (não fui eu quem os ligou), em retrato, com o
`content_size` intocado. Uso do Pro Max **avisado no comentário do worktree**
ao começar (06:50) e ao terminar (07:05).

## 1. O que a fusão custou

`main` estava **53 commits à frente** (`46816150` era a base; `d5f77e2` no
começo, `05ef887` ao fim — trouxe os dois).

| arquivo | os dois lados mexeram? | como resolveu |
|---|---|---|
| `SPEC.md` | sim — **único conflito de texto** | append contra append; **os dois blocos ficam inteiros**, o do `main` primeiro e o meu por último, que é a ordem de mesclagem que o documento sempre teve. 6503 + 574 + 302 = 7380 linhas, nenhuma perdida |
| `Traco/Pagina/PaginaView.swift` | sim | juntou sozinho — `main` nas linhas 122/280/485, C1 na 304 |
| `EVOLUCAO.md`, `RUMO.md` | sim | juntaram sozinhos |
| `Traco/Caderno/*`, `TracoTests/EscritaVisivelTests.swift`, `TemaTests.swift` | só a C1 | intactos |

## 2. A letra que colidiu

A C1 carregava **duas** ADRs para **uma** letra reservada. A `08w` da C1-A é da
Q-H, **que já mesclou**; a regra "muda quem é mais barato de mover" não alcança
quem está em `main`. A C1-A passa a **`09d`**; a **`08x` fica** como estava.

**Provado do tamanho da alegação**, como o `LETRAS-ADR.md` exige — nos seis
arquivos de troca pura, os multiconjuntos de linhas removidas e adicionadas são
idênticos depois de normalizar a letra:

```
OK  (1 linha,  só a letra)  Traco/Caderno/CadernoView.swift
OK  (2 linhas, só a letra)  Traco/Caderno/EscritaVisivel.swift
OK  (3 linhas, só a letra)  TracoTests/EscritaVisivelTests.swift
OK  (5 linhas, só a letra)  TracoTests/TemaTests.swift
OK  (1 linha,  só a letra)  ferramentas/orca/c1-caret.md
OK  (5 linhas, só a letra)  ferramentas/orca/c1b-gaveta.md
```

**O registro estava errado sobre si mesmo, e isso ficou escrito nele.** Ele dava
`08z` como próxima livre; lida pelo comando que ele mesmo prescreve, a `08z`
está no branch da Q2 e a `08` está **cheia**. Daí `09d` para a C1-A e `09e` para
esta ADR. Deixei `ESTEIRA.md` e `LACO.md` como estavam: o que eles contam é a
colisão de 08/09, e é um relato correto do que houve naquele momento. **Fica uma
ponta que não é minha de consertar:** `LACO.md:577` aponta a C1 pela letra
`08w`, que agora é da Q-H — o orquestrador decide se reescreve o próprio log.

## 3. O achado da fusão — a etiqueta do bot come papel

O `main` pôs a **etiqueta de origem** (ADR 08u/09b) **acima do editor** na
Página. Ela aparece quando o autor abre nota feita pelo bot, e ele **escreve
nela**: teclado de pé, caret vivo — o estado que a 08f governa. A invariante
**nunca o tinha visto**; a etiqueta não existia quando a suíte foi escrita.

A geometria aguenta porque os dois lados da C1 leem alturas **já descontadas**
da cápsula (o seguidor ouve o `containerSize` do ScrollView; `tetoDoEncaixe`
mede a `CadernoView`, irmã da cápsula). **Mas isso é raciocínio.** Medi:

```
ETIQUETA AX5:   papel 180 -> 150 pt (a cápsula tomou 30 pt)
ETIQUETA large: papel 194 -> 168 pt (a cápsula tomou 25 pt)
ESCRITA AX5: 39 amostras, 39 com a linha do caret na área livre do papel; teclado real 308 pt
✔ Test run with 2 tests in 1 suite passed after 57.710 seconds.
```

**O caso tem portão próprio:** exige que o papel encolha antes de medir. Uma
etiqueta que não desenhasse daria verde sobre a tela de sempre — prova vazia com
cara de prova —, e aí ele reprova dizendo que não mede o que promete.

**O cenário passou a neutralizar `origemDaPagina`**, como já neutralizava cartão
e toast. **Digo o tamanho disto para não cobrar mérito que não houve:** é
guarda, não conserto de vermelho — hoje nenhuma suíte suja essa propriedade pela
sessão viva (as que chamam `abrir(nota:)` usam `Sessao` própria).

## 4. Suíte integral na ÁRVORE MESCLADA

`com-trava.sh`, `-parallel-testing-enabled NO`, 17e `C7341E64`:

**Rodei duas vezes, e digo as duas.** A primeira foi da fusão crua, ANTES de eu
acrescentar o caso da etiqueta (981/157, 84,2 s, 0 avisos, ESCRITA 31/31 e
44/44). A que vale é a **final**, com o caso novo dentro:

```
✔ Test run with 981 tests in 157 suites passed after 87.204 seconds.
** TEST SUCCEEDED **
grep -c "warning:"  ->  0
GAVETA AX5:   teclado emulado 318 pt, 0 fora do papel, 0 com outra superfície sobre ela
GAVETA large: teclado real 308 pt,    0 fora do papel, 0 com outra superfície sobre ela
ETIQUETA AX5:   papel 180 -> 150 pt (a cápsula tomou 30 pt)
ETIQUETA large: papel 194 -> 168 pt (a cápsula tomou 25 pt)
ESCRITA AX5: 39 amostras, 39 dentro (teclado real 308 pt)
ESCRITA large: 52 amostras, 52 dentro (teclado real 308 pt)
LINHA: 61 offsets varridos, 0 em que a linha visual difere do caret
PISO: 2687 combinações com folga sobrando, 338 apertadas
```

O **número de testes não muda** (981 em 157): o caso da etiqueta são asserções e
amostras dentro de um caso que já existia, não um caso novo — as amostras é que
crescem, **31 → 39** e **44 → 52**, oito de cada vez, que são as duas fases da
etiqueta. A C1 sozinha tinha **956 em 154**. Os **25 testes que o `main` trouxe** e os da
C1 passam **juntos** — a única coisa que nenhum dos dois lados tinha medido.
**Nenhum teste ficou vermelho na fusão.**

## 5. As duas pendências da C1-C

**(a) Pro Max `6033B043` — REEXECUTADO, a ressalva sai.** Na árvore mesclada,
teclado **REAL de 318 pt nos dois tamanhos**:

```
GAVETA AX5:   teclado real 318 pt, 0 fora do papel, 0 com outra superfície sobre ela
GAVETA large: teclado real 318 pt, 0 fora do papel, 0 com outra superfície sobre ela
ESCRITA AX5: 31 amostras, 31 …; ESCRITA large: 44 amostras, 44 …; teclado real 318 pt
LINHA: 61 offsets varridos, 0 diferentes; menor linha 63 pt, maior 65 pt
✔ Test run with 7 tests in 2 suites passed after 55.166 seconds.
```

Esta prova é **melhor** que a que ela substitui: é da árvore fundida, não do
candidato sozinho. Sem runner pendurado nesta corrida.

**(b) O teclado emulado de AX5 — não muda conclusão nenhuma, e eis por quê.**
Duas razões independentes, nenhuma delas indulgência:

1. **O caminho emulado aplica área segura DE VERDADE.** Quando o teclado de
   software não sobe em 8 tentativas, o teste sintetiza 318 pt e os aplica em
   `additionalSafeAreaInsets.bottom`; **o layout reflui**. O que é sintético é o
   **número**, não a restrição — a medida continua sendo de geometria real.
2. **318 > 308, e papel menor é estritamente mais difícil** para uma invariante
   de continência. Passar a 318 é **mais forte** que passar a 308.

O que o caso emulado **não** prova é a chegada animada do teclado real — e isso
está coberto de outro lado: nesta corrida o caso ESCRITA teve o teclado **real
de 308 pt nos dois tamanhos** no 17e, e o **real de 318 nos dois** no Pro Max.

## 6. Scorecard (preenchido por mim; a nota é do revisor)

| dimensão | nota | por quê |
|---|---:|---|
| Fusão sem perda | 9 | Um conflito de texto, os dois blocos inteiros, contagem de linhas fechada; cada escolha declarada por escrito |
| Prova na árvore mesclada | 9 | 981/157 verdes com 0 avisos no 17e, e a prova por quadro reexecutada no Pro Max com teclado real |
| Achado da fusão | 9 | A etiqueta do `main` come papel onde a 09d media o aperto; medida, com portão contra prova vazia |
| Higiene da letra | 9 | Troca provada por multiconjunto; o registro corrigido contra o comando, e o erro dele escrito nele |
| Estado honesto | 9 | Pendências fechadas com prova nova; o emulado explicado em vez de dispensado; a guarda declarada como guarda; a ponta do `LACO.md` entregue ao dono dela |
| Jornada real | 8 | Página real hospedada, teclado real nos dois aparelhos — mas **sem captura de tela desta volta**: o que mudou aqui é fusão e instrumento, e a tela é a mesma que a C1-C filmou |

**Limites, ditos.** (1) Não filmei vídeo novo: esta volta não muda a tela, e o
MP4 da C1-C continua sendo a prova visual. (2) O caso GAVETA de AX5 na suíte
integral segue com teclado emulado no 17e — explicado acima, não descontado.
(3) Não mesclei em `main`: quem mescla é o orquestrador.
