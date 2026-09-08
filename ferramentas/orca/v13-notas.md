# Volta V13 — Notas e a barra de baixo até 9

Front-end (Fable 5.1), 08/09/2026. Simulador **iPhone 17 Pro (teste 2) `B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9`**. Toda sessão de `orca emulator`, todo `xcodebuild` e `xcodebuild test` passaram por `ferramentas/orca/com-trava.sh` (segurei a trava em cada passada). Prova de tela é `xcrun simctl io B91C8DEF… screenshot`; a árvore de AX foi conferida contra a captura do mesmo instante (o cabeçalho "Notas" e os rótulos batiam) antes de cada toque.

## G0 e as seis fases do design-router

**Ciclo:** multiplicar. **Intenção:** o autor acha a nota que procura, entende o que a lista mostra, e o chrome não disputa atenção. **Obstáculo:** a V9 deu 7,0 à tela com quatro defeitos nomeados.

1. **Ancorar (auditar antes de tocar).** A V9 tem cinco dias e seis voltas por cima; conferi **cada defeito na tela viva** antes da primeira linha (tabela abaixo). Sistema existente é âncora: tokens de `Tema`, `Pilula`, `Cartao`, `LinhaDeEstado`, `Vazio`.
2. **Sistema.** Nenhum token novo. Só o que já existia: `Tema.chrome/meta/tintaSuave/tintaFraca/linha`, `Pilula(.acao)`, o separador de 0,5 da própria lista.
3. **Construir.** As correções abaixo, amarradas uma a uma a um defeito confirmado vivo.
4. **Mover.** Nenhuma animação nova; o cartão da sábia continua subindo com `.move(.bottom)+opacity` sob `Tema.corte`, e a régua perde a máscara (que não animava). Movimento reduzido não muda.
5. **Julgar.** Capturas antes/depois por estado, curva-zero medida, scorecard preliminar (a nota final é do revisor).
6. **Portão.** Suíte integral, build sem aviso, shortstat.

## A auditoria V9 conferida na tela viva — defeito a defeito

| # | defeito da V9 | estado em 08/09 | prova |
|---|---|---|---|
| 1 | "Trabalhos" é texto âmbar com ícone no chrome (`NotasView.swift:56-64`) — navegação vestida de link | **VIVO** | `v13-antes-01-lista.png` (linha âmbar sob o título); em AX5 ocupa 60 pt de chrome, `v13-antes-02-ax5.png` |
| 2 | a régua de chips corta sem sinal de rolagem | **VIVO, com outra cara.** A máscara de 28 pt que existe desde 31/08 (`2a3dc68`) esfuma o último chip e **apaga o seguinte inteiro**: a régua parece terminar em "Especificação" (recorte em `v13-antes-01-lista.png`, x 374–402 pt), e em AX5 aparece um "S" cortado sem esfumado (`v13-antes-02-ax5.png`) | `v13-antes-01-lista.png`, `v13-antes-02-ax5.png` |
| 3 | cartão da sábia em falha guarda ~120 pt de vão entre a pergunta e o estado | **VIVO** — reproduzido pela rota real (resposta **recolhida**: perguntar, abrir a nota-fonte pela linha A VOLTA, editar, voltar): pergunta de uma linha, vão de ~100 pt, "A resposta foi recolhida…". Em AX5 o botão corta em "Repetir pergu…" | `v13-antes-13-sabia-recolhida.png`, `v13-antes-14-sabia-recolhida-ax5.png` |
| 4 | nota que nasce só com um bloco "Seção" vazio vira linha em branco | **VIVO** — a página `## ` grava (`Sessao.paginaVazia` lê o texto cru), `Nota.temVoz` diz sim, `tituloNaLista` devolve "" e a lista mostra uma linha muda de ~150 pt | `v13-antes-01-lista.png` (terceira linha de HOJE, entre "Plano da semana" e SETEMBRO) |
| 5 | AX5: título corta em uma linha, menu de ordem vira "M…" (Acessibilidade 6) | **METADE MORTO.** O menu virou ícone na V8 (`v13-antes-02-ax5.png`); o título continua cortando, agora em duas linhas ("Quero dormir mais cedo est…" na V9; o `.lineLimit(2)` está em `NotasView.swift:724`) | `v13-antes-02-ax5.png` |
| 6 | cápsulas locais em três versões nas Notas, mais Versões e Rede (Componentes 6) | **METADE MORTO.** As três das Notas migraram para `Pilula` na V10-B; `VersoesView.swift:31,123` e `RedeView.swift:82` continuavam com `Capsule()` à mão | `grep Capsule Traco/Notas` antes: 3 ocorrências |

Não vi nada errado na **barra de baixo** (busca + cartão no `safeAreaInset`): a V9 também não apontou defeito nela; fica como está, e a volta não inventa item.

