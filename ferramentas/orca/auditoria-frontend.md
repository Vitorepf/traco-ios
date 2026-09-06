# Auditoria de front-end — volta 9 (nota base por tela)

Fable front-end, 05/09/2026, branch `Vitorepf/volta-9-auditoria` (base main e51550e). Método: `design-router` fase 5 (auditar antes de tocar) ancorado em VISAO-PRODUTO, SISTEMA-CLARO e SPEC §11/§20/§21/§22; `curva-zero` para a contagem de toques e decisões. Nenhum arquivo de código editado. As notas são a **base** que o RUMO pede: a régua é o scorecard da ESTEIRA (mínimo 9 para mesclar), com 0–10 por dimensão.

**Instrumento.** Build do branch via `com-trava.sh` (BUILD SUCCEEDED, um aviso pré-existente em `EditorBlocoView.swift:271`), instalado no iPhone Air **64F7B8B4** (ligado e desligado por mim; iOS 26.5). Dados plantados na mão: 8 notas por `traco://anotar`, 3 notas digitadas (WOOP vestido e preenchido, "eu sou um vencedor", pergunta "?"), 1 nota de blocos (título, lista, tarefa, tabela, citação, código), 3 compromissos pela prosa (Dentista sexta 14:30, Reunião amanhã 10h, Correr toda terça 6:30), 1 Trabalho com versão preparada pela IA do aparelho e um ato agendado, 2 provas do Recordar. Toques por `cliclick` na janela do Simulator (teclado físico ligado: o teclado de software não aparece nas capturas). Sem maestro. **Restaurado ao fim e conferido:** `content_size` = large (era large), `appearance` = light (era light), `ReduceMotionEnabled` = 0 (era 0). O app foi reinstalado do zero para os estados vazios, então os dados de teste não ficaram no aparelho. Simuladores de outros (17 Pro, 17 Pro Max, 17e, o iPhone 17 do dono) não foram tocados.

**Capturas:** `ferramentas/orca/v9-<tela>-<estado>.png` (89, reduzidas a 900 px de largura e 256 cores depois da revisão; os originais a 1260 px estão no commit 1c6aa62) e seis vídeos `v9-<tela>-movimento.mp4` (8–14 s, re-codificados a 630 px). Uma captura é do estado que ela mostra, não do nome: conferi o conteúdo de cada uma antes de citá-la.

**Revisão G3** (`revisao-v9-auditoria.md`, Fable revisor, 05/09, iPhone 17e): 89/89 capturas e 6/6 vídeos conferidos; três amostras reproduzidas no 17e, com quatro capturas próprias `v9-rev-*-17e.png`. Este texto já incorpora as seis correções que a revisão pediu: duas células recalibradas na tabela (Calendário e Trabalho, Estado honesto), causa-raiz do defeito 1, defeito 2 estendido ao Trabalho, três apontadores de evidência corrigidos, três capturas órfãs citadas (uma renomeada) e o inventário completado.

## Tabela-resumo FINAL (nota base do RUMO, recalibrada pelo G3)

| tela | Design | Simplicidade | Movimento | Componentes | Acessibilidade | Estado honesto | média |
|---|---|---|---|---|---|---|---|
| 1 Página em branco + Caderno | 7 | 6 | 7 | 6 | 6 | 8 | 6,7 |
| 2 Notas + barra de baixo | 7 | 7 | 8 | 6 | 6 | 8 | 7,0 |
| 3 Calendário + ficha | 8 | 7 | 8 | 7 | 7 | **6** | 7,2 |
| 4 Recordar | 5 | 8 | 5 | 6 | 5 | 8 | 6,2 |
| 5 Perfil | 7 | 6 | 9 | 7 | 8 | 9 | 7,7 |
| 6 Trabalho | 5 | 5 | 7 | 4 | 7 | **8** | 6,0 |
| 7 Padrões | 7 | 8 | 8 | 7 | 6 | 9 | 7,5 |
| 8 Camadas / navegação | 8 | 8 | 7 | 7 | 6 | 9 | 7,5 |

Duas células desceram na revisão: Calendário, Estado honesto 7 → 6 (além da promessa sob permissão não perguntada, a ficha promete "Toca hoje às 09:00" para uma hora já passada, reprodução do revisor) e Trabalho, Estado honesto 9 → 8 (a mesma promessa não autorizada em `v9-trabalho-agendar.png`). Médias por dimensão: Design 6,8 · Simplicidade 6,9 · Movimento 7,4 · Componentes 6,2 · Acessibilidade 6,4 · Estado honesto 8,1. Nenhuma tela chega a 9 em todas as dimensões. As dimensões mais baixas no conjunto são **Componentes** (média 6,2) e **Acessibilidade** (6,4): é exatamente o que a V10 (fundação) e a V8 (acessibilidade, ainda não mesclada) atacam. Onde a V8 já corrige um achado, está dito.

## 1. Página em branco + Caderno

**Capturas.** Vazia `v9-pagina-vazia.png` e primeira abertura `v9-pagina-vazia-primeira.png`; forma vestida automaticamente com cartão `v9-pagina-cartao-vestido.png`; folha dos campos `v9-pagina-folha-campos.png`, preenchida `v9-pagina-folha-preenchida.png`; forma na página com o pé de ações `v9-pagina-forma-vestida-preenchida.png`; cartão de aviso `v9-pagina-cartao-aviso.png`; pergunta e sábia (pensando `v9-pagina-sabia.png`, resposta `v9-pagina-sabia-resposta.png`); blocos do caderno `v9-caderno-blocos.png`; menu "Todas" (abriu a Lente; ver defeito) `v9-caderno-menu-todas.png`; AX3 `v9-ax3-pagina-cartao.png`, AX5 `v9-ax5-pagina-cartao.png`; movimento `v9-pagina-movimento.mp4` (a forma vestindo e o cartão entrando, 12 s). Estados não capturados: falha de gravação (não provocável sem código); carregando (não existe: tudo local).

