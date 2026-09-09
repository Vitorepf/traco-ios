# B1 — os `try!` que quebram com dado de fora

Volta B1, trilha B (caça a defeitos, DIRETRIZ §8 item 2). Branch
`Vitorepf/volta-b1-trybang`, sem mesclar. ADR `2026-09-09o` em `SPEC.md`.

## O que a volta foi buscar, e o que achou

A A1 (ADR `2026-09-08s`) deixou oito `try!` congelados no portão
`TracoTests/PortaoDoTryBangTests.swift`, quatro deles julgados **dívida real —
serializam valor vindo de FORA**. A §8 manda "cada uma com teste que reproduz
**antes**": fui atrás do dado que faz cada um explodir na mão do autor.

**Ele não existe — e nos dois piores casos o `try!` guardava a porta errada.**

| alvo | o que se mediu | veredito |
|---|---|---|
| `Notas/Corpus.swift:171` | `JSONEncoder().encode` de um `String` (`campos` é `[String: String]`); o `!` do dicionário ao lado está coberto pelo filtro `f.campos[$0] != nil` três linhas acima | **infalível por construção** |
| `App/Sessao.swift:615` | `JSONEncoder().encode([String])`; `[String]` é sempre JSON válido e `String` do Swift é sempre UTF-8 válido | **infalível por construção** |
| `Analise/FonteNotas.swift` | o `json(_ objeto: Any)`; objeto inválido **não lança**, LEVANTA `NSInvalidArgumentException` | **guarda errado — consertado** |
| `Trabalho/PraticaTrabalho.swift` | o mesmo helper, o mesmo defeito | **guarda errado — consertado** |

### O dado que tentei, e não explodiu

`AProvaDosQuatro.feio` é o pior que um autor consegue digitar e colar: NUL
(U+0000), controle (U+001F), o não-caractere U+FFFF, emoji fora do plano básico,
espaço de largura zero, os separadores de linha e parágrafo do Unicode
(U+2028/U+2029), barra, aspas, `{}[]:,`, tabulação e um acento combinante solto.
Ele entra pelo título e pelo texto da nota, pela pergunta, pela conversa, pelo
catálogo, pelo retrato, pela tentativa da prática e pelos campos do gesto — e
sai inteiro dos quatro. O campo do Corpus **volta idêntico** do backup
(`Corpus.importar` → `Corpus.separarCampos`), que é a prova de ida e volta, não
só de não-crash.

### O achado que valeu a caça

`JSONSerialization.data(withJSONObject:)` com objeto inválido **não devolve
erro**: levanta uma exceção do Objective-C, que mata o processo por baixo de
`try!`, de `try?` e de `do/catch` igualmente. Sonda fora da suíte
(`swift sonda.swift`, porque a exceção não é capturável e derruba o runner):

```
*** Terminating app due to uncaught exception 'NSInvalidArgumentException',
    reason: 'Invalid number value (NaN) in JSON write'
*** Terminating app due to uncaught exception 'NSInvalidArgumentException',
    reason: 'Invalid type in JSON write (__NSTaggedDate)'
```

Trocar `try!` por `try?` ali teria sido **um verde que nunca visita o lugar do
defeito**. O guarda que funciona é `JSONSerialization.isValidJSONObject` antes da
chamada, e é o que está lá agora — três linhas, nos dois arquivos, sem caminho de
erro novo: o esquema vazio derruba a leitura da resposta remota, e essa recusa o
app já sabe dizer.

## VERMELHO antes do verde — as duas sondas, no instrumento

**1. O `try!` de volta em `FonteNotas.json`** (`34CC3F94`, `-parallel-testing-enabled NO`):

```
✘ Test nenhumTryBangNovoNaProducao() recorded an issue at PortaoDoTryBangTests.swift:123:9:
  Expectation failed: (divergencias → ["Traco/Analise/FonteNotas.swift: 1 hoje, 0 congelado  ← SUBIU"]).isEmpty → false
✔ Test aAssinaturaDaNotaAceitaOTextoMaisFeio() passed after 0.034 seconds.
2026-09-09 13:34:19.641028-0300 Traco[63902:15558530] *** Terminating app due to uncaught
  exception 'NSInvalidArgumentException', reason: 'Invalid number value (NaN) in JSON write'
** TEST FAILED **
```

