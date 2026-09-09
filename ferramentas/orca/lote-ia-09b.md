# LOTE-IA-09b — as mesmas duas fixtures em `grok-4.5` e `grok-4.6`, uma janela só

**Papel:** MEDIDOR. **Não conserto e não julgo.** O que segue são as saídas e o
que se CONTA nelas. A leitura de mérito é dos revisores.

**Worker:** LOTE-2. **Branch:** `Vitorepf/lote-ia-09` (não mesclado).
**Data:** 09/09/2026. **Aparelho:** `B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9`
(iPhone 17 Pro, teste 2 — o da CONTA), **e nenhum outro**.

---

## 1. O binário: o mesmo, e NÃO foi instalado

A primeira coisa que a janela fez foi conferir o `sha256` do que já estava no
aparelho. **Bateu — logo, não instalei.**

```
[2026-09-09T23:14:47Z] binario instalado: e9983ddb5a0f6d91b20c42e38b801eb889aac85112b56bd4da946830a5a96e71
[2026-09-09T23:14:47Z] sha256 BATE — NAO instalo
```

| o quê | sha256 | esperado |
|---|---|---|
| `Traco.app/Traco` (executável) | `e9983ddb5a0f6d91b20c42e38b801eb889aac85112b56bd4da946830a5a96e71` | ✅ bate |
| `Traco.app/Traco.debug.dylib` (onde mora o código) | `1da1534e45540ccef20c6bd8975fbd20cf05151ab762f0b14e439d5e36c131b3` | ✅ o do LOTE |

**Conferido de novo às 23:35:50Z, depois de fechada a janela: os dois continuam
idênticos.** Nenhum `install`, `erase`, `clearState`, `uninstall` ou
`xcodebuild test` tocou o `B91C8DEF`. A janela aborta com `exit 2` se o `sha256`
não bater — a guarda está no script, não na minha memória.

**As fixtures também são as mesmas do LOTE**, byte a byte:

| fixture | sha256 | igual à do LOTE? |
|---|---|---|
| `prova/q3-responder-nas-notas.json` | `b0fc69f9e7ba4ec5d5715d073f08515c3840058b4dce08bd770b932c4adcac01` | ✅ |
| `prova/q4-instigar-contrapor-casos.json` | `ed9267c19b26dc61ea2247b3b00e3cc862bf9d7cf9f535786b312811c7f1e3be` | ✅ |
| `prova/q2-fumaca.json` | `ab4c3857ea8f68ea4a2c867ef93049acdc6613b4b2c023da4acfe61f130020fa` | ✅ |

---

## 2. A janela: UMA chamada de `com-trava.sh`, 18 min 48 s

**Toda a sequência correu dentro de UMA chamada de
`ferramentas/orca/com-trava.sh`** — conferência do `sha256`, as três fumaças e
as quatro corridas. Primeira linha 23:14:47Z, última 23:33:35Z. A trava foi
tomada antes e solta depois; conferi que o diretório `/tmp/traco-instrumento.lock`
sumiu ao fim. **Declarado.**

O script está versionado em `ferramentas/orca/lote-ia-09b-janela.sh`; o log de
parede, em `prova/lote09b-janela.log`.

### 2.1 A linha do tempo, com hora (UTC)

| hora | o que | modelo |
|---|---|---|
| 23:14:47Z | trava tomada; `sha256` conferido — **não instalo** | — |
| 23:14:49Z | **fumaça 1 (ANTES)** — `contaGrokLigada=true`, **12 modelos** | `grok-4.3` |
| 23:14:51Z → 23:17:04Z | `responderNasNotas` — 21 execuções | **`grok-4.5`** |
| 23:17:06Z → 23:22:02Z | `instigar` + `contrapor` — 36 execuções | **`grok-4.5`** |
| 23:22:04Z | **fumaça 2 (ENTRE OS BLOCOS)** — `contaGrokLigada=true`, **12 modelos** | `grok-4.3` |
| 23:22:06Z → 23:25:48Z | `responderNasNotas` — 21 execuções | **`grok-4.6`** |
| 23:25:50Z → 23:33:32Z | `instigar` + `contrapor` — 36 execuções | **`grok-4.6`** |
| 23:33:34Z | **fumaça 3 (FIM)** — `contaGrokLigada=true`, **12 modelos** | `grok-4.3` |
| 23:33:35Z | janela encerrada, trava solta | — |

