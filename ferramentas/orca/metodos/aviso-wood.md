# A proveniência do `avisoWood`

Trilha Métodos · volta M5 · 06/09/2026 · **ficha para a volta de app**, não é
método do catálogo.

O Traço interrompe o autor cinco vezes, por cinco avisos. Um deles cita um
estudo no nome da constante e não diz isso a ninguém. Esta ficha dá a esse aviso
a mesma proveniência que a volta 16 deu aos métodos — e propõe o texto exato.

**Nada de Swift foi tocado.** O que está aqui é texto e fonte; a mudança no app
é volta do dono.

## O que existe hoje

Em `Traco/Analise/AnaliseLocal.swift`:

```swift
nonisolated static let avisoWood = "Afirmação sem prova não gruda. O que aconteceu que fez você escrever isso?"
```

Dispara em duas rotas:

1. localmente, pela regex `eu sou (rico|um vencedor|incrível|o melhor|imparável)`;
2. pelo rótulo `"afirmacaoVazia"` vindo da análise, no dicionário `avisos` — que
   é, como diz o comentário no código, "a ÚNICA porta entre um rótulo da IA e uma
   frase na tela".

Aparece como cartão de Aviso (`CartaoAnaliseView`, trilho vermelho, chip
"Aviso"), em texto único que quebra em quantas linhas precisar.

## A fonte

Joanne V. Wood, W. Q. Elaine Perunovic e John W. Lee, **"Positive
self-statements: power for some, peril for others"**, *Psychological Science*
20(7), 2009, p. 860–866 (doi:10.1111/j.1467-9280.2009.02370.x). Resumo lido na
íntegra no Europe PMC:

> "Positive self-statements are widely believed to boost mood and self-esteem,
> yet their effectiveness has not been demonstrated. We examined the contrary
> prediction that positive self-statements can be ineffective or even harmful. A
> survey study confirmed that people often use positive self-statements and
> believe them to be effective. Two experiments showed that among participants
> with low self-esteem, those who repeated a positive self-statement ('I'm a
> lovable person') or who focused on how that statement was true felt worse than
> those who did not repeat the statement or who focused on how it was both true
> and not true. Among participants with high self-esteem, those who repeated the
> statement or focused on how it was true felt better than those who did not, but
> to a limited degree. Repeating positive self-statements may benefit certain
> people, but backfire for the very people who 'need' them the most."

## O que o estudo afirma, e o que NÃO afirma

**Afirma:** que as pessoas usam afirmações positivas e acreditam que funcionam;
que, em dois experimentos, quem tinha autoestima baixa e repetiu a frase se
sentiu PIOR; que quem tinha autoestima alta se sentiu melhor, "mas em grau
limitado"; e que o efeito tende a ser contrário justamente em quem mais procura
a técnica.

**Não afirma:**

- que afirmação positiva "não gruda" — a frase do aviso de hoje. O estudo não
  mede fixação nem memória; mede **humor e autoavaliação logo depois**;
- que escrever seja o mesmo que repetir. O experimento pede repetição de uma
  frase dada ("I'm a lovable person"), não a escrita de uma frase própria num
  caderno;
- que exista dano duradouro. As medidas são imediatas;
- nada sobre este autor. São médias de grupos de estudantes universitários; o
  app não sabe, e não pode saber, em qual grupo o autor está.

**Consequência direta:** o texto atual está **sem origem e um passo além do que
a fonte sustenta.** "Não gruda" é uma sentença do app sobre o mundo; o estudo
não a autoriza.

## O que o aviso deveria dizer

A fronteira: **forma, informação e pergunta — nunca a resposta do autor.** O
aviso não julga a frase, não diagnostica quem escreveu e não manda apagar. Ele
entrega o que se sabe e devolve a caneta.

### Texto proposto (recomendado)

> **Um estudo de 2009 mediu isto: repetir uma frase dessas fez quem estava com a
> autoestima baixa se sentir pior, e quem estava com ela alta, um pouco melhor.
> O que aconteceu que fez você escrever isso?**

Por que assim:

- **informação, não sentença** — "um estudo mediu isto", com o resultado nos dois
  sentidos, inclusive o favorável. O autor decide;
- **não diagnostica** — não diz em qual grupo o autor está, porque o app não
  sabe. Diz o que aconteceu com dois grupos e para;
- **a pergunta continua a mesma**, palavra por palavra. Ela é a melhor parte do
  aviso de hoje: pede o FATO, que é o que o Traço sempre pede, e é o caminho
  para a Nota permanente com fonte ou para o Argumento com evidência;
- **não proíbe nada.** O autor pode manter a frase; o aviso não bloqueia a
  escrita, e nunca deve.

### Variante curta, se o cartão ficar longo demais na tela

> **Repetir uma frase dessas ajudou quem já estava bem e piorou quem não estava
> (estudo de 2009). O que aconteceu que fez você escrever isso?**

### A linha "de onde vem", no padrão da volta 16

A volta 16 ensinou o app a mostrar FONTE, FUNÇÃO, O QUE O TRAÇO ADAPTOU,
EVIDÊNCIA e SERVE PARA nos métodos. Um aviso que interrompe merece pelo menos as
duas primeiras, atrás de um toque, com este conteúdo:

- **FONTE** — Wood, Perunovic e Lee, "Positive self-statements: power for some,
  peril for others", *Psychological Science*, 2009.
- **EVIDÊNCIA** — Dois experimentos com estudantes, medindo humor logo depois de
  repetir uma frase dada. Quem tinha autoestima baixa se sentiu pior; quem tinha
  alta, um pouco melhor. Não mede escrever a própria frase, não mede efeito
  duradouro, e não diz nada sobre você.

Isso é trabalho de app (não existe superfície de proveniência no cartão de
Aviso hoje) e fica para a volta do dono. **Enquanto ela não vem, trocar só a
frase já corrige o que está errado: a sentença sem origem.**

## O que NÃO fazer, e é o mais importante

1. **Não dizer ao autor como ele está.** "Se você está se sentindo mal, isto vai
   piorar" transforma o app em diagnóstico. O estudo mede grupos; o Traço não
   mede ninguém.
2. **Não bloquear.** O aviso é cartão, não porta. A escrita continua.
3. **Não moralizar.** Nada de "pare de se enganar" — nem no tom, nem por
   implicação. O tom do catálogo é seco: informa e pergunta.
4. **Não citar a ciência como veredito.** "Comprovado que não funciona" seria o
   mesmo erro de "não gruda", com jaleco. São dois experimentos, e a ficha diz
   quantos.

## Observação sobre o gatilho, para a mesma volta

A regex local é estreita: `eu sou (rico|um vencedor|incrível|o melhor|imparável)`.
Ela não pega "eu sou capaz de qualquer coisa", "eu consigo tudo", "sou
imbatível", "eu mereço isso" — e a rota da IA (`afirmacaoVazia`) cobre o resto de
forma imprevisível.

**Recomendação: mexer no gatilho DEPOIS do texto, e com parcimônia.** Um aviso
que dispara errado é pior que um aviso que não dispara: ele interrompe o autor no
meio de uma frase legítima. Se for mexer, o teste é o mesmo das regex do
catálogo — frases reais do autor, e nenhum falso positivo.

## Onde isto entrou na trilha

O aviso apareceu quando eu rejeitei o candidato **Afirmações positivas** na volta
M4 (barra 4: a identidade do método é uma alegação de eficácia que a evidência
contradiz). Achei então que o app já tinha a defesa em código — sem dizer de
onde ela vinha. Ver `rejeitado-afirmacoesPositivas.md`.
