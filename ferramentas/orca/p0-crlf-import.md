# P0-CRLF — o arquivo só se apaga quando o app leu tudo o que havia nele

**Volta:** P0-CRLF · **branch** `Vitorepf/p0-crlf` · **base** `366e609` (main).
**Worktree:** `/Users/vitorepf/orca/workspaces/traco-ios/p0-crlf`.
**ADR:** 09y (letra dada pelo coordenador; conferi em `origin/main` que
`grep -c "^| 09y" ferramentas/orca/LETRAS-ADR.md` devolve **1** — não a escrevi).
**Aparelho:** `34CC3F94-FDB5-4575-A4F5-80271829A18B` (teste 3), build, suíte e
jornada. **Não toquei em `B91C8DEF`** — a Q4-E tem janela aberta nele.

> **O caso E mudou o nome da volta. Não é o bug do Windows.** O `\r` era um dos
> caminhos até o defeito; o defeito é a porta apagar um arquivo que ela não leu
> inteiro. Achei o caso E porque **refiz a medida do revisor do zero**, com as
> linhas verbatim do `Corpus`, em vez de confiar na tabela que me deram.

---

## 1. Método — por que a medida foi refeita

O despacho trazia a tabela A/B/C/D pronta. O relatório citado
(`ferramentas/orca/revisao-mac-2-a.md`, tip `476afe2` do branch `Vitorepf/mac-2-a`)
**não contém o harness do import**: ele mede a *cerca* do `EspelhoTrabalhos`, não a
porta. A saída da medida do import está descrita no `LACO.md` de `main`
(10/09, 10h35), em prosa, sem os números por caso.

Então construí o meu, e ele é verbatim dos DOIS lados:

- `Antes` = linhas **304-358** de `Traco/Notas/Corpus.swift` em `HEAD` (`366e609`);
- `Depois` = linhas **309-393** da árvore de trabalho;
- único acréscimo: um stub de 2 linhas para `Gesto.doNome` (que devolve `nil`,
  como devolve para qualquer nome que o catálogo não conhece).

Harness em `ferramentas/orca/p0-crlf/harness.swift`, saída em
`ferramentas/orca/p0-crlf/medida-antes-depois.txt`. **Nenhuma linha de medida foi
ajustada para o conserto passar** — a coluna ANTES é a mesma expressão que a coluna
DEPOIS, rodando contra a função velha.

Reproduzi A/B/C/D **idênticos aos do revisor**. Foi ao acrescentar as colunas
"quanto do arquivo eu li" e "apagaria?" que o caso E apareceu.

## 2. A medida — antes e depois, oito casos

| caso | ANTES: itens · origem · apaga? · selo vazou? | DEPOIS: itens · apaga? · consumido |
|---|---|---|
| A) LF puro, selada | 0 · — · **não** · não | 0 · não · 0.00 |
| B) tudo em CRLF, selada | 1 · **autor** · **SIM** · **SIM** | 0 · não · 0.00 |
| C) `\r` só na linha do estado | 0 · — · **SIM** · não | 0 · não · 0.00 |
| D) `\r` só na linha da origem | 1 · **autor** · **SIM** · **SIM** | 0 · não · 0.00 |
| E) **prosa antes do 1º cabeçalho, sem um `\r`** | 1 · autor · **SIM** · não | 1 · não · **0.52** |
| F) misto: nota sã + `\r` antes do `---` | 1 · autor · **SIM** · **SIM** | 0 · não · 0.00 |
| G) `.md` solto, sem cabeçalho | 1 · autor · SIM | 1 · **SIM** · **1.00** |
| H) nota **aberta** inteira em CRLF | 1 · autor · SIM | 0 · não · 0.00 |

"selo vazou" = o corpo de uma nota `estado: selada` entrou como nota. **A linha G é a
irmã que NÃO acusa**: o caminho comum continua importando e continua podendo esvaziar
a pasta. Sem ela, `podeRetirar = false` fixo passaria em tudo o mais.

**O caso E, por extenso.** `# minhas notas de hoje` + uma linha, e só então o primeiro
`---\ncriada:`. O laço começa em `hits[0].range.location`: **tudo antes do primeiro
cabeçalho nunca é examinado**. Leu 12 de 104 caracteres com tinta, importou a nota de
baixo, marcou `contemProtegida = false` — e `Entrada.confirmar` **apagou o arquivo**.
Sem Windows, sem `\r`, sem import de fora: basta o dono escrever um `.md` como uma
pessoa escreve.

## 3. O conserto — a invariante é COBERTURA, e ela é um número

Quatro mudanças, todas em `Corpus.swift` menos uma linha em `Entrada.swift`.

