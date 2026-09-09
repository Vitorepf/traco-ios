# Volta D1 — as Notas sem slop

Designer Fable 5.1, 09/09/2026. Responde ao veredito do dono (DIRETRIZ §9, 11h22: **Notas 4/10, "slop"**).

**Instrumento.** Build, capturas de antes/depois, sondas de curva-zero e suíte no **iPhone 17 Pro (teste 3) `34CC3F94-FDB5-4575-A4F5-80271829A18B`**, ligado por mim no início de cada corrida e **desligado ao fim da mesma corrida** (`xcrun simctl shutdown`, conferido `Shutdown` no log de cada uma). Todo `xcodebuild` e toda sessão de `orca emulator` passaram por `ferramentas/orca/com-trava.sh` — segurei a trava uma vez por corrida (build + install + semear + capturar, ou sonda, ou suíte), nunca entre corridas. O aparelho da conta (`B91C8DEF`) só entrou no fim, para o vídeo de 15 s (seção própria abaixo). Nenhuma voz, Siri, VoiceOver ou iPad. Prova de tela é `xcrun simctl io 34CC3F94… screenshot`, sempre pelo UDID.

**Estado semeado, o mesmo no antes e no depois:** `scratchpad/semear-notas.py` grava 19 notas no `ZNOTA` do App Group no formato que o app grava (colunas lidas do `PRAGMA`): 3 de hoje, 6 de setembro, 7 de agosto, 2 de julho e 1 expressiva trancada; WOOP, Se–então, Decisão (com "confiro em 05/09/2026", devida → A VOLTA), Destaque, Especificação, Nota permanente, prosa; sete domínios; uma "feito pelo bot" (ADR 08u). Um Trabalho vindo do arranque.

**Achados de instrumento, para a ESTEIRA:** (1) `xcrun simctl openurl … traco://notas` abre o diálogo do sistema "Abrir com Traço?" e não chega à tela (`antes/00-caderno` da primeira corrida); (2) o helper do `orca emulator` criado num boot anterior devolve `ok:true` sem tocar — matar **só** o `serve-sim` do meu UDID (pid em `orca emulator list --json`) e reatar a cada boot resolveu (nunca `emulator kill`, que derruba o vizinho); (3) o gesto da borda esquerda (1%→85%) abre o arquivo como no maestro, e o botão `notas-da-pagina` também.

## As seis fases, começando pela 5

### Fase 5 — auditar antes de tocar (o "antes", na tela viva)

Capturas: `ferramentas/orca/d1/antes-01-large.png`, `antes-02-ax5.png`; a página em branco, que é a âncora de identidade: `antes-00-caderno.png`.

O que a tela tinha, de cima para baixo: título "Notas" com a cápsula do menu de ordem ("Mais recentes ⌄") e um botão redondo de compartilhar; a régua de **29 cápsulas** de filtro (Todas em carvão, WOOP, Se–então, Especificação… seta); a linha "Trabalhos" com ícone de documento, contagem e chevron na borda; o rótulo **A VOLTA** em caixa alta com tracking; a cobrança em negrito; **HOJE**; cada nota com título em 17 semibold, uma **etiqueta em cápsula** com o método em caixa alta ("WOOP"), o trecho, e a **etiqueta do domínio em caixa alta numa cápsula à direita** ("SAÚDE"); **SETEMBRO**; a barra de busca num **cartão branco com lupa** ("Buscar ou perguntar"); a barra de abas.

**O teste do genérico (`tastemaker`), respondido na tela antiga:** *o que nesta tela só poderia ser o Traço?* — **as palavras** (WOOP, A VOLTA, Trabalhos, "perguntar"). Nada na forma. Trocando a fonte e a cor, é a lista de qualquer app de notas gerado por IA em 2026: título grande + fileira de pílulas + linhas com tags à direita + barra de busca em cartão + tab bar. A régua de 29 cápsulas é o exemplo mais forte: o domínio "Saúde" fica a **7,8 telas** à direita (medido pela árvore de AX: `x = 7.766` em frações de tela), e no fim da régua ainda aparece cortado (captura `antes-s1`). **Concordo com o 4/10.** Onde discordo, com a captura na mão: a *estrutura* já era certa (o tempo como única seção, a volta no topo, a busca no polegar) — o slop estava na *forma*, não no roteiro. É por isso que esta volta troca forma e mantém roteiro.

