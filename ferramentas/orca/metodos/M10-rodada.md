# Trilha Métodos — volta M10

06/09/2026 · worktree `metodos-m1`, mesmo branch.

## 1. A emenda da ficção entrou no brief

`ferramentas/orca/papeis/pesquisador-metodos.md`, na seção da régua, logo depois
da frase sobre fragilidade dita: ficção é **grau A de forma** (obra, autor, ano,
lida na íntegra) e **o grau mais fraco de conteúdo**, e obriga a linha *"é ficção;
dá o critério e o nome, e não estabelece nada"*. A cópia solta
(`secao-brief-regua.md`) foi atualizada junto.

## 2. O ângulo: julgar uma coisa feita

Rendeu **um método e duas rejeições** — e a razão de render só um é o achado do
ângulo, que vale mais que um segundo método: **quase tudo em "julgar o feito" é
campo de um método só, ou é portão de processo.** Matar os queridinhos é campo. A
segunda opinião é campo. Guardar antes de olhar é campo. A esteira é portão.

| candidato | grau | faculdade | ciclo | estado |
|---|---|---|---|---|
| [Está bom?](estaBom.md) | **A** | criação | melhorar + multiplicar | proposto |
| [Matar os queridinhos](rejeitado-matarOsQueridinhos.md) | A (lido) | — | — | **REJEITADO — barra 3** |
| [A ESTEIRA como método](rejeitado-esteiraComoMetodo.md) | — | — | — | **REJEITADO — barra 1** |

### Está bom? — Horácio, Ars Poetica (c. 19 a.C.)

Grau A, lido no texto integral em tradução identificada. Três movimentos são
dele: **guardar antes de julgar** ("suprimido até o nono ano"), **um juiz
competente**, e **cortar o enfeite** ("poda os ornamentos ambiciosos").

A passagem mais dura das duas mil linhas, e a que eu não esperava achar:

> "if you choose rather to defend than correct a fault, he spent not a word more
> nor fruitless labor, but you alone might be fond of yourself and your own works,
> without a rival."

**Se você prefere defender a corrigir, o juiz não gasta mais uma palavra — e você
fica sozinho, gostando da própria obra, sem rival.** Horácio descreve isso do lado
do crítico; o Traço vira para o lado do autor e faz disso um campo: *onde eu
defendi em vez de corrigir*.

**Os dois campos que são do Traço** — e a ficha diz que são, porque não achei em
fonte nenhuma: esse, e a pergunta que o dono formulou: *é "não está bom" ou eu
estou cansado? Como eu sei*. O "como eu sei" é o que impede a pergunta de virar
desabafo.

**Não criei rótulo de faculdade novo.** Depois do que a M9 mostrou sobre a
taxonomia inflada pelo meu próprio incentivo, este método entra em **criação** —
a prateleira que o mapa mostra torta, com dois métodos de gerar opções e nenhum
de julgar o feito. Se um dia o dono quiser separar *gerar* de *fazer*, é edição de
rótulo, não método novo.

### As duas rejeições

**Matar os queridinhos** — desta vez eu abri o livro: Quiller-Couch, *On the Art
of Writing* (1916), aula XII, lido. E registro a lição de atribuição: a frase é
atribuída no mundo a Faulkner, Fitzgerald, Twain, Wilde e Stephen King — **grau A
quando se abre o livro, grau E quando se repete o que todo mundo diz**. Cai na
barra 3, pela sexta vez na trilha e da forma mais clara: é um campo, não um
método. Sozinho, "corte o que você ama" não diz contra o quê. A frase foi
aproveitada como segunda fonte do campo `enfeite` do Está bom?.

**A ESTEIRA como método** — fui eu que apontei, na M9, que ela vive fora do
catálogo. A conclusão de agora é que ela **deve continuar fora**, e cai na barra
1: é portão de processo, feito para que o trabalho de OUTRA pessoa não entre sem
prova, aplicado por revisor independente com evidência anexada. Como método seria
uma forma de quinze campos que o autor preencheria sozinho — não multiplica (é
mais trabalho por entrega) e não desenvolve (preencher rubrica ensina a preencher
rubrica).

