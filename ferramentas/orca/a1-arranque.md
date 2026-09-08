# Volta A1 — o arranque honesto: o Traço que não abre tem de dizer, não morrer

Implementador: Claude Opus 5. Simulador: **iPhone 17 Pro Max `6033B043-F436-41F9-B4F8-2D9E67761980`**.
ADR: **2026-09-08s**. Branch: `Vitorepf/volta-a1-arranque`, sem mesclar.

Declaro: toda sessão de `orca emulator` e todo `xcodebuild` passaram por
`ferramentas/orca/com-trava.sh` — **segurei a trava**. Nenhum mouse ou teclado
do Mac foi tocado. O simulador do Grok (`C2416CBC`) não foi tocado; nem o
`34CC3F94`, nem o `64F7B8B4`. Nenhum maestro nesta volta.

## G0 — a linha da volta

**Ciclo:** multiplicar (sem arranque não há nada) **e** eixo 4 (menos risco).
**Intenção:** o autor abre o Traço e, se algo estiver errado, entende o que houve
e não perde o que escreveu.
**Obstáculo:** `TracoApp.swift:13` fazia `try! DiscoTraco.abrir(emTeste:)`.
**Critério do dono (item 8):** falhas previsíveis permitem recuperação e
preservam o conteúdo.

## O que eu achei ao ler antes de tocar — e mudou a volta

O `try!` era o menor dos dois defeitos, e é preciso dizer isto com clareza.
`DiscoTraco.abrir` em `main` **já não morria**: quando o disco recusava, ela
punha `aviso` e devolvia um contentor **em memória**. O app inteiro subia sobre
um caderno vazio, com uma frase de aviso por cima.

Só que `Corpus.escrever` (`Traco/Notas/Corpus.swift`, a varredura do selo)
**apaga do espelho em Arquivos todo `.md` que não estiver na lista que recebe**,
e a lista vem do contexto. Selar, queimar, apagar ou importar com o caderno
vazio da RAM na mão apagaria o backup sem nuvem — **o estrago que o defeito
ainda não tinha feito.** A radiografia de 02/09 (tag
`arquivo/fix-furos-radiografia`, commit `d4c6b4d`) tinha visto exatamente isso e
resolvido com uma bandeira que o `Corpus` lia; `main` reimplementou o aviso por
outro caminho e **perdeu a guarda**.

A saída mais curta que resolve os dois de uma vez, e sem invadir área de volta
viva: **não abrir nada no lugar.** Sem container não há `RaizView`; sem
`RaizView` nenhuma rota do selo existe; o espelho não é tocado por construção,
sem bandeira nova, sem tocar em `Traco/Notas/**`.

## O contrato, item por item

**1. O arranque deixa de ser `try!`.** `DiscoTraco.abrir` devolve
`.aberto(ModelContainer)` ou `.recusou(Error)`. `TracoApp` guarda isso em
`@State` e a `Scene` escolhe entre `RaizView` e `ArranqueFalhouView`.
`Ferias.expirarSePassou`, `Revisoes.agendarFilaDiaria`,
`Revisoes.agendarRevisaoSemanal` e as reconciliações da Ilha saíram do `init`
para `aoAbrir()` e **só correm com caderno de verdade** — reagendar a partir de
um mundo vazio calaria o que está de pé lá fora.

**2. Nada de apagar para "consertar".** O único ato oferecido é **tentar abrir
de novo**. Não há limpar, recriar nem migrar. A tela não promete conserto: se a
segunda tentativa recusa, ela diz que recusou.

**3. O portão do `try!`** — `TracoTests/PortaoDoTryBangTests.swift`, irmão do
portão do movimento (ADR 08e) e reusando a varredura dele (`codigoVisivel`, que
apaga comentário e string antes de contar).