Rodei o `grok-4.5` PRIMEIRO de propósito: se a janela esticasse, o corte cairia
no `4.6` e não nas repetições, como manda o brief. Não foi preciso cortar nada.

### 2.2 A conta NÃO caiu — as três leituras coladas

```
lote09b-fumaca-1-antes   2026-09-09T23:14:49Z  contaGrokLigada=true  modelos=12
lote09b-fumaca-2-entre   2026-09-09T23:22:04Z  contaGrokLigada=true  modelos=12
lote09b-fumaca-3-fim     2026-09-09T23:33:34Z  contaGrokLigada=true  modelos=12
```

Nenhum comando derrubou a conta. Não houve nada a escalar.

As fumaças rodam **sem** `TRACO_AVALIAR_MODELO` (o campo `modeloConfigurado`
delas registra o padrão de produção, `grok-4.3`): elas medem a CONTA e a lista de
modelos, que não dependem do modelo escolhido.

### 2.3 A liberação usada — e sim, `responderNasNotas` precisa dela

Confirmado no código: `Traco/Analise/Politica.swift:106` põe `responderNasNotas`
em `.indisponivelPorQualidade`, e `provedor(_:)` só devolve `.grok` para essa
regra quando `liberadasParaAvaliacao` contém a operação. **Sem liberar, a rota
bate em `nil` antes de alcançar o provedor.**

| corrida | `TRACO_AVALIAR_LIBERAR` | conferido no JSONL (`operacoesLiberadasParaAvaliacao`) |
|---|---|---|
| as duas de `q3` | `responderNasNotas` | `["responderNasNotas"]` em **todas as 42** |
| as duas de `q4` | `instigar,contrapor` | `["contrapor","instigar"]` em **todas as 72** |
| as três fumaças | *(vazio)* | `[]` |

---

## 3. UMA alavanca só — e a prova de que foi só ela

A lei da Q2-F é que a comparação mexa **em uma alavanca**. Variei
`TRACO_AVALIAR_MODELO` e nada mais; o resto é o mesmo binário, a mesma fixture,
o mesmo aparelho, a mesma janela. **A prova está gravada em cada uma das 114
execuções**, não na minha palavra:

| o que ficou fixo | como se confere no JSONL | valor medido |
|---|---|---|
| esforço | `chamadasGrok[].esforco` | **`low` em 114 de 114** |
| binário | `sha256` antes e depois | `e9983ddb…` nas duas leituras |
| fixture | `fixtureSHA256` no `inicio` | `b0fc69f9…` / `ed9267c1…` |
| aparelho | um só ligado por mim | `B91C8DEF` |
| conta e motores | `contaGrokLigada` / `motoresDesligados` | `true` / `false` em 114 de 114 |
| **modelo (a alavanca)** | `modeloConfigurado` | uniforme por corrida, e `modeloSolicitado == modeloRespondido` em todas |

Teto e temperatura não foram tocados: não há chave de ambiente para eles no
binário (só `TRACO_AVALIAR_MODELO`, `TRACO_AVALIAR_SEM_ESFORCO`,
`TRACO_AVALIAR_LIBERAR` e `TRACO_AVALIAR_IA` existem), e
`TRACO_AVALIAR_SEM_ESFORCO` **não foi exportado** — daí o `low` uniforme.

---

## 4. O ÍNDICE das saídas

Todos os JSONL estão inteiros em `prova/`, sem corte, e **todos fecharam com
`{"evento":"fim"}` gravado**.

