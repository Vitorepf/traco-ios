# Os métodos de journaling e o catálogo — o que já está, o que falta, em que ordem

17/09/2026 · cruzamento de [`JOURNALING.md`](../../../JOURNALING.md) (86 métodos da
família, levantados em 14/09) com [`Metodos.json`](../../../Traco/Modelo/Metodos.json)
(28 métodos no app) e com o código que roteia.

Este documento **não propõe código**. Propõe o que entra, o que não entra, e por
quê — na régua que a trilha Métodos já usa: as [quatro barras](../papeis/pesquisador-metodos.md)
e a [régua da proveniência](regua-da-proveniencia.md).

---

## 1. O estado de hoje, conferido no código

**O catálogo tem 28 métodos.** Os 21 da ADR 04l mais os sete da leva 1 (M3:
Subtração, Coluna da esquerda, Classe de referência, Cinco porquês, Hamming, O
que se vê e o que não se vê, Exame da noite).

**Um método é dado, e agora é dado até o fim.** A [curadoria da M14](a-curadoria.md)
fechou dizendo que discutir 32 ou 42 era "discutir o andar de cima de uma casa
cujo térreo tem dez cômodos": a análise de bordo conhecia dez formas escritas à
mão e os Atalhos, nove. **Os dois térreos foram consertados desde então**, e vale
registrar porque muda a conta inteira deste documento:

| onde | antes | hoje |
|---|---|---|
| Modelo do aparelho | `enum GestoDeBordo` com dez casos | `esquema()` e `instrucoesDoCatalogo` gerados do catálogo — `AnaliseDeBordo.swift:23-30`, ADR 06g |
| Siri e Atalhos | `enum GestoEscolha` com nove casos | `FormaEntity`/`FormaQuery` sobre `Catalogo.todos`, e pega até o método da pasta do autor — `Intencoes.swift:252-273` |
| Roteamento remoto | — | o prompt lista o catálogo inteiro — `AnaliseRemota.swift:18-21` |
| Roteamento local | — | percorre `Catalogo.todos` pela regex de `roteamento` — `AnaliseLocal.swift:282-289` |
| Perfil | — | `Catalogo.todos`, com a contagem e o que a pasta do autor recusou — `PerfilView.swift:345-384` |

Ou seja: **hoje um método novo entra nas cinco portas sem uma linha de Swift** —
um objeto no `Metodos.json`, ou um arquivo em `Documents/Traço/metodos/*.json`
(`Metodo.swift:298-326`).

**A única superfície que cresce com o catálogo é uma linha de menu.** `FiltroNotas.allCases`
monta o menu de filtro das Notas a partir do campo `filtro` de cada método
(`Gesto.swift:102-107`): 27 dos 28 têm um, e com a Trancadas o menu tem 28 linhas.
**Um método com `"filtro": null` custa zero de tela.** No momento de escrever nada
muda com o tamanho do catálogo: o autor não escolhe entre 28, ele escreve e o
roteador devolve **uma** forma, com "Deixar como nota" ao lado.

**A parede que decide metade desta família: a guarda de escrita pessoal.**
`AnaliseLocal.eEscritaPessoal` (ADR 06h/06i, `AnaliseLocal.swift:236-248`) lê cinco
léxicos — o sentimento no autor, o juízo sobre si, o funcionamento negado, a
confissão de conduta, a omissão. Quando qualquer um acende, a nota tem **uma porta
só**: Expressiva acima de 120 caracteres (`tetoDoDesabafo`), silêncio abaixo. Nenhum
método veste. Está travado em teste (`EscritaPessoalTests.swift:483-531`), e a guarda
mora em código **de propósito**, porque a pasta do autor reescreve o catálogo e não
pode afrouxar a proteção.

Consequência para tudo que vem abaixo: **um método de journaling cujo gatilho é o
autor falando do que sentiu não é roteável.** Não é questão de mérito; é a
arquitetura. Isso elimina, antes de qualquer discussão, o benefit finding, a carta
de autocompaixão, a carta não enviada e o affect labeling **como métodos do
catálogo** — e os empurra para onde eles de fato cabem, que é o fecho da Expressiva.

