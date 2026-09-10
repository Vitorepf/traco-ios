# LOTE-IA-09c — os consertos semânticos da Q3 e da Q4 medidos, num binário só

**Papel:** MEDIDOR. **Não conserto e não julgo.** O que segue são as saídas e o
que se CONTA nelas. A leitura de mérito é dos revisores.

**Worker:** LOTE-3. **Branch:** `Vitorepf/lote-ia-09c` (**não mesclado**).
**Data:** 09–10/09/2026.
**Aparelhos:** `34CC3F94` (teste 3) para build e suíte; `B91C8DEF` (teste 2, o da
CONTA) para a janela de medida. **Nenhum terceiro foi ligado.**

---

## 1. A montagem: o que colidiu foi só documento

`Vitorepf/lote-ia-09c` = `main` (`c46094d`) + `Vitorepf/volta-q3-notas` (`e83dd11`)
+ `Vitorepf/volta-q4-instigar` (`dcbf7c6`).

| passo | commit da mescla | conflito |
|---|---|---|
| `main` `c46094d` | ponto de partida | — |
| Q3 (`e83dd11`) | `65dd87c` | **`SPEC.md`** e **`ferramentas/orca/LETRAS-ADR.md`** |
| Q4 (`dcbf7c6`) | `b9059fc` | **`SPEC.md`** |

**Nenhum conflito de código** — como no LOTE-1. `Traco/Analise/Sabia.swift` e
`Traco/Analise/Politica.swift`, os dois arquivos de produção que as duas voltas
tocam, **auto-mesclaram** (a Q3 mexe no caminho de `responderNasNotas`, a Q4 em
`montarInstigar`/`montarContrapor`).

**Como resolvi:** as três colisões eram **ponto de inserção no fim do arquivo** —
`main`, Q3 e Q4 acrescentam ADR no mesmo lugar. **As três ADRs ficam, na ordem
`main` → Q3 → Q4**, nenhuma linha descartada; só acrescentei a linha em branco
entre blocos. Em `LETRAS-ADR.md`, a linha de `09i` existia dos dois lados —
`main` dizia *"reservada, volta viva"*, a Q3 dizia *"reservada"*: **ficou a de
`main`**, mais recente. É a mesma resolução do LOTE-1, palavra por palavra.

**As fixtures estão INTACTAS, e são byte a byte as do LOTE-1 e do LOTE-2:**

| fixture | sha256 | igual às janelas anteriores? |
|---|---|---|
| `prova/q3-responder-nas-notas.json` | `b0fc69f9e7ba4ec5d5715d073f08515c3840058b4dce08bd770b932c4adcac01` | ✅ |
| `prova/q4-instigar-contrapor-casos.json` | `ed9267c19b26dc61ea2247b3b00e3cc862bf9d7cf9f535786b312811c7f1e3be` | ✅ |
| `prova/q2-fumaca.json` | `ab4c3857ea8f68ea4a2c867ef93049acdc6613b4b2c023da4acfe61f130020fa` | ✅ |

**A comparação é pareada, e o par é este:** o LOTE-1 mediu **estas mesmas
fixtures**, em `grok-4.3`, no binário `e9983ddb…`, que já trazia a **primeira**
rodada da Q3 (`2a06314`) e da Q4 (`aec62d4`). Esta janela mede o mesmo material no
binário `c6cd0ca8…`, que acrescenta a **segunda** rodada — a Q3-B (`e83dd11`) e a
Q4-B (`dcbf7c6`). **O que muda entre as duas colunas é o conserto, e só ele.**

---

## 2. A suíte integral, no `34CC3F94` (teste 3)

```
$ ferramentas/orca/com-trava.sh bash -c 'xcodegen generate &&
    xcodebuild test -project Traco.xcodeproj -scheme Traco \
      -destination "platform=iOS Simulator,id=34CC3F94-FDB5-4575-A4F5-80271829A18B" \
      -derivedDataPath build'
✔ Test run with 1019 tests in 163 suites passed after 88.687 seconds.
** TEST SUCCEEDED **
RC=0
```

