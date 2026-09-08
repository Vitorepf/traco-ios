# VOLTA L2-B — a prova é do binário que está sendo julgado

Worker de FRONT-END E DESIGN (Fable 5.1). Meu simulador: iPhone 17 Pro
`C2416CBC-C5D9-41F9-ACD8-45EED8FC355E` (402 × 874 pt), o único onde instalei.
Não toquei em `B91C8DEF` (teste 2), `6033B043` nem `C7341E64`. Topo de partida:
`9bea1b8`. Resposta ao G3 `revisao-l2-latencia.md` (CORRIGIR ANTES).

Skills carregadas antes de qualquer SwiftUI: `design-router` (com `REDESENHO.md`)
— as seis fases estão nas seções abaixo. `curva-zero` não foi recarregada: a
volta não toca jornada, folha nem formulário; a leitura da L2 continua valendo.

---

## G0 — a linha da volta

**Ciclo:** melhorar para multiplicar depois — o autor lê quanto tempo leva para
descobrir que errou. **Intenção:** ler a série sem dever nada e sem que a seção
coma o Perfil. **Obstáculo:** o G3 encontrou a ADR com a letra de `main`, as
capturas "depois" de um binário intermediário, e pediu o cartão curto em AX5
mais baixo. **Evidência:** a letra certa nos dois documentos; toda captura,
árvore e medida saídas do MESMO binário, o do commit; e a compactação medida —
para ficar ou para ser recusada com prova.

## 1. ADR `08b` → `08h` (P1)

`SPEC.md:5391` agora é `## ADR 2026-09-08h`; `EVOLUCAO.md:14` diz "ADR 08h";
o relatório anterior também. Conferido junto:

```
$ grep -n '08b' SPEC.md EVOLUCAO.md | grep -v 'Retomada'
SPEC.md:5468: (a frase do adendo que conta a troca de letra)
```

`a`–`d` são de `main`, `e` da P1, `f` da V12, `g` da F4-F; `h` é esta.

## 2. As provas refeitas no binário do commit (P1)

**Ancorar (auditoria antes de tocar).** O G3 estava certo, e conferi na tela
viva: `l2-depois-modo-b.png` de 10h43 mostrava "Sai do que já está escrito…" e
`l2-depois-teto-12-meses.png` mostrava "nos últimos 12 meses com descobertas." —
copy de um binário do meio da L2. As MEDIDAS, porém, eram do binário certo:
compilei o `9bea1b8` de novo (dylib de 12:40, `grep -a` no dylib acha "Sai das
hip" e "nos 12 " e não acha "Sai do que j") e a árvore devolveu os mesmos
5.541 pt (A) e 6.115 pt (B). O que estava errado era a foto, não o número.

**O que foi refeito** — três builds, todos por `com-trava.sh`, todos com
`-destination id=C2416CBC…`, `simctl uninstall` antes de cada `install`, dylib
conferido por data e por string:

| build | código | para quê |
|---|---|---|
| 1 (12:40) | `9bea1b8` | medir de novo A, B, vazio, vinte meses; captura "antes" da alternativa |
| 2 (12:58) | `9bea1b8` + registro em fluxo só | medir e fotografar a compactação pedida pelo G3 |
| 3 (13:02) | o commit final (= `9bea1b8` no Swift) | TODAS as capturas `l2-depois-*`, as árvores `l2-ax-*-ax5.json` e as medidas |

**As medidas, no binário final** (altura do cartão pela árvore de AX, do rótulo
"LATÊNCIA DA DESCOBERTA" ao rótulo "MÉTODOS", × 874 pt; tela útil = 682 pt):

| estado semeado | `large` (o do aparelho) | AX5 | AX5 no `9bea1b8` da primeira passada |
|---|---|---|---|
| MODO A (3 meses, 9 registros) | 886 pt | **5.541 pt · 8,13 telas** | 5.541 — igual |
| MODO B (3 meses, 18 em aberto, 12 registros) | 1.025 pt | **6.115 pt · 8,97 telas** | 6.115 — igual |
| VAZIO | 241 pt | **1.485 pt · 2,18 telas** | só tinha 241 em `large`; AX5 é novo |
| VINTE MESES (2 descobertas/mês, jan/2025→ago/2026) | 792 pt | **4.992 pt · 7,32 telas** | 5.340 — **outra semente**, ver abaixo |

**Número que mudou, dito sem enfeite:** os 5.340 pt de vinte meses vinham de um
script em `/tmp` que não existe mais; semeei de novo com script próprio
(`semear-vinte.py`, duas descobertas por mês, quarenta registros) e o cartão
mede 4.992 pt. Não é o cartão que encolheu: é outro conjunto de registros (a
cota por estado corta em 4 descobertos, mas o resumo e os textos mudam). O que
a captura prova continua igual: doze linhas, setembro/2025 → agosto/2026, com
"nos 12 últimos." na legenda (`l2-depois-teto-12-meses.png`). Build 1 e build 3
dão os mesmos 4.992 na mesma semente, como devem.

**Estado do aparelho, declarado:** letra `large` antes e depois (o que
encontrei; o orquestrador pediu `medium`, e restaurei o valor encontrado —
`l2-restauracao-letra-normal.png`, 13:10, e o eco de `simctl ui content_size`
diz `large`); aparência `light` restaurada após a captura escura (eco `light`).
Perfil continua **"sem conta — recursos locais disponíveis"** — está na árvore
de AX de todo estado (`l2-ax-*-ax5.json`) e no topo de `l2-depois-vazio.png`;
não limpei as abas do Safari nem toquei no `B91C8DEF`.

## 3. Os 341 pt: tentado, medido, recusado com prova (P2)

**Sistema.** A regra da ADR 08h não muda: medida em `Tema.meta`+`tintaSuave`,
prosa em `.footnote`+`tintaFraca`, nenhum token novo, `Tema.miudo` fora do app.

**Construir (a alternativa).** A única "apresentação de fato compacta dos
detalhes dos registros" que não esconde texto, não corta registro (é do
Modelo) e não devolve `Tema.miudo` é o registro num fluxo só: a medida abre a
linha no degrau maior, a hipótese segue na mesma linha no degrau menor,
separada por " — ". Implementada com interpolação de `Text` (o `+` de `Text`
está obsoleto no iOS 26 — o primeiro build avisou, o segundo não), build 2.