A ficha traz a divisão de trabalho entre os dois, e a frase que resume:
**uma rubrica não pergunta se você está cansado, porque foi feita para ser
aplicada por outra pessoa.**

## 3. A dívida escondida, escrita para quem executa

Nova seção no fim de [`o-que-falta-no-catalogo.md`](o-que-falta-no-catalogo.md),
com o que fazer, o custo e o que NÃO fazer em cada uma das três.

**Destilar e Palavra** — barato e é só rótulo: trocar `faculdade` de "linguagem"
para "criação", duas palavras no JSON, nada de roteamento. E o aviso: não inventar
a faculdade "ofício" só para elas, que é como a taxonomia entortou.

**Dia e Destaque** — **não mexer**, só documentar. O Destaque tem superfície
própria (tela bloqueada e widget) e fundir custaria a superfície, que é a coisa
mais usada do app. Duas frases nas fichas dizendo que a diferença é de superfície,
não de movimento.

**A Expressiva** — a decisão de arquitetura, e a resposta às suas duas perguntas:

*O que aconteceria se ela saísse:* **quebraria a proteção, não a organização.** O
objeto dela tem `campos: []`, `movimento: ""` e `pergunta: ""` — ela está no
catálogo porque **o roteador mora no catálogo**. Se sair, o roteamento por
palavras de sentimento some junto, e um desabafo longo passa a cair no próximo
método cuja regex casar — a Coluna da esquerda ou o Exame da noite, que **fazem
perguntas**. É o dano que a regra de ordem existe para evitar, chegando por outra
porta.

*O que teria de existir antes:* (a) **um lugar para reconhecedores que não são
métodos** — uma segunda lista no mesmo arquivo, sem campos e sem movimento, lida
antes da lista de métodos; (b) a garantia de que `Gesto.doNome` e
`Catalogo.metodo` continuam aceitando "expressiva", senão notas antigas viram
prosa; (c) trocar cada `if gesto == .expressiva` por "é uma proteção?", o que abre
a porta para a segunda proteção que um dia venha.

*E a recomendação:* **não fazer agora, e fazer junto da volta que conserta a
análise de bordo.** As duas abrem os mesmos arquivos e mexem na mesma fronteira
entre catálogo e roteamento — e a de bordo é a que tem valor de função. Feita
sozinha e com pressa, esta é a mudança de maior risco do catálogo inteiro, porque
a proteção da escrita pessoal depende de a Expressiva ser encontrada primeiro.

## 4. Prova