**4. A lista congelada, MEDIDA e com julgamento caso a caso.**
O `grep` cru **não serve de prova** — hoje ele conta **10** neste branch, porque
esta volta escreveu duas linhas de comentário que dizem `try!`. A conta que vale
é a de `try!` em CÓDIGO, e este comando a reproduz em qualquer checkout:

```
grep -rn 'try!' Traco/ TracoWidget/ | grep -vE '^[^:]+:[0-9]+:[[:space:]]*//'
```

**9 em `main`, 8 aqui** — as duas saídas estão coladas na seção "A medida do
`try!`, refeita nas duas árvores", abaixo. O portão não usa esse filtro de uma
linha: usa `codigoVisivel`, que apaga comentário **e** string antes de contar, e
chega ao mesmo 8; o filtro acima é a versão que qualquer um roda sem compilar
nada.

| arquivo:linha | julgamento |
|---|---|
| `Traco/TracoApp.swift:13` | **CONSERTADO nesta volta** (era a morte no arranque) |
| `Traco/Caderno/AnexoDisco.swift:48` | infalível por construção — `NSRegularExpression` de padrão literal |
| `Traco/Notas/Indice.swift:96` | infalível por construção — idem |
| `Traco/Notas/Corpus.swift:277` | infalível por construção — idem |
| `Traco/Trabalho/ConferenciaTrabalho.swift:179` | infalível **só enquanto todo chamador passar literal**: o padrão chega por argumento. É o que fura primeiro. Volta E1, viva |
| `Traco/Analise/FonteNotas.swift:155` | **dívida real** — `JSONSerialization.data` sobre objeto montado em runtime. Volta Q, viva |
| `Traco/Trabalho/PraticaTrabalho.swift:529` | **dívida real** — idem. Volta E1, viva |
| `Traco/Notas/Corpus.swift:144` | **dívida real** — `encode` de campo do autor, com um `!` de dicionário na mesma linha |
| `Traco/App/Sessao.swift:599` | **dívida real** — `encode` do texto do autor |

As quatro dívidas reais foram ao RUMO ("Dívida vinda dos portões de hoje").
**Nenhuma se conserta aqui**: `Analise` é da volta Q e `Trabalho` é da E1, as
duas vivas em 08/09 — invadir área alheia é falha, não zelo.

## Provas

### O portão: verde no repositório de hoje

```
✔ Test aVarreduraAindaEnxerga() passed after 0.001 seconds.
✔ Test nenhumTryBangNovoNaProducao() passed after 0.240 seconds.
✔ Suite PortaoDoTryBangTests passed after 0.240 seconds.
```

### O portão: VERMELHO com um `try!` plantado

Plantado `static var plantado: NSRegularExpression { try! NSRegularExpression(pattern: "x") }`
em `Traco/App/TituloTela.swift`, e removido em seguida (`git diff` limpo):

```
✘ Test nenhumTryBangNovoNaProducao() recorded an issue at PortaoDoTryBangTests.swift:111:9: Expectation failed: (divergencias → ["Traco/App/TituloTela.swift: 1 hoje, 0 congelado  ← SUBIU"]).isEmpty → false
  Traco/App/TituloTela.swift: 1 hoje, 0 congelado  ← SUBIU
```

### A medida do `try!`, refeita nas duas árvores

Conferida no fecho da volta (A1-D, 08/09), não herdada do texto. `main` estava
em `b4559f5`; o candidato, em `8f2c671` + o diff desta passada. A árvore de
`main` foi extraída por `git archive main Traco TracoWidget` para um diretório
temporário — o checkout principal está sendo editado por outra sessão e não se
toca.

**`main` (`b4559f5`) — 9, e o `grep` cru também dá 9:**

