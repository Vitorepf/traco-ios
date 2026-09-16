# 05 — Lente: contexto e parametrização

Leitura feita em 16/09/2026, só leitura. Atlas lido em `atlas-server` (último commit 694b593ef, 30/07/2026). Não rodei nenhum comando do Atlas: os estados vêm dos próprios docs e podem estar velhos. Traço lido na árvore de trabalho de `main`, **com as mudanças ainda não commitadas** (ADR 16k em `Sessao.swift`, `Sabia.swift`, `FonteNotas.swift`).

Em uma frase: o Atlas trata contexto como **referência com motivo, orçamento, frescor e recibo de perda**. O Traço já faz bem a parte do **selo e da revalidação**, mas monta o contexto **rota por rota, à mão**. Por isso o conserto de 16/09 (campos rotulados) entrou numa rota só e o mesmo defeito continua nas outras.

---

## 1. O modelo de contexto do Atlas

### 1.1 Camadas

O Atlas separa o contexto em quatro planos:

| Plano | O que é | Evidência |
|---|---|---|
| **Ciclo por pedido** | prompt → APCR → `AiContextPackBuilder` (recall + verbatim + semântico) → ranking (ACRS) → frescor (ACFQ) → compilador (ACCR) → portão de qualidade (ACQCG) → injeção Open Brain → provedor | `docs/engineering-knowledge-base/atlas-cognition-operating-system.md`, «Ciclo 2 - Query-Time» |
| **Ordem fixa no prompt** | 1) sistema e identidade; 2) instruções e política; 3) contrato da tarefa e objetivo; 4) `# Atlas Open Brain Context` (**uma** seção, sem duplicata); 5) pedido | `open-brain-context-injection.md`, «Prompt Placement» |
| **Tipos de referência** | `memory_refs`, `verbatim_refs`, `knowledge_refs`, `code_refs`, `provider_projection_refs`, `open_brain_audit_refs`, cada tipo com campos obrigatórios | `memory/retrieval-and-context.md`, «Context Ref Types»; `memory-core-contracts.md`, «Active Contracts» |
| **Sinal antes do roteador** | O ACFD transforma o pedido num vetor de seis funções (`reasoning, retrieval, generation, code, vision, audit`), somando 1,0, com hash determinístico. É **sinal, não decisão**. | `atlas-cognitive-function-decomposer.md`; `AtlasCognitiveFunctionDecomposerService.php:206-256, 296-328` |

O compilador (ACCR) tem uma regra que vale citar para o Traço: **«Não misturar instrução de sistema com evidência operacional»**. Ele também separa *fatos, inferências, memórias, decisões, bloqueios e riscos* antes de aplicar o orçamento (`atlas-context-compiler-runtime.md`, «Fluxo» 3 e «Regras para IA»).

O decompositor é só heurística por substring: `str_contains` sobre palavras-chave (`AtlasCognitiveFunctionDecomposerServiceSupport.php:23`). Por isso «cli» casa com «cliente» e «doc» casa com «documento». É exatamente a classe de defeito que o Traço mediu em 16/09: «decidi» casava com o rótulo «O que estou decidindo». No gateway, o ACFD entra como *opt-in seam* (`AiGatewayService.php:55-67`).

### 1.2 Orçamento

- Parâmetros do pedido: `budget_chars` (exemplo de 20.000), `refresh`, `require` e `provider_safe_only`, este sempre `true` (`open-brain-context-injection.md`, «Policy Modes»).
- **Primeiro pacote pequeno e depois expansão sob demanda.** O pacote inicial leva índice, resumos e *handles* (`expand:<source_type>`, `recheck:<source_type>`). O provedor pede o resto por `atlas_context_expand` (mesmo doc, parágrafos sobre `context_delivery_policy` e *compact prompt mode*).
- Quando estoura: «drop lowest priority refs and report truncation» (`retrieval-and-context.md`, «Budget Rules»).
- Invariante: `must_keep_coverage = 1.0`. A compactação nunca pode descartar decisão, bloqueio ou DoD (`atlas-cognition-operating-system.md`, «Regras para IA»; glossário TEOS, `compaction_receipt`).
- No legado, eram até 8 referências por pacote (`context-pack.md`, «Politica De Tamanho». O doc está `deprecated` e aponta para os quatro sucessores).

