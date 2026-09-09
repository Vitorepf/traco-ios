# B1-B — o portão da regex se contornava com uma chamada aninhada

Volta de correção do **P1 do G3** sobre a B1 (`ea48a8e`, já em `main`). Branch
`Vitorepf/volta-b1-trybang`, sem mesclar. Aparelho de trabalho `34CC3F94` (teste 3),
ligado e desligado dentro da corrida, sob `ferramentas/orca/com-trava.sh`.

## O defeito, reproduzido antes de consertar

O reconhecedor do portão era `#"\bregex\(([^()]*)\)"#`. `[^()]*` proíbe parêntese
dentro do argumento, então numa chamada embrulhada **o padrão não casa em lugar
nenhum** — a chamada não fica "aceita": fica **invisível**. A contagem nem sobe.

Plantei em `ConferenciaTrabalho`, logo acima da declaração de `regex(_:)`:

```swift
static let padraoDeFora = blocosDeTempo
static func sonda() { _ = regex(padraoDeFora.trimmingCharacters(in: .whitespaces)) }
```

e rodei o portão com o arquivo de teste **de `ea48a8e`** e depois com o desta volta,
mesmo plantio, mesmo aparelho:

```
###### [A] PARSER ANTIGO (HEAD) + plantio ANINHADO — o bypass do G3
✔ Test aConferenciaSoAceitaPadraoLiteralDoProprioArquivo() passed after 0.003 seconds.
✔ Test run with 6 tests in 1 suite passed after 0.028 seconds.

###### [B] PARSER NOVO + o MESMO plantio ANINHADO
✘ Test aConferenciaSoAceitaPadraoLiteralDoProprioArquivo() recorded an issue at
  PortaoDoTryBangTests.swift:270:9: Expectation failed:
  (deFora → ["padraoDeFora.trimmingCharacters(in: .whitespaces)) }"]).isEmpty → false
✘ Test run with 7 tests in 1 suite failed after 0.035 seconds with 1 issue.
```

E a forma **plana**, para provar que ela não regrediu:

```
✘ ... Expectation failed: (deFora → ["padraoDeFora"]).isEmpty → false
↳ padrão que NÃO é literal deste arquivo chegando a `regex(_:)`:
  padraoDeFora
```

Por que isto era P1 e não acabamento: no código de verdade o padrão quase nunca chega
cru. Chega depois de um `trimming`, de um `map`, de uma interpolação — ou seja, o
portão dava verde **exatamente para a forma que a dívida real teria**.

`Traco/` voltou byte a byte ao original depois das sondas (`git diff --stat Traco/`
vazio; o plantio foi restaurado de `/tmp/conferencia.orig`).

## O conserto

Um extrator, `AProvaDosQuatro.argumentosDeRegex(_:)`, em vez do regex de uma linha:

- casa só `#"(func\s+)?\bregex\("#` — a captura 1 marca a **declaração** e a tira;
- do que vem logo depois, na mesma linha, exige um **identificador NU seguido de `)`**;
- qualquer outra forma volta como **o resto da linha, cru**, e por não ser nome de
  literal do arquivo cai em `deFora`. Isto é o que fecha o bypass: não se tenta
  entender o argumento embrulhado, só se recusa a chamá-lo de literal.

Consumir apenas `regex(` (e não até o `)`) tem um efeito colateral bom: **duas chamadas
na mesma linha continuam sendo duas**. O parser antigo, ao consumir até o fecho,
engolia a segunda.

O extrator tem um só chamador de produção (o portão) e um de sonda — não é abstração
especulativa, é o mesmo código que os dois testes precisam ver igual.

## LIMITE DECLARADO (também no portão, na ADR 09o e no RUMO)

O portão reconhece **apenas `regex(nome)` na mesma linha**. Saem VERMELHAS, mesmo
sendo literais do próprio arquivo:

1. concatenação (`regex(a + b)`), interpolação e string inline (`regex("(?i)…")`);
2. chamada partida em duas linhas.

A troca é deliberada e a direção importa: **nenhuma dessas formas produz falso VERDE.**
Quem precisar de uma delas tira o `try!` de `regex(_:)` — o conserto de verdade — ou
alarga `argumentosDeRegex` **com a sonda da forma nova junto**. Alargar sem sonda é
reabrir o P1. Portão que promete mais do que vê é o defeito que esta volta consertou.

## As duas formas ficam guardadas

`oPortaoDaConferenciaEnxergaArgumentoAninhado` — quatro casos no arquivo, para a
próxima pessoa não precisar redescobrir: as duas que TÊM de acusar (plana e aninhada)
e as duas que NÃO podem (literal declarado e a própria declaração de `regex(_:)`).

## Suíte integral

```
$ ferramentas/orca/com-trava.sh xcodebuild test -scheme Traco \
    -destination 'platform=iOS Simulator,id=34CC3F94-FDB5-4575-A4F5-80271829A18B' \
    -parallel-testing-enabled NO
✔ Test aConferenciaSoAceitaPadraoLiteralDoProprioArquivo() passed after 0.005 seconds.
✔ Test oPortaoDaConferenciaEnxergaArgumentoAninhado() passed after 0.001 seconds.
✔ Test run with 997 tests in 161 suites passed after 88.508 seconds.
** TEST SUCCEEDED **
```

997 = 996 da B1 + 1 (a sonda do parser). `grep -c ' warning: '` no log: **0**.

## Instrumento e limites

Só o **`34CC3F94`** (teste 3): `simctl boot` no começo da corrida, `simctl shutdown`
no fim — conferido, ele está `Shutdown` agora. **`B91C8DEF` não foi tocado**: nenhum
`xcodebuild test`, nenhum install, nenhum `erase`/`clearState`/`uninstall`; continua
`Booted` como aparelho da conta, e por isso não houve leitura de `ContaGrok.ligada` a
colar (não houve instalação por cima que a exigisse).

Sem captura de tela: esta volta é um teste que lê arquivo-fonte, não tem superfície.
Nenhuma função de voz, Siri, ditado ou VoiceOver foi acionada; nenhum iPad envolvido.
A sonda de parser fora da suíte rodou como `swift sonda.swift` no scratchpad da sessão
e foi descartada — o que ela mediu está reproduzido pelos testes acima, na suíte.

## Scorecard (preenchido por mim; a nota final é do revisor independente)

| dimensão | nota | evidência |
|---|---:|---|
| Visão | 10 | o portão volta a guardar o que promete guardar |
| Contrato | 9 | ADR 09o com adendo, RUMO com o limite nomeado, portão com o limite escrito dentro |
| Correção | 9 | bypass reproduzido antes, vermelho medido nas duas formas, verde só depois |
| Jornada real | n/a | sem alteração de tela ou navegação |
| Design | n/a | sem superfície visual |
| Simplicidade | 9 | um extrator, dois chamadores; nada de parser de expressão |
| Movimento | n/a | sem animação |
| Componentes | n/a | sem componente |
| Acessibilidade | n/a | sem superfície; VoiceOver não acionado (proibido) |
| Performance | n/a | teste de texto, 0,005 s |
| Privacidade e autoria | n/a | não toca conteúdo do autor |
| Estado honesto | 10 | o limite do portão está declarado em três lugares em vez de escondido |
| Complexidade | 9 | +56 linhas em um arquivo de teste, zero em produção |
| Fora do app | n/a | sem superfície externa |
| Relato | 10 | as duas saídas coladas, plantio e restauração descritos |