**Julgar — o que a medida diz, MODO A:**

| | duas linhas (`9bea1b8`, final) | fluxo só (build 2) | Δ |
|---|---|---|---|
| `large` | 886 pt | 850 pt | −36 pt (−4%) |
| AX5 | 5.541 pt | 5.361 pt | **−180 pt (−3,2%)** — recupera 180 dos 341 |

Por que não chega, pela própria árvore (AX5, MODO A, elemento a elemento):

| elemento | altura |
|---|---|
| parágrafo de abertura (37 palavras) | **833 pt** |
| manchete + composição | 544 pt |
| legenda dos meses | 261 pt |
| três meses | 525 pt |
| nove registros, duas linhas | 2.997 pt (223 a 449 cada) |
| nove registros, fluxo só | 2.823 pt |

Em AX5 cada registro já embrulha em quatro a seis linhas e a hipótese começa
numa linha nova de qualquer jeito — `l2-alternativa-inline-ax5-registros.png`
mostra "descoberto · / levou 2 dias — / estudar antes do / café rende mais",
exatamente as mesmas quatro linhas da forma em duas linhas. O ganho só aparece
onde a última linha da medida tinha sobra. E em `large`, o tamanho em que o
dono lê, o fluxo só troca a linha "título · legenda" (a medida sozinha, a
hipótese embaixo — `l2-depois-modo-a-fim.png`) por uma linha de dois corpos que
quebra no meio da hipótese ("conferir em 5 de / set. de 2026 — publicar o
vídeo…" — `l2-alternativa-inline-large-fim.png`), por 36 pt.

**Decisão: não corto.** Os 341 pt em AX5 na série curta são o preço de a medida
ter saído do menor corpo do produto, e nenhum arranjo dos detalhes muda essa
conta sem cortar palavras: a altura mora no parágrafo (833 pt) e no embrulho
das linhas. O Swift do commit é o do `9bea1b8`; a alternativa fica nas três
capturas `l2-alternativa-inline-*.png` e nas árvores do scratch, para o
orquestrador decidir com as duas lado a lado, como ele pediu. Se ele decidir
pelo fluxo só, é uma função de nove linhas (`linhaDe`) e um build.

**Mover.** Nada se move; nada novo a respeitar em Reduzir Movimento.

## Portão — scorecard preenchido por mim (a nota final é do revisor)

| dimensão | nota que proponho | evidência |
|---|---|---|
| Visão | 9 | inalterada: fecha a lacuna do G4 da L1 |
| Contrato | 9 | ADR `08h` em SPEC e EVOLUCAO, com o adendo L2-B; código coerente |
| Correção | 9 | Swift = `9bea1b8`; suíte `✔ Test run with 887 tests in 143 suites passed after 8.638 seconds.`; build 3 sem aviso |
| Jornada real | 9 | A, B, vazio e vinte meses fotografados e medidos no binário final, em `large` e AX5; escuro × AX5 na seção |
| Design | 9 | o que já estava em 9 não foi tocado |
| Simplicidade | 8 | os 341 pt continuam, medidos e argumentados; a alternativa recupera 180 e piora a leitura — 8 defendido, não 9 escondido |
| Movimento | n/a | ausência deliberada |
| Componentes | 9 | nenhum novo; o `linhaDe` da alternativa não entrou |
| Acessibilidade | 8 | árvores de AX dos quatro estados anexas (ordem, combinação, nada focável); não ouvi a fala; transbordo AX5 NÃO reproduziu nesta sessão (todas as capturas AX5 inteiras), continua no RUMO |
| Performance | n/a | nada novo |
| Privacidade e autoria | 9 | "sem conta" conferido em toda árvore; nada mudou nas rotas |
| Estado honesto | 9 | vazio DEPOIS agora tem foto e medida; o número de vinte meses que mudou está explicado |
| Complexidade | 9 | diff em Swift: zero linhas |
| Fora do app | n/a | — |
| Relato | — | este documento |

## Instrumento, declarado

- **Trava:** todo `xcodebuild`, `xcodebuild test` e TODA sessão de `orca
  emulator` (attach + ax, attach + tap, attach + gesture) passaram por
  `ferramentas/orca/com-trava.sh`, em sessões curtas (`ax.sh`, `tap.sh`,
  `swipe.sh` no scratch), para não segurar a máquina entre gestos.
- **Capturas** por `xcrun simctl io C2416CBC… screenshot`, nunca `booted`.
  Zero maestro. Zero mouse do Mac.
- **Helper:** desta vez o `orca emulator list` mostrou o helper no MEU UDID do
  início ao fim; a árvore só faltou (503 "No frontmost application") quando o
  app não estava na frente. Encerrado com `orca emulator kill` ao fim.
- **Achado de instrumento novo (A4):** o Traço, no meu aparelho, morreu duas
  vezes sem relatório de crash — uma logo depois do `launch` que segue a
  semeadura do MODO A (em três de três semeaduras do A; nunca no B, vazio ou
  vinte), outra no meio de uma rolagem, com a árvore de AX voltando a tela
  inicial. Não há `.ips` de hoje em `DiagnosticReports`. Hipóteses: `simctl
  terminate booted` de outra volta (há três simuladores ligados) ou pressão de
  memória. Registro como fato; o script relança e confere pela árvore antes de
  cada captura, e nenhuma medida saiu de um app que não estava na frente.
- **Rolagem** por gesto normalizado com o dedo parado 500 ms antes de soltar:
  mesmo assim o simulador aplica ~3,2× de inércia; o script mira por árvore e
  corrige em dois ou três passos.
- Semeadura: `semear-latencia.py` do repositório (A e B, intacto) e dois
  scripts meus no scratch que o importam (`semear-vazio.py`, `semear-vinte.py`).
- Suíte integral no binário final, no meu UDID:

```
✔ Test run with 887 tests in 143 suites passed after 8.638 seconds.
** TEST SUCCEEDED **
```

## Capturas e árvores (todas do build 3, 13:03–13:10 de 08/09)

| arquivo | o que prova |
|---|---|
| `l2-depois-modo-a.png` / `-fim.png` | MODO A, `large`: rótulo, parágrafo "Sai das hipóteses…", manchete em duas linhas, legenda "nos 12 últimos.", os nove registros em duas linhas |
| `l2-depois-modo-a-ax5-registros.png` | MODO A, AX5: os registros no degrau `meta`, sem transbordo |
| `l2-depois-modo-b.png` / `-registros.png` | MODO B, `large`: "agosto de 2026 · 1 descoberta · levou 5 dias"; "18 em aberto" na segunda linha, quieta; "proposta por Grok" e "autoria desconhecida"; doze registros |
| `l2-depois-vazio.png` | o VAZIO depois (faltava): "ainda não há série…", cartão de 241 pt |
| `l2-depois-teto-12-meses.png` / `-fim.png` | vinte meses semeados, doze impressos (setembro/2025 → agosto/2026) |
| `l2-depois-ax5-meses.png` | AX5: legenda com o horizonte e as linhas de mês |
| `l2-depois-ax5-escuro.png` | aparência escura do aparelho (eco `dark`), AX5, a seção idêntica e clara |
| `l2-alternativa-inline-large.png` / `-large-fim.png` / `-ax5-registros.png` | a compactação recusada, `large` e AX5, para decidir lado a lado |
| `l2-ax-{a,b,vazio,vinte}-ax5.json` | as árvores de AX de onde saíram as medidas |
| `l2-restauracao-letra-normal.png` | letra restaurada a `large`, 13:10 |

As capturas `l2-antes-*.png` e `l2-incidente-*.png` da primeira passada ficam
como estavam: são o "antes" e a evidência do incidente, não prova do candidato.

## Três linhas para o LACO

- A ADR da L2 é `08h`, e toda prova visual da L2 saiu, agora, do binário do
  commit — inclusive o vazio DEPOIS que faltava.
- A compactação dos registros que o G3 sugeriu foi feita, medida e recusada:
  recupera 180 dos 341 pt em AX5 e piora a leitura em `large`, porque em AX5 a
  altura mora no parágrafo e no embrulho das linhas, não no arranjo dos detalhes.
- O simulador matou o app duas vezes sem crash log, sempre com três aparelhos
  ligados; a árvore de AX antes de cada captura é o que garante que nenhuma foto
  saiu de tela errada.
