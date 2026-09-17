# prova/e8-instigar-contrapor — as perguntas que instigam e o contraponto, remedidos. Régua registrada em 17/09/2026, antes da corrida

**Rotas:** `instigar` e `contrapor` (`Politica`: `indisponivelPorQualidade`, medidas em 10/09; "volta a ter executor quando algum passar a MESMA matriz"). Árvore pós-E7/E8-responder.

**Antes da medida (varredura das guardas que calam, líder 17/09):** `Sabia.parsePerguntas` — item que não é texto sai sozinho (antes a lista inteira virava nil); `Sabia.parseContraparte` — chave fora das cinco é ignorada (antes nil) e, em cada campo, sai só a FRASE com fato ou número que a pessoa não deu (antes o campo inteiro). `GuardaDeInstigar` e `GuardaDeContrapor` tiram um item e ficam como estão.

**Mudança na sonda (registrada):** o texto vai como a produção o manda — `Caderno.prosa(de:)` (Sessao e LenteView); em 10/09 ia cru. Isso muda o que se mede em relação a 10/09.

**Casos (`lote.json`, sha256 `0556410407632a8c…`, 34 casos × 3):**
- instigar, a MESMA matriz: `prova/instigar-cego-base-casos.json` (sha `b831b3c3…`), 8 casos — os dois cegos são `revisor-instigar-nota-que-ja-responde` e `revisor-instigar-fatos-negados`;
- contrapor, a MESMA matriz: `prova/q4c-contrapor-cego-casos.json` (sha `da012e21…`), 8 casos — os dois cegos são `revisor-contrapor-alternativas-negadas` e `revisor-contrapor-razoes-fechadas`;
- regressão: os 6 + 6 de `prova/q-qualidade-casos.json` (08/09: instigar 1/6, contrapor 1/6);
- novos: `casos-novos.json` (sha `213fd983…`), 3 + 3 **SINTÉTICOS**, escritos por agente cego ao código e ao caderno do dono.

**Braço:** só `grok-4.5` (decisão do líder: o 4.3 reprovou em 10/09 e o controle não muda a decisão). `TRACO_AVALIAR_MODELO=grok-4.5`, `TRACO_AVALIAR_LIBERAR=instigar,contrapor`. Bruto em `chamadasGrok[].bruto`.

**Leitura:** os mesmos dois leitores cegos, itens embaralhados, pelo PRINCÍPIO DA SÁBIA (fiel, não literal; não inventa; útil; sem gênero presumido; a IA nunca fala como a pessoa), cada item contra os seus `requisitos`, com um critério a mais (líder): **instigar** — a pergunta faz pensar sobre o que a pessoa escreveu, sem responder por ela e sem pedir o que ela já disse; **contrapor** — mostra o outro lado ou a opção que faltou com base no que ela escreveu, sem inventar fato. Um descumprimento em qualquer repetição reprova o caso.

**Barra, por rota (líder, 17/09):** os dois casos cegos cumprem **3/3**; a matriz **≥ 6 de 8**; os novos **≥ 2 de 3**; voz e gênero **0**; a regressão de q-qualidade não fica abaixo do medido em 08/09 (≥ 1 de 6). Passou: a rota aponta para o `grok-4.5` (como o `modeloMedido` das Notas), com teste, e volta à tabela. Não passou: `porque` com a causa e o conserto nomeado.

## Volta 1 — medida (Air, 17/09, binário `df75d134…`, corrida `77158A03`, `grok45.jsonl`)

102 respostas: 0 erros, 0 listas vazias, 0 contrapontos com os três campos vazios; guardas tiraram algo em 3. Leitura cega (`leitura-cega-veredictos.txt`, chave em `leitura-cega-chave.json`):

| rota | cegos (barra 2/2) | matriz (≥ 6/8) | novos (≥ 2/3) | q-qualidade (08/09: 1/6) | gênero (0) | respostas que cumprem |
|---|---|---|---|---|---|---|
| instigar | 1 de 2 | **6 de 8** | **2 de 3** | 5 de 6 | 3 | 44 de 51 |
| contrapor | 0 de 2 | 2 de 8 | **2 de 3** | 0 de 6 | 11 | 28 de 51 |

**Não passou.** Causa, lida no código e NOSSA: os pedidos tratam quem escreve no feminino (`sistemaInstigar`, 10 vezes; o corpo do contrapor, 4) e nenhum leva o `semGenero` — o modelo devolve «enganada», «que ela fixou»; o `outroCampo` pede «um caso de outro campo (… época)» e o modelo afirma fato histórico (GPS, calculadora, fotografia) — 4 invenções que derrubam três casos; «passo básico» vaza (2), variante do andaime que a guarda não conhece. Depois: pergunta já respondida (2), substituto do que falta (1), argumento por fator que a nota tirou (2), contra vazio (1).

## Volta 2 — conserto e régua (autorizados pelo líder, registrados ANTES da corrida)

(a) Gênero pela raiz, em TODOS os pedidos do app (varredura dos `sistema*`): quem escreve vira "quem escreve", neutro, e o `semGenero` entra em todos. (b) `outroCampo`: analogia MARCADA ("é como quando…") ou pergunta ("isso lembra…?"), nunca fato histórico afirmado; sem analogia fiel, "". **Leitura:** analogia marcada não conta como invenção. (c) Andaime: "passo básico" na lista da guarda, e conferir "passo mais básico" e "movimento" soltos. Barra igual.
