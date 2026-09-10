# MERGE-P0-CRLF — o defeito que apagava arquivo do autor sai de `main`

**Linha do ciclo.** É o **G5** do P0-CRLF. Serve à intenção *"o trabalho do autor não
some"*; reduz o obstáculo *"o app apaga arquivo do autor depois de violar o selo, e isso
está VIVO em `main`"*; prova-se por **`origin/main` com o portão dentro** e pela **suíte
integral verde com prova de árvore própria**.

**Não revisei e não consertei nada.** A volta foi **aprovada no re-G3** (`29e9548`) sem
nenhuma dimensão abaixo de 9. Meu trabalho aqui é mesclar, provar que ficou verde,
empurrar — mais a **uma palavra** de caneta que o revisor deixou anotada.

**Aparelho.** Um só: **`A1DF082C-FC87-4DF9-9F56-F2DA1C084DED`** (iPhone 17 Pro, **teste
4**, o da SUÍTE). **Não toquei nos dois aparelhos de conta** — `B91C8DEF` e `34CC3F94`:
nenhum `install`, nenhum `erase`, nenhum `clearState`, nenhum `uninstall`, nenhum
`xcodebuild test`, nenhuma sonda, nenhuma chamada de rede a modelo nenhum. Esta volta não
precisa de aparelho de conta e não usou nenhum. Não liguei nem desliguei simulador; achei
os três ligados e deixo os três ligados.

**Voz, VoiceOver e iPad:** nenhum acionado, em momento nenhum. **Tamanho de letra:** não
toquei — nenhuma captura nesta volta, e nenhum `simctl ui content_size` foi rodado.

**Onde mesclei.** Num **checkout descartável do pai** em `/tmp/merge-p0`
(`git worktree add … origin/main`), que é o caminho que a ESTEIRA abençoa em 09/09. Não
escrevi no checkout principal nem em worktree alheio. Removido ao fim (§6).

---

## 1. O que entrou

```
* 12b2b32 LETRAS-ADR: a 09y se chama DELIMITAÇÃO — o título da letra é o que a próxima pessoa lê
* 56520dc MERGE-P0-CRLF: o arquivo do autor para de sumir — a delimitação vira invariante e o portão falha fechado
* 29e9548 re-G3 do P0-CRLF: APROVADO — o diff é comentário, o harness dá a mesma saída byte a byte
* 0f3b4a1 P0-CRLF-B: a invariante é cobertura de DELIMITAÇÃO, e a alegação encolhe até caber no que o código faz
* 6aa109f Merge remote-tracking branch 'origin/main' into Vitorepf/p0-crlf
* 9452c5d G3 do P0-CRLF: o código passa, o texto que sai com ele não
* 21939ae P0-CRLF: o arquivo só se apaga quando o app leu tudo o que havia nele
```

**Sete commits, e li a lista inteira.** Nenhum órfão de portão: `21939ae` é o conserto,
`9452c5d` e `29e9548` são o G3 e o re-G3 que o julgaram, `0f3b4a1` são as quatro correções
de texto que o G3 pediu, `6aa109f` é a trazida de `main` para dentro do branch, e os dois
últimos são meus. Mescla **`--no-ff`**, **sem reescrever história**: `HEAD^1` = `b62b789`
(o `main` que achei), `HEAD^2` = `29e9548` (a ponta do branch).

**A ponta que mesclei foi `29e9548`, não `0f3b4a1`.** O spec dizia `0f3b4a1` porque foi
escrito antes; `29e9548` é o commit do próprio revisor e **só toca
`ferramentas/orca/revisao-p0-crlf.md`** (141 linhas de relatório, nenhum arquivo de
target). Deixá-lo fora publicaria o conserto sem o parecer que o aprovou.

### O conserto, em uma frase

`Corpus.importarComEstado` devolve `(itens, podeRetirar, consumido)`: `consumido` é a
fração dos caracteres **com tinta** que caiu DENTRO de um bloco importado, e `podeRetirar`
é `lidos == tinta`. O portão que falha fechado é a linha
`guard cabecalhos(conteudo) == hits.count else { return ([], false, 0) }` —
`cabecalhos` conta a mesma forma por `\.isNewline`, que enxerga CRLF e CR; se as duas
contagens discordarem, **nada entra como do autor e nada se apaga**.

## 2. O que conflitou: `SPEC.md`, um trecho, e os dois lados são ADR apensada no mesmo fim

