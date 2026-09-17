# prova/e6 — segundo cérebro: notas que se ligam (`ecos`). Régua registrada em 17/09/2026, ANTES do código

**Plano do líder (E6):** remedir `ecos` COM o bruto (`chamadasGrok[].bruto`), para separar lista vazia do modelo de lista derrubada pela `GuardaDeEcos`; alavanca candidata a da 16g/V2 (as palavras escolhem as candidatas, o modelo escolhe entre elas). Nunca escreve `[[…]]` pelo autor (a ligação continua sendo o toque dele na folha).

**Por que está cortada** (`Politica`, 08/09): 3 de 6 casos; devolveu `[]` onde o vínculo mais serve (18 inscritos contra a sala de 15) — perde o vínculo por consequência.

**Casos (escritos ANTES do código):**
- os 6 de `ecos` de `prova/q-qualidade-casos.json` (sha `29654d46…`), com as esperadas lidas dos requisitos: `q5-ecos-sentido-e-contradicao` [0, 2], `qn-ecos-relacao-por-consequencia` [0, 2] (18 inscritos × sala de 15), `qn-ecos-duas-relacoes-e-distratores` [0, 2], `qn-ecos-nota-curta` [0, 2]; controles `q5-ecos-coincidencia-lexical` e `qn-ecos-sem-relacao-legitima`;
- os 9 de `casos-novos.json` (sha `3279f7ef…`), **SINTÉTICOS**, escritos por agente cego ao código e sem acesso a caderno nenhum (o arquivo antigo de 16/09, derivado do caderno real, foi tirado do repositório por ordem do líder): 7 com vínculo (13 a 17 candidatas; em 5 a nota nova não repete palavra de 4+ letras da esperada) e 2 controles.
- Juntos em `lote.json` (sha `82590cdd…`, 15 casos × 3), esperadas em `esperadas.json`: 11 com vínculo, 4 controles.

**Régua (3 repetições):**
1. **Vínculo:** em cada repetição, as esperadas TODAS devolvidas em ≥ 5/6 dos 11 casos com vínculo — **≥ 10 de 11**.
2. **Literal:** zero trecho devolvido que não seja literal da candidata (conferido no bruto, antes da guarda).
3. **Controles:** os 4 devolvem `[]` nas 3 repetições.
4. Registrado sem barra: candidata que só divide palavra devolvida; vazio do modelo × vazio da guarda (pelo bruto).

**Passou:** a linha de `ecos` sai de `indisponivelPorQualidade` com o medido no `porque`, e a folha «Notas ligadas» volta a mostrar «Talvez se liguem». **Não passou:** registrar o medido com o bruto e parar.

**Achado na leitura do código, antes da medida:** a folha «Notas ligadas» (`RedeView.montarCandidatas`) manda ao modelo as PRIMEIRAS 40 notas de um fetch sem ordem — não as mais próximas da nota; e o contexto da Página (`Sessao`) ordena por `Indice.vizinhas`, que no simulador não tem índice de sentido (memória: NLEmbedding PT nil) e cai em "todas". A alavanca da 16g entra aí: as candidatas escolhidas pelas palavras da nota, e o modelo escolhe entre elas.

**Ordem:** primeiro a LINHA DE BASE no Air (a rota como está, liberada só na sonda, com o bruto), depois o conserto que o bruto apontar.

## Linha de base (corrida `E2DB2B60`, grok-4.3 — o modelo da produção —, dylib `205891b4…`, `base-grok.jsonl`)

Pelo JSONL, por repetição: **vínculo (todas as esperadas) 8, 7, 7 de 11** (barra ≥ 10); pelo menos uma esperada 8, 8, 8; trecho não literal **0**; controles vazios **4/4** nas 3; candidata a mais 0. **O bruto é igual à saída** em todas as 45: a `GuardaDeEcos` não tirou nada — o vazio é do MODELO. Falhas: `qn-ecos-relacao-por-consequencia` (18 inscritos × sala de 15) nas 3 (uma só esperada na rep 3); `qn-ecos-nota-curta` (café depois das quatro → sono) nas 3; `qn-ecos-duas-relacoes-e-distratores` (o mesmo padrão) em 2; `e6-07` (compromisso anotado noutra nota) em 2; `e6-04` (o mesmo padrão, duas esperadas) uma pela metade.

**Causa lida no pedido:** `sistemaEcos` pede só as que "falam da MESMA coisa que a nota" e manda "Na dúvida, menos — ou nenhum"; a lista do que conta ("o tema que volta, a mesma decisão com outro nome, a tese que uma contradiz na outra") não tem consequência, padrão que se repete nem compromisso ou prazo anotado noutra nota — exatamente os que caíram. As candidatas desses casos são ≤ 17: o corte das 40 da folha não é a causa AQUI (é defeito de produção, consertado junto).

**Braço A, sem código (registrado antes da corrida):** o mesmo binário e o mesmo pedido no `grok-4.5` (`TRACO_AVALIAR_MODELO`), mesmo lote, mesma régua — para separar modelo de pedido antes de mexer no pedido.

