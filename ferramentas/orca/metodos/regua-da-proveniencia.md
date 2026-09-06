# A régua da proveniência

Trilha Métodos · volta M6 · 06/09/2026.

Esta régua não é invenção minha: ela **deriva** de duas frases do
`VISAO-PRODUTO.md`, e existe porque eu tropecei duas vezes na mesma pedra.

> "Uma prática espiritual pode fornecer significado; uma obra filosófica, uma
> lente; um estudo, evidência delimitada. O catálogo deve distinguir essas
> funções, a fonte, a adaptação feita pelo Traço e o que se sabe sobre o uso
> proposto. **Beleza, tradição, nome técnico ou citação não certificam
> eficácia.**"

> "[A origem declarada pelo criador] deve orientar a amplitude da busca; não deve
> ser apresentada como comprovação de que todas as obras humanas foram examinadas
> **ou de que todas as técnicas têm a mesma evidência**."

As duas pedras:

- **Ohno (M2):** citei uma frase que eu não tinha lido no livro. Fechei trocando
  a citação por uma que eu li inteira.
- **Double Crux (M5):** quase cortei um candidato porque a origem era material de
  oficina — enquanto o catálogo já carregava o **Feynman** (técnica atribuída,
  sem nenhum texto do autor) e o **Dia** (anedota sem fonte primária), os dois em
  pé. Régua nova aplicada só ao candidato novo é injustiça, não critério.

O dono resolveu a segunda com a frase que vira o eixo deste arquivo:
**fragilidade dita é honestidade; fragilidade escondida é motivo de corte.**

---

## Dois eixos que não se confundem

O esquema da volta 16 tem `funcao` com três valores: `pratica`, `lente`,
`evidencia`. **Isso é o que o método É** — a distinção que o VISAO-PRODUTO pede.
Não é o mesmo que a qualidade da origem.

| eixo | pergunta | onde vive |
|---|---|---|
| **função** | isto é uma prática, uma lente ou um estudo com evidência delimitada? | campo `funcao` |
| **grau de origem** | quão estabelecida é a fonte, e eu li o original? | campo `fonte`, e é o que esta régua mede |

Um método pode ser `funcao: evidencia` com origem de grau A (WOOP) e outro pode
ser `funcao: pratica` com origem de grau E (Feynman). São coisas diferentes, e
confundi-las é como o catálogo passa a mentir sem ninguém perceber.

---

## Os cinco graus

### A — obra publicada, lida no original

Livro, artigo ou documento com autor, ano e localização; **e quem escreveu a
ficha leu a passagem citada**. Exemplos no catálogo: Toulmin, Adler, Osborn,
Ericsson, Tetlock.

**Obriga a dizer:** obra, autor, ano; a adaptação que o Traço fez; o que se sabe
e o que não se sabe sobre o uso proposto; para que serve e para que não serve.
O de sempre — grau A não dispensa nada, só não acrescenta ressalva.

### B — obra publicada, citada de segunda mão

A obra existe e é localizável, mas quem escreveu a ficha **não leu a passagem**:
leu em enciclopédia, resenha, resumo ou citação de terceiro.

**Obriga a dizer, na própria ficha e na tela: que a citação é de segunda mão e
por onde ela chegou.** Sem isso, o leitor supõe grau A.

**Regra de saída, e é a preferida:** quando a fonte não está acessível, **troque
a citação por uma que você leu inteira** e mantenha a obra como origem. Foi o que
fiz com Ohno: a obra continua sendo o *Toyota Production System* (1988), e a
citação que sustenta o método passou a ser a publicação da própria Toyota
(*Toyota Traditions*, 2006), lida na íntegra. Grau B é aceitável; grau B
silencioso não é.

### C — material assinado e datado fora da edição formal

Palestra transcrita, publicação institucional, manual de oficina, texto em sítio
pessoal ou comunidade. Tem autor, data e endereço; não passou por editora nem
por revisão de pares.

Exemplos: a palestra de **Hamming** (1986, transcrição de J. F. Kaiser), o
**Double Crux** (LessWrong, 2017, manual do CFAR), o memorando de **Fermi**
(1945), a publicação da **Toyota** (2006).

**Obriga a dizer o que o material é.** "Palestra", "post de comunidade", "manual
de oficina", "publicação da empresa" — com a data. E, quando não há estudo,
dizer que não há. A ficha do Double Crux cita o próprio autor admitindo que o
algoritmo "tem alguns buracos e esquisitices": **isso é o grau C funcionando**,
não um defeito da ficha.

### D — tradição sem autor

