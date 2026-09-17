# prova/e9 — nota enorme e síntese. Régua registrada em 17/09/2026, antes do código

**PRINCÍPIO DA SÁBIA** (dono, 16/09; `ferramentas/orca/PROMPT-LIDER-CONSELHO.md`): fiel, não literal; nota enorme nunca fica fora por tamanho; resposta curta por padrão, com a fonte.

**Causa conferida no código (antes):** `RespostaNotas.montar` leva a nota do AUTOR inteira ou nada; o pacote tem 16.000 caracteres, e uma nota de 50–200 mil fica fora, nomeada («não coube inteira») — dívida (a) da ADR 16l. Nenhum código recusa síntese (`interpretar` só confere que o ID existe e não é linha em branco); o risco é o julgamento do modelo de conferência ("tire o que não segue do material").

**Casos (escritos ANTES do código, por agente cego ao código e ao caderno do dono; SINTÉTICOS):** `casos.json` (sha256 `1d40c59d6d47559c29e6e23589ae443c60f82e0bd96efe63ff0d1ef325682880`), gerado deterministicamente por `gerar_casos.py` (sha256 `55f46a1e5cacee7013b84cb98b35d0dfd3ad68ba233f700a570f601cf3d63779`): três cadernos, cada um com UMA nota enorme — diário de trabalho de 60.036 caracteres (fato corrigido depois: R$ 440 → R$ 410), estudo de 120.060 sem títulos com um parágrafo de 9.574 caracteres sem quebra, registro de projeto de 200.075 (três decisões e uma pergunta em aberto; MDF cogitado e não decidido) — mais 4 notas curtas (uma de isca); uma pergunta específica e uma ampla por caderno. 6 casos × 3.

**Mais, na mesma janela e no mesmo binário:** `prova/16k/lote-remedida.json` (sha256 `eb6519cb…`: os 30 da 16i, `real-01`, os 6 de precedência e 4 alheias) × 3.

**Régua:**
1. **Nenhuma nota do autor fora por tamanho:** a nota enorme chega ao pacote (por partes ou síntese) em **18/18**; `foraDoPacote` sem "nota «…»: não coube" para ela.
2. **Leitor cego** (sem pedido, sem código) julga cada resposta dos 6 casos contra `resposta_deve`, `resposta_nao_pode` e os `requisitos`: (a) não inventa e (b) não contradiz — **zero** violações nas 18; (c) concisão e (d) utilidade — o caso cumpre nas 3 repetições em **≥ 5 de 6** casos.
3. **Sem regressão** da remedida da E7: 16i ≥ 28/30 em cada repetição; `real-01` 3/3; notas esperadas ≥ 5/6; voz 0 e gênero 0 (leitor cego); vazias 0.
4. Registrado, sem barra: `prec-02` (dívida b da 16l), tamanho do pedido, chamadas por pergunta e duração.

**Linha de base** (antes do código): corrida `95321F0A` no Air (17/09 01:59Z–02:07Z), binário `2fe77e4b…` (sem a E9), `casos.json` × 3 → `base-grok.jsonl`. A nota enorme chegou ao pacote em **0 de 18**: em 16 o pacote registra "nota «…»: não coube"; em 2 (`e9-a-ampla` reps 1 e 2) ela nem foi candidata. As respostas dizem que "nesta consulta" o registro não veio.

## Volta 1 — medida (corrida `AC6A4D07`, binário `daa3314c…`, `medida-grok.jsonl`)

Nota enorme no pacote **14 de 18**; vazias **3**; 16i 29/29/29; precedência 4/6, 5/6, 6/6. Não passou. Causas (bruto): `SinteseDeNota.parse` jogava fora leitura acima de 1.500 (5 de 16); partes juntadas com linha em branco desalinhavam a citação (2 vazias); `interpretar` recusava "insuficiente" com ID (1 vazia); a escolha das notas devolveu [] para a pergunta que nomeia o diário (2). Consertos da volta 2 aprovados pelo líder, com a varredura das guardas que calam.

## Volta 2 — medida (corrida `CB6046FE`, binário `dae1d74a…`, `medida-volta2-grok.jsonl`)

Pelo JSONL: nota enorme no pacote **18 de 18**; vazias **0**; 16i **29/29/29**; precedência **5/6** nas três (só `prec-04`); `real-01` entrou 3/3; leitura presente em 17 de 18; pedido médio 2.153. Leitor cego nos 6 casos (`leitura-cega-e9-volta2.txt`): (a)+(b) **1 violação** em 18 (`e9-a-ampla` rep 3 diz que nada mudou); (c)+(d) nas 3 repetições em **3 de 6** casos — os três específicos cumprem 3/3; os três amplos falham (longos, falam da mecânica — "4 de 45 partes", "linhas enviadas", "a leitura da nota" —, perdem conclusões). **Não passou.** Causa lida no bruto, NOSSA: em `e9-a-ampla` rep 3 a leitura trazia duas das três mudanças e a resposta a ignorou — o pedido diz "valem as linhas" e "diga o que esta consulta contém", e o modelo leu ausência nas partes como ausência na nota; a leitura abria pela rotina e enterrava as decisões.

## Volta 3 — conserto (registrado ANTES da corrida; última volta do laço)

Só pedidos: `sistemaResponderNasNotas` — pergunta sobre o conjunto de uma nota em partes responde pela `leituraDaSabia` (ausência nas partes não é ausência na nota); nunca fala da mecânica (partes, linhas, trechos enviados, "nesta consulta", "a leitura da nota"); só as notas que tocam a pergunta. `SinteseDeNota.sistema` — começa pelo que mudou, foi decidido ou concluído (com data), valores vigentes e mudanças de papel; perguntas em aberto; rotina numa frase curta no fim. Régua igual.