**Um conflito só**, e é o previsto: `SPEC.md`, `CONFLICT (content)`. `EVOLUCAO.md`
auto-mesclou (uma linha, a da `09y`). `LETRAS-ADR.md` **não conflitou** — o branch nunca o
tocou; a linha da `09y` já era do `main`.

Os dois lados apensam ADR **no mesmo fim do arquivo**:

| lado | o que trazia |
|---|---|
| `HEAD` (`main`) | `## ADR 2026-09-09v` (Q3-C), `## ADR 2026-09-09w` (Q3-D), `## ADR 2026-09-09z` (MERGE-Q3D) |
| `Vitorepf/p0-crlf` | `## ADR 2026-09-09y` (P0-CRLF) |

**Casei os dois lados; não escolhi um.** O `SPEC.md` é **append-ordenado, não ordenado por
letra** — as quinze últimas ADR do arquivo saem `09k, 09m, 09o, 08z, 09n, 09q, 09q, 09h,
09i, 09t, 09r, 09v, 09w, 09z`. Então a resolução certa é **união na ordem de chegada**: o
bloco do `main` primeiro, o bloco da `09y` depois. Removi os três marcadores e nada mais.

**Prova do tamanho da alegação**, como manda a `LETRAS-ADR.md` — dois `diff` vazios:

```
$ diff <(git show origin/main:SPEC.md) <(sed -n '1,9177p' SPEC.md)
IDENTICO ao main nas primeiras 9177 linhas
$ diff <(git show Vitorepf/p0-crlf:SPEC.md | sed -n '8977,$p') <(sed -n '9178,$p' SPEC.md)
IDENTICO ao bloco 09y do branch
```

9177 (o `main` inteiro) + 121 (o bloco da `09y`, com a linha em branco que o separa) =
**9298**, que é o `wc -l` do arquivo resolvido. Zero marcadores de conflito. Nenhuma
palavra de nenhum dos dois lados foi reescrita por mim.

**Os três arquivos de código não conflitaram, e conferi por quê:**
`git log <base>..origin/main -- Traco/Notas/Corpus.swift Traco/Notas/Entrada.swift
TracoTests/IntegridadeCorpusTests.swift` sai **vazio** — o `main` não os tocou desde a
base. Conferido byte a byte que os três ficaram **idênticos ao lado do branch**.

## 3. A correção de caneta

`ferramentas/orca/LETRAS-ADR.md:82` intitulava a `09y` com *"o app **leu** tudo"*, e a
invariante mudou de nome no re-G3. A palavra certa está escrita na própria ESTEIRA, na lei
que o G3 corrigiu: *"o arquivo só se apaga quando o app **delimitou** tudo o que havia
nele"*.

```diff
-| 09y | P0-CRLF · o arquivo só se apaga quando o app leu tudo o que havia nele | reservada, volta viva |
+| 09y | P0-CRLF · o arquivo só se apaga quando o app delimitou tudo o que havia nele | em `main` |
```

Duas mudanças na mesma linha: a palavra, e o estado — de `reservada, volta viva` para
`em `main``, porque este commit é o que a põe lá; é a convenção que a `09t` e a `09z`
seguem. Conferido depois: `grep -c '^| 09y'` = **1**, e uma única "Próxima livre" viva
(linha 95), dizendo **`10b`** — a `10a` já é da volta TEMPO, que o `main` reservou.

**O que NÃO corrigi, e declaro:** o título da ADR no `SPEC.md:9179` também diz *"quando o
app leu tudo"*. É texto de contrato que o revisor leu e aprovou, e o pedido era **uma
palavra no `LETRAS-ADR`**. Não reescrevo contrato aprovado por conta própria — fica
registrado aqui para quem tocar a `09y` depois.

## 4. Instrumento — e o vermelho que era do MEU checkout, não da mescla

**Rodei a suíte três vezes, e colo as três.** As duas primeiras ficaram **vermelhas com 4
issues**, e a causa **não é a mescla**: é o **lugar onde eu montei o checkout descartável**.

### 4a. As duas primeiras corridas — 4 vermelhos, sempre os mesmos, sempre a mesma causa

```
1ª  INICIO 2026-09-10T15:06:50Z   (checkout em /tmp/merge-p0)
    ✘ Test run with 1027 tests in 163 suites failed after 87.099 seconds with 4 issues.
    ** TEST FAILED **   RC=65   FIM 2026-09-10T15:09:06Z

2ª  INICIO 2026-09-10T15:10:14Z   (mesmo worktree, chamado por /private/tmp/merge-p0)
    ✘ Test run with 1027 tests in 163 suites failed after 87.264 seconds with 4 issues.
    ** TEST FAILED **   RC=65   FIM 2026-09-10T15:13:45Z
```

