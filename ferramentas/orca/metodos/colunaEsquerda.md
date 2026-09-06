# Coluna da esquerda — ficha do candidato

Volta M1 da trilha Métodos · 06/09/2026 · **APROVADO pelo dono (06/09)**,
aguardando a colagem na volta M3. **Este é o método da restrição de ordem:**
ver o contrato em `achados-catalogo.md`.

Faculdade: **relação** (hoje vazia no catálogo — nenhum dos 21 trata de outra
pessoa).
Ciclo: **MELHORAR** — a capacidade de dizer o que se pensa na frente de quem
precisa ouvir. É a que limita conversa difícil, sociedade, contratação, briga.

## Fonte

Chris Argyris e Donald Schön, *Theory in Practice: Increasing Professional
Effectiveness* (Jossey-Bass, 1974) — a teoria (teoria esposada × teoria em
uso). O exercício das duas colunas aparece em Chris Argyris, **"Teaching Smart
People How to Learn", Harvard Business Review, maio–junho de 1991**, e foi
difundido por Peter Senge e colegas em *The Fifth Discipline Fieldbook* (1994).

Citação literal, do artigo de 1991 (o caso do executivo):

> "Next, he divided the paper in half, and on the right-hand side of the page,
> he wrote a scenario for the meeting—much like the script for a movie or
> play—describing what he would say and how his subordinates would likely
> respond. On the left-hand side of the page, he wrote down any thoughts and
> feelings that he would be likely to have during the meeting but that he
> wouldn't express for fear they would derail the discussion."

E a razão de o exercício existir:

> "Ask people in an interview or questionnaire to articulate the rules they use
> to govern their actions, and they will give you what I call their 'espoused'
> theory of action. But observe these same people's behavior, and you will
> quickly see that this espoused theory has very little to do with how they
> actually behave. […] people consistently act inconsistently, unaware of the
> contradiction between their espoused theory and their theory-in-use."

## O que a fonte afirma, e o que não afirma

**Afirma:** o que a pessoa diz que faz e o que ela faz não batem, e ela não vê
a diferença; a coluna da esquerda — o que se pensa e não se diz — é onde a
contradição fica guardada. Argyris relata casos de intervenção com executivos e
consultores.

**Não afirma:** que escrever as duas colunas sozinho, num caderno, melhore a
relação. No método de Argyris o caso é DISCUTIDO com terceiros — é aí que o
aprendizado acontece, na descrição dele. Não há ensaio, não há medida de
eficácia; é método de intervenção e de ensino. A ficha não alega mais que isso.

## Por que passa nas quatro barras

1. **Ciclo** — MELHORAR.
2. **Origem verificável** — autor, obra, ano, veículo, citação literal do texto
   de 1991 (PDF de reserva de biblioteca universitária, texto conferido).
3. **Não duplica** — não é a **Expressiva**: a Expressiva é desabafo com tempo,
   porta fechada e selo, sem campos e sem comentário da IA; aqui há uma
   conversa concreta, quatro perguntas e uma frase de saída. Não é o
   **Steelman**: o Steelman reescreve a POSIÇÃO do outro no melhor, um exercício
   de argumento; a Coluna da esquerda olha para o que o AUTOR calou. Não é o
   **Se–então**, que é gatilho e substituto — embora leve a ele, e o
   encadeamento está proposto.
4. **Honestidade sobre evidência** — dito acima: sem estudo, com o detalhe
   incômodo (Argyris discute o caso com outros; o Traço não tem outros).

## O que ele desbanca ou complementa

Complementa a Expressiva sem invadi-la, e a ordem do catálogo garante isso: um
texto longo com palavras de sentimento continua indo para a Expressiva, que é
protegida (ver a prova de roteamento, bloco 1 — a frase "na reunião com o
chefe… senti uma raiva enorme… chorei depois" vai para a Expressiva, não para
cá). A Coluna da esquerda pega o outro caso: a frase curta, seca, factual, de
quem engoliu alguma coisa e sabe disso.

**Por isso este método NÃO pode ser posto antes da Expressiva no catálogo.**
Está medido: na ordem alternativa que testei, ele rouba o desabafo. Colar no
FIM do catálogo, sempre.

## Caso de uso real no Traço

O dono sai de uma reunião com um fornecedor tendo aceitado um prazo que sabe
impossível. Escreve "não disse o que pensei na conversa de ontem". A forma abre
com a conversa, cobra o que ele pensou e calou, o que o impediu (não queria
parecer difícil) e a frase que ele diria agora. O encadeamento manda para o
Se–então: *se* eu sentir que vou parecer difícil, *então* eu digo a frase.

## O que a forma pede e o app ainda não faz