| arquivo | operação(ões) | modelo | execuções | HTTP ≠ 200 / erro da API | corrida |
|---|---|---|---:|---:|---|
| `prova/lote09b-fumaca-1-antes.jsonl` | `modelosGrok` | *(padrão)* | 1 | 0 | `AF473753…` |
| `prova/lote09b-q3-grok-4.5.jsonl` | **`responderNasNotas`** | **`grok-4.5`** | **21** | **0** | `48EBC723…` |
| `prova/lote09b-q4-grok-4.5.jsonl` | **`instigar` + `contrapor`** | **`grok-4.5`** | **36** | **0** | `80AD7977…` |
| `prova/lote09b-fumaca-2-entre.jsonl` | `modelosGrok` | *(padrão)* | 1 | 0 | `D6384193…` |
| `prova/lote09b-q3-grok-4.6.jsonl` | **`responderNasNotas`** | **`grok-4.6`** | **21** | **0** | `FBD5EB29…` |
| `prova/lote09b-q4-grok-4.6.jsonl` | **`instigar` + `contrapor`** | **`grok-4.6`** | **36** | **0** | `420D4858…` |
| `prova/lote09b-fumaca-3-fim.jsonl` | `modelosGrok` | *(padrão)* | 1 | 0 | `83FA7A86…` |

**Total: 114 execuções de operação medida, 0 erro de transporte.**
Somadas às 76 do LOTE: **190 execuções nas mesmas duas fixtures**.

**Uma execução voltou sem retorno, e ela NÃO é erro de transporte.**
`grok-4.5`, `q4-contrapor-razao-ja-sustentada`, repetição 1: o HTTP foi **200**,
o desfecho foi *"conteúdo completo"*, 122 tokens de raciocínio — e ainda assim o
app registrou `Falha.semRetorno` e `saida: null`. **O provedor respondeu; o que
não chegou foi o retorno da operação.** Registro a distinção porque o LOTE
anterior contava as duas coisas na mesma coluna.

---

## 5. A TABELA — operação × modelo × casos passados

### 5.1 O que "passou" quer dizer aqui, e o que ele NÃO quer dizer

**Perguntei ao orquestrador e o `ask` estourou os 900 s sem resposta**
(`thread msg_bb5cfbdc32c0`), então decido dentro da fronteira do meu papel.

"Passou" nesta tabela é **só o que uma regex decide**, e cada guarda é **frase
da própria fixture**, não critério meu:

| guarda | de onde vem, palavra por palavra | onde vale |
|---|---|---|
| **G1** | *"REPROVA: `escreveuRotuloInterno` = true"* | 5 dos 7 casos de `q3` |
| **G2** | *"O texto entregue ao autor NÃO contém N1T1, N2T1 nem qualquer rótulo"* / *"REPROVA: citar N9T9"* → regex `\bN\d+T\d+\b` | `q3` |
| **G3** | *"De 2 a 5 perguntas; retorno vazio reprova"* | `instigar` |
| **G4** | *"Nenhuma pergunta cita degrau… 'movimento básico' ou 'passo que se pula'"* | `instigar`, **menos** o caso isento (§5.3) |
| **G5** | *"Os três campos vazios reprovam"* / *"contra e foraDaLista vazios ao mesmo tempo reprovam"* / *"Retorno vazio reprova"* | `contrapor` |

O conferidor está versionado em `ferramentas/orca/lote-ia-09b-guardas.py` — a
contagem se refaz, não se acredita.

> **ISTO NÃO É VEREDITO.** A maior parte dos requisitos das duas fixtures é
> prosa que só uma LEITURA decide — *"soma os 520 euros e cita as duas notas"*,
> *"não vira conselho médico"*, *"as perguntas do degrau 4 são visivelmente
> diferentes das do degrau 0"*. **Nada disso está contado abaixo.** A Q2-F
> chegou aos seus 15/17/16 de 18 por leitura humana do revisor, e é essa leitura
> que responde as duas perguntas da volta — não esta tabela.

### 5.2 A tabela

Execuções que passaram nas guardas mecânicas. O `grok-4.3` é o LOTE anterior,
medido com **o mesmo binário e as mesmas fixtures**, passado pelo **mesmo
conferidor** — logo, comparável.