```
Traco/TracoApp.swift:13:        container = try! DiscoTraco.abrir(emTeste: emTeste)
Traco/Analise/FonteNotas.swift:155:        String(data: try! JSONSerialization.data(withJSONObject: objeto, options: [.sortedKeys]), encoding: .utf8)!
Traco/App/Sessao.swift:599:        let dados = try! JSONEncoder().encode([nota.texto, nota.camposJSON, nota.sentido,
Traco/Caderno/AnexoDisco.swift:48:        let rx = try! NSRegularExpression(pattern: #"traco://[a-z]+/([0-9A-Fa-f-]{36})"#)
Traco/Trabalho/ConferenciaTrabalho.swift:179:    private static func regex(_ padrao: String) -> Regex<AnyRegexOutput> { try! Regex("(?i)" + padrao) }
Traco/Trabalho/PraticaTrabalho.swift:547:        String(data: try! JSONSerialization.data(withJSONObject: objeto, options: [.sortedKeys]), encoding: .utf8)!
Traco/Notas/Corpus.swift:144:                let valor = String(decoding: try! JSONEncoder().encode(f.campos[id]!), as: UTF8.self)
Traco/Notas/Corpus.swift:277:        let padrao = try! NSRegularExpression(
Traco/Notas/Indice.swift:96:    nonisolated static let marcadorPDF = try! NSRegularExpression(
```

**Candidato (branch da A1) — 8, com o `grep` cru em 10:**

```
Traco/Analise/FonteNotas.swift:155:        String(data: try! JSONSerialization.data(withJSONObject: objeto, options: [.sortedKeys]), encoding: .utf8)!
Traco/App/Sessao.swift:599:        let dados = try! JSONEncoder().encode([nota.texto, nota.camposJSON, nota.sentido,
Traco/Caderno/AnexoDisco.swift:48:        let rx = try! NSRegularExpression(pattern: #"traco://[a-z]+/([0-9A-Fa-f-]{36})"#)
Traco/Trabalho/ConferenciaTrabalho.swift:179:    private static func regex(_ padrao: String) -> Regex<AnyRegexOutput> { try! Regex("(?i)" + padrao) }
Traco/Trabalho/PraticaTrabalho.swift:529:        String(data: try! JSONSerialization.data(withJSONObject: objeto, options: [.sortedKeys]), encoding: .utf8)!
Traco/Notas/Corpus.swift:144:                let valor = String(decoding: try! JSONEncoder().encode(f.campos[id]!), as: UTF8.self)
Traco/Notas/Corpus.swift:277:        let padrao = try! NSRegularExpression(
Traco/Notas/Indice.swift:96:    nonisolated static let marcadorPDF = try! NSRegularExpression(
```

A diferença entre as duas listas é **uma linha e só uma**: `TracoApp.swift:13`,
que era o arranque. As 8 do candidato são exatamente as da tabela congelada
acima, e o portão (por `codigoVisivel`) chega ao mesmo 8.

**Uma divergência de número de linha, dita porque `main` andou hoje:**
`PraticaTrabalho.swift` está em **:529** neste branch e em **:547** no `main` de
`b4559f5` — a volta E1 mexeu no arquivo depois que este branch saiu. O `try!` é
o mesmo e a lista continua com os mesmos 8 alvos; quem mesclar deve reler essa
linha da tabela (aqui, no RUMO e no doc do portão) contra o `main` do momento da
mescla. Nada disso muda a contagem.

### Suíte integral e build

```
** BUILD SUCCEEDED **
✔ Test run with 934 tests in 152 suites passed after 74.006 seconds.
```

`ferramentas/orca/com-trava.sh xcodebuild test -scheme Traco -destination
'id=6033B043-F436-41F9-B4F8-2D9E67761980' -parallel-testing-enabled NO`.
Zero `warning:` no log (`grep -c warning: → 0`).

**Repetida na ÁRVORE FINAL** (A1-D, 08/09, com as correções do revisor já
escritas, mesmo comando, mesmo `6033B043`, que foi ligado para isto e desligado
ao fim):

```
✔ Test run with 934 tests in 152 suites passed after 55.699 seconds.
** TEST SUCCEEDED **
```

