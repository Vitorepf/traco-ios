# C1-C — a sonda mede a regra inteira, e o vídeo mostra o que promete

**Volta de correção do re-G3 da C1-B** (`ferramentas/orca/revisao-c1-caret.md`).
Sobre `600608f`, no worktree `volta-c1-caret`. **Nada mesclado.**

O revisor reproduziu o vermelho do pai e o verde do candidato com as próprias
mãos, e mesmo assim reprovou. Ele estava certo nas duas coisas, e nenhuma delas
é o conserto: são a **prova** dele. Esta volta não toca em uma linha do app.

## Instrumento e limites de aparelho

- **Meu simulador: iPhone 17e `C7341E64-3A33-4ADD-AF6C-9296215FAD09`**, retrato,
  sem mexer no tamanho de texto global do aparelho (a suíte troca a categoria
  pela janela e devolve).
- **Todo `xcodebuild` passou por `ferramentas/orca/com-trava.sh`** — segurei a
  trava em todas as corridas, inclusive a do checkout descartável do pai.
- **Não usei** maestro, `orca emulator`, mouse, computer-use, Siri, ditado,
  VoiceOver, fala ou iPad. Não toquei em `C2416CBC` (Grok) nem em `6033B043`
  (reservado à F5b). Não desliguei simulador nenhum.
- Havia quatro simuladores ligados; todo comando foi por **UDID explícito**.

## 1. A sonda media metade da 08f

`Quadro.cabe` era `area.contains(linha)` — só `E ⊆ P`. A 08f também diz
**"nenhuma outra superfície pode desenhar nessa área"**, `P ∩ O = ∅`, e essa
metade recebia verde **sem portão nenhum** por quadro.

Agora cada quadro carrega as duas, e o relato as separa:

```swift
var noPapel:    Bool { !linha.isNull && linha.height > 0 && area.contains(linha) }  // E ⊆ P
var semIntruso: Bool { intrusos.isEmpty }                                            // P ∩ O = ∅
var cabe:       Bool { noPapel && semIntruso }
```

`contar` conta e data cada metade no seu próprio termo, e o teste tem **duas**
asserções, cada uma com a sua frase. Uma sonda que soma os dois vermelhos num
número só deixa de dizer qual regra caiu.

`intrusos(sobre:editor:)` — a varredura da árvore de CAMADAS que a medida
discreta já usava — passa a ser chamada **em cada quadro**, e a ler geometria e
opacidade pela **apresentação**, como `E` e `P`. Custo medido: **1,6 a 3,1 ms
por quadro** numa cadência de 16,7 ms. O preço que o RUMO temia é pago com
folga, e a dívida do oráculo de pixels encolheu (RUMO atualizado).

### O primeiro vermelho foi FALSO, e isso está escrito no código

A primeira versão desta medida acusou um intruso em `large`, **um** quadro, a
+0,250 s — exatamente o primeiro quadro depois de o cartão nascer:

```
GAVETA large, cartão a chegar: 87 quadros, 0 fora do papel, 1 cobertos
GAVETA   coberta +0.250 s: linha 344–371 | CALayer 20,256 350×110
```

Uma camada recém-criada **ainda não foi entregue ao render**: `presentation()`
devolve nil. Lê-la pelo modelo é lê-la **na geometria de destino** enquanto a
linha e o papel estão na do quadro anterior — dois relógios no mesmo evento,
agora dentro do instrumento, que é o defeito que a própria 08x fechou no app.
Camada sem apresentação não pinta naquele quadro: **fica de fora**, com o motivo
comentado no código.

### E o portão prova que sabe reprovar

Zero intruso só vale como prova se a sonda mostrar, ali, que veria um. Depois
das três cenas verdes, o mesmo teste **planta uma camada adversarial** à frente
do editor, sobre a linha ativa, e **exige** que os quadros a acusem:

```
GAVETA AX5,   sonda adversarial: camada 151–184 pt sobre a linha 134–201 (322 pt de largura);
              50 quadros, 35 acusados (P ∩ O ≠ ∅), 0 fora do papel
GAVETA large, sonda adversarial: camada 168–181 pt sobre a linha 161–188 (55 pt de largura);
              51 quadros, 35 acusados (P ∩ O ≠ ∅), 0 fora do papel
```

Os ~15 quadros não acusados são os de repouso antes de plantar. A camada sai
depois, e os quadros seguintes voltam a zero — o teste também cobra isso. E ela
**aparece no vídeo**: a faixa vermelha sobre "agora" é essa camada.

## 2. `E` era a caixa do caret, não a linha

