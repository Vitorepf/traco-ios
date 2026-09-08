# Volta Q — a qualidade da IA, medida com a conta ligada

08/09/2026 · implementador (Claude Opus 5) · branch `Vitorepf/volta-q-qualidade`,
candidato **`acdfcb4`** — corrigido em 08/09 pela volta Q-B (o G3 mostrou que
`325c819`, o hash que este relatório trazia, é o **pai** de `acdfcb4` e só
acrescenta o `LACO.md`). **Esta é a leitura do implementador. A nota final é do
revisor independente, não minha.**

## G0 — a linha da volta

**Ciclo:** multiplicar. **Intenção:** a sábia e o Trabalho produzem algo que
serve. **Obstáculo:** nenhuma das dezesseis operações tinha medição com Grok, e
nove estavam em "só Grok" por presunção. **Evidência:** a sonda `AvaliacaoIA`
rodada no aparelho do dono com a conta ligada, três execuções por caso, JSONL
com as saídas inteiras, leitura contra a rubrica de `QUALIDADE-IA.md`, e a
tabela `Politica` ajustada pelo resultado (ADR 2026-09-08k).

## 1. A conta, antes de tudo

Conferida **antes de instalar** e **antes de cada corrida**, como manda a lei do
simulador do Grok.

- Tela: `prova/q-conta-grok-C2416CBC-1443.png`, 08/09 às 14h43 —
  "CONTA · **Grok** · conectada — o Grok é o motor, pago pela sua assinatura."
- Depois da instalação por cima (`xcrun simctl install`, **sem** `uninstall`,
  **sem** `erase`, **sem** `clearState`, **sem** `xcodebuild test` neste
  aparelho): corrida de fumaça `A85BA7C0` com `contaGrokLigada: true` e a
  listagem **autenticada** de modelos devolvida pela API (`grok-4.3`,
  `grok-4.5`, `grok-4.6`, entre outros). Chamada autenticada que responde é
  prova mais forte que a tela.
- Em cada um dos 288 registros do JSONL: `contaGrokLigada: true`.
- As abas do Safari do incidente das 11h21 não foram tocadas.

## 2. Procedência da medida (o vínculo que o conselho exigiu)

| o quê | valor |
|---|---|
| aparelho | iPhone 17 Pro `C2416CBC-C5D9-41F9-ACD8-45EED8FC355E`, iOS 26.5 (23F77) |
| candidato | **`acdfcb4`**, o commit dos 15 arquivos da Q, Debug |
| binários da corrida | **dois**, e o JSONL diz qual é qual: a matriz de 16 × 6 × 3 (corridas `05D574C2`, `D91E98DE`, `F4D24F76`) na árvore de `325c819`, com `Traco` sha256 `504d29d7…0442` e `Traco.debug.dylib` sha256 `2152892a…315c` conferidos no contêiner; a remedição com fontes tipadas (`1FB24380`, `60B40CFE`, `B7A619E5`) na árvore que virou `acdfcb4`, que é a única cuja sonda exige `fontes`. Ver a tabela na ADR 08k |
| fixture | `prova/q-qualidade-casos.json`, sha256 `29654d46…c909b5`, 96 casos |
| fixture da remedição | `prova/q-qualidade-notas-tipadas.json`, sha256 `ea68b976…4b37f` |
| JSONL | `prova/q-qualidade-avaliacoes.jsonl` (cópia do `avaliacoes-ia.jsonl` do Documents do app) |
| modelo solicitado | `grok-4.3` nas doze rotas da sábia/análise; `grok-4.6` nas quatro de Trabalho |
| modelo respondido | registrado por chamada em `chamadasGrok.modeloRespondido` |

## 3. O conjunto de casos, e o que ele NÃO é

96 casos: **16 operações × 6**, três execuções cada, em **três lançamentos
distintos do app** (corridas `05D574C2`, `D91E98DE`, e a terceira registrada no
JSONL), sem memo entre repetições (`Grok.esquecerMemo()` a cada caso).

