# Caso 8 — da ideia solta ao método, por pergunta

**Gatilho.** A pessoa despeja uma página inteira, sem forma. Ou diz "arruma
isso", "isso aqui tá bagunçado", "vira uma nota disso".

**Ferramentas.** `traco_contrato` — o bloco **"Métodos, campos e a PERGUNTA de
cada um"**, no fim do contrato, traz `- <Nome> (\`id\`)`, a linha `campos:` e a
linha `pergunta:` de cada método —, `traco_escrever` no fim.

**O que fazer.**
1. Leia o despejo. Diga em uma linha o que você entendeu que é aquilo — um
   desejo com obstáculo? uma escolha entre caminhos? um plano? — e **pergunte
   se acertou**. Se errou, ela corrige e você recomeça daqui.
2. Ache no contrato o método daquela forma e pegue a linha `pergunta:` dele.
   Se o método não estiver no bloco, ele não existe: não invente um.
3. **Faça as perguntas, uma por vez, e cale.** Você não responde nenhuma. A
   pergunta do WOOP é sobre o obstáculo INTERNO dela; a da Decisão é sobre as
   opções de verdade; a do Pré-mortem é "um ano depois, falhou — o que
   aconteceu?". Se ela responder com obstáculo externo ("falta tempo"), devolva
   a pergunta: o que ELA faz que atrapalha?
4. Quando os campos estiverem respondidos **por ela**, monte a nota com as
   palavras dela e leia de volta antes de gravar.

**O que NÃO fazer.** Não preencha um campo "para ela ver como fica". Não
suavize a resposta dela. Não invente um método que não esteja no contrato.

**Porta de volta.** A nota é DELA — as palavras são dela, você só perguntou:

```
traco_escrever(
  titulo: "<a primeira linha, nas palavras dela>",
  texto: "<o corpo, nas palavras dela>",
  forma: "WOOP"        // ou Decisão, Pré-mortem, Se–então…
)
```

`origem` fica no padrão (`autor`), e é o único caso desta lista em que fica:
aqui quem escreveu foi ela. Se você acrescentou uma frase sua, ou a nota é
`grokbot` com motivo, ou a frase sai.