### 1.3 Referência × conteúdo

- Regra-mãe: «All refs must be small, explainable, provider-safe and budgeted. **Full content is exceptional.**» (`memory-core-contracts.md`).
- Cada referência leva `id, slug, título, categoria, prioridade, path, content hash, resumo, **motivo da inclusão**` (`context-pack.md`).
- No contrato VoxContextRef, `ref` é um identificador opaco, **nunca o conteúdo cru**; `meta` leva só hash, tamanho e ids. Os `kind` são enumerados em três listas: *default-on*, *opt-in com TTL ≤ 24 h* e *proibidos*. Um `kind` fora da lista dá 422, e `resolved=false` pausa até o humano confirmar ou remover (`docs/contracts/vox/VoxContextRef.v1.md`, «Regras invariantes» 1–7). **Atenção: o contrato é só papel.** O V4 está bloqueado pelo GATE V3 e não há runtime.
- O que é de fora vem marcado: «mark untrusted content as data, never instruction» (`retrieval-and-context.md`, «Immune Retrieval Contract» 5).

### 1.4 Frescor

- Todo item recuperado expõe `freshness`: momento do registro, último uso, idade em dias e status de revisão (`retrieval-and-context.md`).
- O ACFQ bloqueia fonte velha, sem autoridade ou contraditória. Regra: «Não transformar unknown freshness em current» (`atlas-context-freshness-quality-gate.md`).
- O manifesto do pacote (AP-100) tem `created_at`, `expires_at` e `ttl_seconds`, mas **os timestamps ficam fora do hash de replay**. Um *self-reflection gate* classifica o pacote em `sufficient | insufficient | contradictory | risky`, e em modo `required` falha fechado (`docs/ap/AP-100-context-pack-manifest-self-reflection-contract.md`).
- Planejado (TEOS) é `temporal_truth`: `valid_from, valid_until, observed_at, verified_at, stale_after, source_hash, confidence, superseded_by, evidence_refs, authority_level`, com a cadeia de autoridade **`operator > canonical_doc > evidence_runtime > code_intelligence > provider_output`** (glossário TEOS).

### 1.5 Proveniência

- Todo item tem `lineage` (fonte local, tipo e id da referência, origem, hash), `freshness` e `audit` (flag *provider-safe*, classe de privacidade, redação) (`retrieval-and-context.md`).
- O ranking prefere escopo explícito a memória global e **decisão aceita a observação**, e anexa um *reason string* (mesmo doc, «Ranking Rules»).
- Toda injeção grava rastro: hash do objetivo, política, status (`injected | skipped | degraded | failed_open | failed_closed`), motivo, `context_pack_hash` e contagem por tipo (`open-brain-context-injection.md`, «Audit And Evidence», «Failure Semantics»). **O texto do prompt nunca é persistido; as métricas são.**
- Um recibo de compactação lista `retained_items` com `must_keep` e motivo, e `discarded_items` com `discarded_reason ∈ {stale, low_signal, duplicate, out_of_scope, superseded}` (glossário TEOS). Esse recibo está como *planned*.

---

## 2. A parametrização

### 2.1 No Atlas: o que é parâmetro, quem ajusta, como aparece