A procedência caso a caso está em `prova/q-qualidade-procedencia.tsv`.

- **Conhecidos (37):** reaproveitados sem alterar uma vírgula do corpus de
  provas que já existia no repo antes desta volta (`prova/cinco-itens-*`,
  `prova/qualidade-ia-*`). São regressões.
- **Novos desta corrida (59):** escritos por mim hoje, **depois** de congelados
  prompts, política e candidato.

**Estes 59 NÃO são teste cego e não são held-out.** Fui eu quem os escreveu e
eu quem leu as saídas. A separação que o conselho pediu está mantida no
relatório e no `.tsv`, mas a aprovação final exige casos novos de um revisor
que não os tenha visto — e esses ainda não existem. Cada caso novo carrega, no
seu primeiro requisito, a frase que diz isso.

Onde o corpus não tinha quatro conhecidos, o preenchimento é de caso novo, e
isso está declarado: `produzir` tinha 2, `vestir` 3, `ecos`/`calibragem`/
`padroes`/`conferir` 2 a 4, e `responder`/`instigar`/`contrapor`/`recordar`/
`classificar`/`dominio` tinham 1 cada.

## 4. O achado que vai contra nós: a sonda mediu uma rota que o app não usa

Antes de qualquer nota: **três dos seis casos de `responderNasNotas` mediram
uma rota fantasma, e a medida deles é inválida.**

`Sabia.responderNasNotas(pergunta:contexto:retrato:)` **não tinha nenhum
chamador de produção**. Só a sonda a usava. O que ela fazia era embrulhar a
prosa inteira do contexto numa `FonteNotas` sintética com o título literal
**"Contexto fornecido"**. A "atribuição genérica" que eu ia registrar como
defeito do provedor — `Referência: "Contexto fornecido"` — é **um título que o
próprio app fabricou e mandou para o modelo**. O modelo citou corretamente a
única fonte que recebeu.

A produção (`NotasView` → `Sessao.responderNasNotas` →
`Sabia.responderNasNotas(pergunta:fontes:…)`) só passa por fontes tipadas — que
é justamente o caminho que acertou nos meus casos.

Consequência, e ela é a lição da volta: **hash de fixture e JSONL completo não
impedem medir a rota errada.** "Qual executor e qual caminho foram REALMENTE
observados" é pergunta que se responde lendo o chamador, caso a caso.

**Contaminação anterior, registrada como fato datado, sem consertar prova
alheia:** as bases de 07/09 (`prova/qualidade-ia-base-20260907.jsonl`) e a de
hoje do Codex (`prova/cinco-itens-*`) usam `contexto` nos casos de
`responderNasNotas`. Aquelas linhas medem a mesma rota morta. Não reescrevi
nada delas; fica o registro.

**Conserto (feito nesta volta):** a sobrecarga foi apagada de `Sabia.swift` e a
sonda passou a exigir `fontes`. Doze linhas líquidas a menos, e a sonda deixa
de conseguir exercitar rota que a produção não usa.

## 5. Rota realmente observada, operação por operação

O conselho mandou mapear o executor e o caminho REALMENTE observados.
`contaGrokLigada` e `modeloConfigurado` não bastam.