**Curva-zero.** Escrever e concluir: 2 toques (página, Concluir) e 0 decisões. Vestir: automático; abrir os campos: +1 toque, 1 decisão (abrir ou deixar como nota). Boa curva na tarefa principal.

| dimensão | nota | evidência e defeito (lei) |
|---|---|---|
| Design | 7 | O cartão da forma flutua **sobre** os campos que a própria forma acabou de abrir: em `v9-pagina-cartao-vestido.png` ele cobre o rótulo DEPOIS DISTO e em `v9-pagina-sabia-resposta.png` cobre o campo OBSTÁCULO INTERNO. Duas camadas disputando a mesma zona (`law-of-figure-ground`, §21 "camada que desliza precisa de profundidade" vale para camada que cobre). "Voltar à página" na folha dos campos é o tint padrão do botão, âmbar `#D9A542` sobre branco (`PaginaView.swift:31-35` não pinta; `RecordarView.swift:416-422` pinta `tintaSuave`): reprova como texto (ADR 02h, 04d). |
| Simplicidade | 6 | O pé da página com a nota preenchida soma régua (6 chips + Todas + teclado) + "Trabalhar nisto" + Analisar · Recordar · Anexar · Lente = 13 alvos (`v9-pagina-forma-vestida-preenchida.png`), todos com o mesmo peso (`hicks-law`, `von-restorff-effect`); é o item "visto e não tocado" da FILA. A régua corta o chip "C…" sem sinal de rolagem (`v9-caderno-apos-menu.png`, página vazia com a régua de volta depois de fechar o menu; `law-of-continuity`). A nota que nasce só com um bloco "SEÇÃO" vazio vira **linha em branco** na lista das Notas (`v9-escuro-notas.png`, terceira linha): conteúdo vazio deveria não ser nota ou ter nome. |
| Movimento | 7 | Cartão entra em easeOut 0,26 e sai em 0,18 (`Tema.cartao`), coerente e visível no vídeo. Mas o ponto de "lendo…" pulsa em `repeatForever` sem checar movimento reduzido (`PaginaView.swift:328`) e a gaveta do caderno recebe `reduzido: false` cravado (`CadernoView.swift:165-166`); a V8 fecha os dois (ADR 05t). |
| Componentes | 6 | Três `ButtonStyle` privados só nesta área (`CartaoAnaliseView.swift:291,302`, `PaginaView.swift:612`) além de `PressaoDiscreta`; o rótulo de seção (label + tracking) reescrito em 32 lugares de 14 arquivos; o cartão com trilho âmbar não existe fora de `CartaoAnaliseView`. |
| Acessibilidade | 6 | Em AX3 e AX5 o cartão ocupa a tela e as ações "Abrir os campos / Deixar como nota" ficam fora da vista (`v9-ax3-pagina-cartao.png`, `v9-ax5-pagina-cartao.png`); a V8 prende as ações no pé. A régua é chrome fixo por decisão do §22. |
| Estado honesto | 8 | A sábia diz o que leu ("leu o começo de 6 notas suas · foram junto…") e o aviso nomeia a falta de prova. Falta: "Todas" com a nota preenchida abriu a **Lente** em vez do menu das formas (`v9-caderno-menu-todas.png`): o alvo da régua (y≈745) e o da linha de ações (y≈850) trocaram de lugar entre a página vazia e a preenchida, e o toque caiu no vizinho. O revisor reproduziu no 17e com outra manifestação e a mesma causa: 3 s depois de digitar, o cartão WOOP vestiu sozinho e **substituiu a régua e a linha de ações inteiras** (`v9-rev-pagina-cartao-toma-o-pe-17e.png`); o toque mirado em "Todas" caiu no texto do cartão. É chrome que some sob o dedo, posição instável e não alvo pequeno (`fitts-law`). |

## 2. Notas + barra de baixo

**Capturas.** Lista `v9-notas-lista.png`; vazia `v9-notas-vazia.png`; ordem `v9-notas-ordem-menu.png`; filtro WOOP `v9-notas-filtro-woop.png`; menu do domínio `v9-notas-dominio-menu.png`; "Como contexto" `v9-notas-contexto.png`; busca `v9-notas-busca.png`; sábia pensando `v9-notas-sabia-pensando.png` e falha `v9-notas-sabia-falha.png`; escuro `v9-escuro-notas.png` (fica claro: um mundo só, confirmado); AX3 `v9-ax3-notas.png`; AX5 `v9-ax5-notas.png`; movimento `v9-notas-movimento.mp4` (busca filtrando, cartão da sábia subindo, 10 s). Não vi A VOLTA: com os dados plantados a fila do dia não existia. PELO SENTIDO aparece no vídeo das Notas (quadros 9–10, "falam disto sem usar a palavra", ao perguntar "que metodo uso para decidir a viagem"); na busca por "dentista" só vieram letras, porque o índice de sentido acabara de nascer.

**Curva-zero.** Achar por palavra: 1 toque + digitar (a lista filtra ao vivo); perguntar: a mesma barra + enter, 0 decisões. Filtrar por forma: 1 toque em 29 chips.