**1. `importarComEstado` devolve `(itens, podeRetirar, consumido)`.**
`consumido` = fração dos **caracteres com tinta** (não-espaço, não-quebra: o `\r` não
conta como conteúdo) que viraram nota. `podeRetirar` = `lidos == tinta`.
Qualquer `continue` — selo, cabeçalho que não fecha, corpo vazio — e a prosa antes do
primeiro cabeçalho deixam a conta curta **sozinhos**. Não há bookkeeping por ramo, e
um `continue` que alguém acrescente amanhã já está coberto.

**2. O portão saiu de quem chama.** `contemProtegida` deixou de existir. Quem sabe se
leu tudo é quem leu; remontar a decisão do lado de fora
(`podeRetirar = !resultado.contemProtegida`) **era** o defeito. `Entrada.swift:61`
agora escreve `podeRetirar: resultado.podeRetirar`.

**3. Portão que não enxerga falha fechado.** O regex do cabeçalho só conhece o fim de
linha LF. `Corpus.cabecalhos(_:)` conta **a mesma forma** (`---`, `id:` opcional,
`criada:`) partindo por `\.isNewline`, que enxerga CRLF, CR e LF. Contagens diferentes
= existe cabeçalho do Traço que este parser **não leu** — e cabeçalho não lido pode ser
um selo. Então **nada entra como do autor e nada se apaga**, em vez de o arquivo
inteiro virar uma nota aberta. Fecha B e F.

**4. As duas leituras do cabeçalho passam a saber o que é uma linha.**
`cabecalho.split(whereSeparator: \.isNewline)` no lugar de `split(separator: "\n")`,
nos dois lugares. Stdlib, sem função nova. Fecha D, onde
`origem: modelo\r\nestado: selada` voltava como UMA linha e derrubava a origem **e** o
selo de uma vez (`"\r\n"` é UM `Character`; `CharacterSet.whitespaces` não contém
`\r`).

### Resposta às duas perguntas do despacho

**"Normalizar na porta de entrada basta?"** Bastaria para B/C/D/F — e **não escrevi a
normalização**, por ordem do coordenador: `Corpus.fimDeLinhaLF(_:)` chega a `main` pela
MAC-2-A, e duas versões da mesma função no mesmo arquivo é o slop que a casa nomeia.
Não copiei a forma inline de `BlocoCaderno.swift:83`: é a que o revisor provou **cega**
(`s.contains("\r")` resolve para `contains(_: Character)` e num texto CRLF o `Character`
é `"\r\n"`, não `"\r"`).

**"E se não bastar, o que falha fechado?"** Fiz as duas: a **cobertura** governa o
apagar, e o **portão de contagem de cabeçalhos** governa o entrar. Elas são
independentes de propósito — a cobertura fecha E, que normalização nenhuma fecharia; o
portão fecha B e F, que a cobertura sozinha não fecharia (em B o arquivo inteiro vira
uma nota e a cobertura é 100%).

### Custo declarado

Enquanto `fimDeLinhaLF` não chega, **uma nota aberta inteira em CRLF não importa** —
caso H. Ela fica na `entrada/`, intacta. É a direção segura: nada se perde. Quando a
normalização entrar na primeira linha de `importarComEstado`, B, C, F e H passam de
"recusadas em segurança" a "lidas certo", e as guardas 3 e 4 continuam sendo o portão.

### De graça, e por isso dito e não tocado (fora de escopo do despacho)

- **`Corpus.swift:281` (`separarCampos`) — coberto de graça.** Os dois chamadores
  (`Sessao.swift:1402` e `:1829`) recebem `ItemImportado.texto`, que agora ou vem de um
  bloco que o parser entendeu inteiro, ou não vem. **Não o toquei.**
- **`Sabia.swift:955`, `VozDoAutor.swift:78`, `AnaliseLocal.swift:295` — NÃO cobertos.**
  Leem texto já gravado no banco, e nota importada **antes** deste conserto guarda o
  `\r`. Continuam com dono no RUMO.

### Dívida nomeada

A recusa é **muda**. O arquivo fica na pasta e o autor não é avisado de que o formato
não foi entendido: `Entrada.arquivos` descarta o arquivo sem itens (`continue`), e
dar-lhe voz é mexer no toast de `Sessao.recolherEntrada`. Acabamento fora do escopo de
um P0 de perda de dado — nomeado aqui, não escondido.

## 4. Prova

### Suíte

`ferramentas/orca/com-trava.sh xcodebuild test -scheme Traco -destination
id=34CC3F94-... -derivedDataPath <privado> -configuration Debug`. Trava tomada às
**10h49m55** pelo PID 98568 (li o dono da trava, não o efeito colateral). Build **LIMPO**:
`derivedDataPath` novo e privado desta volta, 44 `CompileSwiftSources`.