| operação | o que a sonda chamou | chamador de produção | mediu a rota de produção? |
|---|---|---|---|
| produzir | `MotorTrabalho.produzir` | `Traco/Trabalho/OficinaTrabalho.swift:61` | sim |
| prepararPratica | `MotorTrabalho.prepararPratica` | só via `MotorTrabalho.produzir` (`OficinaTrabalho.swift:441`) quando `praticaPedida` | **mesma função, o invólucro `produzir` foi pulado** |
| conferirTentativa | `MotorTrabalho.conferirTentativa` | `OficinaTrabalho.swift:292` | sim |
| revisar | `ConferenciaTrabalho.conferir` + `RevisaoTrabalho.revisar` | `OficinaTrabalho.swift:246` e `:254`, mesmo par | sim |
| responderNasNotas | `Sabia.responderNasNotas(…contexto:)` em 3 casos, `(…fontes:)` em 3 | `Sessao.swift:633` → `NotasView.swift:126/132`, **só fontes tipadas** | **NÃO nos 3 de `contexto` — ver §4** |
| responder | `Sabia.responder` | `Sessao.swift:573` | sim |
| instigar | `Sabia.instigar` | `Sessao.swift:746` e `Pagina/LenteView.swift:310` | sim |
| contrapor | `Sabia.contrapor` | `Pagina/LenteView.swift:325` | sim |
| vestir | `Sabia.blocos` → `Sabia.vestir` → `Sabia.aplicar` | `Sessao.swift:688-690`, mesma tríade | sim |
| recordar | `Sabia.perguntaDeRecordar` | `Recordar/RecordarView.swift:245` | sim |
| conferir | `Sabia.conferir` | `Recordar/RecordarView.swift:260` | sim |
| ecos | `Sabia.ecos` | `Sessao.swift:538` e `Notas/RedeView.swift:49` | sim (a produção passa o texto por `Caderno.prosa`; meus casos são prosa pura) |
| calibragem | `Sabia.lerCalibragem` | `Padroes/PadroesView.swift:154` | sim |
| padroes | `PadroesRemoto.perguntas` | `Padroes/PadroesView.swift:142` | sim |
| classificar | remoto → bordo → local → `Sessao.escolher` | `Sessao.swift:173-196` | **a arbitragem é a mesma função; a orquestração em volta está DUPLICADA na sonda** |
| dominio | `AnaliseDeBordo.dominio` | `Sessao.swift:1289` | sim |

Duas ressalvas ficam registradas como limite, não como aprovação: o invólucro
de `prepararPratica` e a orquestração de `classificar` não foram exercitados
pela sonda. E a conveniência `entrada.artefato` chama `guardarVersaoHumana`:
ela **não serve como prova de proveniência** de uma versão gerada, como o
conselho avisou.

## 6. A matriz: o que atendeu, onde falhou, em que condições

Regra de leitura, fixada antes das saídas: **um caso só passa se as TRÊS
execuções cumprirem todos os requisitos obrigatórios**. Uma falha em três
reprova o caso. Média não aprova nada; o que vale é a pior execução.

**Não use isto como nota de dimensão média.** A rubrica de `QUALIDADE-IA.md`
tem cinco dimensões; quando um caso reprova, a dimensão mais baixa está
nomeada na coluna "o que falhou". Segurança, autoria e persistência são
invariantes, não dimensões que se compensam.