Começou **00:36:07Z**, terminou **00:38:09Z** (10/09/2026 UTC). Log inteiro em
`prova/lote09c-suite.log` (4685 linhas).

**1019 = 1015 do LOTE-1 + 4 que as duas emendas trouxeram.**
`grep -c 'warning:'` no log: **1**, e é o herdado de sempre —
`Traco/Notas/NotasView.swift:806`, `'+' was deprecated in iOS 26.0`. **Nenhuma das
duas voltas toca esse arquivo**; ele não está no diff `main..HEAD`.

### 2.1 O `sha256` do binário que foi para o aparelho da conta

Produto: `build/Build/Products/Debug-iphonesimulator/Traco.app`

| o quê | sha256 |
|---|---|
| **`Traco.app/Traco` (executável)** | **`c6cd0ca8611b8b1f38c0daa7ee11903829b51c6e55f04ab56e987036744edf26`** |
| `Traco.app/Traco.debug.dylib` (onde mora o código) | `c021fe965fe36d84a43939e96d0838130b8353d48deaf2a58d9e8090d9981aba` |

**O binário MUDOU** — o do LOTE-1/LOTE-2 era `e9983ddb…`. Por isso instalei, e
por isso instalei **uma vez só**.

---

## 3. A janela: UMA chamada de `com-trava.sh`, 16 min 13 s

**Toda a sequência correu dentro de UMA chamada de
`ferramentas/orca/com-trava.sh`** — as quatro fumaças, a única instalação e as
quatro corridas. Primeira linha **00:38:42Z**, última **00:54:55Z**. A trava foi
tomada antes e solta depois; conferi que `/tmp/traco-instrumento.lock` sumiu ao
fim. **Declarado.**

O script está versionado em `ferramentas/orca/lote-ia-09c-janela.sh`; o log de
parede, em `prova/lote09c-janela.log`.

### 3.1 A linha do tempo, com hora (UTC)

| hora | o que | modelo |
|---|---|---|
| 00:38:42Z | trava tomada; binário no aparelho = `e9983ddb…`, a instalar = `c6cd0ca8…` | — |
| 00:38:44Z | **fumaça 1 (ANTES do install)** — `contaGrokLigada=true`, **12 modelos** | *(padrão)* |
| 00:38:45Z | **INSTALL — o único da janela**, por cima (`xcrun simctl install`) | — |
| 00:38:50Z | binário no aparelho = **`c6cd0ca8…`**, dylib = `c021fe96…` | — |
| 00:38:52Z | **fumaça 2 (DEPOIS do install)** — `contaGrokLigada=true`, **12 modelos** | *(padrão)* |
| 00:38:52Z → 00:41:04Z | `responderNasNotas` — **21 execuções** (7 casos × 3) | **`grok-4.3`** |
| 00:41:04Z → 00:46:58Z | `instigar` + `contrapor` — **36 execuções** (12 casos × 3) | **`grok-4.3`** |
| 00:47:00Z | **fumaça 3 (FIM do bloco de produção)** — `contaGrokLigada=true`, **12 modelos** | *(padrão)* |
| 00:47:01Z → 00:49:08Z | `responderNasNotas` — 21 execuções | `grok-4.5` *(a sobra)* |
| 00:49:08Z → 00:54:52Z | `instigar` + `contrapor` — 36 execuções | `grok-4.5` *(a sobra)* |
| 00:54:54Z | **fumaça 4 (fecho)** — `contaGrokLigada=true`, **12 modelos** | *(padrão)* |
| 00:54:55Z | binário FIM = `c6cd0ca8…`; janela encerrada, trava solta | — |

**A ordem é a que o brief pediu:** fumaça → **uma** instalação → fumaça → as duas
fixtures seguidas **sem reinstalar** → fumaça. O bloco do `grok-4.5` veio
**depois** da fumaça de fecho do `grok-4.3`, de propósito: se ele falhasse, a
medida de produção já estava inteira. **Nenhuma repetição foi cortada** para o
modelo extra caber — as três de cada caso são fixas na fixture.