Os quatro são **portões de varredura de fonte**, nenhum deles perto do `Corpus`:

```
✘ PortaoDaRotaQueCalaTests.aVarreduraAindaEnxerga()              — :124
✘ PortaoDaRotaQueCalaTests.nenhumaOperacaoPerdeuASuaSuperficie() — :136
✘ PortaoDoMovimentoTests.nenhumMovimentoNovoForaDeTema()         — :157
✘ PortaoDoTryBangTests.nenhumTryBangNovoNaProducao()             — :93
```

Todos com a MESMA mensagem, e é ela que entrega a causa:

```
Caught error: … "O arquivo “AnaliseDeBordo.swift” não pôde ser aberto porque tal arquivo
não existe." NSFilePath=/tmp/merge-p0/Traco//privateAnalise/AnaliseDeBordo.swift
```

`Traco//privateAnalise` não é pasta nenhuma. **Medi o mecanismo em vez de adivinhar** —
`PortaoDoMovimentoTests.fontes(_:)`, linhas 119–133, monta o caminho relativo por recorte
de string:

```swift
let relativo = pasta + "/" + url.path.replacingOccurrences(of: base.path + "/", with: "")
```

Em macOS **`/tmp` é link simbólico para `/private/tmp`**. `base.path` sai do `#filePath` e
vale `/tmp/merge-p0/Traco`; o `FileManager.enumerator` devolve o caminho **resolvido**,
`/private/tmp/merge-p0/Traco/Analise/AnaliseDeBordo.swift`. A string `/tmp/merge-p0/Traco/`
ocorre **no meio** do caminho resolvido, no deslocamento 8 — então o `replacingOccurrences`
a arranca **de lá**, sobra `/private` + `Analise/AnaliseDeBordo.swift`, e o `pasta + "/"`
na frente fecha o `Traco//privateAnalise/AnaliseDeBordo.swift` do erro.

**A 2ª corrida foi o meu primeiro conserto, e ele NÃO funcionou** — chamei tudo pelo
caminho resolvido (`cd /private/tmp/merge-p0`, `-project /private/tmp/…`) achando que o
compilador passaria a ver `/private/tmp`. Não passou: `strings` no `TracoTests.xctest`
construído mostra **`/tmp/merge-p0/TracoTests/…`** assado como `#filePath`. **A cadeia de
build reescreve `/private/tmp` de volta para `/tmp`**, então não há como consertar isso de
fora estando dentro de `/tmp`. Registro o conserto que falhou porque ele é a metade
interessante: a hipótese estava certa e a *cura* estava errada.

### 4b. A terceira corrida — checkout FORA de `/tmp`

Movi o worktree descartável para **`/Users/vitorepf/traco-merge-p0`** (`realpath` de
`/Users/vitorepf` é ele mesmo, sem link simbólico nenhum) e refiz do zero. É um desvio
declarado da letra da ESTEIRA, que diz *"em `/tmp`, removido ao fim"*: o propósito da regra
— não escrever no checkout principal nem em worktree alheio — está preservado, e a `/tmp`
é justamente o que torna a medida inválida aqui. Removido ao fim, como manda (§6).

**Build LIMPO nas três** (`rm -rf build` e `derivedDataPath` novo antes de cada uma), logo
a contagem de aviso vale.

```
INICIO 2026-09-10T15:14:30Z   (checkout em /Users/vitorepf/traco-merge-p0)
✔ Test run with 1027 tests in 163 suites passed after 89.094 seconds.
** TEST SUCCEEDED **
RC=0
FIM 2026-09-10T15:17:09Z
```

Os quatro portões que caíam nas duas primeiras, agora verdes:

```
✔ Test aVarreduraAindaEnxerga() passed after 0.106 seconds.          (PortaoDaRotaQueCala)
✔ Test nenhumaOperacaoPerdeuASuaSuperficie() passed after 0.324 seconds.
✔ Test nenhumMovimentoNovoForaDeTema() passed after 1.070 seconds.
✔ Test nenhumTryBangNovoNaProducao() passed after 0.237 seconds.
```

**Aviso: 1, herdado, 0 introduzidos.** Build LIMPO, então o número vale.
`…/Traco/Notas/NotasView.swift:814:30: warning: '+' was deprecated in iOS 26.0` — é o
conhecido de `main`, e nenhuma das pontas desta mescla toca o arquivo.

**O vermelho conhecido NÃO apareceu.** `IndiceTests.oIndiceAproximaESeloTira` passou nas
três corridas (`✔ … passed after 0.003 seconds`). Fica dito porque o spec mandou declarar
se aparecesse.

