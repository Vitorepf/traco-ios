# Ordem de grandeza — ficha do candidato

Volta M4 da trilha Métodos · 06/09/2026 · **proposto**, não colado.

Faculdade: **quantidade** (vazia). O catálogo inteiro é de palavras: em 21
métodos, o único número é o 0 a 100 da Atualização, que é grau de crença, não
grandeza do mundo.
Ciclo: **MULTIPLICAR agora** — um número aproximado em dois minutos decide o que
nem começa. E MELHORAR: estimar é habilidade, e quem nunca põe número não a
desenvolve.

## Fonte

**Enrico Fermi, "My Observations During the Explosion at Trinity on July 16,
1945"** — relatório curto de observação, lido na íntegra.

> "About 40 seconds after the explosion the air blast reached me. I tried to
> estimate its strength by dropping from about six feet small pieces of paper
> before, during and after the passage of the blast wave. Since at the time,
> there was no wind I could observe very distinctly and actually measure the
> displacement of the pieces of paper that were in the process of falling while
> the blast was passing. The shift was about 2½ meters, which, at the time, I
> estimated to correspond to the blast that would be produced by ten thousand
> tons of T.N.T."

A prática de estimar quebrando a pergunta em fatores palpitáveis ficou conhecida
como **problema de Fermi**, e é tradição de ensino de física sem autor único —
a ficha diz a tradição em vez de inventar um dono, que é o que a barra 2 pede.

## O que a fonte afirma, e o que não afirma

**Afirma:** que Fermi, em campo, com pedaços de papel, produziu uma estimativa
de energia enquanto todo mundo esperava semanas pelo cálculo.

**Não afirma:** nada sobre método. É um relatório de observação; Fermi não
propõe técnica, não ensina nada, não generaliza. E — o ponto que a ficha faz
questão de escrever — **o número dele estava errado**: dez mil toneladas de TNT
contra as vinte e uma mil do cálculo final. Errado por mais do dobro, e ainda
assim mais perto do que a maior parte das previsões de Los Alamos. **É essa a
promessa do método: a casa decimal e a velocidade, não a precisão.** Não há
estudo de eficácia, e este método é o que menos poderia alegar um: ele se
apresenta como aproximação.

## Por que passa nas quatro barras

1. **Ciclo** — os dois, dito acima.
2. **Origem verificável** — autor, documento, data, lido na íntegra; e a
   tradição nomeada como tradição.
3. **Não duplica** — a **Classe de referência** (M1) prevê prazo ou custo pelos
   casos parecidos que o autor já viveu: precisa de história. Este funciona
   quando não há caso nenhum — decompõe em fatores e multiplica. São o par de
   uma coisa só, e por isso encadeiam: se há casos, Classe; se não há, fatores.
   A **Atualização** dá número a uma crença sobre o mundo, não a uma grandeza. E
   a **Divergência** gera opções, não quantidades.
4. **Honestidade sobre evidência** — a ficha diz que o número de Fermi estava
   errado por mais do dobro. Um método cuja fonte é um erro documentado é mais
   honesto do que a maioria.

## O que ele desbanca ou complementa

Complementa a Classe de referência pelos dois lados, e o encadeamento vai daqui
para lá: quem começou pelos fatores e descobre que TEM casos parecidos deve usar
os casos, que são melhores. Complementa também a Especificação — restrição sem
número é desejo.

## Caso de uso real no Traço

"Dá para estimar quantas notas por ano?" Antes de projetar exportação, busca ou
compressão, o dono quebra: quantos dias eu escrevo por semana, quantas notas por
dia, quantos caracteres por nota. Multiplica. Sai a casa — milhares, não milhões
— e a casa decide a arquitetura. O campo do "o que teria de ser verdade para
mudar de casa" é o que impede o número de virar opinião: se um fator dobrar,
muda? Se não muda, a conta aguenta.

## O que a forma pede e o app ainda não faz

Duas coisas, nenhuma bloqueante:

1. O campo dos fatores é uma **lista com uma linha por fator** — o mesmo campo
   repetível que a Divergência, os Cinco porquês e a Classe de referência já
   pediram. Quatro métodos agora. Está em `achados-catalogo.md`.
2. Um campo de **conta** que o app soubesse multiplicar seria o luxo: hoje o
   autor multiplica na cabeça ou na calculadora e escreve o resultado. Não
   proponho calculadora dentro do Traço — é escopo novo e o dono decide —, mas
   registro que é aqui que ela faria falta.

