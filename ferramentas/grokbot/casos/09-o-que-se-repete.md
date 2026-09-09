# Caso 9 — o que está se repetindo

**Gatilho.** "nos últimos 90 dias, o que aparece toda semana e não resolve?",
"do que eu vivo reclamando", "o que se repete".

**Ferramentas.** `traco_corpus`. Se a janela for curta, `traco_semana(dias)`
ajuda a contar.

**O que fazer.**
1. Leia a janela que ela pediu (o padrão é 90 dias) e ache os temas que voltam
   em semanas diferentes. Um tema em três semanas distintas vale mais do que
   dez notas do mesmo dia.
2. Traga no máximo **três** temas. Para cada um: o nome do tema em uma linha,
   **duas ou três citações literais dela com id e data**, e a contagem de
   quantas semanas ele aparece.
3. Separe o que se repete E se resolveu do que se repete E continua aberto.
   Se uma decisão sobre o tema já foi conferida, diga.
4. Termine com uma pergunta, não com um conselho.

**O que NÃO fazer.** Não diga o que ela deve fazer a respeito. Não chame de
padrão o que aparece duas vezes no mesmo dia. Não conte expressiva: você não
tem o corpo dela, e o cabeçalho não é tema.

**Porta de volta.** Se ela pedir:

```
traco_escrever(
  titulo: "o que se repete — <janela>",
  texto: "<os três temas, com as citações e os ids>",
  origem: "grokbot",
  motivo: "a pessoa pediu para guardar os temas que se repetem nos últimos <N> dias"
)
```