| Parâmetro | Quem ajusta | Como fica visível |
|---|---|---|
| Modo de injeção `off/auto/required`, `budget_chars`, `refresh` | a superfície declara, o backend compõe; nenhuma superfície cola memória no prompt | rastro com `status` e `reason`; o modo `off` exige registrar o motivo |
| `context_delivery_policy` (orçamento inicial, mistura de fontes) | **o laço de feedback**, mas só encolhe o orçamento inicial *limitado* por ROI por referência. Nunca remove must-keep; *readiness-only feedback* sem atribuição «is non-actionable» | `atlas_memory_maintenance_status` → `context_feedback_metrics`, `open_brain_prompt_metrics` |
| Regras e *nudges* do ACFD (`RULES`, viés por `framework`/`role`, distribuição padrão 0,5/0,2/0,15/0,05…) | o operador, «via PR», e «Alterar keywords ou biases somente com teste» | CLI com barras ASCII, `debug.hits` e JSONL append-only com `decomposition_hash` |
| `kind` permitido, opt-in ou proibido (Vox) | **só por ADR** («Adição = nova ADR. Remoção = nova ADR.») | a lista normativa no próprio contrato; recusa 422 com evento `VOX_ACTION_BLOCKED` |
| Limites de mudança por peça (`allowed_changes`, `forbidden_changes`, `risk_level`, `required_tests`) | o autor do doc canônico (frontmatter) | a Cartografia, na camada «Prova e Segurança» do modal |
| Decisão de parar (AHCL: `continue/repair/replan/escalate/submit`) | derivada de spec, plano, evidência, gates e review | painel com `action, reason, readiness, next_step, next_command`. Risco declarado: «Atlas Code mostrar score, mas esconder reason/next_step» (`atlas-hierarchical-control-loop.md`) |

O padrão que atravessa tudo: **o parâmetro muda por evidência (teste, ADR, ROI medido), nunca por aprovação solta, e a mudança deixa recibo.** A promoção silenciosa é proibida («Silent promotion from chat, Obsidian or Open Brain usage», `memory-core-contracts.md`).

### 2.2 A Cartografia serve para mostrar os parâmetros?

**Em parte, e não do jeito que o Traço pode usar.**

- Ela **mostra os parâmetros declarados de governança** de cada peça: nome, status, fonte, owner, `allowed/forbidden_changes`, risco, patamar e versão, organizados em sete camadas no modal do toque longo (Essencial, Fluxo, Relações, Evolução, Patamares, Versões, Prova e Segurança) (`atlas-cartography-nomenclature-contract.md` §Contratos; `atlas-universal-reality-cartography.md`).
- Para a IA, ela serve de **mapa de contexto**: a IA pode pedir «contexto de um node», «vizinhos por profundidade», «allowed_changes e forbidden_changes», «impact map de uma mudança» (`atlas-cartographic-knowledge-os-submodules.md`, «AI Navigation API»).
- Ela **não mostra os parâmetros vivos de cada pedido**: o que entrou, o que caiu, o orçamento, o frescor. Isso mora no rastro e nas métricas do Open Brain. A própria ACOS diz: «Cartografia — visualiza ACOS mas é separada (visualization-only)», e a Cartografia «consome verdade; não cria verdade».
- Ela é, por construção, **um painel navegável**: mundo, setor, fluxo, engrenagem. A ADR 14a do Traço proíbe exatamente isso.

O que vale trazer da Cartografia são quatro contratos, não a tela:
1. «Todo node visual precisa apontar para fonte real».
2. «Ausência de fonte deve aparecer como lacuna, não como silêncio».
3. «Tap navega, **long press explica**» (o que é, de onde veio, como entra, como sai).
4. O «Truth Guard»: o que se mostra ao humano tem de ser **idêntico** à fonte, e qualquer divergência é defeito crítico (`atlas-cartography-truth-guard.md`).

### 2.3 No Traço: os parâmetros escondidos que existem hoje