**Ajustes do líder na volta 3 (registrados antes da corrida):** (1) a versão do pedido da leitura entra na chave guardada (`SinteseDeNota.versaoDoPedido = 2`): leitura feita pelo pedido antigo não é reusada; (2) `semGenero` ganha a regra do adjetivo e do particípio («vale mais firmeza» em vez de «seja mais rígido») — só no pedido; (3) pergunta ampla em poucas frases, conclusões e mudanças primeiro, nada de mecânica. Barras iguais: (a)+(b) zero; (c)+(d) ≥ 5 de 6; voz e gênero 0.

## Volta 3 — medida (corrida `07A1560B`, binário `82e0dd11…`, `medida-volta3-grok.jsonl`)

Pelo JSONL: nota enorme **18/18**; leitura presente **18/18**; vazias **0**; 16i **29/29/29**; precedência 6/6, 6/6, 5/6; `real-01` 3/3. Leitura cega (`leitura-cega-e9-volta3.txt`): (a)+(b) **2 violações** (data errada numa ampla; "sem outras conclusões" noutra); (c)+(d) nas 3 repetições **3 de 6** (específicas 3/3, amplas 0/3); voz **0**, gênero **1** (`alheia-3`: «sentado… destro»); casos da V e `real-01` SIM em todas; invenção 0. **Não passou nas três voltas do laço.**

**Causa lida no código, nossa:** as regras novas da ampla entraram só no pedido da GERAÇÃO; o texto que a pessoa lê é o da CONFERÊNCIA, cujo pedido ainda manda "Diga o que ESTA consulta contém e o que falta nela" — e a mecânica ("linhas desta consulta", "nesta seleção") volta ali. O rótulo das partes ("as outras partes não vieram") e o aviso do pacote ("não conclua ausência a partir desta seleção") empurram no mesmo sentido. **Conserto seguinte nomeado:** as regras da pergunta ampla e da mecânica no pedido da conferência; nota com leitura guardada não recebe o "diga o que esta consulta contém"; o rótulo das partes deixa de falar do que não veio.

## Volta 4 — conserto (autorizado pelo líder, registrado ANTES da corrida)

Só (1)–(3): (1) o pedido da CONFERÊNCIA ganha as regras da pergunta ampla (poucas frases, conclusões e mudanças primeiro, todas as que a leitura e as linhas trazem, rotina de fora, só as notas que tocam a pergunta) e da mecânica (nada de partes, linhas, trechos enviados, "nesta consulta", "nesta seleção", "a leitura da nota"); (2) sai da conferência o "Diga o que ESTA consulta contém" — nota com `leituraDaSabia` responde pelo todo; (3) o rótulo das partes diz "trechos da nota, os que tocam a pergunta; a nota inteira está resumida em leituraDaSabia quando ela vem", sem "as outras partes não vieram". Mesma régua, mesmo lote, mesmos leitores.

## Volta 4 — medida (corrida `74C4AEF2`, binário `3536e456…`, `medida-volta4-grok.jsonl`)

Pelo JSONL: nota enorme 17/18 (a 18ª é a vazia); vazias **1** (`e9-a-ampla` rep 2); 16i **29/29/29**; precedência 5/6, 5/6, 6/6; `real-01` 3/3. Leitura cega (`leitura-cega-e9-volta4.txt`): (c)+(d) nas 3 repetições **5 de 6** ✓ (as três amplas melhoraram: b-ampla e c-ampla cumprem 3/3); (a)+(b) **2 violações** — a MESMA data errada em `e9-a-ampla` (negociação do milheiro em 22/04; foi 15/07); voz **0**, gênero **0**; casos da V e `real-01` SIM em todas; invenção 0. **Não passou**: régua 1 (17/18), régua 2(a)(b) e vazias.

**Causas, lidas no bruto:** (1) a data errada nasce na LEITURA GUARDADA — `SinteseDeNota` roda no modelo padrão (`grok-4.3`) e escreveu "Em 22/04/2026, após negociação, o milheiro … ficou em R$ 410", juntando duas entradas; a resposta copia a leitura. (2) A vazia é guarda nossa: resposta ampla tirada da leitura, base "notas", SEM trecho citado — `interpretar` exige ao menos um ID na base notas e cala a resposta inteira. **Conserto seguinte nomeado:** a leitura roda no `modeloMedido` das Notas (`grok-4.5`) e cada valor leva a data da entrada em que foi escrito; base "notas" sem ID, com nota do pacote que traz leitura, vale com a nota da leitura como fonte.

## Volta 5 — conserto (autorizada pelo líder em 17/09, registrada ANTES do código e da corrida; última)

Só (a) e (b): **(a)** a leitura guardada roda no `modeloMedido` das Notas (`grok-4.5`), não no padrão global (`grok-4.3`); o pedido manda escrever cada valor, decisão e mudança com a data da ENTRADA em que foi escrito, nunca juntar numa frase fatos de entradas diferentes sob uma data só; o `semGenero` entra no pedido; `versaoDoPedido` sobe para 3 (a leitura da volta 4 não é reusada). **(b)** base "notas" sem trecho citado deixa de calar a resposta **só** quando alguma nota do pacote traz `leituraDaSabia`: a fonte citada é a nota (ou as notas) da leitura; sem leitura no pacote, continua recusada. Testes nos dois sentidos, e o do modelo e da data no pedido.

**Mesma régua, mesmo lote** (`lote.json`, sha `f4635f27…`: os 6 casos × 3 e a remedida da E7 × 3), mesmos leitores cegos, mesmo aparelho. Na sonda: a chamada da leitura com `modeloSolicitado` `grok-4.5`. **Passou** → a E9 fecha inteira. **Não passou** → a E9 fica parcial e para (sem volta 6).
