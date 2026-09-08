# V12-C — as quatro medidas que faltavam à V12-B

Worker: Claude Fable 5.1, papel de front-end e design, 08/09/2026, worktree
`volta-v12b-pagina` (candidato anterior `62fc69f`; base `499623c`). Relato da
V12-B: `v12b-pagina.md`. Revisão G3 que pediu as medidas:
`revisao-v12b-pagina.md` (GPT 5.6 Terra, veredito CORRIGIR ANTES em quatro
dimensões — todas por medida que faltava, nenhuma por defeito visto).

**Instrumento.** iPhone 17 Pro Max **`6033B043`**, o meu, já ligado quando
cheguei. Todo `xcodebuild` e `xcodebuild test` sob `ferramentas/orca/com-trava.sh`,
destino por UDID. **Nenhum maestro, nenhum mouse**: o aparelho foi dirigido por
`orca emulator` (`ax`/`tap`/`type`/`gesture`, frames 0..1) e toda captura é
`xcrun simctl io 6033B043 screenshot`. `TRACO_SEM_MODELO=1` no ambiente do
simulador (motor local; nada gasto em conta nenhuma). O build "antes" é a base
`499623c` compilada num worktree temporário no scratch e instalada pelo próprio
`xcodebuild test` — conferido por símbolo: `nm Traco.debug.dylib | grep Pilula.*tinta`
devolve **0** no antes e **1** no depois. Ao fim: `content_size` = `large`,
worktree temporário removido, helper do emulador morto.

**Esta volta é a fase 6 do `design-router` — Julgar e Portão** — com a
`curva-zero` como régua do ponto 1; as fases 1–5 são as da V12-B. Vim medir e
não mudar pixel, mas **a medida de performance expôs um defeito da própria
V12-B** (seção 3) e o conserto é uma linha no `CadernoView`; fora isso, o
código de app só recebeu a passada de corte do ponto 4.

---

## 1. Curva-zero: toques contados, antes e depois

Roteiro: **Página com a forma vestida pela análise automática → "Abrir os
campos" → folha com os campos**. O texto é o mesmo nos dois builds ("Quero
correr de manha mas tenho preguica de levantar"), digitado numa Página nova
depois de relançar o app; a forma veste sozinha na pausa (0 toques).

| tamanho | antes (`499623c`) | depois (esta volta) | capturas |
|---|---:|---:|---|
| `large` | **1 toque** ("Abrir os campos" está no cartão) | **1 toque** | `v12c-antes-large-vestida.png` → `v12c-antes-large-campos.png`; `v12c-depois-large-vestida.png` → `v12c-depois-large-campos.png` |
| AX5 | **2 toques** (o cartão vira menu "•••"; "Abrir os campos" mora dentro) | **2 toques** | `v12c-antes-ax5-vestida.png` → `-menu.png` → `-campos.png`; idem `v12c-depois-ax5-*` |

**Empate**, e é o esperado: a volta moveu geometria, não controles. Quem
conta é a árvore AX de cada passo (`v12c-ax-*-{vestida,menu,campos}.txt`): os
mesmos ids `cartao-recolhido` → `abrir-campos` → `campos-voltar` nos dois
builds. O que a árvore mostra de diferente é a geometria que a V12-B veio
consertar: em `large`, o cartão vestido fica a `y = 0,445` no antes (a meio do
papel — o vão de 86,7 pt) e a `y = 0,671` no depois (colado à régua); em AX5,
`0,521` contra `0,627`.

## 2. VoiceOver: rótulo, ordem e estado desabilitado

**Limite do instrumento, dito antes do número:** o simulador não roda o
VoiceOver. A prova é a **árvore de acessibilidade viva** lida por
`orca emulator ax` — os mesmos elementos, rótulos, traços e estado `enabled`
que o leitor de tela lê; é dela que o VoiceOver monta a fala. O que não está
provado é a fala em si e o gesto de deslizar — isso pede aparelho.

**Estado desabilitado da `Pilula`** (depois, `v12c-ax-depois-large-vestida.txt`
e `v12c-ax-depois-ax5-vestida.txt`):

```
button | 'Recordar'                    | en=False | id=None
button | 'Conferir o hábito em 7 dias' | en=False | id=encadear-compromisso
```

Duas formas (`.acao` no pé, `.larga` na forma), as duas com **`enabled = false`**
— o traço `notEnabled`, que o VoiceOver anuncia como "esmaecido" depois do
rótulo, não como botão comum — e com o **rótulo inteiro**. O rótulo é o texto
da cápsula; não há rótulo derivado de ícone nem elemento sem nome.

**Ordem e rótulos em AX5 vestido** (`v12c-ax-depois-ax5-vestida.txt`), por
posição na tela, de cima para baixo:

1. `Notas`, `Concluir` (topbar)
2. `Página` (grupo, com o texto do autor como valor)
3. `SE (HORA / LUGAR / OBSTÁCULO)` · campo `Se (hora / lugar / obstáculo)` ·
   `ENTÃO EU (…)` · campo `Então eu (…)` · `DEPOIS DISTO` ·
   `Conferir o hábito em 7 dias` (desabilitado)
4. cartão `Se–então. isto é um hábito que trava num gatilho.` (pop up button)
5. `Trabalhar nisto` · `Mais ações da nota` (pop up button)

Todo elemento tem rótulo; os dois menus dizem que são menus ("pop up button");
o cartão recolhido lê a frase inteira mesmo com o texto cortado na tela
("isto é um h…"). **Nenhum defeito exposto pelo leitor** — nada a consertar.

## 3. Performance: digitação e rolagem no `CadernoView`

**Limite do instrumento, com a mensagem colada.** Tentei o Instruments no meu
UDID, três vezes:

```
xctrace record --template "Animation Hitches" … → * [Error] Hitches is not supported on this platform.
xctrace record --template "SwiftUI" …           → * [Error] The SwiftUI instrument is not supported on the Simulator.
xctrace record --template "Time Profiler" --attach <pid> --time-limit 6s → "Starting recording…" e nunca termina (>7 min a 0% de CPU; morto por mim)
```

O revisor abriu a porta do **trace equivalente**, e é isto:
`TracoTests/CadernoHitchesTests.swift` — um teste hospedado no app que instala
um `CADisplayLink` no run loop principal e, enquanto conta os quadros
entregues, **zera a Página, digita 1232 caracteres no `TextEditor` real** (o
mesmo caminho da tecla: `insertText` → binding → `Caderno.comTexto` →
re-render, com o teclado de pé) e **rola o `ScrollView` real do `CadernoView`**
três vezes até o fundo e de volta. Hitch é o que o Instruments chama de hitch:
quadro que chegou atrasado (intervalo > 1,5 × a duração esperada) e o atraso
somado. O mesmo arquivo, a mesma carga, o mesmo aparelho, um build atrás do
outro. Todas as linhas `HITCH` de todas as rodadas estão em
`v12c-hitch-linhas.txt`; as que decidem:

| build | digitação (1232 caracteres, ~29 s) | rolagem (3 idas e voltas) |
|---|---|---|
| antes `499623c` | 1754 quadros, **0 perdidos**, maior intervalo 16,7 ms | 253 quadros, **0 perdidos**, curso 449 pt |
| V12-B como estava (`62fc69f` + corte) | 1739 quadros, 1 perdido (31,1 ms), maior 47,8 ms | 253 quadros, 0 perdidos, **curso 1003 pt** |
| **depois (com o conserto abaixo)** | 1750 quadros, **0 perdidos**, maior 16,7 ms | 252 quadros, **0 perdidos**, curso 449 pt |

Em cinco rodadas por build a digitação oscilou entre 0 e 5 quadros perdidos
em ~1750 (o antes chegou a 5; a V12-B a 2; o depois 0, 0 e 5): ruído de uma máquina
com cinco simuladores, não diferença entre builds. **Uma observação que não
arredondo:** na fase de rolagem, um único quadro longo (92, 151 e 176 ms)
apareceu em 3 das 6 rodadas dos builds com o `VStack` explícito (V12-B e
depois), e em nenhuma das 5 do antes. É um evento por rodada, não um hitch de
rolagem contínuo — a hipótese é o resultado da análise da pausa (o aviso de
"silêncio" a entrar no encaixe) a cair no meio do deslize, que o teste não
separa. Fica nomeado como dívida de medida, não como defeito visto.
**Sem hitch atribuível ao encaixe na digitação nem na rolagem em si** — o
número que a ESTEIRA pede.

**O que a geometria denunciou.** O teste imprime o inset inferior do papel
(`adjustedContentInset.bottom`) e o curso: com o teclado de pé e o encaixe
VAZIO, o antes media **192 pt** (a régua e as ações) e a V12-B **746 pt** — os
mesmos 192 mais **554 pt de teto**. A captura de dentro do processo
(`v12c-digitado-v12b-coberto.png`) mostra o que isso é na tela: **o texto do
autor cortado na terceira linha**, o resto do papel coberto por uma caixa da
cor do fundo até a régua. Causa: `.frame(maxHeight: tetoDoEncaixe)` é um frame
FLEXÍVEL — enche o que o `.safeAreaInset` propõe, o teto inteiro — e a V12-B,
ao tornar `acimaDoPe` um `VStack` explícito, fez a caixa existir **mesmo sem
ocupante** (o `TupleView` vazio de antes não produzia caixa nenhuma). A pilha
do encaixe é opaca (`Tema.fundo`), logo a caixa cobre o papel. O `alignment:
.bottom` da V12-B era verdadeiro, mas tratava o sintoma: uma caixa que cresce
com o teto não devia existir.

