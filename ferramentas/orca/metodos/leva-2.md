# Leva 2 — pacote de colagem

Trilha Métodos · fechado na volta M8 · 06/09/2026.

**Para quem vai colar.** Este arquivo basta: não é preciso abrir as oito fichas
nem interpretar nada. Cada método vem com o objeto JSON final, o grau de
proveniência já declarado, os encadeamentos e as frases que têm de rotear para
ele no app. As fichas continuam existindo, uma por método, para quem quiser a
defesa e as citações; a colagem não depende delas.

O que **não** está aqui, de propósito: o que a leva 2 pede do app. Está no fim,
depois da linha de corte, para não confundir quem cola — **nada daquilo é
pré-requisito**.

## Antes de abrir o `Metodos.json`

1. **A leva 1 tem de estar dentro primeiro.** Quatro encadeamentos da leva 2
   apontam para métodos da leva 1 (`classeDeReferencia`, `subtracao`,
   `colunaEsquerda`, `vistoNaoVisto`). Se a leva 1 não estiver colada, esses
   botões acendem e não fazem nada — ver `achados-catalogo.md`, I.4.
   Conferido em 06/09: `main` tem 21 métodos; a leva 1 está com a volta M3.
2. **Leia `achados-catalogo.md`, Parte I inteira.** Em especial I.2: nenhum
   destes entra antes da Expressiva. Todos vão **no fim do array**, na ordem
   abaixo. Dentro da leva a ordem não é crítica — nenhum dos oito aponta para
   outro dos oito —, mas mantê-la facilita a conferência.
3. **Copie o bloco `json` inteiro, sem reescrever.** As regex têm `\b` e acentos
   testados; retocar à mão é o jeito mais fácil de estragar a prova.

## Os oito, na ordem

| # | método | id | faculdade | grau |
|---|---|---|---|---|
| 1 | A nota do fato contrário | `fatoContrario` | honestidade | A |
| 2 | Ordem de grandeza | `ordemDeGrandeza` | quantidade | A (fonte) + D (prática) |
| 3 | Começaria hoje? | `comecariaHoje` | desapego | A (Jevons) + B (Arkes, dito) |
| 4 | O combinado | `combinado` | coordenação | A |
| 5 | O ponto que decide | `pontoQueDecide` | desacordo | C |
| 6 | O que se repetiu | `oQueSeRepetiu` | balanço | A |
| 7 | A regra que eu faço | `regraQueEuFaco` | ética | A |
| 8 | A reparação | `reparacao` | reparação | A |

Seis dos oito são grau A limpo. Era a restrição que o dono pôs na M7, e ela
mudou o resultado: as levas anteriores acumulavam grau C porque fonte aberta é
mais fácil de achar, não porque o mundo só tivesse grau C.

---

### 1. A nota do fato contrário — `fatoContrario`

- **rodada** M4 · **faculdade** honestidade · **função** pratica · **GRAU A: obra publicada, lida no texto integral**
- **o que faz:** isto é um fato contra o que você defende — e ele foge.
- **encadeia para:** `atualizacao`, `argumento`  · todos já estarão no catálogo depois da leva 1
- **frases de teste** (têm de rotear para `fatoContrario` no app):
  - «achei um estudo contra o que eu venho defendendo»
  - «esse número não bate com o que eu venho dizendo»