**A nota que me dou, dimensão por dimensão, ANTES** (a nota final é do dono):

| dimensão | antes | por quê |
|---|---:|---|
| Identidade (teste do genérico) | 3 | só as palavras são do Traço; a forma é molde |
| Hierarquia por tipografia | 4 | quatro selos disputam com o título; o método em caixa alta pesa mais que a voz do autor |
| Silêncio (chrome × conteúdo) | 4 | régua de 29, linha de menu, cartão de busca, botão redondo: cinco objetos de sistema antes da primeira nota |
| Curva-zero de achar | 5 | por palavra é bom (1 toque + digitar); por domínio é 2 arrastos + 1 toque, e o chip fica cortado na borda |
| Curva-zero de marcar | 8 | 2 toques (o chip abre o menu, ADR 05d) — isso já estava certo |
| Acessibilidade (AX5) | 6 | "Traba-lhos" hifenizado com ícone gigante; a régua mostra 1,5 chip |
| Estado honesto | 8 | contagem nomeia o filtro (V13), trancada não finge |

### Fase 1 — Ancorar

**Contrato.** Pessoa: o autor do caderno, no iPhone, procurando uma nota (achar) ou pondo o domínio numa nota (marcar), sem pensar na ferramenta. Resultado observável: a nota aberta / o domínio trocado. Ciclo: multiplicar. Plataforma: só iPhone, pt-BR.

**O que dá identidade ao Traço** (DIRETRIZ §9, e a captura `antes-00-caderno.png` prova): **o papel, a letra e o silêncio**. A página em branco tem a data em tinta fraca, a linha "1 volta a conferir" em tinta âmbar, o caret âmbar, e mais nada. A casa já tem o idioma **"a folha afirma um fato, e o fato é a porta"** (`LinhaDaVolta`, ADR 05b). A lista das Notas passa a ser o **sumário dessa folha**: as primeiras linhas do autor, na letra da página (`Tema.corpo`), com o tempo como margem ("hoje", "setembro") e o método/domínio ditos com uma palavra em tinta suave.

**A direção, nomeada:** (1) **ordem de leitura**: título → o que a folha cobra (âmbar) → as notas, por tempo; (2) **ritmo**: uma hairline entre notas, 24 pt antes de cada mês; (3) **tipografia**: `corpo` para a voz do autor (título da nota e a cobrança), `meta` para tudo o que é da casa, nada em caixa alta; (4) **densidade**: a mesma da folha (≈73 pt por nota, igual à anterior — medido); (5) **comportamento**: filtro e ordem são palavras que abrem menus; o domínio é a palavra com seta na margem; (6) **a quebra deliberada** (o "one intentional rule-break" do `tastemaker`): a pergunta da volta em **tinta âmbar** no corpo da folha — o único texto âmbar da lista, a folha cobrando.

### Fase 2 — Sistema

**Nenhum token, cor, fonte ou componente novo.** `Tema.corpo/meta/tinta/tintaSuave/tintaFraca/ambarTinta/linha/margem/alvo`, `SetaDeMenu`, `ChipDominio`, `TituloTela`, `.alvo(folgaV:)`, `.discreto`. **Retirado:** `Pilula.Forma.menu` (sem consumidor); a régua e o `haMaisChips`; o `.cartao(.papel)` da busca; o círculo `Tema.chip` do compartilhar; três `.rotulo()` desta tela. `ponytail`: subi a escada antes de cada troca — a palavra com seta já existia (`SetaDeMenu` + `Tema.meta`), a linha-porta já existia (`LinhaDaVolta`), o menu já existia (`menuOrdem`).

### Fase 3 — Construir

Tudo em `NotasView.swift`, `ChipDominio.swift`, `Pilula.swift`; a ADR 09k lista as sete decisões. `git diff --shortstat -- Traco`: **3 arquivos, +248 −264 — líquido-negativo (−16)**, sem arquivo novo. Os identificadores de acessibilidade continuam (`filtro-todas`, `filtro-woop`, `filtro-dominio-saude`, `secao-volta`, `volta-notas`, `abrir-trabalhos`, `contagem-busca`, `chip-dominio`, `busca-notas`, `ordem-notas`) — e um novo, `filtro-notas`, a palavra que abre o menu. Os itens do menu entram na árvore de AX do helper (a sonda achou "Saúde" pela árvore, `depois/sonda.json`).

