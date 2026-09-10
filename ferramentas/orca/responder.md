# RESPONDER — o prompt foi a alavanca, e ela NÃO fecha a rota

Volta `Vitorepf/responder`, ADR **2026-09-10b**, sobre `origin/main aabc52d`.
Aparelho da conta: **`B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9`** (teste 2), exclusivo
meu por ordem do orquestrador das 12h40. Suíte no **teste 4, `A1DF082C`**.
**Nenhum `xcodebuild test` tocou aparelho de conta.**

**O veredito, em uma linha: `responder` FICA em `indisponivelPorQualidade`.** Duas
reescritas do pedido foram medidas contra o texto vigente, no MESMO binário, e as
duas ficaram **piores que a base**. O que muda na tela do autor é a linha do
Perfil: o conserto que estava prometido ali **foi tentado e medido**, então ele
sai, e o motivo passa a dizer as DUAS metades do defeito.

**As horas.** Janela 1: fumaça de abertura **15:44:10Z**, conta ligada, 12
modelos; fecho **16:04:17Z**, ligada, 12. Janela 2: abertura **16:18:47Z**,
ligada, 12; **16:18:53Z** pós-install, ligada, 12; fecho **16:38:02Z**, ligada,
12. **Seis fumaças, conta ligada em todas.** Duas instalações (uma por
tentativa), as duas conferidas por `cmp` contra o meu produto de build.

---

## 1. A alavanca, e o que ela NÃO era

A ordem da volta e o G0 da Astra são explícitos: **uma alavanca só, o PROMPT**.
Modelo `grok-4.3`, esforço `medium`, temperatura 0,3, contexto, formato e teto de
saída ficaram **idênticos** aos dos 18 casos da Q2-F.

O que garantiu isso — e é a peça que o orquestrador exigiu quando viu que eu
havia mexido em mais coisa — foi uma costura de sonda: o pedido ANTERIOR passou a
viver no MESMO binário, sob `TRACO_AVALIAR_PEDIDO=base`. Assim **os dois braços
correm o mesmo dylib** e a única variável entre eles é o texto do pedido.

| | base | candidato 1 | candidato 2 |
|---|---|---|---|
| `pedidoResponderSHA256` | `d42d61ea…` | `20a0b7af…` | `72840c9a…` |
| caracteres | 2.235 | 3.065 | 3.632 |
| ocorrências no dylib instalado (busca de bytes) | 2 | 2 | 2 |

Cada registro do JSONL carrega `pedidoResponderSHA256`, então **a corrida diz de
si mesma qual texto mandou** — a Q2-F teve de reconstruir isso procurando 2.235
bytes dentro do dylib.

### A separação que o orquestrador cobrou: alavanca × instrumento

| o quê | por quê existe | mexe na saída que o autor vê? |
|---|---|---|
| **ALAVANCA** — o texto de `sistemaResponder` | é a hipótese em teste | sim, e é o ponto |
| INSTRUMENTO — retorno **bruto** em `Grok.Diagnostico.bruto` | sem ele mede-se o modelo pelo que sobrou do nosso parser (pedido da Astra) | não |
| INSTRUMENTO — `pedidoResponderSHA256` na sonda | identifica o braço | não |
| INSTRUMENTO — identidade da requisição em `perguntarASabia` | defeito de concorrência achado por leitura (pedido da Astra) | não alcança a sonda |
| INSTRUMENTO — divulgação só das vizinhas que couberam | a divulgação não correspondia ao que viajou | não alcança a sonda |
| **MUDA A SAÍDA** — o corte silencioso aos 900 saiu de `limparResposta` | perda silenciosa vendida como resposta completa | **sim** — e é por isso que a base foi **remedida** |

**A base foi remedida nas DUAS janelas, com o mesmo binário de cada candidato.**
Nenhuma das 240 saídas passou de 900 caracteres, então o corte removido **não
alcançou esta medida** — mas isso é fato conferido, não suposição.

---

## 2. A matriz: 20 casos × 3 repetições × 4 braços = 240 saídas, lidas uma a uma

`.` cumpre · `X` descumpre · **negrito** = o caso reprova (um descumprimento reprova)

