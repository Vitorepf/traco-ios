# Revisão G3 — volta 7: integridade e selo nas rotas restantes (ADR 2026-09-05s)

Revisor: Claude Fable 5.1, sessão independente, 05/09/2026. Branch `Vitorepf/volta-7-integridade`, commit 30c3ef0 sobre main 41b2605; merge-tree contra main d4d98da: **sem conflito**. Instrumento: iPhone 17e `C7341E64-3A33-4ADD-AF6C-9296215FAD09` (liguei, usei, desliguei; content size devolvido a `large`); tudo por `com-trava.sh`. Nenhum código editado, nada commitado.

## Veredito: CORRIGIR ANTES (uma dimensão em 8)

Lista mínima:

1. **Privacidade e autoria (8)** — `trancarESair` e `abrirFecho` chamam `pararTimer()` ANTES de `salvar(trancar: true)`. Com o disco recusando, a guarda nova mantém o texto (certo), mas o relógio já morreu: `timerLigado = false`, `timerPrazo = nil`. A gravação automática seguinte (cena ao fundo, `PaginaView:201`; troca de aba, `irPara`) calcula `prazo = nil` e grava `expressivaPrazo = nil` no disco quando ele volta a aceitar. Resultado: a expressiva fica aberta sem prazo, e `trancarExpressivasVencidas` nunca a sela — a garantia do §8 ("o selo não depende de o autor responder") some justamente na rota que a volta corrigiu. Em main o defeito já existia em `abrirFecho`; em `trancarESair` é novo, porque antes a página virava e o prazo persistido sobrevivia. Não vaza para projeção nenhuma (`nuncaSai`/`podeEntrar` olham gesto e fechada, não prazo) — é a tranca automática que se perde. Correção mínima: mover `pararTimer()` para depois do `guard salvar(...)` nas duas rotas (o relógio continua, `esgotarTimer` tenta de novo, e a gravação automática leva `timerPrazo`), mais um teste com `timerLigado = true`, recusa e depois sucesso, esperando `expressivaPrazo != nil` ou `trancada`.

Recomendado junto (não bloqueia sozinho):

2. **Estado honesto** — a linha fixa "Não consegui guardar agora…" é substituída por QUALQUER `mostrarToast` sem `fixo` (31 chamadas: "N notas vieram de fora", "não consegui trancar", "revisões precisam de permissão"…), que zera `toastFixo` e apaga o toast em 2,5 s. A ADR diz que a linha "só some quando um `salvar` grava"; o código não garante. Um `guard !toastFixo || fixo` (ou reexibir a fixa depois da transitória) fecha.

## Scorecard

