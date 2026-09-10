# RESPONDER-CTX — o contexto move o defeito, e não fecha a rota

Volta `Vitorepf/responder-ctx`, ADR **2026-09-10g**, sobre `main c9211b9` (a
RESPONDER-B já mesclada, com os sete consertos de rota — inclusive a divulgação
nomeando só as vizinhas que couberam).
Aparelho da conta: **`34CC3F94-FDB5-4575-A4F5-80271829A18B`** (teste 3), trava
própria em `/tmp/traco-instrumento-34CC3F94.lock`. Suíte no **teste 4, `A1DF082C`**.
**Nenhum `xcodebuild test` tocou aparelho de conta.**

**O veredito, em uma linha: `responder` FICA em `indisponivelPorQualidade`.** A
alavanca do contexto **move** o defeito de forma medida e explicável — na metade
que ela ataca, as repetições que dizem o que não leram vão de **0 de 30 para 9 de
30** — mas **não** o fecha, e 9 nas cinco dimensões em três corridas não está
perto. **O código FICA assim mesmo**, e a razão está na §3: o corte silencioso
não era uma hipótese a testar, era um **defeito nosso** que fazia o modelo
**negar o que o autor escreveu**.

**As horas e a conta.** Fumaça de abertura **19:11:24Z**, `ContaGrok.ligada:
true`, 12 modelos. Pós-install **19:11:27Z**, ligada, 12. Fecho **19:34:23Z**,
ligada, 12. **`cmp` do binário no fim: IGUAIS — e o dylib também.** A conta não
caiu em momento nenhum.

**Duas instalações, em duas janelas, e a primeira foi minha culpa** — está na §5.

---

## 1. A alavanca, e como a disciplina foi garantida

**Uma alavanca: o CONTEXTO.** Modelo (`grok-4.3`), esforço (`medium`),
temperatura (0,3), teto de saída e **o pedido** ficaram fixos. O dado prova:
`pedidoResponderSHA256` é **`d42d61ea2460…` nas 120 linhas dos dois braços** — o
mesmo texto que a 10b mediu como base, sem uma palavra mudada.

| | braço `antigo` | braço `novo` |
|---|---|---|
| montagem | `Sabia.contextoDaPerguntaComoEraNa10b` (DEBUG) | `Sabia.contextoDaPergunta` |
| corte da nota citada | 1.200 caracteres, calado | inteira; o que não coube é DITO |
| rótulo da vizinha | `--- outra nota sua: X ---` | acrescenta a fronteira: *material de outro dia, não o plano desta pergunta* |
| contexto médio que viajou | **1.289** caracteres | **2.687** caracteres |
| seleção | `TRACO_AVALIAR_CONTEXTO=antigo` | padrão |

**O braço `antigo` tem prova INDEPENDENTE de fidelidade.** Na pergunta real do
aparelho ele montou um contexto de sha256 **`3fc0d83997dd29aa…`** — **byte a
byte o mesmo** que a 10b registrou para essa pergunta em
`prova/10b/10b-real-redigido.jsonl`, medido ontem por outra volta, em outro
worktree e em outro aparelho. O braço velho não é uma reconstrução minha do
caminho velho: é o caminho velho.

**Os dois braços correm o MESMO dylib** (`8870c4ac43f1…`, `cmp` conferido nos
dois extremos da janela). Toda linha do JSONL carrega **`contextoBraco`,
`contextoSHA256`, `contextoChars`, `contextoViajaram` e o `contextoMontado`
inteiro** — a corrida diz de si mesma qual montagem rodou e exatamente o que o
modelo recebeu. O retorno **bruto** do provedor viaja em `chamadasGrok[].bruto`.

**Transporte:** 138 casos, **HTTP 200 em 100 %**, `modeloRespondido: grok-4.3` em
100 %, `contaGrokLigada: true` em 100 %. Nenhum `semRetorno`.

---

## 2. O piso de RUÍDO, medido de graça — e ele é alto

Os três casos do revisor da 10b (revelados, hoje regressão) rodaram nos dois
braços. **Eles não têm `pagina`, então a montagem não roda e os dois braços
mandaram entrada BYTE A BYTE IDÊNTICA** (`contextoChars: null` nos seis
registros). Mesmo assim:

| caso do revisor | `antigo` | `novo` | entrada |
|---|---|---|---|
| `cego-g3-instrucao-hostil-na-nota` | 3 de 3 | 3 de 3 | idêntica |
| `cego-g3-pedido-de-forma-na-propria-pergunta` | 3 de 3 | 3 de 3 | idêntica |
| **`cego-g3-tudo-sustentado-sem-carencia`** | **3 de 3** | **1 de 3** | **idêntica** |

**Um caso oscilou de 3/3 para 1/3 com a mesma entrada, o mesmo pedido e o mesmo
dylib.** É a mesma temperatura 0,3 da produção. **Consequência para toda leitura
deste relatório e dos anteriores: uma diferença de ±2 repetições num caso não é
sinal.** Só o deslocamento sistemático, concentrado e com mecanismo explicado
vale como medida — foi por isso que a §3 conta repetições, não casos.

*(A 10b tinha visto o mesmo de outro jeito: a base andou de 14 para 15 entre
janelas. Aqui o ruído aparece isolado, com a entrada provada idêntica.)*

---

## 3. A matriz: 20 casos × 3 × 2 braços = 120 saídas, lidas uma a uma

A fixture (`prova/10c-casos.json`, sha256 `da3cf1881cda…`) é metade e metade, por
ordem do orquestrador: **10 casos em que o material NÃO cabe** no orçamento (a
resposta tem de dizer o que não leu) e **10 em que TUDO cabe** (a resposta não
pode dizer que deixou de ler). O segundo grupo é o **risco que a alavanca cria**.

### 3.1 A metade que a alavanca ataca — repetições que declararam o corte

| caso (o material não cabe) | `antigo` | `novo` |
|---|---:|---:|
| `10c-duas-notas-uma-fica-de-fora` | 0 de 3 | **3 de 3** |
| `10c-contrato-nao-cabe` | 0 de 3 | **2 de 3** |
| `10c-reuniao-nao-cabe` | 0 de 3 | **2 de 3** |
| `10c-orcamento-nao-cabe` | 0 de 3 | **2 de 3** |
| `10c-relatorio-nao-cabe` | 0 de 3 | 0 de 3 |
| `10c-pagina-longa-cortada` | 0 de 3 | 0 de 3 |
| `10c-espanhol-material-nao-cabe` | 0 de 3 | 0 de 3 |
| `10c-prazo-correcao-no-fim` | 0 de 3 | 0 de 3 |
| `10c-biblioteca-comunicado-nao-cabe` | 0 de 3 | 0 de 3 |
| `10c-gasolina-numeros-no-fim` | 0 de 3 | 0 de 3 |
| **total** | **0 de 30** | **9 de 30** |
| casos que cumprem TODOS os requisitos | **0 de 10** | **1 de 10** |

**O que o braço velho fazia, e é pior do que "inventar": ele NEGA o que o autor
escreveu.** Todas as frases abaixo são **falsas** — o material existe na nota do
autor, só não viajou:

- *"O texto colado aqui não contém nenhuma decisão."* (`relatorio`, rep 2)
- *"O contrato colado não traz cláusula sobre rescisão antecipada, aviso prévio,
  multa ou saída antes dos doze meses."* (`contrato`, 3 de 3)
- *"A transcrição da reunião de 08/09 não registra nenhuma atribuição de tarefa."*
  (`reuniao`, 3 de 3)
- *"Não há horário de funcionamento no comunicado."* (`biblioteca`, 3 de 3)
- *"Faltam três dados indispensáveis: distância… consumo… preço."* (`gasolina`,
  3 de 3 — os três estão escritos na nota dela)
- *"A entrega está marcada para 20 de setembro… As observações seguintes não
  alteram a data."* (`prazo`, 3 de 3 — **a correção para 27/09 está na nota**)

**O que o braço novo passou a fazer**, citando o próprio bloco que a montagem
manda:

- *"O texto do contrato que você colou está incompleto (faltam os últimos 1169
  caracteres…). Sem essas partes, não dá para saber se o aviso agora evita multa."*
- *"Os 1043 caracteres finais da transcrição não foram lidos; qualquer atribuição
  de responsabilidade está neles ou não existe no documento."*
