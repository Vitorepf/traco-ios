# prova/16k — a voz da obra nas Notas (régua pré-registrada em 16/09/2026 16:33, antes do código)

**Alavanca única:** o pedido da rota das Notas (geração e conferência) passa a dizer que a fonte de obra é regra de um mestre, não nota da pessoa. Nada mais muda: montagem, escolha das seções (16i/16j), modelo, esforço, temperatura.

**Fixture:** `prova/16i/lote.json` (sha256 `03e1c80d584d97851a0cd5eb5b84dcf5d90c12711546ef641a2a9ed5b50b6afd`) — as mesmas 30 perguntas × 3 da 16i — e `prova/16i/lote-alheias.json` (sha256 `d443f3ecb6b1a162272fcffb58d72708900b430ae5e2a2a5658b2c2ae2988e58`) × 3.

**Régua (decidida pelo líder, 16/09):**
1. **Voz:** 0 de 90 respostas atribuem a obra à pessoa — "suas notas", "suas anotações", "você anotou/registrou/escreveu", "sua regra" referindo-se ao texto do mestre. Conta um leitor cego (agente que não vê o pedido nem o código), sobre as 90 respostas inteiras; a busca por palavras é só triagem.
2. **Sem regressão:** a seção certa entre as enviadas ≥ 28/30 em cada repetição e citada com mestre, vídeo e minuto (`prova/16i/contar.py`).
3. **Controle:** as 4 alheias × 3 sem obra enviada.

Base (16i, pedido antigo): triagem por palavras 42 de 90; 28/30 em cada repetição.

## Acréscimo à régua (pedido do líder, auditoria 16/09 noite) — registrado em 16/09/2026 18:17, ANTES do código de gênero e de precedência

A alavanca V passa a cobrir três defeitos de conteúdo da rota das Notas; a medida é a mesma janela.

4. **Gênero:** 0 de 90 (+ alheias + precedência) respostas flexionam gênero para a pessoa ("você mesma/mesmo", "cansada/cansado", "obrigada/obrigado" dirigido a ela) — leitor cego conta.
5. **Precedência:** `prova/16k/precedencia-casos.json`, 6 casos escritos por agente cego ao código (caderno de notas do autor + obras da biblioteca + pergunta sobre o que ELE decidiu/escreveu), × 3 repetições, pela SELEÇÃO do app (`Sessao.contextoDasNotas` sobre o caderno do caso), não por fontes dadas: as notas esperadas entre as enviadas em todos os casos com nota esperada; nenhuma resposta diz que falta o registro quando a nota foi enviada; o controle negativo não inventa decisão. Leitor cego confere "resposta_deve"/"resposta_nao_pode".
6. As réguas 1–3 continuam valendo sobre o mesmo binário.

Causa conferida no 17e antes do código: a pergunta "O que eu decidi sobre vendas e desconto?" tem 4 palavras de 4+ letras (decidi, sobre, vendas, desconto) e `NotasFiltro.casa` pede metade; as três Decisões do caderno dividem uma cada — nenhuma entra, e a obra entra pelo ranking.

## Separação (líder, 16/09) e régua da V2 — registrado em 16/09/2026 18:23, ANTES do código da precedência

- **V1 = voz + gênero** (já codados): corrida `D81B84B6-E6A7-4792-8CD0-CE73CE868D96` no Air, 21:23Z, lote `lote-v1.json` (30 perguntas + 4 alheias × 3). Binário: `Traco.debug.dylib` sha256 `b63bffd87b82d25c…`, HEAD `48232e2a` + diff de `Sabia.swift` sha256 `035298d8afeb3217…`. Réguas 1–4 acima.
- **V2 = precedência.** Decisão do DONO (16/09, relatada pelo líder): opção A — o Grok escolhe até 5 notas DO AUTOR pelo sentido entre até 30 candidatas, recebendo só título + ~200 caracteres de cada; trancadas, seladas e expressivas NUNCA são candidatas; as escolhidas vão inteiras e ANTES das obras; sem conta ou sem resposta, a seleção de hoje. **Régua:** nos 6 casos cegos (`precedencia-casos.json`), a nota esperada entra no pacote em ≥ 5/6 em cada uma das 3 repetições e a resposta a usa (leitor cego); o controle negativo não inventa decisão; sem regressão da 16i (28/30) nem da voz/gênero da V1.
- **Linha de base da seleção** (`linha-de-base-selecao.txt`, 17e, antes do código): 0 de 8 notas esperadas entram; só as duas obras vão ao pedido nos 6 casos.
- **Índice de sentido:** `NLEmbedding.wordEmbedding(for: .portuguese)` é **nil no simulador** (17e, iOS 27; `Indice.disponivel = false`) e **existe no macOS deste Mac** (script `swift`: palavra e frase em português disponíveis; distância escola–colégio 0,99). Não há iPhone real à mão: que ele exista num iPhone é indício (o mesmo framework do sistema), não prova. No aparelho onde o dono usa a conta (o Air, simulador) o índice está morto — é por isso que a seleção cai só nas palavras.
- **Caso real acrescentado antes da corrida da V2** (`real-01` em `precedencia-casos.json`, relatado pelo líder, 17e com Grok, 16/09): "o que eu decidi sobre desconto?" — a Decisão diz "Decidi: Não dar desconto e oferecer um bônus de implantação" e a resposta falou em "caminhos mistos: dar desconto (inclusive 20%…) e, em paralelo, não dar desconto" (misturou `escolha` com `decidido`). Régua do caso: a nota entra e a resposta diz a decisão sem apresentar o que estava em jogo como decisão (leitor cego). Não entra no ≥ 5/6 dos casos cegos; é registrado à parte.