| dimensão | nota | evidência e defeito (lei) |
|---|---|---|
| Design | 7 | "Trabalhos" é texto âmbar com ícone no canto superior esquerdo (`NotasView.swift:50-57`): navegação vestida de link, o mesmo defeito que o §20 tirou do rodapé e a ADR 05f do topo (`law-of-similarity`, `critique-affordance`). A régua de chips corta em "E…" sem sinal (`law-of-continuity`, FILA). O cartão da sábia em falha guarda um vão vazio de ~120 pt entre a pergunta e "a sábia não respondeu." (`v9-notas-sabia-falha.png`, `critique-composition`). |
| Simplicidade | 7 | A barra "Buscar ou perguntar" no pé resolve a ADR 05e; a régua com 29 chips (formas + domínios + trancadas) é a decisão mais longa da tela (`hicks-law`). |
| Movimento | 8 | Cartão sobe com `.move(.bottom)+opacity` 0,25 s e em movimento reduzido vira corte seco (`NotasView.swift:70-71,197`): coerente com §21. A seleção em lote anima 0,15 s. |
| Componentes | 6 | A cápsula de filtro existe em três versões locais (`NotasView.swift:255`, `:372`, `:456`) mais a de `VersoesView.swift:31,124` e `RedeView.swift:81`; só `ChipDominio` é compartilhado. |
| Acessibilidade | 6 | Em AX5 o título da nota corta em uma linha ("Quero correr d…") e o menu de ordem vira "M…" (`v9-ax5-notas.png`); em AX3 "Mais r…" (`v9-ax3-notas.png`). A V8 troca o menu por ícone; o corte do título continua aberto (`critique-typography`). |
| Estado honesto | 8 | "a sábia não respondeu. Repetir pergunta" e "2 notas com 'dentista'" dizem a verdade; a vazia oferece o caminho ("escrever na página"). Menos: a linha em branco da nota vazia (ver tela 1). |

## 3. Calendário + ficha

**Capturas.** Dia vazio `v9-calendario-dia-vazio.png`, dia com evento `v9-calendario-dia-evento.png`, toast de aviso desligado `v9-calendario-dia.png`; prosa digitada `v9-calendario-prosa-digitada.png`; ficha `v9-calendario-ficha.png`, fim com DO CADERNO e Apagar `v9-calendario-ficha-fim.png`, repetição `v9-calendario-ficha-repete.png`, AVISO reaberto `v9-calendario-ficha-aviso-estado.png`; semana `v9-calendario-semana.png`, mês `v9-calendario-mes.png`, ano `v9-calendario-ano.png`, lista `v9-calendario-lista.png`; consulta em prosa `v9-calendario-consulta.png`; ficha do sistema (feriado) `v9-calendario-ficha-sistema.png`; folha de permissão do sistema `v9-calendario-vazio.png`, sem permissão `v9-calendario-sem-permissao.png` (com `v9-perfil-sem-permissao.png`); outro dia pela tira da semana `v9-calendario-dia-30-ago.png` (30 de agosto, vazio; era `v9-calendario-dia-11.png`, nome errado); misparse `v9-calendario-prosa-misparse.png` e a reprodução do revisor `v9-rev-prosa-misparse-ficha-17e.png`, `v9-rev-prosa-misparse-lista-17e.png`; escuro `v9-escuro-calendario.png`; AX3 `v9-ax3-calendario.png`, AX5 `v9-ax5-calendario.png`; movimento `v9-calendario-movimento.mp4` (D→S→M→A→D e um arrasto, 14 s) e `v9-reduce-motion-movimento.mp4` (mesma troca com Reduzir Movimento, 13 s).

**Curva-zero.** Marcar: 3 toques (campo, enviar, Pronto) + digitar, 0 decisões explícitas; a antecedência do aviso é decidida por padrão ("na hora") e só se vê na ficha.

| dimensão | nota | evidência e defeito (lei) |
|---|---|---|
| Design | 8 | É o clone e lê caro. Na semana e no mês os títulos dos eventos saem a ~8 pt e cortados ("Reuniã", "Dentis", `v9-calendario-semana.png`; `CalendarioEscalas.swift:399,412,543,564` em `.system(size:)`): tinta de domínio bonita, texto ilegível (`critique-typography`). Três barras empilhadas no pé (escalas + Hoje, prosa, navegação) continuam o item da FILA (`critique-information-density`). |
| Simplicidade | 7 | A prosa "7 de setembro" **criou um compromisso** chamado "7 de setembro" no dia âncora às 9h em vez de levar ao dia (`v9-calendario-prosa-misparse.png`, no Air caiu no dia 15 porque a âncora estava lá; no 17e do revisor caiu em 05/09, `v9-rev-prosa-misparse-lista-17e.png`). Causa-raiz: `CalendarioFrase` **não conhece nome de mês** (nenhum "setembro"/"janeiro" em `Calendario.swift`; só "dia 15", dias da semana e relativos), então "N de <mês>" nunca é data: vira título e cai na âncora. Não é desempate entre marcar e consultar; é padrão ausente (ADR 02i; `teslers-law`: a ambiguidade tem de ser absorvida pelo parser ou devolvida como pergunta, nunca virar compromisso). Apaguei o compromisso em seguida. |
| Movimento | 8 | Desdobramento por geometria casada com mola 0,55/0,86 (`CalendarioTema.morph`), um objeto e um driver, visível no vídeo. Com Reduzir Movimento o título cruza "2026" e "5 de setembro" legíveis na mesma linha por ~0,3 s (`v9-reduce-motion-movimento.mp4`, t≈1 s, transição M→A): cross-fade entre irmãos (§21). |
| Componentes | 7 | `CalendarioTema` é um segundo sistema: `PressaoClara` ao lado de `PressaoDiscreta`, `chipActivo`, `CalendarioToast` ao lado do toast da Sessão, e sete tamanhos fixos (`CalendarioEscalas.swift:198…668` ×6, `CalendarioView.swift:186`). A ficha tem o melhor cabeçalho do app (✕ + Pronto) e ninguém mais o usa. |
| Acessibilidade | 7 | Horas, chips e grade presos por decisão (ADR 02h/05t); em AX5 o título e a ficha crescem bem (`v9-ax5-calendario.png`). O ano a 8 pt segue desenho, não leitura. |
| Estado honesto | 6 | A ficha diz "Toca sexta-feira, 11 de set. às 14:30." enquanto o app, no mesmo minuto, avisa "os avisos do Traço estão desligados no iPhone" (`v9-calendario-ficha-aviso-estado.png` × `v9-calendario-dia.png`): a promessa só cai quando o estado é `.negado` (`CalendarioFicha.swift:166-176`), e no não-perguntado ela mente (ADR 04a, pergunta 2). Segunda mentira na mesma seção, reproduzida pelo revisor: o compromisso criado pela prosa às 20:53 promete "Toca hoje às 09:00", hora já passada, sem aviso disso (`v9-rev-prosa-misparse-ficha-17e.png`). Com o calendário do aparelho negado, só o Perfil conta (`v9-perfil-sem-permissao.png`); o próprio calendário não diz nada (`v9-calendario-sem-permissao.png`, ADR 03e). A lista do dia vazio diz "Nada marcado." (frase de desculpa que SISTEMA-CLARO §7.6 pede para não existir). |

