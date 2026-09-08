# V12-F — o teste do A1 não passava pelo caminho do A1

Claude Fable 5.1, 08/09/2026, 17h20–17h55. Worktree `volta-v12b-pagina`, topo
de partida `aafdc72`. Simulador **iPhone 17 Pro (teste 2) `B91C8DEF`**, o meu.
Todo `xcodebuild` e toda condução sob `ferramentas/orca/com-trava.sh` — **declaro
que segurei a trava**. Nenhum `orca emulator` nesta volta (o condutor é o
XCUITest preso ao UDID); nenhum maestro; nenhum mouse; `C2416CBC` (conta Grok)
e `6033B043` (juiz do re-G4) intocados; nenhum simulador alheio desligado. O
`design-router` não foi carregado: a volta não escreve SwiftUI de tela, cor,
fonte nem movimento — toca um alvo de teste e um script de shell.

## O que o re-G3 apanhou

`testLargeComCartao` aceitava `sem-cartao` como saída normal e passava VERDE
sem tocar "Abrir os campos". Quarto instrumento do dia a provar menos do que
parecia. Conferi o estado do aparelho ANTES de tocar em qualquer coisa:
`autoAnalise => false` no plist do contêiner do app em `B91C8DEF` — o mesmo
estado que a memória de 08/09 já acusava —, e `ConnectHardwareKeyboard = 1`
(sem teclado de software, o filme do A1 não é o filme do A1).

## Os consertos

1. **Pré-condições que falham** (`TracoUITests/EscritaVisivelUITests.swift`):
   `exigir(_:_:)` — cartão (`cartao-recolhido`), botão "Abrir os campos" e
   folha aberta (`forma-*`) são três `XCTFail` com o motivo; a falha escreve
   `/tmp/v12e/falhou.pronto` com o motivo dentro. Os casos "encaixe vazio"
   afirmam o contrário (`XCTAssertFalse(cartao.exists)`). Em AX5 o botão vive
   no menu da linha do cartão: o teste toca a linha e acha o item por
   identificador OU rótulo. A classe virou `@MainActor` (zero avisos no build).
2. **O estado do aparelho sai da prova**: `-autoAnalise <true/>` em
   `launchArguments`. Tem de ser `<true/>`: provei com um binário de linha de
   comando que no domínio de argumentos `1`, `YES`, `true` chegam como
   `NSTaggedPointerString` e `as? Bool` devolve nil, enquanto `<true/>` e
   `<false/>` chegam como `__NSCFBoolean`. A primeira planta (`"0"`) passou
   verde exatamente por isso — e por isso o teste que aceita o estado errado
   é pior que nenhum: sem a pré-condição eu teria acreditado no `"1"`.
3. **Condutor** (`ferramentas/orca/v12e-conduzir.sh`): reconhece
   `falhou.pronto` em qualquer fase, imprime o motivo, fotografa e sai; o caso
   sem cartão se reconhece em 1 s (antes esperava `gravar` por 180 s).

Achado colateral registrado: `xcodebuild test-without-building` trocou o
contêiner de dados do app (UUID `F373C593` → `BFEAB75A`, sem plist), então
plantar `autoAnalise=false` pelo plist não chegou ao app; a planta válida é
`<false/>` pelo mesmo canal do conserto.

## Linha VERMELHA (planta `-autoAnalise <false/>`, `v12f-teste-linhas.txt`)

```
EscritaVisivelUITests.swift:33: error: -[TracoUITests.EscritaVisivelUITests testLargeComCartao] : failed - PRÉ-CONDIÇÃO: o cartão da forma não está na tela — o caminho do A1 começa nele
Test Case '-[TracoUITests.EscritaVisivelUITests testLargeComCartao]' failed (35.840 seconds).
** TEST EXECUTE FAILED **
condutor: PRÉ-CONDIÇÃO falhou antes de 'gravar': o cartão da forma não está na tela — o caminho do A1 começa nele
```

Captura do estado plantado: `v12f-planta-falhou.png` (papel, régua, pé,
teclado; nenhum cartão). Planta revertida, rebuild sem aviso, e o candidato
volta a verde: `testLargeComCartao passed (41.409 s)`.