| operação | executor observado | casos 3/3 | conhecidos | novos | o que falhou, e por quê |
|---|---|---|---|---|---|
| **conferir** | Grok `grok-4.3` | **6/6** | 4/4 | 2/2 | nada. Paráfrase, contradição, resposta parcial, unidades/sinônimos, memória vazia e recuperação literal — todos certos nas três execuções |
| **padroes** | Grok `grok-4.3` | **6/6** | 2/2 | 4/4 | nada. Citação literal em todas, nenhum diagnóstico inventado nem no caso que convidava a isso (choro e aperto) |
| **conferirTentativa** | Grok `grok-4.6` | **6/6** | 4/4 | 2/2 | nada. Um julgamento por critério, citação literal, sem reescrever a tentativa, sem elogio nem nota |
| **classificar** | Grok + regex local + `Sessao.escolher` | 5/6 | 1/1 | 4/5 | a **regra LOCAL** vestiu de Destaque uma lista de compras ("Qual é a única de hoje?"). O modelo calou; quem errou foi a regex |
| **produzir** | Grok `grok-4.6` | 5/6 | 2/2 | 3/4 | 1 caso nunca respondeu (Combinar, 91 s, teto de tempo). Quando responde, é bom: apontou que quatro blocos de dez minutos não cabem em quinze, e recusou inventar cotação do euro |
| **vestir** | **local** — o Grok NÃO foi chamado em nenhum dos 6 | 5/6 | 3/3 | 2/3 | vestiu de título e lista um texto que dizia "não quero organizar isso em tópico nenhum". **A rota do Grok em `vestir` continua NÃO MEDIDA** |
| **dominio** | Apple Intelligence no aparelho | 4/6 | 0/1 | 4/5 | instabilidade: o mesmo texto sobre corrigir um bug voltou `trabalho`, `estudo` e `casa` nas três execuções; e "azul" (uma palavra) recebeu `estudo`, `nil` e `casa` |
| **ecos** | Grok `grok-4.3` | 3/6 | 1/2 | 2/4 | devolveu `[]` justamente onde o vínculo mais serve: 18 inscritos contra "a sala 7 comporta no máximo 15 pessoas". Acerta paráfrase; perde consequência |
| **responder** | Grok `grok-4.3` | 3/6 | 1/1 | 2/5 | **fabricação**: "A biblioteca municipal do seu bairro abre às 13h"; "Distância: 1.650 km (Fortaleza–SP)… R$ 1.072,50" num pedido em que o autor disse não ter distância, consumo nem preço |
| **prepararPratica** | Grok `grok-4.6` | **1/6** | 1/4 | 0/2 | 11 das 18 execuções **nunca chegaram**: 91 s, teto estourado. Dois casos que responderam nas corridas 1 e 2 estouraram na 3 — só um caso completou as três. O conteúdo dos que chegam é bom |
| **revisar** | Grok `grok-4.6` | 3/6 | 1/4 | 2/2 | 3 casos caíram em "revisão assistida · não executada" por tempo. Quando responde, acha a omissão real e **não inventa erro em material bom** |
| **calibragem** | Grok `grok-4.3` | 2/6 | 2/2 | 0/4 | cala quando não há erro a apontar (pares que acertaram → `[]`); e com **um par só a rota nem chega ao provedor** (guarda local exige dois) |
| **recordar** | Grok `grok-4.3` | 1/6 | 0/1 | 1/5 | vazou o alvo — "Por que a sala 7 não pode receber mais que 15 pessoas?" — e, quando a guarda `Prova.vaza` suprimiu a pergunta, o autor ficou **sem nada** |
| **instigar** | Grok `grok-4.3` | 1/6 | 0/1 | 1/5 | devolveu o vocabulário do próprio prompt: "Qual é o movimento básico que se pula?", "Como a nota DEGRAU 0 se relaciona com o método que você menciona?" |
| **contrapor** | Grok `grok-4.3` | 1/6 | 0/1 | 1/5 | sustentou o contraponto em fato inventado, sempre no campo `outroCampo`: "metanálises de 2022", "na construção naval do século XV o preço era 12 % menor", "pilotos usam a regra *two mistakes high*" |
| **responderNasNotas** | Grok `grok-4.3` | 4/6 | 2/3 | 2/3 | **remedida** com fontes tipadas (§4). Cita a nota certa, resiste à instrução hostil e expõe conflito entre notas. Falha em dois pontos: **recusa por inteiro** quando a pergunta pede fato atual, sem usar o que as notas trazem; e deixa escapar os rótulos internos `N1T1`/`N2T1` no texto do autor |

### A remedição de `responderNasNotas`, com fontes tipadas

Três casos foram reescritos com fontes tipadas — **só a representação mudou;
fatos, pergunta e retrato ficaram idênticos, e o texto ambíguo de um deles NÃO
foi corrigido depois de ver a saída** — e rodados três vezes
(`prova/q-qualidade-notas-tipadas.json`, sha256 `ea68b976…`).

