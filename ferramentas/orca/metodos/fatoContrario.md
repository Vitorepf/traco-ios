# A nota do fato contrário — ficha do candidato

Volta M4 da trilha Métodos · 06/09/2026 · **proposto**, não colado.

Faculdade: **honestidade** (vazia). O catálogo tem métodos que perguntam o que
mudaria de ideia (Argumento, Atualização) — nenhum que capture o fato contrário
no instante em que ele aparece, que é quando ele ainda existe.
Ciclo: **MELHORAR** — é a capacidade de não se enganar, e ela limita todas as
outras. Sem ela, todo o resto do catálogo trabalha com material selecionado.

## Fonte

**Charles Darwin, *The Autobiography of Charles Darwin*** — escrita em 1876,
publicada em 1887 por Francis Darwin. Texto integral lido no Project Gutenberg
(eBook 2010).

A regra, palavra por palavra:

> "I had, also, during many years followed a golden rule, namely, that whenever
> a published fact, a new observation or thought came across me, which was
> opposed to my general results, to make a memorandum of it without fail and at
> once; for I had found by experience that such facts and thoughts were far more
> apt to escape from the memory than favourable ones."

E o resultado que ele atribui ao hábito:

> "Owing to this habit, very few objections were raised against my views which I
> had not at least noticed and attempted to answer."

Três coisas estão nessa frase e as três viraram o método: **sem falta e na
hora** (`without fail and at once`), **porque o contrário foge da memória mais
depressa que o favorável**, e **anotar não é responder** — Darwin anota primeiro
e responde quando pode.

## O que a fonte afirma, e o que não afirma

**Afirma:** que Darwin seguiu esse hábito por muitos anos; que ele havia
descoberto, por experiência própria, que fatos contrários escapam da memória
mais depressa que os favoráveis; e que atribui a isso o fato de poucas objeções
o terem pego desprevenido.

**Não afirma:** nada medido. É testemunho de um cientista sobre a própria
prática, escrito aos sessenta e sete anos, por quem já sabia que a teoria tinha
vencido — o viés de quem conta a história depois. Não há controle, não há
comparação, e nada diz que o hábito funcione para outra pessoa. A ficha não
alega eficácia nenhuma.

## Por que passa nas quatro barras

1. **Ciclo** — MELHORAR, dito acima.
2. **Origem verificável** — autor, obra, ano de escrita e de publicação, editor,
   e a citação lida no texto integral em domínio público.
3. **Não duplica** — a **Atualização** (Tetlock) parte de uma crença e pede um
   número, com o que a faria subir ou descer *em tese*; aqui existe um fato
   concreto que já apareceu, e o movimento é capturá-lo antes que suma. O
   **Argumento** (Toulmin) pede a melhor objeção *imaginada* por quem defende a
   tese — este método pega a objeção que o mundo mandou, sem convite. E o
   **Steelman** reescreve a posição do outro; aqui não há outro: há um fato.
   Nenhum dos três tem o nervo do tempo: agora, antes de esquecer.
4. **Honestidade sobre evidência** — dito acima, com o viés do próprio Darwin
   nomeado.

## O que ele desbanca ou complementa

Complementa a Atualização e o Argumento, e os encadeamentos vão para os dois: o
fato contrário vira "o que me faria descer" na Atualização, e vira a objeção no
Argumento. É o método que ALIMENTA os outros dois — sozinho ele é uma anotação;
com eles vira revisão de crença.

## Caso de uso real no Traço

O dono defende que o roteamento local basta sem a IA. No meio de um teste,
aparece uma frase real do próprio uso que o roteamento local erra feio. Isso
some em dez minutos, e some porque é inconveniente. A forma pede o fato como ele
veio, o que ele atinge, onde foi, e o que teria de ser verdade para ele ser
decisivo — o campo da resposta fica vazio, de propósito, para não transformar a
captura em defesa.

## O que a forma pede e o app ainda não faz

