# Achados do catálogo — contrato de colagem e pedidos de app

Trilha Métodos · M1 a M9 · reorganizado em 06/09/2026.

> **Reorganizado na volta M5.** Nada do contrato mudou de conteúdo: a regra de
> ordem, o conserto do Se–então e as provas exigidas continuam com as mesmas
> palavras. O que mudou é a arrumação — o que se repetia entre as rodadas foi
> juntado, e cada item ganhou **estado**: resolvido, em curso ou aberto. Quem
> está executando a M3 e já leu a versão anterior: o que você leu continua
> valendo.

## Como usar este arquivo

| se você vai… | leia |
|---|---|
| colar métodos no `Metodos.json` | **Parte I** inteira, antes de abrir o arquivo |
| abrir uma volta de app a partir da trilha | **Parte III** |
| entender por que um roteamento erra hoje | **Parte II** |
| escrever a proveniência de um método | [`regua-da-proveniencia.md`](regua-da-proveniencia.md) |
| colar a leva 2 | [`leva-2.md`](leva-2.md), que basta sozinho |
| entender o critério da trilha inteira | [`o-que-a-trilha-aprendeu.md`](o-que-a-trilha-aprendeu.md) |
| decidir o que a trilha caça a seguir | [`o-que-falta-no-catalogo.md`](o-que-falta-no-catalogo.md) |
| saber o que as provas da trilha garantem | **Parte IV** |

## Estado da trilha (fonte única — se divergir de outro arquivo, vale este)

| método | rodada | estado |
|---|---|---|
| Subtração, Coluna da esquerda, Classe de referência, Cinco porquês | M1 | **aprovados; a M3 está colando** |
| A pergunta de Hamming, O que se vê e o que não se vê, Exame da noite | M2 | **aprovados; a M3 está colando** |
| A nota do fato contrário, Ordem de grandeza, Começaria hoje? | M4 | **aceitos** (leva 2) |
| O combinado, O ponto que decide | M5 | **aceitos** (leva 2) |
| O que se repetiu | M6 | **aceito** (leva 2) |
| A regra que eu faço, A reparação | M7 | **aceitos** (leva 2) |
| Ver antes de nomear, O que não está lá | M9 | **propostos**, gosto não decidido — os dois de **grau A** |
| Matriz de Eisenhower, Cerca de Chesterton, Considerar o oposto, Critérios de parada, Sanduíche de feedback, Afirmações positivas, Revisão anual, Carta ao eu do futuro, Teste do jornal de amanhã, Regra de ouro, Escada de inferência, Observação sem avaliação | M1–M9 | **rejeitados**, com ficha e motivo |

Dezessete propostos, **doze rejeitados**, sete na leva 1 (com a M3), oito na
[leva 2](leva-2.md) e dois esperando gosto.

**O mapa das faculdades está em
[`o-que-falta-no-catalogo.md`](o-que-falta-no-catalogo.md)** — o que a coleção
cobre bem, o que cobre por acidente, onde o autor fica na mão, e os três tetos de
crescimento (o primeiro deles já estourado, no código).

**Os oito da leva 2 estão empacotados para colar em [`leva-2.md`](leva-2.md)** —
JSON final, grau declarado, encadeamentos e frases de teste. Quem colar não
precisa abrir as fichas.

**Antes de escrever ou colar qualquer ficha, leia a
[régua da proveniência](regua-da-proveniencia.md)** — resumida no brief do papel
(`ferramentas/orca/papeis/pesquisador-metodos.md`) desde a M7, e completa aqui — os cinco graus de origem, o
que cada um obriga a dizer na tela, e a auditoria dos 21 que já estão no
catálogo (três não passariam hoje, e o conserto é de três frases).

## A regra do roteador (o que torna a ordem um contrato)

`Traco/Analise/AnaliseLocal.swift`, `detectarGesto`: o catálogo é percorrido **na
ordem do arquivo** e vence o **primeiro** método cuja regex casa no texto em
minúsculas. A Expressiva só é considerada acima de 120 caracteres. O Destaque não
tem regex: é reconhecido pela forma (três ou mais linhas curtas), em código.

**Ordem no arquivo é comportamento.** Não é estilo, não é organização.

---

# PARTE I — CONTRATO DE COLAGEM

Vale para toda leva, não só para a M3.

## I.1 Onde colar — **regra permanente**

