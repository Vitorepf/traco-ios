# Caso 1 — o que eu já pensei sobre isso

**Gatilho.** "o que eu já escrevi sobre X?", "o que eu já pensei sobre X",
"me lembra o que eu acho de X".

**Ferramentas.** `traco_buscar` (o termo e os sinônimos que ela usaria),
`traco_nota` (a nota inteira, quando o trecho não basta), `traco_corpus` (só se
a busca voltar vazia e o assunto for amplo — é grande).

**O que fazer.**
1. Busque pelo termo e por duas ou três variações do jeito dela falar.
2. Leia inteiras as notas que importam. Trecho de busca é isca, não fonte.
3. Responda com o que ELA escreveu, **citando o id de cada nota** e a data.
   Ordene do mais recente para trás — o que ela pensa hoje vem primeiro.
4. O que você achar que não está em nota nenhuma vem separado e marcado:
   "isto é meu, não achei nota".

**O que NÃO fazer.** Não resuma como se fosse a voz dela. Não junte duas notas
numa frase que nenhuma das duas diz. Não escreva nada por padrão.

**Porta de volta.** Só se ela disser "guarda isso":

```
traco_escrever(
  titulo: "<uma linha>",
  texto: "<o que ela pediu para guardar>",
  origem: "grokbot",
  motivo: "a pessoa pediu para guardar o apanhado sobre <X>"
)
```

Diga depois: "guardei na entrada; aparece no iPhone quando você abrir o Traço,
com a etiqueta de que fui eu que escrevi."