**E há 14 métodos aprovados esperando na fila.** A trilha Métodos produziu, entre
as voltas M4 e M13, quatorze fichas aprovadas que **nunca foram coladas**; o pacote
de execução pronto está em [`leva-3-e-fusao.md`](leva-3-e-fusao.md) (M15, 06/09),
com o JSON, os consertos e os dois testes que quebram. Isso importa para a ordem
no fim deste documento: propor o 29º método enquanto quatorze aprovados dormem é
inverter a fila.

---

## 2. Os que já estão (11 dos 86)

| # | método da pesquisa | no app | onde |
|---|---|---|---|
| 4 | Intenção de implementação (Gollwitzer) | **Se–então** | `seEntao`; aviso no aparelho (ADR 02e) e compromisso de 7 dias |
| 8 | Escrita expressiva (Pennebaker) | **Expressiva** | `expressiva`, SPEC §8, `FechoExpressivaView`, `Revisoes.agendarSerie` |
| 9 | Contraste mental / WOOP (Oettingen) | **WOOP** | `woop`, com o obstáculo INTERNO cobrado pela sábia |
| 33 | Descarte físico (Briñol 2013) | **Queimar** | SPEC §8; `Nota.queimada` |
| 36 | Pré-mortem (Klein) | **Pré-mortem** | `premortem` |
| 49 | Exame da noite (Sêneca) | **Exame da noite** | `exameDaNoite`, com regra, compromisso de 7 dias e ritual de Recordar |
| 54 | Diário de decisão (Bevelin, Kahneman) | **Decisão** | `decisao`; `espero` → `aconteceu`/`saldo` em `soDepois` |
| 55 | Coluna da esquerda (Argyris) | **Coluna da esquerda** | `colunaEsquerda` |
| 60 | Dia (Ivy Lee) | **Dia** | `dia`; `roubou` em `soDepois` |
| 61 | Destaque (Keller) | **Destaque** | `destaque`, campo `unica`, tela bloqueada e widget |
| 62 | Nota permanente (Luhmann) | **Nota permanente** | `notaPermanente` |

Vale dizer em voz alta: **os outros 17 métodos do catálogo não são journaling.**
Especificação, Destilar, Argumento, Leitura, Feynman, Analogia, Steelman,
Divergência, Primeiros princípios, Prática deliberada, Atualização, Subtração,
Classe de referência, Cinco porquês, Hamming, O que se vê e o que não se vê,
Palavra — são instrumentos de pensar. O catálogo do Traço **não é um app de
diário com métodos**; é uma caixa de ferramentas onde a família do diário ocupa
onze lugares.

## 3. Os parciais — e nenhum deles pede método novo

| # | método | o que já cobre | o que falta |
|---|---|---|---|
| 5 | Monitoramento de progresso de metas (d ≈ 0,40) | `seEntao` tem compromisso de 7 dias; `decisao` tem `espero`/`aconteceu`/`saldo` | **nada que seja método.** O WOOP não tem volta própria, mas encadeia para o Se–então, que tem. O risco declarado na pesquisa ("vira métrica") é exatamente o que §12 recusa |
| 24 | Reescrita narrativa (Wilson) | a série de quatro dias da Expressiva (ADR 02f) | nada |
| 32 | Escrita de metas (Morisano) | `woop` + `spec` | nada |
| 51 | Diário estoico | `exameDaNoite` + `premortem` (a premeditatio) | a "vista de cima" não tem forma, e não achei fonte que a distinga do Pré-mortem |
| 58 | Hansei | `exameDaNoite` | nada |
| 63 | Commonplace book | `leitura` + `notaPermanente` | nada |
| 67 | Idea journal / spark file | `notaPermanente` | a releitura periódica é leitura do corpus, não forma |
| 83 | Diários por domínio | `Dominio` inferido no salvar (ADR 02c) | nada |
| 85 | Áudio | Ditado | nada |
| 70 | Journaling reflexivo genérico | a página em branco e a Expressiva | nada: é difuso por definição, e sem movimento próprio não há ficha possível |

## 4. Os recusados por decisão de spec — e a decisão continua de pé