**O conserto (uma linha, `CadernoView.swift`):** `.fixedSize(horizontal: false,
vertical: true)` depois do `.frame(maxHeight:alignment:)`. A caixa volta a ter
a altura do ocupante — zero quando vazio, o cartão quando há cartão, nunca mais
que o teto — e o cartão continua colado ao pé por construção (não há mais
caixa para ele saltar dentro). Provado: inset **192 pt** de novo com o encaixe
vazio (`v12c-digitado-depois.png`: o papel inteiro legível até a régua;
`v12c-rolado-depois.png`: a última linha encostada na régua, como no antes
`v12c-rolado-antes.png`), e com um cartão no encaixe, no build final vivo
(`v12c-depois-large-cartao-final.png`, `v12c-ax-depois-large-cartao-final.txt`),
o cartão fica a `y = 0,671`, o pé dele a `0,787` e a régua a `0,803` — os
mesmos ~15 pt (padding + fio) que a V12-B mediu, e o papel (`Página`) passa a
terminar onde o cartão começa (`h = 0,548`, contra `0,676` sem cartão). O
fantasma do `.sheet` não volta por construção — a causa dele era a caixa que
crescia — mas **não refiz o vídeo de quadros nativos**, e a geometria com
cartão E teclado de pé não foi fotografada nesta volta (o `type` do emulador
esconde o teclado de software e a análise não vestiu dentro do teste); fica
dito como limite.

**O teste roda só quando pedido.** Ele dirige o app vivo, e a nota que digita
entra no índice em memória do processo que a suíte inteira compartilha: na
primeira rodada da suíte completa derrubou `IndiceTests` (4 issues,
`Indice.quantas` 3 em vez de 2). Por isso a suíte é `.enabled(if:
TRACO_MEDIR_HITCH == "1")`; a medida se pede assim:

```
TEST_RUNNER_TRACO_MEDIR_HITCH=1 xcodebuild test … -only-testing:TracoTests/CadernoHitchesTests
```

## 4. Complexidade: a passada de corte e a exceção

Antes do corte, o código de app media **+107/−62 = +45** (o revisor conferiu:
com `-w`, +59/−14 = +45). A passada barata, sem perder estado nem prova:

| onde | o que saiu | linhas |
|---|---|---:|
| `Pilula.swift` | `private var tinta` (wrapper de uma linha do `static func tinta`) — inlinado no `foregroundStyle` | −2 |
| `Pilula.swift` | `private var contorno` (wrapper de uma linha) — inlinado no `strokeBorder`; o comentário ficou, em cima de `capsula` | −2 |
| `CadernoView.swift` | comentário de 8 linhas que repetia a ADR 08c → 4 linhas com ponteiro | −4 |
| `PaginaView.swift` | comentário de 7 linhas que repetia a ADR 08c → 4 linhas | −3 |

Depois do corte, +34. Entra então o conserto da seção 3 (uma linha de código
e quatro de comentário no `CadernoView`), e o saldo final
(`git diff 499623c --numstat -- Traco/`) é **+99/−63 = +36**; com `-w`,
+51/−15 = **+36**. Por arquivo: `CadernoView` +7/−1, `Pilula` +36/−7,
`PaginaView` +53/−48 (reindentação do `VStack`; `-w` dá +5/−1),
`RecordarView` +3/−7.

Não fui além disto de propósito: o que resta é a `static func tinta` (existe
para o teste), a hairline (o estado), o preview alargado (a prova para o olho)
e os comentários que contam o porquê. **Não inventei refatoração para caçar o
zero** — o orquestrador foi explícito, e trocar dívida de tamanho por dívida
de clareza seria pior.

**A exceção está na ADR 08c** (`SPEC.md`, bloco "As quatro medidas que
faltavam"): saldo **+36**, autorizado pelo **orquestrador (Claude Opus 5,
08/09)**, porque o crescimento compra **um estado que não existia** (a
`Pilula` desabilitada legível, que estava a 1,53:1 para todos os chamadores)
e **um portão contra a regressão** (`PilulaContrasteTests`) — lacuna nomeada,
que é o que a regra da ESTEIRA pede para admitir crescimento.

---

## Instrumento: o que aconteceu e fica registrado

