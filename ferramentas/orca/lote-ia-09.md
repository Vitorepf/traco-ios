# LOTE-IA-09 — as três operações numa janela só, com um binário só

**Papel:** MEDIDOR. Não conserto e não julgo. O que segue são **as saídas**; a
leitura é dos revisores.

**Worker:** LOTE. **Branch:** `Vitorepf/lote-ia-09` (não mesclado).
**Data:** 09/09/2026.

---

## 1. O binário: um só, e ele é este

### 1.1 O que foi mesclado, e o que colidiu

`Vitorepf/lote-ia-09` = `main` + `Vitorepf/volta-q3-notas` + `Vitorepf/volta-q4-instigar`.

| passo | commit | conflito |
|---|---|---|
| `main` (3123140, Merge B2) | fast-forward | nenhum |
| Q3 (`2a06314`) | merge `5e15911` | **`SPEC.md`** e **`ferramentas/orca/LETRAS-ADR.md`** |
| Q4 (`aec62d4`) | merge `edb4dad` | **`SPEC.md`** |

**Os conflitos foram todos de DOCUMENTO, nenhum de código.** O aviso da Q3 sobre
`AvaliacaoIA.swift` **não se materializou**: a Q4 não tocou nesse arquivo, e
`Traco/Analise/Sabia.swift` — o único arquivo de produção que as duas voltas
tocam — **auto-mesclou sem conflito** (a Q3 mexe no caminho de
`responderNasNotas`, a Q4 em `montarInstigar`/`montarContrapor`).

**Como resolvi:**

- `SPEC.md` (as duas colisões): **as duas ADRs ficam, na ordem `main` → Q3 → Q4**.
  Era um conflito de ponto de inserção — a B2 (09q), a Q3 (09h) e a Q4 (09i)
  acrescentam ADR no mesmo fim de arquivo. Nenhuma linha foi descartada; só
  acrescentei a linha em branco entre blocos.
- `ferramentas/orca/LETRAS-ADR.md`: a linha da letra `09i` existia dos dois lados
  com estado diferente — `main` dizia *"reservada, volta viva"*, a Q3 dizia
  *"reservada"*. **Ficou a de `main`** (mais recente e mais informativa).

### 1.2 A suíte integral, no `34CC3F94` (teste 3)

```
$ ferramentas/orca/com-trava.sh xcodebuild test -scheme Traco \
    -destination 'platform=iOS Simulator,id=34CC3F94-FDB5-4575-A4F5-80271829A18B' \
    -parallel-testing-enabled NO -derivedDataPath /tmp/dd-lote-ia-09
✔ Test run with 1015 tests in 163 suites passed after 89.235 seconds.
** TEST SUCCEEDED **
```

**1015 = 1003 (log da Q3) + 12 da B2/Q4 que entraram pela mescla.**
`grep -c ' warning: '` no log: **1**, e é o herdado de sempre —
`Traco/Notas/NotasView.swift:806`, `'+' was deprecated in iOS 26.0`. Nenhuma volta
desta mescla toca esse arquivo.

### 1.3 O sha256 do binário que foi para o aparelho da conta

Produto: `/tmp/dd-lote-ia-09/Build/Products/Debug-iphonesimulator/Traco.app`

| o quê | sha256 |
|---|---|
| `Traco.app/Traco` (executável) | `e9983ddb5a0f6d91b20c42e38b801eb889aac85112b56bd4da946830a5a96e71` |
| `Traco.app/Traco.debug.dylib` (onde mora o código) | `1da1534e45540ccef20c6bd8975fbd20cf05151ab762f0b14e439d5e36c131b3` |
| a árvore inteira do `.app` (sha256 dos sha256 ordenados) | `4b5c3fe848a13209703ee1e4208d9776b6dd6639f6fb1abc2068b822ca65a8d1` |

**Prova de que os dois consertos estão DENTRO deste binário**, e não só no
branch — contagem de símbolos em `Traco.debug.dylib`:

