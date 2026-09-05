# Volta 8 — acessibilidade real nas jornadas principais (ADR 2026-09-05t)

Data: 05/09/2026. Branch `Vitorepf/volta-8-acessibilidade`, base `main` 41b2605.

## O que mudou (semântica, movimento e escala; aparência intacta)

| Arquivo | Mudança |
|---|---|
| `Traco/Tema.swift` | `fadeReduzido`, `animacao(_:reduzido:)`, `transicao(_:reduzido:)` — a lei do movimento reduzido num lugar |
| `Traco/App/Camadas.swift` | reduzido: posição corta seco, arquivo entra por fade (sem deslizar) |
| `Traco/App/BarraNavegacao.swift` | reduzido: a barra não desce 130 pt, só apaga |
| `Traco/Pagina/PaginaView.swift` | toast por `Tema.transicao`; "lendo…" sem laço em reduzido; ação de rotor "Ligar/Desligar análise automática" no lugar do toque longo; anúncios do cartão (forma sugerida, aviso, sábia pensando/respondeu, vestido, sem conta) |
| `Traco/Caderno/CadernoView.swift` | `Tema.gaveta(reduzido:)` lê o ambiente (era `false` cravado); régua/barra de ligação entram por `Tema.transicao`; régua com rótulo, chips com hint, "Todas" com hint; régua para em `xxxLarge` |
| `Traco/Caderno/EditorBlocoView.swift` | mola do trilho por `Tema.animacao` |
| `Traco/Notas/NotasView.swift` | cartão da sábia é contêiner nomeado; anúncios (pensando, respondeu, não respondeu, sem modelo); transições por `Tema.transicao`; menu de ordem mostra ícone em AX; controles do título param em `xxxLarge` |
| `Traco/Notas/RedeView.swift` | ecos entram por `Tema.transicao` |
| `Traco/Calendario/CalendarioEscalas.swift` | ações de rotor "Dia/Semana/Mês/Ano seguinte/anterior", uma por escala, no mesmo `andar` do arrasto |
| `Traco/Calendario/CalendarioView.swift` | toast por `Tema.transicao` |
| `Traco/Calendario/CalendarioFicha.swift` | menu do domínio: "Domínio: X" + hint |
| `Traco/Recordar/RecordarView.swift` | blocos e "O que não voltou" por `Tema.transicao`; pergunta e pista com `fixedSize` vertical; cabeçalho para em `xxxLarge` |
| `TracoTests/TemaTests.swift` | 1 teste: reduzido devolve `fadeReduzido`; normal devolve a animação dada |
| `maestro/ax5.yaml` | + Calendário e Perfil em AX5 (capturas 04 e 05) |
| `SPEC.md`, `EVOLUCAO.md` | ADR 05t; linha "Direção visual e uso simples" |

