# F6 — os widgets da tela bloqueada, vistos na bloqueada de verdade

**Papel:** FORA DO APP (Fable 5.1). **Worktree:** `volta-f6-bloqueada`, sobre `f9f2292` (main). **Linha do ciclo (G0):** multiplicar — a pessoa olha o relógio e vê o que o dia tem, sem destrancar. **ADR:** 2026-09-09r (`SPEC.md`; letra registrada em `LETRAS-ADR.md`). Sem mesclar.

**Aparelhos.** Comecei no `34CC3F94` (teste 3), que eu liguei às 17:17 e que outra volta passou a usar em série (`xcodebuild test -only-testing:…`, pids 63998, 82800, 13183, 31050, 54221 entre 17:38 e 18:19), desligando-o ao fim de cada corrida **fora da trava** — duas corridas minhas morreram no meio ("Shutting Down", 17:44 e 18:02). Escalei; o coordenador respondeu "troque para o teste 4". Tudo o que vale aqui foi medido no **`A1DF082C-FC87-4DF9-9F56-F2DA1C084DED` (iPhone 17 Pro, teste 4)**, que eu liguei às 18:20 e desliguei ao fim. **Não encostei no `B91C8DEF`** (li só arquivos dele em disco para achar onde o iOS guarda o pôster; nada foi tocado). O teste 3 fica como o encontrei (ligado por outra volta). Tamanho de letra e aparência do teste 4 conferidos antes (`medium`, `light`) e restaurados ao fim (linha "restaurado: tamanho=medium aparência=light" no log da corrida).

**Instrumento.** Todo `xcodebuild` e toda ação de `orca emulator` por `com-trava.sh`; instalar+semear+plantar+fotografar numa posse só da trava (`TRAVA_MINHA=1`, padrão da F5b). Prova de tela é `xcrun simctl io <UDID> screenshot`, dada por boa só quando o OCR (`f5-ler`) leu o texto esperado (`f6-fotografar.sh`). Binário conferido por `cmp` do `TracoWidget.debug.dylib` contra o build depois de cada install. Nenhum mouse, nenhuma voz, nenhum VoiceOver, nenhum maestro. Skills: `design-router` carregada antes de tudo, começando pela **fase 5 (auditar antes de tocar)** — as seis fases estão citadas abaixo.

## O achado que abriu a porta: o editor da bloqueada existe, e a captura é cega a ele

A F1 fotografou o toque longo na bloqueada e viu "a galeria de fundos sem os botões Personalizar/+". Repeti e vi a mesma captura. Mas a **árvore de AX** (`orca emulator ax`), que na casa devolve 503, aqui responde — o PosterBoard é o app da frente — e listou `posterboard-customize-button` ("Personalizar"), `grouped-widgets-reticle-view` ("Adicionar Widget"), `inline-widget-reticle-view`, `editing-done`. O `simctl screenshot` só desenha o pôster (relógio 09:41 "idealizado"); o chrome do editor não sai. **Ausência na captura não era prova de ausência na tela.** Receita inteira, por rótulo e não por coordenada, em `ferramentas/orca/f6-plantar-bloqueada.sh`; o que aprendi para ela funcionar está nos comentários do script (toque longo acima do cartão vivo; `button lock` numa tela já trancada destranca; a folha da galeria some da árvore mas o reticle do topo continua tocável em (0,5, 0,093); `tap` não aciona botão na bloqueada, `gesture` de pressão aciona; o "−" fica no canto superior esquerdo do widget da fileira; helper `serve-sim` velho por boot responde ok sem tocar).

## Fase 5 — o que a tela mostrou antes de eu tocar em código (binário de `main` + o círculo experimental)

| estado | inline (topo, ao lado da data) | retângulo (fileira) | captura |
|---|---|---|---|
| dia | "Qua., 9  terminar o capítulo do m…" — a linha do autor, cortada pelo sistema em ~24 caracteres | (fileira: Próximo "PRÓXIMO / Dentista / hoje às 19:07" e o círculo experimental ○) | `f6-antes-bloqueada-dia-inline-retangulo-proximo-circulo.png` |
| feito | **igual ao por fazer** — nada diz que a única coisa de hoje foi feita | "✓ DESTAQUE / ~~terminar o ca…~~" — UMA linha, 14 caracteres, metade do cartão vazia | `f6-antes-bloqueada-feito-inline-sem-marca.png` |
| vazio | "Traço" — vazio que cala | "Traço" — idem; círculo "+" | `f6-antes-bloqueada-vazio-que-cala.png` |
| toque de feito no círculo | — | **abre o app** (Notas, teclado pronto); `superficie.feito` segue `false` | `f6-toque-no-circulo-abre-o-app.png` |
| toque de feito no retângulo (código de `main`) | — | **abre o app** (Perfil/Página); `feito` segue `false`; no log do `chronod` só `record reload … externalRequest(Traco)` depois de o app abrir, nenhum `perform` | `f6-toque-no-retangulo-abre-o-app.png` |
| cápsula do cartão vivo (mesmo `LiveActivityIntent`) | — | **roda sem abrir o app**: a cápsula vira "avisos desligados no iPhone" (recusa honesta, ADR 03e) | `f6-capsula-do-cartao-vivo-roda-sem-abrir.png` |