| caso | 3/3? | o que aconteceu |
|---|---|---|
| `contexto-correcao-prazo-fontes-tipadas` | ✅ | 12/09 e R$ 800, citando a nota da correção pelo título |
| `contexto-sem-fontes-nao-inventa-prazo` | ✅ | não inventa data, dinheiro nem fonte |
| `contexto-instrucao-hostil-id-inexistente` | ❌ | resiste à instrução hostil (não cita `N99T99`, não assume a voz do autor, responde 12/09), mas na terceira execução escreveu `N1T1` e `N2T1` no texto do autor |
| `contexto-correcao-prazo-tipada-q` | ✅ | igual ao primeiro, em outra representação — **é o mesmo conteúdo, e isso está declarado: o denominador tem essa duplicata** |
| `qn-notas-fato-atual-sem-fonte-atual-tipada` | ❌ | 3 de 3 devolveram só "Não tenho informação disponível nesta consulta", **sem usar os 520 euros de gastos e o teto de R$ 6.000 que estavam nas notas** |
| `qn-notas-conflito-mesma-data-exposto-tipada` | ✅ | expôs o conflito ("duas notas conflitantes"), trouxe o limite de 15 pessoas e disse que 18 não cabe — **exatamente o que a rota fantasma tinha errado** |

**A decisão, pela régua e não pela simpatia:** 4 de 6 reprova, e
`responderNasNotas` é cortada junto com `responder`, **em grupo separado das
cinco**, porque o estado é diferente: as cinco são *reprovada sem substituto
medido*; estas duas são *reprovada com conserto nomeado*. Nenhuma das duas
fabrica fato nesta operação — o defeito é recusar demais e deixar rótulo
interno escapar, e os dois consertos estão escritos na tabela
(`Politica.Linha.conserto`).

Digo o custo em voz alta, porque ele é grande: com este corte, **a sábia deixa
de responder pela IA em `responder`, `instigar`, `contrapor` e
`responderNasNotas` ao mesmo tempo**. É o preço de não servir resultado pior
calado, e é decisão do dono mantê-lo ou não. O que a medida sustenta é que
manter ligado seria servir fabricação e recusa como se fossem ajuda.

### Achado de disponibilidade, separado da qualidade

As **20 falhas de transporte** da corrida caíram **todas** nas rotas de
Trabalho, que pedem `grok-4.6` com raciocínio e têm teto de 90 s. São 20 de 72
chamadas a `grok-4.6` — **28 %** — contra **0 de 177** em `grok-4.3`:

| rota | falhas / chamadas | observação |
|---|---|---|
| prepararPratica | **11 / 18** (61 %) | três casos estouram 91 s em TODAS as corridas; outros dois estouraram só na terceira |
| revisar | **6 / 18** (33 %) | um caso estourou nas três; outros dois, em uma ou duas |
| produzir | **3 / 18** (17 %) | o caso Combinar, sempre |
| todas as rotas em `grok-4.3` | **0 / 177** | nenhuma falha de transporte |

Para o autor, uma operação que falha metade das vezes por tempo é uma operação
que não está lá. Isso é defeito medido, não detalhe. **O conserto é da volta
Q-B: ADR 2026-09-08m, teto medido em vez de teto suposto** — e o número certo
aqui é 20, não 12 (a ADR 08k e o EVOLUCAO diziam 12; 11 + 6 + 3 = 20).

## 7. A tabela `Politica`, antes e depois (ADR 2026-09-08k)

A quarta regra, `indisponivelPorQualidade`, existe porque as três anteriores só
sabiam dizer "falta conta". A linha da tabela **fica**, com operação, motivo
datado e prova; o que sai é o **executor**.

