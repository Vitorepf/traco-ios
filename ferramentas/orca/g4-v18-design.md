# G4 — volta 18 (Trabalho): julgamento de design

Sessão de julgamento (não implementa, não commita). Fases **Mover**, **Julgar**,
**Portão** do `design-router`, com `curva-zero` como autoridade sobre a carga
cognitiva da jornada. Worktree `volta-18-trabalho`, topo `120af64`.

## Instrumento e limites da evidência

Simulador **iPhone 17 Pro Max `6033B043-F436-41F9-B4F8-2D9E67761980`**, ligado
por mim, build do branch compilado nesta worktree
(`xcodebuild … -derivedDataPath /tmp/claude-501/dd-g4v18`, BUILD SUCCEEDED),
instalado e lançado. Desligado ao fim; Dynamic Type devolvido a `medium` e
`ReduceMotionEnabled` devolvido a `false` antes de desligar.

A lei do instrumento vale e foi confirmada nesta sessão: **`maestro --device`
não isola.** Havia um `maestro-driver-iosUITests-Runner` de OUTRO worker
segurando `[::1]:7001` (device `A1DF082C`, iPhone 17 Pro "teste 4") — `lsof`
confirma. Não usei maestro. Também não usei `cliclick` por coordenada como
instrumento principal: com cinco simuladores abertos as janelas se cobrem, e
medi que o `cliclick` **grampeia coordenada negativa** (`m:-500,500` devolve
`430,500` em `cliclick p:`), o que faria o toque cair na janela do vizinho.

O que usei, e é reproduzível: o **Simulator publica a árvore de acessibilidade
do iOS na AX do macOS**, com o `accessibilityIdentifier` em `AXIdentifier`.
Toquei por identificador (`click` do System Events = AXPress), escrevi por
`keystroke`, rolei por arrasto dentro da faixa de tela exclusiva da minha janela,
e **toda prova de tela é `xcrun simctl io <UDID> screenshot`**, nunca uma
asserção. A sessão inteira correu sob `ferramentas/orca/com-trava.sh`
(`/tmp/traco-instrumento.lock`), adquirida e liberada por mim.

**O que eu NÃO consegui exercitar, e por isso não julgo:** não há conta Grok
neste aparelho. Logo, nenhuma versão preparada pela IA, nenhum exercício,
nenhum feedback e nenhuma conferência assistida. A versão que existe nas minhas
capturas é **minha** (`produtor: Você`), escrita por "Escrever minha própria
versão". Onde isso muda a leitura, digo abaixo.

### Capturas e vídeo (`ferramentas/orca/`)

| arquivo | estado |
|---|---|
| `g4-v18-01-lista.png` | entrada dos Trabalhos, vazia |
| `g4-v18-02-folha-primeira-vez.png` | a folha recém-criada, cursor já no pedido |
| `g4-v18-03-praticar-topo.png` | trilho em Praticar |
| `g4-v18-04-combinar-topo.png` | trilho em Combinar |
| `g4-v18-05/06-com-versao-*.png` | documento com versão |
| `g4-v18-07-lista-com-trabalho.png` | lista com um trabalho |
| `g4-v18-08/09/15-*.png` | **a edição fantasma** (achado 1) |
| `g4-v18-10-dialogo-descartar.png` | confirmationDialog do sistema sobre a folha |
| `g4-v18-11/12-ax5-*.png`, `g4-v18-19-ax5-rolagem.png` | AX5: topo, Praticar e quatro paradas da rolagem |
| `g4-v18-13-mover-normal-quadros.png` | 15 quadros da troca do trilho, movimento normal |
| `g4-v18-14-mover-reduzido-quadros.png` | os 16 quadros gravados sob Reduzir Movimento |
| `g4-v18-16/17-familia-*.png` | Calendário e Notas, para comparação |
| `g4-v18-18-intercambio-disabled.png` | **o Intercâmbio** (achado 3) |
| `g4-v18.mp4` / `g4-v18-rm.mp4` | a troca do trilho nos dois modos |

