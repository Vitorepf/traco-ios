# Afirmações positivas — **REJEITADO**

Volta M4 da trilha Métodos · 06/09/2026.

Candidato: escrever e repetir uma afirmação positiva sobre si mesmo ("eu sou
capaz", "eu vou conseguir"). É o método mais popular do mundo e o único desta
trilha contra o qual **o app já tem uma defesa escrita em código**. Esta ficha
existe para documentar por que essa defesa está lá.

## A fonte, e o que ela mostra

Joanne V. Wood, W. Q. Elaine Perunovic e John W. Lee, **"Positive
self-statements: power for some, peril for others"**, *Psychological Science*
20(7), 2009, p. 860–866 (doi:10.1111/j.1467-9280.2009.02370.x). Resumo lido na
íntegra no Europe PMC:

> "Positive self-statements are widely believed to boost mood and self-esteem,
> yet their effectiveness has not been demonstrated. We examined the contrary
> prediction that positive self-statements can be ineffective or even harmful."

> "Two experiments showed that among participants with low self-esteem, those
> who repeated a positive self-statement ('I'm a lovable person') or who focused
> on how that statement was true felt worse than those who did not repeat the
> statement […] Repeating positive self-statements may benefit certain people,
> but backfire for the very people who 'need' them the most."

## Onde ele cai

**Barra 4 — não dá para escrever com honestidade e continuar sendo o método.**

As outras rejeições desta trilha caíram na barra 3, por duplicarem um movimento.
Esta é diferente: o movimento é próprio, ninguém no catálogo o faz. Ele cai
porque **a identidade do método é uma alegação de eficácia** — repita e você se
sentirá melhor — e a evidência disponível diz o contrário justamente para quem
mais o procuraria. Escrever a proveniência honesta ("a repetição pode piorar o
estado de quem tem autoestima baixa") esvazia o método: não sobra nada para
fazer.

Um método do catálogo pode ter evidência fraca, ou nenhuma — metade dos 21 tem
"sem evidência específica conhecida" e isso é aceitável, porque a ficha diz.
O que não é aceitável é um método cuja única razão de existir é um efeito que a
melhor evidência disponível contradiz.

## O app já sabia disso

`Traco/Analise/AnaliseLocal.swift` tem uma constante chamada **`avisoWood`**:

```
nonisolated static let avisoWood = "Afirmação sem prova não gruda. O que aconteceu que fez você escrever isso?"
```

e ela dispara na regex `eu sou (rico|um vencedor|incrível|o melhor|imparável)`.
Ou seja: quando o autor escreve uma afirmação positiva, o Traço não abre forma
nenhuma — **devolve uma pergunta pedindo o fato**. O nome da constante aponta
para o mesmo estudo desta ficha.

Aceitar este candidato seria colocar no catálogo um método que o próprio motor
do app interrompe. A rejeição não é só coerente com a evidência: é coerente com
o produto.

## O que fica aproveitado

Duas coisas, e valem mais que o candidato:

1. **Uma linha de proveniência para o `avisoWood`.** O aviso hoje aparece sem
   origem. Com a volta 16, o Traço passou a saber mostrar de onde vem cada
   coisa; um aviso que interrompe o autor merece o mesmo — "Wood, Perunovic e
   Lee, 2009". Sugestão para a volta de colagem ou para uma volta de app.
2. O movimento que sobra, quando se tira a alegação, já existe: o Traço pede o
   **fato** que sustenta a frase. Isso é a Nota permanente com fonte, ou o
   Argumento com evidência. Nada a criar.

## Evidência da rejeição

- Wood, Perunovic e Lee (2009), resumo citado acima, com DOI.
- `Traco/Analise/AnaliseLocal.swift`: `avisoWood` e a regex que o dispara.