## Braço A — medida (corrida `E735647B`, grok-4.5, mesmo binário e pedido, `bracoA-grok45.jsonl`)

Vínculo **9, 11, 10 de 11** (a rep 1 fica abaixo da barra); pelo menos uma esperada 10, 11, 11; trecho não literal **0**; controles vazios **4/4** nas 3; bruto igual à saída. Sobram: `qn-ecos-relacao-por-consequencia` devolve só o índice 0 (o limite da sala) e perde o 2 (a alternativa ainda não confirmada) nas reps 1 e 3; `e6-07` vazio na rep 1. **O modelo é a maior parte da alavanca; o pedido ainda não nomeia consequência nem compromisso anotado noutra nota.**

## Volta 1 — conserto (registrado ANTES do código e da corrida)

(1) `Sabia.ecos` chama no `modeloMedido` (`grok-4.5`), como as Notas. (2) `sistemaEcos`: a lista do que conta como vínculo passa a nomear, além do tema que volta, da mesma decisão com outro nome e da contradição, **a consequência** (o que a nota faz esbarra no que a outra fixou — limite, prazo, compromisso, alternativa ainda em aberto) e **o mesmo padrão que se repete**; nenhuma instrução nova sobre uma forma de frase; o resto do contrato (no máximo 3, trecho literal de 8 a 120, coincidência de vocabulário não é eco) fica. (3) Produção: a folha «Notas ligadas» e o contexto da Página escolhem as candidatas num ponto só — as até 30 de `Sessao.candidatasDoAutor` (palavras da nota primeiro, depois as mais recentes), sem a própria nota e sem as já ligadas —, no lugar das 40 primeiras da lista; teste com a nota ligada fora das 40 primeiras. (4) E6b (depois): o parser já ignora chave extra — o `tipo` da relação cabe no esquema sem ser pedido nem medido agora.

Mesmo lote, mesma régua. Passou: `ecos` sai de `indisponivelPorQualidade` com o medido no `porque`. Não passou: registrar e parar.

**Condições do líder para a volta 1 (registradas antes da corrida):** (1) **casos reservados** — 4 escritos por outro agente cego, sem ver o pedido nem os casos atuais (3 com vínculo: consequência, padrão, compromisso noutra nota, com palavras diferentes; 1 controle), em `casos-reservados.json`; a barra vale para os atuais (≥ 10 de 11, zero não literal, controles 4/4) E para os reservados (≥ 2 de 3 com vínculo em cada repetição, controle vazio nas 3). (2) **molde** — contar no bruto, lado a lado (base, braço A, volta 1), as palavras da lista do pedido novo (limite, prazo, compromisso, alternativa, em aberto, consequência, padrão) nos itens devolvidos; se saltarem, é molde e reprova. A resposta de `ecos` não tem texto livre (só `i` e `trecho` literal): na base 33 itens, 1 palavra da lista ("alternativa" ×3, copiada da candidata); no braço A 49 itens, "alternativa" ×3. (3) **candidatas só do autor** — obra e nota do bot fora (a sugestão é entre notas suas); selada e expressiva também, com teste que acusa (`seladaExpressivaObraEBotNaoSaoCandidatas`).
**Casos reservados:** `casos-reservados.json` (sha `8ec4ddc5…`), agente cego sem ler arquivo nenhum do repositório: `e6r-01` consequência (conserto por vizinho × garantia que cai) [7]; `e6r-02` padrão (compra de madrugada depois de aperto) [1, 8]; `e6r-03` compromisso noutra nota (viagem × cuidar do cachorro) [10]; `e6r-04` controle (afinar o violão). Lote da volta 1: `lote-volta1.json` (sha `587f18f7…`) = os 15 do `lote.json` + os 4 reservados, × 3.

## Volta 1 — medida (corrida `00CB3A1A`, grok-4.5 pela produção — `modeloMedido` —, dylib `e2102f21…`, `volta1-grok.jsonl`)

**Atuais (15):** vínculo **10, 10, 10 de 11** ✓; trecho não literal **0** ✓; controles vazios 4/4, 4/4 e **3 de 3 + 1 erro** (`e6-09` rep 3: `semRetorno`, desfecho "transporte", HTTP 200 sem corpo em 4 s). A única falha de vínculo é `qn-ecos-relacao-por-consequencia`, que devolve o limite da sala (0) e não a alternativa em aberto (2) nas 3. **Reservados (4):** vínculo 3/3, 3/3 e **2 de 2 + 1 erro** (`e6r-01` rep 3: "transporte", sem status, em 0,02 s); controle vazio nas 3 ✓. **Molde:** 59 itens no bruto, palavras da lista "alternativa" ×3 (copiada da candidata) — igual à base e ao braço A.

**Leitura pela régua:** o vínculo, o literal, os reservados e o molde passam; os controles, pela letra, não — um controle com erro de transporte não "devolveu vazio". Não conta como passou. **Registrado ANTES de repetir:** a corrida inteira roda de novo, mesmo binário e mesmo lote (`587f18f7…`), e as DUAS vão no relatório; passa só se a repetida cumprir a régua inteira, controles incluídos. Dívida de produção nomeada: `ecos` não repete a chamada na falha de transporte (o `responder` repete uma vez) — a folha fica sem sugestão.