## 4. Recordar

**Capturas.** Nota de onde parte `v9-recordar-00-nota-aberta.png`; transição esconder→escrever `v9-recordar-prova.png`; escrever `v9-recordar-escrever.png`, `v9-recordar-escrever-2.png`; revelar `v9-recordar-revelar.png`, com O QUE NÃO VOLTOU `v9-recordar-revelar-2.png`; "hoje não" `v9-recordar-hoje-nao.png`; AX3 `v9-ax3-recordar.png`, AX5 `v9-ax5-recordar.png`; movimento `v9-recordar-movimento.mp4` (esconder, escrever, revelar, 9 s). Vazio não capturado: `traco://recordar` sem nota mostra só um toast na página (`Sessao.swift:1469`) que passou antes da captura.

**Curva-zero.** 1 toque (Recordar) + escrever + 1 toque (Revelar); adiar é 1 toque. Curta e certa.

| dimensão | nota | evidência e defeito (lei) |
|---|---|---|
| Design | 5 | A tela de escrever é um campo e dois textos soltos no pé, "Revelar" e "hoje não", sem cara de botão (`v9-recordar-escrever.png`, `critique-affordance`); a ação principal não se destaca (`von-restorff-effect`). No revelar, DE MEMÓRIA fica centrado verticalmente contra A NOTA: os dois rótulos não partilham linha de base (`v9-recordar-revelar-2.png`, `law-of-continuity`). |
| Simplicidade | 8 | Uma pergunta, uma resposta, uma revelação; O QUE NÃO VOLTOU sem placar (§12). |
| Movimento | 5 | `v9-recordar-prova.png` pegou "Ouça uma última vez, a nota vai se esconder." e "O que estava escrito?" legíveis **um sobre o outro**: cross-fade entre irmãos com `delay(0.08)` e offsets soltos (`RecordarView.swift:392-395`), a violação literal do §21. Durações 0,3/0,35/0,4 sem token. |
| Componentes | 6 | `PrimarioStyle` próprio (`RecordarView.swift:467`), "voltar" e "Voltar à página" desenhados aqui, rótulo RECORDAR repetido à mão. |
| Acessibilidade | 5 | Em AX5 "vol-tar" e "RECOR-DAR" hifenizam e a pergunta corta em "obstáculo inter…" (`v9-ax5-recordar.png`); a V8 trava o cabeçalho em xxxLarge e dá `fixedSize` à pergunta. |
| Estado honesto | 8 | "volta amanhã." diz o efeito do adiar; mas o toast nasce em cima de "Trabalhar nisto" e das quatro ações (`v9-recordar-hoje-nao.png`): a mensagem tapa os controles. |

## 5. Perfil

**Capturas.** Topo `v9-perfil-1.png`, rolagens `v9-perfil-2.png`, `v9-perfil-4.png`; férias `v9-perfil-ferias.png` e ligado `v9-perfil-ferias-ligado.png`; sem permissão de calendário `v9-perfil-sem-permissao.png`; AX3 `v9-ax3-perfil.png`, AX5 `v9-ax5-perfil.png`. Sem movimento próprio; sem estado de carregamento.

**Curva-zero.** Ligar férias: 1 toque na aba + 2 rolagens de tela + 1 toque; 1 decisão (até quando). A primeira ação útil está a duas telas do topo.

| dimensão | nota | evidência e defeito (lei) |
|---|---|---|
| Design | 7 | O cartão CONTA gasta a primeira tela com um parágrafo que se lê uma vez (FILA, `critique-information-density`). Ações como "Entrar com a conta Grok", "Abrir os Ajustes do Traço" e "Esquecer tudo" são texto âmbar ou linha com chevron, três formas para a mesma classe de ato (`law-of-similarity`). |
| Simplicidade | 6 | Quatro telas de rolagem e 12 seções; o que se toca (férias, análise automática, avisos) está no meio (`fitts-law`). |
| Movimento | 9 | Só toggles do sistema. n/a quase: não há o que errar. |
| Componentes | 7 | Linha com chevron (`PerfilView.swift:747`), steppers dos horários e o cartão de seção são locais; o selo SEU a 9 pt fixo (`PerfilView.swift:237`, `.system(size: 9)`) é o mesmo desenho do PRÉ-MORTEM dos Padrões; nada de `Traco/Componentes`. |
| Acessibilidade | 8 | Escala inteira em AX3 e AX5 sem corte (`v9-ax5-perfil.png`); toggles com rótulo. |
| Estado honesto | 9 | "sem conta — tudo funciona aqui no aparelho", "acesso negado. O campo volta a mostrar um exemplo", "desligados. Sem eles, nada te cobra", "ligado até 12 de setembro": cada estado tem frase e saída. |

## 6. Trabalho

**Capturas.** Lista vazia `v9-trabalho-lista-vazia.png`, lista `v9-trabalho-lista.png`; Trabalho novo `v9-trabalho-1.png`…`v9-trabalho-4.png`; preparando `v9-trabalho-preparando.png`; versão `v9-trabalho-versao-1.png`, `v9-trabalho-versao-2.png`; conferência `v9-trabalho-conferencia.png`, `-2`, `-3`; ato preparado `v9-trabalho-ato-1.png`; agendamento com aviso `v9-trabalho-agendar.png`; AX3 `v9-ax3-trabalho-lista.png`, AX5 `v9-ax5-trabalho-lista.png`. Movimento: quase inexistente (não gravado). Falha da IA: não provocável sem cortar a rede do simulador (a preparação usou o modelo do aparelho).