```
semRotulos            12    (Q3)
escreveuRotuloInterno 16    (Q3)
montarInstigar         8    (Q4)
montarContrapor        6    (Q4)
```

---
## 2. A janela: uma só, no `B91C8DEF` (aparelho da CONTA)

**Toda a sequência correu DENTRO de UMA chamada de `ferramentas/orca/com-trava.sh`**
— fumaça, instalação, as três fixtures e a fumaça final. A primeira linha do log
é 22:18:15Z e a última 22:28:42Z: **10 min 27 s de janela**, uma trava só,
tomada antes disso e solta depois. Declarado.

O script da janela está versionado como
`ferramentas/orca/lote-ia-09-janela.sh`; o log de parede, como
`prova/lote09-janela.log`.

### 2.1 A linha do tempo, com hora (UTC)

| hora | o que |
|---|---|
| 22:18:15Z | trava tomada; binário de antes = `934d9b7f…` |
| 22:18:16Z | **fumaça 1 (ANTES do install)** — `contaGrokLigada=true`, **12 modelos** |
| 22:18:17Z | **INSTALL — a única** (`simctl install`, exit 0) |
| 22:18:24Z | **fumaça 2 (DEPOIS do install)** — `contaGrokLigada=true`, **12 modelos** |
| 22:18:26Z → 22:21:11Z | `responderNasNotas` (Q3), 21 execuções |
| 22:21:13Z → 22:25:58Z | `instigar` + `contrapor` (Q4), 36 execuções |
| 22:25:59Z → 22:28:39Z | `responder` (Q2-F, a quarta e opcional), 19 execuções |
| 22:28:41Z | **fumaça 3 (FIM)** — `contaGrokLigada=true`, **12 modelos** |
| 22:28:42Z | janela encerrada, trava solta |

(As horas são as do `prova/lote09-janela.log`, colado inteiro no arquivo.)

### 2.2 A conta NÃO caiu — as três leituras coladas

```
lote09-fumaca-1-antes        2026-09-09T22:18:16Z  contaGrokLigada=true  modelos=12
lote09-fumaca-2-pos-install  2026-09-09T22:18:24Z  contaGrokLigada=true  modelos=12
lote09-fumaca-3-fim          2026-09-09T22:28:41Z  contaGrokLigada=true  modelos=12
```

Os 12 modelos da fumaça final, na íntegra:

```
grok-4.20-0309-non-reasoning, grok-4.20-0309-reasoning, grok-4.20-multi-agent-0309,
grok-4.3, grok-4.5, grok-4.6, grok-build-0.1, grok-imagine-image,
grok-imagine-image-2.0, grok-imagine-image-quality, grok-imagine-video,
grok-imagine-video-1.5
```