| Parâmetro | Onde | Quem ajusta | Visível hoje? |
|---|---|---|---|
| **forma** (gesto) | `Nota.gesto`; vestir e classificar (`Politica.swift`, `.vestir`/`.classificar` = `grokDepoisBordo`) | IA e regex; o autor desfaz (`Sinal.solto`) | na página, pela própria forma |
| **domínio** | `Nota.dominio` / `dominioTravado` (`Nota.swift:118-142`) | léxico ou aparelho; **o autor corrige pelo toque longo e a inferência trava** | chip; a correção está no toque longo (ADR 14a, item 6) |
| **origem** (autor / obra / obra suposta / bot) | `Corpus.pareceObra`, `Nota.origem` | importação deduz; **«nenhuma tela muda a origem de uma nota»** (dívida da ADR 16a) | etiqueta «obra», «parece obra» |
| **degrau** do que a sábia cobra | `Degraus.instigar(g, sinais:)` (`Sessao.swift:1064`) | sobe com a prática (sinais) | Perfil, «O que a sábia cobra, por forma» |
| **Retrato** ligado/desligado | `Retrato.ligado` (UserDefaults, `Retrato.swift:35-38`) | o autor, por um interruptor no Perfil | sim, e é um controle de painel anterior à 14a |
| **conteúdo do Retrato** | `Retrato.ler` (`Retrato.swift:43-115`) | algoritmo, com teto de 1.500 caracteres | Perfil, «O retrato, exatamente como viaja» (`PerfilView.swift:181-186`) |
| **pesos do conselho** | `Conselho.pesos` (aquém ×0,6, igual ×1, além ×1,25) | o saldo que o autor escreve na volta (ADR 16e) | **não**: «nada aparece ao autor» |
| **quem responde cada operação**, modelo medido, esforço | `Politica.linha` (`Politica.swift:83-150`) | o desenvolvedor, só com medida (`porque` datado) | Perfil lista as indisponíveis com `motivo` |
| **tetos** | Notas 16.000 (`Sabia.swift:287`); Retrato 1.500; aparelho 3.500 (`Sabia.swift:1311`); contexto da página 5.000 (`:806`); vizinha 600 (`Sessao.swift:565`); título 80 (`FonteNotas.swift:31`); resposta 900; escolha 30 candidatas × 200 caracteres (`Sessao.swift` 16k) | constantes no código | só como «Contexto parcial» e «leu N notas suas e M obras» |

O que o Traço já faz melhor que o Atlas: **todo parâmetro de provedor carrega a prova junto** (`Linha.porque`, `medidaEm`, `conserto`). É o recibo de parametrização que o Atlas pede. O defeito é de forma: o `porque` é prosa de ADR com milhares de caracteres dentro do Swift (`Politica.swift`, `.contrapor`), e a medida não é um dado consultável.

Dos «parâmetros escondidos» da VISÃO (gesto, domínio, origem, liga; função; «se encantar → / se travar →»), só a forma e a origem de obra chegam ao modelo, e a forma chega apenas pelo nome dos campos (16k). **Domínio e liga não viajam em nenhum pedido.** Achei `funcao` só no nível do método (`Metodos.json`, `"funcao": "pratica"`), não por nota. O par «encantar/travar» não aparece no modelo de dados.

---

## 3. Onde o Traço perde contexto e onde manda demais

### 3.1 Perde

**P1. Campos sem rótulo: consertado numa rota, vivo em outras cinco.**
Causa conferida em `prova/16k/LEIA.md`, V3: `VozDoAutor.juntar` (`VozDoAutor.swift:26-37`) junta **só os valores** dos campos. No `real-01`, «Dar 20% de desconto» (o que estava em jogo) e «Não dar desconto e oferecer um bônus» (o decidido) chegaram como duas linhas em conflito, 3 de 3 no Air. O conserto, `Sessao.textoRotulado` (`Sessao.swift:738-748`, ainda não commitado), só entra por `fonteParaPergunta`, ou seja, **só na rota das Notas**. O mesmo formato sem rótulo continua em:
- **Conselho → Grok** (`escolherRegra`): `Conselho.consulta` junta `escolha`, `opcoes` e `criterio` com `\n`, sem rótulo (`Conselho.swift:30`), e manda como `"situacao"` (`Conselho.swift:197`);
- **Padrões → Grok** (`soGrok`): `vozes = abertas.map(\.vozDoAutor)`, até 12 notas, sem rótulo **e sem data** (`PadroesView.swift:127-131`);
- **Trabalho**: `DocumentoTrabalho(intencao: nota.textoDeQualquerOrigem, …)` (`PaginaView.swift:562`), que alimenta produzir, conferir e revisar (`OficinaTrabalho.swift:263-294`);
- **Recordar**: `VozDoAutor.juntar(texto:campos:)` (`RecordarView.swift:45, 144`);
- **dentro do próprio conserto**: campos fora do método e o `sentido` («o que ficou claro») entram **sem rótulo** (`Sessao.swift:745-746`).

