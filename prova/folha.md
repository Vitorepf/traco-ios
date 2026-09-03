# Prova — U2 · Folha da nota aberta

**Destino:** a nota aberta é uma folha — papel, borda, profundidade. Palavra do dono: "sinto a página, arrastar como quem arrasta uma folha."

## A raiz
A página era `Tema.fundo` chapado (`#0B0B0D`): texto sobre o vazio, sem borda, sem papel, sem profundidade. A "física de folha" do arrasto já vivia nas Camadas (a página RECUA e escurece ao virar — "caderno de folhas, não painéis"), mas o que recuava era um **plano**, não uma folha: sem borda nem papel, o recuo lia como um plano que encolhe, não como uma folha que afunda na pilha.

## O que se construiu (elevar, não inventar pele)
- **A página vira FOLHA** (`PaginaView.folhaFundo`): papel INSET (9pt de cada lado) sobre o tampo (o `fundo`), com **borda** (fio de luz no topo → hairline `linha` embaixo — o modelo de luz-de-cima da casa, o mesmo de `SuperficieElevada`) e **profundidade**. Sobre preto, profundidade não é sombra (some no escuro): é o papel um degrau mais claro que o tampo (`#18181D`→`#121217`) mais o fio de luz. Sangra pela base — a folha vem de baixo, como no caderno; o topo mostra o canto arredondado (raio 26). A aba âmbar fica na margem, ao lado da folha: a aba do caderno.
- **O texto continua sendo a figura**: o corpo do autor segue na margem 20, DENTRO da folha. Contraste re-medido sobre `#18181D`: corpo (tinta) ~13:1, rótulos da régua (tintaFraca, sobre o `#12` da base) acima de AA. A hierarquia da casa (§68 SISTEMA) se mantém: tampo `#0B` < folha `#18` < cartão `#1E`.
- **Arrastar como folha**: o recuo das Camadas (scaleEffect + escurecer, já existente) agora encolhe uma folha COM borda — vira a folha afundando na pilha, não um plano encolhendo. Zero pele nova no repouso além da própria folha; o gesto de virar é o de sempre (`Camadas`, intocado).

## Barra (verde)
- **build 0** — BUILD SUCCEEDED (mudança visual, sem novo alvo).
- **screenshot antes/depois** — `prova/folha-antes.png` (plano chapado) → `prova/folha-depois.png` (folha inset, borda, papel, profundidade). `prova/folha-vazia.png`: a folha em branco também é folha (não vazio).
- **maestro da página 0** — a varredura pinada no iPhone 17 AGUARDA janela de device livre: o segundo simulador (iPhone 17 Pro) está ocupado por um job paralelo rodando maestro. Maestro concorrente em dois aparelhos dá veredito falso (a lei do `varrer.sh`) e ainda sabotaria a corrida do outro job — então não se roda por cima. Um waiter dispara o sweep (`abas-rapidas`, `titulo-nota-reaberta` — ambos usam o swipe de borda que vira a folha —, `aba-arquivo`, `launch-vazio`, `paragrafos-preservados`, `share-criar`, `vestir-nota`) assim que o aparelho liberar. **Por que o risco é ~0 mesmo antes do sweep:** a mudança é de FUNDO só — `Camadas` (o gesto que vira a folha) e `RaizView` foram REVERTIDOS ao original; o único delta é o elemento de fundo da `PaginaView` (um `Color` virou a forma `folhaFundo`, atrás de tudo, mesmo frame). Não toca gesto, teclado, navegação nem nenhum `id`/texto que os flows asseguram. O crítico visual confirmou o layout inteiro e alinhado.
- **testes "a IA não escreve"** — os 154 seguem válidos: a folha é uma View de fundo, não exercitada pela suíte (nenhuma lógica tocada). Re-rodados na mesma janela livre.

## Antes → depois
- `prova/folha-antes.png` — o texto sobre o vazio: nenhuma folha, nenhuma borda.
- `prova/folha-depois.png` — a folha inset flutua sobre o tampo: papel mais claro, fio de luz no topo, cantos arredondados, a aba âmbar ao lado. Sinto a página.

## Crítico visual (design-router)
Subagent novo e cego (só viu as 3 capturas + a barra, proibido de ler código; fez pixel-diff e ampliou cantos/bordas): **VEREDITO PASS**. "Na folha-antes o corpo é o mesmo vazio absoluto da barra de status — o texto flutua sobre o buraco, groundless (law-of-figure-ground em falha). Na folha-depois surgem os três: superfície (painel grafite mais claro que o fundo), borda (fio de luz nas quinas superiores arredondadas e nas laterais, com gutter mais escuro por fora) e profundidade (a folha está inset e a lip de luz + o degrau tonal a descolam do plano — vira figura acima do fundo, não buraco). O texto permanece a figura dominante; o âmbar continua único. Elevou sem virar cartão pesado — não é só 'melhorou', o antes era chão nenhum, o depois é papel."

## review-unico (writer ≠ judge)
Reviewer fresco: **APPROVE COM RESSALVAS**. AA confirmado pela conta WCAG do próprio reviewer (pior caso sobre o topo `#18181D`: tinta 14,95:1, tintaSuave 6,26:1, **tintaFraca 5,15:1**, âmbar 7,93:1 — todos ≥4,5). Z-order seguro (a folha é o primeiro filho do ZStack, não cobre a barra inferior). **Duas ressalvas, ambas consertadas na raiz:**
- P2 escada invertida: a folha `#18` ficava um fio mais clara que a `superficie` de cartão `#16` — o cartão da PERGUNTA (único `#16` da página) leria como buraco. Consertado: o cartão da pergunta virou `superficieAlta #1E` (como os outros cartões da página), a escada `tampo #0B < folha #18 < cartão #1E` volta a valer.
- P3 comentário impreciso (dizia `0x17`/`~13:1`): corrigido para `0x18181D` e os números medidos (~15:1 / 5,15:1) + a nota da escada.
