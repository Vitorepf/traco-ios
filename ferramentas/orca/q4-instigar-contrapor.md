# Q4-C — a guarda que apaga deixou de virar silêncio, e os dois consertos de prompt

**Volta:** Q4-C, retomada em 10/09 depois de o Mac reiniciar duas vezes na madrugada
e matar o worker que a fazia. **Branch:** `Vitorepf/q4-c`, sem mesclar.
**ADR:** 2026-09-09s (a guarda que apaga) + **emenda** à 2026-09-09i (os dois prompts).
**Relatório do implementador. A nota final é do revisor independente, não minha.**

## Linha do ciclo

Entra no **G1→G3** de `instigar` e `contrapor`; serve à intenção **"a IA responde ou
diz por que não — nunca some"**; reduz o obstáculo **"duas operações cortadas e uma
rota que cala com HTTP 200"**; prova-se por **12 casos × 3 repetições em `grok-4.3` e
`grok-4.5`**, mesma janela, uma instalação por cima, no aparelho da conta.

## Ato 0 — o que sobreviveu ao reinício, e o que era verdade nele

Encontrei a árvore com cinco arquivos alterados e sem commit, mais dois scripts novos
não rastreados. **Li o diff inteiro e comitei antes de qualquer outra coisa**
(`d1773e1`), com a mensagem dizendo que era trabalho **em curso** e que build e suíte
ainda não tinham sido conferidos nesta árvore.

O relatório do estado anterior dizia *"código pronto, build OK, 1025 testes passam"*.
**Conferi na árvore de agora, e era verdade** — mas só depois de corrigir o meu
próprio instrumento: a minha primeira tentativa usou `xcodebuild build` seguido de
`test-without-building`, e `build` **não constrói o pacote de testes**; a corrida
morreu em *"Failed to load test bundle"* e o meu `echo "suíte saiu $?"` reportou **0**
porque o `$(date)` da própria linha havia resetado o `$?`. Duas armadilhas do
instrumento, ambas do tipo *verde que não visitou o lugar*. Refeito com `xcodebuild
test`:

```
[07:46:45] build saiu · warnings=1 · errors=0
   W .../Traco/Notas/NotasView.swift:806:30: warning: '+' was deprecated in iOS 26.0
** BUILD SUCCEEDED **
✔ Test run with 1025 tests in 164 suites passed after 147.072 seconds.
** TEST SUCCEEDED **
```

**O build foi LIMPO** (`rm -rf build` + `xcodebuild clean build`, `derivedDataPath`
próprio do worktree), então a contagem vale sobre a árvore e não sobre a corrida: **1
warning, e é o herdado de `main` em `NotasView.swift:806`**, dívida de outra volta.
Suíte no **`34CC3F94`** (aparelho de trabalho), que encontrei ligado e deixei ligado.

## Os três defeitos

### 1. `Falha.semRetorno` com HTTP 200 — bug NOSSO, e veio primeiro

A causa estava à vista em `Sabia.parseContraparte`: o `limpo(_:)` devolve `""`
quando a frase cai numa guarda (imperativo, `vazaAlheio`, `numeroAlheio`, tamanho);
com as três chaves caídas, `Contraparte.vazia` é verdadeira e a função devolvia
`nil`. **A guarda que protege apagando produzia o silêncio**, indistinguível do
provedor mudo. A Lente escrevia *"a sábia não respondeu."* sobre uma resposta que
existiu.

O conserto separa três desfechos onde havia dois:

| desfecho | valor | o que o autor lê |
|---|---|---|
| não há quem responda | `Politica.aviso(_:)`, antes da chamada | a frase da tabela `Politica` |
| o provedor não devolveu nada legível | `nil` | "a sábia não respondeu." |
| leu inteiro e nada meu sobreviveu | `Contraparte` vazia / `[]` | `Sabia.nadaPassouNaGuarda` |

**Os irmãos, procurados e nomeados.** `parsePerguntas` tinha a mesma forma
(`guard !limpas.isEmpty else { return nil }`) e recebeu o mesmo conserto — o defeito
era da FORMA, não de uma rota. A espécie é **"guarda por campo que apaga e segue"**,
e só esses dois a têm: `parseMapa`, `parseVoltaram` e `parsePerguntaDeRecordar`
recusam a resposta INTEIRA no primeiro item inválido, que é honestamente *não deu
para ler*. E a convenção já era da casa — `parseCalibragem`, `parseEcos` e
`PadroesRemoto.parsePerguntas` já separavam os dois desfechos (teste
`todosOsParsersDeListaSeguemAMesmaRegra` congela isso). O terceiro chamador,
`Sessao.instigarSobreAForma`, já lia `r?.first` e **não precisou de uma linha** —
o conserto ficou onde os dois passam, não em cada chamador.

