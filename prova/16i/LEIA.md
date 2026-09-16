# prova/16i — as seções das Notas pelo sentido (Air E66EF2AD, conta Grok, 16/09/2026)

Casos escritos antes do código: `ferramentas/obras/perguntas.json` (20, commit da 16b) e `perguntas-reserva.json` (10, 16c); `lote.json` só os embrulha com as obras do Documents (`hormozi.md`, `lenny.md`, idênticos à biblioteca). Gabarito = o vídeo de cada pergunta (o mesmo da 16g).

Contagem pelo JSONL: `python3 contar.py notas-pelo-sentido-grok.jsonl F522B872-E990-4FDD-82CE-E14E58D2D6C3`.

| repetição | certa entre as enviadas | certa citada (link + minuto) | via modelo |
|---|---|---|---|
| 1 | 28/30 (18/20 + 10/10) | 28 | 29 |
| 2 | 28/30 (18/20 + 10/10) | 28 | 29 |
| 3 | 28/30 (18/20 + 10/10) | 28 | 29 |

- Falhas: `p-19` nas 3 (a certa fica fora das 30 candidatas — 47ª, já medido na 16g); `semRetorno` em `p-15` (rep 1 e 2) e `p-17` (rep 3): a geração passou de 900 caracteres ou a conferência foi recusada — contrato da rota, com a escolha feita.
- 268 chamadas, HTTP 200 em todas; duração por caso (escolha + geração + conferência): mediana 19,6 s, pior 35,8 s.
- Voz: em 42 das 90 respostas o modelo chama a regra de "suas notas" / "a regra que você anotou" (dívida da ADR 16i).
- `alheias-grok.jsonl` (build final, depois da revisão): 4 perguntas alheias × 3 — nenhuma obra enviada; em 9 a obra foi candidata e o Grok respondeu `{"regras":[]}` nas 9; nenhuma recusa «não coube».
- A corrida principal usou o build anterior às correções da revisão (recusa falsa, seção duplicada, aviso da falha); elas não tocam a escolha nem a montagem destas 30 perguntas.