### 3.2 A conta NÃO caiu — as quatro leituras coladas

```
lote09c-fumaca-1-antes         2026-09-10T00:38:44Z  contaGrokLigada=true  modelos=12
lote09c-fumaca-2-pos-install   2026-09-10T00:38:52Z  contaGrokLigada=true  modelos=12
lote09c-fumaca-3-fim           2026-09-10T00:47:00Z  contaGrokLigada=true  modelos=12
lote09c-fumaca-4-fim45         2026-09-10T00:54:54Z  contaGrokLigada=true  modelos=12
```

**A conta sobreviveu ao install por cima** — a leitura de antes e a de depois estão
a 8 segundos uma da outra e dizem a mesma coisa. Nenhum comando derrubou a conta;
não houve nada a escalar. Nenhum `erase`, `clearState`, `uninstall` ou
`xcodebuild test` tocou o `B91C8DEF`. Conferi o `sha256` do executável e do dylib
**depois de fechada a janela**: continuam `c6cd0ca8…` e `c021fe96…`.

### 3.3 A liberação usada, conferida no JSONL e não na minha memória

`Traco/Analise/Politica.swift:106` põe `responderNasNotas` em
`.indisponivelPorQualidade`, e `provedor(_:)` (linha 165) só devolve `.grok` para
essa regra quando `liberadasParaAvaliacao` contém a operação. **Sem liberar, a
rota bate em `nil` antes de alcançar o provedor.**

| corrida | `TRACO_AVALIAR_LIBERAR` que usei | `operacoesLiberadasParaAvaliacao` no JSONL |
|---|---|---|
| as duas de `q3` | `responderNasNotas` | `["responderNasNotas"]` em **todas as 42** |
| as duas de `q4` | `instigar,contrapor` | `["contrapor","instigar"]` em **todas as 72** |
| as quatro fumaças | *(vazio)* | `[]` |

---

## 4. O ÍNDICE das saídas

Todos os JSONL estão inteiros em `prova/`, sem corte, e **todos fecharam com
`{"evento":"fim"}` gravado**.

| arquivo | operação(ões) | modelo | execuções | **transporte** (HTTP ≠ 200) | corrida |
|---|---|---|---:|---:|---|
| `prova/lote09c-fumaca-1-antes.jsonl` | `modelosGrok` | *(padrão)* | 1 | 0 | `297A0FF4…` |
| `prova/lote09c-fumaca-2-pos-install.jsonl` | `modelosGrok` | *(padrão)* | 1 | 0 | `69F00C16…` |
| **`prova/lote09c-q3-grok-4.3.jsonl`** | **`responderNasNotas`** | **`grok-4.3`** | **21** | **0** | `A4713BBA…` |
| **`prova/lote09c-q4-grok-4.3.jsonl`** | **`instigar` + `contrapor`** | **`grok-4.3`** | **36** | **0** | `B301B987…` |
| `prova/lote09c-fumaca-3-fim.jsonl` | `modelosGrok` | *(padrão)* | 1 | 0 | `1CAA9457…` |
| `prova/lote09c-q3-grok-4.5.jsonl` | `responderNasNotas` | `grok-4.5` | 21 | 0 | `87E95B23…` |
| `prova/lote09c-q4-grok-4.5.jsonl` | `instigar` + `contrapor` | `grok-4.5` | 36 | 0 | `338EE6A6…` |
| `prova/lote09c-fumaca-4-fim45.jsonl` | `modelosGrok` | *(padrão)* | 1 | 0 | `4B224448…` |

**Total: 114 execuções de operação medida, 114 chamadas ao provedor, 0 erro de
transporte.** Somadas às 76 do LOTE-1 e às 114 do LOTE-2: **304 execuções nas
mesmas duas fixtures**.