---

## 1. MOVER — nota 9

**Vocabulário.** Todo movimento do módulo passa pela lei, em cinco pontos e
nenhum solto: `TrabalhoView:66` (`Tema.movimento(.deslocamento, Mola.camada)` —
a chegada da versão, por `artefatos.count`), `:119` (`Tema.animacao(Mola.escala)`
— a rolagem até o campo focado), `:224` (`Tema.movimento(.escala, Mola.escala)`
— o trilho), `:635` (`Tema.transicao(…)` — o cartão da versão) e `:962`
(`Tema.gaveta(reduzido:)`). `grep "withAnimation\|.animation(\|.transition("`
em `Traco/Trabalho/` devolve exatamente esses cinco. Zero animação crua.

**Como o trilho se move (normal).** Gravei e extraí os quadros
(`g4-v18-13`): a troca Praticar → Combinar leva ~13 quadros a 25 fps (≈0,52 s),
compatível com `Mola.escala` (`response: 0.55`). O carvão não desliza: ele
apaga numa pílula enquanto acende na outra. É calmo e é da casa.

**Sob Reduzir Movimento.** Ligado por
`simctl spawn … defaults write com.apple.Accessibility ReduceMotionEnabled -bool true`
+ shutdown/boot. Prova quantitativa, porque `simctl io recordVideo` só emite
quadro quando a tela muda: **as mesmas três trocas produziram 253 quadros no
modo normal e 16 sob Reduzir Movimento.** Os 16 quadros estão todos em
`g4-v18-14`, e todos mostram estado **resolvido** — Praticar, Combinar,
Delegar, Praticar. Não existe um único quadro intermediário. O corte é seco,
que é exatamente o que `Tema.movimento(.escala, _, reduzido: true) → nil`
promete. A lei cumpre o que enuncia.

**O que desconta.** No modo normal há ~0,2 s em que as duas pílulas estão em
cinza médio e **nenhuma lê como selecionada** (linhas 2 e 3 de `g4-v18-13`).
Com três opções, um cross-fade de preenchimento deixa o estado indefinido no
voo; um preenchimento que se move (`matchedGeometryEffect`) manteria sempre
exatamente uma marcada. É pequeno, mas é o único ponto em que o movimento
custa clareza em vez de dar.

**Não exercitado:** a chegada da versão preparada pela IA com `Mola.camada`.
Sem conta Grok, a versão que entrou foi a minha; ela anima pelo mesmo
`.animation` do bloco `documento(oficina)`, mas não tenho quadro isolando o
`artefatos.count` vindo da IA. A 18-C não tocou animação — confirmado por
`git diff ece2b27..120af64 -- Traco/Trabalho/` não conter nenhuma das cinco
chamadas.

---

## 2. JULGAR

### 2.1 É a mesma família, ou só ficou menos feia? — em 80% sim, e o resto dói

**O que prova a família.** Não é semelhança, é o mesmo código. `CabecalhoDeFolha`
é o cabeçalho de `CalendarioFicha` e `CalendarioFichaSistema` — a ficha que o
dono aprovou. `Pilula` é a mesma cápsula dos chips do Calendário (`g4-v18-16`:
o "D 6" e o "D" da escala são carvão preenchido entre cinzas — exatamente o
desenho do trilho Delegar/Praticar/Combinar) e dos filtros das Notas.
`.cartao()` e `.rotulo()` são os mesmos modificadores. `AcaoTrabalhoStyle` não
existe mais — sobrou uma menção em comentário em `Componentes/Botao.swift:19`.
Paleta, escala tipográfica e ritmo de 32/12 estão de pé, e em AX5 o trilho
empilha sem sangrar (`g4-v18-11`).

