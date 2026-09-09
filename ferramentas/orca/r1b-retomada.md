# R1-B — a régua do dono: as seis fases, a curva-zero em toques, e a Complexidade

Implementador (Claude Opus 5), 09/09/2026, 03h30–05h00.
Branch `Vitorepf/volta-r1-retomada`, sem mesclar. ADR **2026-09-08y** atualizada.

**Simulador: iPhone 17 Pro (teste 3) `34CC3F94-FDB5-4575-A4F5-80271829A18B`**,
recebido desligado, ligado por mim, usado sozinho, desligado ao fim com
`xcrun simctl shutdown` do meu UDID — **nunca `orca emulator kill`**, que ontem
derrubou o aparelho de outra volta. Nenhum toque no `C2416CBC` (conta Grok do
dono, com a conta caída): nada instalado, nada apagado, nada lançado nele.
**Nenhum mouse do Mac, nenhuma voz, nenhuma Siri, nenhum VoiceOver, nenhum iPad,
nenhum maestro.** Todo `xcodebuild`, `xcodebuild test` e toda sessão de
`orca emulator` passaram por `ferramentas/orca/com-trava.sh` — segurei a trava em
cada uma. Capturas por `xcrun simctl io 34CC3F94… screenshot`, com o UDID
explícito, nunca `booted`.

O G3 disse **CORRIGIR ANTES** e manteve o mérito: o contrato determinístico da
retomada é bom e a recusa de rolar automaticamente está correta. Isso não se
refaz. O que esta volta faz são as três coisas que a DIRETRIZ §7 cobra.

---

## 1. As seis fases do `design-router`, com o que eu fiz em cada uma

O G3 tem razão: o relato anterior citou a rota e uma fase só. As seis, com a
tela na frente:

### Ancorar — de quem é a dor e qual é a tarefa

A pessoa é o autor que **trabalhou ontem e volta hoje**. A tarefa não é "ver a
folha": é **saber as sete coisas** de que ele precisa para continuar — o
objetivo, o próximo passo, a versão nova, o ato que ele marcou, o resultado que
ele mesmo informou, quando foi o último retorno e a dificuldade que registrou.
Essas sete viraram a régua desta volta, e estão escritas no teste
(`CurvaZeroRetomadaUITests.fatos`), não só no relato. O critério do dono, palavra
do Astra: *"o dono volta depois e continua com pouca explicação"* — item 4 da
fila, ciclo multiplicar a mente.

### Sistema — o que já existe e não se reinventa

Inventário antes de escrever qualquer coisa: a folha já tem `secao(…)`,
`Tema.meta`, `Tema.tintaSuave`, `Pilula` e `CabecalhoDeFolha`; a `retomada` já é
o segundo bloco. **Nenhum token novo, nenhum componente novo, nenhuma cor nova,
nenhuma tipografia nova.** O bloco "Desde …" usa exatamente o que a folha ao
redor usa — é por isso que na captura `r1b-normal.png` ele não se lê como
enxerto. A decisão de NÃO criar componente está medida na seção 3.

### Construir — o menor caminho que entrega a tarefa

Um bloco só, dentro da `retomada` que já existia; uma função de domínio
(`mudancasDesde`) que sai dos vínculos que o app guarda; duas datas novas no
documento porque decisão sem data não pode ser contada. Nenhuma tela nova,
nenhum agregado novo, nenhum estado persistido novo. **Nenhuma frase escrita por
modelo** — um resumo gerado seria bonito e seria mentira sobre o que a pessoa
fez.

### Mover — o que se move, e por que quase nada se move

**Nenhuma animação nova, e isso é decisão, não esquecimento.** O bloco entra com
o documento, na composição da folha. Animar a chegada dele chamaria atenção para
o *aparecimento* quando a atenção tem de ir para o *conteúdo*: quem volta depois
de um dia quer ler, não assistir. O único movimento da folha continua sendo a
rolagem por foco/ação explícitos, que eu não toquei — e a **rolagem automática na
abertura foi recusada**, porque ela esconderia a intenção, que é o objetivo que o
critério manda retomar. Fase aplicável, resposta "nada se move", motivo escrito.

### Julgar — a tela viva contra a auditoria