Trouxe para `prova/` deste branch, **byte a byte do branch `Vitorepf/lote-ia-09`**,
as duas saídas do LOTE-1 que formam o par: `prova/lote09-responder-nas-notas.jsonl`
e `prova/lote09-instigar-contrapor.jsonl`. Sem elas a comparação não se refaz.

Outros artefatos: `prova/lote09c-janela.log` (log de parede),
`prova/lote09c-suite.log` (suíte), `prova/lote09c-guardas.txt` (a saída inteira do
conferidor sobre os seis arquivos).

---

## 5. UMA alavanca por comparação, e a prova de que foi só ela

Duas comparações vivem nesta janela, e cada uma mexe em **uma** coisa:

- **conserto** (LOTE-1 `grok-4.3` × LOTE-3 `grok-4.3`): muda o binário, mesma
  fixture, mesmo modelo, mesmo aparelho, mesmo esforço.
- **modelo** (LOTE-3 `grok-4.3` × LOTE-3 `grok-4.5`): muda `TRACO_AVALIAR_MODELO`,
  mesmo binário, mesma fixture, mesma janela.

**A prova está gravada em cada execução**, não na minha palavra:

| o que ficou fixo | como se confere no JSONL | valor medido |
|---|---|---|
| esforço | `chamadasGrok[].esforco` | **`low` em 114 de 114** |
| binário | `sha256` antes, depois e ao fim | `c6cd0ca8…` nas três leituras |
| fixture | `fixtureSHA256` no `inicio` | `b0fc69f9…` / `ed9267c1…` |
| aparelho | um só usado por mim para medir | `B91C8DEF` |
| modelo pedido = modelo que respondeu | `modeloSolicitado` × `modeloRespondido` | **iguais em 114 de 114** |

Teto e temperatura não foram tocados: não há chave de ambiente para eles no
binário, e `TRACO_AVALIAR_SEM_ESFORCO` **não foi exportado** — daí o `low`
uniforme, o mesmo das duas janelas anteriores.

---

## 6. A TABELA — o que uma REGEX decide, e nada além disso

### 6.1 O que "passou" quer dizer aqui

Cada guarda é **frase da própria fixture**, não critério meu. O conferidor é o do
LOTE-2, **copiado sem alterar a lógica de contagem** para que as três janelas
continuem comparáveis: `ferramentas/orca/lote-ia-09c-guardas.py`. A contagem se
refaz, não se acredita.

> **ISTO NÃO É VEREDITO.** A maior parte dos requisitos das duas fixtures é prosa
> que só uma LEITURA decide — *"soma os 520 euros e cita as duas notas"*, *"não
> vira conselho médico"*, *"o contraponto se apoia na premissa do próprio texto"*.
> **Nada disso está contado abaixo.** As duas perguntas da volta — se os consertos
> pegaram — se respondem na leitura dos revisores, não nesta tabela.

### 6.2 A tabela, com a linha de base junto

| operação | LOTE-1 `grok-4.3` *(1ª rodada)* | **LOTE-3 `grok-4.3`** *(2ª rodada)* | LOTE-3 `grok-4.5` |
|---|---:|---:|---:|
| `responderNasNotas` (7 casos × 3) | 21 / 21 | **21 / 21** | 21 / 21 |
| `instigar` (6 casos × 3) | 18 / 18 | **18 / 18** | 18 / 18 |
| `contrapor` (6 casos × 3) | 18 / 18 | **15 / 18** ⟶ *ver 6.3* | 17 / 18 |
| **total** | **57 / 57** | **54 / 57** | **56 / 57** |

**Os SETE casos da Q3 correram, não só os três que falhavam**, e os **12 da Q4**
também: a linha de base entrou na mesma corrida. **O `grok-4.3` caiu de 57/57 para
54/57, e as três quedas estão nomeadas uma a uma abaixo** — duas delas são a
RÉGUA do conferidor, não o retorno do modelo, e nenhuma toca a Q3.

### 6.3 As três quedas, uma a uma — transporte e retorno em colunas separadas