**O que ainda é outra família, e está no caminho comum.** Dentro da própria
folha, `IntercambioTrabalhoView` — "Editar com outras ferramentas" — não usa
**nenhum** componente da casa: são dois `Button` crus, sem cápsula, sem chip,
sem seta, a 20 pt, indistinguíveis do texto ao redor (`g4-v18-18`). E usam
`.disabled()` três vezes (`:26`, `:29`, `:86`), que é a lei que esta volta diz
ter abolido. Medi os pixels de `g4-v18-18`: **"Exportar versão em Markdown"
(habilitado) e "Importar versão de arquivo" (desabilitado) renderizam os dois
em `#1C1C1E`** sobre `#F4F4F2` — 15,5:1 os dois, idênticos. Um controle morto
com a aparência exata de um vivo é o pior caso de `critique-affordance`: pior
que o cinza de 1,53:1 que a volta corrigiu, porque ali pelo menos algo avisava.
A nota 5 de Design da auditoria dizia "formulário cru do sistema"; este bolso
é literalmente isso, sobrevivendo dentro da folha redesenhada.

Terceiro ponto, menor: o `confirmationDialog` de descartar rascunhos chega como
cartão flutuante do sistema **sem o título** ("Descartar os rascunhos dos
campos?" não aparece), com a frase quebrada em cinco linhas curtas e o
destrutivo em vermelho por cima da cápsula primária (`g4-v18-10`). É material
do sistema, não do papel.

### 2.2 Densidade da folha com uma versão presente — `critique-information-density`

A folha vazia mede **duas telas**, e não três: rolando até o fim
(`g4-v18-02` → `p2/p3`) chega-se ao rodapé em dois arrastos. Contra oito
`DisclosureGroup` na V9, hoje são cinco (`AgendamentoAcaoView` 1,
`IntercambioTrabalhoView` 1, `TrabalhoView` 3; era 1+1+6). Isso é ganho real.

Com a versão presente, porém, o cartão **imprime o mesmo parágrafo duas vezes**:
o texto da versão e, logo abaixo, um campo "Editar a versão" já aberto com o
mesmo texto (`g4-v18-05`, `g4-v18-09`, `g4-v18-15`). O autor lê a mesma frase
em sequência, e o editor ocupa espaço de cartão sem ter sido pedido. A causa é
o achado 1 abaixo; a consequência de densidade é dele.

Copy: numa folha em que **todos** os campos estão vazios, já há quatro linhas de
apoio (a do trilho, a do travamento, a do "Preparar este ato", a do
"Guardar…") mais três linhas de rodapé. Copy é design, e aqui ela é honesta —
"Preparar não marca como realizado", "Guardar preserva a sua resposta como sua"
— mas é muita voz de manual para uma tela em branco.

### 2.3 O trilho como decisão no caminho — `hicks-law`

Três opções antes do primeiro pedido. A favor: **o padrão já vem escolhido**
(Delegar, carvão em `g4-v18-02`), então ninguém precisa decidir para começar; e
a escolha muda de verdade o que "Preparar" faz — em Praticar a seção
"Preparar uma versão" some inteira e sobra "Minha tentativa" (`g4-v18-03`), em
Combinar entra o campo do trecho (`g4-v18-04`). Uma decisão que muda o resto da
tela merece estar no caminho, não num disclosure. **A colocação está certa.**

O que quebra é a explicação. A linha de apoio sob o trilho é **estática**:
`Text("Delegar não exige aprender a executar tudo. Você pode mudar quando
quiser.")` (`TrabalhoView:226`). Com Praticar selecionado ela continua dizendo
"Delegar não exige…" (`g4-v18-03`); com Combinar, idem (`g4-v18-04`). A frase
que existe para explicar a escolha explica a opção que o autor **não** escolheu,
e está colada logo abaixo dela. Hick's law cobra o custo da decisão; aqui o
custo é pago e a ajuda não chega.

### 2.4 Hierarquia entre pedir, acompanhar, conferir e praticar — `critique-visual-hierarchy`

A ordem de leitura está certa e é o maior acerto da volta: a intenção do autor
**em 28 pt bold, com as palavras dele**, depois quem faz, depois o pedido,
depois o ato, depois a dificuldade. A Dificuldade saiu da frente; a Prática
desceu para depois do pedido que a produz. É a ordem do ciclo.

O que falta é peso. Em uma rolagem convivem **duas ou três cápsulas carvão de
largura inteira** — "Preparar com IA", "Preparar este ato" e, em Praticar,
"Guardar minha tentativa". Nenhuma domina, e nada na tela diz em que etapa do
ciclo o autor está. As seções são rótulos de 11 pt de peso igual sobre o mesmo
papel, sem contenção (`law-of-common-region`): quatro perguntas com campo e
botão, empilhadas. Além disso o mesmo preenchimento carvão carrega **dois
significados** a 200 pt de distância — "opção selecionada" no trilho
(`Pilula(.filtro, selecionada:)`) e "ação primária" abaixo
(`Pilula(.larga, selecionada: true)`), porque `Pilula` desenha `chipAtivo`
para `cheia = forma == .acao || selecionada`. É defensável (carvão = o que está
comprometido, em toda a casa), mas custa (`law-of-similarity`).

### 2.5 A pergunta que a volta existe para responder

> Um autor que abre o Trabalho pela primeira vez entende, sem ninguém explicar,
> que aquilo serve para transformar uma intenção dele em algo feito?

**Em identidade, sim. Em estrutura, ainda não — e por isso a resposta é "meio".**

O que responde "sim": a folha abre com **a frase do próprio autor como título
da tela**, em 28 pt (`g4-v18-02`). Não é um rótulo de formulário, é o que ele
escreveu. E o primeiro campo já chega com o cursor dentro, perguntando "O que
você quer que a IA prepare ou ajuste?". A leitura de cima para baixo — minha
intenção → quem faz → preparar uma versão → próximo ato → o que está
dificultando — é a de uma oficina, não a de um cadastro. A entrada
(`g4-v18-01`) também é uma pergunta, não um "+": "O que você quer realizar?".

O que ainda responde "formulário": **o ciclo nunca é mostrado como ciclo.** Não
há progresso, não há "você está aqui", não há nada que diga que as quatro
seções são etapas de uma mesma volta em vez de quatro pedidos independentes. O
que o olho vê, quatro vezes seguidas, é *rótulo em caixa alta → pergunta →
campo em névoa → botão*. É a forma de um formulário bem vestido. E o único
momento em que a folha vira instrumento — a versão chegando como um objeto de
papel, com número, produtor e conferência — é justamente o momento em que ela
se quebra (achado 1).

Não é mais "outra família: formulário cru do sistema". É a família certa,
executando um formulário. O passo que falta não é visual, é estrutural.

---

## 3. Achados

### Achado 1 — BLOQUEIA. A folha nomeia uma edição que não existe, e trava a ação primária

**Estado.** Autor sem conta de IA escreve a própria versão: "Escrever minha
própria versão" → digita → "Guardar minha versão". A versão entra (Histórico
passa a 1). A partir daí, e **para sempre**:

- o cartão mostra o texto da versão e, logo abaixo, um campo "Editar a versão"
  já aberto com o mesmo texto (`g4-v18-05`);
- a ação primária "Preparar nova versão com IA" fica travada com
  **"Guarde a intenção ou a versão que está editando antes de pedir uma nova
  preparação."** — e o autor não está editando nada (`g4-v18-09`);
- "Importar versão de arquivo" fica travado pela mesma razão (`g4-v18-18`).

**Reprodução, e é o ponto.** Não sobrevive só à reabertura: fechei a folha,
voltei à lista, reabri — persiste (`g4-v18-08`). Descartei os rascunhos pelo
diálogo, **desliguei e religuei o simulador**, relancei o app, reabri o
trabalho e toquei apenas nas pílulas do trilho: **voltou** (`g4-v18-15`, tirada
sem ter tocado no cartão da versão nesta sessão do app).

**Causa, no código.** `campoEmEdicao(_:)` (`TrabalhoView:972`) julga a intenção
e o resultado por **diferença** — `rascunhos["intencao"] != documento.intencaoAtual.texto` —
mas julga a versão por **não-vazio**: `if !vazio("versao") { return "versao" }`.
E o rascunho de "versao" é escrito pelo próprio cartão: `campo("Editar a
versão", chave: "versao", padrao: a.conteudo)` (`:623`) tem
`get { rascunhos[chave] ?? padrao }` / `set { definir(chave, $0) }` — quando o
`TextField` confirma o texto que o `padrao` lhe deu, `definir` grava o rascunho
em `UserDefaults`, e a partir daí `!vazio("versao")` é verdade eternamente.
`edicaoPendente` fica travado, `motivoDoTravamento` anuncia um obstáculo
inexistente, e o cartão se mantém aberto porque a condição é
`editandoVersao || !vazio("versao")` (`:622`).