`grep -c warning: → 0` também neste log. É a árvore que vai ao commit, não uma
anterior.

### A tela, com o banco de VERDADE impedido de abrir

Não é mock. O `default.store` do App Group
(`.../Shared/AppGroup/…/Library/Application Support/default.store`) foi copiado
para `/tmp/a1-store-guardado/` e **trocado por um diretório de mesmo nome**. O
arranque recebeu erro real:
`SwiftDataError(_error: SwiftData.SwiftDataError._Error.loadIssueModelContainer, _explanation: nil)`.

| captura | o que mostra |
|---|---|
| `a1-01-escrito.png` | o antes: a nota escrita no app, antes de qualquer sabotagem |
| `a1-02-falha-large.png` | a tela honesta em `large` (o `content_size` do aparelho era `large`, conferido por `simctl ui`) |
| `a1-03-recusou-de-novo.png` | depois de tocar "Tentar abrir de novo": a segunda recusa dita, sem promessa |
| `a1-04-falha-AX5.png` | AX5 (`accessibility-extra-extra-extra-large`), topo |
| `a1-05-falha-AX5-rolado.png` | AX5 rolado: a ação e o detalhe cabem, nada cortado |
| `a1-06-recuperado.png` | o `default.store` restaurado, o app abre normal |
| `a1-07-nota-viva.png` | a nota intacta na lista: "A prova de que nada se perdeu no arranque falho." |