| caso | rep | transporte | retorno | o que o conferidor disse |
|---|---:|---|---|---|
| `q4-contrapor-tudo-ou-nada` | 1 | **HTTP 200**, *"conteúdo completo"*, 1155 tokens de raciocínio | **`Falha.semRetorno`**, `saida: null` | `semRetorno` |
| `q4-contrapor-tudo-ou-nada` | 2 | HTTP 200 | `contra: ""`, `foraDaLista: ""`, `outroCampo` preenchido | `contra vazio` |
| `q4-contrapor-razao-ja-sustentada` | 2 | HTTP 200 | `contra: ""`, `foraDaLista` preenchido, `outroCampo: ""` | `contra vazio` |

**A primeira é a mesma coisa que o LOTE-2 nomeou:** o provedor respondeu, o que
não chegou foi o retorno da operação. **Não é erro de transporte** e não está na
coluna dele.

**As outras duas são a RÉGUA, e a régua é do conferidor — não da fixture.** A
fixture **nunca escreve** *"contra vazio reprova"*. O mais duro que ela escreve
para estes dois casos é *"os três campos vazios reprovam"* e *"calar nos três
também [reprova]"* — e **em nenhuma das duas execuções os três campos estão
vazios**. A regra `contra vazio` veio do conferidor do LOTE-2 e é **mais dura que
a letra**. Deixei a contagem como estava para não quebrar a comparação com as
janelas anteriores, e o script imprime a leitura pela letra ao lado:

```
  contrapor            15/18 passaram nas guardas mecânicas
  contrapor            17/18 pela LETRA da fixture (a regra "contra vazio" é do conferidor, não dela)
```

**Pela letra da fixture, o `grok-4.3` fica 56/57 e a única queda em 57 execuções
é o `semRetorno`.** Qual das duas réguas vale é decisão de quem lê — eu conto as
duas e digo de onde cada uma vem.

### 6.4 Uma coluna nova, e ela é igualdade de string, não leitura

O defeito que a Q3 ataca é a **meia-recusa**: devolver a frase fixa de limite e
nada mais. Essa frase é literal no código
(`Traco/Analise/FonteNotas.swift:109`, `limiteSemBase`), então comparar o texto
entregue com ela é **igualdade, não interpretação**. Fica em coluna separada, fora
da contagem das guardas.

| corrida | execuções em que o texto entregue é **SÓ a frase de limite** |
|---|---|
| LOTE-1 `grok-4.3` | **3 de 21** — todas em `q3-sem-lastro-nenhum-continua-honesto` |
| **LOTE-3 `grok-4.3`** | **3 de 21** — todas em `q3-sem-lastro-nenhum-continua-honesto` |
| LOTE-3 `grok-4.5` | **3 de 21** — todas em `q3-sem-lastro-nenhum-continua-honesto` |

**Nas outras 18 execuções de cada corrida a frase não aparece sozinha em nenhuma.**
O único caso que a devolve é justamente o que a fixture desenhou **sem lastro
nenhum**, onde o limite honesto é o que ela pede. **Esta coluna não separa os dois
binários** — nem o LOTE-1 caía nela. Registro isso e não o disfarço: se a
meia-recusa da 08/09 foi consertada em duas rodadas, **a diferença entre a primeira
e a segunda não está aqui**, e quem a encontrar vai encontrá-la na prosa.

---

## 7. OBSERVAÇÕES — separadas dos números, e NÃO são veredito

**O.1 — A palavra do autor voltou, e essa é a única coisa que a contagem mecânica
mostra tendo MUDADO com o conserto.** No caso `q4-instigar-o-autor-escreve-metodo`
*"método"* e *"degrau"* são palavras **do autor**, e a fixture exige o inverso da
proibição de jargão (o caso está isento da guarda G4 por ordem dela).