| operação | `grok-4.3` (LOTE) | `grok-4.5` | `grok-4.6` |
|---|---:|---:|---:|
| `responderNasNotas` | 21 / 21 | 21 / 21 | 21 / 21 |
| `instigar` | 18 / 18 | 18 / 18 | 18 / 18 |
| `contrapor` | 18 / 18 | **17 / 18** | 18 / 18 |
| **total** | **57 / 57** | **56 / 57** | **57 / 57** |

O único descumprimento mecânico em 171 execuções é o `semRetorno` do §4.

**O que esta tabela mede sobre os três modelos: nada que os separe.** As guardas
mecânicas — as que os dois revisores citaram como defeito estrutural: rótulo
interno vazado, jargão do app na pergunta, campo em branco — **não distinguem os
três modelos porque nenhum dos três as viola**. Quem separar os modelos vai
separá-los na prosa, não aqui.

### 5.3 Um caso ficou FORA da guarda, e por quê

`q4-instigar-o-autor-escreve-metodo` é o caso em que **"método" e "degrau" são
palavras DO AUTOR**, e o requisito da fixture é o inverso da proibição:

> *"A guarda é relativa ao texto do autor e não pode calar a pergunta que usa as
> palavras dele. Pelo menos uma pergunta fala do método de estudo dele ou do
> segundo degrau dele, sem virar pergunta sobre o app."*

Minha primeira passada aplicou a regex de jargão neste caso e **reprovou o
`grok-4.5` duas vezes por acertar**. Corrigi o escopo. Depois tentei a checagem
inversa — exigir a palavra literal — e ela reprovou o `grok-4.6` 3 de 3 por
perguntas que falam do estudo dele **sem repetir as palavras**. Isso é leitura,
não contagem, então **o caso saiu da tabela** e vira observação:

| modelo | repetições em que a palavra do autor (`método`/`degrau`) aparece no retorno |
|---|---|
| `grok-4.3` | 0 de 3 |
| `grok-4.5` | **2 de 3** |
| `grok-4.6` | 0 de 3 |

**Se este requisito passa ou não é dos revisores.** O que eu conto é que só o
`4.5` devolve as palavras dele.

---

## 6. OBSERVAÇÕES — separadas dos números, e NÃO são veredito

**O.1 — Quantas perguntas o `instigar` devolve muda muito com o modelo.**
Nenhum dos três saiu da faixa de 2 a 5.

| modelo | 3 perguntas | 4 | 5 |
|---|---:|---:|---:|
| `grok-4.3` | 2 | 13 | 3 |
| `grok-4.5` | 0 | 1 | **17** |
| `grok-4.6` | 0 | **14** | 4 |

**O.2 — Campos em branco no `contrapor`.** O `grok-4.3` deixou `outroCampo` em
branco 2 vezes e `foraDaLista` 2 vezes; o `grok-4.6`, **nenhuma**; o `grok-4.5`
tem 1 branco em cada campo, e **os três são a mesma execução** — a do
`semRetorno`, cuja `saida` é `null`. Fora dela, o `4.5` não deixou campo em
branco. Lembro que a Q4 permite explicitamente `outroCampo` em branco; sobre
`foraDaLista` em branco eu continuo **não sabendo** se é permitido.

**O.3 — Nenhum rótulo interno vazou, em modelo nenhum.** `escreveuRotuloInterno`
veio `false` nas 63 execuções de `responderNasNotas` dos três modelos, e nenhum
texto final casa com `\bN\d+T\d+\b`. Os dois casos que a fixture montou para
reexecutar o vazamento de 08/09 não vazaram em nenhum dos três.

**O.4 — Um único caso termina sem fonte citada, e é o mesmo nos três modelos:**
`q3-sem-lastro-nenhum-continua-honesto`, 3 de 3 em cada — o caso desenhado sem
lastro. Nos outros 6 casos, os três modelos citam fonte em todas as repetições.

**O.5 — O `grok-4.6` é o mais lento dos três, com folga; o `grok-4.5` é o mais
rápido.** Média de segundos por execução, mesmo esforço (`low`):