A sonda adversarial trouxe de graça um defeito da medida que ninguém tinha
visto: a faixa saiu com **2 pt de largura**. No **fim do documento** — que é
onde o autor escreve — nenhum fragmento do TextKit 2 começa na posição do caret,
`textLayoutFragment(for:)` devolve nil, e `linhaAtiva` ficava só com o
`caretRect`. Com o recuo de um caractere:

| | antes | depois |
|---|---:|---:|
| `E` em AX5 | 2 pt de largura | **322 pt** |
| `E` em `large` | 2 pt | **55 pt** |

A altura sempre esteve certa (é ela que o corte da gaveta ataca), e por isso o
vermelho e o verde da C1-B continuam de pé. Mas a metade `P ∩ O = ∅` cobrava,
antes disto, **apenas quem cobrisse a coluna do caret**. O teste também passa a
digitar uma palavra no fim (o bloco acabava em espaço, e o caret caía numa linha
vazia).

## 3. O vermelho do pai, agora nas DUAS metades

Checkout **descartável** do pai `4898703` (`git archive` para o scratchpad, sem
metadados de git, removido ao fim), com **só** o arquivo de teste deste ramo por
cima, `derivedDataPath` próprio, mesmo 17e:

```
PAI 4898703 + sonda C1-C, teclado de software real 308 pt
AX5,   cartão a chegar: 85 quadros, 7 fora do papel (E ⊄ P), 2 cobertos (P ∩ O ≠ ∅)
       fora    +0.270 a +0.367 s = 0.113 s, pior corte 32 pt
       coberta +0.317 a +0.350 s = 0.050 s
GAVETA coberta +0.317 s: linha 122–189 | CALayer 0,167 390×677 | CALayer 20,167 350×82
                                       | ColorShapeLayer 36,168 3×66 | CGDrawingLayer 51,168 197×66
large, cartão a chegar: 85 quadros, 5 fora (0.083 s, pior corte 14 pt), 5 cobertos (0.083 s)
✘ Test run with 2 tests in 1 suite failed after 54.574 seconds with 4 issues
```

**O cartão do pai não só cortava a linha: desenhava por cima dela.** O
`ColorShapeLayer` é a tarja do cartão e o `CGDrawingLayer` é o texto dele, os
dois sobre a linha que o autor estava a escrever. O instrumento anterior não
tinha como dizê-lo — e este é o achado que justifica o veredito do revisor.

O candidato, no mesmo aparelho:

```
GAVETA AX5:   0 quadro(s) com a linha ativa fora do papel, 0 com outra superfície sobre ela
GAVETA large: 0 quadro(s) com a linha ativa fora do papel, 0 com outra superfície sobre ela
✔ Test run with 2 tests in 1 suite passed after 54.669 seconds
```

Sequências carimbadas versionadas: `c1/c1c-quadros-vermelho.txt` e
`c1/c1c-quadros-verde.txt`.

## 4. O vídeo

`c1b-gaveta-consertada.mp4` tinha **44 s da Tela Inicial, sem o Traço**.
`git rm`. Não foi corrigido: foi **removido**, porque prova que ninguém olhou
não é prova.

No lugar entra **`c1/c1c-pagina-na-sonda.mp4`** — 36 s, 390×844, 562 KB,
gravado por `xcrun simctl io C7341E64… recordVideo` **durante a corrida verde** e
recortado da parte em que a Página está de pé. **Eu o assisti antes de
versionar**: extraí doze quadros ao longo dos 36 s e os olhei num mosaico. Eles
mostram, em ordem, a Página real com o teclado, o texto a ser escrito, o cartão
"Trabalhar nisto / Mais ações da nota" a chegar, o aviso "A sábia não
respondeu", o toast do microfone, e a faixa adversarial vermelha sobre a linha
"agora". Nenhum quadro de Tela Inicial.

**O que ele prova e o que não prova, dito aqui para não virar promessa outra
vez:** ele prova que a corrida aconteceu **na Página**, com o cartão, o aviso e
o toast na tela, e mostra a sonda adversarial a fazer o que diz. Ele **não**
prova geometria por quadro — 20 fps de vídeo não medem 16,7 ms. Quem prova isso
é a sequência carimbada.

## 5. Suíte integral

`com-trava.sh`, `-parallel-testing-enabled NO`, no 17e:

```
✔ Test run with 956 tests in 154 suites passed after 85.241 seconds
** TEST SUCCEEDED **
grep -c "warning:"  ->  0
GAVETA AX5:   teclado emulado 318 pt, 0 fora do papel, 0 com outra superfície sobre ela
GAVETA large: teclado real 308 pt,    0 fora do papel, 0 com outra superfície sobre ela
GAVETA AX5,   sonda adversarial: 51 quadros, 35 acusados
GAVETA large, sonda adversarial: 51 quadros, 35 acusados
ESCRITA AX5: 31/31; ESCRITA large: 44/44
LINHA: 61 offsets varridos, 0 em que a linha visual difere do caret
PISO: 2687 combinações com folga sobrando, 338 apertadas
```