| dimensão | nota | evidência |
|---|---|---|
| Visão | 9 | Ciclo multiplicar ("a nota nunca se perde; o protegido nunca vaza"). Fecha a lacuna nomeada na linha "Preservar escrita…" do EVOLUCAO ("Demais rotas de commit, projeções concorrentes, selo e recuperação no aparelho") e parte de "ordenação backups/Spotlight/índice" na linha de privacidade. Diff do EVOLUCAO linhas 7 e 16 confere com o código. |
| Contrato | 9 | Tabela da ADR 05s conferida rota a rota contra o diff de `Sessao.swift`: as sete linhas descrevem o que o código faz (versão/widget/índice depois do `persistir`; `guard` em `trancarESair`; `persistir` com rollback em `apagar`/`desfazerApagar`; `projetarTudo` em `importarCorpus` e `desfazerApagar`; `restaurar` registra depois). Custo nomeado (trava global, `isWritableFile`). Duas frouxidões, não inflação: a decisão diz "nem aviso" e o Custo diz "avisos fora do contrato" — `aplicarGatilho`/`continuarSerie` ainda agendam `Revisoes` antes do commit, então vale a segunda frase; e "só some quando um salvar grava" (achado 2). "Fora" honesto. |
| Correção | 9 | Suíte integral no C7341E64: `✔ Test run with 639 tests in 122 suites passed after 8.516 seconds.` `** TEST SUCCEEDED **`; 0 avisos de compilador (`grep -c "\.swift:[0-9]*:[0-9]*: warning"` = 0; os únicos "warning" do log são runtime do simulador: `_UIBackdropView`, `CHHapticPattern`). Os 17 testes novos passaram nominalmente. Maestro no C7341E64 (direto com `--device`, porque `varrer.sh` recusa com 3 simuladores ligados): busca, caderno-gravar, aba-arquivo, auditoria-nav, expressiva-trancar **passaram**; versoes.yaml falhou 3× no passo `openLink traco://notas` por causa do diálogo do sistema "Abrir com Traço?" (simulador recém-instalado; captura em scratch) — a mesma jornada com a navegação por gesto no lugar do deep link **passou** (`v7-rev-versoes-gesto.png`, "1 versão" na tela). Duas execuções iniciais mostraram lista vazia após Concluir, com `CoreData: Sandbox access to file-write-create denied` no arranque pós-`clearState`; nas 4 execuções seguintes a nota persistiu (1 linha em `ZNOTA` a cada vez) — flake da reinstalação no simulador, não atribuído ao branch. Ordem forçada determinística: os dois testes de concorrência chamam as funções síncronas com `geracao` explícita (3→2→1; 1, remover 3, 2, 2, 4), sem `sleep`. Cobertura da tabela: salvar, trancarESair, trancarExpressivasVencidas, apagar/desfazerApagar, importarCorpus, restaurar — todas com recusa injetada. Achado 1 não tem teste (o teste de `trancarESair` roda sem `timerLigado`). |
| Jornada real | 9 | `v7-rev-perfil-indisponivel.png`: linha "iCloud indisponível; guardando só no aparelho" entre a linha "Espelhar numa pasta" e a nota de rodapé (encenada com `defaults write app.traco pasta-espelho-estado`). `v7-rev-perfil-indisponivel-xxxl.png`: mesma linha em `extra-extra-extra-large`, sem clipe, duas linhas. `v7-rev-perfil-normal.png`: sem a linha. `v7-rev-recusa-pagina.png`: banco do App Group em 444/555, texto "texto que nao pode sumir" digitado, toque na aba de arquivo → a página não vira, cartão "Não consegui guardar agora. O texto continua aqui." `v7-rev-recusa-fixa.png`: ~1 min depois, a linha continua e o texto também. A volta ao normal em processo não foi encenável (a conexão SQLite aberta só-leitura não reabre; fica provado por `salvarRecusadoMantemOTextoEALinhaFicaAteGravar`). Conteúdo conferido a olho, não só o arquivo. |
| Design | 9 | Nada de tela nova; duas linhas de texto com tokens (`Tema.meta`/`Tema.tintaSuave`; o cartão do toast já existia). Observação para volta futura, não bloqueio: como linha FIXA, o cartão do toast (padding inferior 88 pt) passa a cobrir permanentemente a borda superior da pílula "Trabalhar nisto" (visível em `v7-rev-recusa-pagina.png`); uma falha que fica merece lugar no fluxo, não sobreposição. |
| Simplicidade | 9 | Telas 0 → 0, opções 0 → 0, passos do caminho comum inalterados; onde havia silêncio (toast de 2,5 s, espelho mudo) há uma linha. |
| Movimento | n/a | Nenhuma animação nova; a linha usa a transição existente do toast (`.opacity`, 0,2 s). |
| Componentes | n/a | Nenhum componente criado ou alterado. |
| Acessibilidade | 9 | Linha do Perfil com `accessibilityIdentifier("estado-espelho")`, fonte dinâmica, XXXL sem clipe (captura). Linha da recusa: `AccessibilityNotification.Announcement` no `mostrarToast`, `.isStaticText`. Nenhum alvo novo. |
| Performance | 9 | Sem tela de lista/editor/parser tocada; sem Instruments. Custo real e nomeado: `Corpus.ordem` (NSLock) faz a varredura síncrona na main esperar um `escreverUma` em voo; antes as duas já corriam e a síncrona já estava na main — o acréscimo é a espera, limitada a um `.md` e três agregados. `Indice.geracoes` e `Corpus.gravadas` crescem um inteiro por nota/arquivo, nunca zerados fora de testes — desprezível. |
| Privacidade e autoria | **8** | Matriz conferida: índice (`paraIndice.podeEntrar` nos 4 estados), Spotlight (`Holofote.lote` nos 4), widget (aberta grava, trancar apaga, expressiva em curso e queimada nunca), contexto da sábia (4 estados, pior caso com todas no índice), export completo (4), `.md` por nota (em curso não existe; selada só metadado — queimada por nota não está neste arquivo, mas `soMetadado` é o mesmo ramo e o agregado tem prova em `NotasESessaoTests`), import (`IntegridadeCorpusTests`). Relógio lógico: todos os chamadores de produção passam `geracao` (`Indice.remover/atualizar/sincronizar` ×7, `Corpus.backupDeUma/escreverEspelho`, `Holofote.indexar` com contador próprio, MainActor por isolamento padrão do projeto). `Indice.sincronizar` preserva a entrada existente quando a geração recusa e nunca ressuscita nota removida por geração maior — provado. `Corpus.avanca` protege `.md` por nota e agregados, alvo a alvo; a varredura velha não apaga `.md` novo — provado. **Achado 1** derruba a nota: a recusa em `trancarESair`/`abrirFecho` deixa a expressiva sem relógio e a gravação seguinte apaga o prazo persistido. |
| Estado honesto | 9 | Linha na tela, fixa, texto intacto (capturas). Toast antigo de 2,5 s virou linha fixa apenas para a recusa de `salvar`; as outras recusas (trancar, apagar, queimar, restaurar, sentido, importar) continuam toasts transitórios — aceitável, cada uma mantém o estado ("a nota continua"). Achado 2: outra mensagem transitória pode apagar a linha fixa sem gravação. |
| Complexidade | 9 | `git diff --shortstat`: 10 arquivos, +656/−89; código de produção 6 arquivos, +218/−87 (líquido +131) — um enum `Geracao` (12 linhas), dois `avanca`, um `projetarTudo` que substitui três blocos repetidos, uma chave de UserDefaults, 7 linhas de view. Testes +386, SPEC +46, EVOLUCAO ±4. Sem dependência nova, sem arquivo de produção novo. Justificado pela lacuna. |
| Fora do app | n/a | Nenhuma superfície nova; o widget (Destaque) só mudou de ordem (grava depois do commit) e tem teste. |
| Relato | 9 | Relato do implementador com tabela rota a rota, matriz célula a célula, números literais (17/639/122), "fica de fora" honesto (avisos, haptics, captura do espelho). A captura "não encenável" era encenável no simulador de teste com maestro — feita aqui. |