Auditei antes de tocar e **um dos três defeitos do G0 já tinha caído**: "a folha
não abre no ponto certo" é falso hoje — o "Continuar" nasce a 0,36 tela do topo.
Nesta volta o julgamento foi refeito com números novos e mais duros (seção 2), e
mais três estados que eu não tinha julgado: **sem visita**, **reabertura** e
**AX5 com o bloco na janela**. Os três agora têm captura e árvore do mesmo
instante, e viraram teste.

### Portão — o que fica vermelho se isto quebrar

Cinco testes de domínio em `TracoTests/RetomadaTrabalhoTests.swift` (janela,
ordem, dois eixos, decisão sem data, âncora — com o vermelho mostrado antes do
verde) e **quatro na tela viva** em `TracoUITests/CurvaZeroRetomadaUITests.swift`
(a medida em toques, teto+excedente+reabertura, primeira visita, AX5). Suíte
integral verde e sem avisos (seção 5). O que o portão **não** alcança está dito
na seção 6, em vez de fingido.

---

## 2. A curva-zero em TOQUES E GESTOS — executada, não inferida

O G3 está certo: "0,48–0,67 tela" mede **distância percorrida**, e a régua do
dono é **quanto a pessoa tem de fazer**. Os "no mínimo quatro arrastos" do relato
anterior eram inferência, não medida.

Agora a medida é execução. O condutor é o **XCUITest**, que dá toque e arrasto
de verdade no aparelho do `-destination` — não o helper do `orca emulator`, que
amplifica o arrasto de 6 a 24x e é um só na máquina. **Mesma tarefa, mesmo
estado plantado, mesmo gesto (`swipeUp()`, ~0,76 tela por vez), mesmo aparelho,
mesma letra (`large`).** O "antes" é o binário compilado de `c751c02`; o
"depois", o desta volta.

| | antes | depois |
|---|---:|---:|
| toques até a folha (Notas → Trabalhos → o trabalho) | 3 | 3 |
| **arrastos dentro da folha** | **5** | **0** |
| **paradas de leitura** (posições onde um fato novo aparece) | **6** | **1** |
| fatos na primeira tela, sem gesto nenhum | 2 de 7 | **7 de 7** |

A tabela por gesto, como o teste a escreveu (`*` = dentro da janela legível;
número = altura de tela a partir do topo da folha):

```
antes — janela=874pt  toques-ate-a-folha=3
gesto objetivo passo   versão  ato     resultado retorno dificuldade vistos
0     0.24*    0.36*   1.57    2.41    2.45      3.76    4.22        2
1     -0.54    -0.42   0.79*   1.63    1.67      2.98    3.44        3
2     -1.32    -1.20   0.01*   0.85*   0.89      2.20    2.66        4
3     -2.10    -1.98   -0.77   0.08*   0.11*     1.42    1.88        5
4     -2.88    -2.76   -1.55   -0.70   -0.67     0.64*   1.10        6
5     -3.58    -3.46   -2.25   -1.41   -1.37     -0.06   0.40*       7
gestos-ate-os-sete=5  toques=3  vistos=7/7

depois — janela=874pt  toques-ate-a-folha=3
0     0.24*    0.36*   0.58*   0.53*   0.74*     0.72*   0.48*       7
gestos-ate-os-sete=0  toques=3  vistos=7/7
```

Arquivos: `ferramentas/orca/r1b-medida-antes.txt`, `…-depois.txt`. A captura do
estado normal, com os sete na primeira tela, é `r1b-normal.png`.

**O que esta medida NÃO diz.** Não diz que a pessoa dá exatamente cinco arrastos:
diz que **com o mesmo gesto, no mesmo aparelho e no mesmo estado**, o antes exige
cinco e o depois zero. Não foi medida em AX5, onde o percurso do "antes" é mais
longo. E o número de paradas de leitura é contado pela tabela (posições em que um
fato novo entra na janela), não por observação de uma pessoa real.

---

## 3. A Complexidade — o que desceu, medido

O G3 recusou o 8 arredondado, e com razão. Resolvo com número, não com adjetivo.

**O diff de produção, contado linha a linha** (`git diff c751c02 -- Traco/`):

