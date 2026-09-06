# Contrato da volta M3 (colagem) e achados do catálogo

Trilha Métodos · escrito na M2, atualizado na M4 · 06/09/2026.

Índice: **1 a 3** o contrato da colagem (onde colar, por que no fim, o conserto
aprovado) · **4** o que a M3 tem de provar · **5 e 6** achados abertos e limites
das provas · **7** o que a forma livre está pedindo do app.

**Quem executa a M3 lê as seções 1 a 6 antes de abrir
`Traco/Modelo/Metodos.json`.** A seção 7, escrita na M4, é outra coisa: o que a
forma livre dos métodos está pedindo do app, para o dono abrir voltas do laço.

O que está aqui foi medido, não deduzido, e um
dos itens protege a escrita pessoal do dono: errar nele não quebra teste nenhum
— aparece no dia em que um desabafo cai numa forma que faz perguntas.

## Estado, para não haver dúvida

| o que | estado |
|---|---|
| Subtração, Coluna da esquerda, Classe de referência, Cinco porquês (M1) | **APROVADOS pelo dono, 06/09.** Entram na M3 |
| Cinco porquês, especificamente | aprovado **condicionado** ao fecho da citação de Ohno. **Condição cumprida na M2** (citação trocada por fonte lida na íntegra). Entra |
| Conserto da regex do Se–então | **aprovado pelo dono para a M3** (item 3 abaixo) |
| Pergunta de Hamming, O que se vê e o que não se vê, Exame da noite (M2) | propostos, **gosto ainda não decidido. NÃO colar na M3** |
| Matriz de Eisenhower, Cerca de Chesterton, Considerar o oposto | rejeitados. Não entram |

## Como o roteador funciona (a regra que torna a ordem um contrato)

`Traco/Analise/AnaliseLocal.swift`, `detectarGesto`: o catálogo é percorrido
**na ordem do arquivo** e vence o **primeiro** método cuja regex casa no texto
em minúsculas. A Expressiva só é considerada acima de 120 caracteres. O Destaque
não tem regex — é reconhecido pela forma (três ou mais linhas curtas), em
código.

**Ordem no arquivo é comportamento.** Não é estilo, não é organização.

---

# 1. CONTRATO: onde colar

Os quatro objetos aprovados entram **no FIM do array**, depois de `atualizacao`,
nesta ordem:

```
… , atualizacao,
    subtracao,
    colunaEsquerda,
    classeDeReferencia,
    cincoPorques ]
```

