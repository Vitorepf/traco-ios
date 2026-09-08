# G5 da V17 — a prova da árvore mesclada

Implementador, 08/09/2026, 16h40. Branch `Vitorepf/volta-v17-artefato`, commit de merge `a010725`.
Simulador **iPhone 17 Pro (teste 2) `B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9`**, que já estava ligado —
não liguei nem desliguei nenhum aparelho, não rotacionei e não mexi em tamanho de letra, então não há
nada a restaurar. Nenhum toque no `C2416CBC` (o da conta Grok), no `6033B043`, no `34CC3F94`, no
`C7341E64` nem no `64F7B8B4`. Nenhum mouse, nenhum maestro. Build e teste por `com-trava.sh`: segurei a
trava do instrumento nas duas passadas, uma de cada vez.

## 1. A prova dos portões entrou na árvore

Estava solta no worktree e agora está no commit `68d3807`: o parecer `g4-v17-design.md`, as 11 capturas
`g4-v17-*.png` e o `revisao-v17-artefato.md` como o revisor o deixou — não editei uma linha dele.

As capturas passaram por `sips -Z 1000` antes do commit, porque o RUMO (linha 150) recusa PNG acima de
400 KB desde a V10. **3,7 MB → 1,8 MB**, quatro estavam acima do teto e nenhuma está agora:

| captura | antes | depois |
| --- | ---: | ---: |
| `g4-v17-ajuste-indisponivel.png` | 455 997 | 208 112 |
| `g4-v17-rota-contestar.png` | 451 805 | 185 369 |
| `g4-v17-tentativa-da-causa.png` | 432 190 | 173 780 |
| `g4-v17-nesta-versao.png` | 397 353 | 238 161 |
| `g4-v17-a-pedido-seu.png` | 366 160 | 214 329 |
| `g4-v17-leitura-contestada.png` | 349 704 | 170 357 |
| `g4-v17-tentativa-da-causa-ax5.png` | 289 223 | 140 223 |
| `g4-v17-nesta-versao-ax5.png` | 285 866 | 169 970 |
| `g4-v17-leitura-nao-concluida.png` | 279 378 | 133 720 |
| `g4-v17-tres-capsulas.png` | 262 357 | 124 245 |
| `g4-v17-tres-capsulas-ax5.png` | 248 485 | 116 493 |

A maior agora é `g4-v17-nesta-versao.png`, com 238 161 bytes.

## 2. `main` veio para o branch

`git merge main` tocou 21 commits — P1, L2 e F4-F/G/H mescladas, mais RUMO, LACO, ESTEIRA e os pareceres
do conselho. **Um único conflito, em `SPEC.md`, e de lugar, não de sentido:** as duas pontas apenderam ADR
no mesmo fim do documento — este branch a `08j` e a `08k`, `main` a `08i` (o corte honesto da F4-H).
Resolvi mantendo os dois lados **em ordem cronológica**: a `08i` primeiro, porque é a mais antiga, e a
`08j`/`08k` depois, onde já estavam. Nenhuma linha de nenhum dos lados se perdeu, e nada mais foi tocado.

**A letra da ADR desta volta continua `2026-09-08j`.** Depois do merge o SPEC tem `08a`, `08b`, `08e`,
`08g`, `08h`, `08i`, `08j`, `08k`, nessa ordem, sem colisão: `main` parava na `08i`.

`git log HEAD..main` = **0**.

## 3. A árvore mesclada está provada

Build, no `B91C8DEF`, com `-destination id=` e `-parallel-testing-enabled NO` (há seis simuladores ligados
nesta rodada, e com mais de dois o `xcodebuild test` pendura):

```
** BUILD SUCCEEDED **
```

Zero `warning:` na saída inteira.

Suíte integral, mesma trava, mesmo aparelho:

```
✔ Test run with 928 tests in 149 suites passed after 10.674 seconds.
** TEST SUCCEEDED **
```

Eram 912 antes do merge; `main` trouxe mais 16. Nenhuma falha na passada inteira (`✘` não aparece uma vez
no log). O ruído de `CHHapticPattern`/`hapticpatternlibrary.plist` é do simulador, não do app.

Portão do movimento, que o diff desta volta obriga porque tocou `TrabalhoView`:

```
◇ Suite PortaoDoMovimentoTests started.
✔ Test aVarreduraAindaEnxerga() passed after 0.001 seconds.
✔ Test nenhumMovimentoNovoForaDeTema() passed after 0.988 seconds.
✔ Suite PortaoDoMovimentoTests passed after 0.989 seconds.
```

O portão não tem teto numérico a comparar: `nenhumMovimentoNovoForaDeTema` exige lista de divergências
vazia (`PortaoDoMovimentoTests.swift:188`), e ela está vazia. Nada subiu, nada a declarar.

## O que esta passada NÃO fez

Não mexi em nada que passou nos portões. Não tentei a jornada com provedor real — é da frente Q e está
declarada como lacuna na `08j`. Não consertei os quatro P3 do juiz (`isHeader` nas duas seções novas, o
`id` do `DisclosureGroup`, as aspas do "A pedido seu.", o `spacing` literal): não bloqueiam, o
orquestrador os põe no RUMO. **Não mesclei em `main`** — isso é do orquestrador.