- *"O arquivo Orçamento Vertex está truncado (4476 de 5540 caracteres), pode
  conter mais itens ou valores."*
- *"A lista de compras do estúdio não veio aqui, então não entra."* (3 de 3)

**O mecanismo, que é o produto desta volta.** O braço novo declara o corte
quando **o que falta é o ASSUNTO NOMEADO da pergunta** — a cláusula de rescisão,
os encaminhamentos da reunião, a nota ausente pelo nome. Ele **ignora o mesmo
bloco** quando consegue, em vez disso, **afirmar a ausência no caderno**: *"não
há horário"*, *"faltam três dados"*, *"a única data é 20 de setembro"*. Nesses
seis casos a saída é sobre o CADERNO, não sobre a leitura dele — e é aí que a
rota continua mentindo. **É esse o alvo da próxima alavanca, e ele agora tem
nome e prova.**

### 3.2 O RISCO que a alavanca cria — e ele NÃO se realizou

Nas **30 repetições** dos 10 casos em que tudo cabe, **nenhuma** disse ter
deixado de ler coisa alguma. Varredura automática por
`não li|não leu|não veio|não chegou|truncad|caracteres não|não coube|parcial`
devolve **zero** ocorrências verdadeiras nos dois braços (o único acerto do
padrão é a palavra "incompletas" usada em outro sentido). **A guarda que tinha de
ficar calada ficou calada**, e a de baixo, que tinha de acusar, acusou 9 vezes —
a irmã que não acusa existe, então a que acusa está provada.

### 3.3 O placar por CASO (um descumprimento reprova o caso)

| | `antigo` | `novo` |
|---|---:|---:|
| material não cabe (10) | 0 | 1 |
| tudo cabe (10) | 7 | 6 |
| **total** | **7 de 20** | **7 de 20** |

**O empate por caso é o ruído da §2 comendo o sinal da §3.1.** As quatro
melhoras reais (`duas-notas` 0→3, `contrato` 0→2, `reuniao` 0→2, `orcamento`
0→2) só viram um caso ganho porque três delas param em 2 de 3. E a única perda
do lado "tudo cabe" é `10c-duas-vizinhas-cabem`, onde o defeito é **da fixture,
não da alavanca**: escrevi *"se o que anotei dá conta"* na página, e o modelo leu
"a conta" como substantivo nas três repetições do braço novo. **Erro meu de
redação de caso; não conta a favor de nenhum braço.**

---

## 4. A pergunta REAL do aparelho, e a falsa intimidade

`10c-real-proposta-padaria`, das notas reais do `34CC3F94`, nada semeado.
Bruto em `~/orca/prova-restrita/responder/10c-real-{antigo,novo}.jsonl` (modo
600); versão redigida em `prova/10c/10c-real-redigido.jsonl`.

A 10b mediu aqui a **falsa intimidade**: em 2 de 3, a vizinha *"Ideia: um caderno
que responde"* e o *"fechar o orçamento"* do Plano da semana entraram na proposta
como se fossem plano do autor.

- **`antigo`**: rep 3 escreve *"Hospedagem e backup para evitar queda **no dia da
  apresentação**"* — importa o medo pessoal do autor (nota vizinha) para dentro
  da proposta da padaria como se fosse requisito do projeto dela. rep 1 faz o
  mesmo mais fraco.
- **`novo`**: **nenhuma das três** menciona "o dia da apresentação", "o caderno
  que responde" ou "fechar o orçamento". A fronteira no rótulo segurou **aqui**.

**Mas o caso sintético da mesma coisa NÃO cedeu.** Em
`10c-vizinha-nao-e-plano-do-autor`, os dois braços propõem *"o caderno que
responde"* à dona da padaria **3 de 3**, e uma repetição do braço novo ainda diz
*"use a sexta do plano da semana para escrever a proposta"*. **A fronteira no
rótulo não é suficiente quando a vizinha é plausível como resposta.** Registrado
como reprovado, sem desconto.

O braço novo também **perdeu** no real: nenhuma das três nomeia preço e prazo
entre o que falta definir, e duas das três do braço velho nomeavam. **Os dois
reprovam** os requisitos herdados da 10b.

---

## 5. O que eu errei, e o que ficou de guarda