| caso | base 1 | cand. 1 | base 2 | cand. 2 |
|---|---|---|---|---|
| `q2-gasolina-sem-dado` | ... | ... | ... | ... |
| `q2-gasolina-so-distancia` | ... | ... | ... | ... |
| `q2-gasolina-tres-dados` | ... | ... | ... | ... |
| `q2-biblioteca-sem-horario` | ... | **XX.** | ... | **X.X** |
| `q2-biblioteca-endereco-sem-horario` | ... | **..X** | ... | **..X** |
| `q2-biblioteca-comunicado-14h` | ... | **XX.** | ... | ... |
| `q2-prazo-correcao-explicita` | ... | ... | ... | ... |
| `q2-prazo-conflito-sem-resolucao` | **XXX** | ... | **XXX** | ... |
| `q2-espanhol-geral` | ... | **X..** | ... | ... |
| `q2-relatorio-tres-restricoes` | **XX.** | ... | **XXX** | **X.X** |
| `q2-acordar-cedo` | ... | ... | ... | ... |
| `q2-dado-alem-do-recorte` | ... | ... | ... | ... |
| `revisor-orcamento-cotacao-datada` | ... | **XXX** | ... | **.X.** |
| `revisor-responsavel-nao-definido` | **XXX** | **.XX** | **XXX** | **.XX** |
| `revisor-retomar-sem-suporte` | **X.X** | **.X.** | **XXX** | **X..** |
| `revisor-venda-nao-observada` | ... | **X.X** | ... | **X.X** |
| `revisor-espanhol-sem-material` | ... | ... | ... | ... |
| `revisor-correcao-sem-confirmacao-formal` | **X.X** | ... | **XX.** | ... |
| `10b-relatorio-estrutura-fornecida` | ... | ... | ... | ... |
| `10b-relatorio-sem-indice-nem-busca` | **XX.** | ... | ... | **X.X** |
| **casos cumpridos (de 20)** | **14** | **12** | **15** | **12** |

| pergunta real do aparelho | base 1 | cand. 1 | base 2 | cand. 2 |
|---|---|---|---|---|
| `10b-real-proposta-padaria` (não versionada) | — | XXX | — | .X. |

`prova/10b/10b-base.jsonl`, `prova/10b/10b-candidato.jsonl`,
`prova/10b2/10b2-base.jsonl`, `prova/10b2/10b2-candidato.jsonl`.
Fixture versionada: `prova/10b-casos.json`, sha256 `0af49dc5f5b3…` — os 18 casos da
Q2-F **sem uma palavra reescrita**, mais os dois controles novos.

**Os 240 registros: HTTP 200 em 100 %, `contaGrokLigada: true` em 100 %,
`modeloRespondido: grok-4.3` em 100 %.** Nenhuma falha de transporte, nenhum
`semRetorno`.

---

## 3. O defeito, e por que ele é SIMÉTRICO

As duas reescritas falharam do mesmo jeito, em direções opostas. É um só defeito
com duas faces, e nenhum dos dois textos conseguiu segurar as duas ao mesmo tempo.

**Face A — inventa o documento que nunca viu.** Base, `q2-relatorio`, janela 2:
*"vá direto ao sumário ou índice… Leia só resumos executivos, conclusões e
tabelas"* — três coisas que a pessoa não descreveu. O candidato 1 **matou isso**:
o PDF sumiu das três execuções. O candidato 2 **trouxe de volta**: *"Leia primeiro
o sumário… Use a ferramenta de busca do PDF"*.