Nada de estrutura — cinco campos, um deles de volta. Mas o método **pede
velocidade**: o valor inteiro está em capturar em segundos, no meio de outra
coisa. É o caso de uso mais forte que a trilha achou para a captura de um toque
que a trilha Fora do app já entregou; um destino direto ("anotar fato
contrário") seria a versão fiel. Anotado em `achados-catalogo.md`, não é
bloqueio.

## JSON pronto para colar

```json
{
  "id": "fatoContrario",
  "nome": "A nota do fato contrário",
  "origem": "Charles Darwin",
  "faculdade": "honestidade",
  "proveniencia": {
    "fonte": "Charles Darwin, The Autobiography of Charles Darwin (escrita em 1876, publicada em 1887 por Francis Darwin); texto integral lido no Project Gutenberg, eBook 2010",
    "funcao": "pratica",
    "adaptacao": "Darwin descreve um hábito de captura, não um formulário. O Traço faz quatro campos e cobra a única coisa que a regra exige — escrever AGORA, com o fato do jeito que ele veio. O campo da resposta nasce vazio de propósito e só aparece depois: a regra é sobre capturar, não sobre vencer a objeção.",
    "evidencia": "Darwin relata o hábito e o resultado que atribui a ele: quase nenhuma objeção o pegou desprevenido. É testemunho de um cientista sobre a própria prática — sem controle, sem medida, e contado por quem já sabia que tinha dado certo. Não há evidência de que anotar o fato contrário faça diferença em quem não seja Darwin.",
    "aplicabilidade": "Serve para o instante em que aparece um fato, uma observação ou um argumento CONTRA o que o autor sustenta. Não serve para dúvida geral nem para autocrítica: sem um fato específico, não é isto."
  },
  "filtro": "Fato contrário",
  "reconhecimento": "isto é um fato contra o que você defende — e ele foge.",
  "movimento": "A regra de ouro de Darwin. Quando aparece um fato, uma observação ou uma ideia CONTRÁRIA ao que se sustenta, anotar sem falta e na hora — porque, como Darwin observou em si mesmo, o contrário escapa da memória muito mais depressa que o favorável. Cobre o fato como ele veio, não como você o rebateria: a resposta pode ficar em branco. Cobre também o que ele atinge e o que teria de ser verdade para ele ser decisivo.",
  "pergunta": "O fato, do jeito que ele veio. A resposta pode ficar para depois.",
  "roteamento": [
    "\\bcontra o que eu (acho|penso|defendo|sustento)\\b|\\bisso contraria\\b|\\bcontradiz o que eu\\b|\\bn[ãa]o bate com o que eu\\b",
    "\\bfato contr[áa]rio\\b|\\bachei um (dado|estudo|caso|n[úu]mero) contra\\b|\\bevid[êe]ncia contra\\b",
    "\\bderruba (a minha|minha) (ideia|hip[óo]tese|posi[çc][ãa]o)\\b|\\bfala contra a minha\\b"
  ],
  "campos": [
    {
      "id": "fato",
      "rotulo": "O fato contrário, como ele veio"
    },
    {
      "id": "contra",
      "rotulo": "O que ele atinge (o que eu sustento)"
    },
    {
      "id": "onde",
      "rotulo": "Onde eu topei com ele"
    },
    {
      "id": "decisivo",
      "rotulo": "O que teria de ser verdade para ele ser decisivo"
    },
    {
      "id": "resposta",
      "rotulo": "A minha resposta, quando eu tiver",
      "soDepois": true
    }
  ],
  "recordar": {
    "alvo": [
      "fato"
    ],
    "pista": [
      "contra"
    ],
    "pergunta": "Qual era o fato que ia contra?",
    "instrucao": "O que você sustenta fica. O fato contrário some — como ele sempre faz.",
    "rotuloAlvo": "O FATO CONTRÁRIO"
  },
  "encadeamentos": [
    {
      "rotulo": "Quanto isto mexe na crença",
      "para": "atualizacao",
      "mapa": {
        "acredito": "contra",
        "descer": "fato"
      },
      "exige": [
        "fato"
      ]
    },
    {
      "rotulo": "Montar o argumento com esta objeção",
      "para": "argumento",
      "mapa": {
        "tese": "contra",
        "objecao": "fato"
      },
      "exige": [
        "fato"
      ]
    }
  ],
  "definicao": "um fato, observação ou ideia contrária ao que o autor sustenta, anotada na hora"
}
```
