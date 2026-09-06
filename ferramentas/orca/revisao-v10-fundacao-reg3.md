# Re-G3 — V10 fundação de design após correção C (ADR 2026-09-05v)

Fable revisor, 06/09/2026, worktree `volta-10-fundacao`, topo **71db7b1** = main 59e5833 + A 0709f9f + B 1f0c8f3 + C 71db7b1. Simulador do revisor: iPhone 17 Pro C2416CBC (encontrado desligado, `large`, RM 0; ligado por mim; ao fim `TRACO_SEM_MODELO` removido, `large` conferido, desligado — os outros quatro simuladores ligados não foram tocados). Nenhum arquivo do branch editado; evidência nova só em `v10-reg3-*.png` (não versionados, ≤ 142 KB cada). Todo build, teste e maestro por `com-trava.sh`.

## Veredito: INTEGRAR (aguarda G4)

As três dimensões abaixo de 9 no G3 anterior (Contrato 8, Componentes 8, Complexidade 7) sobem a 9. Nada da lista mínima ficou por fazer. Três achados baixos ficam para o G5/voltas por tela, nenhum bloqueia.

## O que a correção C prometeu × o que o repositório tem

| promessa (relatorio-v10-c.md) | conferido |
|---|---|
| `CartaoAnaliseView` cita `.compacto` nas seis chamadas; `CompactoStyle` apagado | Sim: `grep CompactoStyle Traco/` vazio; seis `.buttonStyle(.compacto)` em CartaoAnaliseView (linhas 34, 94, 241, 261, 270, 275). `BotaoCompacto.makeBody` (Botao.swift:37-47) é byte a byte o antigo `CompactoStyle` (font `Tema.barra`, `.alvo()`, scale, opacity, animation na mesma ordem) |
| Estilos no repositório: sete | Sim: `grep ": ButtonStyle"` = PressaoDiscreta, PressaoClara, BotaoPrimario, BotaoCompacto, BarraBotaoStyle, CartaoBotaoStyle, AcaoTrabalhoStyle. Doc de Botao.swift e ADR dizem "três em Componentes, sete no repositório" |
| `Toast.swift` apagado e fora do pbxproj | Sim: arquivo ausente, três linhas do pbxproj removidas, `grep Toast` no app só acha `CalendarioToast`/`mostrarToast` (pré-existentes) |
| `LinhaQueAbre.abaixo` removido | Sim: enum `Abre` e `seta` apagados, preview "aberta" junto; único chamador (CalendarioFicha "Avisar") usa a forma menu |
| `Tema.confirmacaoEntra` apagada | Sim (Tema.swift −4); nenhum chamador em `Traco/` nem em testes |
| Frases corrigidas | ADR: "três estilos" → "três em Componentes — no repositório são SETE"; Prova em pixels reais (0 px / 235 px / 1 922 px / 2 186 px / 3,7 % / 218–636 px / 1,2 % e 5,1 % ordem); EVOLUCAO 15 idem; relatório de A: "a ponte saiu, o Toast nunca a citou"; relatório de B: Toast riscado, `.abaixo` "saiu na correção" |
| Δ sob RM da queima e da célula nova no custo assumido | Sim: parágrafo "Dois Δ de movimento" na ADR e linhas da tabela de A corrigidas (0,15 s + 3,15 s parado; 0,45 → 0,70 s) |
| Complexidade: +570, regra "cada volta por tela líquido-negativa" | Sim: parágrafo "Complexidade, decisão do orquestrador" na ADR; números batem com o meu shortstat (abaixo) |
| PNG ≤ 400 KB | Sim: `find ferramentas/orca -name 'v10*' -size +400000c` vazio; `v10a-diff-ax5.png` 162 619, `v10a-diff-large.png` 119 263 |
| Rebase sobre 59e5833 sem conflito; suíte 713/0 | Sim: `git merge-base` = 59e5833; `git merge-tree --write-tree 59e5833 71db7b1` sem conflito; suíte abaixo |

## Instrumento (meu simulador, 06/09 04:17–04:34)

- `com-trava.sh xcodebuild test` no C2416CBC, derivedData limpo: **`✔ Test run with 713 tests in 125 suites passed after 7.471 seconds`**, `** TEST SUCCEEDED **`.
- Avisos do build: só os pré-existentes em `ConferenciaTrabalhoTests.swift:381` (`d`/`p` var→let). Nenhum novo. O aviso Sendable de `EditorBlocoView:272` não apareceu neste build limpo.
- Build "antes" = `git archive 59e5833` no scratch, `xcodebuild build` EXIT 0, 0 avisos.
- `merge-tree` contra main 59e5833: árvore única, zero conflito.
- Tema.swift × main: `miudo` (linha 76) e `acaoViva` (linha 78) de F2 estão no branch; as únicas linhas de main ausentes são as que A reestruturou em `Duracao`/`Mola` (já revistas no G3 anterior). Nada perdido.
- Shortstat `Traco/*.swift` 59e5833..71db7b1: **+1058 −488 = +570** em 30 arquivos; `Componentes/` +758 (9 arquivos); telas +300 −488 = **−188** (21 arquivos); C sozinha +27 −136 = **−109**; testes +73 −6. Bate com a ADR.

