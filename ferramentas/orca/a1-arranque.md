# Volta A1 — o arranque honesto: o Traço que não abre tem de dizer, não morrer

Implementador: Claude Opus 5. Simulador: **iPhone 17 Pro Max `6033B043-F436-41F9-B4F8-2D9E67761980`**.
ADR: **2026-09-08n**. Branch: `Vitorepf/volta-a1-arranque`, sem mesclar.

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
`grep -rn 'try!' Traco/ TracoWidget/` deu **9 antes** da volta, **8 depois**.

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

### Suíte integral e build

```
** BUILD SUCCEEDED **
✔ Test run with 934 tests in 152 suites passed after 74.006 seconds.
```

`ferramentas/orca/com-trava.sh xcodebuild test -scheme Traco -destination
'id=6033B043-F436-41F9-B4F8-2D9E67761980' -parallel-testing-enabled NO`.
Zero `warning:` no log (`grep -c warning: → 0`).

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

### Ordem de leitura para o VoiceOver

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
  tem nenhum `.md`, e ela está no código e no preview — **não fotografada**,
  porque o espelho do aparelho tinha a nota (declarado, não vendido como visto).

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

- **O estado "espelho vazio"** da frase do meio não foi fotografado (o aparelho
  tinha a nota). Está no código e no preview.
- **VoiceOver falado** não foi ouvido — a ordem e os rótulos vêm da árvore de AX,
  não de um simulador com VoiceOver ligado. Mesma pendência de instrumento que o
  RUMO já registra para outras voltas.
- **A recuperação é só "tentar de novo".** Trazer o espelho em Markdown de volta
  para dentro do banco é volta própria, e está no RUMO.
- O aparelho foi restaurado: `content_size` de volta em `large` (conferido por
  `xcrun simctl ui`), helper do `orca emulator` morto ao fim, simulador deixado
  ligado como estava.