```
✔ Test arquivoSoSaiDaEntradaQuandoOAppLeuTudo() passed after 0.001 seconds.
✔ Test oQueOAppLeuInteiroContinuaPodendoSairDaEntrada() passed after 0.001 seconds.
✔ Suite IntegridadeCorpusTests passed after 0.021 seconds.
✔ Test run with 1021 tests in 163 suites passed after 145.732 seconds.
** TEST SUCCEEDED **
```

**1 warning, o herdado:** `NotasView.swift:806:30` (`'+' was deprecated in iOS 26.0`).

**Prova de árvore própria — mais forte que um nome exclusivo.** Além dos dois testes acima,
que só existem neste candidato, extraí os **901 nomes distintos** de teste que o log
executou e os comparei com os declarados na minha `TracoTests/`:
**nomes executados que não existem na minha árvore: 0.** Nenhum teste de outra volta correu
aqui. Linhas em `ferramentas/orca/p0-crlf/suite-linhas.txt`.

### Jornada real no aparelho

`ferramentas/orca/p0-crlf/jornada.sh`, tudo dentro de **uma** chamada de `com-trava.sh`:
instalar, semear sete `.md` em `Documents/Traço/entrada/`, lançar, esperar, ler e fotografar.
Saída em `ferramentas/orca/p0-crlf/jornada.txt`, captura em `p0-01-depois-de-recolher.png`.

```
== binário instalado bate com o candidato?
SIM — cmp idêntico
== antes de lançar: entrada/
a-lf-selada.md  b-tudo-crlf.md  c-cr-no-estado.md  d-cr-na-origem.md
e-prosa-antes.md  f-misto.md  g-md-solto.md
== depois de o app recolher a entrada: entrada/ (o que SOBREVIVEU)
a-lf-selada.md  b-tudo-crlf.md  c-cr-no-estado.md  d-cr-na-origem.md
e-prosa-antes.md  f-misto.md
== o que virou nota (notas/, escrito pelo próprio app)
notas/…4858.md:8:só uma ideia solta, sem cabeçalho nenhum
notas/…835f.md:8:corpo aberto
== algum corpo SELADO entrou no caderno?
Traço/entrada/a-lf-selada.md:7:a dor que ninguém lê   ← só em entrada/, nos que ficaram
Traço/entrada/b-tudo-crlf.md:7:…  c-cr-no-estado.md:7:…  d-cr-na-origem.md:7:…
Traço/entrada/f-misto.md:12:outra dor
== binário instalado ainda é o candidato, DEPOIS da corrida?
SIM
```

**Sete entraram, SEIS ficaram.** O único que saiu foi `g-md-solto.md` — o `.md` sem
cabeçalho, lido 100%. A nota do caso E entrou (`corpo aberto`) **e o arquivo dela ficou**:
em `main` ela entrava e o arquivo era apagado com a prosa de cima dentro. Nenhum corpo
selado em `notas/`.

### O "antes" que eu não encomendei — e o aviso que ele carrega

Às **10h57**, **entre duas chamadas minhas de `com-trava.sh`**, alguém instalou **outro**
build de `app.traco` no mesmo UDID: o contêiner de dados trocou
(`BE66E3B3…` → `34B3D8AD…`) e o binário do bundle passou a ser de 10h57, com `cmp`
**diferente** do meu produto de 10h50. Esse build apagou **exatamente**
`b-tudo-crlf.md`, `d-cr-na-origem.md`, `e-prosa-antes.md` e `f-misto.md`, deixando
`a-lf-selada.md` e `c-cr-no-estado.md` — que é, byte por byte, o comportamento de `main`
na minha tabela. **O P0 aconteceu ao vivo no aparelho, num minuto, sem pedir nada a
ninguém.** Vale como "antes", e vale como aviso: há um `xcodebuildmcp` rodando desde 10h40
(pid 96331), e **um MCP de xcodebuild não passa por `com-trava.sh` por construção**.
Por isso a jornada foi **refeita inteira** e o `jornada.sh` agora confere o `cmp` do binário
instalado **antes e depois** da corrida, dentro da mesma trava. Escalei ao coordenador.

### Limite declarado (não desconta nota)

Não cheguei à **lista** de notas por toque: a árvore de AX do app volta vazia (só o nó
`Application`, largura 0) e "Todas" na barra do editor abre a folha de **Formas**. Parei na
terceira tentativa em vez de gastar instrumento navegando. A superfície deste defeito é a
**pasta do autor**, e ela está provada acima pelo estado do disco e pelos `.md` que o
próprio app escreveu. **VoiceOver falado: proibido no Traço, não exercitado.**

