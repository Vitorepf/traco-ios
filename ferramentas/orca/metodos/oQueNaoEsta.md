# O que não está lá — ficha do candidato

Volta M9 da trilha Métodos · 06/09/2026 · **proposto**, não colado.

**GRAU A com uma novidade: a fonte é FICÇÃO** — e a régua da trilha ainda não
tinha classificado esse caso. Ver a seção própria abaixo.

Faculdade: **percepção** — a metade negativa dela.
Ciclo: **MULTIPLICAR agora** — o dia deste autor é feito de ler relatos de outros
(agentes, fornecedores, clientes) e decidir em cima deles. O que falta num relato
é a informação mais cara que existe, e é a única que não chega sozinha.

## Fonte

Arthur Conan Doyle, **"Silver Blaze"**, em *The Memoirs of Sherlock Holmes*
(1893; publicado no Strand em dezembro de 1892). Texto integral lido no Project
Gutenberg (eBook 834). Domínio público.

> "Is there any point to which you would wish to draw my attention?"
> "To the curious incident of the dog in the night-time."
> "The dog did nothing in the night-time."
> "That was the curious incident," remarked Sherlock Holmes.

Quatro linhas, e o método inteiro está nelas: a informação não estava no que
aconteceu, estava no que **deixou de** acontecer — e ninguém a teria notado sem
uma expectativa formada de antemão (um cão late para estranhos).

## Sobre citar ficção — o que a régua não previa

A [régua da proveniência](regua-da-proveniencia.md) tem cinco graus e nenhum deles
fala de ficção. Aplicando-a com honestidade:

- **É grau A pela forma:** obra publicada, autor, ano, veículo, edição, lida no
  texto integral. Não há nada de segunda mão aqui.
- **É o grau mais fraco que existe pelo conteúdo:** ficção não estabelece nada.
  Não é experimento, não é relato de prática, nem sequer é testemunho — é um
  personagem inventado notando uma ausência numa história escrita para que ele a
  notasse. O cão não latiu porque Doyle decidiu que não latiria.

**Proposta de emenda à régua, para o dono decidir:** a ficção entra como grau A
de *forma* e obriga uma linha a mais — **"é ficção; a fonte dá o critério e o
nome, e não estabelece nada"**. É o que esta ficha faz. Sem essa linha, um leitor
apressado vê "Doyle, 1892" e supõe evidência onde há literatura.

## O que a fonte afirma, e o que não afirma

**Afirma** — no sentido em que uma obra de ficção afirma: que a ausência só é
perceptível contra uma expectativa, e que a expectativa precisa ser convocada de
propósito.

**Não afirma**, e a lista é longa e importante: não há experimento, não há
medida, não há prática relatada. Não há evidência de que listar o esperado
melhore a leitura de relato nenhum. E há um risco que a ficha nomeia na
aplicabilidade: **este método pode virar instrumento de desconfiança.** A lista é
do que a própria história promete — não do que você teme. Um autor que use isto
para caçar má-fé vai achar má-fé em todo relato, porque toda lista feita com
suspeita se cumpre.

## Por que passa nas quatro barras

1. **Ciclo** — MULTIPLICAR agora.
2. **Origem verificável — grau A de forma**, com a ressalva da ficção escrita.
3. **Não duplica** — a **Nota do fato contrário** (leva 2) captura um fato que
   apareceu e vai contra você; aqui não apareceu nada, e é esse o ponto. O
   **Argumento** pede a melhor objeção, que é uma ideia; a falta não é ideia, é
   buraco. **Ver antes de nomear** (esta mesma rodada) registra o que está lá —
   este é o negativo dele, e por isso os dois dividem a faculdade. O
   **Combinado** cobra condição de pronto antes; este lê o que voltou.
4. **Honestidade sobre evidência** — dita acima, com o risco de uso nomeado.

## O que ele desbanca ou complementa

É o par de **Ver antes de nomear**: um registra o que está, o outro procura o que
não está. E encadeia para o **Combinado** (leva 2) — o que falta vira pedido com
condição de satisfação, em vez de virar ressentimento. Esse encadeamento é o
caminho real do dia do dono: relato incompleto → pergunta específica → combinado.

## Caso de uso real no Traço

Um relato de volta chega dizendo "suíte verde, tudo certo". A lista do que
deveria estar ali, se fosse o que diz ser: a saída colada, o número de testes, o
que foi testado que é novo, o que não foi. Falta a saída colada e falta o que não
foi testado. A falta mais provável não é mentira: é que o worker rodou uma parte.
A pergunta sai daí, específica, e vira combinado com condição de pronto.