| operação | `grok-4.3` | `grok-4.5` | `grok-4.6` |
|---|---:|---:|---:|
| `responderNasNotas` | 7,87 s | **6,34 s** | 10,55 s |
| `instigar` | 6,35 s | **6,62 s** | 10,13 s |
| `contrapor` | 9,48 s | 9,84 s | **15,50 s** |

Os tokens de raciocínio andam junto: média 785/524/861 no `4.3`, **193–276 no
`4.5`** e 422–607 no `4.6`. O `4.5` entrega o mesmo trabalho com **menos de um
terço** do raciocínio do `4.3` — e é o que devolve mais perguntas (O.1).
**Latência não é qualidade**, e o teto de tempo da rota é outro assunto; ponho
aqui porque é número, não impressão.

**Nada foi consertado, nada foi julgado.** As quatro corridas carregaram,
validaram e correram na primeira tentativa.

---

## 7. Instrumento, e o que foi deixado como estava

- **`B91C8DEF` (teste 2), o aparelho da CONTA:** a janela inteira. **Zero
  instalações** (o `sha256` bateu), zero `erase`, `clearState`, `uninstall` ou
  `xcodebuild test`. Conta ligada nas três fumaças.
- **`34CC3F94` (teste 3), o aparelho de trabalho: NÃO foi usado.** Esta volta não
  compilou e não rodou suíte — é o mesmo binário do LOTE. **Encontrei-o ligado e
  não o liguei, logo deixei ligado**, como manda a ordem. Nenhum terceiro
  simulador foi ligado.
- **Trava:** uma chamada só de `com-trava.sh`, do começo ao fim. Declarado.
- **Voz, VoiceOver e iPad:** nada disso foi usado, acionado ou tocado.
- Nada de orientação, tamanho de letra ou Movimento Reduzido foi alterado — esta
  volta não tem tela, só JSONL.

### 7.1 A dívida da trava continua de pé

A guarda dos 30 min de `com-trava.sh` **não olha o PID**, e esta janela é UMA
chamada longa por desenho — 18 min 48 s desta vez, e ela pode crescer com
modelos mais lentos. Mantive o `mtime` fresco com um `touch` a cada 60 s **de
dentro do meu script**, que morre com ele. **Não toquei em `com-trava.sh`.**
É a mesma dívida que o LOTE nomeou, e ela **não se fechou**: dono, orquestrador.

### 7.2 Um limite do que eu medi

**Não medi `responder` (`q2f-casos.json`) nesta volta** — o brief pediu duas
fixtures e eu rodei as duas. Quem quiser as três operações da Q2-F nos três
modelos tem `responder` medido só em `grok-4.3` (LOTE) e a leitura da Q2-F.

---

## 8. Scorecard (preenchido por mim; a nota final é do revisor independente)

| dimensão | nota | por quê |
|---|---|---|
| G0 — fronteira de IA | — | não se aplica: esta volta não decide nada de IA, mede |
| G1 — mérito da entrega | 9 | duas fixtures × dois modelos, 114 execuções, 0 erro de transporte, uma alavanca só, sem instalar |
| G2 — prova | 9 | JSONL inteiros, três fumaças com hora, `sha256` do binário conferido antes e depois, conferidor versionado |
| G3 — honestidade do estado | 9 | o falso positivo da minha primeira guarda está no relatório; o `semRetorno` está separado do erro de transporte; o que não é contável está dito |
| G4 — instrumento | 9 | um aparelho, zero instalações, trava numa chamada só, `34CC3F94` intocado |
| G5 — registro | 9 | índice, linha do tempo, guardas citadas palavra por palavra da fixture |

**O que falta, com dono:** a **leitura de mérito** dos quatro JSONL — se os
consertos da Q3 e da Q4 passam em `grok-4.5` e `grok-4.6`, e se o `4.5` vence
fora da rota de `responder`. **As guardas mecânicas não separam os três
modelos**; quem separa é o revisor, e essa leitura é dele, não minha.