### Fase 4 — Mover

Nenhuma animação nova; **duas a menos** (a seta da régua e o `withAnimation` da troca de chip). O menu é do sistema; o cartão da sábia continua subindo sob `Tema.corte`; movimento reduzido não muda de lei (ADR 05y). O vídeo de 15 s no aparelho da conta está na seção "Vídeo" abaixo.

### Fase 5 (de novo) — Julgar, com o depois na mão

Capturas: `depois-01-large.png`, `depois-02-ax5.png`, `depois-s1-menu-filtro.png` (o menu com Domínio e Método), `depois-s2-filtro-saude.png` ("Saúde ⌄ · Mais recentes ⌄" e "3 notas · Saúde"), `depois-s4-menu-dominio.png` (a palavra abre o menu do domínio), `depois-s6-busca.png` (a busca "celular" com o realce âmbar, "pelo sentido" em minúsculas, o botão de perguntar).

**O teste do genérico, respondido com a tela nova:** *o que nesta tela só poderia ser o Traço?* — (1) a folha cobrando em tinta âmbar, "O que aconteceu?", no corpo da lista, a mesma tinta e o mesmo gesto de "1 volta a conferir" na página; (2) a frase-porta "1 trabalho ›", que é o idioma da casa (a folha afirma e o fato abre); (3) o título de cada nota na letra da própria página (`corpo` regular), com o método dito numa palavra ("WOOP · …") — a lista lê como o sumário do caderno, não como células; (4) o tempo em minúsculas na margem ("hoje", "setembro"); (5) a busca como uma linha ao pé, com o caret âmbar, não uma barra. Trocando fonte e cor, ainda seria uma folha com uma cobrança âmbar no alto e uma frase-porta — não é o molde de app de notas. Não é um clichê trocado por outro: nada de vidro, bento, serifa grande ou animação — é Inter/SF, hairline e três tintas, que é o que a casa já era.

**A nota que me dou, dimensão por dimensão, DEPOIS** (a nota final é do dono):

| dimensão | antes | depois | por quê |
|---|---:|---:|---|
| Identidade (teste do genérico) | 3 | 8 | cinco coisas só do Traço, listadas acima; falta a mão do dono no vídeo |
| Hierarquia por tipografia | 4 | 9 | corpo para a voz, meta para a casa, âmbar para a cobrança; zero selos |
| Silêncio (chrome × conteúdo) | 4 | 9 | antes da primeira nota: título, duas palavras, uma frase-porta |
| Curva-zero de achar | 5 | 8 | domínio: 3 gestos → 2 toques, sem cápsula cortada; WOOP: 1 → 2 toques (custo dito) |
| Curva-zero de marcar | 8 | 8 | 2 toques, igual; a palavra com seta diz que abre |
| Acessibilidade (AX5) | 6 | 8 | sem "Traba-lhos" hifenizado; as palavras empilham; menus do sistema escalam |
| Estado honesto | 8 | 8 | contagem nomeia o filtro; trancada não finge; nada escondido |

**Acabamento que vira dívida nomeada (DIRETRIZ §8, "fechar antes de abrir"):** o rótulo "A SÁBIA, SOBRE:" do cartão continua em caixa alta (`.rotulo()`), como nas outras telas — mudar o `Rotulo` é volta de sistema, não desta tela; a régua de cápsulas `Pilula(.filtro)` continua em `Trabalho*` e no caderno; o `.dynamicTypeSize` teto do compartilhar. Dono: a próxima volta de design (D2, a tela que o dono nomear).

## Curva-zero de achar e marcar, em toques e gestos (`curva-zero`)

Sonda `ferramentas/orca/d1/sonda-curva-zero.py`, dirigindo o `orca emulator` pela árvore de AX no teste 3, o mesmo estado semeado nos dois builds, com as capturas `antes-s*.png` / `depois-s*.png` conferidas uma a uma. Roteiro (estado → ação → retorno): a lista aberta → achar → a nota na tela / o filtro na contagem → marcar → a palavra do domínio muda.