**Achado novo, não corrigido (fora dos defeitos nomeados; vai para o RUMO):** a pergunta interrompida some. `ConversaNotas` promete "sair da tela não perde o pedido interrompido", mas `RaizView` **recria** `NotasView` ao trocar de aba e o `@State` morre: perguntei, toquei em Calendário e voltei — nenhum cartão (`v13-antes-11-calendario-apos-negar.png` e a lista limpa em seguida). É estado desonesto (a pergunta desapareceu sem dizer), e a correção é mover a conversa para a `Sessao` — `Traco/App`, área da A1.

## O que mudou, defeito a defeito (Construir)

| # | correção | onde |
|---|---|---|
| 1 | "Trabalhos" sai do chrome e vira **linha da lista** com ícone, contagem e `chevron.forward`; some em busca/filtro; continua acima do vazio (os fluxos `maestro/*` chegam por `abrir-trabalhos` com `clearState`) | `NotasView.linhaTrabalhos`, `@Query trabalhos` |
| 2 | a máscara da régua sai; **seta no fim da régua só enquanto há chip omitido** (`onScrollGeometryChange`); a contagem nomeia o filtro: "3 notas · WOOP" | `NotasView.chips`, `contagem(_:)` |
| 3 | `fixedSize(vertical)` depois do `frame(maxHeight:)` nos dois `ScrollView` do cartão; "Repetir pergunta" toma a altura do texto (o `fixedSize` no rótulo media uma linha e desenhava duas por cima das vizinhas — visto em `v13-depois-14` da primeira passada, corrigido na segunda) | `NotasView.cartaoDaSabia` |
| 4 | nota aberta com `tituloNaLista` vazio não entra na lista; teste `paginaSemNomeNaoViraLinhaEmBranco` (prova do vermelho: `soSecao.temVoz` é verdadeiro e ela some mesmo assim; código sozinho entra) | `NotasFiltro`, `NotasESessaoTests` |
| 5 | título da nota e da linha A VOLTA sem teto de linhas em tamanhos de acessibilidade | `NotasView.botaoNota`, `secaoDaVolta` |
| 6 | "Pronto"/"Restaurar" de Versões e Ligações em `Pilula(.acao)`; zero `Capsule()` à mão em `Traco/Notas` | `VersoesView`, `RedeView` |

## Provas (Julgar e Portão)

**Instrumento.** O teste 2 (`B91C8DEF`) foi desligado pelo dono às ~19h45 depois de o Mac falar; **parei de usar qualquer voz** (nunca usei Siri, `button`, ditado, VoiceOver ou `say` — os comandos desta passada foram só `attach`, `ax`, `tap`, `type` e `gesture`, além de `simctl`). Com autorização do orquestrador, o resto da passada foi no **iPhone 17e `C7341E64`**, ligado por mim e **desligado ao fim** (`xcrun simctl shutdown`, conferido `Shutdown`). A hipótese "a sábia no aparelho sobe `sirittsd`/`SiriAUSP`" foi testada de graça: `ps -axo comm` antes, 1 s e 10 s depois de perguntar, e ao fim da suíte — **0 processos de fala em todos os momentos**; a hipótese cai no 17e.

**Suíte integral na árvore final** (17e, `com-trava.sh`, `-parallel-testing-enabled NO`):
```
✘ Test run with 948 tests in 153 suites failed after 73.298 seconds with 18 issues.
✘ Test aLinhaAtivaEOCaretFicamNaAreaLivreDoPapel(tamanho:) with 2 test cases failed after 63.664 seconds with 18 issues.
```
947 verdes. O único vermelho é o caret do caderno em AX XXXL, e **é pré-existente no 17e**: a árvore de `HEAD` sem este diff dá as mesmas 18 issues no mesmo aparelho (`scratchpad/teste-antes-escrita.log`: `✘ Test run with 1 test in 1 suite failed … with 18 issues`). Não é desta volta (Traco/Caderno) e não reproduz no 17 Pro (V12-C fechou nele). Build sem aviso (`** BUILD SUCCEEDED **`, nenhum `warning:` fora do `appintentsmetadataprocessor`).

**Capturas** (`ferramentas/orca/v13/`; ANTES no teste 2 às 19h1x–19h2x, ANTES no 17e às 19h54 com o build de `HEAD`, DEPOIS no 17e às 19h57–20h03):