## JSON pronto para colar

```json
{
  "id": "ordemDeGrandeza",
  "nome": "Ordem de grandeza",
  "origem": "Enrico Fermi, 1945",
  "faculdade": "quantidade",
  "proveniencia": {
    "fonte": "GRAU A para o relatório de Fermi, lido na íntegra; GRAU D para a prática (problema de Fermi, tradição de ensino de física, sem autor único). Enrico Fermi, \"My Observations During the Explosion at Trinity on July 16, 1945\"; relatório curto, lido na íntegra. A prática de estimar por decomposição ficou conhecida como problema de Fermi e é tradição de ensino de física, sem autor único.",
    "funcao": "pratica",
    "adaptacao": "Fermi estimou uma grandeza com o que tinha na mão, em segundos. O Traço faz disso cinco campos: a pergunta, os fatores em que ela se quebra com o palpite de cada um, a conta, a CASA — e o campo que separa número de opinião: o que teria de ser verdade para o resultado mudar de casa.",
    "evidencia": "O relatório de Fermi é observação de campo, não artigo de método: ele não propõe técnica nenhuma. E o número dele estava errado — estimou dez mil toneladas de TNT, e o cálculo final deu vinte e uma mil. Errado por mais do dobro, e ainda assim mais perto do que a maior parte das previsões de Los Alamos. A promessa do método é a casa e a velocidade, não a precisão. Não há estudo de eficácia.",
    "aplicabilidade": "Serve para uma quantidade desconhecida que se quebra em fatores palpitáveis. Não serve quando existem casos parecidos com desfecho conhecido — aí é a Classe de referência — nem quando a resposta exata está a um clique."
  },
  "filtro": "Ordem de grandeza",
  "reconhecimento": "isto é uma quantidade que dá para estimar antes de medir.",
  "movimento": "Ordem de grandeza (problema de Fermi). Quebrar a pergunta em fatores que dá para palpitar, palpitar cada um, multiplicar, e dizer a CASA: dezenas, milhares, milhões. Cobre o palpite de cada fator separado — o palpite escondido dentro da cabeça não conta — e a pergunta que separa número de opinião: o que teria de ser verdade para o resultado mudar de casa.",
  "pergunta": "Em que fatores isto se quebra — e quanto é cada um?",
  "roteamento": [
    "\\bordem de grandeza\\b|\\bchute de quanto\\b|\\bn[úu]mero aproximado\\b|\\bproblema de fermi\\b",
    "\\bd[áa] para estimar\\b|\\bquanto (dá|daria) mais ou menos\\b|\\bquantos? mais ou menos\\b",
    "\\bnem sei a ordem\\b|\\bnem imagino quanto\\b|\\bquanto ser[áa] que d[áa]\\b"
  ],
  "campos": [
    {
      "id": "quantidade",
      "rotulo": "A quantidade que eu quero saber"
    },
    {
      "id": "fatores",
      "rotulo": "Os fatores, um por linha, com o meu palpite"
    },
    {
      "id": "conta",
      "rotulo": "A conta e o resultado"
    },
    {
      "id": "casa",
      "rotulo": "A casa: dezenas, centenas, milhares…"
    },
    {
      "id": "muda",
      "rotulo": "O que teria de ser verdade para mudar de casa"
    },
    {
      "id": "medido",
      "rotulo": "O número de verdade, quando eu souber",
      "soDepois": true
    }
  ],
  "recordar": {
    "alvo": [
      "casa",
      "muda"
    ],
    "pista": [
      "quantidade"
    ],
    "pergunta": "Qual era a casa, e o que a mudaria?",
    "instrucao": "A pergunta fica. O número some.",
    "rotuloAlvo": "A CASA"
  },
  "encadeamentos": [
    {
      "rotulo": "Tem casos parecidos? Classe de referência",
      "para": "classeDeReferencia",
      "mapa": {
        "estimo": "quantidade"
      },
      "exige": [
        "quantidade"
      ]
    },
    {
      "rotulo": "Conferir o número em 30 dias",
      "compromisso": {
        "titulo": "o número de verdade: ",
        "campo": "quantidade",
        "dias": 30
      },
      "exige": [
        "casa"
      ]
    }
  ],
  "definicao": "uma quantidade desconhecida que se quebra em fatores palpitáveis (\"ordem de grandeza\", \"dá para estimar\")"
}
```