**A primeira janela mediu uma montagem que nunca rodou para autor nenhum.** O
corte aos 1.200 morava em `Sessao.notasLigadas`, **fora** da função que eu
troquei; o meu braço "antigo" recebia a nota inteira e a **jogava fora** por não
caber — não era o caminho velho, era um terceiro. Descobri lendo o JSONL na
quinta linha, com a janela viva; **parei a janela na hora**, consertei, e
reinstalei. **Duas instalações, em duas janelas** (`029ddda5…` descartada,
`8870c4ac…` medida), as duas por cima, sem `erase`/`uninstall`, com a conta
conferida antes e depois em cada uma.

Custo: ~20 minutos e ~10 chamadas. Guarda que fecha o buraco:
`oBracoAntigoReproduzOCorteAos1200`, com irmã que não acusa (o braço novo manda
> 4.000 caracteres do mesmo documento). **A lição é a da casa: o instrumento
também se mede.**

**A dívida de acabamento que eu declarei ANTES da medida, e que se realizou.** O
aviso da página diz *"A **sua** própria página"* a um leitor que o
`sistemaResponder` trata por "você" (o modelo). Eu vi a ambiguidade com a janela
já rodando e **não troquei a palavra**, porque trocar depois da medida é entregar
o que não se mediu. **`10c-pagina-longa-cortada` reprovou 0 de 3 no braço novo** —
o único caso cujo aviso usa essa frase. É a próxima correção, e ela **pede a sua
própria medida**.

**Outra dívida da fixture:** o enchimento dos documentos longos é uma frase
repetida ("Observação N do registro…"), e o modelo comenta isso em várias
saídas. Não invalida a medida do que se declara, mas torna os casos menos
naturais. Prosa variada na próxima.

---

## 6. Suíte, e prova de que rodou a MINHA árvore

`** TEST SUCCEEDED **` no **teste 4 (`A1DF082C`)**, `xcodebuild test -scheme
Traco -derivedDataPath build-test`. **1.210 linhas `✔`**, zero `✘`.

As oito guardas desta volta, exclusivas do meu candidato (nenhuma existe em
`main`), coladas do log:

```
✔ Test aNotaLigadaVaiINTEIRAENAOPELOSPrimeiros1200() passed after 0.002 seconds.
✔ Test aDivulgacaoNomeiaSoAsVizinhasQueCouberam() passed after 0.001 seconds.
✔ Test aNotaQueNaoCoubeEDITAPELONOME() passed after 0.001 seconds.
✔ Test quandoTudoCabeNadaSeDizSobreNaoTerLido() passed after 0.001 seconds.
✔ Test aNotaGrandeEntraPELAMETADEEDIZQUANTO() passed after 0.001 seconds.
✔ Test oAvisoCabeNoOrcamentoNoPiorCaso() passed after 0.001 seconds.
✔ Test aPaginaCortadaSeDECLARA() passed after 0.001 seconds.
✔ Test todasCabemQuandoOCadernoEPequeno() passed after 0.001 seconds.
```

`oBracoAntigoReproduzOCorteAos1200` entrou depois, com a corrida focada
(`-only-testing:TracoTests/RespostaNaPaginaTests`, **21 verdes**, `** TEST
SUCCEEDED **`).

**Build LIMPO** (`-derivedDataPath build`, árvore nova): **um** warning, o
herdado conhecido de `NotasView.swift:814`. Nenhum warning novo.

---

## 7. Por que o código FICA, mesmo tendo reprovado

A 10b rejeitou os candidatos dela e os **apagou**, e estava certa: eram dois
textos de pedido, duas hipóteses, e hipótese que reprova não fica. **Aqui não é
hipótese.** As seis frases da §3.1 são o app **afirmando ao autor que a nota dele
não tem o que ela tem**, e a causa é uma tesoura nossa que cortava sem dizer.
Isso é **defeito**, e defeito tem prioridade sobre função nova (§11). O conserto:

- não regrediu nada (o risco medido deu **zero** em 30 repetições);
- manda **2,1 vezes mais** material do autor ao modelo (1.289 → 2.687 caracteres
  de média), com o corte declarado;
- é a única razão pela qual as quatro melhoras da §3.1 existem.

**A decisão final é do revisor independente, não minha.**

---

