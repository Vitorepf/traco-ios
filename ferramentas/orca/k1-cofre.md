# K1 — a suíte integral apagava a conta do dono

**Aparelhos.** Trabalho: `34CC3F94-FDB5-4575-A4F5-80271829A18B` (iPhone 17 Pro,
teste 3) — build, três corridas de teste. **Conta: `B91C8DEF` — nunca tocado**,
nenhum `xcodebuild`, nenhum install, nenhum `erase`; só leitura de metadados do
arquivo de keychain, fora do simulador. **A trava `com-trava.sh` foi segurada nas
três corridas** e solta ao fim de cada uma. Não liguei nem desliguei nenhum
simulador: encontrei os dois já de pé (`34CC` foi ligado por outra volta) e
deixei-os como estavam — não desligo o que não liguei.

## Linha do ciclo (G0)

**Ciclo:** preservar o que é do autor. **Intenção:** rodar a suíte não custa a
conta de ninguém. **Obstáculo:** dois testes escreviam no keychain real do
simulador. **Evidência:** a conta viva antes e depois, com a fumaça colada.

## A causa, confirmada

`TracoTests` roda **hospedada dentro do app**. O keychain é do **simulador**, não
do processo de teste. `ContaGrok.sair()` faz `guardar(nil, …)` em `oauth-acesso`
e `oauth-renova` do serviço `app.traco.xai` — o serviço de verdade. Os dois
testes que o chamavam (`NotasESessaoTests.swift:572` e `:578`) apagavam a conta.

**As irmãs.** `grep` por `SecItem`, `kSecAttrService`, `app.traco.xai` e
`grokExpiraEm`: **todo o acesso ao cofre do app vive dentro de `ContaGrok`** e em
mais lado nenhum. `ContaGrok.sair()` tem três chamadores: os dois testes e
`PerfilView.swift:505` (o botão do autor, que é para apagar mesmo). Por isso a
guarda foi ao **serviço**, não a `sair()`: assim ela cobre `guardar`, `lido`,
`ligada`, `token`, `renovar` e `guardarSessao` — e o teste que ainda não existe.

## O conserto (3 linhas, `Traco/Analise/ContaGrok.swift`)

```swift
static let emTeste = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
static let servico = emTeste ? "app.traco.xai.testes" : "app.traco.xai"
private static let chaveExpira = emTeste ? "grokExpiraEm-testes" : "grokExpiraEm"
```

Injetar, não pular: os dois testes ficam de pé com o texto que tinham. É o mesmo
desvio da ADR 05u (`SuperficieDisco.isolarParaTestes()`), que pegou o App Group e
esqueceu o cofre — o precedente já estava na casa, lido pela metade.

## Prova 1 — o vermelho, reproduzido

Um teste descartável (`k1ProvaDoCofre`, removido depois da prova) plantou uma
conta FALSA no serviço **real** e chamou `sair()`. Corrida com o valor antigo
(`servico = "app.traco.xai"`), `34CC3F94`, `-parallel-testing-enabled NO`:

```
◇ Test k1ProvaDoCofre() started.
K1 ANTES  acesso=FALSO-acesso-k1 renova=FALSO-renova-k1
K1 DEPOIS acesso=APAGADO renova=APAGADO
✘ Test testeNuncaEscreveNoCofreDoAparelho() recorded an issue at NotasESessaoTests.swift:641:9:
  Expectation failed: (ContaGrok.servico → "app.traco.xai") != "app.traco.xai"
✘ Test run with 6 tests in 1 suite failed after 0.086 seconds with 1 issue.
** TEST FAILED **
```

A conta plantada some entre uma linha e a seguinte. É o defeito, na tela.

## Prova 2 — o verde, mesma corrida

Mesmo teste, mesmo aparelho, só com o conserto no lugar:

```
K1 ANTES  acesso=FALSO-acesso-k1 renova=FALSO-renova-k1
K1 DEPOIS acesso=FALSO-acesso-k1 renova=FALSO-renova-k1
K1 LIMPO  acesso=APAGADO renova=APAGADO
✔ Test k1ProvaDoCofre() passed after 0.045 seconds.
✔ Test testeNuncaEscreveNoCofreDoAparelho() passed after 0.017 seconds.
✔ Test run with 6 tests in 1 suite passed after 0.097 seconds.
** TEST SUCCEEDED **
```

`sair()` correu e a conta continua onde estava. (`K1 LIMPO` é a sonda a apagar a
conta falsa que ela própria plantou — não deixei lixo no aparelho.)

## Prova 3 — o portão

`testeNuncaEscreveNoCofreDoAparelho`, em `TracoTests/NotasESessaoTests.swift`,
afirma duas coisas: que sob teste `ContaGrok.servico` **não é** `app.traco.xai`,
e — lendo o cofre do aparelho direto por `SecItemCopyMatching` — que `sair()`
**não move** o que lá está. A primeira asserção é a que morde, e a prova de que
morde é a corrida vermelha acima: com o valor antigo restaurado, ela falha.

## Prova 4 — suíte integral por `com-trava.sh`, no `34CC3F94`

```
ferramentas/orca/com-trava.sh xcodebuild test -project Traco.xcodeproj -scheme Traco \
  -destination 'id=34CC3F94-FDB5-4575-A4F5-80271829A18B' -parallel-testing-enabled NO

✔ Test run with 991 tests in 160 suites passed after 89.654 seconds.
** TEST SUCCEEDED **
```

990 antes, 991 agora: o portão novo.

## A conta do dono, no `B91C8DEF`, depois de tudo

Leitura só de fora, sem tocar no simulador (cópia do keychain para o scratchpad,
`sqlite3` na cópia):

```
B91C8DEF genp=48 → agrp `W28WF9A5A2.app.traco` = 2 linhas   (oauth-acesso + oauth-renova)
34CC3F94 genp=43 → agrp `W28WF9A5A2.app.traco` = 0 linhas   (a suíte não deixou rastro)
```

E os carimbos, às 11h49, depois das minhas três corridas (11h44, 11h46, 11h47):

```
B91C8DEF  keychain-2-debug.db-wal  11:22:14   ← ANTES da primeira corrida minha
34CC3F94  keychain-2-debug.db-wal  11:49:19   ← a minha suíte
```

O cofre do aparelho da conta não foi escrito por nada meu, e as duas linhas do
Traço estão lá. **A conta do dono está viva.** Não consegui ler `ContaGrok.ligada`
de dentro do app no `B91C8DEF` porque isso exigiria correr algo nele, que é
exactamente o que a ordem proíbe — declaro isto como limite do instrumento, não
como prova em falta: as duas linhas no grupo de acesso do app são o cofre.

## O que fica aberto (dívida nomeada no RUMO, §8)

O `UserDefaults.standard` do app continua real dentro da suíte: `revisaoNivel`,
`revisaoProxima`, `revisaoConta`, `padroesVistas` e a chave do rascunho do
Trabalho. Nenhuma é credencial, cada teste limpa a sua, e por isso não segurou
esta volta. Escrito no RUMO com dono.

## Scorecard (preenchido por mim; a nota é do revisor)

| dimensão | nota | porquê |
|---|---:|---|
| G0 — ciclo e intenção | 9 | preservar o que é do autor, dito e medido |
| G1 — mérito do conserto | 10 | causa-raiz no ponto único de passagem, 3 linhas |
| G2 — prova | 10 | vermelho reproduzido, verde na mesma corrida, portão que morde, suíte integral |
| G3 — tela | n/a | não há superfície nova; o motor é o cofre |
| G4 — ponytail | 10 | reusou o precedente da 05u, sem arquivo novo, sem abstração |
| G5 — fecho | 9 | ADR, letra registada, dívida nomeada; falta a mescla, que é do orquestrador |
