# V12-D — a letra da ADR e o quadro longo que ninguém isolou

Worker: Claude Fable 5.1, papel de front-end e design, 08/09/2026, worktree
`volta-v12b-pagina` (topo ao chegar `035c5e0`). Correção do re-G3
(`revisao-v12b-pagina.md`, seção "re-G3"): Simplicidade, Acessibilidade e
Complexidade já a 9; faltavam **Contrato** (ADR com letra de outra ADR) e
**Performance** (quadro longo repetido, com hipótese e sem causa). (Há um
`relatorio-v12d.md` mais antigo em `ferramentas/orca`: é a V12-D da série
anterior à limpeza de 07/09, não esta.)

**Instrumento.** iPhone 17 Pro Max **`6033B043`**, o meu, já ligado em `large`
quando cheguei e deixado em `large`. **Toda** sessão de `xcodebuild test` passou
por `ferramentas/orca/com-trava.sh` — segurei a trava 21 vezes (uma por
rodada) e esperei por ela duas (a volta F4-H no `A1DF082C` estava a compilar). Nenhum maestro,
nenhum mouse, nenhum `orca emulator` (não precisei do helper: a medida é de
dentro do processo e as capturas são as que o próprio teste grava no contêiner,
copiadas por `simctl get_app_container`). Nenhum simulador proibido foi tocado.
`xcodegen generate` antes do primeiro build porque o `.xcodeproj` não vive no git.

**Fases do `design-router`.** Esta volta não mudou um pixel nem uma linha de
SwiftUI de view: os dois arquivos de app tocados (`CadernoView.swift:228`,
`PaginaView.swift:316`) só trocam `08c` por `08f` dentro de um comentário. As
seis fases são as da V12-B/V12-C (`v12b-pagina.md`); aqui só a **6 — Julgar e
Portão** trabalha, com medida.

---

## 1. Contrato — a letra

A ADR desta volta estava como `08c`; `08c` é de `main` ("conferência conserva
restrições ao adaptar"). A letra livre desta sessão é **`08f`** (`a`–`d` de
`main`, `e` da P1 mesclada, `g` da F4-F, `h` da L2). Renomeada em **sete
lugares**, e só nesses sete existia:

| arquivo | o que mudou |
|---|---|
| `SPEC.md:5391` | `## ADR 2026-09-08c` → `## ADR 2026-09-08f` |
| `EVOLUCAO.md:16` | `ADR08c (volta V12-B)` → `ADR08f (volta V12-B)` |
| `Traco/Caderno/CadernoView.swift:228` | comentário `(ADR 08c)` → `(ADR 08f)` |
| `Traco/Pagina/PaginaView.swift:316` | comentário `(ADR 08c)` → `(ADR 08f)` |
| `ferramentas/orca/v12b-pagina.md:263` | scorecard |
| `ferramentas/orca/v12c-medidas.md` | 5 menções (tabela de corte, exceção, scorecard, arquivos) |
| `ferramentas/orca/revisao-v12b-pagina.md` | intocado: é o texto do revisor, que fala de `08c` como achado |

Conferido no fim: `grep -rn "08c" SPEC.md EVOLUCAO.md ferramentas/orca/v12b-pagina.md ferramentas/orca/v12c-medidas.md Traco TracoTests` devolve **0** linhas;
`grep -n "^## ADR 2026-09-08" SPEC.md` mostra `08a` e `08f` (a `08c` de `main`
chega no merge do orquestrador, sem colisão). SPEC e EVOLUCAO dizem a mesma
letra.

## 2. Performance — o quadro longo, isolado

### 2.1 O que a V12-C tinha

Um quadro longo isolado na fase de rolagem em 3 de 6 rodadas (92, 151 e
176 ms) e a hipótese "o aviso da análise caiu no deslize". O
`CadernoHitchesTests` contava quadros, mas não sabia **o que mudou no quadro
longo**.

### 2.2 A sonda

Três acréscimos ao teste, nenhum ao app:

- **sonda por quadro** — o `CADisplayLink` passa a gravar, a cada quadro, o
  `adjustedContentInset.bottom` do papel (= a altura do encaixe: muda quando o
  aviso, o cartão ou o "lendo…" entram) e o `contentOffset.y`;
- **cada quadro longo impresso com o que mudou nele** — instante na fase,
  duração, inset antes→depois, offset antes→depois;
- **a chamada de rolar cronometrada** — se `setContentOffset(animated:)`
  demorasse, o custo seria síncrono no pedido;
- e, à medida que a causa recuava, **a espera medida**, **a primeira descida
  separada** e **a captura cronometrada** (2.4–2.6).

### 2.3 Rodadas 1–3 — o protocolo antigo, agora com a sonda