**O que a F5 chamou de "bloqueada" era o cartão da Live Activity** (`f5-depois-bloqueada.png`, com a frase inteira em duas linhas). O `accessoryRectangular` nunca tinha sido visto: esta é a primeira captura dele.

## As quatro perguntas da volta, respondidas com a tela

**1. O que cabe num círculo e numa linha?** Na linha: a **linha do autor**, e só ela — ~21 caracteres ao lado da data (com o glifo de estado), cortada com reticências pelo sistema; não há segunda linha nem escala. Num círculo: **hoje, nada que valha o lugar.** Construí o `accessoryCircular` como o gesto de assinatura do Traço fora do app — ○ por fazer, ✓ feito, + quando não há Destaque, um toque marca — e o medi: o toque **abre o app** em vez de marcar (três vezes: glifo-alvo, círculo inteiro como alvo, por `tap` e por pressão). O retângulo que já existia faz o mesmo. Um círculo que se veste de botão e age como link é pior que nenhum: **retirado** (o código está no histórico deste branch, commit anterior ao fecho, e no relato). A dívida chama-se **F6b** no RUMO, com o diagnóstico: o intent é `LiveActivityIntent` (roda no processo do app, ADR 04f) e a bloqueada não lança o app para um botão de widget — lança para a cápsula do cartão vivo. O caminho é um intent que corra na extensão, o que mexe nos contratos 04f/05u (só o app escreve o instantâneo): uma consulta ao Astra antes.

**2. O que aparece quando não há nada?** Antes: "Traço" nas duas faces (vazio que cala). Agora: inline **"escolha a única coisa"** (medido: com "Traço · " na frente saía "escolha a única c…"), retângulo **"DESTAQUE / escolha a única coisa de hoje"**, na forma do próprio Destaque. O toque abre o app na página do dia, teclado pronto — já é assim; não pus `widgetURL`. `f6-depois-bloqueada-vazio-oferece.png`.

**3. Eles atualizam?** Sim, pela linha do tempo, sem o app. Semeei o "curto" (três compromissos de 1 min; `validoAte` = T0 + 4 min) às **18:48:12** e a bloqueada trocou sozinha para "Traço · desatualizado" / "DESATUALIZADO": fotografada às **18:53:38** no meio da transição (as duas faces em fundido, `f6-bloqueada-curto-desatualizado-t0+5min.png`) — ou seja, virou entre 18:52:12 e 18:53:38, com o app fechado, pela entrada que o `Relogio` já tinha desenhado. A recarga externa depois de cada publicação do app aparece no `chronod` em ≤ 2 s (`record reload: [app.traco::app.traco.widget:TracoWidget] = externalRequest(Traco)`, 18:48:00.802, `f6-chronod-curto.log`, 345 linhas do widget nessa janela).

**4. Dynamic Type e as duas aparências.** **Não escalam.** Inline e retângulo idênticos em `medium` e em AX5 (`f6-bloqueada-dia-ax5-escuro.png` × `f6-depois-bloqueada-dia.png`); o cartão vivo ao lado escala (Dentista, cápsula). Claro e escuro: **idênticos** — o material da bloqueada é o do fundo de tela, e `simctl ui appearance light` não muda nada (`f6-bloqueada-dia-ax5-claro.png`). É o mesmo limite que a F5b provou na Ilha; fica registrado, não desconta.

## O que mudou no código (fases Ancorar → Sistema → Construir → Mover → Julgar → Portão)

- **Ancorar:** a linha G0; o brief; `TracoWidget.swift` inteiro nas famílias de acessório; `FraseDoAutor`, `BotaoFeito`, `DestaqueFeitoIntent.perform` (só `TRACO_APP`), `Relogio.datas`; as capturas da F1/F4/F5/F5b. **Sistema:** nenhum token novo — `Tema.label`, `Tema.meta`, `Tema.trackingLabel`, os glifos `circle`/`checkmark.circle.fill` que o retângulo e a casa já usam. **Construir:** (a) inline com `Label` — glifo ○/✓ + linha, rótulo de voz "Feito: …" (`d.emVoz`); vazio "escolha a única coisa"; `indisponivel` diz "Traço · sem dados" como o retângulo; (b) retângulo: `linhas: 2` + `frame(maxWidth: .infinity)` no lugar do `Spacer` + **`fixedSize(horizontal: false, vertical: true)`** na frase — só o último abriu a segunda linha ("terminar o / capítulo do me…", 22 caracteres; antes "terminar o ca…", 14); vazio "DESTAQUE / escolha a única coisa de hoje"; (c) círculo: construído, medido, retirado. **Mover:** nada animado; a transição de estado é o fundido do sistema (visto em `f6-bloqueada-curto-desatualizado-t0+5min.png`). **Julgar:** cada mudança tem antes/depois na bloqueada de verdade; o que não mediu (teto de linhas sozinho, `frame` sozinho) está dito, não escondido. **Portão:** suíte abaixo.