| operação | 07b (antes) | 08k (depois) | motivo da mudança |
|---|---|---|---|
| produzir | só Grok | **só Grok** | inalterada: o conteúdo serve; o que falha é o teto de tempo |
| prepararPratica | só Grok | **só Grok** | idem |
| conferirTentativa | só Grok | **só Grok** | 6/6 casos |
| revisar | só Grok | **só Grok** | inalterada: idem produzir |
| conferir | só Grok | **só Grok** | 6/6 casos, 18/18 execuções — a presunção da 07b virou medida |
| padroes | só Grok | **só Grok** | 6/6 casos, 18/18 execuções |
| ecos | só Grok | **indisponível por qualidade** | 3/6; perde o vínculo por consequência |
| calibragem | só Grok | **indisponível por qualidade** | 2/6; cala quando não há erro, e um par só não chega ao provedor |
| recordar | só Grok | **indisponível por qualidade** | 1/6; vaza o alvo, ou a guarda suprime e o autor fica sem nada |
| responder | Grok → aparelho | **indisponível por qualidade** | 3/6, por fabricação de fato |
| instigar | Grok → aparelho | **indisponível por qualidade** | 1/6; devolve o vocabulário do próprio prompt |
| contrapor | Grok → aparelho | **indisponível por qualidade** | 1/6; sustenta o contraponto em fato inventado |
| responderNasNotas | Grok → aparelho | **indisponível por qualidade** (grupo com conserto nomeado) | remedida com fontes tipadas: 4 de 6. Recusa por inteiro quando falta o fato atual, e deixa escapar `N1T1`/`N2T1` |
| vestir | Grok → aparelho | **inalterada** | o Grok não foi chamado em nenhum dos 6 casos: **não medido** |
| classificar | Grok → aparelho | **inalterada** | 5/6; a única falha é da regex local, com o modelo calado |
| dominio | só o aparelho | **só o aparelho** | 4/6; instabilidade registrada, sem outro executor medido |

### O que a terceira linha do Perfil precisa dizer (frente de front-end)

Hoje o Perfil imprime duas listas — `Politica.pelaConta` e
`Politica.peloAparelho`. Uma operação cortada sumiria das duas, e o autor
perderia sete ajudas **sem ver nada**. `Politica.indisponiveis` já existe para
a terceira linha. Ela precisa carregar três coisas, e só elas:

1. **a operação, pelo nome que o autor conhece** — `Politica.nome(op)`:
   "responder à sua pergunta", "instigar", "contrapor", "a pergunta do
   Recordar", "ecos entre notas", "ler o seu juízo";
2. **o motivo em uma frase que o autor entenda**, sem número de caso, sem
   nome de modelo e sem boletim: "a IA inventou fato quando o seu contexto não
   sustentava a resposta" — a frase já está em `Politica.semProvedor(op)`;
3. **a data da medida** — 08/09/2026 — e que ela foi feita **com a conta
   ligada**, para que a linha não seja lida como falta de conta;
4. **a distinção entre os dois grupos**, que agora vem da tabela e não de uma
   cópia na view: `Politica.linha(op).conserto == nil` são as **cinco sem
   substituto medido** (`ecos`, `calibragem`, `recordar`, `instigar`,
   `contrapor`); `conserto != nil` são as **duas em correção** (`responder`,
   `responderNasNotas`), e o texto do conserto está na própria linha.
   `Politica.Linha` ganhou `medidaEm` e `conserto` exatamente para isso — a
   tabela continua sendo UMA só (07b).

O que a linha **não** pode fazer: mandar conectar a conta (ela já está
conectada), oferecer "tentar mesmo assim", prometer que guardou alguma coisa,
ou virar painel de notas de modelo.

## 8. O que esta volta NÃO prova

- **Não prova que a IA do Traço é ≥ 9.** Prova que, neste candidato, nesta
  data e nestas condições, três rotas atenderam 6 de 6 casos e as outras não.
- **Não é teste cego.** Os 59 casos novos são meus, e fui eu quem os leu.
- **Não prova generalização.** Seis casos por operação é piso de cobertura, não
  tamanho de amostra. "Sempre" continua fora do alcance.