| tarefa | antes (`antes-s*`) | depois (`depois-s*`) | o que a captura mostra |
|---|---|---|---|
| achar por domínio "Saúde" | **2 arrastos** na régua (Saúde a 7,8 telas; no fim da régua fica **cortada** na borda esquerda) **+ 1 toque = 3** | **2 toques** (abrir "Todas ⌄", escolher "Saúde") | antes: `antes-s1-regua-fim.png` (cápsula cortada), `antes-s2-filtro-saude.png`; depois: `depois-s1-menu-filtro.png`, `depois-s2-filtro-saude.png` ("3 notas · Saúde") |
| achar a nota de julho rolando | 1 arrasto | 1 arrasto | `antes-s3-julho.png`, `depois-s3-julho.png` (mesma amplificação do helper nos dois) |
| marcar o domínio (Saúde → Estudo) | 2 toques | 2 toques | `antes-s4-menu-dominio.png`, `depois-s4-menu-dominio.png`; a árvore de AX diz "Domínio: Estudo" depois nos dois |
| achar por palavra "celular" | 1 toque + digitar | 1 toque + digitar | `antes-s6-busca.png`, `depois-s6-busca.png` |
| filtrar por WOOP (o 2.º chip, visível) | 1 toque | **2 toques** | custo assumido: o menu troca o melhor caso da régua pelo pior caso |

**Poder preservado:** os 29 filtros continuam todos alcançáveis, agora sem rolar; ordem, lote, contexto, versões, ligações, série, apagar — inalterados (menu de contexto e modo lote não mudaram). **Não simplificado por engano:** a régua sumiu, mas o filtro "aceso" continua na tela, agora como a própria palavra ("Saúde ⌄") e na contagem.

## Portão

- **Suíte integral** no teste 3, `com-trava.sh`, `-parallel-testing-enabled NO`, árvore final:
  ```
  ✘ Test run with 990 tests in 160 suites failed after 88.785 seconds with 3 issues.
  ✘ Suite EscritaVisivelTests failed after 77.569 seconds with 3 issues.
  ```
  **987 verdes.** Os três vermelhos são de `EscritaVisivelTests` (a geometria do **caderno**, `Traco/Caderno`, fora desta volta): `aLinhaFicaNoPapelEmCadaQuadroDaGaveta` em `large` (`totalFora 3`, `totalCoberto 2`) e `aLinhaAtivaEOCaretFicamNaAreaLivreDoPapel` em AX XXXL (`papelComEtiqueta 86,33 < papelSemEtiqueta 86,33`). A seção "O vermelho é do pai?" abaixo diz o que a mesma suíte faz na árvore de `HEAD` sem este diff, no mesmo aparelho.
- **Build** sem erro; `PilulaContrasteTests` ajustado (a forma `.menu` deixou de existir — o teste listava as seis formas).
- **`git diff --shortstat -- Traco`: 3 arquivos, +248 −264** (líquido −16); com docs, maestro e teste: 10 arquivos.
- **Maestro:** três fluxos atualizados por leitura (`busca-filtro`, `pelo-sentido`, `anexo-no-sentido`); **não corridos** — `varrer.sh` recusa com dois simuladores ligados e o da conta fica ligado. Limite declarado; a sonda cobriu os mesmos passos.
- **Aparelho restaurado:** `content_size` `large` antes e depois de cada corrida (linha "content_size restaurado: large" em cada log), orientação intocada, Movimento Reduzido intocado; teste 3 `Shutdown` ao fim de cada corrida.

## Scorecard (o meu; a nota final é do revisor e a da tela é do dono)