**Curva-zero.** Intenção → versão preparada: Notas (1) + Trabalhos (1) + campo (1) + digitar + Começar (1) + campo do pedido (1) + digitar + Preparar (1) = 6 toques e 2 digitações; a decisão de apoio (delegar/praticar/combinar) está escondida num disclosure e nunca é oferecida no caminho.

| dimensão | nota | evidência e defeito (lei) |
|---|---|---|
| Design | 5 | É outra família: formulário cru do sistema, chips cinza e chevrons, sem papel, sem cartão tingido, sem cabeçalho de ficha (`v9-trabalho-1.png` ao lado de `v9-calendario-ficha.png`). O botão "Preparar com IA" é cinza igual a "Começar este trabalho" e, depois da primeira versão, vira uma cápsula marrom escura (`v9-trabalho-versao-1.png`): o mesmo botão com duas roupas e nenhuma do sistema (`law-of-similarity`, SISTEMA-CLARO §2.3). |
| Simplicidade | 5 | Cinco telas de rolagem, oito `DisclosureGroup` (`TrabalhoView.swift:165,220,283,469,497,500`), conferência em prosa densa (`v9-trabalho-conferencia.png`). Toquei "Preparar com IA" com o pedido vazio e nada aconteceu: o botão está desabilitado (`TrabalhoView.swift:210`) mas não parece (`critique-affordance`). |
| Movimento | 7 | Nenhuma animação própria além de um `withAnimation` sem curva (`TrabalhoView.swift:73`); o spinner de "A IA está preparando…" com "Cancelar preparação" é o estado de carga mais honesto do app. |
| Componentes | 4 | `AcaoTrabalhoStyle` próprio (`TrabalhoView.swift:678`), zero uso de `Tema.chip`/`Tema.label`, "Voltar" em cápsula de 30 pt só aqui (`TrabalhosView.swift`), cabeçalho "Trabalho" centrado só aqui. |
| Acessibilidade | 7 | Escala bem em AX5 (`v9-ax5-trabalho-lista.png`); "Voltar" e os chips cinza têm alvo por reserva, não por `contentShape` (ADR 05t, "idioma frame sobrevive em Trabalho"). |
| Estado honesto | 8 | "Realização ainda não confirmada", "Marcar um horário não confirma a realização", "Não avaliado", "Apple Intelligence no aparelho", "o modelo do aparelho não devolveu revisão válida": produzido, agendado, executado e observado distintos. Menos: o agendamento do ato promete "Toca hoje às 20:22 · na hora" (`v9-trabalho-agendar.png`) na mesma sessão em que o iPhone dizia "avisos desligados"; `AgendamentoAcaoView.swift:136-143` só cala a promessa com `permissaoNegada`, o mesmo defeito 2 da ficha do Calendário. |

## 7. Padrões

**Capturas.** Semana e trajetória `v9-padroes-1.png`, `v9-padroes-2.png`, perguntas `v9-padroes-3.png`; vazio `v9-padroes-vazio.png`; AX3 `v9-ax3-padroes.png`, AX5 `v9-ax5-padroes.png`. Movimento: entrada das perguntas em fade+offset 0,3 s (não gravado à parte).

**Curva-zero.** 1 toque na aba; ler; 1 toque numa pergunta para responder na página.

| dimensão | nota | evidência e defeito (lei) |
|---|---|---|
| Design | 7 | Cartões densos mas ordenados; o selo PRÉ-MORTEM é âmbar a 9 pt fixo (`PadroesView.swift:388`), fora do tipo e do contraste do sistema (§22, ADR 02h). |
| Simplicidade | 8 | Três perguntas, dois períodos, sem controle: a tela certa para ler. |
| Movimento | 8 | `withAnimation(.easeOut(0.3))` e `.opacity+offset(8)` (`PadroesView.swift:155,175`) com verificação de movimento reduzido no arquivo. Durações soltas. |
| Componentes | 7 | Rótulos ESTA SEMANA/TRAJETÓRIA à mão, cartão de pergunta com chevron (`PadroesView.swift:222`) só aqui. |
| Acessibilidade | 6 | Em AX3 os títulos das notas cortam em uma linha ("Quero correr de manhã antes do trab…", `v9-ax3-padroes.png`) e em AX5 pior (`v9-ax5-padroes.png`): o texto do autor é a única coisa que não podia truncar (§22, medida de aceite). |
| Estado honesto | 9 | "nada neste período.", "ainda não há o que ler. escreva primeiro.", "Sem nota, sem seta: quem lê é você." |

## 8. Camadas / navegação

**Capturas.** Puxador na borda `v9-camadas-pagina-puxador.png`; arquivo aberto pelo gesto `v9-camadas-arquivo-aberto.png` (abriu no Calendário, a última aba); volta `v9-camadas-pagina-de-volta.png`; barra em todas as capturas do arquivo; movimento `v9-camadas-movimento.mp4` (gesto da borda ida e volta e troca de abas, 14 s) e `v9-reduce-motion-movimento.mp4` (segunda metade). Transições de aba nos vídeos das telas 2 e 3.

**Curva-zero.** Escrita ↔ arquivo: 1 gesto ou 1 toque; a casa não se escolhe (§20). Bom.

