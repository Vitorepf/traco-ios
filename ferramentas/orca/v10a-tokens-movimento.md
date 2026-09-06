# V10-A — tokens e movimento (ADR 2026-09-05v, metade A)

Fable A, 06/09/2026, branch `Vitorepf/volta-10-fundacao`, mesmo worktree que B. Escopo: `Tema.swift`, `CalendarioTema.swift`, os pontos de chamada de animação das telas que B não migra, e `TemaTests`. Nenhum arquivo criado; nada em Componentes, NotasView, CalendarioFicha*, Recordar, Versoes, Lente, Perfil, Trabalho, Modelo, Migração ou Análise.

## O que mudou

**Tokens em `Tema`.** `Duracao.{curta 0,15 · media 0,25 · longa 0,4}` mais os que ficam fora do vocabulário com nome e motivo: `toque 0,08` (o press), `passo 0,05` (delay entre campos), `pulso 0,7` (laço do "lendo…"), `fecho 0,9` (a página amanhece depois do fecho expressivo), `relogio 1,0` (a barra do timer anda um segundo por segundo), `queimaCena 3,0` (a cena do fogo). `Mola.{toque 0,32/0,65 · camada 0,55/0,82 · escala 0,55/0,86 · teclado interpolatingSpring 420/34}`. `Raio.{controle 10 · campo 14 · cartao 18}` (o `raio` 12 do caderno fica; unificar é volta por tela). `Sombra.{flutuante 8 %/16/6 · campo 6 %/12/4}` com `View.sombra(_:)`. `pressaoLeve 0,96` (a pressão do calendário). Apagados: `formaNasce`, `cartaoEntra`, `cartaoSai` (órfãos), `push`, `queima` (órfão), `queimaCena`, `confirmacaoEntra` — este último ficou como ponte para um `Toast` que nunca o citou (a frase original deste relatório dizia o contrário; achado do G3); apagado na correção da volta.

**`CalendarioTema` cita `Tema`.** Treze cores, duas sombras, três raios e a mola do morph deixam de repetir hex e número; `PressaoClara` usa `Tema.pressaoLeve` e `Tema.pressaoAnim(_:reduzido:)`; o toast usa `.sombra(Tema.Sombra.flutuante)`.

**A lei de movimento, estendida.** `Tema.movimento(classe, animação, reduzido:)` é o único lugar que decide sob Reduzir Movimento, por classe: deslocamento → fade curta (ou corte seco por `Tema.corte`, no que o dedo ou o relógio movem); escala → nada (o estado vira); opacidade → mantém; laço → para. `animacao`, `transicao`, `corte` e `gaveta` da V8 continuam (mesmos nomes, mesma resposta) — `animacao` é o caso deslocamento. `pressaoAnim` ganha `reduzido:` e devolve nil sob RM (pressão é escala); `PressaoDiscreta`, `PressaoClara`, `BarraBotaoStyle`, `CompactoStyle` e `CartaoBotaoStyle` leem o ambiente e passam. Novos sob RM: o pulso "lendo…" para, a barra do timer corta a cada segundo, o `scrollTo` das escalas corta, `PadroesView:175` e `RaizView:87` passam por `Tema.transicao`.

## Literais migrados (16 durações e 4 molas + a do teclado)

| onde | antes | agora | Δ |
|---|---|---|---|
| Página chega (`PaginaView:105`) | easeOut 0,25 | `media` | 0 |
| Página vazia / toast / voz (`:305,306,372`) | easeOut 0,2 ×3 | `media` | +0,05 |
| ponto "lendo…" (`:334`) | easeInOut 0,7 laço | `pulso`, classe laço | 0 · RM: para |
| timer, dígitos (`:525`) | linear 0,3 | `media` | −0,05 · RM: fade curta |
| timer, barra (`:539`) | linear 1,0 | `relogio`, `corte` | 0 · RM: corta |
| campos da forma (`CamposFormaView:31`) | easeOut 0,35 + 0,05·i | `longa` + `passo`·i | +0,05 |
| forma nasce (`:38`) | easeOut 0,48 | `longa` | −0,08 |
| Camadas (`Camadas:102`) | spring 0,55/0,82 | `Mola.camada` | 0 |
| barra recolhe (`BarraNavegacao:137`) | interpolatingSpring 420/34 | `Mola.teclado` | 0 |
| aba do arquivo com teclado (`RaizView:82`) | easeOut 0,2 | `media` | +0,05 |
| confirmação entra / sai (`:95-97`) | 0,22 / easeIn 0,15 | `media` / `curta` | +0,03 / 0 |
| fecho entra / página amanhece (`:108-110`) | 0,22 / 0,9 | `media` / `fecho` | +0,03 / 0 |
| transformar bloco (`CadernoView:231,290`) | easeOut 0,18 | `curta` | −0,03 |
| célula nova (`EditorBlocoView:242`) | spring 0,35/0,8 | `Mola.escala` 0,55/0,86 | assenta em ≈ 0,70 s em vez de ≈ 0,45 s (+0,25 s); declarado na ADR |
| ecos da Rede (`RedeView:51`) | easeOut 0,3 | `media` | −0,05 |
| juízo dos Padrões (`PadroesView:155`) | easeOut 0,3 | `media` | −0,05 |
| confirmação materializa (`ConfirmacaoView:82,89`) | 0,22 | `media`, classe escala | +0,03 · RM: nada |
| queima / recuo (`FechoExpressivaView:134-137`) | 3,0 / 0,2 | `queimaCena` / `media`, classe deslocamento | 0 / +0,05 · RM: a cena vira fade de 0,15 s e o app espera 3,15 s parado (antes: 3,0 s sem tratamento); declarado na ADR |
| toast do calendário (`CalendarioView:143`) | easeOut 0,22 | `media` | +0,03 |
| campo de prosa (`:433,434`) | easeOut 0,15 | `curta` | 0 |
| morph (`CalendarioTema:137`) | spring 0,55/0,86 | `Mola.escala` | 0 |
| rolar até a hora (`CalendarioEscalas:140`) | morph(false) só sem RM | `corte(Mola.escala)` | 0 |
| pressão (`Tema`) | 0,08 / spring 0,32/0,65 | `toque` / `Mola.toque` | 0 · RM: nada |
| gaveta (`Tema`) | 0,40 | `longa` | 0 |

