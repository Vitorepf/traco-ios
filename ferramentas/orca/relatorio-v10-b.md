# V10-B — componentes, previews e migração (ADR 2026-09-05v, metade B)

Fable B, 06/09/2026, branch `Vitorepf/volta-10-fundacao`, mesmo worktree que A. Escopo: `Traco/Componentes/*` (novo), `NotasView`, `CalendarioFicha`, `CalendarioFichaSistema`, `RecordarView`, `SPEC.md`, `EVOLUCAO.md`, `Traco.xcodeproj` (gerado). `Traco/Notas/ChipDominio.swift` mudou para `Componentes/` (a remoção foi absorvida pelo commit de A, 32bcf78, porque estava no índice do worktree compartilhado). Nada em Tema, CalendarioTema, Pagina, Caderno, App, Padroes, Trabalho, Modelo, Migração ou Análise.

## O que existe agora

`Traco/Componentes`, um arquivo por componente, 32 `#Preview` (normal, selecionado, pressionado, desabilitado, vazio, carregando, falha, AX5 onde o estado existe), nomes em português, alvo de 44 pelo `View.alvo()` de Tema:

| componente | o que é | usado em |
|---|---|---|
| `Pilula` | cápsula de controle; seis formas nomeadas que as telas têm HOJE (`filtro` 36 nas Notas, `menu` 34 com seta, `controle` 36 do SISTEMA-CLARO, `acao` "Pronto" carvão, `larga` largura inteira, `etiqueta` 6×2); com `acao:` vira Button + alvo + `.discreto`; sem, é rótulo de Menu | Notas (filtros, ordem, gesto), ficha do iPhone (chip do calendário, "Abrir no Calendário"), cabeçalho ("Pronto") |
| `ChipDominio` | um só: etiqueta (Notas) ou tingido com ícone e seta (ficha); menu com ícone + marca no atual, "Sem domínio", "Devolver ao app" quando travado; sem `aoEscolher`, só mostra | Notas, ficha |
| `.rotulo(_:)` | caixa alta, 11 semibold, tracking +1,2, cor por tela | Notas (5), ficha (1 + `secao`), ficha do iPhone (1), Recordar (3), ChipDominio |
| `LinhaDeEstado` | pensando / lendo / falhou / semConta em `meta` | Notas (3 linhas do cartão da sábia) |
| `LinhaQueAbre` | título, valor, seta de menu ou seta que gira; alvo 44 | ficha ("Avisar") |
| `.cartao(_:)` | papel, campo, flutuante (`Tema.Sombra.flutuante`), tingido; raios de `Tema.Raio` | Notas (cartão da sábia, campo de busca), ficha (3 campos), ficha do iPhone (QUANDO) |
| `.discreto` / `.primario` / `.compacto` | os três estilos de botão; `.discreto` é a `PressaoDiscreta` de Tema; `.primario` recua sozinho quando desabilitado; todos passam `reduzido:` a `Tema.pressaoAnim` | Recordar (Revelar, próxima, Voltar à página), todas as três telas (`.discreto`) |
| `CabecalhoDeFolha` | ✕ ou "voltar" + título + Pronto; vão da largura da saída quando não há Pronto; ids `<prefixo>-fechar/-pronto` | ficha, ficha do iPhone, Recordar |
| `Toast` + `.toast(_:reduzido:)` | cápsula carvão, ação âmbar opcional; entra por `safeAreaInset` e nunca cobre a barra | ninguém ainda (calendário, página e perfil desenham o seu; voltas por tela) |
| `Vazio(frase:acao:)` | frase em `corpo` no eixo do conteúdo + a saída do buraco | Notas (vazio e vazio da busca) |

**Sete ButtonStyles → três.** `PrimarioStyle` (Recordar) apagado, virou `.primario`; `PressaoClara` das duas fichas virou `.discreto`. Ficam, em arquivos de outras voltas: `PressaoClara` (CalendarioTema; hoje cita `Tema.pressaoLeve`), `CompactoStyle` e `CartaoBotaoStyle` (CartaoAnaliseView), `BarraBotaoStyle` (PaginaView, desenho do dono), `AcaoTrabalhoStyle` (TrabalhoView).

**32 rótulos → um modificador.** Migrados os das minhas telas. Ficam 24 em 12 arquivos: PadroesView 5, LenteView 3, RedeView 3, PortalCodigoView 2, CamposFormaView 2, FechoExpressivaView 2, SerieView 2, PortalArquivoView 1, DoCadernoView 1, CartaoAnaliseView 1, PaginaView 1, PerfilView 1.

**Recordar, fases sem cruzar texto (§21).** Ler e esconder eram duas views cruzando em fade; agora são UM `ScrollView` cujos modificadores (blur, escala, opacidade) animam. Cada fase sai em corte seco (`removal: .identity`) e entra por `Tema.transicao(opacidade + 8 pt)`; a linha de instrução também. Durações pelo vocabulário de A: `media` (0,25, antes 0,3 e 0,35), `longa` (0,4), delay `toque`. Notas: seleção `curta`, filtros e pé `media`, o pé corta por `Tema.corte`.

## Zero pixel: prova