| corrida | repetições em que a palavra do autor aparece no retorno |
|---|---|
| LOTE-1 `grok-4.3` (1ª rodada) | **0 de 3** |
| LOTE-2 `grok-4.5` | 2 de 3 |
| LOTE-2 `grok-4.6` | 0 de 3 |
| **LOTE-3 `grok-4.3` (2ª rodada)** | **3 de 3** |
| **LOTE-3 `grok-4.5`** | **3 de 3** |

**Se isso é o conserto pegando, quem diz é o revisor.** O que eu conto é que a
mesma fixture, no mesmo modelo de produção, saiu de 0 de 3 para 3 de 3 quando o
binário mudou.

**O.2 — Campos em branco no `contrapor` aumentaram no `grok-4.3`.**

| corrida | `contra` vazio | `foraDaLista` vazio | `outroCampo` vazio | `semRetorno` |
|---|---:|---:|---:|---:|
| LOTE-1 `grok-4.3` | 0 | 2 | 2 | 0 |
| **LOTE-3 `grok-4.3`** | **2** | **3** | **6** | **1** |
| LOTE-3 `grok-4.5` | 0 | 0 | 0 | 1 |

A Q4 permite explicitamente `outroCampo` em branco em um dos casos; sobre os
outros dois campos eu continuo **não sabendo** o que a fixture permite fora das
frases já citadas. **É número, não juízo.**

**O.3 — Nenhum rótulo interno vazou, em corrida nenhuma.**
`escreveuRotuloInterno` veio `false` nas 42 execuções de `responderNasNotas` desta
janela, e nenhum texto final casa com `\bN\d+T\d+\b`. Idem no LOTE-1.

**O.4 — Um único caso da Q3 termina sem fonte citada, e é o mesmo nas três
corridas:** `q3-sem-lastro-nenhum-continua-honesto`, 3 de 3 em cada — o caso
desenhado sem lastro. Nos outros 6 casos, todas as execuções citam fonte.

**O.5 — Quantas perguntas o `instigar` devolve mudou com o binário.** Nenhuma
corrida saiu da faixa de 2 a 5 que a fixture manda.

| corrida | 2 perguntas | 3 | 4 | 5 |
|---|---:|---:|---:|---:|
| LOTE-1 `grok-4.3` | 0 | 2 | **13** | 3 |
| **LOTE-3 `grok-4.3`** | **1** | **12** | 3 | 2 |
| LOTE-3 `grok-4.5` | 0 | 1 | **15** | 2 |

O `grok-4.3` no binário novo encurtou a lista: de 13 execuções com 4 perguntas
para 12 com 3. **O `2` é o piso da fixture, e ele foi tocado uma vez.**

**O.6 — Tempo e raciocínio, mesmo esforço (`low`).** Ponho aqui porque é número,
não impressão. **Latência não é qualidade.**

| operação | LOTE-1 `grok-4.3` | LOTE-3 `grok-4.3` | LOTE-3 `grok-4.5` |
|---|---:|---:|---:|
| `responderNasNotas` | 7,87 s | **6,16 s** | 5,97 s |
| `instigar` | 6,35 s | 6,62 s | 8,17 s |
| `contrapor` | 9,48 s | **12,91 s** | 10,84 s |

Média de tokens de raciocínio: `responderNasNotas` 785 → **669** (`4.5`: 222);
`instigar` 524 → **754** (`4.5`: 310); `contrapor` 861 → **1164** (`4.5`: 343).
**O binário novo faz o `grok-4.3` raciocinar mais no `contrapor` e menos no
`responderNasNotas`.**

**Nada foi consertado, nada foi julgado.** As quatro corridas carregaram,
validaram e correram na primeira tentativa.

---

## 8. Instrumento, e o que foi deixado como estava

- **`B91C8DEF` (teste 2), o aparelho da CONTA:** a janela inteira. **UMA
  instalação**, por cima, declarada em §3.1, com `contaGrokLigada` conferido a 1 s
  antes e a 7 s depois. **Zero `erase`, `clearState`, `uninstall` ou
  `xcodebuild test`.**