Os Δ são o custo assumido da fundação: dezesseis durações viram três mais seis nomeadas, e nenhum deslocamento muda de curva. Nada em repouso muda.

## Prova

**Instrumento.** iPhone 17 Pro C2416CBC (encontrado desligado, claro, texto padrão, RM 0; ligado por mim; ao fim: texto `large`, RM 0, env `TRACO_SEM_MODELO` removido, desligado). Build "antes" = HEAD 2229031 limpo; build "depois" = HEAD + só o meu diff, num worktree isolado no scratch (`git worktree add` + `git apply`), para não misturar as edições de B que vivem no mesmo worktree. Toques por `cliclick` na janela Point Accurate; sem maestro. Calendário concedido por `simctl privacy` depois de cada reinstalação (a primeira rodada "depois" caiu na caixa de permissão e foi refeita).

**Pixels (12 telas, `v10a-diff-large.png` e `v10a-diff-ax5.png`: antes | depois | diferença).** Fora da barra de status (relógio): 0 px em página com cartão AX5, calendário mês large, Notas (Camadas aberto) large e AX5, Padrões large e AX5, página vazia AX5. Calendário dia large/AX5: só a linha "agora" e a rolagem até a hora (03:18 vs 03:21). Calendário mês AX5: 2 047 px na etiqueta do feriado, que muda de largura com a hora de corte do Dynamic Type (mesmo build, vai e volta). Página vazia large: 72 649 px — o puxador do arquivo no instante da captura; relançando três vezes o mesmo build "depois", duas dão 7 458 px, o caret piscando (bbox 0–23 pt × 60–86 pt), uma repete o puxador. Página com cartão large: 9 465 px no canto inferior esquerdo, o mesmo puxador em fade.

**Movimento (vídeo simctl a 30 fps, quadro a quadro, `v10a-*-quadros.png`: linha de cima antes, de baixo depois, alinhadas no primeiro quadro que muda).** Sem RM: Camadas abre em 2 quadros de corte e a barra sobe em 12, iguais; morph Dia→Mês em 7 e 8 quadros com a mesma progressão de escala; cartão da forma: campos nascendo com o mesmo escalonamento. Com RM: morph em crossfade de 4 quadros nos dois (a lei já era da V8), Camadas corta, cartão entra por fade. Vídeos "depois" em `v10a-*-depois.mp4` (400 px).

**Suíte.** `com-trava.sh xcodebuild test` no C2416CBC: **650 testes em 123 suítes, 0 falhas** (7,3 s), incluindo os 8 de `TemaTests`: um por classe sob RM (deslocamento, escala, opacidade, laço), pressão sob RM, gaveta/morph na mesma lei, corte seco, e `nenhumLiteralDeDuracaoOuMolaNosArquivosDaV10A`, que lê os 16 arquivos da V10-A e falha se sobrar `duration: <número>`, `.spring(response:`, `dampingFraction: <número>` ou `interpolatingSpring(`. Build do worktree isolado: 1 aviso, o pré-existente de `EditorBlocoView.swift:272` (toolchain, memória 15). No worktree compartilhado os avisos são de `Componentes/*` e `RecordarView` (B).

**Shortstat dos meus arquivos.** 17 arquivos, +259 −113. `Tema.swift` +99 −26 (tokens e a lei, com os motivos em comentário), `TemaTests` +73 −6, `CalendarioTema` +26 −24; as 14 views somam +61 −59. As linhas líquidas ≤ 0 da volta vêm de B (32 rótulos, 7 estilos, 5 cabeçalhos); a metade A cria o vocabulário e por isso cresce.

## Limites

Digitação por `cliclick` engoliu teclas numa rodada (memória: simulador sob carga); refiz com digitação em pedaços e conferi o texto na captura. Os vídeos de `simctl` não têm cadência fixa: a comparação é por quadros alinhados e contagem, não por igualdade byte a byte. O crossfade do título no morph com RM ("Sete/embro" por 2 quadros) é o defeito 10 da auditoria, anterior e fora deste escopo. A ponte `Tema.confirmacaoEntra` saiu na correção do G3: o Toast nunca a citou.