| # | método | onde a spec recusa |
|---|---|---|
| 3 | Registro de pensamento (TCC) | encosta em diagnóstico (§2, §19.1) |
| 6, 7, 44 | Automonitoramento, ativação comportamental, mood tracking | medem o autor — §19.1 |
| 53 | Daily Questions (Goldsmith) | pontua o dia; mesma família do streak — §12 |
| 69 | Diário pessoal datado | a lista de cartões não é o altar — §3 |
| 78 | Guided / prompt | prompt ocupando o vazio — §3 |
| 79 | Journaling com IA | a IA nunca resume, intitula nem analisa — §2 |
| 80 | Habit tracker / streak | §12 |
| 1, 2, 10, 11, 12, 27 | WET, CPT, IRT, diary card, life review, NET | clínicos; só com profissional |

---

## 5. Os que faltam: um a um, contra as quatro barras

### Entra — e eu defendo: **Três coisas boas** (#13, Seligman 2005)

**O argumento não é a gratidão. É que o catálogo só sabe olhar para o que deu
errado.** Cinco porquês faz a autópsia, Pré-mortem imagina a falha, Inversão
garante a falha, Exame da noite pergunta o que não repetir, Subtração tira o que
sobra. **Zero métodos olham para o que deu certo e perguntam por quê.** Essa
assimetria não é postura estoica do produto: é um buraco, e ele custa a capacidade
de **atribuição** — saber qual foi a sua parte num resultado bom é a mesma perícia
que saber qual foi a sua parte num ruim, e o autor hoje só treina metade.

- **Barra 1 (ciclo):** desenvolver a capacidade. Não é bem-estar: é atribuição.
- **Barra 2 (origem):** Seligman, Steen, Park e Peterson, *Positive Psychology
  Progress*, *American Psychologist* 60(5), 2005 — grau B até alguém ler o artigo
  no original; a ficha dirá isso.
- **Barra 3 (não duplica):** nenhum método do catálogo tem campo de causa sobre
  resultado bom. O `saldo` da Decisão julga uma decisão registrada antes, não o
  dia.
- **Barra 4 (evidência honesta):** efeito medido sobre afeto com uma semana de
  prática e seguimento de seis meses, em amostra de voluntários na internet;
  meta-análises da família de gratidão dão g ≈ 0,22 e avisam que quase todo estudo
  dura uma ou duas semanas. **Ninguém mediu no formato do Traço.**

**Como entra sem tela nova:** dois campos, no molde achatado que a Coluna da
esquerda já usa —

- `boas` · "As três coisas que deram certo hoje (uma por linha)"
- `minhaParte` · "Por que cada uma aconteceu, e qual foi a minha parte"

`roteamento` em torno de "deu certo hoje", "foi um bom dia", "três coisas";
encadeamento natural para o `dia` de amanhã. **O segundo campo é o método** — sem
ele isto vira lista de gratidão, que é o #14, e o #14 não entra (abaixo).