```json
{
  "id": "fatoContrario",
  "nome": "A nota do fato contrário",
  "origem": "Charles Darwin",
  "faculdade": "honestidade",
  "proveniencia": {
    "fonte": "GRAU A: obra publicada, lida no texto integral. Charles Darwin, The Autobiography of Charles Darwin (escrita em 1876, publicada em 1887 por Francis Darwin); texto integral lido no Project Gutenberg, eBook 2010",
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

### 2. Ordem de grandeza — `ordemDeGrandeza`

- **rodada** M4 · **faculdade** quantidade · **função** pratica · **GRAU A para o relatório de Fermi, lido na íntegra; GRAU D para a prática (problema de Fermi, tradição de ensino de física, sem autor único)**
- **o que faz:** isto é uma quantidade que dá para estimar antes de medir.
- **encadeia para:** `classeDeReferencia`  · todos já estarão no catálogo depois da leva 1
- **frases de teste** (têm de rotear para `ordemDeGrandeza` no app):
  - «qual é a ordem de grandeza disso»
  - «dá para estimar quantas notas por ano»

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

### 3. Começaria hoje? — `comecariaHoje`

- **rodada** M4 · **faculdade** desapego · **função** lente · **GRAU A para Jevons, lido no fac-símile; GRAU B para Arkes e Blumer — metadados conferidos, texto integral atrás de paywall, NÃO lido**
- **o que faz:** isto já consumiu muito, e é por isso que continua.
- **encadeia para:** `decisao`, `subtracao`  · todos já estarão no catálogo depois da leva 1
- **frases de teste** (têm de rotear para `comecariaHoje` no app):
  - «já investi seis meses nessa frente»
  - «não posso parar agora, seria desperdício largar»

```json
{
  "id": "comecariaHoje",
  "nome": "Começaria hoje?",
  "origem": "Jevons, 1871",
  "faculdade": "desapego",
  "proveniencia": {
    "fonte": "GRAU A para Jevons, lido no fac-símile; GRAU B para Arkes e Blumer — metadados conferidos, texto integral atrás de paywall, NÃO lido. William Stanley Jevons, The Theory of Political Economy (1871), p. 159–160: \"In commerce, bygones are for ever bygones\"; texto integral lido no exemplar digitalizado da Universidade de Toronto, no Internet Archive. O viés que o método existe para vencer está documentado em Hal R. Arkes e Catherine Blumer, \"The psychology of sunk cost\", Organizational Behavior and Human Decision Processes 35(1), 1985, p. 124–140.",
    "funcao": "lente",
    "adaptacao": "Jevons enuncia o princípio; o Traço o transforma em pergunta com data. O que já foi gasto ganha um campo — para ser escrito e posto de lado, não ignorado — e a decisão é tomada como se hoje fosse o primeiro dia.",
    "evidencia": "Jevons argumenta, não mede: é economia clássica de 1871. De Arkes e Blumer eu confirmei os metadados no Crossref, mas NÃO li o texto integral, que está atrás de paywall — digo isto em vez de citar de segunda mão. E a literatura posterior não é unânime: o próprio Arkes assina, em 1998, um trabalho intitulado \"Failure to demonstrate the sunk cost effect in a field experiment\". Nada aqui alega que responder à pergunta melhore decisão alguma.",
    "aplicabilidade": "Serve para algo em curso em que já se investiu tempo, dinheiro ou reputação. Não serve para escolha nova — aí é a Decisão — nem para o que não dá para abandonar."
  },
  "filtro": "Começaria hoje?",
  "reconhecimento": "isto já consumiu muito, e é por isso que continua.",
  "movimento": "Bygones (Jevons, 1871): o trabalho já gasto não tem influência sobre o valor futuro de coisa nenhuma. Escrever o que já foi gasto — para tirar do caminho, não para fingir que não houve — e decidir como se hoje fosse o primeiro dia: sabendo o que eu sei agora, eu começaria isto hoje? Cobre a resposta honesta em uma frase e o que muda: seguir com critério novo, ou parar dizendo o que se leva.",
  "pergunta": "Sabendo o que você sabe hoje, você começaria isto hoje?",
  "roteamento": [
    "\\bj[áa] investi\\b|\\bj[áa] gastei tanto\\b|\\bdepois de tudo (que|o que) eu\\b",
    "\\bcusto afundado\\b|\\bcome[çc]aria (isso |isto )?hoje\\b|\\bcome[çc]aria de novo\\b",
    "\\bn[ãa]o posso parar agora\\b|\\bseria desperd[íi]cio (parar|desistir|largar)\\b|\\bjogar fora tudo\\b"
  ],
  "campos": [
    {
      "id": "oQue",
      "rotulo": "O que está em curso"
    },
    {
      "id": "gastei",
      "rotulo": "O que eu já gastei (tempo, dinheiro, reputação)"
    },
    {
      "id": "hoje",
      "rotulo": "Sabendo o que sei hoje, eu começaria isto hoje?"
    },
    {
      "id": "porque",
      "rotulo": "Por quê — em uma frase"
    },
    {
      "id": "faco",
      "rotulo": "O que eu faço: sigo com que critério, ou paro"
    },
    {
      "id": "levo",
      "rotulo": "Se parar: o que eu levo daqui"
    }
  ],
  "encadeamentos": [
    {
      "rotulo": "Decidir com critério novo",
      "para": "decisao",
      "mapa": {
        "escolha": "oQue",
        "criterio": "porque"
      },
      "exige": [
        "faco"
      ]
    },
    {
      "rotulo": "Se parar, o que sai",
      "para": "subtracao",
      "mapa": {
        "melhorar": "oQue",
        "sai": "oQue"
      },
      "exige": [
        "faco"
      ]
    },
    {
      "rotulo": "Perguntar de novo em 30 dias",
      "compromisso": {
        "titulo": "ainda começaria hoje? ",
        "campo": "oQue",
        "dias": 30
      },
      "exige": [
        "faco"
      ]
    }
  ],
  "definicao": "algo em curso que continua por causa do que já se gastou (\"já investi muito\", \"não posso parar agora\")"
}
```

### 4. O combinado — `combinado`

- **rodada** M5 · **faculdade** coordenação · **função** lente · **GRAU A: artigo publicado, lido no texto integral**
- **o que faz:** isto é um combinado com outra pessoa.
- **encadeia para:** `colunaEsquerda`  · todos já estarão no catálogo depois da leva 1
- **frases de teste** (têm de rotear para `combinado` no app):
  - «combinei com o fornecedor que ele manda até sexta»
  - «ficou de me mandar o arquivo e não mandou»

```json
{
  "id": "combinado",
  "nome": "O combinado",
  "origem": "Winograd e Flores, 1986",
  "faculdade": "coordenação",
  "proveniencia": {
    "fonte": "GRAU A: artigo publicado, lido no texto integral. Terry Winograd, \"A Language/Action Perspective on the Design of Cooperative Work\", CSCW '86 (Austin, dezembro de 1986); versão em Human-Computer Interaction 3(1), 1987, p. 3–30. Texto integral lido. A estrutura da conversa para ação vem de Fernando Flores (1981) e de Winograd e Flores, Understanding Computers and Cognition (1986).",
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

### 5. O ponto que decide — `pontoQueDecide`

- **rodada** M5 · **faculdade** desacordo · **função** pratica · **GRAU C: material assinado e datado fora da edição formal (post de comunidade, manual de oficina), lido na íntegra; não passou por editora nem revisão de pares**
- **o que faz:** isto é um desacordo sem o fato que o decide.
- **encadeia para:** `steelman`, `atualizacao`  · todos já estarão no catálogo depois da leva 1
- **frases de teste** (têm de rotear para `pontoQueDecide` no app):
  - «discordamos sobre o roteamento local há semanas»
  - «estamos em impasse e cada um acha uma coisa»

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

### 6. O que se repetiu — `oQueSeRepetiu`

- **rodada** M6 · **faculdade** balanço · **função** lente · **GRAU A: obra publicada, lida no texto integral em tradução identificada**
- **o que faz:** isto é um período inteiro pedindo contagem, não lembrança.
- **encadeia para:** `seEntao`  · todos já estarão no catálogo depois da leva 1
- **frases de teste** (têm de rotear para `oQueSeRepetiu` no app):
  - «balanço do ano: o que ficou»
  - «eu sempre faço isso, ou acho que faço»

```json
{
  "id": "oQueSeRepetiu",
  "nome": "O que se repetiu",
  "origem": "Aristóteles (Ética a Nicômaco)",
  "faculdade": "balanço",
  "proveniencia": {
    "fonte": "GRAU A: obra publicada, lida no texto integral em tradução identificada. Aristóteles, Ética a Nicômaco, livro I, capítulo 7, e livro II, capítulo 1; tradução inglesa de D. P. Chase, lida no texto integral do Project Gutenberg (eBook 8438). Aristóteles NÃO propõe este exercício: o Traço toma dele o critério — uma vez não estabelece disposição — e monta o resto.",
    "funcao": "lente",
    "adaptacao": "O critério de Aristóteles vira contagem: o autor escreve o que DIZ que faz, depois o que fez mais de uma vez com quantas, e o que fez uma vez só e conta como se fosse hábito. O fecho é do Traço: parar de dizer, ou marcar a próxima data.",
    "evidencia": "É argumento filosófico do século IV a.C., não medida: Aristóteles discute felicidade e virtude ao longo de uma vida inteira, e não faz balanço de ano nem propõe procedimento. Não há estudo de eficácia de nada disto, e a contagem que o método pede é a do próprio autor, sujeita à mesma memória seletiva que ele quer corrigir — por isso o método vale mais com as notas do período à mão.",
    "aplicabilidade": "Serve para o fim de um período longo (um ano, um trimestre) em que o autor quer separar o que faz do que diz que faz. Não serve para o dia — isso é o Dia — nem para julgar conduta, que é o Exame da noite."
  },
  "filtro": "O que se repetiu",
  "reconhecimento": "isto é um período inteiro pedindo contagem, não lembrança.",
  "movimento": "O critério de Aristóteles: \"não é uma andorinha nem um dia bonito que fazem a primavera\". Uma vez não estabelece disposição — disposição é o que se repete. Cobre a contagem: o que o autor DIZ que faz, o que ele fez mais de uma vez e QUANTAS, e o que fez uma vez só e conta como hábito. É a contagem, não a lembrança, que separa uma coisa da outra.",
  "pergunta": "Quantas vezes, de verdade? Uma vez não conta.",
  "roteamento": [
    "\\bbalan[çc]o do (ano|semestre|trimestre)\\b|\\bo que ficou (do|desse|deste) ano\\b|\\bfechando o ano\\b",
    "\\bolhando (o ano|os [úu]ltimos meses|para tr[áa]s)\\b|\\bno ano passado eu\\b|\\bnesse ano eu\\b",
    "\\beu (sempre|nunca) fa[çc]o isso\\b|\\bvivo fazendo\\b|\\bisso [ée] o que eu fa[çc]o\\b"
  ],
  "campos": [
    {
      "id": "periodo",
      "rotulo": "O período (de quando a quando)"
    },
    {
      "id": "digo",
      "rotulo": "O que eu digo que faço"
    },
    {
      "id": "repeti",
      "rotulo": "O que eu fiz mais de uma vez — e quantas"
    },
    {
      "id": "umaVez",
      "rotulo": "O que eu fiz UMA vez e conto como se fosse hábito"
    },
    {
      "id": "paro",
      "rotulo": "O que eu paro de dizer que faço"
    },
    {
      "id": "sigo",
      "rotulo": "O que eu levo para o período seguinte, e a primeira data"
    }
  ],
  "recordar": {
    "alvo": [
      "umaVez"
    ],
    "pista": [
      "digo"
    ],
    "pergunta": "O que você contava como hábito e tinha feito uma vez só?",
    "instrucao": "O que você diz que faz fica. A contagem some.",
    "rotuloAlvo": "A UMA VEZ SÓ"
  },
  "encadeamentos": [
    {
      "rotulo": "Virar hábito (Se–então)",
      "para": "seEntao",
      "mapa": {
        "entao": "sigo"
      },
      "exige": [
        "sigo"
      ]
    },
    {
      "rotulo": "Conferir a contagem em 90 dias",
      "compromisso": {
        "titulo": "quantas vezes? ",
        "campo": "sigo",
        "dias": 90
      },
      "exige": [
        "sigo"
      ]
    }
  ],
  "definicao": "um período longo em que o autor separa o que faz do que diz que faz, contando as vezes"
}
```

### 7. A regra que eu faço — `regraQueEuFaco`

- **rodada** M7 · **faculdade** ética · **função** lente · **GRAU A: obra publicada, lida no texto integral em tradução identificada**
- **o que faz:** isto é um ato que ainda não passou pela pergunta do certo.
- **encadeia para:** `decisao`, `vistoNaoVisto`  · todos já estarão no catálogo depois da leva 1
- **frases de teste** (têm de rotear para `regraQueEuFaco` no app):
  - «só desta vez eu passo por cima disso»
  - «e se todos fizessem isso, no que dá»

```json
{
  "id": "regraQueEuFaco",
  "nome": "A regra que eu faço",
  "origem": "Immanuel Kant, 1785",
  "faculdade": "ética",
  "proveniencia": {
    "fonte": "GRAU A: obra publicada, lida no texto integral em tradução identificada. Immanuel Kant, Fundamentação da Metafísica dos Costumes (1785); tradução inglesa de Thomas Kingsmill Abbott, Fundamental Principles of the Metaphysic of Morals, lida no texto integral no Project Gutenberg (eBook 5682). Kant não propõe um formulário; o Traço toma dele o teste e a distinção entre prudente e certo.",
    "funcao": "lente",
    "adaptacao": "O imperativo categórico vira seis campos. O que o Traço acrescenta é a ordem — escrever a regra ANTES de julgá-la, porque a regra escrita como desculpa (\"só desta vez\") já é a resposta — e o campo final, que é a distinção que Kant faz e o resto do catálogo não faz: isto é prudente, ou é certo?",
    "evidencia": "É filosofia de 1785, uma lente: não há estudo, não há medida, e não pode haver. E a objeção contra o teste tem a mesma idade que ele — desde Constant, discute-se que a universalização produz resultados absurdos em casos-limite (o clássico é mentir ao assassino que pergunta onde está a vítima). O Traço usa o teste como PERGUNTA que obriga a escrever a regra, não como máquina de decidir; quem espera dele uma resposta automática vai se decepcionar, e é isso mesmo.",
    "aplicabilidade": "Serve para um ato que o autor já sabe fazer e ainda não sabe se deve. Não serve para escolher entre caminhos — isso é a Decisão — nem para o que já foi feito, que é a Reparação."
  },
  "filtro": "A regra",
  "reconhecimento": "isto é um ato que ainda não passou pela pergunta do certo.",
  "movimento": "O imperativo categórico (Kant, 1785): \"aja só segundo aquela máxima pela qual você possa ao mesmo tempo querer que ela se torne lei universal\". Escrever a REGRA que o ato faz — como lei, não como desculpa — e virá-la geral, inclusive contra você. O teste não é gostar do resultado: é se a regra SOBREVIVE ao virar geral ou se destrói sozinha, como a promessa falsa, que acaba com as promessas. E cobre a distinção que o resto do catálogo não faz: isto é prudente, ou é certo?",
  "pergunta": "Se valesse para todos, inclusive contra você, a regra ainda funciona?",
  "roteamento": [
    "\\bs[óo] (desta|dessa) vez\\b|\\btodo mundo faz\\b|\\bningu[ée]m vai (saber|notar|ver)\\b|\\bn[ãa]o faz mal a ningu[ée]m\\b",
    "\\be se (todos|todo mundo) fizesse\\b|\\bimperativo categ[óo]rico\\b|\\bque regra eu estou (fazendo|criando)\\b",
    "\\bposso fazer isso\\b|\\bseria errado\\b|\\b(é|e) errado (fazer )?isso\\b|\\bisso (é|e) [ée]tico\\b"
  ],
  "campos": [
    {
      "id": "ato",
      "rotulo": "O que eu vou fazer"
    },
    {
      "id": "regra",
      "rotulo": "A regra que eu estaria fazendo (escreva como lei, não como desculpa)"
    },
    {
      "id": "todos",
      "rotulo": "Se valesse para todos, inclusive contra mim: o que acontece"
    },
    {
      "id": "sobrevive",
      "rotulo": "A regra sobrevive, ou se destrói ao virar geral?"
    },
    {
      "id": "prudente",
      "rotulo": "Isto é prudente, é certo, ou só prudente?"
    },
    {
      "id": "faco",
      "rotulo": "O que eu faço com isso"
    }
  ],
  "recordar": {
    "alvo": [
      "regra",
      "sobrevive"
    ],
    "pista": [
      "ato"
    ],
    "pergunta": "Qual era a regra que aquilo fazia — e ela sobrevivia?",
    "instrucao": "O ato fica. A regra some.",
    "rotuloAlvo": "A REGRA"
  },
  "encadeamentos": [
    {
      "rotulo": "Decidir com este critério",
      "para": "decisao",
      "mapa": {
        "escolha": "ato",
        "criterio": "sobrevive"
      },
      "exige": [
        "sobrevive"
      ]
    },
    {
      "rotulo": "Quem paga o que não se vê",
      "para": "vistoNaoVisto",
      "mapa": {
        "ato": "ato"
      },
      "exige": [
        "ato"
      ]
    }
  ],
  "definicao": "um ato que ainda não passou pela pergunta do certo (\"só desta vez\", \"ninguém vai saber\", \"e se todos fizessem\")"
}
```

### 8. A reparação — `reparacao`

- **rodada** M7 · **faculdade** reparação · **função** pratica · **GRAU A: obra publicada, lida no texto integral em tradução identificada — NÃO li o hebraico, e isto está dito**
- **o que faz:** isto é um dano feito a alguém, esperando reparo.
- **encadeia para:** `seEntao`  · todos já estarão no catálogo depois da leva 1
- **frases de teste** (têm de rotear para `reparacao` no app):
  - «magoei o cliente com aquela resposta»
  - «foi culpa minha e deixei ele na mão»

```json
{
  "id": "reparacao",
  "nome": "A reparação",
  "origem": "Maimônides, Mishneh Torá (c. 1180)",
  "faculdade": "reparação",
  "proveniencia": {
    "fonte": "GRAU A: obra publicada, lida no texto integral em tradução identificada — NÃO li o hebraico, e isto está dito. Maimônides (Moshe ben Maimon), Mishneh Torá, Hilchot Teshuvá, capítulo 2, seções 1, 2 e 9 (c. 1180); tradução inglesa de Eliyahu Touger (Moznaim), lida no texto integral no Sefaria.",
    "funcao": "pratica",
    "adaptacao": "Maimônides escreve um código religioso sobre pecado e perdão. O Traço toma duas coisas e deixa a teologia de fora: a ORDEM da reparação entre pessoas — devolver o que se deve, depois pedir, e pedir de novo — e o critério operacional de que acabou, que não é sentimento e sim a mesma situação com a mesma oportunidade sem repetir.",
    "evidencia": "É código legal do século XII, não estudo: não há medida de nada, e as afirmações de Maimônides sobre perdão divino não são avaliáveis aqui e não entram na ficha. O que o Traço usa é o critério e a ordem, que são verificáveis pelo próprio autor. Não há evidência de que escrever isto repare relação alguma; quem repara é o que se faz depois de escrever.",
    "aplicabilidade": "Serve para um dano concreto feito a uma pessoa concreta. Não serve para culpa difusa nem para desabafo — desabafo é a Expressiva, e ela não é comentada."
  },
  "filtro": "Reparação",
  "reconhecimento": "isto é um dano feito a alguém, esperando reparo.",
  "movimento": "Teshuvá (Maimônides, Hilchot Teshuvá 2). Dano a outra pessoa não se resolve por dentro: \"mesmo que devolva o dinheiro que deve, tem de apaziguá-lo e pedir que o perdoe\". Primeiro o que ela perdeu — não como você se sente —, depois o que dá para devolver, depois o que você vai dizer e quando. E o critério de que acabou é o mais duro: a mesma situação, com a mesma oportunidade, e você não repete. Sentir-se mal não é reparação; é o começo dela.",
  "pergunta": "O que ELA perdeu — não como você se sente?",
  "roteamento": [
    "\\bmagoei\\b|\\bmachuquei\\b|\\bprejudiquei\\b|\\bfiz mal (a|ao|à|para)\\b",
    "\\bpreciso pedir desculpa\\b|\\bdevo (desculpas|uma desculpa)\\b|\\bpedir perd[ãa]o\\b|\\bcomo (eu )?reparo\\b",
    "\\bfoi culpa minha\\b|\\bdeixei (ele|ela|eles) na m[ãa]o\\b|\\bquebrei a confian[çc]a\\b"
  ],
  "campos": [
    {
      "id": "quem",
      "rotulo": "Quem foi atingido"
    },
    {
      "id": "perdeu",
      "rotulo": "O que ELA perdeu (não como eu me sinto)"
    },
    {
      "id": "devolvo",
      "rotulo": "O que dá para devolver, concretamente"
    },
    {
      "id": "digo",
      "rotulo": "O que eu vou dizer a ela, e quando"
    },
    {
      "id": "teste",
      "rotulo": "A situação que vai testar: a mesma chance, e eu não repito"
    },
    {
      "id": "foi",
      "rotulo": "Depois: o que aconteceu quando eu disse",
      "soDepois": true
    }
  ],
  "recordar": {
    "alvo": [
      "teste"
    ],
    "pista": [
      "quem",
      "perdeu"
    ],
    "pergunta": "Qual era a situação que ia testar isso?",
    "instrucao": "Quem e o quê ficam. O teste some.",
    "rotuloAlvo": "A SITUAÇÃO DE TESTE"
  },
  "encadeamentos": [
    {
      "rotulo": "Vigiar a situação de teste (Se–então)",
      "para": "seEntao",
      "mapa": {
        "se": "teste"
      },
      "exige": [
        "teste"
      ]
    },
    {
      "rotulo": "Falar com ela em 3 dias",
      "compromisso": {
        "titulo": "falar com ",
        "campo": "quem",
        "dias": 3
      },
      "exige": [
        "digo"
      ]
    }
  ],
  "definicao": "um dano concreto feito a uma pessoa concreta, com o que devolver, o que dizer e a situação que testa"
}
```

---

## Encadeamentos: o que fica vivo, o que ainda espera

**Vivos assim que a leva 2 entrar** (destino já no catálogo depois da leva 1):

| de | para | leva |
|---|---|---|
| `ordemDeGrandeza` | `classeDeReferencia` | 1 |
| `comecariaHoje` | `subtracao` | 1 |
| `combinado` | `colunaEsquerda` | 1 |
| `regraQueEuFaco` | `vistoNaoVisto` | 1 |
| `fatoContrario` | `atualizacao`, `argumento` | catálogo original |
| `pontoQueDecide` | `steelman`, `atualizacao` | catálogo original |
| `oQueSeRepetiu` | `seEntao` | catálogo original |
| `reparacao` | `seEntao` | catálogo original |

**Ainda esperando destino — NÃO colar agora.** São encadeamentos de métodos da
leva 1 apontando para métodos da leva 2. Só podem entrar **depois** que a leva 2
estiver dentro, e são uma linha cada no array `encadeamentos` do método de
origem. A lista completa está em `encadeamentos.md`, na seção "Segunda passada":

| de (já colado) | para (leva 2) | o que leva |
|---|---|---|
| Coluna da esquerda | `exameDaNoite` | já colado na leva 1 — este par já está vivo |
| Classe de referência | `ordemDeGrandeza` | `estimo`→`quantidade` |
| Subtração | `comecariaHoje` | `melhorar`→`oQue` |
| O que se vê e o que não se vê | `comecariaHoje` | `ato`→`oQue` |
| Coluna da esquerda | `combinado` | `comQuem`→`quem` |

Isso é uma volta de edição posterior, com o mesmo cuidado de sempre. Não é
requisito da leva 2.

## O que provar antes de mesclar

O mesmo de qualquer leva (`achados-catalogo.md`, I.5), sem atalho:

1. Suíte integral verde no simulador de teste, via `com-trava.sh`. **Nenhuma
   volta de pesquisa rodou suíte** — o G1 é da colagem.
2. `todaRegexDoCatalogoCompila` passando.
3. As 16 frases de teste acima roteando para o método certo **no app**.
4. A frase de desabafo de `achados-catalogo.md` I.2 continuando a cair na
   Expressiva.
5. Nenhum botão morto na linha "DEPOIS DISTO".
6. Os oito aparecendo no Perfil com a proveniência (fonte, função, adaptação,
   evidência, aplicabilidade) — inclusive o **GRAU**, que agora abre o campo
   `fonte` e é a primeira coisa que o autor lê.

O que a trilha já provou, no script da M7 (cenário com os 36 métodos): 0 falso
positivo, 0 colisão de ordem, 0 botão morto, 0 erro de esquema, 0 regex que não
compila. Os 5 desvios que aparecem são herdados e estão documentados na Parte II
do `achados-catalogo.md`.

## Correções de frase que viajam junto

Três da M6 (Decisão, Primeiros princípios, Inversão — proveniência inflada) já
foram para a M3. **A M8 achou mais seis**, no outro eixo — alegação de eficácia —
e elas estão prontas, com a frase de hoje e a frase corrigida, em
[`auditoria-eficacia.md`](auditoria-eficacia.md). Quatro são dos 21 e duas eram
minhas, já corrigidas nos JSON acima.

Se a leva 2 for colada por quem também pode editar os 21, colar as seis junto
economiza uma volta. Se não, elas ficam onde estão, prontas.

---
---

# Depois da linha de corte: o que a leva 2 pede do app

**Nada disto é pré-requisito da colagem.** Os oito métodos funcionam no app de
hoje, achatados onde precisam ser. Esta parte é para o dono abrir volta, não para
quem cola.

- **Campo repetível** — `ordemDeGrandeza` quer uma linha por fator com o palpite
  de cada um. É o quarto método a pedir: Divergência (já no catálogo), Cinco
  porquês e Classe de referência (leva 1) e este. Hoje vai como um campo de
  texto, "um por linha".
- **Compromisso com dois campos** — `combinado` leva para a agenda só a frase do
  pedido; queria levar também a condição de pronto, para a cobrança ser
  utilizável sem abrir a nota. `reparacao` tem o mesmo caso (o nome da pessoa e o
  que vai ser dito). Uma chave a mais no `Compromisso`.
- **Compromisso recorrente** — não é da leva 2 (é da Pergunta de Hamming e do
  Exame da noite, leva 1), mas continua aberto.
- **A leitura do corpus** — `oQueSeRepetiu` é o argumento mais forte que a trilha
  produziu para o pedido III.4 do `achados-catalogo.md`: a contagem que ele pede
  é de memória, sujeita ao mesmo viés que o método quer corrigir. Com o corpus
  listando, por forma e por período, as notas com campo de volta preenchido, a
  contagem vira fato. **Três métodos pedem essa mesma leitura** — Classe de
  referência para prever, este para contar, e a revisão anual (rejeitada como
  método exatamente por isso) para julgar o passado.
- **Captura direta para uma forma** — `fatoContrario` tem o valor inteiro na
  velocidade: o fato contrário some em minutos, e é literalmente o que Darwin
  diz. Um destino de captura que já abra nesta forma seria a versão fiel.

A lista completa, com custo estimado e ordem recomendada, está na Parte III de
[`achados-catalogo.md`](achados-catalogo.md).