## V2 medida — corrida `ADDEF457-52B9-4AED-B370-AE608F0B9327` (Air, 22:06Z), binário `Traco.debug.dylib` sha256 `ee17e4cf3aa92af8…`

`python3 contar_v2.py v2-grok.jsonl ADDEF457-52B9-4AED-B370-AE608F0B9327`: a nota esperada entra nos 6 casos cegos em **5/6, 5/6 e 4/6** (linha de base 0 de 8 notas). Falhas: `prec-04` nas 3 (foi só a nota de 12/08 que corrige, não a Decisão de 30/06); `prec-05` rep 3 vazia pelo contrato da rota (`semRetorno`). `prec-06` (controle) não inventa decisão nas 3. `real-01`: a nota entra nas 3, e a resposta diz nas 3 que "falta marcar qual linha vale" — trata "dar 20% de desconto" e "não dar desconto e oferecer bônus" como linhas em conflito.

## V3 — rótulos dos campos (registrado em 16/09/2026 19:16, ANTES do código)

**Causa conferida no código:** `VozDoAutor.juntar` (usado por `Nota.textoDeQualquerOrigem` → `Sessao.fonteParaPergunta`) junta os VALORES dos campos sem os rótulos; o modelo recebe "Dar 20% de desconto…", "Dar o desconto", "Não dar desconto e oferecer um bônus de implantação" sem saber que a última é o "Decidi".
**Alavanca única:** a nota com forma vai à rota das Notas com cada campo rotulado pelo nome do método ("Decidi: …", "O que estou decidindo: …"); nada mais muda.
**Régua:** `real-01` × 3 — a resposta diz que a decisão foi não dar desconto e oferecer o bônus, sem apresentar o desconto como decisão nem como conflito (leitor cego), 3/3; os 6 casos cegos sem regressão da V2 (a nota esperada entra em ≥ 5/6 em cada repetição, e as falhas do contrato da rota são registradas à parte).

## Remedida final — corrida `88B31333-6889-4547-9452-E8853DA357A9` (Air, 22:27Z–23:15Z)

Binário: `Traco.debug.dylib` sha256 `014a6c7d1a6ae8a2…`, HEAD `2cf3eca1` + diff de Sabia/Sessao/Conselho/AvaliacaoIA/FonteNotas sha256 `1b4f0b1be5c16f04…` — V1 + V2 + V3 + linha em branco citada ignorada + teto que corta em vez de esvaziar (com a frase de corte, trocada ANTES do commit pelo corte silencioso e `Retorno.cortada`, a pedido do líder; o corte não muda o que se conta aqui). Depois desta corrida, sem medida própria (não tocam os casos: cadernos ≤ 8 notas, obras conferidas, escolhas < 20 s): pontuação das candidatas sem rótulo, "só o nome" com rótulo, marca da obra suposta, espera de 20 s nas escolhas.

Lote `lote-remedida.json` (7 casos da V + 30 da 16i + 4 alheias) × 3 = 123 casos.

| régua | medido |
|---|---|
| 16i: certa entre as enviadas ≥ 28/30 | **29 / 29 / 29** (só `p-19`, fora das 30) — citada com minuto nas mesmas |
| precedência: nota esperada no pacote ≥ 5/6 nos 6 cegos | **6/6, 6/6, 6/6** (`prec-04` passou) |
| `real-01`: a nota entra | 3/3 (a resposta vai ao leitor cego) |
| respostas vazias | **0 de 123** (16i: 3 por corrida; V1: 3; V2: 1) |
| alheias sem obra enviada | 11/12 — `alheia-3` rep 1 ("quero aprender violão"): o Grok escolheu uma seção, a resposta saiu base geral e não a citou |

Voz, gênero e o cumprimento de `resposta_deve`/`resposta_nao_pode` dos 7 casos: leitura cega em `leitura-remedida.md`.