**Por que bloqueia.** A volta 18-C se chama "a folha cumpre a regra que
enuncia". Esta é a regra da folha sendo falsa no caminho mais ordinário que
existe sem conta de IA, contra a ação primária da tela, e persistindo através
de reinício de aparelho. Também é a origem do achado de densidade 2.2.

**Correção mínima.** Julgar "versao" como se julga intenção e resultado:
pendente só quando o rascunho **difere** de `o.documento.versaoAtual?.conteudo`.

---

### Achado 2 — BLOQUEIA (barato). A linha do trilho fala sempre de Delegar

**Estado.** `TrabalhoView:226`, texto fixo. Com Praticar selecionado
(`g4-v18-03`) e com Combinar selecionado (`g4-v18-04`) a folha continua
dizendo "Delegar não exige aprender a executar tudo".

**Impacto.** A única frase que explica a decisão que muda o resto da tela
descreve a opção não escolhida, encostada nela. É desinformação, não densidade.

**Correção mínima.** Uma frase por opção, ou uma frase que descreva as três sem
nomear uma; manter "Você pode mudar quando quiser" (essa vale para as três).

---

### Achado 3 — BLOQUEIA. O Intercâmbio não é da casa e desabilita ao velho modo

**Estado.** Na mesma folha, `IntercambioTrabalhoView` usa `Button` cru para
"Exportar versão em Markdown", "Importar versão de arquivo" e "Guardar como
nova versão externa", e `.disabled()` nos três (`:26`, `:29`, `:86`).

**Evidência.** Em `g4-v18-18`, com a importação desabilitada, amostrei os
pixels: enabled e disabled renderizam **os dois em `#1C1C1E`**. Um controle
morto idêntico a um vivo, sem cápsula e sem qualquer sinal de que é tocável.

**Impacto.** É o bolso de "formulário cru do sistema" que a auditoria V9
apontou, sobrevivendo dentro da folha que a volta reescreveu, e é a lei da
própria volta ("nenhuma ação bloqueada usa `.disabled()`") quebrada a dois
blocos de onde ela é cumprida.

**Correção mínima.** `Pilula` nas duas ações e a mesma lei do resto da folha:
sem `.disabled()`, motivo ao lado e no hint, toque leva ao que falta.

---

## 4. PORTÃO

| eixo | nota | o que segura a nota |
|---|---|---|
| **Design** | **7** | família provada por componente compartilhado com a ficha do Calendário; mas um bloco inteiro (Intercâmbio) ainda é sistema cru no caminho comum, e o `confirmationDialog` chega sem título por cima da cápsula primária |
| **Simplicidade** | **7** | duas telas em vez de três, 8 → 5 disclosures, decisão no caminho com padrão pronto; mas a folha afirma uma edição que não existe, imprime a versão duas vezes e explica a opção errada |
| **Movimento** | **9** | cinco chamadas, todas pela lei, zero cruas; 253 quadros contra 16 sob Reduzir Movimento, sem um único quadro intermediário; desconta só o instante em que nenhuma pílula lê como selecionada |
| **Componentes** | **7** | `Pilula`/`CabecalhoDeFolha`/`.cartao`/`.rotulo` compartilhados, `AcaoTrabalhoStyle` apagado; mas o Intercâmbio não usa nenhum, e o `.disabled()` de `Pilula` continua quebrado **no componente** — a volta consertou o chamador |