**A sonda passou a nomear a guarda.** `Sabia.apagou(chave, guarda)` grava — só em
DEBUG, só o nome da chave e da guarda, nunca o texto bruto — e `AvaliacaoIA` publica
em `guardasQueApagaram`. Sem isso o LOTE seguinte só saberia dizer "vazio". Mesma
linha da ADR 08p.

### 2. `contrapor` inventava renda que a nota não tem

`fatoQueEleNaoDeu` excluía `"renda"` **de propósito**, com medo da recusa covarde.
Pôr `"renda"` na lista **sozinha** aumentaria o defeito 1 — mais frases apagadas,
mais `nil`, mais silêncio. **Por isso o 1 veio antes**: com o desfecho novo o custo
saiu, e `"renda"` entrou. `"juros"` e `"inflação"` continuam fora: são propriedade
do produto financeiro, não fato da vida dela.

No prompt, a proibição por PROCEDÊNCIA saiu da **penúltima linha** e subiu para
dentro do bloco **Proibido**, com o exemplo medido e a consequência escrita.

### 3. `instigar` no texto magro não pedia *quando*

*"Não devolva vazio quando há texto…"* era a **última linha**, escrita como consolo
contra o vazio. Sumiu do fim e virou cobrança no ALTO, logo abaixo do que **MANDA**,
com as três pernas nomeadas e o contraexemplo medido (*"'O que era?' e 'o que
mudou?' não cumprem a do quando"*) — o mesmo movimento que a Q4-B fez ao promover "O
QUE COBRAR".

No **pedido** a troca é de palavras: uma linha sai do fim, quatro entram no alto. Mas
na **saída** o efeito foi aditivo, e é aí que mora o defeito que esta janela comprou
— está medido mais abaixo, e não arredondado.

## A prova do vermelho

Com a mutação que devolve a forma antiga (`return c.vazia ? nil : c` e
`guard !limpas.isEmpty else { return nil }`), a suíte nova acusa, no `34CC3F94`:

```
✘ respostaInteiraEsvaziadaNaoEhSemRetorno() ... Expectation failed: (r → nil) != nil
✘ respostaInteiraEsvaziadaNaoEhSemRetorno() ... Expectation failed: (r?.vazia → nil) == true
✘ oIrmaoDoInstigarDistingueOsMesmosDoisDesfechos() ... (Sabia.parsePerguntas(...) → nil) == []
✘ Test run with 6 tests in 1 suite failed after 0.016 seconds with 3 issues.
```

Mutação **desfeita** (`git checkout -- Traco/Analise/Sabia.swift`, `grep` da marca = 0):
não fica dívida viva.

## A medida

**A janela.** `lote09e`, **10/09 10:55:25Z → 11:10:47Z**, aparelho da CONTA
`B91C8DEF` (iPhone 17 Pro, teste 2), **uma** instalação por cima, tudo dentro de UMA
chamada de `com-trava.sh` — boot, fumaça, install, as duas corridas e as fumaças do
meio e do fim. Log inteiro em `prova/lote09e-janela.log`. A janela **esperou na fila
da trava** enquanto a Q3-C fazia build e suíte; foi assim que o desenho previu.

**A conta, colada:**

```
[2026-09-10T10:55:37Z] CONTA ANTES: "contaGrokLigada":true
[2026-09-10T10:55:43Z] CONTA DEPOIS DO INSTALL: "contaGrokLigada":true
[2026-09-10T11:10:47Z] CONTA NO FIM: "contaGrokLigada":true
[2026-09-10T10:55:31Z] binario ANTES:  2c040c4ea99d5403b4bdaa7b59758f69849daf90418bf82e238d72a1135e49d3
[2026-09-10T10:55:41Z] binario DEPOIS: 264215afa69e4bdce243fa87aec50be846c3dc634a2f0e4deb0cea265ff63a52
[2026-09-10T11:10:47Z] binario FIM:    264215afa69e4bdce243fa87aec50be846c3dc634a2f0e4deb0cea265ff63a52
```

O aparelho estava **desligado** desde o reinício do Mac; liguei por `simctl boot` e
li a conta antes de tudo. A conta **não caiu** em nenhum momento.

**O binário medido é o binário comitado.** Todo o código que decide o comportamento
de `instigar` e `contrapor` — `Sabia.swift`, `AvaliacaoIA.swift`, `LenteView.swift` e
os dois testes — foi comitado **antes** da janela, em `d1773e1`, e não recebeu uma
linha depois dela. O segundo commit mexe só em `Politica` (a cópia da tela do Perfil),
no portão que a guarda, nos documentos, na prova e no ferramental — nada que entre no
pedido, na resposta ou nas guardas que a medida exercitou.

**A fixture é a MESMA do LOTE-3** — `q4-instigar-contrapor-casos.json`, SHA
`ed9267c19b26…` gravado nos dois JSONL. 12 casos × 3 repetições × 2 modelos = **72
execuções** de cada lado, então os dois números se comparam direto.

### Item 1, que é o do despacho: o `semRetorno` com HTTP 200 sumiu?

**Sumiu. Duas vezes antes, zero agora, no mesmo par de modelos.**

| | LOTE-3 (base) | LOTE-5 (agora) |
|---|---|---|
| `grok-4.3` | 1 — `q4-contrapor-tudo-ou-nada` rep. 1, HTTP 200 | **0** |
| `grok-4.5` | 1 — `q4-contrapor-razao-ja-sustentada` rep. 2, HTTP 200 | **0** |
| **total em 72 execuções** | **2** | **0** |

E a prova de que o conserto é o certo, não um apagamento do sintoma: **uma** execução
acionou a guarda e a sonda a nomeou — `q4-contrapor-razao-ja-sustentada` rep. 1 do
`grok-4.3`, `foraDaLista · tamanho`. A chave caiu, **as outras duas sobreviveram**, e
o autor recebeu contraponto em vez de "a sábia não respondeu". Se ainda houvesse
`nil`, essa execução teria virado silêncio.

### Itens 2 e 3

| item | LOTE-3 | LOTE-5 |
|---|---|---|
| 2 · renda/salário que a nota não declara, no `contrapor` | **4** (1 no `4.3`, 3 no `4.5`) | **0** |
| 3 · texto magro pede QUANDO | **1/6** | **6/6** |
| 3 · texto magro cumpre as TRÊS pernas (o quê, quando, dar certo) | **1/6** | **6/6** |

O texto magro, no `grok-4.3` de hoje, palavra por palavra:

```
r1  - O que aconteceu?          - Quando aconteceu?              - O que seria dar certo?
r2  - O que aconteceu?          - Em que dia não deu certo de novo? - O que seria dar certo?
r3  - O que não deu certo?      - Quando não deu certo de novo?  - O que seria dar certo?
```

Antes, o mesmo caso e o mesmo modelo devolviam *"O que era?"* e *"O que mudou de
novo?"*, e o **quando** não aparecia em nenhuma das três.

### A linha de base que não podia regredir

| | LOTE-3 | LOTE-5 |
|---|---|---|
| degrau 4 repete as perguntas do degrau 0 | não | **não** |
| a voz do autor volta (`o-autor-escreve-metodo`) | 3/3 nos dois | **3/3 nos dois** |
| guardas mecânicas, conferidor `lote-ia-09c-guardas.py` **INALTERADO** | 68/72 (70/72 pela letra) | **72/72** |

O conferidor do LOTE-3 **não foi tocado** — mudar o instrumento faria os dois lotes
deixarem de se comparar. As colunas novas moram num arquivo à parte
(`ferramentas/orca/lote-ia-09e-q4c.py`), cada uma com a linha da fixture que a
autoriza citada no comentário.

### O defeito OPOSTO que a mesma janela comprou — e ele é meu

Promover a cobrança do QUANDO fez com que ela mandasse **também onde não devia**. Em
`q4-instigar-com-metodo-decisao` rep. 2 do `grok-4.3`, as perguntas voltaram como o
gabarito nu:

```
- O que aconteceu?
- Quando aconteceu?
- O que seria dar certo?
```

Sem a sala, sem o limite de R$ 1.000, sem os clientes — e a linha da fixture desse
caso é literalmente *"As perguntas cobram critério, evidência e custo de errar — mas
falam da sala, do limite de R$ 1.000 e dos clientes."* A base do LOTE-3 cobria os
três em 3 de 3.

Para o achado não depender de eu ter lido, o medidor ganhou uma coluna **mecânica** —
*repetição em que NENHUMA pergunta compartilha palavra de conteúdo com a nota* — e
ela correu **também sobre a base**, com o mesmo código:

| GENÉRICA (a repetição INTEIRA sem nada da nota), nas 5 notas COM matéria | LOTE-3 | LOTE-5 |
|---|---|---|
| `grok-4.3` | 0/15 | **1/15** (`com-metodo-decisao` r2) |
| `grok-4.5` | 0/15 | **0/15** |

**Mas o caso extremo é a ponta, não o tamanho — e o tamanho é maior.** Contando
pergunta a pergunta (quantas carregam alguma palavra de conteúdo da nota), a diluição
aparece nos **DOIS** modelos, porque a cláusula promovida não substituiu perguntas:
ela ACRESCENTOU perguntas, e as acrescentadas são as pernas do gabarito.

| perguntas ancoradas na nota / total, 5 casos ricos × 3 repetições | LOTE-3 | LOTE-5 |
|---|---|---|
| `grok-4.3` | 49/51 — **96%** | 48/63 — **76%** |
| `grok-4.5` | 59/61 — **97%** | 63/71 — **89%** |

Caso a caso, contra a base (ancoradas/total nas três repetições):

| caso | `4.3` base | `4.3` agora | `4.5` base | `4.5` agora |
|---|---|---|---|---|
| `sem-metodo-degrau-0` | 9/9 | 9/9 | 11/11 | 11/11 |
| `mesmo-texto-degrau-4` | 8/8 | 11/15 | 12/12 | 15/15 |
| `com-metodo-decisao` | 12/14 | **8/11** | 13/14 | **10/15** |
| `o-autor-escreve-metodo` | 9/9 | 11/13 | 12/12 | 13/15 |
| `premissa-incerta` | 11/11 | **9/15** | 11/12 | 14/15 |

O caso do método (`com-metodo-decisao`) e o da premissa (`premissa-incerta`) são os
que mais perdem, e são justamente os dois em que a fixture cobra coisa própria —
critério/evidência/custo de errar num, o exame da premissa no outro.

**A forma do defeito, nomeada:** o requisito que subiu para MORDER na nota pobre
virou **acréscimo** na nota farta. O modelo cumpre a lista promovida e a soma às
perguntas que já faria, em vez de deixá-la governar só onde falta matéria.

A coluna **não se lê** no texto magro: ali a nota é "Não deu certo de novo.", sem
palavra de conteúdo, e genérica é o desfecho certo — está escrito no cabeçalho do
medidor, para o próximo não tropeçar nela.

**O conserto está escrito e NÃO foi aplicado**, de propósito: a alavanca não é mais
promoção nem mais proibição — é o requisito ficar **CONDICIONADO à matéria**. Quando a
nota dá pouco, pergunte o quê / quando / o que seria dar certo; quando ela dá mais, as
perguntas saem do que ELA escreveu e o *quando* entra só se faltar. **Uma frase, não um
parágrafo** — inchar o pedido é como se compraram os defeitos anteriores. Aplicá-la
agora faria o binário comitado divergir do binário medido, e uma corrida nova também
não seria medida. Fica como **dívida nomeada** na emenda à 09i, dona: a volta seguinte
de `instigar`.

**E o que o `4.5` não repetir também é resultado.** A janela é uma comparação de UMA
alavanca — mesmo prompt, mesmo binário, mesma fixture, mesma janela, só o modelo muda
— e nela o `grok-4.5` é melhor que o `grok-4.3` em `instigar` nas duas colunas novas:
**0/15 contra 1/15** de repetição inteiramente genérica, e **89% contra 76%** de
perguntas ancoradas. Isso entra como insumo pareado para a escolha de modelo POR
OPERAÇÃO que a Q3-C está pondo de pé.

## Estado honesto — o que NÃO foi feito

- **`instigar` e `contrapor` continuam `indisponivelPorQualidade`.** Eu medi; a
  leitura de mérito é de quem não escreveu os casos. Não tirei nenhuma da lista.
- **Não há captura da Lente com a frase nova na tela, e isso é dívida NOMEADA com
  dono, não acabamento esquecido.** A frase está coberta por teste, e **a tela dela só
  existe quando a operação voltar**: hoje `Politica.aviso(_:)` responde antes de a
  Lente chamar a Sábia, porque `instigar` e `contrapor` seguem
  `indisponivelPorQualidade`. Não se fotografa o que o app não pode mostrar. **Quem
  devolver `instigar` ou `contrapor` à lista fotografa esta frase no mesmo ato** — se
  ninguém estiver de guarda ali, no dia em que a operação voltar essa frase chega ao
  autor sem nunca ter sido vista na tela. O orquestrador registra no RUMO.
- **E tentei mesmo assim, com o lever da sonda, e parei.** No meio da tentativa a
  **Q3-C tomou a trava para instalar no mesmo `B91C8DEF`** — duas voltas no aparelho
  da conta na mesma manhã —, e qualquer captura depois do install dela seria do
  **binário dela**: evidência contaminada, que declarada vale e usada é pior que
  nenhuma. Escalei o fato na hora; o orquestrador respondeu para **não retomar o
  aparelho** e assumiu o despacho compartilhado como erro dele. Cheguei à folha de
  Notas com o meu binário (`08:19`), não à Lente, e não anexo essa captura porque ela
  não sustenta a frase que a citaria.
- **Um warning na árvore**, herdado de `main` em `NotasView.swift:806`. Não é meu.
- **Dívida minúscula, nomeada:** `Sabia.guardasQueApagaram` cresce sem teto num app
  DEBUG que não seja a sonda (3 strings curtas por gesto de `contrapor`, drenadas a
  cada execução da sonda). Não pus teto porque pôr custa mais linha do que o problema.

## O portão final, depois de tudo o que mudou

Build **LIMPO** (`rm -rf build` + `clean build`) e suíte integral no `34CC3F94`, com a
árvore como ela vai para o commit:

```
build LIMPO saiu 0 · warnings=1 · errors=0
   W .../Traco/Notas/NotasView.swift:806:30: warning: '+' was deprecated in iOS 26.0
xcodebuild test saiu 0
✔ Test run with 1025 tests in 164 suites passed after 107.956 seconds.
** TEST SUCCEEDED **
```

**O único warning é o herdado de `main`.** E o portão pegou um erro MEU antes de
passar: o `motivo` que eu tinha escrito para o `contrapor` saiu com **91 caracteres e
uma data dentro** — e `motivo` é a LINHA DA TELA do Perfil, que por contrato é oração
curta, sem data e sem caminho de prova (quem carrega evidência é o `porque`, que vai
para a ADR). Reescrito em 72 caracteres, sem barra. **A corrida vermelha está aqui
porque um portão que só aparece quando passa não é portão:**

```
✘ indisponivelPorQualidadeNaoTemExecutorNemComContaEAparelho() ... (m.count → 91) <= 80
✘ indisponivelPorQualidadeNaoTemExecutorNemComContaEAparelho() ... !(m.contains("/") → true)
```

## Dois achados de instrumento, para a ESTEIRA

**1. `touch` na trava pode transformá-la em ARQUIVO, e aí o `mkdir` de todos falha
para sempre.** A janela do LOTE precisa de mais de 30 min, e a guarda de trava velha
do `com-trava.sh` retoma por TEMPO; a defesa que os LOTEs usam é um laço que faz
`touch "$L"` a cada 60 s. Se esse `touch` correr **depois** do `rm -rf "$L"` do dono
— e ele corre, porque o toucher morre no `EXIT` e há uma janela entre as duas coisas
—, ele **cria `/tmp/traco-instrumento.lock` como arquivo comum**. Vi acontecer às
08:25 de hoje: dois `com-trava.sh` (o meu e o da MAC-2-A) girando sem poder entrar,
porque `mkdir` não sobrescreve arquivo. Curou-se sozinho quando o meu saiu e limpou,
mas seriam **30 minutos** de dois workers parados se ninguém tivesse saído.
**Conserto, uma linha, já aplicado em `lote-ia-09e-janela.sh`:**
`[ -d "$L" ] && touch "$L"` — só toca a trava se ela ainda for o diretório do dono.
Os `lote-ia-09*-janela.sh` anteriores têm a mesma linha sem o teste.

**2. `xcodebuild build` não constrói o pacote de testes, e `$(date)` numa linha de
`echo` apaga o `$?`.** As duas juntas me deram um "suíte saiu 0" sobre uma corrida que
tinha morrido em *"Failed to load test bundle"*. É a família do *verde que não visitou
o lugar do defeito*, agora na forma mais barata: **o instrumento mentiu no relato, não
no teste**. Quem declara "suíte verde" cola a linha `Test run with N tests … passed`,
não o código de saída.

## Scorecard (preenchido por mim; a nota é do revisor independente)

| dimensão | nota | evidência |
|---|---|---|
| Visão | 9 | fecha a lacuna "a rota cala com HTTP 200" do EVOLUCAO; diff do EVOLUCAO |
| Contrato | 9 | ADR 09s + emenda à 09i no SPEC, `Politica` e `EVOLUCAO` coerentes, `LETRAS-ADR` com a 09s uma vez só |
| Correção | 7 | 1025 testes em 164 suítes verdes; vermelho plantado e mostrado; **mas a janela comprou um defeito oposto medido nos DOIS modelos — perguntas ancoradas na nota caíram de 96% para 76% no `4.3` e de 97% para 89% no `4.5`** —, consertado só no papel |
| Jornada real | n/a → dívida | a frase nova não foi vista na tela; o motivo está dito acima e a Q3-C tomou o aparelho |
| Design | n/a | nenhum token, layout ou movimento tocado; a frase entra no `LinhaDeEstado` que já existia |
| Simplicidade | 9 | três desfechos onde havia dois, sem tela nova e sem passo novo para o autor |
| Movimento | n/a | nada anima |
| Componentes | n/a | nenhum componente novo |
| Acessibilidade | n/a | nenhuma superfície nova |
| Performance | n/a | nenhuma lista, editor ou parser de caminho quente tocado |
| Privacidade e autoria | 9 | `guardasQueApagaram` guarda **só** o nome da chave e da guarda, nunca o texto; só em DEBUG |
| Estado honesto | 9 | é o objeto da volta: três desfechos distintos, e a tela do Perfil passa a dizer o que a medida de hoje leu |
| Complexidade | 9 | +1 constante, +1 função de 6 linhas, +1 bloco DEBUG; o `parseContraparte` **perdeu** uma linha |
| Fora do app | n/a | nada fora do app |
| Relato | 9 | este arquivo, com a linha de resultado colada e o defeito próprio declarado |

---

# Q4-D — a mesma guarda, VIVA numa rota que o autor usa hoje

**Linha do ciclo.** G1 da trilha B (defeito), depois do G3 da Q4-C. Serve à intenção
*"a IA responde ou diz por que não — nunca some"*; reduz o obstáculo *"o `vestir`, que
está LIGADO, joga fora resposta completa e diz ao autor que a sábia não respondeu"*;
prova-se por teste que reproduz primeiro e pela suíte.

## O defeito, na rota que não está cortada

O G3 da Q4-C achou que a espécie consertada na 09s tinha um caso vivo uma função
adiante. Confirmado no código, e é pior do que "mais um parser": das cinco operações
que a Lente e o Perfil discutem, `instigar`, `contrapor`, `responder`,
`responderNasNotas` e `recordar` estão todas `indisponivelPorQualidade` —
`Politica.aviso(_:)` responde antes de a Sábia ser chamada. **`vestir` não.** É
`.grokDepoisBordo` na tabela `Politica` (`Politica.swift:130`), a rota que o autor
toca em "Vestir tudo" com a conta ligada.

E ali, `Sabia.vestir` (`Sabia.swift:378`) devolvia `nil` para duas coisas diferentes:

- **ninguém devolveu nada** — `gerar` deu `nil` (provedor mudo, orçamento, cancelamento);
- **chegou um cru inteiro e o NOSSO contrato o recusou** — `parseMapa` recusa lista
  vazia (`!saida.isEmpty`), lista com dois títulos (`titulos <= 1`), índice fora do
  intervalo ou forma desconhecida; e `vestir` recusa por conta própria o mapa mais
  curto que os blocos pendentes (`refinado.count == pendentes.count`), que o parser
  nem enxerga.

`Sessao.vestirTudo` (`Sessao.swift:735`) escrevia, nos dois casos, **"a sábia não
respondeu. o texto ficou como estava."** — sobre um HTTP 200 lido até o fim.

## O conserto, e a escada que levou a ele

A pergunta honesta é *chegou um cru?*, e **quem sabe disso é `vestir`, não o parser**.
Por isso o conserto não foi em `parseMapa`: o contrato duro dele não mudou (nada passa
a ser aceito), e ele nunca veria a quarta recusa, a do `refinado.count`. Duas linhas
onde o desfecho já se decide cobrem as quatro:

```swift
guard let cru = await gerar(usuario) else { return locais != blocos ? mapa : nil }
let refinado = parseMapa(cru, blocos: pendentes.count)
guard let refinado, refinado.count == pendentes.count else {
    apagou("vestir", refinado == nil ? "mapa fora do contrato" : "mapa menor que os blocos pendentes")
    return locais != blocos ? mapa : []
}
```

A lista **vazia** carrega o terceiro desfecho sem tipo novo, sem enum e sem camada: um
mapa de sucesso nunca é vazio, porque `blocos` não é (`guard !blocos.isEmpty` na
primeira linha da função). É a mesma convenção da 09s — `nil` é não li, vazio é li e
não sobrou —, agora com a lista de `Rotulo` no lugar da `Contraparte`.

Na tela, o quarto desfecho ganha frase própria, e **não** a `nadaPassouNaGuarda` da
Lente. O motivo é medido, não estético: `vestir` **memoiza**
(`memoPor: "vestir\u{1}…"`, temperatura 0), então *"Peça de novo"* — que a frase da
Lente traz — seria falso ali; o memo devolve o mesmo cru e o mesmo desfecho.

> `Sabia.nadaVestiu` = *"a sábia respondeu, e o que veio não vestia este texto. ele
> ficou como estava."*

Dizer *"nada a vestir aqui."* seria a outra metade da mentira: havia o que vestir, e
a sábia respondeu.

## O teste que reproduz, e o vermelho

Escrito **antes** do conserto. Três `cru` legíveis, lidos até o fim, na forma exata do
mapa que a sonda gravou em `prova/q-qualidade-avaliacoes.jsonl`
(`qn-vestir-tabela-e-lista`): a lista vazia, a lista mais curta que os pendentes, e a
lista com dois títulos. O teste exige antes que o motor local não tenha mexido no
texto (`#require(Caderno.estruturar(dois) == dois)`), senão o desfecho não seria da
sábia.

Corrida de **09:13:01–09:13:33** (`34CC3F94`, sob `com-trava.sh`), com o conserto
ainda fora da árvore:

```
✘ Test vestirComRespostaInteiraNaoEhSemRetorno() failed after 0.001 seconds with 3 issues.
✘ Test aSondaSabeQuandoFoiOVestirQueApagou() failed after 0.002 seconds with 2 issues.
✘ Test run with 9 tests in 1 suite failed after 0.032 seconds with 5 issues.
```

E de novo por **mutação**, depois do conserto, devolvendo a forma antiga do `guard`:
as mesmas **5 issues em 2 dos 9 testes** (`mutacao.log`). Mutação desfeita no mesmo
comando que a rodou; `git diff --stat` confere.

## Verde, no meu aparelho e na minha árvore

Build **LIMPO** (`rm -rf build` no mesmo `com-trava.sh`), `34CC3F94`,
**12:16:13Z–12:18:12Z**:

```
✔ Test run with 1028 tests in 164 suites passed after 88.670 seconds.
```

Prova de que a corrida foi na MINHA árvore — três testes que só existem neste
candidato aparecem no log:

```
✔ Test vestirComRespostaInteiraNaoEhSemRetorno() passed after 0.001 seconds.
✔ Test aTelaDoVestirDizQueHouveRespostaSemMandarPedirDeNovo() passed after 0.001 seconds.
✔ Test aSondaSabeQuandoFoiOVestirQueApagou() passed after 0.001 seconds.
```

**Warnings: 1**, e é o herdado de outra volta (`NotasView.swift:806`, `'+' was
deprecated in iOS 26.0`). Zero novos, sobre build que compilou tudo.

Repetido na árvore final, já com a ADR, o EVOLUCAO e o comentário do teste
corrigidos (incremental, **12:36:28Z–12:38:06Z**, mesmo aparelho e mesma trava):
`✔ Test run with 1028 tests in 164 suites passed after 88.886 seconds.`, com os
quatro testes deste candidato — os três novos mais o
`vestirNaoDisfarcaFalhaSemMelhoriaLocal` reescrito para o contrato novo — verdes no
log (`suite-final.log`).

## Os irmãos, procurados de novo: 12 parsers lidos, a espécie tem 5

| parser | separa "não li" de "li e não passou"? | a tela mente? |
|---|---|---|
| `Sabia.parseContraparte` | sim, desde a 09s | não |
| `Sabia.parsePerguntas` | sim, desde a 09s | não |
| **`Sabia.parseMapa` + `Sabia.vestir`** | **sim, desde esta volta** | **mentia — rota VIVA** |
| `Sabia.parsePerguntaDeRecordar` | **não** (`Prova.vaza`, tamanho, sufixo "?") | não — o ritual cai na frase fixa; rota cortada |
| `Sabia.parseVoltaram` | **não** (estado fora de `estadosConferir`) | não — `RecordarView` só deixa de mostrar o cotejo; não há frase |
| `RespostaNotas.interpretar` | **não** (teto de 900, `trechoIDs`, texto vazio) | **mentiria** — `NotasView.swift:190` escreve "a sábia não respondeu."; só não mente porque `responderNasNotas` está cortada |
| `Sabia.parseCalibragem` | sim (filtra para lista possivelmente vazia) | não |
| `Sabia.parseEcos` | sim (`continue`, nunca `return nil`) | não |
| `PadroesRemoto.parsePerguntas` | sim | não |
| `AnaliseRemota.parseVeredito` | sim (`.silencio` é o terceiro desfecho) | não |
| `PraticaTrabalho.parsePreparacao` | sim (`lerPreparacao` devolve `Result` com o nome da guarda — ADR 08p) | não |
| `Sabia.limparResposta` | n/a — só cai com string vazia, que é o provedor calando | não |

**Consertei um** e não os outros, de propósito: `parsePerguntaDeRecordar` e
`parseVoltaram` não produzem frase de tela nenhuma — mudá-las é código para um caso
que não existe. **`RespostaNotas.interpretar` é dívida nomeada, com dono: a volta que
tirar `responderNasNotas` de `indisponivelPorQualidade`.** O conserto tem de entrar
junto, ou a rota volta mentindo. Está escrito na emenda da ADR.

## A frase da ADR que o código contradizia — corrigida dentro da 09s

O G3 escreveu a substituta e eu a apliquei sem inventar nada: a ADR dizia que
`parseMapa`, `parseVoltaram` e `parsePerguntaDeRecordar` *"recusam a resposta INTEIRA
no primeiro item inválido, que é honestamente não deu para ler"* e que *"os dois da
Lente eram os únicos fora do passo"*. As duas metades eram falsas. O texto corrigido
está em `SPEC.md`, dentro da letra 09s (que continua aparecendo **uma vez só** no
`LETRAS-ADR.md`), e o **mesmo** comentário congelado no teste
`todosOsParsersDeListaSeguemAMesmaRegra` foi corrigido junto — era o outro lugar onde
a frase morava.

## A sonda passou a saber qual das duas quedas foi

`apagou("vestir", …)` grava, só em DEBUG e só o nome, `vestir · mapa fora do
contrato` ou `vestir · mapa menor que os blocos pendentes`, e `AvaliacaoIA` já publica
isso em `guardasQueApagaram`. É uma linha, e ela paga uma dívida velha: em
`prova/qualidade-ia-contexto-vestir-20260907.jsonl` há **6** `Falha.semRetorno` em
`vestir` (`vestir-codigo-crlf` ×3 e `vestir-cerca-aberta-crlf` ×3) e **não há como
saber hoje** se o provedor calou ou se fomos nós — é exatamente a cegueira que esta
volta existe para tirar. Com o conserto, a sonda deixa também de chamar de
`semRetorno` um 200 que ela recebeu: passa a gravar `mapa: []`.

## Estado honesto — o que NÃO foi feito

- **`nadaVestiu` não tem captura.** A rota exige `Sabia.disponivel`
  (`ContaGrok.ligada || noAparelho`), e no `34CC3F94` as duas são falsas: sem conta e
  sem Apple Intelligence, `vestirTudo` sai antes, em "nada a vestir aqui.". O
  `B91C8DEF` é o aparelho da conta e estava com a Q3-D durante toda esta volta — não
  encostei nele. **Limite do instrumento, declarado; a `.png` é da volta que tiver o
  aparelho.** A frase se prova por teste e pelo caminho lido no código.
- **Não há saída real de um `vestir` que o `parseMapa` tenha recusado.** Procurei: a
  sonda grava o `mapa` já interpretado, nunca o `cru`, então nenhum `.jsonl` do
  `prova/` tem o payload bruto de uma recusa. Os `cru` do teste são a **forma exata**
  dos mapas reais gravados, reduzidos às três recusas que o G3 nomeou. Os 6
  `semRetorno` de 07/09 são o sinal de que a rota produz este silêncio, mas são
  **datados** e a causa deles não está registrada — não os conto como prova do
  mecanismo.
- **Não medi nada com o Grok.** Esta é uma volta de defeito, não de qualidade de
  saída: nenhuma linha de prompt mudou, e o `sistemaInstigar` ficou como o G3 pediu,
  intocado.
- **Não mexi no `contrapor`**, que é volta própria e depende do aparelho da conta.

## Instrumento — o que usei, e como devolvi

- **`34CC3F94` (teste 3), aparelho de TRABALHO:** build e as quatro corridas de suíte
  (vermelho, verde da suíte nova, LIMPO integral, final). Achei ligado, deixei ligado.
- **`B91C8DEF` (teste 2), aparelho da CONTA: não encostei.** Estava com a Q3-D. Nenhum
  `install`, nenhum `boot`, nenhum `simctl` meu apontou para ele.
- **Nenhum `xcodebuild` fora do `com-trava.sh`**, nem "rapidinho" — as quatro corridas
  e a leitura de estado do aparelho passaram todas pela trava; duas delas esperaram
  atrás da Q3-D (`q3d-build-suite.sh`, dono da trava às 09:18) e da MAC-2-A
  (`volta.sh`, dona às 09:10), o que é a trava funcionando.
- **Nada de `orca emulator kill`, nada de `erase`, nada de mouse.** Não usei
  controle de computador nesta volta.
- **Devolvido como achei:** `xcrun simctl ui 34CC3F94… content_size` → `medium`,
  `increase_contrast` → `disabled`, com captura em
  `scratchpad/34CC3F94-fim.png` (09:41). Não mudei orientação nem Movimento Reduzido
  em momento nenhum.
- **Ferramenta do `main` trazida antes de correr:** `com-trava.sh` e os três
  `lote-ia-09*-janela.sh` que existem lá (o `09e` é deste branch e não está no `main`).

## Scorecard da Q4-D (preenchido por mim; a nota é do revisor independente)

| dimensão | nota | evidência |
|---|---|---|
| Visão | 9 | fecha a lacuna "a rota cala com HTTP 200" na única rota LIGADA que ainda a tinha; linha nova no EVOLUCAO com dono para o que sobra |
| Contrato | 9 | emenda dentro da letra 09s, com a frase falsa corrigida onde ela morava (SPEC **e** comentário do teste); `LETRAS-ADR` com `09s` uma vez só; EVOLUCAO coerente |
| Correção | 9 | vermelho antes (5 issues em 2 de 9) e por mutação depois; 1028 testes em 164 suítes verdes em corrida minha, com três testes exclusivos deste candidato colados; 1 warning, herdado |
| Jornada real | 8 | a rota é a que o autor usa hoje e o caminho até a frase está lido linha a linha — mas **não há captura**, pelo limite declarado acima |
| Design | 9 | `design-router` carregado, rota "ajuste local de copy": estados afetados listados (são quatro), sistema existente reusado (`mostrarToast`), nenhum token, layout, componente ou movimento tocado |
| Simplicidade | 9 | quatro desfechos onde havia três, sem tipo novo, sem enum, sem tela nova e sem passo novo para o autor |
| Movimento | n/a | nada anima |
| Componentes | n/a | nenhum componente novo |
| Acessibilidade | n/a | nenhuma superfície nova; a frase entra no toast que já existe |
| Performance | n/a | nada em lista, editor ou parser de caminho quente |
| Privacidade e autoria | 9 | `apagou` grava só o nome da guarda, nunca o cru; `#if DEBUG`; nenhuma palavra do autor sai do aparelho por causa desta volta |
| Estado honesto | 9 | é o objeto da volta; o que não foi feito está acima, com o motivo, antes de alguém perguntar |
| Complexidade | 9 | +1 constante, +2 linhas em `vestir`, +1 `guard` de 4 linhas em `Sessao`; nenhum arquivo novo, nenhum `xcodegen` |
| Fora do app | n/a | nada fora do app |
| Relato | 9 | esta seção, com as linhas de resultado coladas e os limites declarados |