### Aparelho restaurado

`content_size = medium` conferido por leitura e por captura
(`p0-03-aparelho-restaurado.png`), aparência clara, barra de estado limpa, retrato.
Os dois simuladores continuam ligados como os achei; **não toquei no `B91C8DEF`**.

## 5. Scorecard (preenchido por mim; a nota final é do revisor independente)

| dimensão | nota | por quê |
|---|---|---|
| Visão | **9** | fecha a lacuna nomeada no EVOLUCAO ("Preservar escrita, importação e restauração"): a porta de entrada apagava o arquivo do autor sem ter lido o que havia nele. Diff do EVOLUCAO na linha 23 |
| Contrato | **9** | ADR 09y em `SPEC.md` (letra dada, conferida uma vez só em `origin/main`), EVOLUCAO e código dizem a mesma coisa; o custo (CRLF aberto não importa até `fimDeLinhaLF` chegar) e a dívida (recusa muda) estão **escritos**, não escondidos |
| Correção | **9** | 1021/163 verde, build limpo, 1 warning herdado; 8 casos medidos antes/depois em harness verbatim; jornada no aparelho com `cmp` do binário antes e depois; irmã que NÃO acusa junto da que acusa |
| Jornada real | **8** | o estado do disco e os `.md` que o app escreveu estão provados, e o aparelho rodou o candidato conferido por `cmp`. **Não** cheguei à lista de notas por toque (AX vazia); a captura que tenho é do app vivo, não da lista |
| Privacidade e autoria | **9** | três das seis rotas convertiam `origem: modelo` em voz do autor e importavam corpo `estado: selada`; nenhuma converte agora, provado por teste e por `grep` no caderno do aparelho |
| Simplicidade | **9** | o coletor deixou de remontar a decisão: `podeRetirar` vem pronto. Uma decisão a menos do lado de fora |
| Complexidade | **9** | **54 linhas somadas e 11 removidas em 2 arquivos de produção**, e ~28 dessas somadas são comentário. Nenhum arquivo novo, nenhuma dependência, nenhuma função de normalização duplicada |
| Performance | **9** | medido antes de escolher: `comTinta` por byte custa **0,6 ms** contra **23,7 ms** por `CharacterSet.whitespacesAndNewlines` num corpus de 562 KB (2000 notas); `cabecalhos` custa 6,0 ms no mesmo. Em arquivo de `entrada/` (dezenas de bytes) é ruído. `ferramentas/orca/p0-crlf/medida-custo.txt` |
| Estado honesto | **8** | o arquivo que fica na pasta É o estado visível, e é o certo. Mas a recusa **não tem frase**: o autor não é avisado de que o formato não foi entendido. Dívida nomeada, não escondida — e é ela que segura esta nota em 8 |
| Relato | **9** | este arquivo, com harness, medidas, log e capturas citados por caminho |
| Design / Movimento / Componentes / Acessibilidade / Fora do app | **n/a** | motor puro: nenhuma view, nenhum token, nenhuma cópia de tela. `ferramentas/orca/papeis/implementador.md` diz "motor puro dispensa" o `design-router`, e por isso não o carreguei |

**Duas dimensões em 8 e ambas pelo mesmo motivo:** a recusa é silenciosa. Dar-lhe voz é
mexer no toast de `Sessao.recolherEntrada`, que é acabamento em cima de um P0 de perda de
dado. Está nomeado para quem pegar a próxima.

## 6. Arquivos

**Produção** (54 somadas, 11 removidas):
- `Traco/Notas/Corpus.swift` — a cobertura, o portão de contagem, os dois `isNewline`,
  `comTinta`, `cabecalhos`
- `Traco/Notas/Entrada.swift` — `podeRetirar: resultado.podeRetirar`

**Teste:** `TracoTests/IntegridadeCorpusTests.swift` — a tabela A–G e a irmã que não acusa.

**Contrato:** `SPEC.md` (ADR 09y), `EVOLUCAO.md` (linha 23).

**Prova:** `ferramentas/orca/p0-crlf/` — `harness.swift` (verbatim dos dois lados),
`medida-antes-depois.txt`, `bench-cobertura.swift`, `medida-custo.txt`,
`suite-linhas.txt`, `jornada.sh`, `jornada.txt`, `p0-01-depois-de-recolher.png`,
`p0-03-aparelho-restaurado.png`.

**Não toquei:** `ferramentas/orca/LETRAS-ADR.md` (a letra é do coordenador),
`BlocoCaderno.swift`, `Sabia.swift`, `VozDoAutor.swift`, `AnaliseLocal.swift`,
`Corpus.separarCampos`, e nenhuma view.