A anatomia verdadeira do método são **duas colunas emparelhadas**: linha a
linha, o que foi dito ao lado do que se pensou naquela hora. O alinhamento é o
método — é olhando para a linha da direita que a da esquerda aparece. O
`CampoForma` de hoje é uma lista plana de campos, então o JSON abaixo entrega a
versão achatada (dois campos longos), que funciona no app de hoje e perde o
alinhamento.

**Volta de laço proposta:** um tipo de campo emparelhado (`par`, N linhas com
dois lados), que serviria também a qualquer método futuro de comparação. Não é
motivo de rejeição; é a próxima volta.

## JSON pronto para colar (versão achatada, roda hoje)

```json
{
  "id": "colunaEsquerda",
  "nome": "Coluna da esquerda",
  "origem": "Chris Argyris",
  "faculdade": "relação",
  "proveniencia": {
    "fonte": "Chris Argyris e Donald Schön, Theory in Practice (1974); o caso das duas colunas em Chris Argyris, \"Teaching Smart People How to Learn\", Harvard Business Review, maio–junho de 1991; difundido por Senge e colegas, The Fifth Discipline Fieldbook (1994)",
    "funcao": "pratica",
    "adaptacao": "Argyris escreve o roteiro de uma reunião que ainda vai acontecer e a analisa com terceiros. No Traço a conversa em geral já aconteceu, e quem lê é o próprio autor: o que foi dito, o que ele pensou e NÃO disse, o que o impediu de dizer, e a frase que diria agora na frente da pessoa. A IA nunca escreve a coluna da esquerda.",
    "evidencia": "Sem estudo de eficácia conhecido: é método de intervenção e ensino, com casos relatados, não ensaio. Argyris afirma que a teoria que a pessoa diz usar e a que ela usa de fato costumam não bater; não afirma que escrever as duas colunas sozinho num caderno melhore a relação.",
    "aplicabilidade": "Serve para uma conversa específica em que o principal ficou por dizer. Não serve para reclamar de alguém em geral, nem para desabafo — desabafo é a Expressiva, e ela não é comentada."
  },
  "filtro": "Coluna da esquerda",
  "reconhecimento": "isto é uma conversa em que você calou o principal.",
  "movimento": "Coluna da esquerda (Argyris). À direita, o que foi dito; à esquerda, o que se pensou e sentiu e não se disse. O que governa a conversa é a coluna da esquerda, e ela é a que ninguém escreve. Cobre se a esquerda tem mesmo o que doeu, o que impediu de dizer, e se a frase nova é dizível na frente da pessoa.",
  "pergunta": "O que você pensou e não disse — a frase inteira?",
  "roteamento": [
    "\\bn[ãa]o (disse|falei|consegui dizer)\\b|\\bengoli\\b|\\bfiquei calad[oa]\\b|\\bdeixei passar\\b",
    "\\bdevia ter (dito|falado|respondido)\\b|\\bqueria ter dito\\b|\\bo que eu queria ter falado\\b",
    "\\b(essa|aquela) conversa (com|foi)\\b|\\ba conversa com (o|a|ele|ela)\\b|\\bna reuni[ãa]o com\\b"
  ],
  "campos": [
    {
      "id": "comQuem",
      "rotulo": "A conversa (com quem, sobre o quê)"
    },
    {
      "id": "disse",
      "rotulo": "O que foi dito, dos dois lados"
    },
    {
      "id": "naoDisse",
      "rotulo": "O que eu pensei e NÃO disse"
    },
    {
      "id": "impediu",
      "rotulo": "O que me impediu de dizer"
    },
    {
      "id": "diria",
      "rotulo": "A frase que eu diria agora, na frente dela"
    }
  ],
  "recordar": {
    "alvo": [
      "naoDisse",
      "diria"
    ],
    "pista": [
      "comQuem"
    ],
    "pergunta": "O que você não disse — e o que diria agora?",
    "instrucao": "A conversa fica. A coluna da esquerda some.",
    "rotuloAlvo": "A COLUNA DA ESQUERDA"
  },
  "encadeamentos": [
    {
      "rotulo": "Se–então para a próxima",
      "para": "seEntao",
      "mapa": {
        "se": "impediu",
        "entao": "diria"
      },
      "exige": [
        "diria"
      ]
    },
    {
      "rotulo": "O outro lado, no melhor",
      "para": "steelman",
      "mapa": {
        "contraria": "disse"
      },
      "exige": [
        "disse"
      ]
    }
  ],
  "definicao": "uma conversa em que o principal ficou por dizer (\"não disse\", \"devia ter dito\", \"fiquei calado\")"
}
```

## Nota de rodada

A proteção da escrita pessoal não é tocada: a Expressiva continua vencendo o
roteamento no texto longo de sentimento, e este método não a contorna nem a
comenta.