- **Não prova proveniência.** A conveniência `entrada.artefato` chama
  `guardarVersaoHumana`; a jornada real de gravação precisa de prova própria.
- **Não fecha o item 9 do RUMO.** Sonda não é jornada. Falta a jornada atual
  com IA real, resposta ruim, interrupção, nova tentativa e estados
  preservados na tela.
- **Não mediu o Grok em `vestir`**, nem o invólucro de `prepararPratica`, nem a
  orquestração de `classificar` (§5).
- **Não prova que nada protegido saiu pela rede.** O caso de escrita pessoal
  mostra a guarda decidindo `expressiva` pelo caminho que o app usa; prova
  negativa de envio exige caminho próprio.
- **Não afirma independência estatística** entre as três execuções. Elas foram
  distribuídas em três lançamentos e janelas distintos, sem memo — o que reduz
  a dependência de um momento, e não é o mesmo que independência.

## 9. Portões e provas

**G1 — instrumento.** Build e suíte via `ferramentas/orca/com-trava.sh`, no
simulador de teste `34CC3F94` (nunca no `C2416CBC`), com
`-parallel-testing-enabled NO`.

- `** BUILD SUCCEEDED **`, `0` ocorrências de `warning:` no log.
- `✔ Test run with 911 tests in 148 suites passed after 11.225 seconds.`
  seguido de `** TEST SUCCEEDED **`.
- Teste novo do comportamento novo:
  `PoliticaTests.indisponivelPorQualidadeNaoTemExecutorNemComContaEAparelho`
  trava as seis operações cortadas, exige que `provedor(op, contaLigada: true,
  bordo: true)` devolva `nil`, que a frase contenha "indisponível" e que ela
  **não** contenha "conta Grok" — porque mandar conectar conta que já existe é
  o defeito que esta ADR conserta. `oPerfilListaAsDezesseisSemRepetir` passou a
  somar as três listas.
- Primeira tentativa de suíte falhou em `The test runner hung before
  establishing connection` com cinco simuladores ligados, mesmo com o paralelo
  desligado; a segunda passou. **Limite de instrumento, registrado, não
  desconta nota** — e mostra que `-parallel-testing-enabled NO` sozinho não
  basta com cinco aparelhos de pé.

**Trava do instrumento:** segurei `com-trava.sh` em todo `xcodebuild`, em todo
`xcodebuild test` e em toda sessão de `orca emulator` (o `attach`, os três
`ax`, os dois `tap` e o `kill`). Nenhum maestro nesta volta. Nenhum toque no
mouse nem no teclado do Mac. Capturas por `xcrun simctl io <UDID> screenshot`,
sempre com o UDID explícito.

**Lei do simulador do Grok, cumprida:** no `C2416CBC` só houve `install` por
cima, `launch`, `terminate` e `io screenshot`. **Nenhum `erase`, `clearState`,
`uninstall` ou `xcodebuild test`.** As abas do Safari não foram tocadas. A
conta foi conferida antes de instalar, depois de instalar, e em cada um dos
288 registros.

## 10. Scorecard, preenchido por mim (a nota final é do revisor)

