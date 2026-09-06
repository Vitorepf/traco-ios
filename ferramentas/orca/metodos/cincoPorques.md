# Cinco porquês — ficha do candidato

Volta M1 da trilha Métodos · 06/09/2026 · **proposto com uma pendência de
citação** (explicada abaixo). Não colado.

Faculdade: **causa** (hoje vazia; o catálogo tem três métodos para o que ainda
vai acontecer — Pré-mortem, Inversão, Especificação — e nenhum para o que já
aconteceu e se repete).
Ciclo: **MULTIPLICAR agora** — o que se repete come a semana toda; matar a
causa devolve o tempo. E MELHORAR, porque descer a cadeia é uma capacidade.

## Fonte

Taiichi Ohno, *Toyota Production System: Beyond Large-Scale Production*,
Productivity Press, 1988 (original japonês, 1978). ISBN 0-915299-14-3.

Citação, tal como reproduzida na enciclopédia que a atribui a essa edição:

> "the basis of Toyota's scientific approach […] by repeating why five times
> the nature of the problem as well as its solution becomes clear."

**Pendência, e é honesto dizer:** não abri o livro. Autor, obra, editora, ano e
ISBN estão conferidos; a frase exata é de segunda mão. Antes de colar no
catálogo, conferir a citação na página (edição inglesa, capítulo 1) — ou trocar
a citação por uma que eu tenha lido inteira. A barra 2 pede a citação que
sustenta, e esta ainda está a um passo da fonte.

A crítica publicada, essa sim lida na fonte primária:

Alan J. Card, **"The problem with '5 whys'"**, *BMJ Quality & Safety* 26(8),
p. 671–677, 2017 (doi:10.1136/bmjqs-2016-005849 — metadados conferidos no
Crossref). Card argumenta que a profundidade do quinto porquê é arbitrária e
que investigadores diferentes chegam a causas diferentes a partir do mesmo
evento. Teruyuki Minoura, ex-diretor da Toyota, chama a ferramenta de básica
demais para achar a causa raiz.

## O que a fonte afirma, e o que não afirma

**Afirma:** que repetir o porquê é a base do método de análise da Toyota, e que
a causa costuma estar escondida atrás de sintomas mais visíveis. É relato de
prática industrial, de quem construiu o sistema.

**Não afirma:** que cinco seja o número certo, nem que o resultado seja
reprodutível. A crítica publicada diz o contrário nas duas coisas. Não há
estudo de eficácia; não há nada sobre uma pessoa aplicando isto às próprias
notas. A ficha não alega eficácia nenhuma.

## Por que passa nas quatro barras

1. **Ciclo** — os dois, dito acima.
2. **Origem verificável** — obra, autor, ano, editora e ISBN conferidos; a
   citação literal está pendente de leitura na fonte (ver acima). A crítica que
   a ficha usa para adaptar o método está conferida no Crossref.
3. **Não duplica** — o **Pré-mortem** imagina uma falha que ainda não houve; a
   **Inversão** pergunta como garantir que falhe; a **Decisão** confere o que
   se esperava. Nenhum dos três desce a cadeia causal de um evento que JÁ
   aconteceu e se repete. O movimento é outro: não é imaginar, é descer.
4. **Honestidade sobre evidência** — a ficha traz a crítica publicada junto com
   a fonte, e a adaptação existe por causa dela.

## A adaptação, que responde à crítica

O Traço não copia os cinco porquês crus. Acrescenta dois campos que a crítica
de Card pede:

- **a causa só vale se for algo que o autor CONTROLA** — causa que é uma pessoa
  não é causa, é queixa;
- **uma segunda cadeia possível, que ele não seguiu** — porque a primeira
  cadeia que se acha é a que se estava procurando.

O movimento também diz, com todas as letras, que o quinto porquê não é sagrado:
para quando a causa é controlável.

## O que ele desbanca ou complementa

Complementa o Pré-mortem pelo outro lado do tempo (um imagina a falha, o outro
a autopsia) e o Se–então, para onde o encadeamento manda a causa: *se* o sinal
da causa aparecer, *então* o que eu mudo.

## Caso de uso real no Traço

"Deu errado de novo, a mesma coisa da semana passada." A volta quebrou no
mesmo ponto pela terceira vez. A forma desce: porque o teste não rodou, porque
o simulador estava ocupado, porque duas frentes usam o mesmo, porque não há
trava — e aí para: a causa é uma que ele controla. O campo da outra cadeia
guarda a que ele não seguiu.

## O que a forma pede e o app ainda não faz

A anatomia verdadeira é uma **cadeia de profundidade variável**: um porquê que
se repete até a causa ser controlável, não uma lista de cinco caixas. O
`CampoForma` de hoje é uma lista fixa, então o JSON entrega cinco campos
numerados — quem parar no terceiro deixa dois vazios, e o app já lida bem com
campo vazio.

**Volta de laço proposta:** campo repetível (`repete`, com rótulo numerado e um
botão de "mais um"), que serviria também à Divergência (as dez opções) e à
Classe de referência (os casos parecidos). Três métodos pedindo a mesma coisa
já é sinal.

## JSON pronto para colar (versão de cinco caixas, roda hoje)