## Código morto em Componentes — grep de cada símbolo público por chamador fora de `Componentes/`

| símbolo | chamadores fora | símbolo | chamadores fora |
|---|---|---|---|
| `.primario` | 3 (Recordar) | `CabecalhoDeFolha` | 3 (ficha, ficha do iPhone, Recordar) |
| `.compacto` | 6 (CartaoAnaliseView) | `.cartao(_:)` | 6 (`.campo` ×4, `.papel` ×2) |
| `.discreto` | 15 | `ChipDominio` | 3 |
| `Pilula` | 5 (`.filtro`, `.menu`, `.etiqueta` Notas; `.controle`, `.larga` ficha do iPhone) + `.acao` em `CabecalhoDeFolha` (Pronto) | `LinhaDeEstado` | 3 (`.pensando`, `.falhou`, `.semConta` nas Notas) |
| `SetaDeMenu` | 1 (Notas) | `LinhaQueAbre` | 1 (ficha, "Avisar") |
| `.rotulo(_:)` | 10 | `Vazio` | 1 (Notas) |

Nenhum tipo, modificador ou estilo sem chamador. Sobram **três casos de enum** que só os previews exercem: `Cartao.Estilo.flutuante` e `.tingido(Dominio?)` (Cartao.swift:13-15, 31-33, 39-41, 46 — ~8 linhas; `CalendarioView:346` e `CartaoAnaliseView:64` seguem chamando `.sombra(Tema.Sombra.flutuante)` direto) e `LinhaDeEstado.Estado.lendo` (2 linhas; o "lendo…" da página, `PaginaView:340`, ainda é `Text` próprio). São a mesma classe do Toast em escala de dez linhas: não bloqueiam, mas a ADR os lista como entregues ("papel, campo, flutuante, tingido"; "pensando, lendo, falhou, sem conta") — ver B1.

## Zero pixel — CartaoAnaliseView, o único arquivo de tela que C tocou (`large`, RM 0, `TRACO_SEM_MODELO=1`, `clearState`)

Roteiro maestro por UDID explícito (o `varrer.sh` recusa com cinco simuladores ligados): página → texto com linha "?" → cartão da forma com pergunta → toque em "Perguntar à sábia" → cartão "sem conta". Build antes = main 59e5833; depois = 71db7b1. Diff fora dos 5 % do topo (relógio), limiar 16/255, capturas originais 1206×2622.

| estado do cartão | botões `.compacto` visíveis | diff antes × depois |
|---|---|---|
| ESPECIFICAÇÃO com pergunta (`v10-reg3-{antes,depois}-cartao-pergunta.png`) | "Deixar como nota", "Perguntar à sábia" (+ "Abrir os campos" em `CartaoBotaoStyle`) | **0 px** |
| SEM CONTA (`v10-reg3-{antes,depois}-cartao-sem-conta.png`) | "Fechar" | **0 px** |
| WOOP "quero correr de manhã" (`v10-reg3-depois-cartao-forma.png`) | "Deixar como nota" | só depois: o fluxo "antes" caiu duas vezes por causa externa (1ª: diálogo de notificações do primeiro arranque no meu simulador; 2ª: `Connection refused` no driver XCUITest porta 7001 — outro worker rodava maestro no iPhone 17e ao mesmo tempo). Conteúdo conferido a olho; os dois botões desse cartão já estão cobertos pelos pares acima |

Conteúdo conferido a olho nas cinco capturas: texto da nota, rótulos PROBLEMA/PRONTO QUANDO/O QUE EU NÃO VOU FAZER (ou RESULTADO/OBSTÁCULO INTERNO/SE [OBSTÁCULO]), cartão com selo e pergunta, ações no pé. A captura de C (`v10c-calendario-dia.png`, 460×1000) é real: dia 6 de setembro às 04:12, linha do agora, prosa "Dentista sexta às 14:30" no campo — é fumaça de app instalado, não prova de pixel do cartão, como o próprio relatório diz.

## Scorecard (14 × nota × evidência)