```

========================================================================
1. FALSO POSITIVO — a regex do candidato da M10 contra as frases de todos os outros
========================================================================
Falso positivo = o candidato novo ROUBA o roteamento de uma frase alheia.


  falsos positivos: 0   fronteiras: 0

========================================================================
2. COLISÃO DE ORDEM — regex já existentes casando nas frases da M10
========================================================================
  colisões: 0

========================================================================
3. CENÁRIO A — 21 + os SETE colados pela M3
========================================================================
  XX  notaPermanente       esperado destilar             «resumir a ideia em 100 caracteres e depois num»
  XX  woop                 esperado premortem            «quero fazer um pré-mortem do lançamento de nov»
  XX  woop                 esperado feynman              «quero entender de verdade como funciona a comp»
  XX  woop                 esperado primeirosPrincipios  «quero desmontar isso até os primeiros princípi»
  XX  woop                 esperado praticaDeliberada    «quero treinar o pedaço da fala que sempre falh»
  erros: 5 de 41 frases  (5 deles são os desvios herdados, medidos na M1)

========================================================================
4. CENÁRIO B — A + a leva 2 inteira (8)
========================================================================
  XX  notaPermanente       esperado destilar             «resumir a ideia em 100 caracteres e depois num»
  XX  woop                 esperado premortem            «quero fazer um pré-mortem do lançamento de nov»
  XX  woop                 esperado feynman              «quero entender de verdade como funciona a comp»
  XX  woop                 esperado primeirosPrincipios  «quero desmontar isso até os primeiros princípi»
  XX  woop                 esperado praticaDeliberada    «quero treinar o pedaço da fala que sempre falh»
  erros: 5 de 77 frases  (5 deles são os desvios herdados, medidos na M1)

========================================================================
5. CENÁRIO C — B + os 2 da M9 + o da M10
========================================================================
  XX  notaPermanente       esperado destilar             «resumir a ideia em 100 caracteres e depois num»
  XX  woop                 esperado premortem            «quero fazer um pré-mortem do lançamento de nov»
  XX  woop                 esperado feynman              «quero entender de verdade como funciona a comp»
  XX  woop                 esperado primeirosPrincipios  «quero desmontar isso até os primeiros princípi»
  XX  woop                 esperado praticaDeliberada    «quero treinar o pedaço da fala que sempre falh»
  erros: 5 de 89 frases  (5 deles são os desvios herdados, medidos na M1)

========================================================================
6. ENCADEAMENTOS — nenhum botão morto em nenhum cenário
========================================================================
O app (Sessao.encadear) IGNORA em silêncio um encadeamento cujo destino não
está no catálogo, mas a UI (CamposFormaView) desenha o botão do mesmo jeito.
Logo: um encadeamento só pode entrar junto com o destino, ou depois dele.

  botões mortos: 0

========================================================================
7. ENCADEAMENTOS — o mapa entre os métodos NOVOS (o que esta rodada acrescentou)
========================================================================
  classeDeReferencia   -> cincoPorques         «Por que os parecidos terminaram assim»  mapa={'aconteceu': 'parecidos'}
  cincoPorques         -> subtracao            «Tirar a peça (Subtração)»  mapa={'melhorar': 'aconteceu', 'sai': 'controlo'}
  perguntaHamming      -> subtracao            «O que sai para caber o ataque»  mapa={'melhorar': 'trabalhando', 'ia': 'ataque'}
  vistoNaoVisto        -> subtracao            «Tirar isto (Subtração)»  mapa={'melhorar': 'ato'}
  exameDaNoite         -> colunaEsquerda       «Abrir a conversa (Coluna da esquerda)»  mapa={'comQuem': 'naoRepito'}
  ordemDeGrandeza      -> classeDeReferencia   «Tem casos parecidos? Classe de referência»  mapa={'estimo': 'quantidade'}
  comecariaHoje        -> subtracao            «Se parar, o que sai»  mapa={'melhorar': 'oQue', 'sai': 'oQue'}
  combinado            -> colunaEsquerda       «Se azedou, abrir a conversa»  mapa={'comQuem': 'quem', 'disse': 'resposta'}
  regraQueEuFaco       -> vistoNaoVisto        «Quem paga o que não se vê»  mapa={'ato': 'ato'}
  oQueNaoEsta          -> combinado            «Pedir o que falta (Combinado)»  mapa={'pedido': 'pergunto', 'pronto': 'falta'}
  estaBom              -> subtracao            «Tirar o enfeite (Subtração)»  mapa={'melhorar': 'oQue', 'sai': 'enfeite'}

========================================================================
8. ESQUEMA (volta 16), mapas e regex que compilam
========================================================================
  erros de esquema: 0 | regex que não compilam: 0

========================================================================
VEREDITO M10
========================================================================
  falsos positivos do candidato da M10: 0
  botões mortos (encadeamento sem destino): 0
  erros herdados do catálogo, sem candidato nenhum: 5
  erros de esquema: 0 | regex que não compilam: 0
  total no cenário C: 39 métodos
```

**0 falso positivo**, **0 colisão de ordem**, **0 botão morto**, **0 erro de
esquema**, **0 regex que não compila**. Os 5 desvios de sempre são os herdados. No
cenário C o catálogo teria 39 métodos — e vale lembrar o que a M9 mediu: **o teto
de trabalho da arquitetura de hoje é cerca de 40.**

A suíte do app não rodou: esta volta não abre simulador nem `xcodebuild`.

## 5. Onde a trilha está

Dezoito propostos, doze rejeitados, sete na leva 1, oito na leva 2, três
esperando gosto (os dois da M9 e o desta rodada). Com todos colados o catálogo
chega a **39 de um teto de ~40** — e o ângulo desta rodada, que era o primeiro da
lista da M9, terminou com uma conclusão que reforça a recomendação de lá:
**a fase de caçar acabou.** O que sobra na lista da M9 (pedir ajuda, agir com
medo, esperar) eu caçaria com a régua de trocar, não de acrescentar.