| rodada | digitação (1232 car.) | rolagem (3 idas e voltas) | o quadro longo |
|---|---|---|---|
| 1 | 1736 quadros, 0 perdidos | 253 quadros, **1 perdido, 150,8 ms** | **+0,15 s** da 1.ª descida, inset **192→192**, offset 0→186 |
| 2 | 1745 quadros, 1 perdido (33 ms) | 252 quadros, **1 perdido, 176,5 ms** | **+0,18 s**, inset **192→192**, offset 0→224; chamada 0,2 ms |
| 3 | 1738 quadros, 1 perdido (33 ms) | 253 quadros, **1 perdido, 130,9 ms** | **+0,13 s**, inset **192→192**, offset **0→0**; chamada 0,2 ms |

Em **3 de 3** o quadro longo está no mesmo lugar — o começo da **primeira**
descida —, o encaixe **não muda de altura** nesse quadro nem em nenhum outro da
rolagem, e a chamada de rolar custa menos de 1 ms. E a linha `HITCH aviso`
diz o resto: **192 pt ao fim da digitação, 192 pt 2,5 s depois** — sob teste o
aviso nem entra (o Grok cala quando `emTeste`, `Grok.swift:30`, e nem cartão
nem "lendo…" mudaram o encaixe nos ~9 s medidos). A hipótese da V12-C está
**refutada**: o aviso não cai no deslize porque não há aviso. (De passagem: a
linha antiga dizia "geometria com cartão: 192 pt"; 192 pt é o encaixe VAZIO —
régua e ações —, o rótulo estava errado e foi corrigido.)

### 2.4 Rodadas 4–9 — a primeira descida separada; rodadas 10–12 — o respiro que a limpou

Como o quadro estava sempre no começo da primeira descida, ela virou fase
própria, seguida de **3 idas e voltas em regime**. Seis rodadas:

| rodada | primeira descida (449 pt) | rolagem em regime (3 idas e voltas) |
|---|---|---|
| 4 | 42 q., **157,0 ms** a +0,16 s, offset 0→0 | 253 q., **0 perdidos**, máx. 16,7 ms |
| 5 | 41 q., 25,1 ms a +0,03 s | 253 q., **0 perdidos**, máx. 16,7 ms |
| 6 | 43 q., **149,4 ms** a +0,15 s, offset 0→0 | 252 q., **0 perdidos**, máx. 16,7 ms |
| 7 | 43 q., **185,7 ms** a +0,19 s, offset 0→0 | 252 q., **0 perdidos**, máx. 16,7 ms |
| 8 | 42 q., **140,3 ms** a +0,14 s, offset 0→148 | 252 q., **0 perdidos**, máx. 16,7 ms |
| 9 | 42 q., **146,7 ms** a +0,15 s, offset 0→0 | 253 q., **0 perdidos**, máx. 16,7 ms |

Regime **6 de 6 limpo** (1515 quadros); primeira descida com um quadro de
140–186 ms em 5 de 6, quase sempre com o offset **ainda em zero** — o custo
era pago antes de o papel se mover. A hipótese seguinte, "TextKit a paginar o
texto abaixo da dobra", foi testada com uma sonda opt-in: `ensureLayout` do
documento inteiro antes da descida, cronometrado, seguido de 0,5 s de respiro.
Rodadas 10–12: o layout custou **0,0 ms** (o documento já estava paginado) e a
primeira descida ficou **limpa 3 de 3**. Quem limpou foi o **respiro**, não o
layout: o quadro longo é um evento no tempo, ~0,15 s depois de algo que
acontece logo antes da fase.

### 2.5 Rodadas 13–15 — a espera medida aponta o culpado

A espera passou a 3,0 s e a ser medida. Em **3 de 3** o quadro longo apareceu
**duas vezes**: a +0,14–0,15 s da espera (138–154 ms) e a +0,14–0,16 s da
primeira descida (136–157 ms), sempre inset 192→192, offset 0. E as duas fases
tinham a mesma coisa imediatamente antes: **`fotografar()`** — o teste
desenhava a janela inteira (`drawHierarchy(afterScreenUpdates: true)`) e
codificava um PNG de 1,3 MB na main thread, logo antes de começar a medir. A
V12-C tinha essa captura exatamente antes da rolagem; conforme a codificação
caía antes ou depois do primeiro quadro medido, o hitch aparecia ou não — os
"3 de 6".

### 2.6 Rodadas 16–21 — protocolo final: a captura cronometrada e fora das janelas

`fotografar()` passou a cronometrar-se e a ser seguida de 0,5 s de respiro,
chamada só fora de fase medida (uma depois da espera, uma no fim). Seis
rodadas, mesmo build, mesmo aparelho:

| rodada | digitação (1232 car.) | espera 3,0 s | primeira descida | rolagem em regime | captura (ms na main thread) |
|---|---|---|---|---|---|
| 16 | 1739 q., 1 perdido (44,8 ms) | 180 q., **0** | 41 q., **0** | 252 q., **0** | 159,3 · 129,0 |
| 17 | 1769 q., **0** | 180 q., **0** | 41 q., **0** | 253 q., **0** | 148,4 · 135,8 |
| 18 | 1769 q., **0** | 180 q., **0** | 42 q., **0** | 252 q., **0** | 162,2 · 152,8 |
| 19 | 1738 q., **0** | 180 q., **0** | 41 q., **0** | 253 q., **0** | 161,0 · 126,6 |
| 20 | 1737 q., 1 perdido (54,1 ms, a +28,4 s) | 180 q., **0** | 41 q., **0** | 253 q., **0** | 159,3 · 155,0 |
| 21 | 1738 q., **0** | 180 q., **0** | 41 q., **0** | 253 q., **0** | 127,0 · 129,5 |

**Espera, primeira descida e rolagem em regime: 6 de 6 com 0 quadros perdidos**
(1080 + 247 + 1516 = 2843 quadros, maior intervalo 16,7 ms em todas). A
captura custa **127–162 ms** — o mesmo intervalo dos quadros longos de todas as
rodadas anteriores (131–186 ms). A digitação mantém o ruído da V12-C: 0–1
quadro de 45–54 ms em ~1750, no primeiro `insertText` ou a +28 s.

Todas as linhas `HITCH` das 21 rodadas: `v12d-hitch-linhas.txt`.

### 2.7 A decisão do ponto 2

**Causa provada e eliminada, saída (a):** o quadro longo **não era o aviso**
(o encaixe fica em 192→192 pt e sob teste o aviso nem entra) **nem o app** —
era a **captura do próprio teste** (127–162 ms na main thread) a cair a
+0,15 s da fase seguinte; tirada das janelas medidas, **6 de 6 rodadas
limpas** em espera, primeira descida e rolagem em regime. Nenhuma linha de app
muda e **nada vai ao RUMO**: não há custo a declarar. O que fica é a lição de
instrumento, escrita no próprio teste: o que grava a prova para o olho nunca
corre dentro do que mede.

## Scorecard (preenchido por mim; a nota final é do revisor independente)

| dimensão | nota | por quê |
|---|---|---|
| Visão | 9 | inalterado |
| Contrato | 9 | `08f` em sete lugares, zero `08c` restante, SPEC e EVOLUCAO a dizer o mesmo |
| Correção | 9 | 21 rodadas verdes de `CadernoHitchesTests`; nenhuma linha de app fora dos dois comentários |
| Jornada real | 9 | inalterado |
| Design | 9 | inalterado (nenhum pixel tocado) |
| Simplicidade | 9 | inalterado (re-G3) |
| Movimento | 9 | inalterado |
| Componentes | 9 | inalterado |
| Acessibilidade | 9 | inalterado (re-G3) |
| Performance | 9 | causa isolada com sonda por quadro (o instrumento a medir-se), hipótese do aviso refutada com número, 6/6 rodadas com 0 perdidos em três fases medidas |
| Privacidade e autoria | n/a | nada tocado |
| Estado honesto | 9 | dito que o aviso não entra sob teste; corrigido o rótulo "com cartão" que era encaixe vazio; as duas hipóteses erradas (aviso, TextKit) e as rodadas que as derrubaram estão coladas |
| Complexidade | 9 | app: 2 linhas de comentário; teste: +~45 linhas (sonda, fases, captura cronometrada), opt-in como antes |
| Fora do app | n/a | — |
| Relato | 9 | 21 rodadas coladas por protocolo, decisão em uma linha, limite do instrumento dito |

## Arquivos desta volta

| arquivo | o que é |
|---|---|
| `v12d-hitch-linhas.txt` | todas as linhas `HITCH` das rodadas 1–21, por protocolo, e o custo de cada captura |
| `v12d-hitch-digitado.png` · `v12d-hitch-fim.png` | as capturas de dentro do processo da última rodada: a linha do autor com o teclado de pé, e o papel rolado ao fim com a última linha acima da régua (o teclado físico do teste não se desenha) |
| `TracoTests/CadernoHitchesTests.swift` | sonda por quadro, quadro longo com o que mudou nele, chamada de rolar cronometrada, espera e primeira descida como fases, captura cronometrada e fora das janelas medidas |
| `SPEC.md` ADR 08f | bloco "A letra e o quadro longo (V12-D)" |
| `revisao-v12b-pagina.md` | a seção re-G3 do revisor, que estava por comitar no worktree e entra neste commit intocada |
| `EVOLUCAO.md` | frase V12-D na célula da ADR08f |