## Volta 1 repetida (corrida `182DBCC3`, mesmo binário e lote, `volta1-repetida-grok.jsonl`)

**Atuais:** vínculo **10, 10, 10 de 11** ✓; não literal **0** ✓; controles: todos os que responderam vieram vazios (4/4, 3/3 + 1 erro de transporte em `q5-ecos-coincidencia-lexical` rep 2, 4/4); candidata a mais 1 (`qn-ecos-relacao-por-consequencia` rep 1 devolve [0, 1]). **Reservados:** vínculo 3/3, 3/3, **2/3** ✓ (`e6r-02` rep 3: o modelo devolveu [1, 8], mas o trecho da 8 tinha **121 caracteres** — literal, fora do contrato de 8 a 120 — e o parser o tirou); controle vazio nas 3 ✓. **Molde:** 61 itens, "alternativa" ×3 — igual às outras três corridas.

**Leitura do líder para os controles** (17/09): o controle conta só o que a Sábia ESCREVEU — erro de transporte não é vínculo inventado. Por essa leitura, **as duas corridas da volta 1 cumprem a régua inteira**: vínculo ≥ 10 de 11 nas 6 repetições, zero trecho não literal, controles sem vínculo em toda resposta escrita, reservados ≥ 2 de 3 e controle vazio. **Passou.** Pendentes para fechar: revisão adversarial do código, a linha de `ecos` na `Politica` (texto de tela pelo líder), a captura da folha «Notas ligadas» mostrando «Talvez se liguem».

**Dívidas nomeadas (líder, 17/09):** (1) a alternativa ainda em aberto da oficina (`qn-ecos-relacao-por-consequencia`, índice 2) não vem em nenhuma das 6 repetições — só o limite da sala; (2) a falha de transporte não é repetida no `ecos` (o `responder` repete uma vez) — 3 casos em 114 chamadas ficaram sem resposta nas duas corridas; (3) o trecho literal de 121 caracteres derruba a sugestão inteira — cortar no limite de palavra dentro de 120 (guarda que corta, não que cala), sem mudar esta medida. **Textos de tela (líder):** `Politica.nome(.ecos)` = "sugerir notas que se ligam"; `semProvedor(.ecos)` = "Sugerir notas que se ligam precisa da sua conta Grok (em Perfil)." — o ecos acha consequência e padrão, não só parecença, e se separa do «Parecidas» local do juntar da nota viva.

## Revisão adversarial e a seleção de candidatas (17/09, antes do commit)

**Corrigi o meu diagnóstico:** a folha NÃO mandava "as 40 primeiras de um fetch sem ordem" — `todas` vem do `@Query` ordenado (NotasView por `criadaEm`, PaginaView por `editadaEm`, do mais novo): eram as 40 MAIS RECENTES. Só o contexto da Página usava fetch sem ordem.

**Defeito achado na troca por `candidatasDoAutor`** (as até 30 que dividem palavra de 4+ letras com a nota, depois as recentes): o vínculo por consequência ou padrão quase não divide palavra. Rodando a pontuação real sobre os 219 candidatos do lote juntos, em 13 dos 14 casos com vínculo alguma esperada pontua 0, com até 66 notas na frente; na nota longa as palavras vazias dominam (a sem relação pontua 11, a certa 1). **A medida desta volta NÃO passou por seleção nenhuma:** a sonda entrega listas prontas de 13 a 17 — o que ela provou é o pedido e o modelo. Também: as versões juntas da nota viva viravam sugestão, e a pontuação custava 0,5 a 1,4 s no main thread.

**Decisão do líder:** a produção fica com o que a folha já fazia, num ponto único (`Sessao.candidatasDeEcos`): as **40 mais recentes** por edição, só notas do autor que se leem, sem a própria, sem as já ligadas e sem as versões juntas; a folha e o contexto da Página chamam esse ponto (o fetch sem ordem acaba); sem pontuação. **A seleção de produção NÃO foi medida pela IA.** Testes: com 41 soltas a mais antiga fica fora e a mais recente entra; a versão junta e a já ligada não entram; obra, bot, selada e expressiva não entram; a folha e a Página chamam o mesmo ponto.

## E6c — registrada ANTES (a volta seguinte)

A sonda passa PELA seleção real: caderno sintético de ≥ 200 notas, escrito por agente cego, com os vínculos esperados espalhados no tempo (recentes e antigos) e nota longa; dois braços no mesmo binário — 40 recentes × 20 recentes + 20 pelas palavras raras. Barra: vínculo esperado entre as candidatas E na resposta, zero trecho não literal, controles vazios e seleção em < 50 ms com 400 notas. Só o braço que passar vai para a produção.

**Dívida (líder): quem mais chama `candidatasDoAutor`** — a mesma falha de palavras vazias em nota longa pode afetar: `Sessao.swift` (a pergunta nas Notas, `comNotasPeloSentido`, as candidatas à escolha pelo Grok), `AvaliacaoIA.swift` (a sonda das Notas, mesmo caminho) e `ConsultarObrasTests.swift` (teste). Não consertado agora.