| dimensão | nota | evidência e defeito (lei) |
|---|---|---|
| Design | 8 | Barra clara, "Escrever" âmbar liderando com fio, quatro destinos: cumpre §20 e SISTEMA-CLARO §2.3. O puxador de 3×36 lê como cursor parado no meio da borda (`v9-camadas-pagina-puxador.png`, `critique-affordance`). |
| Simplicidade | 8 | O gesto volta sempre à última aba: quem sai do Calendário e puxa de novo cai no Calendário, não nas Notas (`v9-camadas-arquivo-aberto.png`). É memória, não defeito, mas contraria "Notas é o arquivo" do §20 na primeira visita. |
| Movimento | 7 | Arrasto 1:1 e mola 0,55/0,82 (`Camadas.swift:98`); com Reduzir Movimento o arquivo **ainda desliza** e a barra desce (`v9-reduce-motion-movimento.mp4`, `BarraNavegacao.swift:136`, `RaizView.swift:87`); a V8 corta seco (ADR 05t). Troca de aba em cross-fade 0,18 sem direção, correta. |
| Componentes | 7 | `BarraNavegacao` com `.system(size:)` 17 e 21 (`:69,94`) por decisão de chrome; `AbaArquivo` (`Camadas.swift:163`) é cápsula própria. |
| Acessibilidade | 6 | A aba do arquivo tem 23 pt de largura e o puxador 3 pt (ADR 05t reconhece); rótulos das abas a 11 pt em `tintaFraca` 5,04:1 (ADR 04d). |
| Estado honesto | 9 | Trocar de tela salva (§20); o toast "1 nota veio de fora." confirma a entrada por `traco://anotar` (visto na sessão de semeadura; passou antes de qualquer captura, não está versionado). |

## Defeitos por severidade

**Alto (impede ou engana):**
1. Prosa "7 de setembro" cria compromisso no dia âncora às 9h em vez de navegar, com promessa "Toca hoje às 09:00" já passada; causa-raiz: `CalendarioFrase` não conhece nome de mês ("N de <mês>" nunca é data, vira título e cai na âncora); `v9-calendario-prosa-misparse.png`, `v9-rev-prosa-misparse-ficha-17e.png`, `v9-rev-prosa-misparse-lista-17e.png`; ADR 02i, `teslers-law`.
2. Ficha promete "Toca sexta-feira…" com avisos não autorizados enquanto o toast diz "desligados"; `v9-calendario-ficha-aviso-estado.png` × `v9-calendario-dia.png`; `CalendarioFicha.swift:166-176`; o mesmo no agendamento do Trabalho, `AgendamentoAcaoView.swift:136-143` (`permissaoNegada`), `v9-trabalho-agendar.png`; ADR 04a.
3. Cartão da forma cobre os campos que acabou de abrir, e em AX3/AX5 esconde as ações; `v9-pagina-cartao-vestido.png`, `v9-ax5-pagina-cartao.png`, reproduzido igual no 17e em `v9-rev-ax5-pagina-cartao-17e.png`; `law-of-figure-ground`, §22 (V8 corrige o AX).
4. Recordar: dois textos legíveis um sobre o outro na troca de fase; `v9-recordar-prova.png`; `RecordarView.swift:392-395`; §21.
5. Trabalho fora do sistema visual (formulário cru, botão com duas roupas, oito disclosures); `v9-trabalho-1.png`, `v9-trabalho-versao-1.png`; SISTEMA-CLARO §2.3, `law-of-similarity`.

**Médio (compreensão e acesso):**
6. Textos de evento a ~8 pt cortados na semana e no mês; `v9-calendario-semana.png`; `CalendarioEscalas.swift:399-564`; `critique-typography`.
7. Títulos do autor truncados em uma linha em AX3/AX5 nas Notas e nos Padrões; `v9-ax5-notas.png`, `v9-ax3-padroes.png`; §22.
8. Pé da página com 13 alvos de peso igual; `v9-pagina-forma-vestida-preenchida.png`; `hicks-law`, `von-restorff-effect` (FILA, desenho do dono).
9. "Revelar"/"hoje não" sem affordance e colunas do revelar desalinhadas; `v9-recordar-escrever.png`, `v9-recordar-revelar-2.png`; `critique-affordance`, `law-of-continuity`.
10. Título do calendário em cross-fade sob Reduzir Movimento; `v9-reduce-motion-movimento.mp4` t≈1 s (M→A); §21.
11. Nota vazia (só bloco SEÇÃO) vira linha em branco na lista; `v9-escuro-notas.png`; `critique-information-density`.
12. "Voltar à página" em âmbar `#D9A542` sobre branco (tint padrão); `v9-pagina-folha-campos.png`; `PaginaView.swift:31-35`; ADR 02h/04d.
13. "Preparar com IA" desabilitado sem parecer; `v9-trabalho-1.png`; `TrabalhoView.swift:210`; `critique-affordance`.
14. Cartão da sábia em falha com vão vazio; `v9-notas-sabia-falha.png`; `critique-composition`.
15. Toast do Recordar tapa a barra de ações; `v9-recordar-hoje-nao.png`; `law-of-figure-ground`.

**Baixo (coerência e acabamento):**
16. "Trabalhos" como link de texto no topo das Notas; `v9-notas-lista.png`; `NotasView.swift:50-57`; `law-of-similarity`.
17. Régua de chips (página e Notas) corta sem sinal; `law-of-continuity` (FILA).
18. Três barras no pé do calendário; `critique-information-density` (FILA, desenho do dono).
19. Cartão CONTA gasta a primeira tela do Perfil; `critique-information-density` (FILA).
20. PRÉ-MORTEM a 9 pt fixo; `PadroesView.swift:388`; §22.
21. "Nada marcado." na lista do dia; `CalendarioView.swift:505`; SISTEMA-CLARO §7.6.
22. Puxador lê como cursor; `v9-camadas-pagina-puxador.png`; `critique-affordance`.
23. Movimento reduzido ignorado em `PaginaView.swift:328`, `CadernoView.swift:165-166`, `BarraNavegacao.swift:136`, `RaizView.swift:87` (V8).

## Inventário de componentes repetidos (para a fundação, V10)