Métodos novos entram **no FIM do array**, na ordem em que a ficha os lista. Os
objetos estão prontos, no bloco ```json de cada ficha em
`ferramentas/orca/metodos/<id>.md`.

Copie o bloco inteiro, sem reescrever. As regex têm `\b` e acentos já testados;
retocar à mão é a maneira mais fácil de estragar a prova.

**Encadeamentos entre métodos da mesma leva** (por exemplo, Classe de referência
→ Cinco porquês e Cinco porquês → Subtração, entre os quatro da M1) só nascem
vivos se a leva inteira for colada. Colar menos métodos do que a ficha prevê
exige tirar os encadeamentos que apontam para quem ficou de fora — ver I.4.

## I.2 Por que no fim, e o que NUNCA fazer — **regra permanente**

**Nenhum destes quatro pode ser colado antes da Expressiva.** Está medido, na
M1 e reconferido na M2:

| ordem testada | resultado |
|---|---|
| os quatro **no fim** | 0 falso positivo, 0 regressão |
| os quatro **antes da Especificação** | dois erros novos, e um é grave |

O erro grave: a **Coluna da esquerda passa a roubar o desabafo da Expressiva**.
Esta frase de teste deixa de ser Expressiva e vira formulário:

> "na reunião com o chefe eu senti uma raiva enorme, doeu ficar ali, fiquei
> calado o tempo todo e chorei depois no corredor, foi pesado demais para mim"

A Coluna da esquerda casa nela por duas regex (`\bfiquei calad[oa]\b` e
`\bna reuni[ãa]o com\b`), e só não a rouba porque a Expressiva vem antes. A
proteção da escrita pessoal, aqui, **é a ordem do arquivo** — não há guarda em
código que salve se a ordem mudar.

**Regra permanente, para esta volta e para as próximas:** nenhum método cuja
regex mencione conversa, silêncio, arrependimento ou sentimento entra antes da
Expressiva. Isso vale para a Coluna da esquerda (M1) e valerá para o Exame da
noite (M2), se o dono o aprovar.

Se algum dia for necessário mexer na ordem, a prova a rodar antes é a do bloco
de falso positivo do script da rodada, e o critério de aprovação é único:
**nenhuma frase longa com palavras de sentimento pode sair da Expressiva.**

## I.3 O conserto da regex do Se–então — **EM CURSO NA M3** (aprovado pelo dono)

Hoje, no `Metodos.json`:

```json
"roteamento": ["sempre que|toda vez|não consigo parar"]
```

Sem `\b`, **"sempre que" casa dentro de "sempre quebra"** — e também de "sempre
queria", "sempre quero", "sempre quebrou". Foi assim que a frase "sempre quebra
no mesmo ponto, qual é a causa", que é dos Cinco porquês, foi parar no Se–então.

Trocar por:

```json
"roteamento": ["\\bsempre que\\b|\\btoda vez\\b|\\bnão consigo parar\\b"]
```

Conferido nesta rodada, com o catálogo inteiro montado (21 + os quatro
aprovados + os três da M2), antes e depois da troca:

```
seEntao          -> seEntao          «sempre que abro o telefone na cama eu perco uma hora»
seEntao          -> cincoPorques     «sempre quebra no mesmo ponto, qual é a causa»
seEntao          -> colunaEsquerda   «sempre queria ter dito o que pensei»
```

O Se–então continua pegando tudo o que é dele ("sempre que…", "toda vez…", "não
consigo parar…") e devolve o que nunca foi. Em todo o corpus de frases das duas
rodadas, a correção **não muda mais nenhum roteamento**. Compila — que é o que o
teste `todaRegexDoCatalogoCompila` cobra.


## I.4 Encadeamento sem destino — **regra permanente**

`Sessao.encadear` sai em silêncio quando o método de destino não está no
catálogo (`guard let destino = Gesto(rawValue: para), destino.conhecido`), mas a
UI desenha um botão para **cada** encadeamento e só o apaga por `exige`. Destino
inexistente = **botão que acende e não faz nada**.

> **Um encadeamento só entra na mesma leva do destino, ou depois dele.**

O mapa de quem aponta para quem, e o que espera a leva seguinte, está em
[`encadeamentos.md`](encadeamentos.md). **Estado:** a M3 levou isto para o nível
do dado (nenhum encadeamento colado aponta para id inexistente, com teste que
trava). No nível da tela — filtrar o botão por destino conhecido — virou volta
própria; ver III.5.

## I.5 O que provar antes de mesclar, em qualquer leva

1. **Suíte integral verde** no simulador de teste, via `com-trava.sh`. Nenhuma
   volta desta trilha rodou suíte: as rodadas de pesquisa não abrem simulador
   nem `xcodebuild`. **O G1 é da volta de colagem.**
2. `todaRegexDoCatalogoCompila` passando com as regex novas.
3. As frases de teste das fichas roteando para o método certo **no app**, e não
   só no script — em especial a frase de desabafo de I.2, que tem de continuar
   caindo na Expressiva.
4. Os métodos aparecendo no Perfil com a proveniência (fonte, função, adaptação,
   evidência, aplicabilidade), que é o que a volta 16 entregou.
5. **Nenhum botão morto na linha "DEPOIS DISTO"** (I.4).

---

# PARTE II — ACHADOS ABERTOS

## II.1 Cinco desvios que já existem hoje — **ABERTO, e a colagem não deve tocar**

Medidos contra os 21 do branch da volta 16, **sem nenhum candidato no
catálogo**. Não são causados por esta trilha, e a diferença com e sem os
candidatos das duas rodadas é **zero**.

| a frase do autor | vai para | deveria ir para | por quê |
|---|---|---|---|
| "resumir a ideia em 100 caracteres e depois numa frase" | Nota permanente | Destilar | `ideia` casa antes, e a Nota permanente vem antes no arquivo |
| "quero fazer um pré-mortem do lançamento de novembro" | WOOP | Pré-mortem | `(?m)^quero` |
| "quero entender de verdade como funciona a compressão" | WOOP | Feynman | `(?m)^quero` |
| "quero desmontar isso até os primeiros princípios" | WOOP | Primeiros princípios | `(?m)^quero` |
| "quero treinar o pedaço da fala que sempre falha" | WOOP | Prática deliberada | `(?m)^quero` |

Quatro dos cinco são o mesmo: **`(?m)^quero` do WOOP engole qualquer frase que
comece com "quero"**, e o dono começa muita frase com "quero".

**Isto NÃO está aprovado e a M3 não deve mexer nisso de passagem.** Muda
comportamento de um método que o dono usa, e a escolha é dele. As duas saídas,
com o risco de cada uma:

1. **Estreitar o WOOP** — `(?m)^quero (parar|começar|voltar a|conseguir)\b` e
   afins, deixando "quero entender", "quero treinar" e "quero fazer um
   pré-mortem" caírem em quem é dono deles. Risco: um desejo escrito de forma
   inesperada deixa de abrir o WOOP. **É a recomendação**, porque não mexe na
   ordem e o efeito é local.
2. **Mover o WOOP para depois** dos métodos com regex específica. Risco: mexe na
   ordem, que é comportamento — e a regra de I.2 passa a ter de ser
   reconferida inteira.


## II.2 O aviso que interrompe sem dizer de onde vem — **ABERTO**

`AnaliseLocal.avisoWood` ("Afirmação sem prova não gruda") cita um estudo no nome
da constante e não o diz a ninguém — e a frase vai um passo além do que a fonte
sustenta. Ficha completa, com a citação literal, o que o estudo não afirma e o
**texto exato proposto**, em [`aviso-wood.md`](aviso-wood.md). É volta de app,
não de catálogo.

## II.2b Seis frases que afirmam sobre as pessoas — **ABERTO** (M8)

A segunda auditoria (eixo da alegação de eficácia) achou seis frases de
`movimento` em que o app afirma um fato sobre as pessoas na própria voz e sem
fonte — todas da forma *"o passo que todo mundo pula"*. Não é promessa de
resultado (o catálogo é limpo nesse eixo); é a mesma espécie do `avisoWood`.
Frase de hoje e frase corrigida, prontas para colar, em
[`auditoria-eficacia.md`](auditoria-eficacia.md). Duas eram minhas e já foram
corrigidas nas fichas.

## II.3 Três fichas com proveniência inflada — **NA M3** (conserto de três frases)

A auditoria da M6 achou três métodos dos 21 cujo **grau declarado está acima do
real**: **Decisão** (cita Kahneman e Klein 2009, artigo que não contém diário de
decisão nenhum), **Primeiros princípios** (obra de Aristóteles colada a um
procedimento moderno que não está nela) e **Inversão** ("discursos (1986 em
diante)", que não localiza nada, mais uma frase atribuída a Jacobi sem essa
palavra).

**Estado (M7):** o dono mandou as três correções para a M3, que é quem está com
o `Metodos.json` aberto. Nenhum é motivo de retirar método. O conserto são três
frases no campo `fonte` / `adaptacao`, sem tocar em código, sem mexer em ordem,
sem risco de roteamento — **as três estão escritas, prontas para colar**, em
[`regua-da-proveniencia.md`](regua-da-proveniencia.md). Cabe em qualquer volta de
colagem, e só fica mais cara com o tempo, porque cada método novo herda o padrão
do que já está lá.

## II.4 A análise de bordo só conhece DEZ métodos — **ABERTO, e é teto de crescimento** (M9)

`AnaliseDeBordo.GestoDeBordo` é uma enum `@Generable` escrita à mão com dez
métodos mais `nenhum`. O modelo de bordo — o que roda sem conta e sem rede — não
sabe devolver nenhum dos onze outros já colados, nem nenhum dos propostos. E em
`Sessao.escolher` **o veredito do modelo vence a regex**, então o bordo pode
sobrescrever um roteamento correto do catálogo por um rótulo mais grosso.

O comentário do próprio arquivo diz que os dois motores "têm de rotear igual,
senão ligar a conta mudaria o comportamento do app". **Hoje ligar a conta muda.**
Não é descuido — a geração guiada de bordo precisa de esquema estático, e o
remoto monta o prompt do `Catalogo.todos` porque pode. É volta de app, e é a que
mais rende: enquanto isto existir, **cada método novo é meio método**.

Análise completa, com os outros dois tetos, em
[`o-que-falta-no-catalogo.md`](o-que-falta-no-catalogo.md).

## II.5 A regex larga da Especificação — **ABERTO** (M9)

`\b(feature|sistema|api|tela|site|função|app|módulo|construir)\b` vence qualquer
método cujo objeto seja uma tela, um app ou um sistema. Medido nesta rodada com o
"Ver antes de nomear": a frase "o que eu vi foi a tela travada por seis segundos"
vai para a Especificação. É a mesma classe dos cinco desvios de II.1 e o conserto
é o mesmo — estreitar a lista de palavras. Não aprovado; a colagem não deve tocar.

---

# PARTE III — O QUE A FORMA LIVRE ESTÁ PEDINDO DO APP

Escrito na M4, atualizado na M5, para quem vai implementar — não para quem já
sabe.

O dono soltou a barra da forma na M1 ("a forma é livre; se ela exigir algo que o
app ainda não faz, diga na ficha"). Doze métodos propostos depois, os pedidos se
repetem, e repetição é o sinal: **não é um método querendo um enfeite, são vários
querendo a mesma peça.**

Sou pesquisador, não implementador: o custo abaixo é estimativa de fora, para
ajudar a ordenar, não promessa. Onde eu li o código, digo o arquivo.

## III.1 Campo repetível — pedido por QUATRO métodos

**O que é.** Um tipo de campo que o autor pode repetir: uma linha, um botão
"mais um", e o rótulo numerado. Hoje `CampoForma` é uma lista fixa declarada no
JSON (`id`, `rotulo`, `teto`, `soDepois`), em `Traco/Modelo/Metodo.swift`.

**Quem pede:**

| método | o que seria repetível | o que faz hoje |
|---|---|---|
| Divergência (**já no catálogo**) | as dez opções | um campo de texto, "uma por linha" |
| Cinco porquês (M1, aprovado) | os porquês, até a causa ser controlável | cinco caixas numeradas fixas |
| Classe de referência (M1, aprovado) | os casos parecidos, com desfecho | um campo, "uma por linha" |
| Ordem de grandeza (M4) | os fatores, com o palpite de cada um | um campo, "um por linha" |

**O que o autor ganha.** Três coisas que "uma por linha" não dá: (a) o app sabe
CONTAR — a Divergência pode cobrar "você parou na terceira, faltam sete", que é
o movimento inteiro dela; (b) cada item vira uma unidade que o Recordar pode
esconder uma a uma, em vez de sumir com o bloco; (c) a cadeia dos Cinco porquês
para quando o autor para, sem duas caixas vazias acusando quem parou no terceiro
porquê — que é o certo, segundo a crítica publicada do método.

**Custo, de fora.** É a mais barata das quatro e a que serve a mais gente: uma
chave nova no `CampoForma` (algo como `repete: true` com rótulo modelo), o
armazenamento (hoje `campos` é `[String: String]` — o caminho barato é continuar
guardando uma string com quebras de linha e repetir só na tela), e a view. Nada
disso mexe em disco, corpus ou export se a string continuar sendo a verdade.

**O que eu NÃO estou pedindo:** editor de lista com arrastar, reordenar, apagar
por gesto. Uma linha, um "mais um", e pronto.

---

## III.2 Compromisso recorrente — pedido por DOIS métodos

**O que é.** Hoje `Encadeamento.Compromisso` tem `titulo`, `campo` e `dias`:
marca UM evento, uma vez, dali a N dias (`Sessao.encadear`, que grava no
calendário). Falta o compromisso que volta sempre.

**Quem pede.** A Pergunta de Hamming (M2) quer a sexta-feira dos grandes
pensamentos — Hamming reservava 10% do tempo, toda semana, e é isso que faz o
método existir em vez de virar uma nota bonita. O Exame da noite (M2) quer toda
noite, que é a prática de Sêneca literalmente.

**O que o autor ganha.** Um método de RITMO deixa de depender de o autor lembrar
de renovar. Hoje ele marca sete dias, e na sétima noite o Traço pergunta uma vez
e cala para sempre.

**Pedido pequeno que veio junto (M5):** o compromisso leva para a agenda só a
frase de UM campo. O combinado (M5) queria levar dois — o pedido e a condição de
pronto —, para a cobrança ser utilizável sem abrir a nota. É uma chave a mais no
`Compromisso`, não uma volta.

**Custo, de fora.** Média. Depende de o `EventoCalendario` do Traço saber
recorrência (não sei se sabe; quem for implementar confere em
`Traco/Modelo`/`Calendario`). Se não souber, existe o caminho pobre e honesto:
ao concluir a conferência, oferecer "marcar a próxima" — recorrência manual, sem
tocar no modelo de calendário. Eu começaria por aí.

---

## III.3 Campo emparelhado (duas colunas) — pedido por UM método, mas é o método inteiro

**O que é.** N linhas com dois lados: à direita o que foi dito, à esquerda o que
se pensou e não se disse. O alinhamento linha a linha É o método de Argyris —
foi olhando para a fala da direita que a da esquerda apareceu.

**Quem pede.** A Coluna da esquerda (M1, aprovada). Ela entra achatada em dois
campos longos, que funciona e perde o alinhamento.

**O que o autor ganha.** A comparação lado a lado, que é onde o método morde.
Serviria também a qualquer método futuro de comparação (antes/depois,
previsto/aconteceu).

**Custo, de fora.** O mais alto dos quatro, por causa da tela: duas colunas num
iPhone, com teclado aberto, é problema de design, não de modelo — e passa pelo
`design-router`. Se for feito em cima do campo repetível (7.1), o modelo já vem
de graça: um repetível de dois lados.

**Honestidade:** este é o único item da lista em que eu recomendaria esperar. A
versão achatada já entrega o movimento; a versão emparelhada entrega a
elegância. Faça 7.1 primeiro e reavalie.

---

## III.4 A Classe de referência lendo o corpus — o pedido grande

**O que é.** Quando o autor abre a Classe de referência para estimar, o Traço
oferece os **casos parecidos que ele mesmo já escreveu**: notas antigas do mesmo
tipo, com o que ele registrou que aconteceu.

**Quem pede.** A Classe de referência (M1, aprovada). Hoje o campo "as vezes em
que fiz parecido" depende inteiramente da memória do autor — e a ficha diz, na
proveniência, que essa é a fraqueza declarada da adaptação: Flyvbjerg usa banco
de dados; a memória tem viés que banco de dados não tem.

**O que o autor ganha.** É a diferença entre o método adaptado e o método de
verdade. Um corpus de notas com datas, formas e campos de volta (`soDepois`) já
é o banco de dados; ninguém está usando. Com isto, o Traço passa a fazer algo
que nenhum caderno faz: lembrar ao autor como as outras vezes terminaram, com as
palavras dele.

**Custo, de fora.** O maior da lista, e o único que muda a natureza do app — de
onde a nota é escrita para onde a nota é consultada. Duas decisões que não são
minhas: (a) como achar "parecido" — mesma forma? mesmas palavras? só as que têm
campo de volta preenchido? — e (b) o que aparece na tela sem virar sugestão da
IA, porque o texto tem de ser do autor, não um resumo gerado. O caminho barato
que eu apostaria: **só as notas da mesma forma que têm o campo de volta
preenchido**, listadas por data, sem ranking e sem resumo. Isso é busca, não
inteligência, e já entregaria quase tudo.

**Reforço da M6:** agora são TRÊS métodos pedindo a mesma leitura, por três
motivos diferentes — a Classe de referência quer o corpus para **prever**, a
revisão anual de Drucker (rejeitada como método justamente por isso) queria para
**julgar o passado**, e "O que se repetiu" quer para **contar**. Para servir aos
três não é preciso inteligência nenhuma: basta listar, por forma e por período, as
notas com campo de volta preenchido.

**Onde isto conversa com o resto:** o Recordar já sabe esconder e cobrar campos;
o corpus já sabe ler mil notas depressa (há medida na suíte). A peça que falta é
a consulta, não o armazenamento.

---

## III.5 Botão de encadeamento sem destino — **volta própria; o dado já é da M3**

**O que é.** Lendo o código para escrever `encadeamentos.md`, achei isto:
`Sessao.encadear` sai em silêncio quando o destino não está no catálogo
(`guard let destino = Gesto(rawValue: para), destino.conhecido else { return }`),
mas `CamposFormaView` desenha um botão para cada encadeamento e só o apaga por
`exige`. **Destino inexistente = botão que acende e não faz nada.**

Não acontece hoje com o catálogo do app, porque todos os destinos existem. Vai
acontecer com a **pasta do autor** (`Documents/Traço/metodos`), onde alguém
apaga um método e outro continua apontando para ele — e a trilha Métodos vai
gerar exatamente isso se colar um encadeamento antes do destino.

**Conserto:** filtrar por destino conhecido em `encadeamentosPronto` e na lista
da view, do mesmo jeito que o `exige` já filtra. Custo: pequeno. **Ganho:** o
Perfil já diz quais arquivos do autor foram recusados; um botão morto é a mesma
categoria de honestidade.

**Estado (M5):** no nível do DADO isto já é item da M3 — nenhum encadeamento
colado aponta para id inexistente, com teste que trava. No nível da TELA (o
filtro na view, que protege a pasta de métodos do autor) o dono abriu volta
própria. Continua valendo o que está escrito acima; o que mudou é que agora tem
dono.

---

## III.6 Captura direta para uma forma — pequeno, e casa com o que já existe

**O que é.** A trilha Fora do app já entregou a captura de um toque (controle
Anotar, `CapturarIntent`, `Rota.captura(ditado:)`). A Nota do fato contrário
(M4) é o método cujo valor inteiro está na velocidade: se o fato não é capturado
em segundos, ele some — é literalmente o que Darwin diz.

**O que o autor ganha.** Um destino de captura que já abre na forma certa. Vale
para o fato contrário e para o Exame da noite (que Sêneca fazia no escuro, sem
lâmpada — um ditado de tela apagada seria a versão fiel).

**Custo, de fora.** Pequeno se a rota já aceita parâmetro; é escolher a forma no
`Intent`. Não sei o suficiente sobre o `CapturarIntent` para afirmar mais que
isso.

---

## Se eu tivesse de ordenar

1. **III.1 campo repetível** — quatro métodos, um deles já no catálogo, custo
   baixo, nada de tela nova.
2. **III.5 botão sem destino** — defeito real, conserto de minutos; a tela já é
   volta do dono.
3. **II.2 o texto do `avisoWood`** — trocar a frase corrige uma sentença sem
   origem, e o texto pronto está em [`aviso-wood.md`](aviso-wood.md). Menor que
   todo o resto desta lista.
4. **III.2 compromisso recorrente** — dois métodos de ritmo, e o caminho pobre
   (oferecer a próxima) já resolve.
5. **III.4 Classe de referência lendo o corpus** — o maior ganho e o maior
   custo; vale abrir como volta própria, com o corte barato descrito acima.
6. **III.6 captura direta** — pequeno, oportunista.
7. **III.3 duas colunas** — esperar III.1 e reavaliar.

Nenhum destes é bloqueio para colagem nenhuma: os doze métodos propostos entram e
funcionam no app de hoje, achatados onde precisam ser.

---

# PARTE IV — O QUE AS PROVAS DA TRILHA COBREM

**Cobrem** (script Python que imita a regra do app, refeito a cada rodada):
falso positivo, colisão de ordem, linha de base sem candidatos, encadeamento sem
destino em cada cenário de colagem, esquema da volta 16 (chaves, `funcao` da
proveniência, campos, encadeamentos apontando para método e campo existentes,
`recordar`, `compromisso`, id não repetido) e compilação das regex.

**Não cobrem:** o app rodando. Nenhuma volta de pesquisa abriu simulador, build
ou suíte — isso é da volta de colagem (I.5).