- **`34CC3F94` (teste 3), o aparelho de trabalho:** build e suíte, **e nada mais**.
  **Limite declarado, e é desvio do brief:** o brief pediu um aparelho de trabalho
  *"que você ligue e desligue"*, e **eu o encontrei LIGADO e não o liguei** — o
  LOTE-2 já o havia encontrado assim e o deixado. A ordem do preâmbulo
  (*"aparelho que você encontrou ligado e não ligou: deixe como achou"*) é a mais
  específica das duas, então **deixei ligado**. Quem quiser a máquina com um
  aparelho só precisa desligá-lo por fora desta volta.
- **Nenhum terceiro simulador foi ligado.**
- **Trava:** duas chamadas de `com-trava.sh` no total — uma para a suíte
  (00:36:07Z → 00:38:09Z) e **uma só para a janela inteira** (00:38:42Z →
  00:54:55Z), como manda a lei de 09/09. Declarado. Soltas as duas.
- **Voz, VoiceOver e iPad:** nada disso foi usado, acionado ou tocado.
- Nada de orientação, tamanho de letra ou Movimento Reduzido foi alterado — esta
  volta não tem tela, só JSONL.

### 8.1 A dívida da trava continua de pé — terceira janela seguida

A guarda dos 30 min de `com-trava.sh` **não olha o PID**, e esta janela é UMA
chamada longa por desenho — 16 min 13 s desta vez. Mantive o `mtime` fresco com um
`touch` a cada 60 s **de dentro do meu script**, que morre com ele. **Não toquei em
`com-trava.sh`.** É a mesma dívida que o LOTE-1 e o LOTE-2 nomearam e ela **não se
fechou**: dono, orquestrador.

### 8.2 O que eu NÃO fiz, e por quê

- **Não escrevi ADR em `SPEC.md` e não reservei letra.** O MEDIDOR não decide
  nada — as ADRs desta matéria são a `09h` (Q3) e a `09i` (Q4), das voltas que
  consertaram, e já vieram na mescla. O LOTE-1 e o LOTE-2 também não escreveram
  ADR. **O achado do §6.3 — a régua do conferidor mais dura que a letra da
  fixture — é candidato a ADR, e o dono dele é quem lê, não eu.**
- **Não atualizei `EVOLUCAO.md`:** esta volta não fecha lacuna, mede.
- **Não mesclei nada em `main`.**

---

## 9. Scorecard (preenchido por mim; a nota final é do revisor independente)

| dimensão | nota | por quê |
|---|---|---|
| G0 — fronteira de IA | — | não se aplica: esta volta não decide nada de IA, mede |
| G1 — mérito da entrega | 9 | Q3+Q4 mesclados, suíte 1019/163 verde, 114 execuções, 7 e 12 casos com a linha de base junto, uma instalação, 0 erro de transporte, e o modelo extra sem cortar repetição |
| G2 — prova | 9 | JSONL inteiros, quatro fumaças com hora, `sha256` antes/depois/fim, conferidor versionado, linha do teste colada, saídas do LOTE-1 trazidas para o par se refazer |
| G3 — honestidade do estado | 9 | a régua mais dura que a fixture está denunciada com a frase dela; a coluna nova que **não** separa os binários está dita; o `semRetorno` está fora da coluna de transporte; o aparelho que deixei ligado está declarado como desvio |
| G4 — instrumento | 9 | um aparelho por papel, uma instalação, janela numa chamada só, conta de pé nas quatro leituras, nada de `erase`/`uninstall`/`xcodebuild test` no `B91C8DEF` |
| G5 — registro | 9 | índice, linha do tempo, guardas citadas palavra por palavra, o que não fiz e por quê |

**O que falta, com dono:** a **leitura de mérito** das quatro saídas — se a
meia-recusa da Q3 e a mudez da Q4 caíram de fato. **A contagem mecânica não
responde isso**: ela mostra uma única mudança (a palavra do autor, O.1) e três
quedas de que duas são régua. **Quem separa é o revisor.**