Cada objeto está pronto para colar, no bloco ```json da sua ficha:

- `ferramentas/orca/metodos/subtracao.md`
- `ferramentas/orca/metodos/colunaEsquerda.md`
- `ferramentas/orca/metodos/classeDeReferencia.md`
- `ferramentas/orca/metodos/cincoPorques.md`

Copie o bloco inteiro, sem reescrever. As regex têm `\b` e acentos que já foram
testados; retocar à mão é a maneira mais fácil de estragar a prova.

**Atenção, mudou na M4:** dois desses objetos ganharam encadeamentos ENTRE si —
Classe de referência → Cinco porquês, e Cinco porquês → Subtração. Como os
quatro entram na mesma leva, os dois botões nascem vivos. Se o dono decidir
colar menos de quatro, esses encadeamentos têm de sair junto, senão viram botão
morto (a razão está em [`encadeamentos.md`](encadeamentos.md), e é a mesma do
item 4 abaixo).

## 2. CONTRATO: por que no fim, e o que NUNCA fazer

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

## 3. CONTRATO: o conserto da regex do Se–então (aprovado pelo dono)

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

## 4. O que a M3 tem de provar antes de mesclar

1. **Suíte integral verde** no simulador de teste, via `com-trava.sh`. Nada
   disto foi rodado nas voltas M1 e M2: elas não abrem simulador nem
   `xcodebuild`, por ordem da tarefa. **O portão G1 é da M3.**
2. `todaRegexDoCatalogoCompila` passando com as regex novas e com a do Se–então
   corrigida.
3. As frases de teste das fichas roteando para o método certo, no app e não só
   no script — em especial a frase de desabafo do item 2, que tem de continuar
   caindo na Expressiva.
4. Os quatro métodos aparecendo no Perfil com a proveniência (é o que a volta 16
   entregou: fonte, função, adaptação, evidência, aplicabilidade).
5. **Nenhum botão morto na linha "DEPOIS DISTO".** Todo `para` de todo
   encadeamento colado tem de existir no catálogo depois da colagem. O app
   ignora em silêncio um destino inexistente, mas desenha o botão do mesmo
   jeito — ver [`encadeamentos.md`](encadeamentos.md). Conferido por teste nesta
   trilha: zero botões mortos nos três cenários de colagem.

## 5. Achado aberto: cinco desvios que já existem hoje

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
   ordem, que é comportamento — e a regra do item 2 passa a ter de ser
   reconferida inteira.

## 6. O que as provas das rodadas cobrem e o que não cobrem

**Cobrem** (script Python que imita a regra do app, nas duas rodadas): falso
positivo, colisão de ordem, linha de base sem candidatos, esquema da volta 16
(chaves, `funcao` da proveniência, campos, encadeamentos apontando para método e
campo existentes, `recordar`, `compromisso`, id não repetido) e compilação das
regex.

**Não cobrem:** o app rodando. Nenhuma volta desta trilha abriu simulador,
build ou suíte. Isso é da M3.

---

# 7. O que a forma livre está pedindo do app

Escrito na M4, para quem vai implementar — não para quem já sabe.

O dono soltou a barra da forma na M1 ("a forma é livre; se ela exigir algo que o
app ainda não faz, diga na ficha"). Dez métodos propostos depois, os pedidos se
repetem, e repetição é o sinal: **não é um método querendo um enfeite, são
vários querendo a mesma peça.** Aqui estão todos num lugar só, do mais pedido ao
menos, com o custo que eu imagino e o que o autor ganha.

Sou pesquisador, não implementador: o custo abaixo é estimativa de fora, para
ajudar a ordenar, não promessa. Onde eu li o código, digo o arquivo.

---

## 7.1 Campo repetível — pedido por QUATRO métodos

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

## 7.2 Compromisso recorrente — pedido por DOIS métodos

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

**Custo, de fora.** Média. Depende de o `EventoCalendario` do Traço saber
recorrência (não sei se sabe; quem for implementar confere em
`Traco/Modelo`/`Calendario`). Se não souber, existe o caminho pobre e honesto:
ao concluir a conferência, oferecer "marcar a próxima" — recorrência manual, sem
tocar no modelo de calendário. Eu começaria por aí.

---

## 7.3 Campo emparelhado (duas colunas) — pedido por UM método, mas é o método inteiro

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

## 7.4 A Classe de referência lendo o corpus — o pedido grande

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

**Onde isto conversa com o resto:** o Recordar já sabe esconder e cobrar campos;
o corpus já sabe ler mil notas depressa (há medida na suíte). A peça que falta é
a consulta, não o armazenamento.

---

## 7.5 Botão de encadeamento sem destino — defeito pequeno, conserto barato

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

---

## 7.6 Captura direta para uma forma — pequeno, e casa com o que já existe

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

1. **7.1 campo repetível** — quatro métodos, um deles já no catálogo, custo
   baixo, nada de tela nova.
2. **7.5 botão sem destino** — defeito real, conserto de minutos.
3. **7.2 compromisso recorrente** — dois métodos de ritmo, e o caminho pobre
   (oferecer a próxima) já resolve.
4. **7.4 Classe de referência lendo o corpus** — o maior ganho e o maior custo;
   vale abrir como volta própria, com o corte barato descrito acima.
5. **7.6 captura direta** — pequeno, oportunista.
6. **7.3 duas colunas** — esperar 7.1 e reavaliar.

Nenhum destes é bloqueio para a M3: os dez métodos propostos entram e funcionam
no app de hoje, achatados onde precisam ser.