| estado | antes | depois |
|---|---|---|
| lista | `v13-antes-01-lista.png` (teste 2), `v13-antes17e-01-lista.png` (17e, mesmo aparelho do depois) | `v13-depois-01-lista.png` — linha em branco sumiu, Trabalhos é linha com seta, seta no fim da régua |
| AX5 | `v13-antes-02-ax5.png` | `v13-depois-02-ax5.png` — A VOLTA sem "…", régua com seta |
| escuro | `v13-antes-03-escuro.png` | `v13-depois-03-escuro.png` (um mundo só, como a V9 registrou) |
| busca / busca vazia | `v13-antes-04/05` | `v13-depois-04-busca.png`, `v13-depois-05-busca-vazia.png` |
| filtro WOOP | `v13-antes-06-filtro-woop.png` ("3 notas") | **"3 notas · WOOP"** em `v13-depois-folha-1958.png` (montagem 3×2 das capturas das 19h57–19h58; a captura solta foi sobrescrita por um toque cego na terceira passada — ver limites) |
| sábia pensando / resposta | `v13-antes-07/08` | `v13-depois-07-sabia-1s.png`, `v13-depois-08-sabia-10s.png` |
| **sábia em falha (recolhida)** | `v13-antes-13-sabia-recolhida.png` (vão de ~100 pt) | `v13-depois-13-sabia-recolhida.png` — pergunta, estado, ação, sem vão |
| falha em AX5 | `v13-antes-14-sabia-recolhida-ax5.png` ("Repetir pergu…") | `v13-depois-14-sabia-recolhida-ax5.png` — "Repetir / pergunta" em duas linhas, sem sobrepor |
| Trabalhos aberto | — | `v13-depois-15-trabalhos.png` (a folha abre pela linha) |
| movimento | — | nenhuma animação nova; a seta da régua entra/sai em `.opacity` sob `Tema.transicao` (movimento reduzido → corte). **Sem vídeo**: o aparelho teve de ser desligado antes |

**Curva-zero** (roteiro "achar uma nota que escrevi na semana passada", nota de 02/09 "Proposta para o cliente da padaria", 16 notas, 17e, mesmo arrasto de 0,03 de tela por gesto nos dois builds):

| | antes (build de HEAD) | depois |
|---|---|---|
| arrastos até a nota ficar visível | 2 | 2 |
| y da nota em repouso (fração da tela) | 1,192 | 1,135 (≈48 pt mais perto) |
| toques por palavra | 1 + digitar | 1 + digitar |
| toques por filtro | 1 em 29 chips | 1 em 29 chips; o chip aceso lê-se na contagem |
| decisões novas | 0 | 0 |

O ganho de escala nos gestos é do instrumento (ESTEIRA: o arrasto amplifica); a comparação vale porque o gesto é o mesmo nos dois builds.

## Limites, ditos por extenso

- **A prova de "a seta some no fim da régua" não tem captura.** Duas tentativas de arrastar a régua até o fim: a primeira andou pouco (chegou a "Inversão", seta ainda certa porque havia mais); na terceira passada o toque cego que devia dispensar um diálogo abriu uma nota, e desliguei o 17e sem religar de novo. Fica a lógica (`contentOffset.x + containerSize.width < contentSize.width − 1`) e a captura da seta presente; o revisor confere o fim num aparelho dele.
- **`v13-depois-06-filtro-woop.png` foi sobrescrita e apagada**; a prova de "3 notas · WOOP" está na montagem `v13-depois-folha-1958.png`.
- **Antes e depois em aparelhos diferentes** (teste 2 → 17e): por isso refiz o ANTES da lista e a curva no 17e com o build de `HEAD` (`v13-antes17e-01-lista.png`).
- **Sem vídeo e sem VoiceOver**, por ordem do dono; acessibilidade provada por árvore de AX e captura.
- **Diff não é líquido-negativo** (+119/−50 em código): ver a ADR.
- **`ax --device` conferido**: em cada passada o cabeçalho "Notas" e os rótulos da árvore batiam com a captura `simctl` do mesmo UDID no mesmo instante; quando a árvore só devolvia a raiz, era um diálogo do sistema por cima (notificações no contêiner novo), não o vizinho.

## Scorecard preliminar (a nota é do revisor)

| dimensão | antes (V9) | minha leitura | por quê |
|---|---|---|---|
| Design | 7 | 9 | os três defeitos de desenho da V9 caíram com o sistema existente; a régua ganhou sinal determinístico |
| Simplicidade | 7 | 8 | a lista deixou de mentir e a contagem explica o filtro; a régua continua a decisão mais longa (29 chips) — o conserto é chip por capacidade, fora desta área |
| Movimento | 8 | 9 | nada novo além de uma opacidade sob `Tema.transicao`; sem vídeo, por instrumento |
| Componentes | 6 | 9 | zero `Capsule()` local em `Traco/Notas`; nenhum componente novo |
| Acessibilidade | 6 | 9 | AX5 sem corte de título, sem sobreposição, botão que quebra linha; VoiceOver não ouvido (proibido) |
| Estado honesto | 8 | 9 | linha em branco fora, seta só quando há omissão, cartão sem vão; a pergunta interrompida que some fica registrada como dívida |
| Correção | — | 9 | teste da prova do vermelho; 947/948 com o vermelho pré-existente e alheio |
| Complexidade | — | 7 | +69 líquidas em código |