| | R1 como o G3 leu | R1-B (agora) |
|---|---:|---:|
| linhas adicionadas | 146 | 151 |
| das quais **comentário** | 51 | 56 |
| linhas removidas | 13 | 14 |
| **líquido de CÓDIGO** (sem comentário) | **82** | **81** |

O código **desceu**, e o que subiu foram cinco linhas de comentário — que nesta
casa é a trilha do contrato, não peso. O que desceu, concretamente:

- **Um estado a menos na view.** `visitaLida` sumiu: a primeira abertura da folha
  já se distingue por `oficina == nil`, e ler a visita **antes** de `oficina =
  nova` tem um bônus — uma leitura que falha não consome mais a janela do autor.
- **Uma duplicação a menos, e ela é anterior a esta volta.** "Resultado que você
  informou: …" era escrita em dois pontos antes da R1 e a R1 fez três. Agora é
  uma: `ResultadoObservado.frase`. É o mesmo defeito que `Apoio.nome` já tinha
  corrigido — duas redações do mesmo estado seriam duas verdades.

**E por que a migração para Componentes NÃO desce o diff — medido, não achado.**
Um componente desta casa carrega interface, corpo e três `#Preview`: os dez
arquivos de `Traco/Componentes/` têm 38, 49, 57, 62, 62, 96, 106, 109, 110 e 187
linhas. O menor deles, `Rotulo`, tem 38 linhas para um modificador de uma linha —
porque o custo fixo é o arquivo, não o conteúdo. O bloco "Desde …" tem **um só
lugar que o chama**, e extraí-lo custaria **+25 a +30 linhas** e criaria um
componente que nenhuma outra tela usa. Migrar aqui é ADIÇÃO disfarçada de
arrumação, e a regra da casa é não criar abstração com uma implementação só.

**Nota que peço: 9.** 81 linhas de código para o item 4 da fila do dono, sem
arquivo novo em `Traco/`, sem tipo novo além de um `struct` de três campos, sem
dependência, sem tela nova, sem estado persistido novo — com um estado de view a
menos e uma duplicação a menos do que antes desta volta começar. Se o revisor
achar que 81 linhas ainda pesam 8, o caminho não é extrair componente: é cortar
função, e a função aqui é o item 4.

---

## 4. O que mudou na NOTA de cada dimensão que toquei, com prova

| dimensão | G3 deu | peço | o que mudou, e onde está a prova |
|---|:---:|:---:|---|
| **Design** | 6 | **9** | As seis fases estão na seção 1, cada uma com o que fiz e ancorada à tela; onde a fase não produz nada (Mover) o relato **diz por quê** em vez de calar. Prova: `r1b-normal.png` (o bloco com os tokens da casa) e `r1b-ax5.png`. |
| **Simplicidade** | 7 | **9** | Curva-zero medida em toques e gestos, executada nos dois binários pelo XCUITest: **3 toques + 5 arrastos + 6 paradas** vira **3 toques + 0 arrastos + 1 parada**. Prova: `r1b-medida-antes.txt`, `r1b-medida-depois.txt`, e o teste que fica vermelho se um dos sete sumir. |
| **Complexidade** | 8 | **9** | Líquido de código 82 → **81**, com −1 estado de view e −1 duplicação anterior à volta; a migração para Componentes foi **medida** e adiciona 25–30 linhas para um único chamador. Prova: seção 3, contagem reproduzível. |
| **Correção** | 8 | **9** | Os limites que faltavam viraram teste na tela viva: teto de quatro linhas, `e mais 1 desde então`, primeira visita sem bloco, e o contrato de que reabrir a folha é visita nova. Prova: `CurvaZeroRetomadaUITests` (4 testes verdes) + suíte integral 963/155, 0 avisos. |
| **Jornada real** | 8 | **9** | Os estados que faltavam (sem visita, reabertura, AX5 com o bloco na janela) foram executados no aparelho, com captura `simctl` e árvore do MESMO instante. Prova: `r1b-sem-visita.png`, `r1b-ax5.png`, `r1b-normal.png`. |
| **Acessibilidade** | 8 | **9** | O G3 apontou que a captura AX5 anterior mostrava o topo da folha e não o bloco. Agora o teste **leva o bloco para dentro da janela** e só então fotografa: `r1b-ax5.png` mostra cabeçalho e linhas legíveis, e o teste afirma que nenhuma linha sangra pelos lados. VoiceOver falado continua declarado como limite, por ordem do dono. |
| **Relato** | 6 | **9** | Este documento: seis fases, medida executada, complexidade contada, e o que a volta não prova dito na seção 6. |