| dimensão | nota | evidência |
|---|---|---|
| Visão | 9 | Confirmada do G3 anterior: linha G0 da V10 (RUMO 66), EVOLUCAO "Direção visual" com o que existe e o que falta. O critério "≤ 0" do G0 foi substituído pela ADR com decisão explícita do orquestrador — a lacuna (Componentes 6,2) é a mesma. |
| Contrato | **9** (era 8) | As três frases infladas foram corrigidas com o número real (tabela acima); Toast e `.abaixo` têm dona nomeada (V15, V12) em vez de "entregues"; Δ sob RM declarados; regra de compensação escrita. Resíduos, todos de G5: (a) Prova da ADR e EVOLUCAO 15 citam "650/0 em 123 suítes" — verdadeiro antes do rebase; o número da árvore que vai a main é **713/125** (relatório de C diz, ADR não); (b) a ADR diz "regra que o RUMO carrega" e o RUMO ainda não a carrega (grep "líquido-negativ" vazio) — é do orquestrador no fecho. |
| Correção | 9 | 713/125/0 no meu simulador, literal acima; avisos zero novos; `merge-tree` limpo. Maestro: dois fluxos do cartão no build 71db7b1 (forma, pergunta → sem conta) 100 % COMPLETED; navegação, estado e IO não mudaram em C (troca de estilo idêntico + remoções sem chamador), por isso não refiz os sete fluxos do G3 anterior. B2 (`BotaoPrimario` com `.animation` antes de `scaleEffect`) segue herdado, fora da lista. |
| Jornada real | 9 | Pares do cartão da análise feitos por mim nos dois builds: 0 px nos dois estados com `.compacto` (tabela). Capturas de C conferidas em conteúdo. Os pares das três telas de B foram refeitos no G3 anterior e nada em C toca essas telas. |
| Design | 9 (provisório, G4 julga) | Sem mudança em relação ao G3 anterior; a correção só apaga. Tokens em tudo que a volta tocou; nenhum literal de duração/mola fora de `Tema` (teste `nenhumLiteralDeDuracaoOuMolaNosArquivosDaV10A` verde nos 16 arquivos). |
| Simplicidade | 9 | Nenhum toque, decisão ou tela a mais; C não muda caminho comum de nada. |
| Movimento | 9 | Confirmado do G3 anterior; a reserva da queima sob RM agora está declarada na ADR com dona (V18). |
| Componentes | **9** (era 8) | Um lugar, nomes em pt, 27 `#Preview` (32 − 4 do Toast − 1 da "aberta"), todo símbolo público com chamador em tela (tabela). Estilos 7, não 8; `.compacto` prova o pixel em duas telas de estado com 0 px. Sobram três casos de enum de preview (B1, ~10 linhas) — abaixo da régua de "motor sem superfície" que reprovou o Toast (72). `Pilula` seis formas continua dívida com nome na ADR, como antes. |
| Acessibilidade | 9 | Labels, hints e ids do cartão iguais (`perguntar-sabia`, `soltar-forma`, `serviu`, `nao-serviu`, hints); `.alvo()` no `.compacto` igual ao antigo. Nada mais mudou desde o G3 anterior. |
| Performance | n/a | Como antes: nenhuma lista, editor ou parser mudou de algoritmo. |
| Privacidade e autoria | n/a | C não toca Modelo, Trabalho, Análise, corpus nem rotas; nada publica, gasta ou envia. |
| Estado honesto | 9 | Cartão "sem conta" antes/depois idênticos ("a sábia precisa da sua conta Grok…", `Fechar`); `LinhaDeEstado` e Recordar como no G3 anterior. |
| Complexidade | **9** (era 7) | O que não tinha chamador saiu (−109; nada de 72 linhas órfãs restou); +570 declarado como custo da fundação **com** a lacuna nomeada (Componentes 6,2, 32 rótulos, 7 estilos, 16 durações) e a regra de abatimento por volta escrita na ADR — é o que a ESTEIRA pede ("não crescem sem lacuna que justifique"), aplicado pela decisão do orquestrador. Telas já −188. Nota 9, não 10: os ~10 linhas de B1 e a regra ainda só na ADR (RUMO no G5). |
| Fora do app | n/a | Nenhuma superfície fora do app tocada. |
| Relato | 9 | `relatorio-v10-c.md` legível sem terminal, cada promessa conferível e conferida; limite declarado honestamente (não capturou o cartão). Todos os PNG ≤ 400 KB. |

## Achados por severidade

**Alto / Médio:** nenhum.

**Baixo**
- B1. Casos de enum só em preview: `Cartao.Estilo.flutuante`, `.tingido(Dominio?)` (Cartao.swift:13-15) e `LinhaDeEstado.Estado.lendo` (LinhaDeEstado.swift:8). Ou a V15/V18 os liga (CalendarioView:346, CartaoAnaliseView:64, PaginaView:340 são os chamadores naturais) ou saem; a ADR os lista como entregues.
- B2. Prova da ADR 05v e EVOLUCAO 15: acrescentar o número da árvore final, 713/125 (hoje só 650/123); RUMO ainda não carrega a regra "líquido-negativa" que a ADR diz que ele carrega. Ambos são do orquestrador no G5.
- B3 (herdado, já listado): `BotaoPrimario` `.animation` antes de `scaleEffect` (Recordar); `accessibilityIdentifier("")` do `CabecalhoDeFolha` sem prefixo; célula nova sem filme comparativo.

## Limites

Não refiz os pares das três telas de B (nada em C as toca; feitos no G3 anterior). O fluxo "antes" do cartão WOOP falhou por causas externas (diálogo de notificações no primeiro arranque; colisão de porta do driver do maestro com outro worker que rodava maestro sem a trava) — cobri os dois botões `.compacto` desse cartão pelos outros dois pares. Não medi VoiceOver nem Instruments (n/a). Aviso ao orquestrador: o maestro de outro worker no iPhone 17e correu fora do `com-trava.sh` durante a minha janela; dois maestros na mesma máquina dividem a porta 7001 e um derruba o outro.