## Achados por severidade

- **MÉDIO (corrigir antes):** achado 1 — relógio da expressiva morre antes do commit recusado; próxima gravação apaga `expressivaPrazo`. `Sessao.swift` `trancarESair` (linha 1639) e `abrirFecho` (880). Fix: `pararTimer()` depois do `guard salvar`. Teste sugerido em `IntegridadeRotasTests`.
- **BAIXO (recomendado junto):** achado 2 — linha fixa apagável por toast transitório. `mostrarToast` (1737).
- **BAIXO (registro):** célula queimada × `.md` por nota sem teste literal nesta suíte (mesmo ramo `soMetadado` da selada; agregado provado noutro arquivo). ADR: "nem aviso" contradiz "avisos fora do contrato" — a segunda é a verdadeira. Cartão fixo sobre a pílula "Trabalhar nisto" (Design, volta futura).
- **AMBIENTE (não do branch):** `versoes.yaml` depende de `openLink`, que num simulador recém-instalado abre "Abrir com Traço?" e trava o fluxo — vale para qualquer fluxo com `openLink` fora dos simuladores já aprovados; `clearState` no iPhone 17e produziu 2× `Sandbox access to file-write-create denied` no arranque e lista vazia após Concluir, não reproduzido nas 4 execuções seguintes.

## Comandos e números

```
xcodebuild test -destination 'platform=iOS Simulator,id=C7341E64-…' -derivedDataPath build
✔ Test run with 639 tests in 122 suites passed after 8.516 seconds.  ** TEST SUCCEEDED **
avisos de compilador: 0
maestro --device C7341E64 (TRACO_SEM_MODELO=1): busca ✓ caderno-gravar ✓ aba-arquivo ✓ auditoria-nav ✓ expressiva-trancar ✓ versoes (por gesto) ✓ | versoes (deep link) ✗ diálogo do sistema
git merge-tree --write-tree d4d98da HEAD → limpo
git diff 41b2605..HEAD --shortstat → 10 files, +656 −89 (produção +218 −87)
```

## Re-G3 — correções da revisão (3ce6028 sobre 30c3ef0)

Revisor: Claude Fable 5.1, sessão independente, 05/09/2026, 19:30–19:45. Só o que mudou: `git diff 30c3ef0..3ce6028` = 3 arquivos, +84/−16 (produção: `Sessao.swift` +19/−12; testes +58; SPEC +11/−5). Instrumento: iPhone 17e `C7341E64-3A33-4ADD-AF6C-9296215FAD09` (liguei, usei, desliguei), tudo por `com-trava.sh`. Nenhum código editado, nada commitado. `git merge-tree --write-tree 5ccf5e7 HEAD` → árvore `0374fa8`, **sem conflito**.