### Veredito: **CORRIGIR ANTES**

Lista mínima, e só ela:

1. **`campoEmEdicao`:** "versao" pendente só quando o rascunho difere de
   `versaoAtual?.conteudo`. Fecha o achado 1 (ação primária travada, importação
   travada, versão impressa duas vezes).
2. **A linha do trilho** passa a falar da opção selecionada.
3. **`IntercambioTrabalhoView`:** as duas ações viram `Pilula` e passam a
   obedecer à lei do bloqueio da folha, sem `.disabled()`.

Feitas as três, Design e Simplicidade chegam a 9 e Componentes acompanha; o
Movimento já está lá.

### Dívida nomeada para o RUMO

- **As duas já sabidas.** (a) Em AX5, documento **com versão da IA** sangrando
  pelos dois lados em `ConteudoTrabalhoView`, pré-existente — **não reproduzi**:
  minha versão é prosa corrida, sem bloco de código nem tabela, e em AX5 nada
  sangrou, nem no cartão da versão (`g4-v18-19`, quatro paradas da rolagem em AX5); a dívida continua nomeada mas sem prova minha.
  (b) O teclado cobrindo a ação primária depois do pedido — não exercitado,
  o teclado de hardware do simulador não sobe o teclado da tela.
- **`Pilula` desabilitada continua quebrada no componente** (`fundo = .clear`,
  `tinta = tintaMorta`): a armadilha que virou 1,53:1 segue armada para a
  próxima tela que chamar `.disabled()` numa `Pilula`.
- **Tocar uma pílula do trilho cancela em silêncio uma preparação em curso.**
  `trilhoDoApoio` chama `aplicar(o) { $0.cancelarPedido(); $0.apoio = a }`
  (`TrabalhoView:235`), sem passar pelo guarda `preparacaoEmCurso` que a própria
  folha aplica a todo o resto. A recuperação existe e é visível depois ("A
  preparação anterior foi cancelada. O pedido continua disponível." +
  "Retomar esse pedido"), por isso é dívida e não bloqueio. **Leitura de código;
  não exercitado ao vivo** (sem conta Grok).
- **O instante sem seleção** na troca do trilho (~0,2 s com as duas pílulas em
  cinza médio).
- **Duas ou três cápsulas carvão por rolagem** e nenhuma marca de etapa: o ciclo
  não se mostra como ciclo. É o passo estrutural que falta para a folha deixar
  de ter forma de formulário.
- **`confirmationDialog`** perdendo o título e chegando como cartão do sistema
  sobre a folha.
- **`Pilula` mora em `Componentes/` mas depende de `CalendarioTema`** para duas
  das suas fontes.

### Três linhas para o LACO

- A volta trouxe o Trabalho para a família — `Pilula`, `CabecalhoDeFolha`,
  `.cartao` e `.rotulo` são os mesmos da ficha do Calendário, `AcaoTrabalhoStyle`
  morreu, e a folha vazia mede duas telas com cinco disclosures em vez de três
  telas com oito.
- O movimento passou: cinco chamadas, todas pela lei, e sob Reduzir Movimento a
  gravação produziu 16 quadros contra 253 — o corte é seco, sem um único quadro
  intermediário.
- Não passa ainda porque a folha mente sobre si mesma no caminho mais ordinário
  (diz que há uma edição pendente que não existe e trava a ação primária, mesmo
  depois de reiniciar o aparelho), a linha do trilho explica a opção que o autor
  não escolheu, e o bloco "Editar com outras ferramentas" continua sendo
  formulário cru do sistema com um botão morto pintado igual a um vivo.