```json
{
  "id": "cincoPorques",
  "nome": "Cinco porquês",
  "origem": "Taiichi Ohno",
  "faculdade": "causa",
  "proveniencia": {
    "fonte": "Taiichi Ohno, Toyota Production System: Beyond Large-Scale Production (Productivity Press, 1988; original japonês de 1978)",
    "funcao": "pratica",
    "adaptacao": "Cinco porquês encadeados, e mais dois campos que a crítica publicada pede: a causa só vale se for algo que o AUTOR controla (não uma pessoa), e uma segunda cadeia possível que ele não seguiu. A forma verdadeira é uma cadeia que para quando a causa é controlável, não uma lista de cinco — ver a ficha.",
    "evidencia": "Ohno apresenta a repetição do porquê como base do método científico da Toyota, com o caso da máquina parada; é relato de prática, não estudo. Teruyuki Minoura, ex-diretor da Toyota, chama a ferramenta de básica demais para achar a causa raiz. Alan J. Card (BMJ Quality & Safety 26:671–677, 2017) argumenta que a profundidade do quinto porquê é arbitrária e que investigadores diferentes chegam a causas diferentes. Nada aqui mede o uso por uma pessoa nas próprias notas.",
    "aplicabilidade": "Serve para algo que já deu errado e se repete, num sistema que o autor controla. Não serve para plano futuro — isso é o Pré-mortem — nem para culpar alguém."
  },
  "filtro": "Cinco porquês",
  "reconhecimento": "isto já deu errado, e a causa ainda é a primeira que apareceu.",
  "movimento": "Cinco porquês (Ohno). Descer a cadeia de causas até uma causa que o autor CONTROLA. Duas cobranças que a crítica publicada pede: causa que é uma pessoa não é causa, é queixa; e o quinto porquê não é sagrado — se a cadeia parou antes, para; se não parou, continua. Cobre também a segunda cadeia possível: a primeira que se acha é a que se procurava.",
  "pergunta": "Por que isso aconteceu — e por que ISSO aconteceu?",
  "campos": [
    {
      "id": "aconteceu",
      "rotulo": "O que aconteceu (o fato, sem explicação)"
    },
    {
      "id": "porque1",
      "rotulo": "Por quê? (1)"
    },
    {
      "id": "porque2",
      "rotulo": "E por que isso? (2)"
    },
    {
      "id": "porque3",
      "rotulo": "E por que isso? (3)"
    },
    {
      "id": "porque4",
      "rotulo": "E por que isso? (4)"
    },
    {
      "id": "porque5",
      "rotulo": "E por que isso? (5)"
    },
    {
      "id": "controlo",
      "rotulo": "A causa que EU controlo (pessoa não é causa)"
    },
    {
      "id": "outra",
      "rotulo": "Outra cadeia possível, que eu não segui"
    },
    {
      "id": "mudo",
      "rotulo": "O que eu mudo para não repetir"
    }
  ],
  "roteamento": [
    "\\bdeu errado de novo\\b|\\baconteceu de novo\\b|\\bde novo o mesmo\\b|\\bsempre (quebra|estoura|d[áa] errado)\\b",
    "\\bpor que isso (aconteceu|deu errado|quebrou)\\b|\\bcausa raiz\\b|\\bcinco porqu[êe]s\\b|\\b5 porqu[êe]s\\b",
    "\\bqual (foi|é) a causa\\b|\\bfalhou de novo\\b"
  ],
  "recordar": {
    "alvo": [
      "controlo",
      "mudo"
    ],
    "pista": [
      "aconteceu"
    ],
    "pergunta": "Qual era a causa que você controla, e o que você mudou?",
    "instrucao": "O que aconteceu fica. A causa some.",
    "rotuloAlvo": "A CAUSA"
  },
  "encadeamentos": [
    {
      "rotulo": "Vigiar a causa (Se–então)",
      "para": "seEntao",
      "mapa": {
        "se": "controlo",
        "entao": "mudo"
      },
      "exige": [
        "mudo"
      ]
    },
    {
      "rotulo": "Conferir em 30 dias se repetiu",
      "compromisso": {
        "titulo": "repetiu? ",
        "campo": "aconteceu",
        "dias": 30
      },
      "exige": [
        "controlo"
      ]
    }
  ],
  "definicao": "algo que já deu errado e se repete, e pede a causa que o autor controla (\"por que isso aconteceu\", \"deu errado de novo\")"
}
```

## Nota de rodada — este método foi rejeitado e voltou

Sob a barra de SEIS, eu tinha este candidato marcado para **rejeição na barra
5** (o passo que as pessoas pulam): o nervo dos cinco porquês é "repita mais
quatro vezes", que é quantidade, não um movimento de outra natureza como o
obstáculo interno do WOOP. A correção do dono (06/09, 13:25) tirou essa barra.
Reavaliado nas quatro que ficaram, ele passa — e a lacuna que ele fecha
(nenhum método para o que já deu errado) é real.

Fica registrado para o dono decidir com a informação inteira: **se a barra 5
voltar, este é o primeiro a sair.**

## Colisão de roteamento achada na prova

A frase "sempre quebra no mesmo ponto, qual é a causa" **não** chega aqui: a
regex do Se–então é `sempre que|toda vez|...`, sem `\b`, e "sempre que" casa
dentro de "sempre **que**bra". É defeito antigo do catálogo, não deste
candidato — a mesma regex captura "sempre queria", "sempre quero", "sempre
quebrou". Correção sugerida para a volta de colagem: `\bsempre que\b`.