### Veredito: INTEGRAR

As duas dimensões abertas fecham. Um achado ALTO **pré-existente em main** (fora do diff, `Camadas.swift`) fica registrado para correção própria; ele não é desta volta, mas a volta o torna visível na rota de recusa.

### Achado 1 (relógio antes do commit) — corrigido

- `trancarESair` (1644–1648) e `abrirFecho` (880–888): `pararTimer()` agora vem DEPOIS de `guard salvar(no:trancar: true)`. `queimar` (1523–1552): depois de `guard persistir`. `grep pararTimer` nas rotas restantes: `novaPagina` (1319) só é chamada depois do commit pelos chamadores; `abrir(nota)` (1379) não é rota de commit e todos os seus chamadores fazem `guard salvar` antes (`RaizView:39`, `PadroesView`, `PaginaView:239`), e a saída com timer é bloqueada por `.sairTranca` em `irPara`/`irNotas`/`irRecordar`. Nenhuma outra rota para o relógio antes do commit.
- Testes: `trancarESairRecusadoDeixaORelogioDePeEAGravacaoSeguinteLevaOPrazo` prova a cadeia inteira (recusa → `timerLigado && toastFixo` → `salvar` aceito com `expressivaPrazo != nil && !trancada` → `trancarExpressivasVencidas(agora: .distantFuture)` sela e zera o prazo). `abrirFechoRecusadoDeixaORelogioDePeEOFechoAbreNaSegunda` prova recusa → relógio de pé, `fechoUUID == nil`, texto intacto → `salvar` leva o prazo → segunda `abrirFecho` tranca, zera o prazo e para o relógio. **Queimar não tem teste com relógio**, e não precisa: `queimar` só é alcançável de `FechoExpressivaView` (127, 136), isto é, depois de um `abrirFecho` aceito que já parou o relógio — o `pararTimer` movido ali é inerte (registro, não achado).
- Na tela (encenação minha, store do App Group em 444/555, app relançado — o log confirma `Attempt to add read-only file … Adding it read-only instead`): texto emocional, "Começar o timer", arrasto de borda, "Fechar a escrita" → `Não consegui guardar agora. O texto continua aqui.` visível, `timer-expressiva` visível, texto visível, `fecho-expressiva` ausente; 20 s depois a linha e o relógio continuam (o relógio já passou de `14:5x`). Banco: 1 linha em `ZNOTA` (a da rodada anterior), WAL intocada (mtime 19:35:29 < fluxo às 19:36). Capturas `v7-reg3-recusa-timer.png` e `-depois.png` — ver achado 3 sobre o que elas mostram.

### Achado 2 (linha fixa apagada pelo transitório) — corrigido

`linhaFixa: String?` separada de `toast`; `toastFixo` virou `linhaFixa != nil`. Um `mostrarToast` transitório passa por cima e, ao expirar, faz `toast = linhaFixa` (volta a linha, ou `nil`). A linha só é zerada em `salvar` depois de `persistir` aceitar (994–997), e o `toast` só é apagado ali se ainda for a própria linha — um transitório em voo termina sozinho. Segunda recusa durante um transitório cancela a task e fixa de novo. Teste `avisoTransitorioNaoApagaALinhaDeRecusa`: transitório de 10 ms sobre a fixa, `toast` = transitório com `toastFixo` verdadeiro; 300 ms depois `toast` = linha de recusa. A ADR ("só some quando um `salvar` grava") agora é verdadeira no código. Parâmetro `duracao` novo em `mostrarToast` existe só para o teste — aceitável, um argumento com default.

### Achado 3 — ALTO, pré-existente em main, fora do diff (registro para correção própria)

