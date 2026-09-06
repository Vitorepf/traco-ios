# O que se vê e o que não se vê — ficha do candidato

Volta M2 da trilha Métodos · 06/09/2026 · **proposto**, não colado.

Faculdade: **consequência** (vazia).
Ciclo: **MULTIPLICAR agora** — o que se aceita sem ver o custo é o que come a
semana. E MELHORAR: enxergar o efeito que não aparece é uma capacidade que se
treina, e Bastiat diz exatamente isso.

## Fonte

Frédéric Bastiat, **"Ce qu'on voit et ce qu'on ne voit pas"** (1850). Li
integralmente a tradução inglesa de Patrick James Stirling, *That Which Is Seen,
and That Which Is Not Seen*, em *Essays on Political Economy*, transcrita no
Wikisource. Obra em domínio público.

A abertura, que é o método inteiro:

> "In the department of economy, an act, a habit, an institution, a law, gives
> birth not only to an effect but to a series of effects. Of these effects, the
> first only is immediate; it manifests itself simultaneously with its cause—
> it is seen. The others unfold in succession— they are not seen: it is well for
> us if they are foreseen."

O passo que o método existe para cobrar — o não visto é um fato NEGATIVO e por
isso não aparece sozinho:

> "It is not seen that as our shopkeeper has spent six francs upon one thing, he
> cannot spend them upon another. It is not seen that if he had not had a window
> to replace, he would, perhaps, have replaced his old shoes, or added another
> book to his library."

> "And if that which is not seen is taken into consideration, because it is a
> negative fact, as well as that which is seen, because it is a positive fact,
> it will be understood that neither industry in general, nor the sum total of
> national labour, is affected, whether windows are broken or not."

E a licença do próprio autor para usar a lente fora da economia:

> "In fact, it is the same in the science of health, arts, and in that of morals.
> It often happens, that the sweeter the first fruit of a habit is, the more
> bitter are the consequences."

## O que a fonte afirma, e o que não afirma

**Afirma:** que todo ato gera uma série de efeitos, dos quais só o primeiro se
vê; que o efeito não visto é um fato negativo — aquilo que deixou de acontecer —
e por isso precisa ser deliberadamente nomeado; e que a distinção vale também
para hábitos e para a moral, não só para economia. É um argumento, com exemplos
construídos.

**Não afirma:** nada medido. Bastiat não faz experimento, não conta ninguém, não
propõe procedimento nem alega que escrever isto melhore decisão alguma. É de
1850, e a parte econômica das conclusões é discutida até hoje — o que este
método usa é a DISTINÇÃO, não a economia de Bastiat. Não há evidência de
eficácia, e a ficha não inventa nenhuma.

## Por que passa nas quatro barras

1. **Ciclo** — os dois, dito acima.
2. **Origem verificável** — autor, obra, ano, tradutor, e quatro citações
   literais lidas no texto integral em domínio público.
3. **Não duplica** — a **Decisão** compara opções sobre a mesa e pergunta o
   custo de errar; aqui há UM ato só, muitas vezes já em curso, e o objeto é o
   que deixou de acontecer por causa dele — o que nunca vai aparecer em lugar
   nenhum para ser comparado. O **Pré-mortem** imagina a falha do plano; o não
   visto de Bastiat não é falha: o ato pode dar certo e o custo existir do mesmo
   jeito. A **Inversão** pergunta como garantir o fracasso. E não é a
   **Subtração** proposta na M1: lá se escolhe o que tirar; aqui se conta o que
   já está sendo pago sem aparecer na conta.
4. **Honestidade sobre evidência** — dito: é argumento de 1850, sem medida, e a
   ficha separa a distinção (que se usa) da economia (que não se usa).

## O que ele desbanca ou complementa

Complementa a Decisão — o encadeamento leva o não visto para o campo do
critério, que é onde ele muda a escolha. E é o contrário exato dos Cinco
porquês: um desce ao passado atrás da causa, este avança ao futuro atrás do
efeito que não vai aparecer.

## Caso de uso real no Traço