A lição secundária da 16k já está no código e precisa ficar em todas as rotas: **o rótulo vai ao modelo, mas não entra na pontuação lexical** (`Sessao.swift:824`: «"decidi" casava "O que estou decidindo" em toda Decisão»).

**P2. Página: a pergunta não leva os campos da forma.**
`let pagina = Caderno.prosa(de: texto)` (`Sessao.swift:642`). `Caderno.prosa` lê só os blocos do markdown (`BlocoCaderno.swift:615`), e os campos moram em `campos`. As vizinhas também vão só como prosa, cortadas em 600 caracteres (`Sessao.swift:564-565`). Uma Decisão vizinha chega **sem o «Decidi»**. A rota `responder` está cortada por qualidade, e a própria linha da `Politica` diz que «a alavanca seguinte da ordem da Astra é o CONTEXTO» (`Politica.swift`, `.responder`). Esta é a parte do contexto que falta.

**P3. Retrato sem proveniência, sem tipo e com pessoa trocada.**
- Nenhuma linha diz **de quando** nem **de qual nota** veio (`Retrato.swift:61-103`). A VISÃO manda «manter fonte, contexto e atualidade» e «distinguir observação, relato e hipótese».
- Mistura três tipos sem marcar nenhum: **contagem** («Formas nos últimos 30 dias»), **relato literal** («Obstáculos internos que já nomeou: “…”») e **leitura por palavras**. A calibragem, quando o saldo está vazio, decide aquém/além por regex sobre «aconteceu» (`Retrato.swift:133-150`), e sai no mesmo tom de fato: «ficou aquém… em N».
- A pessoa e o gênero variam dentro do mesmo pedido: o rótulo diz «evidência do caderno **dela**, nas palavras **dela**» (`Sabia.swift:696`), um bloco diz «nas palavras **dele**» (`Retrato.swift:102`) e outro diz «Resultados que **você** informou» (`Retrato.swift:83`). O mesmo pedido das Notas manda o modelo «Não flexione gênero para a pessoa» (`semGenero`, ADR 16k). É contexto contradizendo instrução.

**P4. Corte do Retrato sem recibo.**
Com mais de 1.500 caracteres, `String(texto.prefix(teto)) + "…"` (`Retrato.swift:113`). Os blocos do fim (palavras conquistadas, calibragem) somem ou chegam cortados no meio da citação, e ninguém registra o que caiu. É o oposto do `must_keep` e do `discarded_reason` do Atlas.

**P5. Omissão sem nome.**
`Pacote.omitidas` é um inteiro (`FonteNotas.swift:89`). Nota que não coube, Retrato que não coube e catálogo que não coube somam no mesmo número (`FonteNotas.swift:167, 174, 207`). O autor recebe sempre a mesma frase: «algumas notas ou informações auxiliares não couberam» (`FonteNotas.swift:336-338`). Nem a sonda sabe **o quê** caiu. O Atlas pede `excluded_refs` com motivo e «report truncation».

**P6. Parâmetros que existem e não viajam.**
O domínio (identidade da nota desde a 14a) não entra em nenhum pedido. A origem só viaja quando é obra (`FonteNotas.swift:156`). Uma nota do bot entra na rota das Notas com a origem só **no título** (« · feito pelo bot», `Sessao.swift:756`, `Nota.swift:21`), que é cortado em 80 grafemas. A ADR 16a já registrou que a etiqueta pode cair nesse corte.

### 3.2 Manda demais

**D1. O catálogo inteiro de formas em toda pergunta nas Notas.**
`Catalogo.todos … "\(nome): \(definicao)"` (`Sessao.swift:919-920`): 28 métodos, cerca de 2.200 caracteres (conta por script sobre `Metodos.json`), em qualquer pergunta, inclusive «quando a mãe chega?». No pacote, o catálogo vem **antes** da obra (`FonteNotas.swift:171`). Ele disputa orçamento com o que responde a pergunta.