**O que pesa contra, e é do dono:** é prática diária, e a `aplicabilidade` da
Expressiva diz "não serve como diário diário". Um método de todo dia é a porta pela
qual o diário datado (#69) volta pela janela. **A defesa:** o Dia já é diário e não
virou altar, porque o Traço não conta quantos dias seguidos. A linha que não se
cruza não é a frequência; é o placar.

### Em observação — bons, e ainda assim não agora

| # | método | por que segura | o que destravaria |
|---|---|---|---|
| 15 | **Autodistanciamento** (Kross e Ayduk) | é uma instrução ("escreva na terceira pessoa"), não uma anatomia de campos. Tecnicamente **passaria** a guarda de escrita pessoal — escrever "ele ficou irritado" não aciona nenhum dos cinco léxicos, que são todos de primeira pessoa —, e isso é mais curiosidade do que argumento | virar uma **lente**, não um método: o esquema já tem `funcao: "lente"`, e nenhum método do catálogo a usa hoje |
| 22 | **Reflexão diária de aprendizado** (Di Stefano e Gino 2014) | a melhor evidência ★★ da família para o ciclo de trabalho (+23% num treinamento de call center), mas o movimento fica espremido entre o `exameDaNoite` (a volta moral), a `praticaDeliberada` (o pedaço que falha) e a `notaPermanente` (a ideia nas suas palavras) | achar o movimento que **só ele** faz. Se for "o que eu aprendi fazendo, sem ser falha nem ideia", há ficha; se não for, é barra 3 |
| 26 | **Worry postponement** (Borkovec) | movimento próprio — anotar e **adiar**, não resolver — e o Traço tem os dois mecanismos (compromisso e aviso). Mas o gatilho é o autor preocupado, e aí a guarda acende | a resposta à pergunta 1 do dono (abaixo). Se o fecho ganhar uma porta, este método ganha um lugar |
| 19 | **Afirmação de valores** (Steele, Cohen) | replicação mista declarada na própria literatura, e o terreno vizinho já tem ficha (`regraQueEuFaco`) que ainda nem foi colada | a leva 3 mesclar, e depois ver o que sobra |
| 25 | **Perdão por escrito (REACH)** | depende da `reparacao`, que é ficha e não está no app | a leva 3 |

### Não entram, e o motivo é curto

| # | método | motivo |
|---|---|---|
| 14 | Diário de gratidão | **barra 3, é o irmão fraco do #13.** Lista sem campo de causa; a própria pesquisa registra saturação |
| 74 | Five Minute Journal | empacota #13 e #14 num formulário por horário — é o prompt no vazio (§3) |
| 37, 38, 39 | Contar gentilezas, savoring, diário de forças | **C2 (irmão):** mesmo movimento do #13 em versão mais fraca. Um carrega a família |
| 18 | Best possible self | **barra 3, é campo:** é o `resultado` do WOOP — "o melhor desfecho" |
| 21 | Pendências antes de dormir (Scullin) | **barra 3, é o Dia** na outra ponta do dia. O que ele pede já existe e não é método: a **âncora da noite** (`Ancora.noite`, hora configurável no Perfil, `PerfilView.swift:827`) apontando para o Dia de amanhã |
| 23 | After Action Review | **barra 3, duas vezes:** `decisao` (esperado × ocorrido) + `cincoPorques` (por quê) |
| 16, 17, 34, 48 | Benefit finding, autocompaixão, affect labeling, carta não enviada | **a guarda.** Todos disparam no autor falando do que sentiu ou do que fez; nenhum é roteável. Os dois primeiros reaparecem na seção 6, que é onde eles servem. A carta não enviada ainda esbarra na Coluna da esquerda |
| 29 | Self-authoring | programa de três cadernos; **barra 4 (orçamento)** — a M10 já rejeitou a Esteira por quinze campos, e o argumento é o mesmo |
| 30, 65 | Work diary, done list | **barra 3**, é o Dia; e contar o feito é o `oQueSeRepetiu`, que é ficha |
| 31 | Carta de gratidão | pede entrega a outra pessoa; o Traço não envia nada, e não deve |
| 41 | Diário de sonhos | **barra 1:** não serve nenhum dos dois ciclos |
| 50 | Exame de consciência inaciano | **barra 3**, é o `exameDaNoite` |
| 64 | Revisão semanal (Allen) | mesma conclusão da [`rejeitado-revisaoAnual`](rejeitado-revisaoAnual.md): varrer o que está aberto é **leitura do corpus**, não escrita. Pedido de app, não método |
| 71, 72 | Morning pages, free writing | **barra 3:** a página em branco do Traço já é isso. O que as distingue é a cota (três páginas, dez minutos), que é o streak com outro nome |
| 73 | Escrita com apagamento | é o Queimar sem separar a linha de sentido — a pesquisa já registra a diferença |
| 75, 76, 77 | One line a day, bullet journal, interstitial | formato, não movimento |
| 42, 43, 46, 47, 52, 56, 57, 59, 66, 68, 81, 82, 84, 86 | Interactive journaling, poesia, journal therapy, Intensive Journal, 4º/10º passo, ciclos reflexivos, parallel chart, retrospectiva, time log, lab notebook, kakeibo, training log, legacy letter, shadow work | programa, formulário, medição do autor ou sem evidência nenhuma. Dois já têm ficha: [carta ao eu do futuro](rejeitado-cartaAoEuDoFuturo.md) e [Drucker](rejeitado-revisaoAnual.md) |
| 45 | Reflexão antes do app (One Sec) | não é método do catálogo; é outra superfície (Tempo de Uso / Atalhos). Fora do escopo desta leitura |

---

## 6. O que não vira método: três perguntas e dois pedidos de app

A pesquisa termina com cinco perguntas abertas. Três delas se resolvem aqui, e
nenhuma com um método novo.

**Pergunta 1 — o autor que sai do fecho pior do que entrou.** É o buraco mais
sério da família inteira, e a literatura tem dois candidatos, os dois recusados
acima *como métodos* justamente porque a guarda os manda para a Expressiva — que
é exatamente onde eles deveriam estar:

- **Benefit finding** (#16, King e Miner 2000): a versão da escrita expressiva que
  a literatura descreve **sem a piora imediata**. Caberia como uma linha no fecho
  do dia 4, ao lado das quatro linhas de sentido.
- **Autocompaixão** (#17, Neff, Leary 2007): a evidência mais direta sobre humor
  logo depois de escrever.

**É decisão do dono, e toca a superfície mais protegida do app.** Registro os dois
com a evidência, não proponho a mudança.

**Pergunta 2 — gratidão.** Respondida na seção 5: entra a **causa** (#13), não a
**lista** (#14). Se o dono achar que qualquer prática diária abre a porta do diário
datado, o corte é do lado dele, e é defensável.

**Pergunta 5 — uma sessão avulsa.** A literatura tem um caso que só existe avulso:
**escrita antes da prova** (#20, Ramirez e Beilock 2011) — dez minutos sobre a
ansiedade, imediatamente antes de uma prova ou apresentação. Uma série de quatro
dias não serve a isso. É argumento a favor da avulsa; não resolve a pergunta.

**Dois pedidos de app, os dois já conhecidos:**

1. **A leitura do corpus** (Parte III.4 de [`achados-catalogo.md`](achados-catalogo.md)).
   Quatro métodos da família pedem a mesma coisa: a revisão semanal (#64) quer ver
   o que está aberto, a revisão anual quer julgar o passado, a Classe de referência
   quer os casos parecidos, o `oQueSeRepetiu` quer contar. **Quatro pedidos, uma
   função.**
2. **A âncora da noite apontando para o Dia de amanhã** — o que o #21 pede, com
   mecanismo que já existe.

---

## 7. A ordem sugerida, e por quê

**1. Mesclar a leva 3** ([`leva-3-e-fusao.md`](leva-3-e-fusao.md), pronto desde
06/09: cinco passos, 14 métodos, a fusão da Inversão no Pré-mortem, dois testes
com número de linha). **Primeiro porque está pronto e porque a régua da M14 é
"trocar, não acrescentar"** — e essa régua não faz sentido enquanto a troca já
decidida não aconteceu. Dois dos "em observação" desta leitura (#19, #25) dependem
de fichas que estão nesse pacote.

**2. Decidir a pergunta 1 — a saída piorada.** É a única coisa nesta leitura que
não é conforto de catálogo: o app hoje **cala** para quem sai do fecho pior, e a
literatura diz que sair pior é o caso comum, não a exceção. Vem antes de qualquer
método novo porque é a diferença entre um limite conhecido e um limite tratado.

**3. Três coisas boas** (#13), com a ficha completa e o `filtro` decidido. Vem
depois de 1 porque o catálogo precisa estar no tamanho final antes de crescer, e
depois de 2 porque é o método mais próximo do terreno pessoal e a resposta da 2
pode mudar como ele se comporta ali.

**4. A leitura do corpus** (III.4). É a função que destrava mais métodos por
unidade de trabalho — quatro pedidos numa —, e nenhum deles é desta família por
acaso: journaling que não relê é diário.

**5. A âncora da noite → o Dia de amanhã.** Barato, mecanismo existente, fecha o
#21 sem método novo.

**Fora da ordem, porque não é trabalho: a régua que este cruzamento confirmou.**
Dos 86 métodos da família, 11 já estão, 10 são parciais e já servidos, 15 são
recusas de spec ou clínicos, **1 entra** e 5 ficam em observação. Os 44 restantes
morrem na duplicação ou no formato. A pesquisa de 14/09 já tinha escrito a frase certa e ela vale como
conclusão: *o inventário de pesquisa não é fila automática de implementação* (§17.2).