**Face B — para em "não consta X" e não ajuda.** `revisor-orcamento-cotacao-datada`
caiu de **3 de 3** na base para **0 de 3** no candidato 1: ele faz a conta certa
(R$ 2.184 contra o teto de R$ 5.000), nomeia os quatro dados que faltam, e acaba
em *"não é possível aprovar hoje"* — sem um passo. `revisor-venda-nao-observada`
caiu por idêntico motivo. O candidato 2 devolveu a continuação (*"Abra o orçamento
e solicite por escrito os quatro itens"*) e foi a Face A que voltou.

**O caso decisivo é `revisor-responsavel-nao-definido`** — o caso que era cego do
revisor, revelado, e agora regressão obrigatória. Ele reprova **1 de 3 nas duas
tentativas**, e o que falta é sempre a mesma metade:

| | o que saiu |
|---|---|
| base (r1) | *"verifique com Marina ou com quem combinou a reunião"* — inventa a reunião e "quem combinou" |
| candidato 1 (r1) | *"Não consta quem apresentará a proposta. **Decida e registre.**"* ✓ |
| candidato 1 (r2, r3) | para em *"sem decisão anotada"*, sem nenhum passo ✗ |
| candidato 2 (r1) | *"…não registrou decisão nem nome do apresentador. **Decida e anote o nome.**"* ✓ |
| candidato 2 (r2, r3) | para em *"não há anotação sobre quem apresentará"* ✗ |

A distinção que a Astra pediu — *"não consta quem apresenta"* × *"ninguém foi
escolhido"* — **o pedido conseguiu ensinar**. A continuação, não: ela aparece numa
execução e some nas outras duas.

### A armadilha da Q4-C, e desta vez fui eu quem a armou

A Q4-C tinha pago para aprender: **promover um requisito para morder no caso pobre
o faz virar acréscimo ou teto no caso rico.** Aqui foi a mesma lei ao contrário.

Eu escrevi, no candidato 1, *"diga ONDE ela confirma pelo nome e endereço que ela
deu"* — pensando no caso em que ela DEU nome e endereço. No caso em que ela não
deu nada, o modelo **afirmou que ela tinha**:

> base, `q2-biblioteca-sem-horario`: *"Busque no site da prefeitura local ou no Google 'horário biblioteca municipal [seu bairro] [sua cidade] hoje'"* ✓
> candidato 1: *"Confirme pelo nome e endereço da biblioteca municipal do seu bairro **que você tem**"* ✗

3 de 3 para 1 de 3. No candidato 2 eu condicionei a cláusula (*"o nome, o endereço
ou o documento que ela TIVER dado"*) e **ainda assim** 2 de 3 afirmaram. Uma
cláusula que nomeia um dado ensina o modelo a supor que o dado existe, mesmo
condicionada.

---

## 4. A pergunta REAL do aparelho da conta

Escolhida **pelo propósito dela** entre as 18 notas que vivem no `B91C8DEF`, sem
semear resposta e **sem substituir nem escrever nenhuma nota** — a nota
"Proposta para o cliente da padaria" (Especificação, `problema: cardápio
desatualizado`, *"Precisam de um cardápio que atualize sem programador"*), com a
pergunta que o autor deixaria nela: **"? o que eu preciso definir antes de mandar
essa proposta"**, e as vizinhas reais que o seletor traria.

**Os dados reais NÃO estão versionados** (DIRETRIZ: caderno pessoal não vai para
prova em git). Modo 600, em `~/orca/prova-restrita/responder/`: a fixture
`10b-real.json` (sha256 `0997ec346bed…`) e os JSONL brutos das duas corridas,
`10b-real-saidas.jsonl` e `10b2-real-saidas.jsonl` — **a sonda grava a `entrada`
inteira em cada registro, então o JSONL cru carregava o texto das notas do
aparelho.** O que ficou em git é a versão redigida (`prova/10b/10b-real-redigido.jsonl`
e `prova/10b2/10b2-real-redigido.jsonl`): hora, duração, conta, sha do pedido, sha
do bruto, o **sha256 e o tamanho** do contexto, e a resposta do modelo. **A nota
não entra; a resposta entra**, porque sem ela ninguém pode conferir a minha
leitura — e a resposta é do modelo, não do autor.

| | veredito |
|---|---|
| candidato 1 | **0 de 3.** Em 2 de 3 a vizinha "Ideia: um caderno que responde" e o *"fechar o orçamento"* do "Plano da semana" entram na proposta da padaria **como se fossem plano dela** — exatamente a falsa intimidade que a Astra previu e que fixture curta não pega. |
| candidato 2 | **2 de 3.** A r1 e a r3 nomeiam o que falta de verdade (mecanismo de atualização, quem altera, frequência, formato atual, restrições técnicas, orçamento e prazo) sem inventar a resposta do cliente. A r2 ainda puxa as duas vizinhas, mas agora **atribuídas** (*"conforme sua nota sobre servidor"*), o que é honesto e não é o defeito. |

É o único lugar onde o candidato 2 é claramente melhor que a base — e não basta.

---

## 5. Os defeitos LOCAIS que esta volta fechou (e que não são a alavanca)

Estes são consertos de código com vermelho e verde na rota real, provados no teste
4 **antes** de a conta ser ocupada. `TracoTests/RespostaNaPaginaTests.swift`, 13
testes novos. **Sete deles ficam VERMELHOS na árvore sem o conserto** — corri a
suíte com os quatro consertos revertidos e colei a saída:

| teste | o que acusa sem o conserto |
|---|---|
| `retornoAtrasadoDeAnaoPublicaNaPerguntaDeB` | `.resposta(A)` publicada sobre o cartão de B |
| `oContextoEODaNotaQuePerguntou` | `contexto?.contains("A proposta vence dia 12.") → false` |
| `aDivulgacaoNomeiaSoAsVizinhasQueCouberam` | `r.viajaram → ["Cabe", "Não cabe"]`, e `contexto.count → 5466 > 5000` |
| `vizinhaQueNaoCabeFicaDeForaInteiraComORotulo` | `r.viajaram → ["Alguma"]` |
| `aRespostaLongaChegaInteiraComARessalvaDoFim` | `limpa.count → 900 == longa.count → 1123` |
| `aFalhaDeixaAPerguntaNoCartaoComRecuperacao` | `s.cartao → nil` |
| `fonteSeladaDuranteAEsperaNaoPublicaAResposta` | `.resposta(…)` publicada com a fonte já trancada |
| `respostaChegaInteiraESemMarkdownPesado` (existente, reescrito) | `r?.hasSuffix("…") → true` |

Os outros seis testes são as **irmãs que NÃO acusam** — `todasCabemQuandoOCadernoEPequeno`,
`aLimpezaDeMarkdownEODescarteDoVazioFicam`, `aVizinhaLigadaViraFonteComAssinatura`,
`aNotaNaoMudaAntesNemDepoisDaResposta`, `expressivaNaoPerguntaEOMotorRecusa`,
`semExecutorOCartaoGuardaAPergunta` — verdes nos dois lados, para o portão não
passar por acaso.

### 5.1 A raiz de por que estes defeitos sobreviveram sete voltas

`Sessao.perguntarASabia` era **inalcançável pela suíte**: no simulador de teste
não há conta Grok e `Motores.desligados` derruba o aparelho, então toda chamada
parava na primeira linha. `disponivel:` e `aviso:` passam a chegar por parâmetro,
com o padrão da produção — o mesmo desenho de `ConversaNotas.perguntar(disponivel:)`,
que já existia. **Superfície sem prova é o irmão do motor sem tela.**

### 5.2 O que cada conserto é

1. **Identidade da requisição.** O guarda era `guard case .sabiaPensando? = cartao`
   — "algum" pensando, e *algum* inclui a pergunta seguinte. Passa a ser um `UUID`
   por tentativa, o padrão de `ConversaNotas.tentativa`. Nenhuma arquitetura nova.
2. **A página se lê JUNTO da pergunta**, não depois do `await`. Com o teto do
   modelo em minutos, abrir outra nota durante a espera deixou de ser hipótese.
3. **Revalidação de acesso antes de publicar**, com `Sessao.dependenciasValidas` —
   a mesma guarda do `responderNasNotas`. Selar, apagar ou editar uma vizinha
   durante o `await` recolhe a resposta.
4. **A divulgação corresponde ao que viajou.** `Sabia.contextoDaPergunta` monta o
   contexto e devolve **os títulos que couberam**; antes o cartão nomeava, para a
   rede, notas que o corte de 5.000 nunca deixou sair do aparelho.
5. **A falha fica junto da pergunta.** Era `cartao = nil` mais um toast que passa:
   depois de minutos de espera, o autor voltava à página sem cartão e sem caminho
   de volta. Agora volta ao `.pergunta`, o mesmo cartão do cancelamento (09n).
6. **O corte silencioso aos 900 saiu.** A parte que morria era sempre a última, e
   é lá que mora a ressalva. Os 900 continuam no PEDIDO; o cartão já rola.
7. **O retorno BRUTO é preservado**, e no PORTÃO por onde as dezesseis rotas
   passam (`Grok.Diagnostico.bruto`, DEBUG) — não numa guarda por chamador.

---

## 6. O que muda na tela do autor

`responder` **não sai** da lista do Perfil. Mas a linha que ele lê muda, e a
mudança é medida:

**Antes**
> responder à sua pergunta — inventa uma situação que você não escreveu · falta ela parar de inventar também a estrutura do documento que você pediu

**Depois**
> responder à sua pergunta — inventa uma situação que você não escreveu, e às vezes só diz o que falta

Duas coisas mudaram:

1. **O conserto SAIU.** Ele dizia *"falta ela parar de inventar também a estrutura
   do documento que você pediu"* — e é exatamente isso que estas duas tentativas
   fizeram, medidas. Manter a frase seria prometer ao autor um conserto que já
   falhou. `responder` muda do grupo "já sabemos o que falta" para o grupo "não
   faz, e não sabemos o conserto".
2. **O motivo ganhou a segunda metade.** A Face B — parar em "não consta X" — é um
   defeito que o autor SENTE e que a tela não dizia.

A frase do ponto de toque (`Politica.semProvedor`) acompanha, e continua sem data,
sem jargão e sem mandar conectar conta que já existe.

**A frase que a Astra propôs para o Perfil — "Responde às perguntas que você deixa
nas notas." — NÃO foi adotada, e não por gosto:** ela é palavra por palavra o que
a linha de `responderNasNotas` já diz na mesma tela (*"Responder as perguntas que
você deixa nas notas precisa da sua conta Grok"*). Adotá-la literalmente faria o
Perfil dizer a mesma coisa duas vezes para duas operações diferentes. A questão
fica aberta para quando `responder` voltar: as duas precisam de nomes que o autor
distinga (a linha `?` na própria nota × a barra das Notas).

**Não há captura de cartão com resposta**, porque não houve resposta nova a
mostrar — o fecho de tela é para quando o mérito passa.

**A linha do Perfil, essa, foi VISTA:**
`ferramentas/orca/10b-perfil-responder-fica-na-lista-large.png`, tema claro,
tamanho `large`, 14h15 de 10/09. Ela mostra `responder` no grupo *"O que ela ainda
não faz, nem com a sua conta ligada"* — quatro linhas agora, era três — e as duas
metades do defeito na frase. O grupo *"Também não faz ainda, e já sabemos o que
falta"* ficou com `instigar` e `contrapor`, que continuam tendo conserto escrito.

A captura é do **teste 4** (`A1DF082C`), não do aparelho da conta, e de propósito:
esta lista é montada de `Politica.indisponiveis`, que **não depende da conta** — a
linha é a mesma nos dois aparelhos, e fotografá-la ali poupou uma terceira
instalação no `B91C8DEF`. O binário fotografado é o do fecho desta volta,
conferido por `cmp` contra o meu produto de build. A frase também é afirmada pelo
caminho da própria tela (`PerfilView.reprovadas` → `linhaDa`) em `PoliticaTests` e
`PerfilQualidadeTests`, então o portão morde mesmo sem a foto.

---

## 7. Instrumento

| | janela 1 | janela 2 |
|---|---|---|
| `Traco` instalado | `34bb498b…` | `382aa06c…` |
| `Traco.debug.dylib` | `681a249f…` | `ff0db024…` |
| `cmp` contra o meu produto | idêntico | idêntico |
| instalações | 1 | 1 |
| conta antes / depois / fim | ✓ 12 / ✓ 12 / ✓ 12 | ✓ 12 / ✓ 12 / ✓ 12 |

- **Build LIMPO** (`clean build`), **0 erros**, **2 linhas de warning**, ambas o
  herdado conhecido de `NotasView.swift:814`. Nenhum warning novo.
- **Suíte: `Test run with 1038 tests in 164 suites passed after 146.578 seconds`**,
  no teste 4. Antes desta volta eram 1.025 em 163 suítes; as 13 novas são as de
  `RespostaNaPaginaTests`. Nomes exclusivos meus executados e verdes:
  `retornoAtrasadoDeAnaoPublicaNaPerguntaDeB`, `aDivulgacaoNomeiaSoAsVizinhasQueCouberam`,
  `fonteSeladaDuranteAEsperaNaoPublicaAResposta`, `aRespostaLongaChegaInteiraComARessalvaDoFim`.
- **Latência:** média 9,1–10,2 s por braço, **pior caso 52,2 s** (candidato 1,
  janela 1). A guarda de 60 s que o orquestrador armou **não disparou**, e o teto
  de `Grok.teto = 240 s` **nunca mordeu**: o pior caso tem 4,6× de folga. Por isso
  esta volta abriu a janela sem esperar o conserto de teto da volta TEMPO, com o
  número na mão e com a autorização do orquestrador registrada no run.
- **`xcodegen generate` foi necessário e eu quase não o fiz**: a primeira corrida
  da suíte deu 1.025 verdes com o arquivo de teste novo **fora do projeto** — o
  vigia não enxergava nada e reportava zero. É o defeito "portão que conta a forma
  certa" outra vez, e só a contagem antes/depois (1.025 → 1.038) o pegou.

### Limites, declarados

- **O `B91C8DEF` foi DESLIGADO por alguém às 16:08:19Z**, no meio da minha janela
  2 (`Unable to lookup in current state: Shutdown`). Não fui eu — nunca chamei
  `shutdown` nem `kill`. A janela abortou **antes** do install (o log diz
  `INSTALL FALHOU`), religuei só o meu UDID às 16:18:39Z, e **a conta sobreviveu**:
  12 modelos antes e depois. Avisado ao orquestrador na hora.
- **A minha leitura é mais dura que a da Q2-F em duas linhas.** A Q2-F leu o
  `grok-4.3` como 15 de 18 e passou `revisor-retomar-sem-suporte` e
  `revisor-correcao-sem-confirmacao-formal`; eu reprovo os dois na base, por
  "Abra Drive, Dropbox, OneDrive" sem condicionar e por exigir confirmação extra
  depois de uma correção explícita. **A base deste relatório é a que EU li**, nas
  mesmas 240 saídas, com a mesma régua nos quatro braços.
- **Três repetições não medem estabilidade**, medem que ela existe: entre as duas
  janelas a base variou de 14 para 15 (o controle de recursos negados passou 3/3
  na segunda e 1/3 na primeira). A conclusão não depende dessa variação — os
  candidatos ficam abaixo das duas bases.
- **Os 18 casos não são cegos para mim**: eu os li antes de rodar. O caso do
  responsável foi revelado por ordem da volta e virou regressão. **O revisor
  guarda um caso realmente novo**, e é dele a leitura independente.
- **Sem VoiceOver, sem voz, sem iPad, sem tamanho de letra de acessibilidade.**

---

## 8. Scorecard (preenchido por mim; a nota final é do revisor independente)

As cinco dimensões de `QUALIDADE-IA.md`, lidas **por saída**, sobre os 4 braços:

| dimensão | base | candidato 1 | candidato 2 | o que decide |
|---|---:|---:|---:|---|
| aderência ao pedido | 7 | 6 | 6 | os candidatos entregam menos do que o caso pede (`revisor-orcamento` 0 de 3 no c1) |
| correção sustentada | 7 | **8** | 7 | o c1 mata o PDF inventado nas 3; o c2 o traz de volta em 2 de 3 |
| utilidade concreta | 7 | 5 | 6 | é a face B: nomear a carência e parar |
| destinatário e divisão de trabalho | 8 | 7 | 7 | o c1 devolve a escolha da divisão para ela (`q2-espanhol-geral`) |
| uso do contexto pertinente | 7 | 6 | 7 | a pergunta real: vizinha virando plano do autor, 2 de 3 no c1 |
| **casos cumpridos (de 20)** | **14 / 15** | **12** | **12** | um descumprimento reprova o caso |

**Nenhuma dimensão chega a 9 em nenhum braço, e nenhum braço chega a 20 de 20.**
`responder` fica cortada.

### O que esta volta entrega, então

O retorno da operação **não**. O que entrega:

1. **A alavanca do prompt está medida e descartada, com número** — a próxima
   tentativa não repete estas duas, e sabe por quê.
2. **Sete defeitos de rota consertados com vermelho e verde**, incluindo um risco
   de concorrência que a fixture não pegava e que a Astra identificou por leitura:
   o cartão podia responder à pergunta que já não era a atual.
3. **A superfície ficou testável.** O corpo de `perguntarASabia` era inalcançável
   pela suíte; agora não é.
4. **O retorno bruto passa a ser preservado nas dezesseis rotas**, no portão.
5. **A tela do autor parou de prometer um conserto que já falhou.**

### A recomendação, para quem pegar a bola

A ordem da Astra continua valendo e a próxima alavanca é o **CONTEXTO**, não o
esquema. A razão está nos números acima: metade do que sobrou é o modelo **falando
de um documento que ele nunca viu**. Nenhum texto de pedido conserta isso, porque
o pedido não pode substituir a informação que não viajou. `Sessao.contextoDoCaderno`
junta ligações, vizinhas e ecos **antes** do corte de 5.000 — e a Q2-F já tinha um
caso (`q2-dado-alem-do-recorte`) em que o dado decisivo fica do lado de fora.

**Não é limite do instrumento; é limite do PRODUTO**, e não absolve Utilidade nem
Contexto.
