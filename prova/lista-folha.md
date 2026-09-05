# Prova — U3 · Arrastar a nota na lista como folha

**Destino:** na lista, a nota se arrasta como folha. Ela descola da pilha e, passada a soleira, se solta para o Recordar.

## A raiz
O WIP já tinha o gesto, mas com dois defeitos que só a captura + o flow expuseram:

1. **Não era folha, era swipe de lista.** A linha da nota é texto puro sobre o tampo (`#0B0B0D`) — sem superfície. O arrasto deslizava o texto e revelava "Recordar" atrás: idêntico ao swipe-para-arquivar do Mail. A sombra de contato existia no código, mas caía sobre **texto pelado** — sobre preto, sombra sem superfície opaca some. Lia como "melhorou" (ganhou um swipe), não "a folha se arrasta".
2. **Puxar de leve ABRIA a nota.** O gesto era `DragGesture` com `.simultaneousGesture` sobre o `Button` da linha. O toque do Button vazava pelo simultâneo: um arrasto curto (31pt) — e pior, um arrasto **lento** (1600ms, mesmo abaixo da soleira) — soltava e a página abria. É a lição 02/set na veia: *DragGesture perde para o Button e para o ScrollView*.

## O que se construiu (elevar, não inventar pele)
- **A nota VIRA folha ao ser erguida** (`folhaErguida`): a superfície materializa sob a linha só enquanto ela é puxada (rampa 4x → o tom cheio já nos primeiros ~18pt; em repouso `progresso 0` → a lista fica plana, texto puro, intocada). Sobre preto, **profundidade não é sombra** (preto não escurece preto) — é a superfície mais clara + o fio de luz + o **fosso de tampo**. Três cues, todos em tokens da casa:
  - **Superfície** — fill sólido `superficieAlta` (`#1E1E22`), o nível do CARTÃO: erguida, a folha sobe ao topo do modelo de luz. Medido: interior **luma 28,3** contra vizinhas/tampo **luma ~9** — um degrau de ~3× (o gradiente pra `#16` da 1ª versão dava só luma 24 no meio da linha fina, subtil demais — dois críticos leram como recuo).
  - **Borda** — fio de luz forte no topo (`white 0.40` → hairline `linha`, 1pt): a quina de cima acende, a lip de luz de quem ergue a folha.
  - **Fosso** — 6pt de tampo acima/abaixo (medido luma ~8 no vão): a folha FLUTUA, descola das vizinhas, não é uma linha selecionada rente.
- **O gesto virou pan UIKit** (`PanFolha`, `UIGestureRecognizerRepresentable`, iOS 18+): resolve o que o `DragGesture` não resolvia. Coexiste com a rolagem (simultâneo → o vertical rola, o horizontal puxa) e, ao engatar, **cancela o toque do Button** (`cancelsTouchesInView`) — a folha puxa sem abrir a nota; rolar também não abre. Sem gate de direção no início (um `shouldBegin` horizontal falhava o pan no arrasto lento — translação ambígua no 1º quadro — e a nota voltava a abrir): a direção é decidida no handler.
- **Zero pele nova no repouso.** Só a nota que se relê (nem trancada nem queimada) engata; as outras ficam firmes, e o toque nelas abre com o atrito próprio de cada uma. O acento da tela continua sendo só o filtro ativo — o "Recordar" revelado é `tintaSuave`, sem âmbar (Von Restorff intacto).

