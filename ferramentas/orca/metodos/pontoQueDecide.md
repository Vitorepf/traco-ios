# O ponto que decide — ficha do candidato

Volta M5 da trilha Métodos · 06/09/2026 · **proposto**, não colado.

Faculdade: **desacordo** (vazia). O catálogo sabe defender uma tese (Argumento),
escrever o lado contrário no melhor (Steelman) e dar número a uma crença
(Atualização). Não sabe **localizar** um desacordo.
Ciclo: **MELHORAR** — discordar sem virar discussão é capacidade, e é a que
decide se o autor aprende de quem discorda dele ou só se cansa.

## Fonte

Duncan Sabien, **"Double Crux — A Strategy for Mutual Understanding"**,
LessWrong, **2 de janeiro de 2017**; o algoritmo publicado no texto é o do manual
do CFAR. Texto integral lido.

O algoritmo, na fonte:

> "3. Seek double cruxes — Seek your own cruxes independently, and compare with
> those of the other person to find overlap. Seek cruxes collaboratively, by
> making claims ('I believe that X will happen because Y') and focusing on
> falsifiability ('It would take A, B, or C to make me stop believing X')."

A exigência de que o fato seja do mundo, e não do jeito que a coisa parece:

> "try to talk about what would be observable in the world rather than how things
> feel or what's good or bad"

E o que separa isto de debate:

> "Part of the value of double crux is that it's the opposite of the weaselly,
> score-points, hide-in-ambiguity-and-look-clever dynamic of, say, a public
> political debate. The goal is to have everyone understand, at all times and as
> much as possible, what the other person is actually trying to say."

## O que a fonte afirma, e o que não afirma

**Afirma:** que um desacordo fica resolvível quando as duas partes acham o fato
observável que, mudando, mudaria cada uma delas; e que o trabalho é de
entendimento, não de pontos.

**Não afirma:** absolutamente nada medido. Não há estudo, nem amostra, nem
comparação — é material de oficina. E o próprio texto declara a própria
fragilidade, o que é raro e vale citar:

> "It's not strictly connected to all of the discussion above; it was designed to
> be read in context with an hour-long lecture and several practice activities
> (so it has some holes and weirdnesses) and is presented here more for
> completeness and as food for thought than as an actual conclusion to the
> above."

**Esta é a proveniência mais recente e mais frágil do catálogo, e a ficha prefere
dizer isso a inflá-la.** Em compensação, é origem **datada, assinada e legível na
íntegra** — o que dois métodos já colados não têm: o **Feynman** é técnica
atribuída sem nenhum texto do próprio Feynman, e o **Dia** é anedota sobre Ivy
Lee sem fonte primária. A barra 2 pede origem verificável; esta é mais
verificável que as duas.

## Por que passa nas quatro barras

1. **Ciclo** — MELHORAR.
2. **Origem verificável** — autor, veículo, data exata, texto lido inteiro.
3. **Não duplica** — o **Steelman** trata da POSIÇÃO do outro (escrevê-la tão
   bem que ele assinaria); este trata do FATO que separa os dois, e o produto é
   uma afirmação testável, não prosa. O **Argumento** pede "o que me faria mudar
   de ideia" — metade disto, e só do meu lado; aqui a segunda metade, o crux do
   outro, é obrigatória, e é ela que transforma discussão em investigação. A
   **Atualização** dá número a uma crença sozinha.
4. **Honestidade sobre evidência** — nenhuma, dito com todas as letras, com a
   autodeclaração de buracos do próprio autor citada.

## O risco que o dono deve pesar

Duas coisas, ditas de frente:

1. **É a proveniência mais fraca do catálogo.** Se a régua for "só obra
   publicada com editora", este método sai — e a ficha não vai brigar.
2. **Ele nasceu para uma conversa a dois, e o Traço é de um.** A adaptação é
   honesta (a nota é o PREPARO da conversa, e o campo de volta guarda qual era o
   crux de verdade), mas quem escrever os dois cruxes e nunca conversar terá
   feito um exercício de imaginação, não um acordo. A `aplicabilidade` diz isso.

## O que ele desbanca ou complementa

Complementa o Steelman, e o encadeamento vai para lá: escrito o lado do outro no
melhor, o crux fica mais fácil de achar. E alimenta a Atualização, levando o
próprio crux para o campo "o que me faria descer" — que é a mesma ideia com
número.

## Caso de uso real no Traço

O dono discorda de um agente sobre roteamento local bastar sem a IA. Em vez de
mais uma rodada de argumentos, a forma cobra: o que decidiria isto? "Se numa
amostra de cinquenta frases minhas o roteamento local errar mais de dez, eu
mudo." Isso é observável, tem número e acaba a discussão — ou a transforma em
teste. O campo de volta guarda o crux que apareceu de verdade, que quase nunca é
o previsto.