Uso corrente de uma profissão ou de uma escola, sem texto fundador identificável.
Exemplos no catálogo: Especificação (engenharia), Destilar (edição), Palavra
(escola).

**Obriga a dizer a tradição, sem inventar um nome**, e a dizer na evidência que é
uso corrente, não estudo. É explicitamente aceito pelo brief do papel.

### E — atribuição sem texto

A técnica leva o nome de alguém que **não a escreveu**, ou vem de uma anedota
sobre uma pessoa real. Exemplos no catálogo: **Feynman** e **Dia** (Ivy Lee).

**Obriga a dizer que é atribuição e que não há texto do autor.** É o que as duas
fichas fazem hoje, com todas as letras — e por isso as duas passam. Grau E
declarado é honesto; grau E vestido de citação é o pior defeito que uma ficha
pode ter (ver a auditoria abaixo).

### F — sem origem localizável

Nem obra, nem autor, nem tradição nomeável. **Não entra.** Não há ficha honesta
possível: não se pode dizer de onde vem o que não se sabe de onde vem.

---

## As três regras que valem em TODOS os graus

### 1. Nenhum grau autoriza alegar eficácia

Nem A. Um estudo no campo `fonte` diz de onde o método veio, **não que ele
funcione para o autor no formato do Traço**. As palavras proibidas continuam
proibidas: "comprovado pela ciência", "cientificamente validado", "eficaz",
"garante". A `funcao: evidencia` significa *estudo com evidência delimitada* — a
palavra que carrega o peso é **delimitada**.

O padrão da casa, que os melhores fichários da volta 16 já seguem: dizer o que o
estudo mediu, **em quem**, e o que ninguém mediu. A ficha da Prática deliberada é
o modelo — cita a meta-análise que **limita** o alcance do próprio método.

### 2. O grau declarado não pode ser maior que o real

Este é o defeito que a auditoria abaixo encontra três vezes, e é o único que
engana: uma ficha de grau E ou C escrita com a aparência de A. Ninguém mente uma
palavra; a ficha apenas **cita uma obra real ao lado de um método que não está
nela**. O leitor completa o resto sozinho.

Teste de bolso, para quem escreve a ficha: *se eu abrir a obra citada no ano
citado, eu acho este método lá dentro?* Se a resposta for não, o grau é outro, e
a ficha tem de dizer qual.

### 3. Fonte inacessível não vira citação de segunda mão silenciosa

Três saídas, nesta ordem: (a) trocar por uma fonte que você leu; (b) manter e
**dizer** que é de segunda mão e por onde; (c) retirar o candidato. Nunca (d),
citar e torcer.

---

## Antes de fechar uma ficha, cinco perguntas

1. Qual é o grau — A, B, C, D ou E? **Escreva-o na ficha**, com essas palavras.
2. Eu li a passagem que estou citando? Se não, a ficha diz por onde ela chegou?
3. Se eu abrir a obra citada, o método está lá — ou só a ideia de que ele
   descende?
4. A linha de evidência diz o que se mediu, em quem, e o que ninguém mediu?
5. A ficha alega, em alguma palavra, que isto funciona? Corte a palavra.

---

# Auditoria dos 21 do catálogo

Apliquei a régua aos 21 métodos como eles estão no `Metodos.json` da volta 16.
**Não posso saber quem leu o quê** — as fichas foram escritas por outra volta —,
então o grau abaixo é o **grau que a ficha declara**, medido contra o que a fonte
citada de fato contém.

## Passam (18 de 21)

| método | grau | por que passa |
|---|---|---|
| WOOP, Se–então, Expressiva, Analogia, Prática deliberada, Atualização | A | obra e estudos nomeados; evidência delimitada e **limitada na própria ficha** |
| Pré-mortem | A | artigo de 2007 mais a base experimental de 1989, com a diferença dita (o uso individual não foi medido) |
| Argumento, Leitura, Divergência, Steelman, Destaque | A | obra, autor e ano; "sem evidência específica conhecida" onde é o caso |
| Nota permanente | A− | a prática é de Luhmann e o livro citado é do divulgador (Ahrens); a ficha diz isso. Ver observação menor abaixo |
| Especificação, Destilar, Palavra | D | tradição dita como tradição, sem nome inventado |
| **Feynman** | **E declarado** | "técnica atribuída a Richard Feynman; **sem texto do próprio autor que a descreva**" |
| **Dia** | **E declarado** | "atribuído a Ivy Lee (1918), relato de Charles Schwab; **sem fonte primária**", e a evidência diz "a origem é anedota" |