As dimensões que o G3 já deu 9 (Visão, Contrato, Privacidade e autoria, Estado
honesto) não foram tocadas e continuam apoiadas na mesma prova. Movimento,
Componentes, Performance e Fora do app seguem **n/a** — e agora a fase Mover
explica o n/a em vez de deixá-lo em branco.

**A nota final é do revisor independente, não minha.**

---

## 5. Suíte integral

`ferramentas/orca/com-trava.sh xcodebuild test -scheme Traco -destination
id=34CC3F94-… -parallel-testing-enabled NO`

```
✔ Test run with 963 tests in 155 suites passed after 55.443 seconds.
** TEST SUCCEEDED **
```

`grep -c "warning:"` no log completo: **0**. O runner conectou em todas as
corridas desta volta (nenhum `0 de N`, nenhum "hung before establishing
connection").

Os quatro testes de tela rodam pelo esquema `TracoUITests`, que **não** entra na
suíte integral (é assim no `project.yml` desde antes desta volta). As quatro
corridas:

```
CurvaZeroRetomadaUITests.testCurvaZeroEmToquesEGestos            ** TEST SUCCEEDED **
CurvaZeroRetomadaUITests.testTetoExcedenteEAVisitaQueRecomecaAoReabrir  ** TEST SUCCEEDED **
CurvaZeroRetomadaUITests.testSemVisitaGuardadaAFolhaCala         ** TEST SUCCEEDED **
CurvaZeroRetomadaUITests.testBlocoDaRetomadaEmAX5                ** TEST SUCCEEDED **
```

---

## 6. O que esta volta NÃO prova, e prefiro dizer

- **Não prova que o dono volta e continua.** Isso fecha no uso dele.
- **Fechar a folha e reabrir é visita nova**, e o bloco cala. É o contrato da ADR
  e agora é teste — mas é uma escolha discutível: quem sai para a lista e volta
  perde o resumo. Não mudei porque mudar seria função nova; fica na mesa do dono.
- **A reabertura interna** (`preservarEReabrir`, depois de um erro de escrita)
  preserva a janela por construção, e **não** foi exercitada na tela: forçar um
  erro de escrita não coube nesta volta.
- **A curva-zero não foi medida em AX5.** Em AX5 o bloco tem 1289 pt e a janela
  874: ele não cabe inteiro, e o percurso do "antes" seria mais longo ainda. A
  prova em AX5 é de legibilidade, não de esforço.
- **Dois destinos de rolagem passam por variável** (`chave`, `falta`) e o portão
  da âncora não os alcança — e o diz.
- **Avaliação de hipótese continua fora da lista** de mudanças (evento real e
  datado, `avaliadaEm`); deixada de fora por enxugamento.
- **O gesto do teste é o `swipeUp()` do XCUITest**, não o polegar de uma pessoa.
  Ele é idêntico nos dois lados da comparação, que é o que a medida precisa; não
  é a velocidade nem a precisão de um humano.

## 7. Instrumento

Uma tentativa de dirigir a folha pelo `orca emulator` (três toques, `attach`
explícito no meu UDID) **não moveu a tela**: a árvore voltava sempre a mesma
Página, e havia outras voltas com aparelho ligado na mesma máquina. Em vez de
insistir — e correr o risco de estar tocando o simulador do vizinho, que é o
achado de 08/09 sobre o helper único — troquei de instrumento para o XCUITest,
que se prende ao UDID do `-destination` e não passa pelo helper compartilhado. A
troca é o que tornou a medida desta volta **reproduzível**, que era exatamente o
que faltava na anterior.

Estado final do aparelho: `34CC3F94` desligado por `xcrun simctl shutdown` do
próprio UDID. Nenhum outro simulador foi ligado, desligado ou tocado por mim.