| componente | onde hoje (arquivo:linha) | variantes | proposta de nome |
|---|---|---|---|
| Pílula / cápsula de controle | `NotasView.swift:255,372,456,751` · `CalendarioView.swift:314-345,442` · `CalendarioEscalas.swift:365-373` · `VersoesView.swift:31,124` · `RedeView.swift:81` · `LenteView.swift:213,366` · `SerieView.swift:41` · `AgendamentoAcaoView.swift:111` · `CadernoView.swift:266` · `CalendarioFichaSistema.swift:40,87` · `BarraNavegacao.swift:72` · `TrabalhosView.swift` (Voltar) | 6 desenhos (chip/chipAtivo, trilho, âmbar, cinza do sistema, carvão, com contorno) | `Pilula` com estados padrão/selecionado/pressionado/desabilitado (SISTEMA-CLARO §2.3) |
| Chip de domínio | `ChipDominio.swift:36` (menu, ADR 05d) · `CalendarioFicha.swift:243` (tinta do domínio) · `CalendarioEscalas.swift:89,420` (evento) | 3 | `ChipDominio` único com tinta e menu opcionais |
| Rótulo de seção (caixa alta + tracking) | 32 ocorrências em 14 arquivos: `NotasView.swift:107,489,522,624,747` · `PadroesView.swift:47,70,266,308,319` · `LenteView.swift:281,319,362` · `RecordarView.swift:192,253,456` · `CamposFormaView.swift:54,122` · `PortalCodigoView.swift:64,73` · `RedeView.swift:130,185,206` · `SerieView.swift:52,56` · `FechoExpressivaView.swift:54,64` · `CartaoAnaliseView.swift:284` · `PaginaView.swift:552` · `PerfilView.swift:761` · `PortalArquivoView.swift:13` · `ChipDominio.swift:32` | 1 desenho copiado | `Rotulo(secao:)` (um modificador) |
| Linha de estado (pensando, lendo, falhou, sem conta) | `CartaoAnaliseView.swift:167-168` · `PaginaView.swift:329` (pulso) · `LenteView.swift:123,179` · `NotasView.swift:86,139,143,324` · `TrabalhoView.swift` (3 `ProgressView`) · `ConversaNotas.swift` (estados) | 5 desenhos | `LinhaDeEstado` com estados ocioso/pensando/respondeu/falhou/semConta e anúncio de acessibilidade |
| Disclosure / linha com chevron | `TrabalhoView.swift:165,220,283,469,497,500` · `IntercambioTrabalhoView.swift` · `AgendamentoAcaoView.swift` · `PerfilView.swift:747` · `PadroesView.swift:222` · `VersoesView.swift:57` | `DisclosureGroup` do sistema × linha própria | `LinhaQueAbre` (chevron, alvo 44, estado aberto animado pela altura, §21) |
| Cartão | `RoundedRectangle(cornerRadius: Tema.raio…)` em 29 lugares de 12 arquivos, entre eles `CartaoAnaliseView.swift:45,53,61` · `NotasView.swift:195,347` · `PerfilView.swift:300` · `TrabalhoView.swift:254,529` · `PortalArquivoView.swift:63…332` | 4 (sobre papel sem sombra, flutuante com sombra, tingido, com trilho âmbar) | `Cartao(estilo:)`; sombra só no que flutua (SISTEMA-CLARO §1.5) |
| Botão de texto / estilos | `PressaoDiscreta` (`Tema.swift:148`) · `PressaoClara` (`CalendarioTema.swift:184`) · `CompactoStyle`, `CartaoBotaoStyle` (`CartaoAnaliseView.swift:291,302`) · `BarraBotaoStyle` (`PaginaView.swift:612`) · `AcaoTrabalhoStyle` (`TrabalhoView.swift:678`) · `PrimarioStyle` (`RecordarView.swift:467`) · botões em `ambarTinta` soltos em Perfil, Trabalho, Recordar | 7 estilos | 3: `Primario`, `Secundario`, `Texto`, todos com `Tema.pressaoAnim` e alvo 44 |
| Cabeçalho de folha | `CalendarioFicha.swift:46` (✕ + Pronto) · `CalendarioFichaSistema.swift` · `LenteView.swift` (Pronto texto) · `CamposFormaView` ("Voltar à página") · `TrabalhosView` ("Voltar" cápsula) · `RecordarView.swift:242` ("voltar") | 5 | `CabecalhoDeFolha(sair:concluir:)` (ADR 04u: folha nasce inteira) |
| Toast | `Sessao.mostrarToast` (30 chamadas) · `CalendarioToast` (`CalendarioTema.swift`) · `PaginaView.swift`, `PerfilView.swift` | 2 desenhos | um `Toast` que nunca cobre a barra de ações |
| Vazio desenhado | `NotasView.swift:679` · `PadroesView.swift:194` · `CalendarioView.swift:505` · `RedeView.swift:89` · `TrabalhosView` | 5 frases, 3 layouts | `Vazio(frase:acao:)` seguindo SISTEMA-CLARO §7.6 |

## Inventário de movimento (para a biblioteca)