Repare no que a segunda linha mostra: o `oGuardaDoJson…` **não falha, ele mata o
runner** — o app morre e o arnês nem registra o teste. É exatamente o que
aconteceria com o autor: tela morta, sem explicação, sem recuperação.

**2. Um padrão de fora chegando a `ConferenciaTrabalho.regex(_:)`** (plantei
`let padraoDeFora = texto` e troquei uma chamada):

```
✘ Test aConferenciaSoAceitaPadraoLiteralDoProprioArquivo() recorded an issue at
  PortaoDoTryBangTests.swift:274:9:
  Expectation failed: (deFora → ["padraoDeFora"]).isEmpty → false
↳ padrão que NÃO é literal deste arquivo chegando a `regex(_:)`:
  padraoDeFora
✘ Test run with 6 tests in 1 suite failed after 0.037 seconds with 1 issue.
** TEST FAILED **
```

Os dois arquivos foram revertidos byte a byte depois de cada sonda
(`git diff --stat` conferido).

**Limite do instrumento, declarado:** a primeira tentativa de sonda usou
`-only-testing:TracoTests/AProvaDosQuatro/aConferencia…` e o xcodebuild devolveu
`** TEST SUCCEEDED **` **sem rodar teste nenhum** — o filtro com nome de função
não casa em Swift Testing. `0 de N não é resultado`: repeti com o filtro da suíte
inteira, e é essa a saída colada acima.

## A quinta, agora guardada

`ConferenciaTrabalho.regex(_:)` faz `try! Regex("(?i)" + padrao)`. É infalível
**só enquanto todo chamador passar um literal do próprio arquivo** — no dia em
que alguém passar um padrão vindo do documento, do pedido ou da resposta da IA,
um `[` sem par mata o app dentro da conferência.
`aConferenciaSoAceitaPadraoLiteralDoProprioArquivo` compara os argumentos de
`regex(` com os `private static let … = #"` declarados no arquivo, tem sonda
própria (`literais.contains("marcaDeTempo")`, `usados.count >= 4`) para não ficar
cego, e a mensagem de falha diz o conserto. Ele fica vermelho no commit que criar
a dívida, não no relatório de crash.

## Portão e lista congelada

A lista de `faltosos` desce de **8 para 6** (descer nunca é vermelho). A medida
que qualquer um reproduz sem compilar nada:

```
$ grep -rn 'try!' Traco/ TracoWidget/ | grep -vE '^[^:]+:[0-9]+:[[:space:]]*//' | wc -l
6
```

As seis restantes estão na tabela do portão, cada uma com o julgamento e a razão.

## Suíte

`ferramentas/orca/com-trava.sh` segurada em toda corrida (build, suíte e as duas
sondas). Aparelho de trabalho: `34CC3F94-FDB5-4575-A4F5-80271829A18B`
(iPhone 17 Pro, teste 3). **Não encostei no `B91C8DEF`.**

```
$ ferramentas/orca/com-trava.sh xcodebuild -scheme Traco \
    -destination 'generic/platform=iOS Simulator' build
** BUILD SUCCEEDED **

$ ferramentas/orca/com-trava.sh xcodebuild test -scheme Traco \
    -destination 'platform=iOS Simulator,id=34CC3F94-FDB5-4575-A4F5-80271829A18B' \
    -parallel-testing-enabled NO
✔ Test run with 996 tests in 161 suites passed after 88.754 seconds.
** TEST SUCCEEDED **
```

996 = 990 de `main` + 6 novos (`AProvaDosQuatro`). Os seis, um a um:

```
✔ Test oPromptDasNotasSobreviveAoTextoMaisFeioDoAutor() passed after 0.005 seconds.
✔ Test aTentativaMaisFeiaSerializaSemPerderLinha() passed after 0.001 seconds.
✔ Test oCampoMaisFeioVoltaIdenticoDoBackup() passed after 0.001 seconds.
✔ Test aAssinaturaDaNotaAceitaOTextoMaisFeio() passed after 0.021 seconds.
✔ Test oGuardaDoJsonEOIsValidJSONObjectENaoOTry() passed after 0.001 seconds.
✔ Test aConferenciaSoAceitaPadraoLiteralDoProprioArquivo() passed after 0.003 seconds.
✔ Test run with 8 tests in 2 suites passed after 0.300 seconds.
```