"Parece que não custa nada, é só apertar um botão." Abrir mais uma frente em
paralelo tem efeito visível (mais coisas andando) e um não visto (a atenção que
some das outras seis, o dono revisando sete relatos em vez de três). A forma
cobra o prazo em que o não visto aparece — porque ele aparece atrasado, e é por
isso que ninguém liga uma coisa à outra.

## O que a forma pede e o app ainda não faz

Nada. Cinco campos de texto no esquema da volta 16.

## JSON pronto para colar

```json
{
  "id": "vistoNaoVisto",
  "nome": "O que se vê e o que não se vê",
  "origem": "Frédéric Bastiat, 1850",
  "faculdade": "consequência",
  "proveniencia": {
    "fonte": "Frédéric Bastiat, \"Ce qu'on voit et ce qu'on ne voit pas\" (1850); tradução inglesa de Patrick James Stirling em Essays on Political Economy, lida integralmente no Wikisource",
    "funcao": "lente",
    "adaptacao": "Bastiat aplica a lente à economia política, em ensaio corrido. O Traço a reduz a um ato do autor e cobra o prazo: quando o não visto aparece. O fecho — manter ou trocar — é do Traço.",
    "evidencia": "É um argumento, não um estudo: Bastiat não mede nada e não afirma eficácia de método nenhum. O texto é de 1850 e sua parte econômica é discutida até hoje. O que se usa aqui é a distinção, não a economia. Não há evidência de que escrever isto melhore decisão.",
    "aplicabilidade": "Serve para um ato, hábito ou gasto cujo efeito visível é claro. Não serve para escolher entre opções — isso é a Decisão."
  },
  "filtro": "O que não se vê",
  "reconhecimento": "isto tem um efeito visível e um custo que não aparece.",
  "movimento": "O que se vê e o que não se vê (Bastiat, 1850). Todo ato dá origem não a um efeito, mas a uma série: o primeiro se vê, os outros não. Escrever os dois — o efeito imediato e o que DEIXA de acontecer porque este ato aconteceu. O que não se vê é um fato negativo: não aparece sozinho, tem de ser nomeado. Cobre o prazo em que ele aparece.",
  "pergunta": "O que deixa de acontecer porque isto aconteceu?",
  "roteamento": [
    "\\bcusto de oportunidade\\b|\\bo que eu deixo de (fazer|ganhar|ter)\\b|\\bdeixo de fazer\\b",
    "\\bcompensa mesmo\\b|\\bsai mais barato\\b|\\bt[áa] de gra[çc]a\\b|\\bnão custa nada\\b",
    "\\bem troca de quê\\b|\\bo que isso me custa\\b|\\bo pre[çc]o disso\\b"
  ],
  "campos": [
    {
      "id": "ato",
      "rotulo": "O ato, o hábito ou o gasto"
    },
    {
      "id": "vejo",
      "rotulo": "O que se vê (o efeito imediato)"
    },
    {
      "id": "naoVejo",
      "rotulo": "O que NÃO se vê (o que deixa de acontecer)"
    },
    {
      "id": "quando",
      "rotulo": "Quando o não visto aparece"
    },
    {
      "id": "troco",
      "rotulo": "Sabendo dos dois: mantenho ou troco"
    }
  ],
  "recordar": {
    "alvo": [
      "naoVejo"
    ],
    "pista": [
      "ato",
      "vejo"
    ],
    "pergunta": "O que deixava de acontecer por causa disto?",
    "instrucao": "O que se vê fica. O que não se vê some.",
    "rotuloAlvo": "O NÃO VISTO"
  },
  "encadeamentos": [
    {
      "rotulo": "Decidir sobre isto",
      "para": "decisao",
      "mapa": {
        "escolha": "ato",
        "criterio": "naoVejo"
      },
      "exige": [
        "naoVejo"
      ]
    },
    {
      "rotulo": "Ver o não visto em 30 dias",
      "compromisso": {
        "titulo": "apareceu o não visto? ",
        "campo": "naoVejo",
        "dias": 30
      },
      "exige": [
        "quando"
      ]
    }
  ],
  "definicao": "um ato cujo efeito visível é claro e cujo custo não aparece (\"custo de oportunidade\", \"o que eu deixo de fazer\")"
}
```