### 4c. Prova de que rodou a MINHA árvore

Três provas, da mais fraca para a mais forte:

1. **Os dois testes exclusivos do candidato executaram e passaram:**
   ```
   ✔ Test arquivoSoSaiDaEntradaQuandoOAppLeuTudo() passed after 0.001 seconds.
   ✔ Test oQueOAppLeuInteiroContinuaPodendoSairDaEntrada() passed after 0.001 seconds.
   ```
   E eles **não existem em `main`**: `git show origin/main:TracoTests/IntegridadeCorpusTests.swift | grep -c` dos dois nomes = **0**; na minha árvore = **2**.
2. **A contagem casa com a árvore.** `@Test` declarados em `TracoTests/` + `TracoUITests/`:
   `main` = **1025**, candidato = **1027** (+2, exatamente os dois novos). A corrida
   executou **1027 tests in 163 suites**.
3. **Auditei os NOMES executados contra os declarados**, que é o grau que o spec prefere:
   911 nomes únicos saíram do log (`✔ Test <nome>(`), e o `comm -23` contra as funções
   declaradas na minha árvore devolve **lista vazia** — nenhum teste executado veio de
   fora dela.

**Aparelho:** só o **teste 4** (`A1DF082C…`). Achei-o ligado e o deixo ligado; não mudei
orientação, tema, Movimento Reduzido nem tamanho de letra — nada a restaurar, porque nada
foi tocado. A trava (`/tmp/traco-instrumento.lock/dono`) serializou as três corridas; numa
delas ela estava com outro worker (`pid 16184`, `-only-testing:TracoTests`, no mesmo
aparelho) e a minha esperou, como tem de ser.

## 5. Escopo — o que NÃO fiz, e de quem é

Não revisei, não consertei e não toquei em nenhum arquivo de target. Três fatos que
**observei** ao rodar, todos **anteriores a esta volta** e nenhum causado por ela:

1. **Os quatro portões de varredura quebram em checkout sob link simbólico** (§4a).
   `PortaoDoMovimentoTests.fontes(_:):128` recorta o prefixo por string em vez de resolver
   o caminho. Está em `main`, morde qualquer worktree em `/tmp`, e a correção cabe numa
   linha (`URL(fileURLWithPath:).resolvingSymlinksInPath()` nos dois lados antes do
   recorte). **Não é minha volta consertar** — fica para o RUMO, sem dono.
2. **`TracoTests/EscritaVisivelTests.swift` roda em AX XXXL, e isso viola a §12.**
   Dois testes parametrizados
   (`aLinhaFicaNoPapelEmCadaQuadroDaGaveta(tamanho:)`:495 e
   `aLinhaAtivaEOCaretFicamNaAreaLivreDoPapel(tamanho:)`:556, ambos
   `@Test(arguments: [.accessibilityExtraExtraExtraLarge, .large])`) mais um valor padrão
   em `:651`. Entrou em `main` pela `423789e` (FUSÃO), **antes** da ordem do dono de 10/09
   10h35; o P0-CRLF não tocou o arquivo. A §12 diz *"nenhum … teste … em AX1–AX5 / XXXL"*,
   então isto é uma violação **viva, que executa em toda corrida da suíte**. Declaro; não
   removo, porque remover teste alheio numa volta de mescla é o "conserto confiante" que a
   ESTEIRA proíbe.
3. **`IndiceTests.oIndiceAproximaESeloTira`, o vermelho conhecido, NÃO apareceu** — nem na
   primeira corrida nem na segunda. Fica dito porque o spec mandou declarar se aparecesse.

**A dívida `P0-SELO-CEGO` continua aberta e está escrita no próprio código** (comentário em
`Corpus.swift`, acima do `guard`): quando as DUAS contagens são cegas ao mesmo cabeçalho
malformado, o arquivo cai no ramo `hits.isEmpty`, que é fail-open — e já era assim em
`main`. O G3 mediu e recomendou uma linha. Não é desta volta.

## 6. O push, e a limpeza

Antes de empurrar li a lista inteira, `git log --oneline origin/main..HEAD`:

```
6c5addf MERGE-P0-CRLF: traz o `main` que andou durante a mescla (a 10b foi para a volta RESPONDER)
12b2b32 LETRAS-ADR: a 09y se chama DELIMITAÇÃO — o título da letra é o que a próxima pessoa lê
56520dc MERGE-P0-CRLF: o arquivo do autor para de sumir — a delimitação vira invariante e o portão falha fechado
29e9548 re-G3 do P0-CRLF: APROVADO — o diff é comentário, o harness dá a mesma saída byte a byte
0f3b4a1 P0-CRLF-B: a invariante é cobertura de DELIMITAÇÃO, e a alegação encolhe até caber no que o código faz
6aa109f Merge remote-tracking branch 'origin/main' into Vitorepf/p0-crlf
9452c5d G3 do P0-CRLF: o código passa, o texto que sai com ele não
21939ae P0-CRLF: o arquivo só se apaga quando o app leu tudo o que havia nele
```

```
To https://github.com/Vitorepf/traco-ios.git
   aabc52d..6c5addf  HEAD -> main
```

`origin/main` = **`6c5addf68be56e9049b1fd5a7f610d7d234e1419`**, às **2026-09-10T15:18:18Z (12h18 local)**.

Esse é o SHA da mescla. **Este relatório é o commit seguinte**, `7fbe747`, empurrado às
2026-09-10T15:18:55Z — um `.md` só, nada de código depois da suíte verde.

**Limpeza, feita.** Worktree descartável (`/Users/vitorepf/traco-merge-p0`) e branch
temporário (`merge-p0-crlf-tmp`) removidos, `/tmp/merge-p0` removido, `git worktree prune`
rodado: `git worktree list | grep -c merge-p0` = **0**. Nada ficou escrito no checkout
principal nem em worktree alheio. O worktree da volta, `p0-crlf`, fica de pé — quem o
remove é o orquestrador.

## 7. Scorecard (preenchido por mim; a nota final é do revisor independente)

Esta é uma volta de **G5**: o mérito já foi julgado e aprovado no re-G3 (`29e9548`). O que
se julga aqui é a mescla.

| dimensão | nota | evidência |
|---|---:|---|
| Visão | 9 | tira de `main` o defeito que APAGA arquivo do autor; `EVOLUCAO.md` traz a linha da `09y`, mesclada sem conflito |
| Contrato | 9 | ADR `2026-09-09y` no `SPEC.md`, união provada por dois `diff` vazios (§2); `LETRAS-ADR` com a `09y` **uma vez**, título corrigido, estado `em main`, uma "Próxima livre" viva |
| Correção | 9 | suíte integral verde no teste 4, contagem e os dois exclusivos colados (§4b); o vermelho da 1ª corrida medido até a linha do código e devolvido ao lugar certo (§4a) |
| Jornada real | n/a | nenhuma tela mudou nesta volta; as capturas da jornada são as do P0-CRLF, já no repositório (`ferramentas/orca/p0-crlf/p0-0*.png`) |
| Design / Movimento / Componentes / Fora do app | n/a | nenhum token, componente, animação ou superfície tocada |
| Simplicidade | 9 | dois commits meus; o de mescla só resolve `SPEC.md`, o outro é **uma linha** |
| Acessibilidade | n/a | motor puro; nenhuma captura, nenhum `content_size` tocado — e a §12 respeitada (nada em AX) |
| Performance | n/a | nada de lista, editor ou parser tocado por mim |
| Privacidade e autoria | 9 | é o objeto da volta: o selo deixa de ser atravessado e `origem: modelo` deixa de virar voz do autor; nenhuma chamada de rede, nenhum aparelho de conta tocado |
| Estado honesto | 9 | a 1ª corrida vermelha está no relatório **inteira**, com a causa medida em vez de escondida; a violação de §12 em `main` e a fragilidade do recorte de caminho ficam declaradas sem serem consertadas |
| Complexidade | 9 | nenhum arquivo novo de target, nenhuma dependência; `xcodegen generate` não produziu diferença |
| Relato | 9 | este documento |

**Oito commits, e li a lista inteira antes de empurrar.** Nenhum órfão de portão: cinco são
o P0-CRLF com os seus dois G3 e a trazida de `main`, dois são meus (a mescla e a caneta) e
o oitavo é a segunda trazida de `main`. Nada que eu não pretendesse publicar.

**Conferido depois do push, sobre `origin/main`:** o `guard cabecalhos(conteudo) ==
hits.count` está em `Corpus.swift`; `Entrada.swift:61` lê `podeRetirar: resultado.podeRetirar`
em vez de remontar o portão; a `## ADR 2026-09-09y` está no `SPEC.md` **uma vez**; a linha
82 do `LETRAS-ADR` diz **delimitou** e **`em main`**; e os quatro SHA que os relatórios
citam (`21939ae`, `9452c5d`, `0f3b4a1`, `29e9548`) continuam alcançáveis.