**O resultado que importa:** os dois métodos com a PIOR origem do catálogo são os
que melhor cumprem a régua. Feynman e Dia dizem exatamente o que são. Se a régua
fosse "só obra publicada", os dois sairiam — e sairiam os dois métodos que o
autor mais usa. A régua não é sobre a força da origem; é sobre a **verdade da
declaração**.

## Não passariam hoje (3 de 21)

Os três têm o mesmo defeito: **grau declarado acima do real**. Nenhum mente uma
palavra; os três citam obra real ao lado de método que não está nela.

### 1. Decisão — grau real E, escrito como se fosse A

A ficha diz:

> "Diário de decisão, prática divulgada por Daniel Kahneman; derivado de Kahneman
> e Gary Klein, *Conditions for Intuitive Expertise* (2009)"

Fui ao artigo: Kahneman e Klein, "Conditions for intuitive expertise: A failure
to disagree", *American Psychologist* 64, 2009, p. 515–526
(doi:10.1037/a0016755). Li o resumo:

> "the authors attempt to map the boundary conditions that separate true
> intuitive skill from overconfident and biased impressions […] evaluating the
> likely quality of an intuitive judgment requires an assessment of the
> predictability of the environment […]"

**O artigo é sobre quando confiar na intuição de um especialista. Não há diário
de decisão nele.** O grau real é E — prática atribuída a Kahneman, sem texto dele
que a descreva. O DOI ao lado faz o leitor supor um grau que não existe.

**Conserto, e é de uma frase:**

> "Diário de decisão: prática atribuída a Daniel Kahneman, sem texto dele que a
> descreva. Kahneman e Klein, *Conditions for Intuitive Expertise* (2009), tratam
> de quando a intuição de especialista é confiável — é evidência vizinha sobre
> julgamento, não a origem deste método."

### 2. Primeiros princípios — obra canônica colada em prática moderna

A ficha diz: "Aristóteles, Física e Metafísica; divulgado como prática de
engenharia".

As obras existem, Aristóteles trata de princípios, e usá-lo como **lente** é
legítimo — `funcao: lente` está certo. O problema é que o **procedimento** de
três campos (o que acho que sei / o que é verdade de fato / o que construo do
zero) não está em Aristóteles, e a ficha não separa as duas coisas. Quem lê supõe
que o método é dele.

**Conserto:** uma frase na adaptação, do mesmo tipo que eu usei no candidato
desta rodada — *"Aristóteles não propõe este exercício; o Traço toma dele a noção
de princípio e monta o resto."*

### 3. Inversão — discurso sem referência, mais uma atribuição embutida

A ficha diz: "Charlie Munger, discursos (1986 em diante), citando Carl Jacobi:
inverta, sempre inverta".

Dois graus misturados. Os discursos de Munger são grau C — material assinado e
datado —, mas **"discursos (1986 em diante)" não localiza nada**: não dá para
abrir. E "citando Carl Jacobi" é grau E dentro de grau C: a frase é atribuída a
Jacobi por terceiros, e a ficha não diz isso.

**Conserto:** nomear UM discurso com data e lugar, ou escrever "discursos, sem
transcrição de referência localizada"; e marcar a frase de Jacobi como
atribuição — *"citando uma frase atribuída a Carl Jacobi"*.

## Observação menor (1)

**Nota permanente.** A fonte nomeia a prática de Luhmann e o livro de Ahrens, que
é o divulgador. Luhmann escreveu sobre o próprio Zettelkasten
("Kommunikation mit Zettelkästen", 1981); citar esse texto elevaria a ficha a um
A limpo. Não é defeito — a ficha já diz que a prática "é atestada pela obra de
Luhmann" —, é uma melhoria barata.

## O que a auditoria diz sobre o catálogo

Três coisas, e nenhuma é "o catálogo está ruim":

1. **As fichas da volta 16 são, no geral, cuidadosas.** Dezoito de vinte e um
   passam, e várias limitam o próprio método com a evidência que existe contra
   ele — o que é raro em qualquer catálogo de métodos.
2. **Os três defeitos são o mesmo defeito**, e é o único que engana de verdade:
   grau declarado acima do real. Não se conserta com mais pesquisa; conserta-se
   com uma frase que diz o que a fonte não contém.
3. **Nenhum dos três é motivo de retirar método.** Decisão, Primeiros princípios
   e Inversão continuam sendo bons instrumentos com movimento próprio. O que
   muda é a linha que o autor lê na tela quando pergunta de onde aquilo veio.

**Custo de consertar os três: três frases** no `Metodos.json`, sem tocar em
código, sem mexer em ordem, sem risco de roteamento. Cabe numa volta de colagem
qualquer — e é o tipo de coisa que só fica mais cara com o tempo, porque cada
método novo herda o padrão do que já está lá.