| dimensão | nota | evidência |
|---|---:|---|
| Visão | 9 | G0: multiplicar; a lista é a folha; DIRETRIZ §9 respondida ponto a ponto |
| Contrato | 9 | ADR 09k; LETRAS-ADR; RUMO com a dívida nomeada |
| Correção | 8 | 987/990; os três vermelhos são do caderno (ver "vermelho do pai"); maestro atualizado, não corrido |
| Jornada real | 9 | lista, AX5, menu do filtro, filtro aceso, menu do domínio, busca — capturas em `d1/` |
| Design | 9 | as seis fases, começando pela 5; tokens de `Tema`, nada novo, uma forma a menos |
| Simplicidade | 8 | curva-zero medida em toques nos dois builds; um custo assumido (WOOP 1→2) |
| Movimento | 9 | duas animações a menos; nenhuma nova; RM sem mudança de lei |
| Componentes | 9 | `ChipDominio` ganha a palavra, `Pilula` perde `.menu`; previews existentes seguem |
| Acessibilidade | 8 | AX5 capturado; rótulos e ids mantidos; menus do sistema; VoiceOver falado é limite declarado |
| Performance | n/a | nenhuma lista, editor ou parser mudou de algoritmo; a lista tem os mesmos `LazyVStack` e `ForEach` |
| Privacidade e autoria | 9 | "feito pelo bot" continua na linha (ADR 08u), agora em palavra; nada publica |
| Estado honesto | 9 | contagem nomeia o filtro; trancada não finge; a cobrança continua na tela |
| Complexidade | 9 | líquido −16 em `Traco`, sem arquivo novo |
| Fora do app | n/a | não toca |
| Relato | — | este |

## O vermelho é do pai?

Sim. `scratchpad/vermelho.sh`: checkout descartável de `HEAD` (`git archive HEAD | tar -x` — só a árvore, nenhum artefato meu), `xcodegen generate`, `xcodebuild test -only-testing:TracoTests/EscritaVisivelTests` no **mesmo teste 3**, sob a mesma trava, logo depois da mesma corrida no meu branch; o checkout foi removido ao fim (`checkout do pai removido` no log).

```
meu branch: ✘ Test run with 2 tests in 1 suite failed after 57.815 seconds with 3 issues.
HEAD (pai): ✘ Test run with 2 tests in 1 suite failed after 57.972 seconds with 3 issues.
```

As três issues são **idênticas** nos dois — `totalFora → 3`, `totalCoberto → 2` em `large`, e `papelComEtiqueta 86,33 < papelSemEtiqueta 86,33` em AX XXXL — e todas em `Traco/Caderno` (a gaveta e a etiqueta do bot na página, ADR 09e), que esta volta não toca. **Não é desta volta**; fica registrado no RUMO como vermelho vivo no `main` no 17 Pro, com dono C1.

## Vídeo de 15 s, sem áudio

**`ferramentas/orca/d1/d1-notas-15s-teste3.mp4`** (15,000 s, 1206×2622, h264, sem faixa de áudio, `ffprobe`), gravado por `xcrun simctl io 34CC3F94… recordVideo` no **teste 3 com o estado semeado**, dirigido por `scratchpad/video.py` (helper reatado, toques pela árvore de AX). **O que se vê, quadro a quadro** (`video-teste3/q1…q14.png` conferidos): 0–2,5 s a lista em repouso (título, "Todas ⌄ · Mais recentes ⌄", "1 trabalho ›", a cobrança âmbar, "hoje"); 2,5–5 s a rolagem até agosto/julho ("Viagem a Ouro Preto", "Pessoas ⌄" na margem); 5–7 s a volta ao topo; 7–9 s o menu do filtro aberto (Domínio, depois Método); 9–12 s "Saúde" escolhido — "Saúde ⌄ · Mais recentes ⌄" e "3 notas · Saúde"; 12–15 s o menu de novo e "Todas".

**No aparelho da conta (`B91C8DEF`): pendente de autorização.** Instalar por cima ali troca o binário que a Q2-D está medindo (ela pode ter instalado o build do branch dela); perguntei ao orquestrador por `ask` às 11h59 ("instalar agora / esperar a Q2-D fechar / outro") e o script está pronto (`scratchpad/video.py`: Perfil antes → install uma vez → Perfil depois → Notas → 15 s), com a conta conferida pela tela do Perfil antes e depois, sem erase/uninstall/shutdown. Assim que a resposta vier, o vídeo do aparelho da conta entra em `d1/d1-notas-15s-conta.mp4` num commit próprio. Até lá o vídeo acima é o que o dono vê — com estado semeado, dito aqui.