**D2. O Retrato em toda pergunta, sem relevância.**
`Retrato.ligado ? Retrato.ler(...)` (`Sessao.swift:916-918`). Até 1.500 caracteres de obstáculos WOOP e calibragem vão junto de qualquer pergunta. O Atlas ranqueia por escopo e anexa o motivo; o Traço anexa por regra fixa.

**D3. Nota escolhida pelo sentido vai inteira, sem teto por nota.**
As até 5 escolhidas vão «INTEIRAS e antes das outras fontes» (`Sessao.swift` 16k, `comNotasPeloSentido`). `caber` só compara com o teto global (`FonteNotas.swift:159-165`). Uma nota longa sozinha empurra o Retrato, o catálogo e as outras notas para `omitidas`. A obra já aprendeu o contrário: recorte em até 3 seções (`FonteNotas.swift:176-208`).

**D4. As instruções viram depósito de consertos.**
Cada defeito medido vira uma cláusula no `sistemaResponderNasNotas`, e a 16k injeta `vozDaObra` e `semGenero` **duas vezes** (geração e conferência; diff de `Sabia.swift:191, 228-229`). Parte desses consertos é de **contexto**, não de instrução. Com o pacote dizendo de quem é cada linha (`origem`, rótulo do campo, pessoa neutra no Retrato), a instrução encolhe. A ADR 10b já mediu que o prompt sozinho não fecha a rota `responder`.

---

## 4. Tornar os parâmetros visíveis e corrigíveis sem painel (ADR 14a)

A 14a proíbe painel e pergunta de escolha. Ela **não** proíbe corrigir, e já diz onde a correção mora: «o domínio é identidade; **corrigir mora no toque longo**» (item 6). O Traço já tem o padrão completo para o domínio: **valor inferido + correção no próprio objeto + trava do autor** (`Nota.soltarDominio`/`devolverDominio`, `Nota.swift:131-142`). É o que se generaliza, e casa com o contrato da Cartografia («long press explica»), sem trazer o mapa.

Princípios (o que o Atlas ensina, sem o peso do Atlas):

1. **Mostrar no ponto de uso, nunca numa seção de ajustes.** O cartão da resposta já diz «leu 3 notas suas e 1 obra» (`FonteNotas.swift:48-54`), e a ficha abre os cartões das notas. Essa ficha é o «exatamente como viajou». Ela deve mostrar a nota **com os rótulos que o modelo leu** («Decidi: …»), não a nota da lista.
2. **Toque longo explica a origem do que a IA fez.** No cartão do conselho: as palavras que ligaram (`Sinal.exposto.porque`, já gravado) e o saldo que pesou (`Sinal.resultado`). Não pede ação. É a camada «Essencial/Fluxo» do modal da Cartografia, em uma frase.
3. **A correção é um gesto no objeto e vale como trava.** O toque longo numa fonte ou numa linha do Retrato permite dizer «isto não vale mais». A inferência não volta por cima, como no domínio. Nada é perguntado; a pessoa corrige quando vê o erro.
4. **Escrever também é corrigir, e a correção já é dado vigente.** O pedido das Notas já trata a fala da pessoa como «dado vigente inclusive correção» (`FonteNotas.swift:128`). Não criar tela para isso: preservar e datar.
5. **A lacuna é dita, não calada.** Quando o que caiu importa (uma nota escolhida que não coube), a ficha nomeia a nota. Quando é auxiliar (catálogo), nada aparece ao autor e a sonda registra. Não é aviso genérico no fim da resposta.
6. **O que se mostra é idêntico ao que viaja** (Truth Guard). O Perfil já promete isso para o Retrato. A mesma função precisa montar o texto da tela e o do pedido. Uma diferença de rótulo entre `rotuloRetrato` (Sabia) e o bloco JSON «SOBRE QUEM ESCREVE (JSON; contexto auxiliar)» (`FonteNotas.swift:171-172`) já é drift.