## O que a forma pede e o app ainda não faz

Nada. Sete campos, um deles de volta.

## JSON pronto para colar

```json
{
  "id": "pontoQueDecide",
  "nome": "O ponto que decide",
  "origem": "Duncan Sabien, 2017 (double crux)",
  "faculdade": "desacordo",
  "proveniencia": {
    "fonte": "GRAU C: material assinado e datado fora da edição formal (post de comunidade, manual de oficina), lido na íntegra; não passou por editora nem revisão de pares. Duncan Sabien, \"Double Crux — A Strategy for Mutual Understanding\", LessWrong, 2 de janeiro de 2017; o algoritmo é do manual do CFAR. Texto integral lido.",
    "funcao": "pratica",
    "adaptacao": "O duplo crux é uma conversa entre duas pessoas. No Traço vira PREPARO: o autor escreve sozinho o próprio crux e o melhor palpite do crux do outro, antes de conversar — e, depois, o campo de volta guarda qual era o crux de verdade. A nota não substitui a conversa; ela é o que se leva para ela.",
    "evidencia": "Não há estudo nenhum: é material de oficina, e o próprio texto diz que o algoritmo \"tem alguns buracos e esquisitices\" e foi escrito para ser lido junto com uma aula de uma hora. É a proveniência mais recente e mais frágil do catálogo, e a ficha prefere dizer isso a inflá-la. Em compensação, é origem datada, assinada e legível na íntegra — o que dois métodos já colados (Feynman, atribuído sem texto do autor; Dia, anedota sem fonte primária) não têm.",
    "aplicabilidade": "Serve para um desacordo específico com alguém que você respeita e vai encontrar de novo. Não serve para posição que ninguém defende — isso é o Steelman — nem para discussão em que o outro não quer chegar a lugar nenhum."
  },
  "filtro": "Crux",
  "reconhecimento": "isto é um desacordo sem o fato que o decide.",
  "movimento": "Duplo crux (Sabien, 2017, do manual do CFAR). Em vez de defender a posição, achar o FATO que decide: aquele que, se fosse falso, faria VOCÊ mudar de ideia. Cobre duas coisas que o método existe para não deixar passar: que o fato seja observável — dito como o mundo é, não como a coisa parece —, e a segunda metade, o crux do OUTRO, no melhor palpite de quem escreve. Sem as duas, não é desacordo localizado: é discussão.",
  "pergunta": "Que fato, se fosse falso, faria VOCÊ mudar de ideia?",
  "roteamento": [
    "\\bduplo crux\\b|\\bdouble crux\\b|\\bponto que decide\\b|\\bonde exatamente (a gente|n[óo]s|eu e ele|eu e ela) discord\\w+\\b",
    "\\bdiscordamos sobre\\b|\\bn[ãa]o chegamos a (um )?acordo\\b|\\bcada um acha uma coisa\\b",
    "\\bo que (decidiria|resolveria) (isso|essa discuss[ãa]o|o impasse)\\b|\\bestamos em impasse\\b"
  ],
  "campos": [
    {
      "id": "desacordo",
      "rotulo": "Sobre o que a gente discorda, em uma frase"
    },
    {
      "id": "minha",
      "rotulo": "O que eu sustento"
    },
    {
      "id": "dele",
      "rotulo": "O que ele sustenta, na melhor versão que eu consigo"
    },
    {
      "id": "meuCrux",
      "rotulo": "O fato que, se fosse falso, me faria mudar"
    },
    {
      "id": "cruxDele",
      "rotulo": "O fato que faria ele mudar (meu palpite)"
    },
    {
      "id": "observavel",
      "rotulo": "Como isso seria observável — o que a gente iria olhar"
    },
    {
      "id": "depois",
      "rotulo": "Depois da conversa: qual era o crux de verdade",
      "soDepois": true
    }
  ],
  "recordar": {
    "alvo": [
      "meuCrux",
      "cruxDele"
    ],
    "pista": [
      "desacordo"
    ],
    "pergunta": "Qual era o fato que decidia — de cada lado?",
    "instrucao": "O desacordo fica. Os cruxes somem.",
    "rotuloAlvo": "O PONTO QUE DECIDE"
  },
  "encadeamentos": [
    {
      "rotulo": "Escrever o lado dele no melhor",
      "para": "steelman",
      "mapa": {
        "contraria": "dele"
      },
      "exige": [
        "dele"
      ]
    },
    {
      "rotulo": "Quanto eu acredito nisso",
      "para": "atualizacao",
      "mapa": {
        "acredito": "minha",
        "descer": "meuCrux"
      },
      "exige": [
        "meuCrux"
      ]
    }
  ],
  "definicao": "um desacordo com outra pessoa que ainda não achou o fato que o decide"
}
```
