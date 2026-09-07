# Transferência — ficha do candidato

Volta M13 da trilha Métodos · 06/09/2026 · **proposto**, não colado. Pedido do
dono (IDEIAS.md, seção C).

**GRAU A** — obra publicada em domínio público, lida no texto integral. O pedido
dizia "tradição de raciocínio por analogia; se achar fonte primária de grau A,
melhor". **Achei**, e ela é melhor do que tradição: dá ao método um campo que eu
não teria escrito sozinho.

Faculdade: **raciocínio** — rótulo existente (Argumento e Steelman moram nele).
Ciclo: **MELHORAR** — e serve direto ao que o dono quer fazer com biografias.

## Fonte

**John Stuart Mill, *A System of Logic, Ratiocinative and Inductive* (1843)**,
livro III, capítulo XX, "Of Analogy", § 3. Texto integral lido no Project
Gutenberg (eBook 27942). Domínio público.

A frase que dá as três colunas do método:

> "Since the value of an analogical argument inferring one resemblance from other
> resemblances without any antecedent evidence of a connection between them,
> depends on the extent of ascertained resemblance, compared first with the
> amount of ascertained difference, and next with the extent of the unexplored
> region of unascertained properties…"

E a competição entre elas, que é o veredito:

> "There will, therefore, be a competition between the known points of agreement
> and the known points of difference in A and B; and according as the one or the
> other may be deemed to preponderate, the probability derived from analogy will
> be for or against B's having the property m."

**A terceira quantidade é a que este método existe para cobrar.** Semelhança e
diferença qualquer um lista; *"a extensão da região inexplorada de propriedades
não apuradas"* é o que ninguém escreve — e numa biografia ela é quase tudo.

## O que a fonte afirma, e o que não afirma

**Afirma:** que a analogia dá **probabilidade**, não conclusão; que a força dela
é uma razão entre três quantidades; e que uma delas é o que não se sabe.

**Não afirma:** nada medido — é lógica indutiva de 1843, uma lente. Mill não
trata de biografia, de negócio nem de imitação; a aplicação é do Traço e está
dita. E não há evidência de que escrever as três colunas melhore transferência
alguma. O que há é mais modesto e ainda vale: quem escreveu as três não confundiu
semelhança com prova.

## Por que passa nas quatro barras

1. **Ciclo** — MELHORAR.
2. **Origem verificável — grau A**, duas citações literais do texto integral em
   domínio público.
3. **Não duplica — e a fonte é quem resolve.** A **Analogia** (Gentner) vai do
   MEU problema para outro campo, para CRIAR; tem o campo "o que não se
   transfere". Este vai do resultado de OUTRA PESSOA para mim, para TESTAR — e a
   diferença decisiva não é a direção: é que a Analogia pesa duas quantidades
   (o que traz, o que não transfere) e Mill exige **três**. A região inexplorada
   não existe em nenhum método do catálogo. A **Classe de referência** (leva 1)
   usa os casos passados do próprio autor; aqui o caso é de outro. E o
   **Sobrevivente** julga se o relato é verdadeiro, não se ele se aplica.
4. **Honestidade sobre evidência** — dita acima.

## O que ele desbanca ou complementa

É a segunda metade de um par, e o par tem ordem: **Sobrevivente primeiro**
(o relato é confiável?), **Transferência depois** (isto vale para mim?). O
encadeamento do Sobrevivente leva o que sobrou de instrução para o primeiro campo
daqui. Sozinho, ele funciona; na ordem, funciona melhor.

E encadeia para a **Atualização**: o veredito vira crença com número, e o campo
`diferente` vira "o que me faria descer".

## Caso de uso real no Traço

O dono lê que um fundador cresceu contratando devagar e escrevendo tudo. Igual
apurado: produto de software, equipe pequena, autor que escreve. Diferente
apurado: ele tinha capital para esperar; o mercado era outro; a época era outra.
**Não sei:** quantas tentativas ele já tinha feito antes dessa, se havia rede,
qual era a tolerância dele a ficar sem receita. O veredito muda quando a terceira
coluna aparece — e o campo do "o que eu apuraria" costuma responder com uma
pergunta de dez minutos.

## O que a forma pede e o app ainda não faz

Nada de estrutura. Uma observação: os três campos do meio são naturalmente
**listas** — é o sexto método a pedir o campo repetível.

## JSON pronto para colar