**Aparelho:** o `34CC3F94` já estava ligado quando cheguei (o `simctl boot`
devolveu `Unable to boot device in current state: Booted`), então **não fui eu que
liguei e não sou eu que desligo** — "quem liga, desliga". O `B91C8DEF` continua
ligado, como manda o preâmbulo. Não instalei binário em aparelho nenhum: a volta
é motor puro e a prova é a suíte.

## Ponytail

Diff líquido pequeno e sem arquivo novo: os testes entram no arquivo do portão,
onde o julgamento já mora. Não inventei caminho de erro — a degradação vai para a
recusa que já existe. Não mexi em `Corpus` nem em `Sessao`: **a medida disse que
não há o que consertar**, e código que não precisa mudar é o diff mais curto que
existe. As duas palavras `private` que caíram (`json` virou `internal`) são o
preço de o guarda ter teste que roda, e não vale abstração nenhuma a mais.

**Dívida nomeada (§8: acabamento não segura a volta):**

- `json(_ objeto: Any)` está **duplicado** em `Analise/FonteNotas.swift` e
  `Trabalho/PraticaTrabalho.swift`, agora idêntico nos dois. Unificar cruza a
  fronteira de duas áreas (volta Q e volta E1) e não cabe aqui. Dono sugerido:
  quem mesclar as duas por último. Custo: um helper de ~6 linhas.
- O tipo `Any` continua sendo o buraco de verdade; o guarda o fecha em runtime,
  não em compilação. Fechar por tipo pede um `JSONValue`, que é abstração sem
  segundo caso hoje. Só vale se aparecer um terceiro chamador.

## Escopo — o que NÃO toquei

`Traco/Analise/Grok.swift`, `AvaliacaoIA.swift`, `Traco/Trabalho/*` além do
`PraticaTrabalho.json` e do `ConferenciaTrabalho` (revertido) — nada do trabalho
"cinco itens" do Codex no checkout principal. Nenhuma view, nenhum Tema, nenhuma
copy: volta de motor puro, `design-router` não se aplica.

## Scorecard (preenchido por mim; a nota final é do revisor)

| dimensão | nota | por quê |
|---|---:|---|
| Visão | 9 | fecha a lacuna nomeada do RUMO ("os quatro `try!` de dado externo"), e fecha com medida em vez de com conserto de fé |
| Contrato | 9 | ADR `2026-09-09o` no SPEC, letra registrada em `LETRAS-ADR.md` no mesmo ato, tabela do portão reescrita com o julgamento novo |
| Correção | 9 | 996 verdes; vermelho de cada portão demonstrado e colado; a sonda de filtro vazio (`0 de N`) declarada como limite |
| Jornada real | n/a | volta de motor puro; nenhum estado de tela mudou |
| Design | n/a | nenhuma view, token ou copy tocada |
| Simplicidade | n/a | nenhum passo, decisão ou tela do autor mudou |
| Movimento | n/a | sem animação |
| Componentes | n/a | sem componente |
| Acessibilidade | n/a | sem superfície |
| Performance | n/a | `isValidJSONObject` roda uma vez por prompt montado, ordens de grandeza abaixo da chamada de rede que o consome; sem lista, editor ou parser tocado |
| Privacidade e autoria | 9 | o texto do autor atravessa os quatro caminhos inteiro e volta idêntico, e é isso que os testes provam; nenhuma rota de acesso mudou |
| Estado honesto | 9 | o achado desconfortável (não havia o que consertar em dois dos quatro) está no relato como achado, não maquiado; o limite do `-only-testing` está declarado |
| Complexidade | 9 | zero arquivo novo, zero dependência; duas dívidas nomeadas com dono em vez de resolvidas por conta própria |
| Fora do app | n/a | nada fora do app |
| Relato | 9 | este documento, com as linhas de resultado coladas e o comando que qualquer um repete |
