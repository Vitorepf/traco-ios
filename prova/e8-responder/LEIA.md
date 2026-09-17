# prova/e8-responder — a pergunta da Página (Tutor) remedida. Régua registrada em 17/09/2026 00:26Z, antes de qualquer corrida e antes do código da sonda

**Rota:** `responder` (`Politica.linha(.responder)`: `indisponivelPorQualidade`, medida em 10/09; "Volta a ter executor quando algum passar a MESMA matriz"). Árvore pós-V3/E7 (campos rotulados; a sonda passa a montar a página com `VozDoAutor.rotulada`, como a `Sessao.perguntarASabia` — prosa e, quando a fixture traz `campos`, os campos rotulados; os 20 da 10b usam `contexto` pronto e não passam por aí).

**Casos:**
- A MESMA matriz: `prova/10b-casos.json` (sha256 `0af49dc5f5b302ce9e5699833c8ca69fbe213aaf3e94fb5fcb33566e1a495cf0`), 20 casos. Os 6 de `responder` de `prova/q-qualidade-casos.json` (corridas de 08/09) já estão nela como regressão (mesma pergunta).
- Novos: `casos-novos.json` (sha256 `88234bd9aecf50f703d3d3a8f1d1fb1f577999c00a963cc38ad0a4a2bdcf46ec`), 4 casos **SINTÉTICOS**, escritos por agente cego ao código e ao caderno do dono (ordem do líder: nada pessoal no git), no tipo de situação do caderno: Decisão com «Decidi» (preço/venda), compras com preço faltando, treino com limitação escrita, nota ligada com fato antigo corrigido pela página.
- 3 repetições. Bruto em `chamadasGrok[].bruto`. Lote rodado: `lote.json` (os 20 + os 4, sha256 `bd04e6cb93d198253fb3610705953dc86970e40f176791fe0bd69ed95a81a08c`), uma corrida por braço, `SIMCTL_CHILD_TRACO_AVALIAR_LIBERAR=responder`.

**Braços (mesmo binário, mesma fixture):** `grok-4.5` (o modelo que a conta serve) e `grok-4.3` (controle; base da 10b: 14 e 15 de 20). `TRACO_AVALIAR_MODELO`, `TRACO_AVALIAR_LIBERAR=responder`.

**Régua (critério da Politica relido pelo PRINCÍPIO DA SÁBIA, `ferramentas/orca/PROMPT-LIDER-CONSELHO.md`):**
- Leitor cego (agente sem o pedido, sem o código, sem o braço) lê cada resposta contra os `requisitos` do caso e contra quatro critérios: (1) não inventa o que a página e as notas ligadas não dizem; (2) não contradiz o que elas dizem; (3) concisão — o essencial em poucas linhas, sem transcrever a página; (4) utilidade — o próximo ato concreto. Voz (não fala como o autor) e gênero (não presume) continuam.
- Onde um requisito antigo pedir apoio literal, vale fidelidade: resumir, reorganizar e concluir cumprem; só atribuir palavras ao autor entre aspas pede literalidade.
- Um descumprimento em qualquer repetição reprova o caso (regra da 10b).
- **Volta:** o braço `grok-4.5` cumpre **20/20** da matriz e **4/4** dos novos, com voz e gênero 0. O controle `grok-4.3` é registrado; se ficar longe de 14–15 da 10b, a leitura explica a diferença (princípio novo ou árvore nova) antes de concluir.
- **Não volta:** o `porque` da linha ganha o medido e a causa nova; o `conserto` é nomeado.

## Volta 1 — medida (Air, 17/09 01:18Z–01:59Z, binário `Traco.debug.dylib` sha256 `2fe77e4b1624b081…`)

Corridas `54C06638` (grok-4.5, `grok45.jsonl`) e `99C59AA2` (grok-4.3, `grok43.jsonl`); 72 respostas cada, bruto em 72/72, zero vazias, zero erros; mediana 10,2 s e 9,0 s. Dois leitores cegos, 144 itens embaralhados sem o braço (`leitura_cega.py`, `leitura-cega-veredictos.txt`, chave em `leitura-cega-chave.json`).

| braço | matriz 10b (caso cumpre nas 3) | novos | respostas que cumprem | resposta trocada pela recusa do app |
|---|---|---|---|---|
| grok-4.5 | **8 de 20** | 2 de 4 | 42 de 72 | 8 |
| grok-4.3 | **8 de 20** | 0 de 4 | 38 de 72 | 4 |

**Não passou.** O controle empata: o modelo não é a alavanca. O 4.3 longe dos 14–15 da 10b: a leitura é outra (cega, pelo PRINCÍPIO — concisão, utilidade, não supor) e há 4 casos novos. **Causa nova, a principal, é NOSSA:** `SustentacaoPagina.filtrar` trocava a resposta INTEIRA por «Não descrevo um documento que você não trouxe…» bastando "pdf"/"sumário"/"abra o arquivo" numa frase — 12 de 144, e sozinha derruba `10b-relatorio-estrutura-fornecida`, `10b-relatorio-sem-indice-nem-busca`, `revisor-espanhol-sem-material`, `revisor-retomar-sem-suporte`. Depois: supor o que quem escreve anota/usa/tem ("a média que você já anota", "sua corretora", "a planilha que você usa"), telefone 156 e cliente inventados; conta de data não fechada (23/09); falta dita pela metade (a quantidade do gelo); dor sem remeter ao ortopedista; um "você mesmo" e um "você mesma".

## Volta 2 — régua do líder (17/09, registrada ANTES da remedida)

Decisão do líder: a guarda que cala a resposta inteira é defeito nosso; conserta-se e remede. **Conserto:** (a) `SustentacaoPagina.filtrar` tira só a frase que supõe o documento não trazido (a recusa inteira só quando sobram menos de 60 caracteres); (b) `sistemaResponder` proíbe supor o que quem escreve anota, usa ou tem, manda fechar a conta de data, dizer por inteiro o que falta e remeter a profissional em saúde; (c) `semGenero` no pedido. **Remedida só no braço grok-4.5**, mesmo lote, mesmos dois leitores cegos (itens embaralhados), mesma régua de leitura. **Barra: ≥ 14/20 na matriz da 10b e ≥ 3/4 nos novos.** Passou: `responder` volta à tabela. Não passou: commit com a causa nova e o conserto seguinte nomeado.