Não tocado: `Sessao.swift` (já anuncia forma vestida, expressiva e toast — não se duplica), Trabalho/*, Modelo/*, Analise/*, Corpus/Indice/Holofote, linha de gravação da PaginaView.

## Prova

- Build genérico: `BUILD SUCCEEDED` (3 vezes, via `com-trava.sh`, destino C2416CBC).
- Suíte integral: **623 testes em 122 suítes, 0 falhas** (`Test run with 623 tests in 122 suites passed`, `TEST SUCCEEDED`), repetida após as correções AX5 (ver corpo do `worker_done`).
- Capturas `simctl` no simulador da volta (iPhone 17 Pro, C2416CBC): `v8-normal-{pagina,notas,calendario,recordar,perfil}.png` e `v8-ax5-{pagina,notas,calendario,recordar,perfil}.png`.
- Tamanho de texto: mudei o do C2416CBC para `accessibility-extra-extra-extra-large` e RESTAUREI para `medium` (conferido: `xcrun simctl ui C2416CBC content_size` → `medium`). O iPhone 17 do dono (1A46B6D3) ficou em `medium` o tempo todo.
- Nota semeada só no simulador da volta ("quero correr de manhã antes do trabalho", via `traco://anotar`), para Notas e Recordar terem conteúdo.

### Colisão no iPhone do dono
Antes da orientação do orquestrador, instalei o build no 1A46B6D3 e abri três rotas (`traco://notas`, `/calendario`, `/recordar`) mais um toque na aba Perfil. A captura seguinte mostrou uma folha de Trabalho de outra volta sendo digitada — o simulador estava em uso. Parei; nada de dados ou tamanho mudou lá. Escalado; o orquestrador mandou usar o C2416CBC.

## Árvore de acessibilidade esperada, por tela (para o revisor conferir com `maestro hierarchy`)

Formato: elemento → label · valor · traits/ações. Sem a palavra "botão" em rótulo.

### Página (id `pagina`)
- `notas-da-pagina` → "Notas" · button
- `concluir` → "Concluir" · hint "Guarda e abre uma página nova" · button (oculto sem voz)
- data → oculta (decisão anterior)
- `linha-da-volta` → "1 volta a conferir" · hint "Abre as Notas, na seção A VOLTA" · button (só quando há)
- editor `pagina` → "Página" / "Título" / "Seção" / "Subseção" / "Citação" · text field
- `regua` → "Régua de formas" (contêiner); `regua-titulo`… → nome da forma · hint "Dá esta forma à linha do cursor" · button; `regua-todas` → "Todas" · hint "Abre a lista com todas as formas"; "Esconder teclado" · button
- `cartao-analise` (contêiner): kicker (texto), pergunta, `abrir-campos` "Abrir os campos" · hint; `soltar-forma` "Deixar como nota" · hint; `chip-dominio` "Domínio: X"/"Sem domínio" · hint "Abre o menu…"; `perguntar-sabia` · hint "A resposta vem aqui, nunca na nota"; `serviu`/`nao-serviu`
- barra: "Trabalhar nisto" · hint; "Analisar" · hint "Classifica o que você escreveu. Não escreve na nota." · **ação custom** "Ligar análise automática"/"Desligar análise automática"; "Recordar" · hint; "Anexar arquivo" · hint; "Lente da língua" · hint. Em AX: Menu "Mais ações da nota" com as mesmas.
- folha da forma: título da forma · header; `soltar-na-folha` "Deixar como nota"; `forma-<gesto>` contêiner com `campo-<id>` → rótulo do campo · text field; "N de M" contador; DEPOIS DISTO → `encadear-*` · hint
- anúncios: "Forma X aberta. Soltar a forma disponível." (Sessão); "Forma X sugerida. Abrir a forma disponível."; "A sábia está pensando."; "A sábia respondeu. A resposta está no cartão."; "Vestido. Desfazer disponível."; aviso literal; "A sábia pelo modelo do aparelho…" ; toast literal (Sessão)

### Notas
- título "Notas" · header; `ordem-notas` → "Ordenar por <ordem>" · button; "Como contexto" · hint; `abrir-trabalhos` "Trabalhos" · hint
- `filtro-todas` e filtros → nome · selected quando ativo · hint "Um filtro por vez"
- `busca-notas` → "Buscar ou perguntar" · valor "vazio"/texto · hint "Escrever filtra; enviar pergunta à sábia"; `perguntar-notas` "Perguntar à sábia"; `limpar-busca` "Limpar busca"
- `cartao-sabia-notas` → "Cartão da sábia" (contêiner): kicker, `resposta-sabia-notas`, "Foram junto: …", serviu/não serviu, `repetir-pergunta-notas`, `fechar-sabia-notas`
- "PELO SENTIDO" · header; "A VOLTA" · header (`secao-volta`); `volta-notas` → "<cobrança> <título>" · hint
- `nota-notas` → título · hint "Segure para recordar a memória" (ações do menu de contexto aparecem no rotor: Recordar, Como contexto, Versões, Ligações, Domínio, Escolher, Apagar); `chip-dominio` ao lado
- anúncios: "A sábia está pensando." / "A sábia respondeu…" / "A sábia não respondeu. Repetir pergunta disponível." / "A sábia … A busca continua."

### Calendário
- `calendario-titulo` · header; `calendario-feriado`
- `escala-dia|semana|mes|ano` → "Dia"/"Semana"/"Mês"/"Ano" · selected; `modo-lista|grade` → "Lista"/"Grade" · selected; `calendario-hoje` "Hoje"
- dia: `dia-chip-AAAA-MM-DD` → dia por extenso (+ "feriado, nome") · selected; `evento-<id>` → "título, intervalo" (+ "com aviso"); `calendario-agora` → "agora, HH:MM"
- semana: linhas → dia por extenso · hint "Toque para abrir o dia"; mês: `mes-dia-*` → dia · valor "N compromissos" · selected; ano: `calendario-ano-*` → "setembro de 2026"
- **ações custom em cada escala**: "Dia seguinte"/"Dia anterior", "Semana seguinte/anterior", "Mês seguinte/anterior", "Ano seguinte/anterior"
- prosa: `calendario-prosa` → "Marcar em palavras" · hint; `calendario-marcar` → "Marcar o compromisso" / ditado; "Marcar" (+)
- ficha: `ficha-fechar` "Fechar"; `ficha-pronto` "Pronto"; `ficha-titulo`; Data/Começa/Termina (DatePicker nativos); `ficha-aviso` → "Avisar: <opção>"; `ficha-aviso-promessa` "Toca …"; `ficha-dominio` → "Domínio: X"/"Domínio: sem domínio" · hint; `ficha-notas`; `ficha-repete-N` → nome do dia · selected; `ficha-apagar`; DO CADERNO · header; `do-caderno-nota` · hint "Abre a nota"

### Recordar
- "Voltar"; "RECORDAR" (texto); instrução/pista/pergunta (`recordar-pergunta`), serviu/não serviu; editor "Memória"; "Revelar" · hint; `recordar-adiar` "hoje não" · hint; `recordar-pular` "pular" · hint; ao revelar: blocos "DE MEMÓRIA"/alvo combinados (`children: .combine`); `recordar-nao-voltou`; "Próxima" · hint; "Voltar à página"; "cobrar antes" · hint
- alvo escondido durante a escrita → `accessibilityHidden`

### Perfil
- "Perfil" · header; seções em rótulos; `estado-conta`, `entrar-conta`/`sair-conta`; `estado-de-bordo` (combinado); `estado-calendario`; `abrir-ajustes` · hint; `estado-avisos`; toggles nativos (`ajuste-retrato`, `ajustes-segunda`, `revisao-semanal`) com título e valor; `retrato` → "O retrato, exatamente como viaja"; `exportar-corpus`/`importar-md` · hint; `espelho-pasta` · hint; `ferias-ate` (DatePicker), `ferias-sem-data`; `esquecer-sinais`

## O que ficou fora
- Passe manual com VoiceOver ligado em aparelho real (requer humano).
- `maestro hierarchy` (do revisor) contra a árvore acima.
- Calendário: ano preso em `large`, grade em `xxLarge` (ADR 02h); régua em `xxxLarge` (esta volta).
- A data da página segue `accessibilityHidden` por decisão anterior — não mexi.
