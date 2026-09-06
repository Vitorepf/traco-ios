# Classe de referência — ficha do candidato

Volta M1 da trilha Métodos · 06/09/2026 · **APROVADO pelo dono (06/09)**,
aguardando a colagem na volta M3.

Faculdade: **previsão** (hoje vazia; a Atualização cobre calibragem de crença,
não estimativa de prazo).
Ciclo: **MULTIPLICAR agora** — um prazo honesto muda o que se promete esta
semana. E MELHORAR no fundo: a série de estimativas conferidas é a única coisa
que ensina alguém a estimar.

## Fonte

Daniel Kahneman e Amos Tversky, **"Intuitive Prediction: Biases and Corrective
Procedures"** (1979), *TIMS Studies in Management Science* 12, p. 313–327.
Operacionalizado por Bent Flyvbjerg, **"From Nobel Prize to Project Management:
Getting Risks Right"**, *Project Management Journal* 37(3), agosto de 2006,
p. 5–15 (texto integral aberto em arXiv:1302.3642).

Citações literais, do texto de Flyvbjerg (que cita Kahneman e Tversky
diretamente):

> "Kahneman and Tversky (1979b) argue that the prevalent tendency to underweigh
> or ignore distributional information is perhaps the major source of error in
> forecasting. 'The analysts should therefore make every effort to frame the
> forecasting problem so as to facilitate utilizing all the distributional
> information that is available,' say Kahneman and Tversky (1979b: 316)."

> "Lovallo and Kahneman (2003: 58) call such common behavior the 'planning
> fallacy' and they argue that it stems from actors taking an 'inside view'
> focusing on the constituents of the specific planned action rather than on
> the outcomes of similar actions that have already been completed."

Os três passos, também literais:

> "(1) Identification of a relevant reference class of past, similar projects.
> The class must be broad enough to be statistically meaningful but narrow
> enough to be truly comparable with the specific project. (2) Establishing a
> probability distribution for the selected reference class. […] (3) Comparing
> the specific project […]"

E, sobre por que a classe não é procurada, Flyvbjerg e colegas, "Uniqueness
Bias: Why It Matters, How to Curb It" (2024, arXiv:2408.07710):

> "We test the thesis for a sample of 219 projects and find that perceived
> uniqueness is indeed highly statistically significantly associated with
> underperformance."

## O que a fonte afirma, e o que não afirma

**Afirma:** que ignorar a informação distributiva — como terminaram os casos
parecidos — é talvez a maior fonte de erro em previsão; que a previsão de dentro
olha para os detalhes deste plano em vez dos desfechos dos parecidos; e que a
percepção de que "este caso é único" anda junto com desempenho pior, em 219
projetos.

**Não afirma:** nada sobre uma pessoa sozinha usando as PRÓPRIAS lembranças
como classe de referência. O método de Flyvbjerg exige banco de dados; a
memória do autor não é banco de dados e tem viés que o banco não tem — a pessoa
lembra melhor das vezes em que acertou. Esta é uma **adaptação**, e a ficha diz
isso na proveniência. Nada aqui é eficácia comprovada.

## Por que passa nas quatro barras

1. **Ciclo** — os dois, dito acima.
2. **Origem verificável** — dois artigos, autores, anos, páginas, e citações
   literais lidas no texto integral, não em resumo.
3. **Não duplica** — não é a **Atualização** (Tetlock): lá o objeto é uma
   CRENÇA sobre o mundo com um número de 0 a 100 e o que a faria subir ou
   descer; aqui o objeto é uma ESTIMATIVA de prazo, custo ou resultado de uma
   coisa que o autor vai fazer, e o movimento é ir buscar casos passados dele
   mesmo. Não é o **Pré-mortem**, que imagina a falha e busca causas; aqui não
   se imagina nada, conta-se o que já aconteceu. Não é a **Decisão**, que
   compara opções.
4. **Honestidade sobre evidência** — o parágrafo do "não afirma" é o coração da
   ficha: o método medido usa banco de dados; o do Traço usa memória.

## O que ele desbanca ou complementa

Complementa a Decisão (o "o que espero que aconteça, e quando eu confiro" ganha
um número com base) e o Pré-mortem, para onde o encadeamento manda o prazo. O
campo do "o que neste caso é mesmo diferente (e como eu sei)" é a resposta
direta ao viés de unicidade de 2024: a exceção passa a exigir prova.

## Caso de uso real no Traço

"Acho que termino em três dias, mas nunca acerto." A forma cobra: as últimas
vezes em que ele fez uma volta parecida, e como cada uma terminou de fato
(uma levou seis dias, outra quatro, outra nunca fechou). O número novo sai
disso. O campo `deu` só aparece na volta, e o Recordar cobra a classe — que é
justamente o que se esquece.

## O que a forma pede e o app ainda não faz

Duas coisas, nenhuma bloqueante:

1. A classe é uma **lista de casos com desfecho** (caso → o que aconteceu),
   não um texto corrido. Hoje vai como um campo de texto, uma linha por caso,
   como o "As opções (uma por linha)" da Decisão já faz.