```json
{
  "id": "transferencia",
  "nome": "Transferência",
  "origem": "John Stuart Mill, 1843",
  "faculdade": "raciocínio",
  "proveniencia": {
    "fonte": "GRAU A: obra publicada, lida no texto integral em domínio público. John Stuart Mill, A System of Logic, Ratiocinative and Inductive (1843), livro III, capítulo XX, \"Of Analogy\", § 3; Project Gutenberg, eBook 27942.",
    "funcao": "lente",
    "adaptacao": "Mill escreve sobre a força de um argumento analógico em geral. O Traço aplica ao caso que interessa ao autor — o que funcionou para outra pessoa — e transforma as três quantidades de Mill em três campos, com o terceiro em destaque porque é o que ninguém escreve: a região inexplorada. O fecho (levo, adapto ou deixo) e o campo do que apurar são do Traço.",
    "evidencia": "É lógica indutiva de 1843, uma lente: Mill não mede nada e não trata de biografia nem de negócio. E ele é explícito sobre o limite do próprio instrumento — a analogia, sozinha, dá probabilidade, não conclusão. Não há evidência de que escrever as três colunas melhore transferência alguma; o que há é a garantia de que quem escreveu as três não confundiu semelhança com prova.",
    "aplicabilidade": "Serve quando o autor quer aplicar em si o que funcionou para outra pessoa ou em outro contexto. Não serve para criar solução nova a partir de outro campo — isso é a Analogia — nem para julgar se o relato é verdadeiro, que é o Sobrevivente."
  },
  "filtro": "Transferência",
  "reconhecimento": "isto é o que funcionou para outra pessoa, querendo virar seu.",
  "movimento": "Analogia julgada (Mill, 1843). O valor da transferência depende de três quantidades, e a terceira é a que ninguém escreve: \"a extensão da semelhança apurada, comparada primeiro com a quantidade de diferença apurada, e depois com a extensão da região inexplorada de propriedades não apuradas\". Cobre as três — o que é igual, o que é diferente, e o que você nem sabe se é igual ou diferente — e o veredito que sai delas: levo, adapto ou deixo.",
  "pergunta": "O que era verdade na situação dela que não é verdade na sua?",
  "roteamento": [
    "\\bfuncionou (para|pro|pra) (ele|ela|eles|o|a)\\b|\\bdeu certo (para|pro|pra) (ele|ela|eles)\\b|\\bno caso dele deu certo\\b",
    "\\bvou fazer igual\\b|\\bfazer o mesmo que (ele|ela|eles)\\b|\\bcopiar o que (ele|ela) fez\\b|\\baplicar o que (ele|ela) fez\\b",
    "\\bser[áa] que serve (para|pro|pra) mim\\b|\\bvale (para|pro|pra) o meu caso\\b"
  ],
  "campos": [
    {
      "id": "funcionou",
      "rotulo": "O que funcionou para ela, e em que situação"
    },
    {
      "id": "igual",
      "rotulo": "O que na situação dela é igual à minha — apurado, não suposto"
    },
    {
      "id": "diferente",
      "rotulo": "O que é diferente — apurado"
    },
    {
      "id": "naoSei",
      "rotulo": "O que eu nem sei se é igual ou diferente"
    },
    {
      "id": "pesa",
      "rotulo": "Pesando os três: eu levo, adapto ou deixo"
    },
    {
      "id": "apurar",
      "rotulo": "O que eu apuraria para encolher o \"não sei\""
    }
  ],
  "recordar": {
    "alvo": [
      "diferente",
      "naoSei"
    ],
    "pista": [
      "funcionou"
    ],
    "pergunta": "O que era diferente — e o que você nem sabia?",
    "instrucao": "O que funcionou para ela fica. As diferenças somem.",
    "rotuloAlvo": "A DIFERENÇA"
  },
  "encadeamentos": [
    {
      "rotulo": "Quanto eu acredito que transfere",
      "para": "atualizacao",
      "mapa": {
        "acredito": "pesa",
        "descer": "diferente"
      },
      "exige": [
        "pesa"
      ]
    },
    {
      "rotulo": "Apurar em 14 dias",
      "compromisso": {
        "titulo": "apurar: ",
        "campo": "apurar",
        "dias": 14
      },
      "exige": [
        "apurar"
      ]
    }
  ],
  "definicao": "o que funcionou para outra pessoa, pesado contra a situação do autor (\"funcionou para ele\", \"vou fazer igual\")"
}
```