- **O meu simulador reiniciou o espaço de usuário sozinho, várias vezes**
  (`launchd_sim: committing to system shutdown` às 11:51:52, 11:54:02,
  11:54:44, 11:58:12 e 12:23:45), e o do vizinho `C2416CBC` nove vezes no
  mesmo intervalo. Cada reinício mata o app e o helper do `orca emulator`. Não
  achei a causa no log do host; nenhuma das horas é um `shutdown` meu. Vale
  como lei: **conferir o pid do SpringBoard antes e depois de cada medida** —
  o teste de hitch fez isso por construção (roda numa sessão só do app).
- **`orca emulator type` esconde o teclado de software** (entra pelo caminho
  do teclado físico). Por isso a contagem de toques foi feita com o teclado
  fechado nos dois builds — a contagem não depende dele; a medida de hitch usa
  `becomeFirstResponder` e mede com o teclado de pé.
- **`xcrun simctl ui content_size` aplicou** nas duas idas (AX5 e volta a
  `large`), conferido por leitura.
- **`autoAnalise` estava desligado** no contêiner do meu aparelho (alguém o
  desligou antes de mim); liguei pelo plist do app para a forma vestir
  sozinha, que é o roteiro pedido. Não é estado do produto: é o meu aparelho
  de teste.

## Verificação

```
✔ Test run with 891 tests in 145 suites passed after 8.157 seconds.
```

`xcodebuild test` no UDID `6033B043`, sob `com-trava.sh`, depois da última
mudança de código (o 891.º é `CadernoHitchesTests`, que a suíte pula sem a
variável); **0 `warning:`** no log inteiro do build. A medida, pedida com a
variável, na mesma árvore:

```
HITCH digitação (1232 caracteres no TextEditor): 1733 quadros em 29.0 s, 5 perdidos, hitch 115.4 ms (3.98 ms/s), maior intervalo 55.4 ms
✔ Test run with 1 test in 1 suite passed after 39.303 seconds.
```

## Scorecard (preenchido por mim; a nota final é do revisor independente)

| dimensão | nota | por quê |
|---|---|---|
| Visão | 9 | inalterado da V12-B |
| Contrato | 9 | ADR 08c ganha o bloco das medidas e a exceção com o saldo, a lacuna e quem autorizou |
| Correção | 9 | suíte verde com o teste de medida novo; o defeito que a medida expôs foi consertado e provado |
| Jornada real | 9 | o roteiro Página → vestida → campos percorrido nos dois builds, em `large` e AX5, com captura e árvore a cada toque |
| Design | 9 | inalterado |
| Simplicidade | 9 | **contagem colada**: 1/1 em `large`, 2/2 em AX5 — empate declarado como empate |
| Movimento | 9 | inalterado |
| Componentes | 9 | inalterado; dois wrappers a menos na `Pilula` |
| Acessibilidade | 9 | estado desabilitado exposto como `enabled = false` com rótulo inteiro; ordem e rótulos em AX5 colados; limite (VoiceOver não roda no simulador) dito |
| Performance | 9 | trace equivalente com número nos dois builds (0 perdidos atribuíveis); Instruments recusado pelo simulador com a mensagem colada; a geometria do mesmo teste achou e provou o papel coberto |
| Privacidade e autoria | n/a | nada tocado |
| Estado honesto | 9 | inalterado |
| Complexidade | 9 | +45 → +34 pela passada de corte, +36 com o conserto; o saldo excepcionado na ADR pelo orquestrador, com a lacuna que compra |
| Fora do app | n/a | nada fora do app |
| Relato | 9 | quatro medidas, cada uma com número, caminho da captura e limite do instrumento |

## Arquivos desta volta

| arquivo | o que é |
|---|---|
| `v12c-{antes,depois}-large-vestida.png` / `-campos.png` | o roteiro em `large`, nos dois builds |
| `v12c-{antes,depois}-ax5-vestida.png` / `-menu.png` / `-campos.png` | o roteiro em AX5, nos dois builds |
| `v12c-ax-{antes,depois}-*.txt` | a árvore AX de cada passo (rótulo, `enabled`, id, frame) |
| `v12c-hitch-linhas.txt` | todas as linhas `HITCH` de todas as rodadas, por build |
| `v12c-digitado-v12b-coberto.png` | a V12-B com o teclado de pé e o encaixe vazio: o texto cortado na terceira linha |
| `v12c-digitado-depois.png` · `v12c-rolado-depois.png` | o mesmo estado com o conserto: papel inteiro, última linha na régua |
| `v12c-rolado-antes.png` · `v12c-rolado-v12b.png` | o papel rolado até o fim, antes e na V12-B (o vão de 554 pt) |
| `TracoTests/CadernoHitchesTests.swift` | a medida de hitch em digitação e rolagem, com a geometria e as capturas de dentro do processo |
| `SPEC.md` ADR 08c | as medidas e a exceção de complexidade |