Texto na tela (`a1-02`): título "O Traço não abriu o seu caderno."; o que houve
("O arquivo onde as suas notas ficam neste aparelho não respondeu. Nada foi
apagado: o Traço parou aqui em vez de abrir um caderno vazio por cima do seu.");
onde está ("**1 nota** está em Markdown no app Arquivos, na pasta Traço. O
arquivo original continua neste aparelho, intacto."); o ato ("Tentar abrir de
novo"); e o detalhe técnico em miúdo, no fim, para quem for pedir ajuda.

A linha do meio é **medida, não prometida**: conta os `.md` que estão no espelho
naquele instante. Sem nenhum, ela diz que não encontrou cópia — inventar um
backup seria pior que não ter um.

### Alvo de 44 pt

Árvore de AX do `6033B043`, **conferida contra a captura `simctl io` do mesmo
UDID no mesmo instante** (mesmos textos, mesmo relógio 18:54 — a lei do
`ax --device` que lê o vizinho):

```
button | Tentar abrir de novo | {'x': 0.0455, 'y': 0.3877, 'width': 0.9091, 'height': 0.046}
```

0,046 × 956 pt (altura do iPhone 17 Pro Max) = **43,98 pt**. Em AX5 o mesmo
botão mede 0,1311 × 956 = 125 pt.

### Prova de que nada se perdeu

Antes: 1 `.md` em `Documents/notas/`, `traco-corpus.md` com 2.303 bytes.
Depois de **três arranques falhos e um "tentar de novo" recusado**:

```
.rw-r--r-- 187 vitorepf  8 Sep 18:52 08dcde59-4190-48e3-acd0-b4c956b8402a.md
    2303 .../Documents/traco-corpus.md
```

Byte por byte igual. Restaurado o `default.store`, a nota reapareceu na lista
(`a1-07-nota-viva.png`), com domínio ESTUDO e sob HOJE.

### O pior caso da frase do meio: o espelho VAZIO, fotografado

A frase do meio conta os `.md` que estão no espelho **naquele instante**. O
estado que mais podia assustar ou mentir é o de zero — e ele foi exercitado no
aparelho, não no preview.

**Como o estado foi plantado** (`6033B043`, 08/09 às 19:17–19:26):

1. O espelho inteiro saiu do contêiner do app para fora do alcance do processo —
   `Documents/notas/*.md` e `Documents/traco-corpus.md` movidos para
   `/tmp/a1b-guardado/` (dois `.md` de nota, 261 e 173 bytes, e o corpus de
   2,4 kB). `Documents/notas/` ficou existente e **vazio**, que é o caso da
   frase, e não o caso de pasta ausente.
2. O `default.store` do App Group
   (`.../AppGroup/1B1F9212-…/Library/Application Support/`) saiu para
   `/tmp/a1b-guardado/store/` e foi **trocado por um diretório de mesmo nome** —
   a mesma sabotagem da passada anterior, que produz o erro real
   `SwiftDataError(…loadIssueModelContainer…)`, e não um erro simulado.
3. App relançado. Captura `xcrun simctl io 6033B043-… screenshot` às **19:26**,
   guardada como `ferramentas/orca/a1-08-espelho-vazio.png`
   (SHA-256 `80668d06695ca7ff…`).

**A frase que a tela mostrou**, conferida abrindo a captura, palavra por
palavra:

> Não encontrei cópia em Markdown no app Arquivos. O arquivo original continua
> neste aparelho, intacto — o Traço não o toca enquanto não conseguir lê-lo.

Com o título "O Traço não abriu o seu caderno.", o parágrafo do que houve, a
ação "Tentar abrir de novo" em âmbar e o detalhe técnico
`SwiftDataError(_error: SwiftData.SwiftDataError._Error.loadIssueModelContainer,
_explanation: nil)` em miúdo no fim. **Nenhuma contagem falsa e nenhum backup
inventado**: com zero `.md` a tela diz que não encontrou cópia, e mesmo assim
não deixa a pessoa achar que o original se perdeu.

**Os `.md` voltaram byte a byte.** SHA-256 dos três arquivos ao sair (19:17) e
depois de restaurados no espelho do aparelho:

```
31c8df5e02f7f18cc911f8b59a51704b21d1354efd5328ad9dc70ea9974f9867  traco-corpus.md
735b07435baf62d60993a93eb9e5b9429a705f4e03751801fef0a05f894a9549  notas/3bfca0b4-2a55-41f4-88e4-426bf2e41ce8.md
54c62bbd99d9206eef8869db7747511cf3ae78172f157b5f077f8d4c07b1c2b8  notas/f4474b30-2376-47ec-aa97-27cab47e19eb.md
```

As duas listas são **idênticas** — o mesmo comando nas duas pontas, `diff` vazio.
Conferido de novo em 08/09 no fecho da volta (A1-D), com o `default.store` já
de volta ao lugar como arquivo e os três `.md` de volta em
`Documents/`.

**Onde essa evidência está agora, dito para ninguém procurar em vão:** a
conferência foi feita **antes** da suíte integral do fecho. O `xcodebuild test`
**troca o contêiner de dados do app** (lei conhecida do instrumento), e depois
dele o container `2FE7F8BD-…` não existe mais no `6033B043`. Os três arquivos
originais continuam em `/tmp/a1b-guardado/`, com os SHA-256 acima — quem quiser
refazer a conta os tem na mão; quem for olhar o aparelho não vai achar o espelho
daquele instante, e isso é o teste, não o defeito.

### Ordem de leitura na árvore de acessibilidade

A árvore de AX entrega, nesta ordem: cabeçalho → o que houve → onde está o
conteúdo (id `arranque-onde-esta`) → ação (id `arranque-tentar`) → "Detalhe
técnico: …". O detalhe entra com `accessibilityLabel` prefixado para não soar
como frase do produto.

## design-router — as seis fases

Rota escolhida na tabela do roteador: **ajuste local de componente/copy** (uma
tela, sistema existente como âncora). Sem moodboard, sem tokens novos.

- **Ancorar.** Li `Tema.swift`, `Componentes/Vazio.swift`, `Componentes/Botao.swift`
  e `App/TituloTela.swift`. A voz do produto para o vazio e a falha já existe:
  frase direta, saída nomeada, nada de glifo triste nem desculpa.
- **Sistema.** **Zero tokens novos.** `Tema.tituloTela` + `trackingTitulo`,
  `Tema.corpo`, `Tema.meta`, `Tema.miudo`, `Tema.tinta`/`tintaSuave`/`tintaFraca`,
  `Tema.aviso` (a segunda recusa), `Tema.margem`, `Tema.entreItens`,
  `Tema.entreSecoes`, `.buttonStyle(.primario(alinhamento: .leading))` —
  o estilo que já garante os 44 pt e a pressão sem opacidade.
- **Construir.** `Traco/App/ArranqueFalhouView.swift`, 90 linhas, dois previews
  (normal e AX5). `ScrollView` porque em AX5 o texto passa de duas telas.
- **Mover.** **Nenhuma animação.** A tela é o fim de um percurso que já deu
  errado; movimento aqui seria enfeite. O único estado que muda é a linha da
  segunda recusa, que aparece seca. Nada a medir sob Reduzir Movimento.
- **Julgar.** O teste do design genérico: trocar o nome deixaria a página
  igualmente adequada a qualquer app? Não — a linha do meio conta **a contagem
  real de arquivos deste produto** e nomeia a pasta Traço no app Arquivos. É
  conteúdo, não moldura.
- **Portão.** Estados exercitados na tela real: falha em `large`, falha em AX5
  (topo e rolado), segunda recusa, recuperação. Não há estado "carregando" nem
  "sem permissão" nesta tela; "vazio" é a variante da frase quando o espelho não
  tem nenhum `.md`, e ela foi **fotografada no aparelho** com o espelho
  esvaziado de propósito (`a1-08-espelho-vazio.png`, seção acima).

## Para quem mescla — conferido no fecho (A1-D), contra o `main` de `b4559f5`

Eu não mesclo. Isto é o que a mescla vai encontrar, medido com
`git merge-tree --write-tree main HEAD`:

**1. O número da ADR COLIDE, e é o único achado que exige decisão.** Enquanto
esta volta corria, a E1 entregou três ADRs em `main`: `08m` (E1), **`08n`
(E1-B, "Cancelar não apaga o que já foi observado")** e `08o` (E1-C). A A1
também se chama **`08n`**. Duas ADRs diferentes com o mesmo número não podem
subir. A primeira letra livre hoje é **`08p`**, mas quem mescla decide — a E1
pode tomá-la antes. **Não renumerei de propósito:** escolher o número é da
mescla, e escolher errado aqui deixaria duas ADRs erradas em vez de uma.
As 11 referências a renumerar, todas neste branch:

```
SPEC.md:6214                          (o cabeçalho da ADR)
EVOLUCAO.md:19                        (linha "Preservar escrita…")
Traco/TracoApp.swift:7
Traco/App/ArranqueFalhouView.swift:3
Traco/Modelo/Migracao.swift:83
TracoTests/PortaoDoTryBangTests.swift:9 e :129
TracoTests/ColheitaEixosTests.swift:818
ferramentas/orca/RUMO.md:96
ferramentas/orca/a1-arranque.md:4 e :372   (este documento)
```

**2. `ferramentas/orca/RUMO.md` NÃO desfaz nada.** `git merge-tree` casa o
arquivo sozinho ("Auto-merging", sem conflito). A A1 acrescenta **duas linhas e
só duas**, na seção "Dívida vinda dos portões de hoje" (as quatro dívidas de
`try!` congeladas; a recuperação que a A1 não entrega). Tudo o que o `main`
ganhou hoje mais abaixo no arquivo — os dois achados da V13, a régua do
vazamento, o RESOLVIDO da Q-C — está em outra região e **sobrevive intacto**.

**3. Os dois conflitos são de vizinhança, não de mérito.**
- `EVOLUCAO.md` (uma marca): os dois lados mexeram em **linhas diferentes** da
  mesma tabela — o `main` na linha "Intenção→artefato delegado…" (E1), a A1 na
  linha "Preservar escrita, importação e restauração". Resolve-se ficando com
  as duas, cada uma do seu lado.
- `SPEC.md` (uma marca): os dois lados **acrescentaram ADRs no mesmo ponto**.
  `main` traz `08m`/`08n`/`08o` da E1; este branch traz a da A1. Ficam todas —
  com o número da A1 corrigido conforme o item 1.

**4. Uma linha da tabela congelada envelhece com o `main`.**
`Traco/Trabalho/PraticaTrabalho.swift` está em **:529** aqui e em **:547** no
`main` — a E1 mexeu no arquivo depois. É a MESMA ocorrência de `try!` e a
contagem não muda (8 aqui, 9 lá), mas o número da linha aparece em três lugares
(a tabela deste relatório, o `RUMO.md` e o doc de `PortaoDoTryBangTests`) e deve
ser relido contra o `main` do momento da mescla. O portão não usa número de
linha — ele conta —, então nada fica vermelho por isto.

## Scorecard (preenchido por mim; a nota final é do revisor independente)

| dimensão | nota | evidência |
|---|---|---|
| Visão | 9 | eixo 4 + item 8 da fila; linha nova no EVOLUCAO na capacidade "Preservar escrita, importação e restauração" |
| Contrato | 9 | ADR 08n, SPEC/EVOLUCAO/RUMO coerentes com o diff |
| Correção | 9 | 934/934 em 152 suítes; portão verde e **vermelho provado**; dois testes de `DiscoTraco` reescritos para o contrato novo |
| Jornada real | 9 | sete capturas do `6033B043`, banco de verdade impedido de abrir, antes e depois |
| Design | 9 | seis fases acima, zero tokens novos, zero componentes novos |
| Simplicidade | 9 | a tela tem UM ato. Passos não cresceram: quem abre com o disco são, não vê nada disto |
| Movimento | n/a | nenhuma animação nesta volta, de propósito |
| Componentes | n/a | nada reutilizável nasceu; a tela é única e usa `.primario` de `Componentes/Botao.swift` |
| Acessibilidade | 9 | AX5 sem clipe (duas capturas), alvo 43,98 pt medido, ordem de leitura da árvore de AX, `accessibilityLabel` no detalhe técnico |
| Performance | n/a | tela estática, sem lista, sem editor, sem parser |
| Privacidade e autoria | 9 | nada publica, gasta ou envia; a mudança **remove** a rota que podia apagar o espelho |
| Estado honesto | 10 | é a volta inteira: a falha ficou visível, a segunda falha também, e nada finge |
| Complexidade | 9 | +153 −88 em 8 arquivos + 2 novos; um `static var aviso` e um overlay morto saíram do `RaizView` |
| Fora do app | n/a | o widget não é tocado; com o disco recusado ele mantém o que já publicou, e o app não republica nada |
| Relato | — | este documento |

## Limites, ditos

- **VoiceOver falado não foi ouvido, e não será** — não é pendência de
  instrumento: é **ordem do dono**. Voz, VoiceOver e ditado estão proibidos no
  Traço, porque o áudio de qualquer simulador sai pelas caixas do Mac onde o
  autor trabalha. A lei da ESTEIRA diz como se prova acessibilidade no lugar
  disso: **árvore de AX e captura**, conferidas no mesmo instante — que é
  exatamente o que esta volta tem (ordem de leitura acima, AX5 em duas capturas,
  alvo de 43,98 pt medido). A fala fica **declarada como limite, e limite
  declarado não desconta nota**.
- **A recuperação é só "tentar de novo".** Trazer o espelho em Markdown de volta
  para dentro do banco é volta própria, e está no RUMO.
- O aparelho foi restaurado: `content_size` de volta em `large` (conferido por
  `xcrun simctl ui`), helper do `orca emulator` morto ao fim, simulador deixado
  ligado como estava.