## O que a forma pede e o app ainda não faz

Nada de estrutura. O campo `deveria` é mais uma lista de linha por item — o
**quinto** método a pedir o campo repetível (Divergência, Cinco porquês, Classe de
referência, Ordem de grandeza e este).

## JSON pronto para colar

```json
{
  "id": "oQueNaoEsta",
  "nome": "O que não está lá",
  "origem": "Arthur Conan Doyle, 1892",
  "faculdade": "percepção",
  "proveniencia": {
    "fonte": "GRAU A: obra publicada, lida no texto integral — e é FICÇÃO, o que a régua desta trilha ainda não tinha classificado. Arthur Conan Doyle, \"Silver Blaze\", em The Memoirs of Sherlock Holmes (1893; publicado no Strand em dezembro de 1892); Project Gutenberg, eBook 834. Doyle não propõe método: o diálogo do cão que não latiu dá o critério e o nome; os campos são do Traço.",
    "funcao": "lente",
    "adaptacao": "O Traço inverte a ordem que a cena de Doyle esconde: primeiro a LISTA do que deveria estar ali, feita de propósito, e só depois o que falta. Sem a lista antes, a ausência não aparece — é essa a única razão de o método existir em vez de ser um conselho.",
    "evidencia": "É ficção do século XIX. Não estabelece nada: nenhum experimento, nenhuma medida, nem sequer um relato de prática — um personagem inventado nota uma ausência numa história escrita para que ele a notasse. O que o Traço usa é o critério e o nome, e isto está dito. Não há evidência de que listar o esperado melhore a leitura de relato algum.",
    "aplicabilidade": "Serve para um relato, relatório ou cena que se quer conferir. Não serve para dúvida geral sobre alguém, e não é instrumento de desconfiança: a lista é do que a própria história promete, não do que você teme."
  },
  "filtro": "O que falta",
  "reconhecimento": "isto é um relato em que falta algo que deveria estar.",
  "movimento": "O cão que não latiu (Doyle, 1892). Diante de um relato, listar primeiro o que DEVERIA estar ali se ele fosse o que diz ser — e só então ver o que da lista não está. A ausência não salta à vista: ela só aparece contra uma lista feita antes. Cobre a lista antes do veredito, o que a falta mais provavelmente significa, e a pergunta que vai a quem escreveu.",
  "pergunta": "O que deveria estar aqui e não está?",
  "roteamento": [
    "\\bo que (est[áa] )?faltando\\b|\\bfalta alguma coisa\\b|\\bo que deveria estar\\b|\\bc[ãa]o que n[ãa]o latiu\\b",
    "\\bn[ãa]o mencionou\\b|\\bn[ãa]o falou (de|do|da|sobre)\\b|\\bpassou batido\\b|\\bevitou falar\\b",
    "\\bnada sobre\\b|\\bem nenhum momento (ele|ela|eles)\\b"
  ],
  "campos": [
    {
      "id": "relato",
      "rotulo": "O que eu tenho na frente (o relato, o relatório, a cena)"
    },
    {
      "id": "deveria",
      "rotulo": "O que DEVERIA estar aqui, se isto fosse o que diz ser (um por linha)"
    },
    {
      "id": "falta",
      "rotulo": "O que dessa lista não está"
    },
    {
      "id": "significa",
      "rotulo": "O que a falta mais provavelmente significa"
    },
    {
      "id": "pergunto",
      "rotulo": "O que eu pergunto, e a quem"
    }
  ],
  "recordar": {
    "alvo": [
      "falta"
    ],
    "pista": [
      "relato"
    ],
    "pergunta": "O que faltava naquele relato?",
    "instrucao": "O relato fica. A falta some.",
    "rotuloAlvo": "O QUE FALTAVA"
  },
  "encadeamentos": [
    {
      "rotulo": "Pedir o que falta (Combinado)",
      "para": "combinado",
      "mapa": {
        "pedido": "pergunto",
        "pronto": "falta"
      },
      "exige": [
        "pergunto"
      ]
    },
    {
      "rotulo": "Perguntei? Conferir em 3 dias",
      "compromisso": {
        "titulo": "perguntei? ",
        "campo": "pergunto",
        "dias": 3
      },
      "exige": [
        "pergunto"
      ]
    }
  ],
  "definicao": "um relato ou cena em que falta algo que deveria estar (\"o que está faltando\", \"não mencionou\")"
}
```