**Isto contradiz a lei escrita na ESTEIRA** ("o INSTALL POR CIMA também derruba a
conta"). No `B91C8DEF`, em 09/09 22:18Z, o install por cima **não derrubou nada**:
12 modelos antes, 12 depois, 12 no fim. Registro como fato medido, não como
revisão da lei — quem revoga lei é o dono.

### 2.3 A instalação: uma, e é esta

```
[22:18:15Z] binário instalado ANTES:  934d9b7f5d73e538fff5002381ad42e0919820f0e32764bbc1f13e0c506e3484
[22:18:17Z] INSTALL (única): /tmp/dd-lote-ia-09/Build/Products/Debug-iphonesimulator/Traco.app
            sha256(exec) = e9983ddb5a0f6d91b20c42e38b801eb889aac85112b56bd4da946830a5a96e71
install exit=0
[22:18:22Z] binário instalado DEPOIS: e9983ddb5a0f6d91b20c42e38b801eb889aac85112b56bd4da946830a5a96e71
```

Conferido de novo **depois de fechada a janela**: o `Traco.app` no `B91C8DEF`
continua `e9983ddb…`. **Uma instalação, nenhuma outra** — as três fixtures
correram por `simctl launch --terminate-running-process` com
`SIMCTL_CHILD_TRACO_AVALIAR_IA` e `SIMCTL_CHILD_TRACO_AVALIAR_LIBERAR`, sem
tocar no binário entre elas.

---

## 3. O ÍNDICE das saídas

Todos os JSONL estão inteiros em `prova/`, sem corte. Toda corrida fechou com
`{"evento":"fim"}` gravado.

| arquivo | operação(ões) | execuções | erros de transporte | fixture (sha256) | corrida |
|---|---|---|---|---|---|
| `prova/lote09-fumaca-1-antes.jsonl` | `modelosGrok` | 1 | 0 | `q2-fumaca.json` `ab4c3857…` | `64DB0251…` |
| `prova/lote09-fumaca-2-pos-install.jsonl` | `modelosGrok` | 1 | 0 | `q2-fumaca.json` `ab4c3857…` | `E0918E18…` |
| `prova/lote09-responder-nas-notas.jsonl` | **`responderNasNotas`** | **21** (7 casos × 3) | **0** | `q3-responder-nas-notas.json` `b0fc69f9…` | `B08D1B09…` |
| `prova/lote09-instigar-contrapor.jsonl` | **`instigar` + `contrapor`** | **36** (18 + 18) | **0** | `q4-instigar-contrapor-casos.json` `ed9267c1…` | `380D0885…` |
| `prova/lote09-responder.jsonl` | **`responder`** (+1 `modelosGrok`) | **19** (18 + 1) | **0** | `q2f-casos.json` `135d6a71…` | `BDB57BDB…` |
| `prova/lote09-fumaca-3-fim.jsonl` | `modelosGrok` | 1 | 0 | `q2-fumaca.json` `ab4c3857…` | `25CCF03B…` |

**Total: 76 execuções de operação medida, 0 erro de transporte.**

- **Erro de transporte** aqui = campo `erro` no caso, **ou** qualquer entrada de
  `chamadasGrok` com `statusHTTP != 200` ou `erroDaAPI`. Contei os dois. Zero
  em 76.
- **Todo caso alcançou o provedor**, exceto o `modelosGrok` da `q2f-casos.json`,
  que por natureza não é chamada de conversa (é o endpoint de modelos).
- **Sim, rodei a quarta (opcional).** `responder` pela fixture da Q2-F
  (`q2f-casos.json`, 19 execuções) entrou no MESMO binário e na MESMA janela,
  logo depois da Q4. Declarado.

### 3.1 Condições registradas em toda linha

Em **todas as 76** execuções: `contaGrokLigada=true`,
`motoresDesligados=false`, `modeloConfigurado=grok-4.3`, e
`operacoesLiberadasParaAvaliacao` exatamente a que cada corrida pedia
(`responderNasNotas` / `instigar,contrapor` / `responder`).

Tempo por execução: `responderNasNotas` média 7,87 s (máx 15,09 s);
`instigar`+`contrapor` média 7,92 s (máx 15,46 s); `responder` média 8,41 s
(máx 13,05 s).

---

## 4. OBSERVAÇÕES — separadas dos números, e NÃO são veredito

Eu meço; quem julga são os revisores. O que segue são fatos estruturais que
notei ao conferir que as saídas existem, **sem nota e sem leitura de mérito**.

**O.1 — O binário que estava no aparelho estava configurado em `grok-4.6`; o meu
mede em `grok-4.3`.** A fumaça 1 (binário antigo) registrou
`modeloConfigurado=grok-4.6`; a fumaça 2 em diante, `grok-4.3`. A causa é do
código, não do aparelho: `Traco/Analise/Grok.swift:87` fixa
`let padrao = "grok-4.3"`, e o binário anterior era um candidato da Q2-E/Q2-F.
**Consequência para quem for ler:** este lote mediu as três operações no
**padrão da produção** (`grok-4.3`) — que na medida da Q2-F foi o **pior** dos
três que servem a requisição (4.3 = 15/18, 4.5 = 17/18, 4.6 = 16/18). Não é
nota; é a condição em que a medida foi feita.

**O.2 — `responderNasNotas` (21 execuções).** Nenhuma saída de texto vazio.
`escreveuRotuloInterno` veio `false` nas 21. Nenhum texto final casa com
`\bN\d+T\d+\b` (o padrão dos rótulos internos) nas 21. Um único caso terminou
sem fonte citada nas 3 repetições — `q3-sem-lastro-nenhum-continua-honesto`,
que é o caso desenhado sem lastro.

**O.3 — `instigar` (18 execuções).** Nenhuma lista vazia. Quantidade de
perguntas por execução: 4 perguntas em 13, 5 em 3, 3 em 2.

**O.4 — `contrapor` (18 execuções).** Campo `contra` preenchido nas 18.
`outroCampo` veio em branco em 2; `foraDaLista` em branco em 2. O branco em
`outroCampo` é explicitamente permitido pelo conserto da Q4 ("o exemplo de outro
campo pode ficar em branco"); o branco em `foraDaLista` eu **não sei** se é, e
por isso está aqui como observação e não como defeito.

**O.5 — `responder` (18 execuções).** Nenhuma saída vazia.

**Nada foi consertado.** Nenhum dos três consertos precisou de remendo para
rodar: as três fixtures carregaram, validaram e correram na primeira tentativa.

---

## 5. Instrumento, e o que foi deixado como estava

- **`34CC3F94` (teste 3), aparelho de trabalho:** **encontrei-o LIGADO e não o
  liguei** — logo, **deixei ligado**, como manda a ordem. Nele correu **só a
  suíte** (`xcodebuild test`, `-parallel-testing-enabled NO`, via `com-trava.sh`).
- **`B91C8DEF` (teste 2), aparelho da conta:** a janela inteira. **Nenhum
  `erase`, `clearState`, `uninstall` nem `xcodebuild test`.** Uma instalação.
- Nenhum terceiro simulador foi ligado.
- **Trava:** a suíte e a janela passaram por `ferramentas/orca/com-trava.sh`,
  cada uma numa chamada só.
- **Voz, VoiceOver e iPad:** nada disso foi usado, acionado ou tocado.

### 5.1 Um limite do instrumento, achado nesta volta e declarado

`com-trava.sh` reclama a trava de terceiros aos **30 min mesmo com o dono vivo**
(a segunda guarda, `find -mmin +30`, não olha o PID). Uma janela como esta —
que por desenho é UMA chamada longa — pode ser roubada por baixo. Enquanto a
minha sequência corria, mantive o `mtime` da trava fresco com um `touch` a cada
60 s **de dentro do meu script**, que morre quando o script morre (a guarda de
PID morto continua valendo). Está nas 4 linhas do topo de
`ferramentas/orca/lote-ia-09-janela.sh`. **Não toquei em `com-trava.sh`.**
Na prática a janela levou 10 min 30 s e o risco não se materializou.
**Dívida nomeada, dono: orquestrador** — decidir se a guarda dos 30 min passa a
olhar o PID, agora que a lei manda sequências inteiras numa chamada só.

---

## 6. Scorecard (preenchido por mim; a nota final é do revisor independente)

| dimensão | nota | por quê |
|---|---|---|
| G0 — fronteira de IA | — | não se aplica: esta volta não decide nada de IA, mede |
| G1 — mérito da entrega | 9 | as três operações medidas num binário só, numa janela só, 76 execuções, 0 erro de transporte |
| G2 — prova | 9 | JSONL inteiros em `prova/`, três fumaças com hora, sha256 do binário e das fixtures, log de parede versionado |
| G3 — honestidade do estado | 9 | o que não medi está dito; observações separadas dos números; o limite da trava declarado com dívida e dono |
| G4 — instrumento | 9 | um aparelho por papel, uma instalação, trava numa chamada só, `34CC3F94` deixado como achado |
| G5 — registro | 9 | índice, linha do tempo e conflitos de mescla nomeados um a um |

**O que falta, com dono:** a **leitura** dos três JSONL — mérito caso a caso das
três operações — é dos revisores em paralelo, por ordem do dono. Eu não a fiz e
não devo fazer.