Mesmo número de testes da C1-B (956 em 154): esta volta não acrescentou casos,
acrescentou **asserções e uma sonda adversarial dentro dos casos que já havia**.

**Diferença honesta contra o relato da C1-B:** dentro da suíte integral, o
teclado de AX5 saiu **emulado (318 pt, 8 tentativas)**, não real. Em `large` foi
real (308 pt), e na corrida isolada foi real nos dois. A C1-B afirmou real nos
dois dentro da suíte inteira; aqui não se repetiu. É variação do simulador sob a
suíte cheia, não asserção afrouxada — e fica dito em vez de arredondado.

## 6. O que ficou de fora, e por quê

- **Pro Max `6033B043`: NÃO reexecutado.** O preâmbulo o reserva à F5b.
  Perguntei ao orquestrador (`orca orchestration ask`, thread
  `msg_bd28ca96c860`) se estava livre; **o `ask` expirou aos 600 s sem
  resposta**. Segui o caminho menos destrutivo: não instalei nada nele. **A
  parte Pro Max continua prova HERDADA da C1-B, não observação minha.**
- **Rebase contra a ponta de `main`: não feito.** `main` andou 22 commits
  enquanto a volta corria (até `e90f3b3`), e toca `Traco/Pagina/PaginaView.swift`,
  que a C1-B também tocou. **Mesclar é do orquestrador**, e rebasear no meio de
  três frentes paralelas é dele também. Fica **nomeado como risco**: o conflito,
  se houver, é em `PaginaView.swift`.
- **O oráculo de pixels continua dívida.** A árvore de camadas mede quem está à
  frente e onde; não mede tinta. O portão adversarial prova a sonda, não o
  pixel. RUMO atualizado com o que encolheu e o que sobrou.

## 7. Diff

```
SPEC.md                              ADR 08x + a correção do re-G3
EVOLUCAO.md                          a mesma correção na linha da 08x
TracoTests/EscritaVisivelTests.swift a sonda (as duas metades, apresentação, adversarial, E no fim do documento)
ferramentas/orca/RUMO.md             a dívida do oráculo de pixels, encolhida e redelimitada
ferramentas/orca/c1b-gaveta.md       a linha que citava o MP4 falso
ferramentas/orca/c1/c1b-gaveta-consertada.mp4   REMOVIDO
ferramentas/orca/c1/c1c-pagina-na-sonda.mp4     novo, assistido
ferramentas/orca/c1/c1c-quadros-{vermelho,verde}.txt  novos
ferramentas/orca/c1c-sonda-inteira.md           este relato
```

**Nenhuma linha de `Traco/` mudou.** O conserto da C1-B está de pé como estava;
o que mudou foi o que o mede.

## Scorecard (preenchido por mim; a nota é do revisor independente)

| dimensão | nota | evidência |
|---|---:|---|
| Visão | 10 | A regra que protege a escrita ativa passa a ser medida inteira, e não pela metade que era fácil. |
| Contrato | 9 | `E ⊆ P` **e** `P ∩ O = ∅` por quadro, contadas e reprovadas separadas; o pai fica vermelho nas duas. |
| Correção | 9 | Pai 7/2 (AX5) e 5/5 (`large`) → candidato 0/0 nas seis cenas; o primeiro vermelho encontrado foi falso e está explicado, não escondido. |
| Jornada real | 9 | Página hospedada, teclado de software real 308 pt na corrida isolada nos dois tamanhos. |
| Design | n/a | Sem superfície nova. |
| Simplicidade | 9 | Uma função de leitura trocada, um struct com dois campos, uma sonda adversarial; sem dependência nova. |
| Movimento | n/a | Nenhuma curva, duração ou animação tocada. |
| Componentes | n/a | Nenhum componente alterado. |
| Acessibilidade | 9 | AX5 e `large` verdes nas duas metades; VoiceOver falado continua limite declarado, não exercitado. |
| Performance | 9 | 1,6–3,1 ms/quadro de sonda numa cadência de 16,7 ms, com a árvore inteira varrida em cada quadro. |
| Privacidade e autoria | n/a | Diff não toca conteúdo, origem, acesso ou envio. |
| Estado honesto | 9 | O MP4 falso saiu; o novo foi assistido e tem o que prova e o que não prova escrito ao lado; Pro Max declarado herdado; o teclado emulado em AX5 na suíte cheia está dito. |
| Complexidade | 9 | A varredura de camadas que já existia passou a correr por quadro; nenhuma abstração nova. |
| Fora do app | n/a | Sem superfície fora do app. |
| Relato | 9 | Cada número tem a linha de saída colada, e o caminho do artefato ao lado. |