`Camadas.swift` (não tocado por esta volta; idêntico em main 5ccf5e7): o arrasto de borda anima `pos` para 0 (camada do arquivo à mostra) e só 16 ms depois escreve `arquivoAberto = true`. Com o timer de pé, o setter (`RaizView.arquivoAberto` → `irPara`) cai em `.sairTranca` e NÃO muda `aba`; `onChange(of: arquivoAberto)` não dispara e nada devolve `pos`. Resultado: a camada Notas fica **visualmente** por cima da página, enquanto hit-testing e acessibilidade dizem "página" (por isso o maestro achou toast, relógio e texto: `accessibilityHidden(!arquivoAberto)`). Reproduzido **sem truque de disco**: timer → arrasto → "Continuar escrevendo" → tela mostra a lista Notas com a expressiva em curso, `timer-expressiva` "visível" para a acessibilidade (`v7-reg3-continuar-camada.png`). Na rota nova de recusa, o mesmo: as capturas `v7-reg3-recusa-timer*.png` mostram a lista, não a página com a linha. Pelo botão "Notas" (`irNotas`) ou pela aba a página fica à vista — a captura do G3 anterior (`v7-rev-recusa-pagina.png`) foi por aba. Correção mínima (dono da área, não desta volta): no `onEnded`, depois de `arquivoAberto = alvo`, se o binding não pegou (`arquivoAberto != alvo`), animar `pos` de volta para `-w`. Não desconta a nota da volta: o estado é honesto, a projeção na tela é bug antigo de `Camadas`; mas o orquestrador deve abri-lo já.

### Registros menores

- Depois de um `esgotarTimer` recusado (relógio em 0:00), `timerTask` já foi cancelada por `alinharTimerAoRelogio`; `timerLigado` continua e o prazo (passado) vai ao disco na gravação automática seguinte, e `trancarExpressivasVencidas` sela no foreground/arranque. A nova tentativa em sessão só acontece por mudança de cena ou gesto do autor. Garantia intacta; comportamento aceitável.
- `mostrarToast` transitório sobre a fixa mantém `toastFixo == true` durante o transitório; nenhuma view lê `toastFixo`, então sem efeito visual.
- A lista Notas mostra a expressiva EM CURSO com o texto (`v7-reg3-continuar-camada.png`). Pré-existente, dentro do app; a matriz de projeções (índice, Spotlight, widget, export) não é afetada. Só registro.

### Scorecard reavaliado (dimensões afetadas)

| dimensão | antes | agora | evidência |
|---|---|---|---|
| Privacidade e autoria | 8 | **9** | `pararTimer` depois do commit nas três rotas; dois testes provam relógio vivo → prazo persistido → selo; encenação no aparelho com store só-leitura: relógio e texto ficam, fecho não abre, banco intocado. Queimar inerte por construção. |
| Correção | 9 | **9** | `✔ Test run with 642 tests in 122 suites passed after 8.870 seconds.` `** TEST SUCCEEDED **`; avisos de compilador `\.swift:N:N: warning` = 0; os 4 testes de `IntegridadeRotasTests` nominalmente passados; maestro `expressiva-trancar` no C7341E64 passou (`v7-reg3-fecho.png`: "Escrita encerrada", Selar, Queimar, campo da linha). |
| Contrato | 9 | **9** | Duas linhas novas na tabela da ADR 05s descrevem o código; "Prova" com 20/642 literais, conferidos. A frase "só some quando um salvar grava" passou de frouxa a verdadeira. |
| Estado honesto | 9 | **9** | Linha fixa sobrevive ao transitório e só sai com gravação aceita (teste + leitura). Ressalva do achado 3: na saída por arrasto de borda, a camada Notas cobre a linha — bug de `Camadas` em main, correção própria. |
| Complexidade | 9 | **9** | Produção +19/−12 num arquivo; sem tipo novo, sem dependência; um `String?` substitui um `Bool`. |

Demais dimensões inalteradas desde o G3 (Visão 9, Jornada real 9, Design 9, Simplicidade 9, Movimento n/a, Componentes n/a, Acessibilidade 9, Performance 9, Fora do app n/a, Relato 9). **Todas ≥ 9 ou n/a com motivo.**

### Comandos e números

```
com-trava.sh xcodebuild test -project Traco.xcodeproj -scheme Traco -destination 'platform=iOS Simulator,id=C7341E64-…' -derivedDataPath build
✔ Test run with 642 tests in 122 suites passed after 8.870 seconds.  ** TEST SUCCEEDED **   avisos: 0
com-trava.sh maestro --device C7341E64 test maestro/expressiva-trancar.yaml → passou (13/13 passos)
encenação recusa (store 444/555, TRACO_SEM_MODELO=1): 19/19 passos; log: "Adding it read-only instead"
git merge-tree --write-tree 5ccf5e7 HEAD → 0374fa8, limpo
git diff 30c3ef0..3ce6028 --shortstat → 3 files, +84 −16 (Traco/ +19 −12)
```