2. O valor pleno viria de o Traço **ler as notas antigas** e oferecer os casos
   parecidos já escritos pelo autor — a classe de referência do próprio corpus.
   Isso é volta de laço, e é a mais interessante que esta trilha achou até
   agora. Sem ela o método funciona; com ela, ele fica sozinho no mercado.

## JSON pronto para colar

```json
{
  "id": "classeDeReferencia",
  "nome": "Classe de referência",
  "origem": "Kahneman e Tversky; Flyvbjerg",
  "faculdade": "previsão",
  "proveniencia": {
    "fonte": "Daniel Kahneman e Amos Tversky, \"Intuitive Prediction: Biases and Corrective Procedures\" (1979), p. 316; método operacionalizado por Bent Flyvbjerg, \"From Nobel Prize to Project Management: Getting Risks Right\", Project Management Journal 37(3), agosto de 2006, p. 5–15",
    "funcao": "evidencia",
    "adaptacao": "Flyvbjerg exige um banco de dados de projetos comparáveis. O Traço usa a única classe que o autor tem à mão: as vezes em que ELE já fez algo parecido, uma a uma, com o desfecho de fato. O palpite de dentro fica escrito ANTES, para poder ser comparado com o de fora, e o campo do \"desta vez é diferente\" cobra a prova da exceção.",
    "evidencia": "Kahneman e Tversky argumentam que ignorar a informação distributiva é talvez a maior fonte de erro em previsão. Flyvbjerg relata o primeiro uso prático em obras de transporte, com bancos de dados reais, e (2024) que em 219 projetos ver o próprio projeto como único está associado a pior desempenho. Nada disso mede uma pessoa usando as próprias lembranças como classe — a memória tem viés que um banco de dados não tem. Isto é adaptação, não o método medido.",
    "aplicabilidade": "Serve para uma estimativa de prazo, custo ou resultado em que o autor já fez coisa parecida antes. Não serve quando não existe caso parecido, nem para crença sobre o mundo — isso é a Atualização."
  },
  "filtro": "Classe",
  "reconhecimento": "isto é uma estimativa que ainda não olhou para os casos parecidos.",
  "movimento": "Classe de referência (Kahneman e Tversky; Flyvbjerg). Escrever o palpite de dentro, depois NOMEAR a classe — as vezes em que já se fez algo parecido — e como cada uma terminou de fato. Só então o número novo. O que se pula é a classe: estima-se pelos detalhes deste plano em vez dos desfechos dos parecidos. Cobre se os casos terminaram de verdade, não como se lembra que deviam ter terminado, e se o número se moveu.",
  "pergunta": "As últimas vezes que você fez algo parecido: como terminaram, de fato?",
  "roteamento": [
    "\\bquanto tempo (isso |isto |ele |ela )?(vai levar|leva|vai demorar|demora)\\b|\\bem quanto tempo\\b",
    "\\bestimativa\\b|\\bestimo\\b|\\bchute de (prazo|tempo)\\b|\\bd[áa] para (fazer|terminar|entregar) (isso|isto) em\\b",
    "\\bacho que (levo|leva|demora|dá para fazer em|termino em)\\b|\\bfica pronto em\\b|\\bentrego (em|at[ée])\\b"
  ],
  "campos": [
    {
      "id": "estimo",
      "rotulo": "O que estou estimando, e o palpite de agora"
    },
    {
      "id": "parecidos",
      "rotulo": "As vezes em que fiz parecido, e como cada uma terminou"
    },
    {
      "id": "agora",
      "rotulo": "O número novo, depois de olhar para elas"
    },
    {
      "id": "diferente",
      "rotulo": "O que neste caso é mesmo diferente (e como eu sei)"
    },
    {
      "id": "deu",
      "rotulo": "Como terminou de fato",
      "soDepois": true
    }
  ],
  "recordar": {
    "alvo": [
      "parecidos",
      "agora"
    ],
    "pista": [
      "estimo"
    ],
    "pergunta": "Como terminaram os casos parecidos — e qual era o número novo?",
    "instrucao": "O que você estima fica. A classe some.",
    "rotuloAlvo": "A CLASSE"
  },
  "encadeamentos": [
    {
      "rotulo": "Pré-mortem deste prazo",
      "para": "premortem",
      "mapa": {
        "plano": "estimo"
      },
      "exige": [
        "estimo"
      ]
    },
    {
      "rotulo": "Conferir a estimativa em 30 dias",
      "compromisso": {
        "titulo": "conferir a estimativa: ",
        "campo": "estimo",
        "dias": 30
      },
      "exige": [
        "agora"
      ]
    },
    {
      "rotulo": "Por que os parecidos terminaram assim",
      "para": "cincoPorques",
      "mapa": {
        "aconteceu": "parecidos"
      },
      "exige": [
        "parecidos"
      ]
    }
  ],
  "definicao": "uma estimativa de prazo, custo ou resultado que ainda não olhou para os casos parecidos"
}
```

## Encadeamento acrescentado na volta M4

**Por que os parecidos terminaram assim — a classe vira a pergunta dos Cinco porquês.**

O mapa inteiro entre os dez propostos, com a regra de quando cada
encadeamento pode entrar, está em [`encadeamentos.md`](encadeamentos.md).
