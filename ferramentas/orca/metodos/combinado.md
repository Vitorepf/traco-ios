# O combinado — ficha do candidato

Volta M5 da trilha Métodos · 06/09/2026 · **proposto**, não colado.

Faculdade: **coordenação** (vazia). Com a Coluna da esquerda, o catálogo passa a
ter dois métodos que envolvem outra pessoa: um para a conversa que azedou, este
para o combinado antes de azedar.
Ciclo: **MULTIPLICAR agora** — quase tudo o que o autor realiza passa por outra
pessoa fazendo alguma coisa. Um combinado sem condição de pronto é a forma mais
cara de perder uma semana.

## Fonte

Terry Winograd, **"A Language/Action Perspective on the Design of Cooperative
Work"**, apresentado na CSCW '86 (Austin, dezembro de 1986); versão em
*Human-Computer Interaction* 3(1), 1987, p. 3–30. Texto integral lido. A
estrutura da conversa para ação é de Fernando Flores (1981) e de Winograd e
Flores, *Understanding Computers and Cognition* (1986).

O método, na fonte:

> "In a simple conversation for action, one party (A) makes a request to another
> (B). The request is interpreted by each party as having certain conditions of
> satisfaction, which characterize a future course of actions by B. After the
> initial utterance (the request), B can accept (and thereby commit to satisfy
> the conditions); reject (and thereby end the conversation); or counter-offer
> with alternative conditions."

O fim, que é a parte que ninguém faz:

> "In the 'normal' course of events, B at some point asserts to A that the
> conditions of satisfaction have been met […]. If A declares that he/she is
> satisfied, the conversation reaches a successful completion."

E a razão de tudo isso ter de ser dito em voz alta:

> "Speech acts take effect by virtue of public declaration — by mutual knowledge
> of hearer and speaker that the act has been made. This is especially obvious
> in the case of declarations and expressives (an apology muttered but not heard
> is not an apology), but is equally true of the others."

## O que a fonte afirma, e o que não afirma

**Afirma:** que um pedido carrega condições de satisfação interpretadas pelos
dois lados; que as respostas legítimas são aceitar, recusar ou contrapor; e que
o combinado só se completa quando quem pediu declara satisfação — a entrega
sozinha não fecha nada.

**Não afirma:** nada sobre eficácia, e Winograd é explícito sobre o que o
diagrama não é: *"This diagram is not a model of the mental state of a speaker
or hearer"* — é a estrutura da conversa, não psicologia. Mais: o próprio artigo,
descrevendo um hospital real, observa que ali **"acceptance of an offer or
request is assumed whenever it is not explicitly rejected"** e que a declaração
de satisfação fica implícita na ausência de reclamação. Ou seja, a fonte
documenta que a prática comum PULA exatamente o que este método cobra — o que
justifica o método e, ao mesmo tempo, avisa que cobrar isso tem atrito.

E há crítica publicada, que a ficha traz porque é séria: Lucy Suchman,
**"Do categories have politics?"**, *Computer Supported Cooperative Work* 2,
1993, p. 177–190 (metadados no Crossref) — sistemas construídos sobre esta
perspectiva impõem disciplina a quem recebe o pedido. Numa nota pessoal a
objeção perde força (o autor está escrevendo o que ele mesmo combinou, e o
Traço não notifica ninguém), mas não some: quem lê a própria nota pode passar a
cobrar dos outros um formalismo que eles não aceitaram.

## Por que passa nas quatro barras

1. **Ciclo** — MULTIPLICAR agora.
2. **Origem verificável** — autor, conferência, data, periódico, páginas; três
   citações literais lidas no texto integral, mais a crítica com DOI.
3. **Não duplica** — a **Especificação** define pronto para uma coisa que o
   autor vai construir sozinho; aqui "pronto" é acordo entre duas cabeças, e a
   pergunta é como AMBOS saberão. A **Coluna da esquerda** (M1) trata da
   conversa que já saiu errada; esta trata do combinado antes disso, e encadeia
   para lá quando azeda. O **Se–então** é gatilho e substituto, sozinho. E o
   `compromisso` do app marca data — data não é condição de satisfação.
4. **Honestidade sobre evidência** — dito acima, incluindo a crítica de Suchman
   e a observação da própria fonte de que a prática real presume o aceite.

## O que ele desbanca ou complementa

Complementa o compromisso do app, que hoje é só data: aqui a data vem
acompanhada do que era "pronto". E encadeia para a Coluna da esquerda quando o
combinado vira ressentimento — que é o caminho real das duas coisas.

## Caso de uso real no Traço

O dono despacha uma volta para um agente. "Ficou de me mandar o relato com a
evidência colada." Duas semanas depois, o relato veio sem as capturas, e a
discussão é sobre o que era "pronto". A forma cobra as condições ANTES, cobra
qual foi a resposta de fato (silêncio não é aceite — e num despacho para agente
o silêncio é a resposta mais comum), e no fim cobra a declaração: satisfeito, ou
o que faltou.

## O que a forma pede e o app ainda não faz

