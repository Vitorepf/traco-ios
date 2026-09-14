# Auditoria de UX, design e componentes — 13/09/2026

Fable, sessão traco-ios-20, sobre `main` 97f68d5. Método: `design-router` fase 5 (auditar antes de tocar), régua = REFERENCIA-HERMES (sete pontos), SISTEMA-CLARO e ADRs 10i/10j/10k/10l/12a. Nenhum arquivo de código editado. A auditoria de 05/09 (`auditoria-frontend.md`) foi lida como hipótese: 215 commits depois, a barra virou pílula, a conversa perdeu a caixa, Perfil/Padrões/Lente pousaram no papel. **Metade dos 23 defeitos de lá caiu; os que ficaram estão marcados abaixo com (v9 #n).**

**Instrumento.** Build de `main` (BUILD SUCCEEDED) instalado no **iPhone Air 64F7B8B4** (ligado por mim; `large`, `light`, restaurados e conferidos ao fim). Dados: 19 notas pelo `d1/semear-notas.py` (store do App Group), 7 compromissos em `calendario.json` (com fuso), 1 trabalho criado na tela, 1 pergunta à sábia. Toques pelo MCP do simulador (sem mouse). O teste 4 (A1DF082C) recebeu o mesmo build às 21:07, mas mudou de tela sozinho um minuto depois com o dono ativo no Mac — **não o dirigi**; os dados dele ficaram. No Air, o diálogo de calendário acabou em "acesso total" (o toque em Não Permitir caiu no botão de cima): o aparelho ficou lendo os calendários de demonstração do simulador.

**Fora, por ordem do dono (13/09, 21h20):** tamanho de fonte / Dynamic Type. Duas capturas em AX5 existem no scratchpad e não contam. Movimento: não gravei vídeo nesta volta — o portão `PortaoDoMovimentoTests` está verde e as durações literais são zero (inventário §C); a nota de Movimento fica **não avaliada**, porque o dono julga motion em vídeo e não em código.

---

## A. Placar por tela (0–10)

Régua: 10 = o dono não acharia nada a dizer diante do Hermes; 9 = mínimo para mesclar (ESTEIRA); ≤6 = tela que ainda "parece feita por IA".

| tela | Design/identidade | Simplicidade (curva-zero) | Componentes/sistema | Texto (voz e clareza) | Estado honesto | Hermes (7 pontos) | média |
|---|---|---|---|---|---|---|---|
| 1 Página + Caderno | 6 | 6 | 6 | 7 | 7 | 5 | **6,2** |
| 2 Notas (lista) | 8 | 8 | 8 | 7 | 8 | 8 | **7,8** |
| 3 Conversa com a sábia | 8 | 8 | 9 | 6 | 5 | 9 | **7,5** |
| 4 Calendário (D/S/M/A/lista) | 8 | 6 | 7 | 8 | 6 | 6 | **6,8** |
| 5 Ficha do compromisso | 7 | 7 | 6 | 8 | 4 | 5 | **6,2** |
| 6 Padrões | 8 | 9 | 9 | 7 | 8 | 9 | **8,3** |
| 7 Perfil | 7 | 6 | 8 | 5 | 8 | 8 | **7,0** |
| 8 Trabalhos + Trabalho | 4 | 4 | 5 | 3 | 8 | 3 | **4,5** |
| 9 Recordar | 6 | 8 | 7 | 8 | 8 | 6 | **7,2** |
| 10 Lente | 7 | 7 | 8 | 7 | 8 | 7 | **7,3** |
| 11 Navegação (pílula, camadas, folhas) | 8 | 8 | 7 | 6 | 8 | 8 | **7,5** |
| **média** | 7,0 | 7,0 | 7,3 | 6,5 | 7,1 | 6,7 | **6,9** |

Nenhuma tela chega a 9 na média. As dimensões mais fracas do conjunto são **Texto** (jargão de spec vazando para a tela, três palavras para "voltar/fechar/pronto") e **Hermes** (caixas que ficaram: campos da forma, ficha, Trabalho). O Trabalho é a tela que puxa tudo para baixo — é a mesma família crua de 05/09 (v9 #5), só que agora com dois níveis de folha.

---

## B. Defeitos, por severidade

Formato: estado → evidência → consequência → requisito → correção.

### Alto — engana ou impede

1. **A ficha promete um aviso que já passou.** Ficha de "Jantar com a Ana" (20:00–22:00, aviso 30 min) aberta às 21:13 diz "Toca hoje às 19:30." → `Aviso.promessa` (`Calendario.swift:224-238`) compara só o dia, nunca `quando < agora` → a pessoa sai da ficha achando que vai ser avisada → SISTEMA-CLARO "erro não anuncia conclusão" → guardar `if quando < agora { return "já passou — não vai tocar" }` (a Sessão já tem esta frase no toast `:1061`; a ficha não a usa). **(v9 #2, ainda aberto na parte da hora passada.)**
2. **A semana esconde compromissos depois das 21h e antes das 3h.** Semana 13–19: "Jantar com a Ana" (20:00) não aparece; "Dentista" (22:30) está colado na borda direita por cima dele → `CalendarioEscalas.swift:283-284` (`origem = 3h`, `span = 18h`) e `:446` (`x = min(…, largura − w − 4)`) prendem o que cai fora à borda → dois eventos viram um, e um jantar some da visão da semana → "Preservar informação necessária" → ou a escala cobre 0–24 na semana (a hora fica a ~12 pt cada), ou o que cai fora vira um chip "+1 à noite" à direita que abre o dia. **(v9 #6 era só o corte de texto; este é pior.)**
3. **Sem conta, a sábia falha e oferece "Perguntar de novo".** Conversa nas Notas: "SÁBIA — Falta a conta. O que escreveu continua aqui." + botão "Perguntar de novo" → `Grok.swift:420` (`.semConta`) e a linha de falha da `ConversaNotas` → repetir sem conta dá o mesmo erro; a saída certa (Perfil › Entrar) não está ali; e o Perfil, no mesmo aparelho, diz "No aparelho — pronto — a análise não precisa de conta" → contradição entre duas telas → falha sem conta deve ter a ação "Entrar com a conta Grok" (rota para o Perfil) em vez de repetir, e a frase deve dizer por que o modelo do aparelho não serviu aqui (a `Politica.semProvedor` já tem esse texto para o Trabalho).
4. **O cartão manda "Abrir os campos" com os campos já abertos.** Página com WOOP vestido: os três campos (RESULTADO, OBSTÁCULO, SE…) já estão na folha e o cartão embaixo ainda diz "Abrir os campos / Deixar como nota" → `CartaoAnaliseView.swift:420` não sabe que a forma abriu sozinha → a pessoa toca num botão que não faz nada visível ou pensa que há mais campos → curva-zero: ação que não muda estado não é ação → quando os campos já estão na folha, o cartão mostra só "Deixar como nota" (ou some). **(v9 #3 mudou de forma: já não cobre os campos, mas contradiz.)**

### Médio — compreensão e coerência

5. **"Notas" no canto da página é um botão vestido de título.** `PaginaView.swift:413` `Button("Notas")` no mesmo lugar e peso em que "Notas" é o título da lista → na página vazia a pessoa lê "Notas" como nome da tela (o caderno?) e não como saída; e o gesto da borda já faz a mesma coisa → `law-of-similarity` → ou vira o glifo da pílula (a mesma cápsula do arquivo) ou some, deixando o gesto e o círculo.
6. **A lista do calendário na escala "A" abre em 1 de janeiro.** Lista com A selecionado começa em "QUINTA-FEIRA, 1 DE JANEIRO / Ano Novo" e hoje está 20 seções abaixo → `CalendarioView.swift:225-262` sem `scrollTo(hoje)` para a lista do ano → cada abertura custa uma rolagem longa → a lista pousa em hoje (âncora) e o passado fica acima, como o Calendário do iPhone.
7. **Três andares no pé do calendário.** Escalas+Hoje (52 pt) + prosa (52 pt) + pílula (52 pt) com folgas = ~200 pt de chrome; na lista o conteúdo passa por baixo e "DOMINGO, 5 DE ABRIL" fica tapado pelo trilho → FILA "campanha do dono" — **não mexi**, só registro que é o maior custo de tela do app (v9 #18). Proposta mínima, se ele quiser: a prosa vira a linha "marcar" no topo da lista, como a busca virou linha nas Notas (ADR 10i), e o pé fica com trilho + pílula.
8. **Microfone no campo da prosa.** Ícone `mic` à direita de "Dentista sexta às 14:30" (`CalendarioView.swift:412-432`, sem rótulo) → voz é proibida (ESTEIRA, ADR 10k "Fora, nomeado") → tirar o ícone; o botão do campo fica só com enviar/parar.
9. **Todo dia inteiro aparece como "00:00".** Padrões › Esta semana: "Aniversário da mãe — sex 18, 00:00" → `PadroesView.swift:278` formata hora sem olhar `diaInteiro` → a pessoa lê um aniversário à meia-noite → "sex 18 · dia inteiro".
10. **Subtítulo repetido cinco vezes.** Padrões: "· nos próximos sete dias" em cada uma das 5 linhas de compromisso (`PadroesView.swift:278`) → ruído que esconde a hora → a frase sobe para o cabeçalho ("COMPROMISSOS · próximos sete dias") e o subtítulo fica "sex 18, 00:00".
11. **Perfil corta a única cópia da informação.** "sem conta — recursos locais disponíveis; exercí…", "pronto — a análise não precisa de conta nem de…", "lendo os seus calendários — nada nos próximos…", "ligados — o Recordar, a revisão de domingo e o…" → `LinhaDeLista` corta o subtítulo em uma linha por regra (ADR 10k §2) mas aqui o subtítulo É o estado → a pessoa não sabe o que "exercí…" quer dizer → ou subtítulo curto (≤ 40 caracteres: "sem conta", "pronto", "lendo — nada em 7 dias", "ligados") com a letra miúda inteira embaixo (a própria 10k §3 permite), ou `linhasDoSubtitulo: 2` nestas quatro linhas.
12. **"0 de 64 avisos ativos."** Perfil › Permissões: número interno do iOS (teto de notificações pendentes) exposto como estatística, sem explicação; e 0 mesmo com dois compromissos com aviso hoje → ou some, ou vira "2 avisos marcados" quando há, e nada quando não há.
13. **Lente: "Instigar" e "Contrapor" são ações com cara de navegação.** Linha com chevron ">" e subtítulo "vai à sábia; as perguntas ficam aqui" (`LenteView`) → chevron é "abre outra tela"; aqui dispara a IA → `critique-affordance` → mesmo desenho do botão do campo da conversa (seta em carvão), ou a linha sem chevron e com o verbo em peso de ação.
14. **O subtítulo da nota muda de uma abertura para a outra.** Lista das Notas: "Quero dormir mais cedo" saiu como "WOOP · se eu pegar o celular, então deixo n…" numa captura e "WOOP · acordar sem alarme · o celular na c…" na seguinte, sem edição → a ordem dos campos no subtítulo não é estável (dicionário `campos` sem ordem) → a pessoa não reconhece a nota pela linha → ordenar pelos campos do método (resultado, obstáculo, plano) sempre.
15. **A permissão do sistema chega sem contexto.** Primeiro "Concluir" → diálogo do iOS "O app Traço deseja enviar notificações"; primeira aba Calendário → diálogo de acesso total → nenhuma linha do Traço explica antes o que vai tocar ou ler (o Perfil explica, mas depois) → HIG: pedir no momento do uso e com o porquê → uma linha do app ("para o Recordar cobrar amanhã, o iPhone vai perguntar…") antes de cada pedido.

### Baixo — acabamento e sistema

16. **Três palavras para sair de uma folha:** "‹ voltar" (Trabalhos, Trabalho, Recordar — minúscula), "Fechar" (conversa), "Pronto" (Lente, ficha, Rede, Versões, Série), "Concluir" (página), "✕" (ficha) → `CabecalhoDeFolha` tem `Saida {fechar, voltar}` e `concluir`; três telas não o usam (`TrabalhosView`, `TrabalhoView`, `RecordarView:370`) → uma regra: ✕ fecha sem guardar, "Pronto" guarda, "‹ voltar" só quando há pilha; caixa baixa só na cópia do dono.
17. **Caixa alta como rótulo de conteúdo (10k §1) ainda em:** "RECORDAR" (`RecordarView.swift:370`, título da folha), "RESULTADO (O MELHOR DESFECHO)", "OBSTÁCULO INTERNO (O SEU HÁBITO/MEDO)", "SE [OBSTÁCULO], ENTÃO EU", "DEPOIS DISTO" (`CamposFormaView`), "NESTE TRABALHO, PREFIRO", "PREPARAR UMA VERSÃO", "PRÓXIMO ATO", "DIFICULDADE" (`TrabalhoView`), "A FORMA DESTA NOTA / ADVÉRBIOS / INSTIGAR / CONTRAPOR / APONTAR UM TRECHO" (`LenteView`, estes são seções e valem). A própria 10k já nomeia o "próximo corte": `CartaoAnaliseView` (10), `PortalArquivoView` (10), `RedeView` (8, com `.uppercased()` em `:179,200`), `PaginaView`, `FechoExpressivaView`, `SerieView`, `PortalCodigoView`, `CamposFormaView`, `Pilula`, `BotaoPrimario`.
18. **Caixas que ficaram depois da 10k §3:** os três campos brancos da forma na página; os cartões cinza QUANDO/AVISO/NOTAS da ficha; os campos cinza e a busca em caixa do Trabalho; o campo da Lente (esse a ADR permite). A regra do Hermes é "nenhuma caixa nova sem prova de que o tipo não resolve" — para campo de escrever, a linha com hairline e caret âmbar (a busca das Notas) já provou que resolve.
19. **Dois idiomas de busca:** "buscar" como linha (Notas, ADR 10i) e "Buscar trabalhos" em caixa cinza com placeholder (Trabalhos) → um só.
20. **Trabalho repete o mesmo parágrafo duas vezes na mesma folha:** "Sem dificuldade plantada, a jornada continua aqui: o próximo passo é um artefato utilizável." + "Ir ao próximo passo" no topo e de novo em DIFICULDADE → e a frase é linguagem de ADR ("plantada", "artefato utilizável"), não do dono → uma vez, em português de uso: "Nada te trava aqui — o próximo passo é a versão pronta."
21. **Três botões primários carvão numa folha só** (Começar este trabalho / Preparar com IA / Preparar este ato) e os desabilitados não parecem desabilitados (v9 #13; o código tirou o `.disabled` de propósito e leva o foco ao obstáculo, `TrabalhoView.swift:1553-1614` — o desenho não mostra isso) → um primário por vista; os outros em `BotaoCompacto`.
22. **Rótulos de linha invertidos.** Padrões: título "Quero dormir mais cedo esta semana · obstáculo: o celular na cama" e subtítulo "o que está em jogo"; Perfil: título "devido · em aberto há 22 dias · conferir em 5 de set. de 2026" e subtítulo "Decidir se troco de plano de celular" → o nome do conteúdo é o título; o estado é o subtítulo (10k §2).
23. **"Latência da descoberta"** e "Hipótese sem resposta é informação; abandonar é resultado." no Perfil — vocabulário da visão, não do uso (Trilha Mac: "falar em linguagem de uso, não em jargão").
24. **Glifo de evento do sistema é um círculo pontilhado** (lista do calendário, "do seu iPhone") — não distingue nada; a 10k pede forma própria por identidade → o glifo do calendário com a cor do calendário de origem.
25. **Feriado no ano é um número riscado** ("1", "21", "7" com barra) → lê como "cancelado" → um ponto abaixo do número, como os compromissos.
26. **Título do calendário ao mudar de escala** e **"Independ…" cortado no mês** (chip branco do feriado, 11 pt) — v9 #6 parcial; no mês os chips "Conferir a", "Jantar co", "Aniversár" cortam em 6–8 letras: só a primeira palavra, ou ponto colorido + contagem como o iPhone faz no mês.
27. **A pergunta que a pessoa digitou foi reescrita** ("que metodo" → "Que método") na linha VOCÊ — é autocorreção do teclado antes do envio, não do app; conferir no aparelho real, porque "as suas palavras, nenhuma mudou" é promessa do produto.
28. **`.rotulo()` e `LinhaDeLista` dependem de 9 `tracking` literais** (`ProsaView:17`, `CadernoView:647`, `EditorBlocoView:90`, `SerieView:29`, `VersoesView:20`, `RedeView:66`, widget ×2) e **25 raios literais** (15 no Caderno) fora do `Tema` — o portão da cor pegou o âmbar, mas não o raio nem o tracking.

---

## C. Inventário do sistema (estado em 13/09)

**O que está bom e não se toca:** `Tema` com vocabulário fechado de duração/mola/raio/sombra e classe de movimento; **zero** `withAnimation` com literal fora do Tema; **zero** `repeatForever`; 24 arquivos leem Reduzir Movimento; `Componentes/` com 21 peças (Pilula, LinhaDeLista, CabecalhoDeSecao, CabecalhoDeFolha, Cartao, CartaoDeResposta, CapsulaDeEspera, LinhaDeAutor, Vazio…); `Toque` centraliza os 6 hápticos; `.alvo()` em 42 lugares; 331 `accessibilityIdentifier`.

**O que ainda duplica:**

| o quê | onde | quanto |
|---|---|---|
| `CalendarioTema` como segundo tema | 18 aliases de `Tema` + escala tipográfica paralela (`meta` 13 vs 15, `chrome` semibold), terceiro tracking (−0,6), `margem` 20 literal, `PressaoClara` (15 usos) ao lado de `PressaoDiscreta` | 1 arquivo, 298 linhas |
| `ButtonStyle` fora de Componentes | `PressaoClara` (CalendarioTema:184), `BarraBotaoStyle` (PaginaView:769) | 2 |
| `.font(.system(size:` | CalendarioEscalas ×6, CalendarioView:186, BarraNavegacao:123,156 | 9 |
| `RoundedRectangle(cornerRadius: <literal>)` | ProsaView ×8, EditorBlocoView ×5, CadernoView ×2, PortalArquivoView ×2, CalendarioEscalas ×4, VersoesView, NotasView ×2, LinhaDeEstado | 25 |
| Cor literal | `SintaxeLocal.swift:22-29` duplica os 8 `Tema.syn*` (e usa `0x86868B`, cor abandonada); `Queima.swift` 10 `Color(red:)` (fogo, aceitável); `.white/.black` 24 | — |
| `.uppercased()` fora do sistema | `RedeView:179,200` | 2 |
| Cabeçalho de folha próprio | `TrabalhosView`, `TrabalhoView` ("‹ voltar"), `RecordarView:370` | 3 |
| Busca em dois desenhos | Notas (linha) × Trabalhos (caixa) | 2 |
| Estilo "desabilitado" | `BotaoPrimario` (tintaFraca), `Pilula` (tintaFraca), `BarraBotaoStyle` (opacity 0,38), `BotaoCompacto`/`PressaoDiscreta` (nada) | 4 desenhos |
| Toast | `Sessao.mostrarToast` (48 chamadas, 33 em minúscula e 9 em maiúscula) × `CalendarioToast` | 2 desenhos, 2 caixas iniciais |

---

## D. Requisitos com nota (o que o app tem de cumprir, e quanto cumpre hoje)

0–10; ★ = requisito do dono por escrito (ESTEIRA / ADR / FILA).

**Identidade e sistema visual**
- R1 ★ Um mundo só, papel `#F4F4F2`, sem claro/escuro — **10** (`preferredColorScheme(.light)` na raiz; conferido em aparência escura: idêntico).
- R2 ★ Cor só identidade ou estado (10k §4) — **8** (portão verde nas telas do sistema; âmbar-tinta ainda em "Perguntar de novo", "O que aconteceu?", "1 volta a conferir", "Trabalhar nisto", "Abrir os campos" — é ação, não traço do autor).
- R3 ★ Caixa alta só em cabeçalho de seção — **6** (defeito 17).
- R4 ★ Nenhuma caixa sem prova de que o tipo não resolve — **6** (defeito 18).
- R5 ★ Linha de lista de três níveis, fio recuado, identidade à esquerda — **8** (Notas, Padrões, Perfil, Lente e lista do calendário usam `LinhaDeLista`; Trabalho e ficha não; glifo do sistema vazio, defeito 24).
- R6 ★ Cabeçalho sussurrado com contagem e recolher — **9** (em toda seção que se conta).
- R7 ★ Tokens: nenhum hex, duração, mola fora do Tema — **8** (duração/mola 10; raio 6; tracking 7; `CalendarioTema` duplica).
- R8 Um acento por tela (o preto) — **8** (a página tem âmbar em 3 lugares ao mesmo tempo: Concluir, Trabalhar nisto, cursor).
- R9 Tipo: hierarquia por cor e peso, não por tamanho; números tabulares — **9**.

**Navegação e chrome**
- R10 ★ Pílula flutuante sem rótulos, cápsula carvão que anda, Escrever fora em círculo âmbar — **9** (cumprido; não medi a viagem da cápsula em vídeo).
- R11 ★ Pé da tela só com a barra — **7** (Notas/Padrões/Perfil sim; Calendário tem três andares por decisão do dono; a página tem régua + 5 ações por mandato "sinto a página").
- R12 Gesto da borda ↔ arquivo, puxador visível — **8** (o puxador de 3 pt continua a parecer um cursor parado, v9 #22).
- R13 Uma palavra para sair de folha, e o mesmo cabeçalho — **5** (defeito 16).
- R14 Folha sobre folha (Notas › Trabalhos › Trabalho) com "‹ voltar" duplo — **6**.

**Página (escrever)**
- R15 ★ Escrever e concluir em 2 toques, forma veste sozinha, nada anima enquanto digita — **9** (vestiu em ~3 s sem tocar; cartão entrou depois de parar).
- R16 O cartão diz o que fez e o que pode fazer — **5** (defeito 4).
- R17 O título/canto da página diz onde estou — **5** (defeito 5).
- R18 ★ Pé com régua de 12 formas + 5 ações (desenho do dono) — registrado, não avaliado.
- R19 Campos da forma em papel (sem caixa), rótulo em frase — **4** (caixas brancas + caixa alta com parênteses).

**Notas e conversa**
- R20 ★ Busca é uma linha da lista; perguntar é a marca "?" — **9**.
- R21 ★ Conversa sem balão, linha de autor, fio recuado, cápsula de espera, botão que muda — **9** (o estado "pensando" não foi visto porque sem conta falha na hora; a cápsula existe e tem teste).
- R22 Falha da sábia leva à saída certa — **3** (defeito 3).
- R23 Linha da nota estável e reconhecível — **7** (defeito 14).
- R24 "trabalhos ›" como porta que não some com filtro (ADR 11a) — **8** (é uma frase em cinza; passa despercebida ao lado de "Todas · Mais recentes").
- R25 Vazio como linha normal — **9** ("nada aqui ainda." em linha; a conversa vazia é uma tela em branco com o campo no pé — aceitável, mas sem uma linha de convite).

**Calendário**
- R26 Dia: linha do agora, cartão tingido pelo domínio, hora legível — **9**.
- R27 Semana mostra todos os compromissos do dia — **3** (defeito 2).
- R28 Mês legível sem cortar títulos — **6** (defeito 26).
- R29 Ano: hoje em carvão, mês corrente contornado, feriados distinguíveis — **7** (defeito 25).
- R30 Lista abre em hoje — **4** (defeito 6).
- R31 Ficha promete só o que vai acontecer — **3** (defeito 1).
- R32 Prosa sem voz — **5** (defeito 8).
- R33 Prosa entende nome de mês (v9 #1) — **não reproduzido nesta volta** (não digitei "7 de setembro"; fica como risco aberto).

**Padrões, Perfil, Lente, Recordar**
- R34 Padrões: três seções no papel, perguntas como conteúdo — **9** (defeitos 9, 10, 22 são texto).
- R35 Perfil abre com Conta em três linhas, letra miúda recolhida — **8** (defeitos 11, 12, 23).
- R36 Destrutivo em `aviso`, no fim — **7** ("Esquecer tudo" vermelho no meio da rolagem; "Apagar todos os compromissos" logo acima da pílula).
- R37 Lente: seções com contagem, ação distinguível de navegação — **7** (defeito 13).
- R38 Recordar: uma pergunta, uma resposta, revelar; "hoje não" sem cara de botão (v9 #9) — **7** (Revelar agora é `BotaoPrimario` e fica em `tintaFraca` até escrever, correto; "hoje não" continua texto solto; RECORDAR em caixa alta).

**Trabalho**
- R39 ★ Produzido / agendado / realizado / observado distintos — **8** (o texto diz; a tela não mostra estado nenhum antes de existir versão).
- R40 Trabalho na família visual do app (papel, LinhaDeLista, um primário) — **3** (defeitos 18, 20, 21).
- R41 Texto em linguagem de uso — **3** (defeitos 20, 23).
- R42 Intenção → versão em ≤ 6 toques sem decisão escondida — **6** (Delegar/Praticar/Combinar agora está à vista, com explicação; mas a folha tem 5 telas de rolagem e "Ir ao próximo passo" duas vezes).

**Estados e permissões**
- R43 Pedido de permissão com contexto antes do diálogo — **4** (defeito 15).
- R44 Sem permissão não é beco (03e) — **8** (Perfil › Abrir os Ajustes; ficha diz "nada vai toca" quando negado).
- R45 Toast nunca cobre a barra de ações (v9 #15) — **não testado** nesta volta (o toast do Recordar não foi provocado).
- R46 Botão desabilitado parece desabilitado — **6** (Trabalho não; página e Recordar sim).

---

## E. O que fazer primeiro (menor mudança por causa)

1. `Aviso.promessa`: guardar `quando < agora` → frase "já passou". Uma linha e um teste (defeito 1).
2. Semana: chips fora de 03–21 viram "+n" à direita que abre o dia, ou span 0–24 (defeito 2). Medir na tela antes: com 24 h a hora fica com ~12 pt.
3. Conversa sem conta: trocar "Perguntar de novo" por "Entrar com a conta Grok" quando `.semConta` (defeito 3).
4. Cartão: esconder "Abrir os campos" quando `camposAbertos` (defeito 4).
5. Lista do calendário: `scrollTo(hoje)` ao entrar (defeito 6).
6. Texto: 9, 10, 20, 22, 23 são só strings — uma volta de cópia com o dono, sem build entre uma e outra.
7. Trabalho: migrar para `CabecalhoDeFolha` + `LinhaDeLista` + um `BotaoPrimario` por vista; campos em linha com hairline (a V18 do RUMO). É a única tela que reprova de olho.
8. Portão: estender `TemaTests.telasDoSistemaSeguemARegraDaCorEDaCaixaAlta` às telas que a 10k deixou de fora, e um portão irmão para raio e tracking literais (hoje 25 + 9).

---

## F. Limites desta auditoria

Sem vídeo (movimento não avaliado). Sem aparelho real. Sem VoiceOver, sem AX, sem voz (por lei do dono). Estados não provocados: sábia pensando/respondendo com conta, falha de gravação, toast do Recordar, prosa "N de <mês>", Live Activity e widget. As capturas foram lidas na hora pelo MCP do simulador; em disco ficaram só `auditoria-ux-13-09/air-pagina-vazia-large.png` e `air-recordar.png`. O Air ficou com o build de `main` 97f68d5, 19 notas semeadas, 7 compromissos, 1 trabalho, acesso total ao calendário e avisos permitidos.

---

## G. Registro das voltas (13/09, noite)

- 1e2a2a6 — ficha promete só o que vai tocar (defeito 1); cartão "Preencher os campos" (4).
- 0efbc28 — lista do calendário em hoje (6); microfone fora do campo da prosa (8); falha sem conta leva ao Perfil (3); Padrões sem "00:00" e sem "nos próximos sete dias" (9, 10); Trabalho sem o parágrafo repetido (20).
- 6273709 — semana 0–24 h com pistas por sobreposição visual (2).
- esta volta — Perfil: as quatro linhas dizem o estado inteiro numa linha (11); "0 de 64 avisos ativos" vira "nenhum aviso marcado." (12); "RECORDAR" em frase (17, parte).
- **Tentado e revertido:** "‹ Notas" no canto da página (defeito 5). Com o chevron — em glifo ou em texto, mesmo com `lineLimit(1).fixedSize()` — `EscritaVisivelTests.aLinhaFicaNoPapelEmCadaQuadroDaGaveta` reprova em AX5 no 17e ("a linha já estava fora do papel antes da gaveta", janela de 15 pt); com "Notas" puro passa. Causa não achada em três corridas; fica aberto para quem mexer no pé da página.
- Suíte: 1199 testes / 180 suítes, verde no iPhone 17e (C7341E64) em cada commit. O 17e foi ligado por mim para a suíte; o Air ficou desligado.
- c346ac6 — linha da nota na ordem dos campos do método (14); Perfil sem subtítulo cortado e sem a frase dos avisos repetida (11, 12).
- cea9800 — rótulos dos campos da forma em frase (17, campos); pílula do mês com a primeira palavra (26).
- 47c825b — busca dos Trabalhos vira a linha das Notas (19).
- **Decisões do dono que a auditoria listou e que ficam como estão:** o risco de feriado no ano (03/set, "em qualquer visualização"); o chevron nas ações da Lente (ADR 10k: "a ação se reconhece pelo chevron"); a medida como título na Latência (G4 da L1); os três andares do calendário; o pé da página.
- **Ainda aberto, e por quê:** Trabalho fora da família (7 em E) pede desenho com veredito do dono — o campo em caixa é `.cartao(.campo)` do sistema, usado também na ficha e na Lente, e trocar o estilo muda três telas de uma vez; a caixa dos campos da forma na página, pelo mesmo motivo; o pré-aviso antes do diálogo de permissão (15) seria uma coisa a mais na tela, e foi deixado de lado; "‹ Notas" (5), ver acima.

## H. Laço de simplicidade (goal de 14/09)

- 0ba3a47 — Trabalho: apoio, praticar e dificuldade nascem recolhidas; a folha abre com intenção, o que preparar e o próximo ato. Antes/depois em `auditoria-ux-13-09/air-trabalho-antes-1.png` / `-depois-1.png`.
- **Não feito e por quê:** "Sua versão" recolhida — `JornadaC9UITests` digita nela e toca "Guardar minha versão" sem abrir seção; colapsar quebra a jornada guardada. Precisa de decisão: quando "Delegar" é a escolha, a versão própria devia ser um toque a mais, e o teste devia abrir a seção.
- 1b50dcc — Página: a régua de formatos sai (ordem do dono, 14/09); título/seção/lista nascem do texto ao concluir; no pé do teclado fica só o glifo de recolher. Trabalhos: linha no lugar do cartão. Os fluxos maestro `caderno-*.yaml` que tocavam a régua ficam sem alvo — aposentar ou reescrever pelo texto.
- 162df2c — Notas: "Todas ⌄ · Mais recentes ⌄" saem do cabeçalho; sobra título, buscar, trabalhos › e a lista. Captura `17e-notas-sem-menus.png`.
- **Próximas causas, na ordem do goal:** o pé da página (Trabalhar nisto + Analisar/Recordar/Anexar/Lente — "Analisar" já é automático; proposta com vídeo para o dono); o menu de domínio por linha nas Notas (correção vira toque longo); os três andares do calendário; o Perfil (12 seções → o que é ajuste de verdade); vídeo de movimento de cada tela.
- 2a7c95f — Notas: domínio por linha vira identidade (sem menu); corrigir no toque longo. Captura `17e-notas-dominio-identidade.png`.
- 475c1e2 — Perfil: consulta nasce recolhida (sábia, latência, métodos, calendário); ajustes abertos. Captura `17e-perfil-recolhido.png`.
- 928b23e — Página: "Analisar" e "Recordar" saem do pé; ficam Trabalhar nisto, Anexar e Lente. Vídeo de 27 s com o pé: `pe-pagina-14-09.mp4` (17e, large; teclado com o glifo, texto, pé de três). Fluxos maestro que tocavam Analisar/Recordar: `auto-analise`, `recordar*`, `aceite`, `auditoria-completa` e mais quatro — sem alvo.
- 2eeebfc — Calendário: escalas e Hoje sob o título; pé com campo + pílula. Captura `air-calendario-2-andares.png`.
- 5191eb8 — Trabalho: um primário por folha ("Preparar este ato" vira secundário).
- Vídeo das abas `abas-14-09.mp4` (Air, 20 s: Notas → Calendário → Padrões). Nos quadros de 12 s e 18 s a cápsula da pílula aparece no Calendário com Padrões na tela; **ao vivo não reproduz** (duas capturas `simctl` com a cápsula certa depois de toques rápidos) — suspeita do gravador, que estica o relógio e não grava quadro parado (memória `recordvideo-estica-o-relogio`). Fica como risco a filmar de novo com `--fps`.

## I. Placar refeito depois de oito voltas (14/09, 11h)

Mesma régua da seção A. Sem vídeo por tela além dos dois gravados; sem o veredito do dono, que é quem julga motion e acabamento. Estimativa minha, para dizer a distância, não para fechar o portão.

| tela | Design | Simplicidade | Componentes | Texto | Estado honesto | Hermes | média | o que ainda falta para 9 |
|---|---|---|---|---|---|---|---|---|
| 1 Página | 7 | 8 | 7 | 7 | 8 | 7 | **7,3** | campos da forma em caixa branca; cartão + campos ainda são duas camadas; "Notas" no canto como título |
| 2 Notas | 8 | 9 | 8 | 8 | 8 | 9 | **8,3** | subtítulo por linha ainda mistura forma e data; "trabalhos ›" como texto cinza |
| 3 Conversa | 8 | 8 | 9 | 7 | 7 | 9 | **8,0** | conversa vazia é uma tela em branco; pensando/resposta não vistos com conta |
| 4 Calendário | 8 | 8 | 7 | 8 | 7 | 7 | **7,5** | trilho sob o título ainda tem 7 controles; mês e ano continuam densos |
| 5 Ficha | 7 | 7 | 6 | 8 | 8 | 5 | **6,8** | três cartões cinza; Repete + sete chips; título sem cara de editável |
| 6 Padrões | 8 | 9 | 9 | 8 | 8 | 9 | **8,5** | quase lá: falta o vídeo e o olho do dono |
| 7 Perfil | 8 | 8 | 8 | 6 | 8 | 8 | **7,7** | letra miúda de quatro linhas por seção; "Latência da descoberta" |
| 8 Trabalho | 6 | 7 | 6 | 6 | 8 | 5 | **6,3** | campos em caixa; "Sua versão" sempre aberta; ainda três telas de rolagem quando há versão |
| 9 Recordar | 6 | 8 | 7 | 8 | 8 | 6 | **7,2** | "hoje não" sem cara de botão; folha vazia com um caret |
| 10 Lente | 7 | 7 | 8 | 7 | 8 | 7 | **7,3** | ações com chevron; letra miúda sob cada cabeçalho |
| 11 Navegação | 8 | 9 | 7 | 7 | 8 | 8 | **7,8** | três palavras para sair de folha; puxador de 3 pt |
| **média** | 7,4 | 8,0 | 7,5 | 7,3 | 7,8 | 7,3 | **7,5** | era 6,9 em 13/09 |

O portão do goal (9 em tudo, com vídeo e "aqui a pessoa faz uma coisa só") não fecha sem duas coisas que só o dono dá: o veredito em vídeo e a decisão sobre as caixas do sistema (`.cartao(.campo)`, que vive na página, na ficha, no Trabalho e na Lente). Tudo o que dava para decidir sozinho, pela régua do goal, foi decidido e está em `main`.
- 85430f8 — Ficha: os sete dias da semana só com repetição ou ao tocar "Repete". Captura `air-ficha-sem-chips.png`. A frase da hora passada vira "nada vai tocar" nas duas telas.
- 5d18351 — Cartão: `.campo` vira texto no papel com fio; ficha, Trabalho, intercâmbio e agendamento perdem a caixa cinza de uma vez. Captura `air-ficha-no-papel.png`. Trabalho e intercâmbio não fotografados nesta volta (mesmo modificador).
- 416dc1f — Campos da forma na página: texto no papel com fio (volta 11). Captura `air-campos-no-papel.png`.
- fa65b43 — Notas: buscar e perguntar num campo flutuante sobre a pílula, com microfone (`air-notas-campo-pe.png`, `air-notas-busca-correr.png`); "buscar" do topo e marca "?" fora. Página: barra de fechar teclado fora (`air-pagina-sem-barra.png`). Substitui a ADR 10i nesses dois pontos — a ADR precisa de nota.
- 2f9cded — Página: pé vira o campo flutuante ("+", pergunta, microfone que dita na página). Captura `air-pagina-campo-pe.png`. As três abas de conteúdo partilham agora um só idioma de pé.
- 94211f3 — REVERTIDO 2eeebfc: as escalas e o Hoje do calendário voltam para o pé (dono, 14/09: "mudou para o topo sem sentido"). O pé do calendário, com escalas, campo e pílula, é decisão do dono — não mexer.
- c160bb5 — `CampoFlutuante` em `Traco/Componentes`: um pé para Notas, página e calendário (14). Calendário em UMA linha: escalas + campo; Hoje condicional; lista/grade no "+" (15, ordem do dono). Captura `air-cal-uma-linha.png`.

## J. Placar refeito depois de quinze voltas (14/09, 12h30)

Mesma régua. Estimativa minha; o veredito do dono em vídeo continua a ser o portão.

| tela | Design | Simplicidade | Componentes | Texto | Estado honesto | Hermes | média | o que ainda falta para 9 |
|---|---|---|---|---|---|---|---|---|
| 1 Página | 8 | 9 | 8 | 7 | 8 | 8 | **8,0** | "Notas" no canto como título; o cartão e os campos ainda são duas camadas |
| 2 Notas | 8 | 9 | 9 | 8 | 8 | 9 | **8,5** | "trabalhos ›" como texto cinza; subtítulo mistura forma e data |
| 3 Conversa | 8 | 8 | 9 | 7 | 7 | 9 | **8,0** | conversa vazia em branco; pensando/resposta não vistos com conta |
| 4 Calendário | 8 | 9 | 8 | 8 | 7 | 8 | **8,0** | mês e ano densos; lista/grade escondido no "+" pede um toque a mais |
| 5 Ficha | 8 | 8 | 8 | 8 | 8 | 8 | **8,0** | título sem cara de editável; "Repete" pede toque para ver os dias |
| 6 Padrões | 8 | 9 | 9 | 8 | 8 | 9 | **8,5** | vídeo e olho do dono |
| 7 Perfil | 8 | 8 | 8 | 6 | 8 | 8 | **7,7** | letra miúda de quatro linhas por seção; "Latência da descoberta" |
| 8 Trabalho | 7 | 7 | 7 | 6 | 8 | 7 | **7,0** | "Sua versão" sempre aberta (UITest); ainda três telas com versão |
| 9 Recordar | 6 | 8 | 7 | 8 | 8 | 6 | **7,2** | folha vazia com um caret; RECORDAR virou frase, o resto ficou |
| 10 Lente | 7 | 7 | 8 | 7 | 8 | 7 | **7,3** | letra miúda sob cada cabeçalho; ações com chevron |
| 11 Navegação | 8 | 9 | 8 | 7 | 8 | 8 | **8,0** | três palavras para sair de folha; puxador de 3 pt |
| **média** | 7,6 | 8,3 | 8,1 | 7,3 | 7,8 | 7,9 | **7,8** | era 6,9 em 13/09 e 7,5 há dez voltas |

**Decisões do dono desta manhã que reescrevem ADRs:** a busca e a pergunta das Notas moram num campo flutuante sobre a pílula (contraria a ADR 10i, que as pôs no topo); a régua de formatos não existe (contraria o §22 do SPEC e a ADR 05f no ponto da régua); o pé do calendário é uma linha (escalas + campo). As três precisam de nota nas ADRs.
- f55c2c9 — Lente: sem as frases de explicação sob cada cabeçalho (16).
- 36332dc — Página: "‹ Notas" no canto (17; defeito 5 fechado).
- 057ff5b — Calendário: a linha única volta a ter o material (cápsula de vidro, trilha, círculo com sombra) e o alternador lista/grade (19). Captura `air-cal-vidro.png`. Perfil sem o parágrafo sob Permissões (18).
- Vídeo `pe-calendario-14-09.mp4` (Air, 32 s): D → S → M → D na cápsula única, o Hoje entrando e saindo, o texto no campo com o enviar a aparecer. Quando o Hoje está à vista, a dica do campo corta em "Dentista…" — é o estado passageiro.
- fa5696b — Calendário: Novo/Colar no toque longo do alternador (20).
- Vídeo `pe-notas-14-09.mp4` (Air, 26 s): o campo do pé sobe com o teclado, "correr" filtra ao vivo ("1 nota com Correr" + pelo sentido), enviar abre a conversa com a pergunta. **Achado novo (engana):** sem conta Grok e com o modelo do aparelho "pronto" no Perfil, a resposta falha com "Falta a conta. O que escreveu continua aqui." e oferece "Perguntar de novo" — `Sabia.disponivel` é verdadeiro pelo modelo de bordo, mas a rota `responder` das Notas cai no Grok. Próxima causa: a falha tem de dizer a verdade da rota (Politica) ou a rota tem de usar o modelo do aparelho.
- 4ec7ce6 — Notas: falha sem conta com a frase da Politica e saída para o Perfil (21).
- Vídeo `padroes-perfil-14-09.mp4` (Air, 21 s): Padrões rolando; Perfil com Conta recolhendo e abrindo.
- e8d0c76 — Padrões e Perfil sem a marca "?" (22). UITests EsperaComEstado e PerguntaSobrevive ficam sem "perguntar-modo" — reescrever pelo campo "busca-notas".
- Vídeo `trabalho-14-09.mp4` (Air, 21 s): lista de Trabalhos em linha, a folha abrindo com intenção, o que preparar e o próximo ato; apoio, dificuldade e histórico recolhidos; campos no papel; um primário.
- 23b2c5a — Trabalho: "Sua versão" recolhida em "Escrever eu mesmo"; abre pelo "Ir ao próximo passo" (23).