O que **não** trazer: ACOS com 30 subsistemas, scorecard, 422, TTL de opt-in, JSONL de hash por pedido. O Traço é de um dono só num iPhone. O que serve é o contrato mínimo: **referência com motivo, recibo do que caiu, autoridade explícita e um serializador só.**

---

## 5 mudanças de contexto e parametrização para o Traço

**1. Um serializador só da nota para a IA, com rótulos, em todas as rotas.**
Mover `Sessao.textoRotulado` para junto de `VozDoAutor` (um lugar, como `FonteNotas` fez com o teto do título) e trocar os chamadores que hoje mandam valores soltos: `Conselho.consulta` (`Conselho.swift:30`), Padrões (`PadroesView.swift:127`), a intenção do Trabalho (`PaginaView.swift:562`), o Recordar (`RecordarView.swift:45`) e a página e as vizinhas da pergunta (`Sessao.swift:564, 642`). Rotular também o `sentido` («O que ficou claro: …») e os campos fora do método. A pontuação lexical continua lendo sem rótulo. *Régua:* um caso tipo `real-01` por rota (decidido × escolha), leitor cego, 3/3, sem regressão dos lotes 16i e 16k.

**2. Retrato com tipo, data e pessoa neutra.**
Cada linha diz o que é e de quando: contagem («Formas nos últimos 30 dias»), relato literal com data («“…” — 12/08») e leitura por palavras, nomeada como tal quando a calibragem veio por regex e não pelo saldo. Trocar «dela/dele/você» por forma neutra nos rótulos (`Sabia.swift:696`, `Retrato.swift:83, 102`), em linha com a `semGenero`. Cortar por **bloco inteiro**, nunca com «…» no meio de uma citação (`Retrato.swift:113`), e com ordem de prioridade declarada. O Perfil mostra o mesmo texto, com a mesma função.

**3. Orçamento por pertinência, não por regra fixa.**
Catálogo só com as formas das notas que viajaram, ou só quando a pergunta é sobre forma ou método (`Sessao.swift:919`). Retrato só com os blocos que dividem assunto com a pergunta, ou com teto menor quando nenhum divide (`Sessao.swift:916`). Teto por nota escolhida pelo sentido, com recorte por parágrafo como a obra já faz por seção (`FonteNotas.swift:176-208`). *Régua:* os lotes 16i e 16k sem regressão, e o tamanho médio do pacote medido antes e depois.

**4. Recibo do pacote, nomeado.**
`Pacote` passa a guardar o que ficou fora e por quê (`nota «título»: não coube`, `retrato: não coube`, `catálogo: fora do assunto`, `obra: fora do assunto`, `nota: selo mudou`) no lugar do inteiro `omitidas` (`FonteNotas.swift:89`). A sonda grava o recibo junto do `bruto`. A tela diz só o que importa ao autor (a nota dele que não coube, pelo nome) e larga a frase genérica de «Contexto parcial» (`FonteNotas.swift:336-338`). É o `compaction_receipt` do Atlas em quatro campos, sem hash.

**5. Correção no objeto: inferido + trava do autor, além do domínio.**
Aplicar o padrão `dominioTravado` (`Nota.swift:118-142`) a três parâmetros que chegam à IA ou ao autor:
- **origem**, pelo toque longo da nota («é minha» / «não é minha»), fechando a dívida da ADR 16a de que nenhuma tela muda a origem;
- **linha do Retrato**, pelo toque longo no Perfil («isto não vale mais»), que sai do Retrato até nova evidência;
- **conselho**, onde o toque longo no cartão explica, sem pedir ação, as palavras que ligaram e o saldo que pesou (`Sinal.exposto.porque`, `Conselho.pesos`).

Nenhum desses é painel ou pergunta: é o toque longo que a 14a já reservou para corrigir. *Prova:* teste de que a trava sobrevive à inferência seguinte, como os testes do domínio, e captura do toque longo em `large`.