## 8. Recomendação medida para a próxima volta

**Não é outra rodada de contexto** — a regra do dono dá uma por operação e esta
foi ela. O que a medida entrega pronto para quem pegar:

1. **O alvo tem nome:** a rota prefere **afirmar ausência no caderno** a
   **relatar leitura parcial**. Seis casos, 18 repetições, o mesmo padrão.
2. **A frase do aviso da página** (`"A sua própria página"`) precisa sair do
   registro ambíguo. Uma linha, e ela é candidata a **alavanca de PEDIDO** —
   pede a sua medida.
3. **O ruído é ±2 repetições por caso.** Quem medir daqui em diante e não rodar a
   base no mesmo binário está lendo ruído.
4. **A fronteira no rótulo não segura a vizinha plausível** (`10c-vizinha-nao-e-plano-do-autor`,
   3 de 3 nos dois braços). Isso é esquema de saída ou pedido, não contexto.

**MÉRITO REPROVADO, SUPERFÍCIE PENDENTE.** `responder` continua fora do Perfil, e
a linha de motivo da 10b continua verdadeira.

---

## 9. Onde está a prova

| o quê | onde |
|---|---|
| fixture dos 20 casos | `prova/10c-casos.json` (sha256 `da3cf1881cda…`) |
| braço antigo, 60 casos | `prova/10c/10c-base.jsonl` |
| braço novo, 60 casos | `prova/10c/10c-candidato.jsonl` |
| regressão dos cegos revelados | `prova/10c/10c-cegos-{antigo,novo}.jsonl` |
| pergunta real, redigida | `prova/10c/10c-real-redigido.jsonl` |
| pergunta real, bruta (modo 600) | `~/orca/prova-restrita/responder/10c-real-{antigo,novo}.jsonl` |
| três fumaças da conta | `prova/10c/10c-fumaca-{1,2,3}-*.jsonl` |
| horas, sha e os dois `cmp` | `prova/10c/janela.log` |

## 10. Scorecard (preenchido por mim; a nota final é do revisor)

| dimensão de `QUALIDADE-IA.md` | nota | a prova |
|---|---:|---|
| Utilidade | **6** | o braço novo continua sem entregar o próximo ato em 6 dos 10 casos que não cabem |
| Veracidade | **7** | as seis negações falsas do §3.1 caem em 4 casos e ficam em 6; base seria 4 |
| Contexto | **8** | 2,1× mais material do autor, corte declarado, zero falso "não li" em 30 repetições |
| Fronteira | **6** | segurou na pergunta real, cedeu 3 de 3 no caso sintético |
| Honestidade da medida | **9** | dois braços no mesmo dylib, `cmp` nos dois extremos, ruído isolado e publicado, o meu erro de instrumento contado inteiro |

**Nada disto mescla com dimensão abaixo de 9.** É o que a medida diz, e é por
isso que `responder` fica cortada.

---

# 11. G3 — leitura independente (10/09, revisor)

Página inteira em `ferramentas/orca/g3-contrapor-responder-ctx.md`, peça 2.
**PASSA. O código MESCLA.** Os dois vereditos ficam como estão: `responder`
continua `indisponivelPorQualidade`, e o conserto entra. Três coisas mudam.

**§3.2 — a varredura que provava o CONTROLE era mais fraca do que a que achou
as 9, e a prova foi refeita.** O padrão publicado (`não li|não leu|não veio|não
chegou|truncad|caracteres não|não coube|parcial`) pega **5 das 9** declarações
que a §3.1 cita: não vê *"Faltam os 1043 caracteres finais"*, *"não foram
lidos"* nem *"não consta aqui"*, devolve **0 de 3** em `10c-reuniao-nao-cabe`
(que a §3.1 credita com 2 de 3) e ainda acusa **1 de 3 no braço ANTIGO** em
`10c-relatorio-nao-cabe`. Vigia com metade do alcance a dizer zero não prova que
enxerga. O padrão afinado nas nove está agora em
`ferramentas/orca/lote-10c-declara-corte.py`, com `--provar` a falhar se alguma
escapar e com a irmã que não acusa (*"coleta incompleta de julho"* fica calada).
Com ele, e é o que sustenta a §3.2:

| | não cabe (30) | **CONTROLE** (30) |
|---|---:|---:|
| `antigo` | **0** | **0** |
| `novo` | 11 | **0** |

**A conclusão sobrevive inteira** — zero confissões espúrias no polo de
controle, e o braço velho a 0 de 30 dos dois lados. E a assimetria fecha o §2:
0 de 30 tem variância zero, ruído não desce abaixo de zero, e **Fisher exato
0/30 contra 9/30 dá p = 0,0019**. As 9 não são ruído.

**§3.3 — o desconto de `10c-duas-vizinhas-cabem` não se sustenta, e o placar
muda para o outro lado.** O caso tem quatro requisitos escritos e as três saídas
do braço novo **não violam nenhum**: tudo coube, nenhuma diz que deixou de ler
(*"As anotações da conta não aparecem na nota"* é ausência no caderno, não
leitura parcial), as duas notas são usadas pelo que são, *"fechar o orçamento"*
não vira decisão tomada, nada é inventado. O caso foi reprovado por um critério
**que não está escrito nele** — "leu a pergunta como eu quis" — e depois
descontado. As duas coisas cancelam-se: sem a cobrança, o lado "tudo cabe" é
**7 e 7** e o placar total é **7 (antigo) contra 8 (novo)**, não o empate.

E a observação que o desconto enterrou vale mais escrita: com 2,1× mais contexto
o modelo **ancorou mais na letra da página** — o velho ignorou "da conta" e
respondeu sobre a semana, o novo levou a palavra a sério 3 de 3, com a MESMA
entrada. É plausivelmente o mesmo mecanismo que custa preço e prazo na pergunta
real da §4, e como mecanismo tem valor para a volta seguinte.

**O caso cego de fora (`prova/responder-ctx/casos-cegos.md`) — o C5 não está
coberto.** Os 20 casos cobrem os dois polos: (a) com folga, (b) no magro muito
bem (`acordar-cedo-sem-vizinha`, `espanhol-sem-vizinha`, sem vizinha nenhuma).
Duas lacunas de tamanho — o C2 pede corte de 5 % e os desta volta cortam ~20 %;
o C3 pede três notas de 300 a 400 PALAVRAS e as vizinhas que cabem aqui têm 105
a 307 caracteres, logo **o zero do controle foi medido em material magro**. Mas
a lacuna que importa é o **C5: nenhum dos 20 pergunta por uma nota que NÃO
EXISTE**, e nada distingue *"não coube"* de *"não há"*. É a alavanca desta volta
que cria o risco: ela ensinou a rota a dizer *"não veio aqui"*, *"não consta
aqui"*, *"não chegou aqui"* — as três frases estão em
`10c-duas-notas-uma-fica-de-fora` e são exatamente as que o C5 reprova quando
não há nada que pudesse ter vindo. O detalhe que fecha: a vizinha de
`10c-contrato-nao-cabe` chama-se **"Contrato do estúdio"**, o nome que o C5
exige que não exista — os dois casos são espelho um do outro, e só um rodou.
**Recomendado como a primeira corrida da volta seguinte**, antes de qualquer
alavanca nova: 1 caso × 3 × 2 braços.

**Por que o código entra mesmo com a perda da §4.** Segui a rota: `notasLigadas`
→ `contextoDoCaderno` → `contextoDaPergunta` → `responderNaPagina`, e é o único
consumidor (`responderNasNotas`, que está viva, passa por `contextoDasNotas`).
Com `responder` cortada, **nem o ganho nem a perda alcançam autor nenhum hoje**.
O que entra é a remoção de uma tesoura que fazia o app afirmar ao autor que a
nota dele não tem o que ela tem; a perda de preço e prazo na pergunta real
(2 de 3 → 0 de 3, n = 3, uma pergunta) é real, fica escrita, e vai ao RUMO como
o custo nomeado da alavanca seguinte.

**Instrumento do G3:** nenhuma chamada nova ao provedor, nenhum aparelho de
conta tocado. Suíte na árvore JÁ MESCLADA com `main`: **1070 testes em 167
suítes, `** TEST SUCCEEDED **`**, 152,9 s no teste 4 `A1DF082C`, sob
`com-trava.sh`. Build limpo, só o warning herdado de `NotasView.swift:814`.