Instrumento: iPhone 17e C7341E64 (encontrado desligado, `large`, claro; ligado por mim; ao fim `large`, claro, desligado). Build "antes" = `git archive HEAD` de 2229031 (= main); build "depois" = `git archive HEAD` (32bcf78, com A) + só os meus arquivos, no scratch, para não misturar o WIP de A. Toques por `cliclick` (janela Point Accurate, origem calibrada por casamento de imagem); dados plantados iguais nos dois builds: seis notas por `traco://anotar`, domínios Ideias e Saúde pelo menu de contexto, "Dentista sexta 14:30" pela prosa, feriado do iPhone com permissão concedida na caixa. Capturas por `simctl io screenshot`; diff em Python (PIL) fora da barra de status; `v10b-<tela>-antes.png` / `-depois.png` em `ferramentas/orca` (900 px, 256 cores).

| tela / estado | large | AX5 |
|---|---|---|
| Notas vazio ("nada aqui ainda." + escrever na página) | 0 px | — |
| Notas lista (HOJE, chips IDEIAS/SAÚDE, ordem, contexto) | 0 px | 0 px |
| Notas filtro sem resultado (Vazio da busca) | 0 px | — |
| Notas busca "casa" (contagem, PELO SENTIDO) | 51 px (caret) | — |
| Notas cartão da sábia | mesmo desenho; a resposta é do modelo do aparelho e muda a cada pergunta (`v10b-notas-sabia-*`) | — |
| Ficha do compromisso, topo | 235 px (caret do título) | 0 px |
| Ficha, rodapé (Aviso, Domínio, Notas, Apagar) | 235 px (idem) | 1 922 px = 0,07 % (rolagem clampada a ±1 pt) |
| Ficha do iPhone (feriado) | 0 px | — |
| Recordar ler (pela rota `traco://recordar`, 1,0 s) | 0 px | 0 px |
| Recordar escrever | 2 186 px = 0,08 % (caret) | 3,7 %: a pergunta da sábia muda por abertura |
| Recordar revelar e conferido (lado a lado) | 0 px | 0 px |

Estados "pensando" e "sem conta" da sábia não capturados: o simulador tem o modelo do aparelho e responde em ~2 s; o `LinhaDeEstado` desses dois está nos previews. A ficha em AX5 já sai cortada à esquerda em main (fileira "Repete" de sete círculos de 32 empurra a largura): defeito anterior, igual nos dois builds, para a volta do calendário.

**Movimento.** `v10b-recordar-fases-depois.mp4` (rota → ler → esconder → escrever → digitação → Revelar → lado a lado, 400 px). Quadro a quadro a 15 fps: ler→esconder embaça e apaga um objeto só; esconder→escrever e escrever→revelar cortam o que sai e amanhecem o que entra; nenhum quadro com dois textos na mesma linha. Os dois primeiros vídeos tinham: a linha de instrução saía em fade sobre a pergunta, e os irmãos da fase escrever (pergunta, serviu/não serviu, editor) saíam em fade sob o lado a lado; a transição passou para cada irmão via `Group`, e a suíte rodou de novo (650/0) sobre o código final. `v10b-recordar-revelar-antes.mp4` é o main para comparação.

**Suíte.** `com-trava.sh xcodebuild test` no 17e: 650/0 em 123 suítes (inclui os 8 `TemaTests` de A). Build: nenhum aviso em `Componentes/*` nem nas quatro telas; os avisos que sobram são os pré-existentes de `EditorBlocoView.swift:272` e `ConferenciaTrabalhoTests.swift:381`.

**Shortstat (meus arquivos).** `Componentes/*` +848 (dez arquivos, 32 previews); NotasView +54 −124, CalendarioFicha +14 −84, CalendarioFichaSistema +6 −36, RecordarView +36 −74 (−45 do ChipDominio antigo no commit de A). Swift líquido de B: **+640**; com A (+159) a volta fecha em **+799**, não ≤ 0. Sem previews e comentários de contrato os componentes têm ~380 linhas; o abatimento real vem das voltas por tela (24 rótulos, 5 estilos, 3 toasts, 4 vazios, os 29 cartões).

## Autoavaliação (14 dimensões)

Visão 9 (MULTIPLICAR, eixo 4; lacuna "Direção visual" do EVOLUCAO) · Contrato 9 (ADR 05v ≤ 45 linhas nas duas metades, EVOLUCAO 15 e design-router) · Correção 8 (suíte verde; componente é view, sem teste novo: o que se prova é o pixel) · Jornada real 9 (17 pares de captura, os estados que o simulador permite; pensando/sem conta só em preview) · Design 9 (tokens de Tema em tudo; CalendarioTema só para ícone e tinta de domínio, que A manteve lá) · Simplicidade 9 (zero toque, decisão ou tela a mais) · Movimento 9 (fases pela lei, corte seco na saída, vídeo; reduce motion coberto pela lei de A, não filmado por mim) · Componentes 8 (um lugar, estados completos, previews; `Pilula` com seis formas é honesto mas ainda não é o sistema) · Acessibilidade 8 (labels, hints e ids preservados; `isSelected` segue no chamador; sem VoiceOver humano) · Performance n/a (sem lista nova nem parser; migração 1:1) · Privacidade e autoria n/a (nada de dado) · Estado honesto 9 (LinhaDeEstado mantém as três frases; falha não some) · Complexidade 6 (+640 líquidas, declarado) · Relato 9.