## Refilmagem pelo caminho certo (quadros nativos, `xcrun simctl io B91C8DEF recordVideo`)

Estado antes do toque, nos dois modos: texto WOOP acima da altura do papel,
teclado de software de pé, cartão "isto é um desejo com obstácu…" com "Abrir
os campos" e "Deixar como nota" no pé, régua e "Trabalhar nisto" abaixo
(`v12f-large-meio-cartao.png`). O toque é do XCTest no botão real; a folha
que abre é a WOOP com os quatro campos (`v12f-large-folha.png`).

| modo | filme | último quadro COM encaixe | primeiro SEM | folha sobe | quadros com cartão/pé/régua e campos juntos |
|---|---|---|---|---|---|
| sem RM | `v12f-abrir-sem-rm.mp4` (tiras `-quadros-20-34.png`, `-35-49.png`) | q26, 2,212 s | q27, 2,230 s | q35 | **0 em 69** |
| com RM (`ReduceMotionEnabled = 1`, reboot) | `v12f-abrir-com-rm.mp4` (tiras `-quadros-20-34.png`, `-35-49.png`) | q26, 2,327 s | q27, 2,350 s | q34 | **0 em 69** |

O que se vê entre o corte e a folha (q27–q34) é o papel a crescer para dentro
da faixa que o teclado libera, com os rótulos dos campos que são dele
("RESULTADO", "OBSTÁCULO INTERNO", "SE [OBSTÁCULO], ENTÃO EU"), e a barra
preditiva do teclado a descer com o teclado — superfície do sistema, não do
app. Nenhum quadro tem o cartão, o pé ou a régua ao mesmo tempo que os
campos. O número é o mesmo que a V12-E declarou (0), agora medido por um
teste que FALHA se o cartão ou o botão faltarem. **A prova é amostrada**: uma
tomada por modo, ~60 fps; o oráculo de pixels segue no RUMO.

AX5 (`testAX5ComCartao`, sem RM): o cartão veio, a linha abriu o menu, o item
"Abrir os campos" existiu e a folha abriu — `passed (43.097 s)`;
`v12f-ax5-meio-cartao.png`, `v12f-ax5-folha.png`. Não é o caminho do A1 (o
G4 mediu o A1 em `large`), fica como prova de que a pré-condição também
funciona pelo menu.

Se a refilmagem do juiz do re-G4 discordar destes números, as duas ficam no
relato do orquestrador; não escolhi.

## Estado do aparelho no fim

`ReduceMotionEnabled = 0` (lido: `0`), `ConnectHardwareKeyboard = 1` (lido no
`DevicePreferences`), aparelho reiniciado e `Booted`, `large`. O contêiner do
app é o novo (`BFEAB75A`), sem plist — o `autoAnalise` volta ao padrão `true`.

## Limites honestos

- Refilmei só `large` nos dois modos e AX5 sem RM; os casos "encaixe vazio"
  ganharam a asserção inversa mas não os rodei nesta volta.
- A prova é amostrada (uma tomada por modo); nenhum oráculo de pixels.
- Não sei por que o `xcodebuild` trocou o contêiner; registrei o fato, não a causa.
- Suíte integral (`Traco`) não rodada: nenhum arquivo do app mudou (diff só em
  `TracoUITests/`, `ferramentas/orca/`, `SPEC.md`, `EVOLUCAO.md`).

## Scorecard (preenchido por mim; a nota final é do revisor)

| dimensão | nota | por quê |
|---|---|---|
| Contrato | 9 | regra escrita na 08f: estado de partida é pré-condição que falha; `<true/>` explicado |
| Correção | 9 | vermelho com a pré-condição nomeada colado; verde só pelo caminho com cartão, botão e folha |
| Jornada real | 9 | o A1 é percorrido de verdade: toque real no botão real, folha real |
| Movimento | 9 | 0 quadros com par legível em 69, sem e com RM, pelo caminho certo; amostrado e dito |
| Acessibilidade | 8 | AX5 pelo menu provado sem RM; com RM não refilmado em AX5 |
| Estado honesto | 9 | a planta `"0"` que passou verde está escrita, com a causa provada |
| Complexidade | 9 | +57/−12 no teste, +16/−7 no condutor; nada no app |