| onde | o quê | duração / curva | reduce motion | fonte |
|---|---|---|---|---|
| Tema | cartão entra/sai | easeOut 0,26 / 0,18 | easeOut 0,18 | `Tema.swift:130-134` |
| Tema | gaveta do caderno | timingCurve(0,32·0,72·0·1) 0,40 | easeOut 0,18 (mas chamada com `reduzido:false`, `CadernoView.swift:165-166`) | `Tema.swift:118-122` |
| Tema | pressão | easeOut 0,08 / spring 0,32·0,65, escala 0,94 | não trata | `Tema.swift:125-129`, 8 usos |
| Página | forma nasce | easeOut 0,48; campos com delay escalonado 0,05 × índice (0,35) | easeOut 0,18 | `CamposFormaView.swift:31,38` |
| Página | vazia/toast/voz | easeOut 0,2 | não trata | `PaginaView.swift:300,301,366` |
| Página | ponto "lendo…" | easeInOut 0,7 repeatForever | **não trata** | `PaginaView.swift:328` |
| Página | timer da expressiva | linear 0,3 / 1,0 | não trata | `PaginaView.swift:515,529` |
| Caderno | transformar bloco | easeOut 0,18; régua `.move(.bottom)` | não trata | `CadernoView.swift:144-166,230,290` |
| Caderno | célula nova | spring 0,35·0,8 | não trata | `EditorBlocoView.swift:241` |
| Notas | cartão da sábia | easeOut 0,25, `.move(.bottom)+opacity` | corte seco (`nil`) | `NotasView.swift:70-71,197` |
| Notas | lote / seleção | easeOut 0,15; `.scale(0,8)+opacity` | não trata | `NotasView.swift:340,784` |
| Calendário | morph de escala e título | spring 0,55·0,86; `matchedGeometryEffect` | easeOut 0,15 (título ainda cruza, ver defeito 10) | `CalendarioTema.swift:138-139`, `CalendarioView.swift:144-240` |
| Calendário | toast | easeOut 0,22, `.move(.top)+opacity` | não trata | `CalendarioView.swift:140-143` |
| Calendário | campo de prosa | easeOut 0,15 | não trata | `CalendarioView.swift:433-434` |
| Calendário | ir a outro dia pela tira, mês, ano; rolar até a hora | `CalendarioTema.morph` (mesma mola 0,55·0,86) | passa `reduceMotion`, menos o `scrollTo` com `morph(false)` | `CalendarioEscalas.swift:43,53,138,298,325,345,496,512,612,622` |
| Cartão da análise | pressão dos dois estilos de botão | `Tema.pressaoAnim` | não trata (herda de Tema) | `CartaoAnaliseView.swift:298,305` |
| Camadas | arquivo desliza | spring 0,55·0,82, arrasto 1:1 | easeOut 0,2 (ainda desliza; V8 corta) | `Camadas.swift:83-135` |
| Barra | recolhe com teclado / troca de aba | easeOut 0,2 / cross-fade 0,18 | easeOut 0,15 | `BarraNavegacao.swift:105,136`, `RaizView.swift:82-110` |
| Raiz | confirmação / fecho | easeOut 0,22 / easeIn 0,15 / easeOut 0,9 | opacity | `RaizView.swift:87-110` |
| Recordar | fases | easeOut 0,3 / 0,35(+delay 0,08) / 0,4; `.opacity+offset(8|10)` | 0,18 só no esconder | `RecordarView.swift:206-443` |
| Padrões | juízo e perguntas | easeOut 0,3; `.opacity+offset(8)` | verifica | `PadroesView.swift:155,175` |
| Rede | ecos | easeOut 0,3; `.opacity+offset(8)` | verifica | `RedeView.swift:50,177` |
| Confirmação / queima | véu, brasa | easeOut 0,22; easeIn 3,0; easeOut 0,2 | easeOut 0,18 | `ConfirmacaoView.swift:82-89`, `FechoExpressivaView.swift:134-137` |
| Trabalho | rolar até o alvo | `withAnimation` padrão | não trata | `TrabalhoView.swift:73` |

Dezesseis durações distintas: onze no vocabulário comum (0,08 · 0,15 · 0,18 · 0,2 · 0,22 · 0,25 · 0,26 · 0,3 · 0,35 · 0,4 · 0,48) mais 0,7 (pulso), 0,9 (fecho), 1,0 (timer da expressiva) em literais e `Tema.queima` 0,55 e `Tema.queimaCena` 3,0 (`Tema.swift:88,91`); e quatro molas (0,32·0,65 · 0,35·0,8 · 0,55·0,82 · 0,55·0,86) para o mesmo vocabulário: entrar, sair, trocar, pressionar. Tamanhos de fonte fixos (`.system(size:)`): 11 ocorrências em 5 arquivos (`CalendarioEscalas.swift` ×6, `CalendarioView.swift:186`, `BarraNavegacao.swift:69,94`, `PerfilView.swift:237`, `PadroesView.swift:388`). Movimento reduzido tratado em 15 arquivos e ignorado em 5 lugares nomeados.

## Proposta de escopo da V10 (fundação)

1. `Tema.swift`: tokens nomeados que faltam: `duracao.{curta 0,15, media 0,25, longa 0,4}`, `mola.{toque, camada, escala}`, `sombra.{flutuante, campo}`, `raio.{controle, cartao, campo}`; `CalendarioTema` passa a citar `Tema`, não a duplicá-lo.
2. `Tema.movimento(_:)` e `Tema.transicao(_:)` como único lugar que devolve fade 0,15 sob Reduzir Movimento (a V8 já traz `animacao/transicao`: mesclar antes e não duplicar).
3. `Traco/Componentes/` com preview por estado (normal, selecionado, pressionado, desabilitado, vazio, carregando, falha, AX5): `Pilula`, `ChipDominio`, `Rotulo`, `LinhaDeEstado`, `LinhaQueAbre`, `Cartao`, `Botao` (3 estilos), `CabecalhoDeFolha`, `Toast`, `Vazio`.
4. Sete `ButtonStyle` viram três; os 32 rótulos de seção viram um modificador; os cinco cabeçalhos de folha viram um.
5. Três telas migradas sem mudança de pixel (captura antes = depois): Notas (pílulas, rótulos, cartão da sábia), ficha do Calendário (cabeçalho, chips) e Recordar (botões, rótulos, fases sem cross-fade).
6. Fora da V10: redesenhar Trabalho (é a V18), mexer no pé da página e nas barras do calendário (desenho do dono), qualquer texto.
7. Prova: suíte verde, `shortstat` com linhas líquidas ≤ 0, previews no Xcode, diff de pixels das três telas em `large` e AX5.

## Limites desta auditoria

Sem VoiceOver ligado (exige humano; a V8 cobre a árvore). Sem aparelho real. Estados "falha de gravação" e "falha da IA" não provocados. Recordar vazio e A VOLTA não vistos com os dados plantados (PELO SENTIDO só no vídeo das Notas). Teclado de software ausente das capturas (teclado físico do simulador). Os vídeos foram re-codificados a 630 px para caber no repositório; os quadros citados foram lidos no original antes.