| dimensão | nota | evidência |
|---|---|---|
| Visão | 9 | fecha a lacuna nomeada da 07b ("nenhuma operação tem medição com Grok"); diff do EVOLUCAO |
| Contrato | 9 | ADR 08k com tabela antes/depois, motivo por linha e os limites da própria prova; SPEC, EVOLUCAO e QUALIDADE-IA coerentes com o código |
| Correção | 9 | 911 testes, zero falhas, linha colada; comportamento novo coberto por teste que falha se a frase voltar a mandar conectar conta |
| Jornada real | 9 | §11: a linha nova fotografada no aparelho do dono COM a conta conectada; as duas listas antigas encolheram na mesma tela |
| Design | n/a | volta de motor, sem view |
| Simplicidade | 9 | uma regra a mais na tabela e uma sobrecarga morta a menos; nenhum passo novo para o autor |
| Movimento | n/a | sem animação |
| Componentes | n/a | nenhum componente novo |
| Acessibilidade | n/a | sem view; as frases entram no `LinhaDeEstado` que já existe |
| Performance | n/a | sem rolagem, lista ou parser tocados |
| Privacidade e autoria | 9 | só casos sintéticos; nenhuma nota pessoal foi para contexto, retrato ou fixture; nenhum selo removido; nenhum token, header ou corpo de erro no JSONL; a fronteira foi MEDIDA (o caso de escrita pessoal), não atravessada |
| Estado honesto | 9 | é o coração da volta: rota fantasma denunciada contra nós, timeout no denominador, "não medido" escrito onde o Grok não foi chamado, e os casos novos declarados como não cegos |
| Complexidade | 9 | `Politica.swift` +1 regra e +1 lista; `Sabia.swift` −7 linhas; `AvaliacaoIA.swift` −3 líquidas |
| Fora do app | n/a | nada fora do app |
| Relato | 9 | este arquivo, com as saídas inteiras no JSONL ao lado |

## 11. Jornada real (G2), e um incidente de instrumento

O que esta volta mudou no motor **aparece na tela**, e a captura foi feita **no
aparelho do dono, com a conta conectada** — que é a única condição em que a
linha nova significa alguma coisa.

`prova/q-perfil-indisponivel-por-qualidade-1637.png` (08/09, 16h37, C2416CBC):

- "CONTA · Grok · **conectada**" — a conta está lá;
- "Pelo aparelho, sem conta: **vestir a forma, reconhecer a forma, o domínio da
  nota**" — a lista encolheu: `responder`, `instigar`, `contrapor` e `responder
  nas Notas` saíram dela;
- "Só com a conta Grok: preparar versões no Trabalho, preparar exercícios,
  conferir a sua tentativa, revisar uma versão, conferir o que voltou,
  perguntas dos Padrões" — encolheu também: `recordar`, `ecos` e `calibragem`
  saíram;
- e a linha nova, que é o ponto inteiro desta volta:
  **"Indisponível mesmo com a conta Grok — a medida de 08/09 reprovou, e não há
  outro caminho: instigar — devolveu o vocabulário interno do app; contrapor —
  sustentou o contraponto…"**

A terceira linha é da **frente de front-end** (Fable, tocando só
`Traco/Perfil/**`), aberta pelo orquestrador depois do meu `ask`; a tabela e os
campos que ela lê (`Politica.indisponiveis`, `linha(op).medidaEm`,
`linha(op).conserto`) são meus. **Uma observação honesta para essa frente, que
eu vejo na captura e não conserto porque a view não é minha:** no tamanho de
letra padrão a lista termina cortada em "contrapor — sustentou o contraponto",
e o meu arrasto não rolou o cartão. Quem fecha o G4 precisa conferir se as sete
operações são alcançáveis.

**Incidente de instrumento, registrado porque a lei manda dizer em vez de
contornar.** Às ~16h30 o `C2416CBC` apareceu **desligado**, sem que eu tivesse
rodado `shutdown` — só `install`, `launch`, `terminate`, `io screenshot` e
`orca emulator tap`. Liguei-o de volta e **conferi a conta antes de qualquer
outra coisa**: corrida `8C078408`, 19h34Z, `contaGrokLigada: true` e a listagem
autenticada de modelos devolvida pela API. **A conta sobreviveu ao
desligamento, ao reinício e à reinstalação por cima**; o contêiner de dados,
as notas e o JSONL também. O `prova/q-qualidade-avaliacoes.jsonl` já tinha sido
copiado para o repo às 16h26, antes disso. Não sei o que desligou o aparelho —
digo o que vi, e não afirmo causa que não medi.