Nada de estrutura. Uma observação de rota: o compromisso de 7 dias já leva o
pedido para a agenda, mas leva só a frase do pedido. Levar junto a condição de
pronto tornaria a cobrança utilizável sem abrir a nota — e isso é o
`compromisso` aceitando um segundo campo, item pequeno para a lista da seção 7
de `achados-catalogo.md`.

## JSON pronto para colar

```json
{
  "id": "combinado",
  "nome": "O combinado",
  "origem": "Winograd e Flores, 1986",
  "faculdade": "coordenação",
  "proveniencia": {
    "fonte": "Terry Winograd, \"A Language/Action Perspective on the Design of Cooperative Work\", CSCW '86 (Austin, dezembro de 1986); versão em Human-Computer Interaction 3(1), 1987, p. 3–30. Texto integral lido. A estrutura da conversa para ação vem de Fernando Flores (1981) e de Winograd e Flores, Understanding Computers and Cognition (1986).",
    "funcao": "lente",
    "adaptacao": "A conversa para ação tem duas pessoas e, no artigo, um sistema que acompanha os estados. O Traço tem uma pessoa e uma nota: o autor escreve o pedido na frase que usou, as condições de satisfação como as duas partes as entenderiam, a resposta que veio de fato — e, na volta, se ele declarou satisfeito. Nada disto governa o outro; é o autor escrevendo o que combinou.",
    "evidencia": "É uma perspectiva de projeto, não um estudo de eficácia. Winograd diz que o diagrama \"não é um modelo do estado mental\" de ninguém, e sim a estrutura da conversa. O próprio artigo observa que, no hospital que ele descreve, o aceite é presumido quando não há recusa explícita e a declaração de satisfação fica implícita — ou seja, o que este método cobra é justamente o que a prática deixa de fora. Há crítica publicada: Lucy Suchman, \"Do categories have politics?\", CSCW 2, 1993, p. 177–190, argumenta que transformar conversa em máquina de estados impõe disciplina a quem é pedido. Numa nota pessoal isso não se aplica do mesmo jeito, mas fica dito.",
    "aplicabilidade": "Serve para um pedido ou uma promessa entre duas pessoas, com prazo. Não serve para tarefa só sua — aí é a Especificação — nem para conversa que já azedou, que é a Coluna da esquerda."
  },
  "filtro": "Combinado",
  "reconhecimento": "isto é um combinado com outra pessoa.",
  "movimento": "Conversa para ação (Winograd e Flores). Um pedido só existe com condições de satisfação — o que as DUAS partes vão entender por pronto — e com um aceite explícito: silêncio não é aceite, e recusa e contraproposta são respostas legítimas. E o combinado não termina quando o outro entrega: termina quando quem pediu DECLARA que está satisfeito. Cobre as condições, a resposta que veio de fato, e a declaração no fim.",
  "pergunta": "Como vocês dois vão saber que está pronto?",
  "roteamento": [
    "\\bcombinei com\\b|\\bficou combinado\\b|\\bo combinado (era|foi)\\b|\\bcondi[çc][õo]es de satisfa[çc][ãa]o\\b",
    "\\bpedi (para|pro|pra) (o|a|ele|ela)\\b|\\bprometi (para|pro|pra)\\b|\\bme comprometi a\\b",
    "\\bficou de (me )?(mandar|fazer|entregar|responder|trazer)\\b|\\bdisse que (ia|iria) (mandar|fazer|entregar)\\b"
  ],
  "campos": [
    {
      "id": "pedido",
      "rotulo": "O que eu pedi (ou prometi), na frase que eu usei"
    },
    {
      "id": "quem",
      "rotulo": "Com quem"
    },
    {
      "id": "pronto",
      "rotulo": "Condições de satisfação: como nós DOIS vamos saber que está pronto"
    },
    {
      "id": "quando",
      "rotulo": "Para quando"
    },
    {
      "id": "resposta",
      "rotulo": "O que veio: aceitou, recusou, contrapôs — ou nada"
    },
    {
      "id": "declarei",
      "rotulo": "Entregue e declarado satisfeito? O que faltou",
      "soDepois": true
    }
  ],
  "recordar": {
    "alvo": [
      "pronto"
    ],
    "pista": [
      "pedido",
      "quem"
    ],
    "pergunta": "Quais eram as condições de satisfação?",
    "instrucao": "O pedido fica. O que era \"pronto\" some.",
    "rotuloAlvo": "O QUE ERA PRONTO"
  },
  "encadeamentos": [
    {
      "rotulo": "Cobrar o combinado em 7 dias",
      "compromisso": {
        "titulo": "combinado: ",
        "campo": "pedido",
        "dias": 7
      },
      "exige": [
        "pronto"
      ]
    },
    {
      "rotulo": "Se azedou, abrir a conversa",
      "para": "colunaEsquerda",
      "mapa": {
        "comQuem": "quem",
        "disse": "resposta"
      },
      "exige": [
        "resposta"
      ]
    }
  ],
  "definicao": "um combinado com outra pessoa: o pedido, as condições de satisfação e o aceite (\"combinei com\", \"ficou de me mandar\")"
}
```
