# A pergunta de Hamming — ficha do candidato

Volta M2 da trilha Métodos · 06/09/2026 · **proposto**, não colado.

Faculdade: **direção** (vazia; o catálogo tem dois métodos de foco — Destaque e
Dia — que escolhem dentro da lista de hoje, e nenhum que pergunte se a lista é
a certa).
Ciclo: **MELHORAR** — a capacidade de escolher no que trabalhar é a que limita
todo o resto. Um ano no problema errado não se recupera com produtividade.

## Fonte

Richard W. Hamming, **"You and Your Research"**, palestra no Bell
Communications Research Colloquium Seminar, **7 de março de 1986**,
Morristown, Nova Jersey. Transcrição feita por J. F. Kaiser a partir da
gravação da palestra, incluindo as perguntas do público. Li a transcrição
inteira.

As citações que sustentam o método:

> "And I started asking, ``What are the important problems of your field?'' And
> after a week or so, ``What important problems are you working on?'' And after
> some more time I came in one day and said, ``If what you are doing is not
> important, and if you don't think it is going to lead to something important,
> why are you at Bell Labs working on it?''"

> "They were unable to ask themselves, ``What are the important problems in my
> field?'' If you do not work on an important problem, it's unlikely you'll do
> important work."

O critério de "importante", que é o que salva o método de virar lista de
desejos — e é o campo do ATAQUE:

> "It's not the consequence that makes a problem important, it is that you have
> a reasonable attack. That is what makes a problem important."

E o fecho, que é a pergunta virada para dentro:

> "I found in the early days I had believed `this' and yet had spent all week
> marching in `that' direction. It was kind of foolish. If I really believe the
> action is over there, why do I march in this direction? I either had to change
> my goal or change what I did."

## O que a fonte afirma, e o que não afirma

**Afirma:** que quase todo mundo trabalha em problemas que a própria pessoa não
acha importantes; que "importante" só quer dizer alguma coisa quando existe um
ataque possível; e que quem faz a pergunta a si mesmo acaba mudando a meta ou o
que faz. Hamming baseia isso em quarenta anos observando cientistas, com casos
nomeados (Shannon, Tukey, o colega que virou chefe de departamento).

**Não afirma:** nada medido. É uma palestra, não um estudo: sem grupo de
controle, sem contagem, e com viés de sobrevivência declarado no próprio texto —
ele estudou os que deram certo. Hamming também não afirma que qualquer um pode
escolher no que trabalha: diz que no começo não se pode, e que a escolha aparece
depois de algum sucesso. Nada aqui é eficácia comprovada.

## Por que passa nas quatro barras

1. **Ciclo** — MELHORAR, dito acima.
2. **Origem verificável** — pessoa, ocasião, data, lugar e transcritor; quatro
   citações literais lidas na transcrição integral.
3. **Não duplica** — o **Destaque** e o **Dia** escolhem dentro do que já está na
   lista de hoje; este pergunta se a lista serve, num horizonte de anos. A
   **Decisão** compara opções que já estão sobre a mesa; aqui o trabalho é
   GERAR a lista dos problemas importantes do campo, que ninguém tinha escrito.
   A **Especificação** começa depois: quando já se sabe o que atacar. E não é o
   WOOP: o WOOP parte de um desejo já formado e cobra o obstáculo interno.
4. **Honestidade sobre evidência** — o parágrafo do "não afirma" diz que é
   palestra, que há viés de sobrevivência e que o próprio Hamming limita o
   alcance.

## O que ele desbanca ou complementa

Não desbanca ninguém; fica acima do Destaque e do Dia na escala de tempo. O
encadeamento natural é para a **Especificação**: o ataque escolhido vira
problema com critério de pronto. Se a M1 entrar, o par com a **Classe de
referência** é bom (quanto tempo custa esse ataque, pelos casos parecidos).

## Caso de uso real no Traço

O dono está com sete frentes abertas e escreve "acho que estou trabalhando na
coisa errada". A forma cobra a lista dos problemas importantes do campo dele —
não do mundo —, cobra em qual deles ele tem um ataque de verdade, e termina na
única escolha que Hamming aceita: mudar a meta ou mudar o que se faz. O
compromisso de 7 dias é a "hora dos grandes pensamentos" que Hamming reservava
nas sextas.

## O que a forma pede e o app ainda não faz

Uma coisa pequena: o compromisso do Traço é de UMA vez, em N dias. A prática de
Hamming é semanal e permanente (10% do tempo, toda sexta). Um compromisso
**recorrente** serviria aqui e em qualquer método de ritmo. Não é bloqueante: o
compromisso de 7 dias funciona, e o autor renova.

## JSON pronto para colar

```json
{
  "id": "perguntaHamming",
  "nome": "A pergunta de Hamming",
  "origem": "Richard Hamming, 1986",
  "faculdade": "direção",
  "proveniencia": {
    "fonte": "Richard W. Hamming, \"You and Your Research\", palestra no Bell Communications Research Colloquium Seminar, 7 de março de 1986; transcrição de J. F. Kaiser a partir da gravação",
    "funcao": "pratica",
    "adaptacao": "O Traço vira para dentro a pergunta que Hamming fazia aos outros na mesa do almoço, e acrescenta a coluna do ATAQUE — que é o critério do próprio Hamming para o que conta como problema importante. O fecho é a escolha que ele diz ter feito: mudar a meta ou mudar o que se faz.",
    "evidencia": "É uma palestra: quarenta anos de observação de um pesquisador sobre outros pesquisadores, com casos nomeados. Não é estudo, não tem grupo de controle, e Hamming não afirma que responder à pergunta melhore o trabalho de alguém. Não há medida de efeito.",
    "aplicabilidade": "Serve para quem tem alguma escolha sobre no que trabalha. Não serve para quem não tem nenhuma — o próprio Hamming reconhece que no começo não se tem."
  },
  "filtro": "Hamming",
  "reconhecimento": "isto é trabalho sem direção — falta perguntar se importa.",
  "movimento": "A pergunta de Hamming. Listar os problemas IMPORTANTES do próprio campo, dizer em qual deles se está trabalhando e, se não for nenhum, por quê. Importante, para Hamming, não é o de maior consequência: é aquele para o qual você tem um ATAQUE. Cobre o ataque de cada problema listado, e o fecho: mudar a meta ou mudar o que se faz.",
  "pergunta": "Se você acredita que a ação está lá, por que você marcha para cá?",
  "roteamento": [
    "\\bproblemas? importantes?\\b|\\bo que (é|e) importante no meu campo\\b|\\bgrandes problemas\\b",
    "\\bno que eu (deveria|devia) estar trabalhando\\b|\\bestou trabalhando (n[oa] )?(coisa )?errad[oa]\\b|\\btrabalhando em coisa pequena\\b",
    "\\bvale a pena trabalhar nisso\\b|\\bisso me leva a algum lugar\\b|\\bpara onde isso me leva\\b"
  ],
  "campos": [
    {
      "id": "campo",
      "rotulo": "O meu campo — onde eu quero contar"
    },
    {
      "id": "importantes",
      "rotulo": "Os problemas importantes dele (um por linha)"
    },
    {
      "id": "ataque",
      "rotulo": "Em qual deles eu tenho um ATAQUE — e qual é"
    },
    {
      "id": "trabalhando",
      "rotulo": "No que eu estou trabalhando de fato"
    },
    {
      "id": "porque",
      "rotulo": "Se não é um deles, por quê"
    },
    {
      "id": "mudo",
      "rotulo": "Mudo a meta, ou mudo o que eu faço"
    }
  ],
  "recordar": {
    "alvo": [
      "importantes",
      "ataque"
    ],
    "pista": [
      "campo"
    ],
    "pergunta": "Quais eram os problemas importantes, e onde você tinha ataque?",
    "instrucao": "O campo fica. Os problemas somem.",
    "rotuloAlvo": "OS IMPORTANTES"
  },
  "encadeamentos": [
    {
      "rotulo": "Especificar o ataque",
      "para": "spec",
      "mapa": {
        "problema": "ataque"
      },
      "exige": [
        "ataque"
      ]
    },
    {
      "rotulo": "Grandes pensamentos em 7 dias",
      "compromisso": {
        "titulo": "grandes pensamentos: ",
        "campo": "campo",
        "dias": 7
      },
      "exige": [
        "importantes"
      ]
    }
  ],
  "definicao": "trabalho sem direção: quais são os problemas importantes do campo, e por que você não está num deles"
}
```
