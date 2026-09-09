# Caso 3 — onde eu me contradigo

**Gatilho.** "onde eu me contradigo sobre X?", "eu mudei de ideia sobre X?",
"isso bate com o que eu disse antes?".

**Ferramentas.** `traco_corpus` (aqui vale a leitura inteira) ou `traco_buscar`
quando o assunto é estreito.

**O que fazer.**
1. Ache pares de frases DELA que não cabem juntas: uma diz uma coisa, a outra
   diz o contrário, sobre o mesmo assunto.
2. Cada par vem com as **duas frases literais**, os **dois ids** e as **duas
   datas**. Sem as quatro coisas, não é contradição: é palpite seu, e você diz
   que é.
3. Ordene por distância no tempo: mudar de ideia em oito meses é uma coisa,
   em dois dias é outra. Diga qual é qual, sem decidir por ela o que significa.
4. No fim, pergunte: "qual das duas você diria hoje?"

**O que NÃO fazer.** Não trate mudança de ideia como erro. Não invente tensão
onde há só assunto parecido. Não use o que a expressiva selada deixou — você só
tem o cabeçalho dela, e o cabeçalho não contradiz nada.

**Porta de volta.** Se ela pedir:

```
traco_escrever(
  titulo: "onde eu me contradigo sobre <X>",
  texto: "<as duas frases, com ids e datas>",
  origem: "grokbot",
  motivo: "a pessoa pediu para guardar as contradições que encontrei sobre <X>"
)
```