## Barra (verde)
- **build 0** — BUILD SUCCEEDED (mudança de View, sem novo alvo; `PanFolha` inline em NotasView.swift, sem regenerar o projeto).
- **flow da lista** — `maestro/cenarios/lista-folha.yaml` verde. Um fluxo, duas garantias: (1) puxão curto abaixo da soleira ERGUE e VOLTA — a nota **não abre** (`Buscar nas notas` segue visível: a busca some quando a página abre); (2) puxão além da soleira SOLTA a folha no Recordar (`RECORDAR` + "Leia uma última vez — a nota vai se esconder.").
- **screenshot do arrasto** — `prova/lista-folha-antes.png` (pilha plana: três linhas de texto, hairlines) → `prova/lista-folha-arrasto.png` (a folha do meio, "a ideia nova", ERGUIDA entre as outras duas: superfície `#1E` clara, borda que acende no topo e nas quinas arredondadas, um fosso de tampo acima/abaixo a descolando, "↺ Recordar" cinza no vão). Frame de pico do arrasto extraído por vídeo (`simctl recordVideo` → o quadro de tom cheio; a folha volta ao repouso ao soltar, então o pico é fugaz). Luma conferida por pixel: folha 28,3 · fosso 8,1 · vizinhas 10,1.
- **bateria de gesto** (a folha tocada em todos os eixos, tudo verde, pinado no iPhone 17):
  - `peel-lento-não-abre` — o caso exato que abria a nota (1600ms, 63pt) agora ergue e volta. **Não abre.**
  - `recordar` — o **toque ABRE** a nota (a página com "Concluir" aparece): o pan não engoliu o toque.
  - `rolagem` — 12 notas, dois swipes verticais revelam a mais antiga: o pan **não rouba a rolagem**.
  - regressão da lista: `notas-e-recordar`, `busca`, `pilha-codigo`, `aba-arquivo` — verdes.
- **testes "a IA não escreve"** — `xcodebuild test`: **154 testes em 30 suítes, TEST SUCCEEDED**. A mudança é de gesto/superfície, nenhuma lógica da suíte foi tocada.

> Nota de aparelho: rodado com o iPhone 17 Pro ligado (job paralelo). Nada de maestro concorrente nos dois — cada comando foi **pinado por UDID** ao iPhone 17 (`--device`/`simctl install <udid>`), o que elimina a ambiguidade que o `varrer.sh` guarda (o instalador ir para um device e o maestro escolher outro). Cada corrida checou antes que o Pro não tinha runner de teste ativo (não por `pgrep -f maestro`, que é falso positivo, mas por `launchctl list` no próprio device).

## Antes → arrasto
- `prova/lista-folha-antes.png` — a pilha em repouso: texto plano, sem profundidade. Um bloco de folhas visto de cima.
- `prova/lista-folha-arrasto.png` — a folha do meio erguida: superfície um degrau mais claro que o tampo E que as vizinhas, quinas arredondadas com o fio de luz aceso, um fosso de tampo separando-a da pilha, "Recordar" revelado no vão. Sinto a folha sair da pilha.

## Crítico visual (design-router) — 3 rodadas cegas, convergindo
Três críticos frescos e cegos (cap da unidade), cada um só as 2 capturas + esta barra + o resultado dos testes, proibidos de ler código. O teto forçou o design a subir a cada rodada:
1. **FAIL** — "não é folha, é swipe de lista; a sombra caía em texto pelado e sumia no preto." → construída a `folhaErguida` (superfície materializa sob a linha).
2. **FAIL** — "clara demais de leve, lê como buraco." (Mediu o interior como mais escuro — engano: o pixel real era mais claro, mas o degrau `#18`/opacity-fade era subtil demais pra ler.) → rampa 4x (tom cheio), borda 0.22→0.30, fosso.
3. **FAIL, concedendo o essencial** — "a superfície ERGUE (uma laje cinza flutuando, ~28 vs ~9), o acento âmbar é respeitado; falta o FOSSO em volta e um fio de luz mais forte; a quina esquerda sai da tela." → fill sólido `#1E`, fio de luz 0.40, fosso 6pt de tampo (as duas primeiras exatamente o que a 3ª rodada pediu; medidas confirmam: superfície 28,3 · fosso 8,1 · vizinhas 10,1).

**Estado:** convergiu a uma folha que ergue de fato (evidência de pixel, não opinião). O único resíduo do 3º crítico — "a quina esquerda deveria ficar na tela" — é **tensão inerente ao gesto**: puxar uma folha para o lado a faz sair pela borda, como quem tira uma folha do bloco; manter o perímetro inteiro visível brigaria com o próprio arrasto. Bati o teto de 3 críticos frescos: **não declaro PASS sozinho** (a lei: sem crítico, não fecha) nem afrouxo a barra. Fica para o olho do dono ao vivo — aceitar e seguir pra página, ou pedir outro caminho (ex.: a folha ergue PARA o leitor, escala+fosso, em vez de deslizar pra fora).