Diff líquido em `TracoWidget/TracoWidget.swift`: +28 −7 (inline reescrito em 11 linhas, retângulo vazio +12, três modificadores no retângulo). Scripts novos em `ferramentas/orca/`: `f6-plantar-bloqueada.sh` (o editor por árvore) e `f6-fotografar.sh` (captura da bloqueada dada por boa pelo OCR). Sem arquivo Swift novo, sem teste novo: a lógica nova é de view (texto por estado), e a regra da casa é que `if/else` de view se prova na tela, não em suíte — as duas faces têm `#Preview` por estado desde a 05u.

## Limites declarados

- **Cinco cliques de `xcodebuild build` + install para um retângulo de duas linhas.** Custo de medir na bloqueada de verdade (~2,5 min por volta). Não fica dívida.
- **`Failed to fetch metadata for DestaqueFeitoIntent`** no log do `TracoWidget` a cada render. Não investiguei; pode ser parte da causa da F6b, pode ser ruído do simulador. Anotado na F6b.
- **O circular órfão:** quando a família saiu do `supportedFamilies`, o iOS manteve por alguns minutos o último desenho em cache do círculo na fileira (o "+") e depois o retirou sozinho. Ninguém tem esse widget no aparelho; sem consequência.
- **Pedidos do sistema ("Permitir Atividades ao Vivo?", "Deseja continuar permitindo…")** cobrem a fileira em AX5 até serem respondidos; respondi por pressão nas coordenadas da árvore de AX (não nas da captura — as duas divergem nesse diálogo).
- **O feito não foi refotografado com o retângulo em duas linhas** (`f6-meio-bloqueada-feito-uma-linha.png` é do build intermediário): a frase é o mesmo `FraseDoAutor`, só o risco muda; o inline com ✓ está em `f6-antes-bloqueada-feito-inline-sem-marca.png` (antes) e o glifo novo aparece nas capturas "depois".
- **StandBy** não existe no simulador (F1); **VoiceOver falado** proibido — o rótulo de voz do inline está no código e na árvore, não foi ouvido.
- **Suíte no teste 4**, não no `34CC3F94` que o spec pedia: foi a ordem do coordenador depois da disputa.

## Scorecard (nota final é do revisor)

| dimensão | nota | evidência |
|---|---|---|
| Visão | 9 | ciclo multiplicar: o dia inteiro na bloqueada, sem destrancar; lacuna do EVOLUCAO reescrita e uma nova nomeada (F6b) |
| Contrato | 9 | ADR 09r; EVOLUCAO; RUMO (F6, F6b); LETRAS-ADR; ADR 04f corrigida no texto da 09r (vale para o cartão vivo, não para o widget) |
| Correção | 9 | suíte integral verde (linha abaixo); nenhuma rota maestro tocada; sem teste novo por ser view — declarado |
| Jornada real | 9 | dia, feito, vazio, desatualizado (com a virada no tempo), AX5, claro — todos na bloqueada de verdade, antes e depois |
| Design | 9 | seis fases citadas com o que cada uma decidiu; tokens do Tema; nenhum número novo |
| Simplicidade | 9 | inline: uma coisa (a linha); vazio oferece em 3 palavras; nada cresceu |
| Movimento | n/a | nada animado pela casa; o fundido é do sistema |
| Componentes | n/a | nenhum componente novo; `FraseDoAutor`/`BotaoFeito` seguem |
| Acessibilidade | 8 | rótulo de voz do feito no inline; alvo do retângulo inteiro; Dynamic Type NÃO escala por limite do sistema (medido) |
| Performance | n/a | nada de lista, editor ou parser |
| Privacidade e autoria | 9 | nada novo sai do app; a linha do autor continua a do `Superficie` (teto 08h) |
| Estado honesto | 9 | feito visível, desatualizado visível, sem dados dito; o botão que abre o app está NOMEADO como defeito, não escondido |
| Complexidade | 9 | +28 −7 num arquivo; dois scripts de instrumento; círculo não ficou |
| Fora do app | 9 | inline e retângulo fotografados na bloqueada de verdade em todos os estados; um toque faz uma coisa — exceto o feito, que é a F6b e está dito |
| Relato | 9 | este arquivo |

## Fecho

**Suíte integral** no teste 4, por `com-trava.sh xcodebuild test -project Traco.xcodeproj -scheme Traco -destination "platform=iOS Simulator,id=A1DF082C-FC87-4DF9-9F56-F2DA1C084DED" -parallel-testing-enabled NO`, às 18:58–19:00:

```
✔ Test run with 1000 tests in 161 suites passed after 88.726 seconds.
** TEST SUCCEEDED **
```

0 `warning:` no log.

Commit no branch `Vitorepf/volta-f6-bloqueada` (SHA no `worker_done`). Sem mesclar. Aparelho teste 4 desligado ao fim, tamanho `medium` e aparência `light` restaurados; teste 3 deixado como o encontrei.
