# G3 — revisão da volta M3 (a colagem dos sete métodos)

Branch `Vitorepf/volta-m3-colagem`, commit `32e91f1`. Revisor independente
(Claude Opus 5), simulador iPhone 17 Pro Max `6033B043`, 06/09/2026.
Nada foi editado nem commitado nesta revisão.

**Veredito: CORRIGIR ANTES.** Um achado alto, reproduzido na tela.

---

## 0. O que confirmei do que o implementador declarou

Tudo isto foi refeito por mim, não repetido dele:

| declaração | conferido | resultado |
|---|---|---|
| sete no FIM do `Metodos.json`, sem reescrever bloco de ficha | `git show --stat`, JSON parseado | ✅ índices 21–27, depois da Expressiva (5); os 21 antigos intactos exceto três campos de proveniência |
| 28 ids únicos | parse do JSON | ✅ 28, sem repetição |
| 0 encadeamento apontando para id inexistente | varredura de todos os `para` | ✅ 0 botão morto; a guarda `nenhumEncadeamentoApontaParaMetodoInexistente` cobre `Catalogo.todos`, não só o bundle |
| conserto do `\b` no Se–então | roteamento refeito com frases minhas | ✅ "sempre quebra" e "sempre queria" saíram do Se–então; "sempre que / toda vez / não consigo parar" continuam dele |
| suíte integral 723/125 | `xcodebuild test` no meu UDID, sob `com-trava.sh` | ✅ `Test run with 723 tests in 125 suites passed`, `** TEST SUCCEEDED **` |
| "build sem aviso" | `grep warning:` no log | ⚠️ **4 avisos** (2 únicos), todos em `TracoTests/ConferenciaTrabalhoTests.swift:381`, **pré-existentes** (commit `73b1ebc`). O target do app compila limpo; a frase "build sem aviso" está errada |
| Perfil diz "28 do app", proveniência dos novos abre | fluxo meu no meu simulador + `simctl io screenshot` | ✅ `m3-rev-01-hamming-proveniencia.png` |
| capturas dele (`m3-01`, `m3-02`) | abertas e lidas, não só listadas | ✅ conteúdo real: "28 do app" e o bloco FONTE do Exame da noite. Não são placeholders |
| teste alheio consertado (`ColheitaRestanteTests`) | diff lido, `Volta.devida` lido | ✅ ele **ampliou** a lista permitida (`classeDeReferencia`), não afrouxou a asserção; e o `default` de `Volta.devida:20-22` de fato cobra qualquer `soDepois` em 7 dias, como ele afirma |

---

## 1. A PROTEÇÃO DA ESCRITA PESSOAL — **ACHADO ALTO**

### O que a volta afirma

ADR 2026-09-06e: *"A escrita pessoal é protegida **pela ordem do arquivo**, e
por nada mais"* + a regra permanente *"nenhum método cuja regex mencione
conversa, silêncio, arrependimento ou sentimento entra antes da Expressiva"*.

### O que eu medi

A proteção **não é a ordem**. É a ordem **mais** o portão dos 120 caracteres em
`AnaliseLocal.swift:99`:

```swift
if g == .expressiva, x.count <= 120 { continue }
```

A Expressiva é **pulada** abaixo de 120 caracteres. Como os sete novos vêm
DEPOIS dela, o `continue` os promove a primeiro-a-casar. A regra permanente do
ADR é obedecida pelos sete — e o roubo acontece assim mesmo.

**14 de 14 linhas curtas com vocabulário da Expressiva** (`senti`, `raiva`,
`chorei`, `doeu`, `triste`, `medo`, `pesado`) vão para os métodos novos:

| frase (minha, não dele) | antes | depois |
|---|---|---|
| "Me arrependi e chorei." | silêncio | **exameDaNoite** |
| "Senti raiva e me arrependi na hora." | silêncio | **exameDaNoite** |
| "Doeu. Perdi a paciência com ela." | silêncio | **exameDaNoite** |
| "Triste. Engoli tudo de novo." | silêncio | **colunaEsquerda** |
| "Fiquei calado e senti medo de falar." | silêncio | **colunaEsquerda** |
| "Deixei passar e doeu." | silêncio | **colunaEsquerda** |
| "Estou triste porque não consegui dizer nada." | silêncio | **colunaEsquerda** |
| (+7 outras, todas iguais) | silêncio | novo método |

E **acima** de 120 caracteres a proteção também falha, sempre que o desabafo não
usa uma das dez palavras da regex da Expressiva — que é o desabafo mais comum de
um dia ruim, o factual:

| desabafo longo, sem palavra de sentimento | antes | depois |
|---|---|---|
| "Foi um dia longo e eu fiquei calado a reunião inteira enquanto ele levava o crédito pelo que eu fiz…" (157) | silêncio | **colunaEsquerda** |
| "Engoli o que eu queria dizer. De novo. É sempre assim, eu penso a resposta perfeita três horas depois…" (155) | silêncio | **colunaEsquerda** |
| "Me arrependi. Deitei e fiquei olhando o teto pensando em tudo que eu não devia ter feito hoje…" (155) | silêncio | **exameDaNoite** |
| "Perdi a paciência de novo com a minha mãe no telefone…" (149) | silêncio | **exameDaNoite** |
| "Não devia ter reagido assim na frente do meu filho…" (154) | silêncio | **exameDaNoite** |
| "Deixei passar mais uma vez. Ele falou aquilo na frente de todo mundo e eu ri junto como um idiota…" (161) | silêncio | **colunaEsquerda** |
| "Hoje eu tratei mal quem não merecia…" (151) | silêncio | **exameDaNoite** |
| "Fui injusto com o time inteiro na retrospectiva…" (155) | silêncio | **exameDaNoite** |

Por que o teste dele não pega: `oDesabafoLongoContinuaExpressivo` usa dois
desabafos **carregados** de vocabulário da Expressiva — *"senti uma raiva
enorme, doeu ficar ali… chorei depois no corredor… foi pesado demais"* e
*"senti uma raiva que não passou o dia inteiro, doeu ver a cara deles e chorei
sozinho"*. O teste prova o único caso em que a ordem basta, e leva o nome da
proteção inteira.

### Na tela (o que decide)

Motores desligados (`TRACO_SEM_MODELO=1`), meu simulador, `simctl io screenshot`:

- **`m3-rev-02-desabafo-vestido.png`** — o desabafo factual da reunião chega
  **vestido de COLUNA DA ESQUERDA**, com quatro campos de exercício carimbados
  sobre o texto do autor ("A CONVERSA (COM QUEM, SOBRE O QUÊ)", "O QUE FOI DITO,
  DOS DOIS LADOS", "O QUE EU PENSEI E NÃO DISSE", "O QUE ME IMPEDIU DE DIZER") e
  o chip de domínio TRABALHO. Antes desta volta esta nota ficava em silêncio.
- **`m3-rev-03-curto-emocional.png`** — *"Perdi a paciencia com ela hoje. Me
  arrependi e chorei."* (53 caracteres) chega **vestido de EXAME DA NOITE**, e o
  cartão diz: *"isto é o seu dia pedindo julgamento — dos seus atos."* Quem
  acabou de chorar recebe um exercício de julgamento moral.

Não é sugestão: `Sessao.swift:243-249` chama `usarForma(g, explicita: false)` e
`cartao = .vestida` no caminho automático. A forma se veste sozinha. A
Expressiva, quando ganha, só **sugere** (`cartao = .expressiva`, sem `gesto`) —
os dois caminhos não são simétricos, e o que rouba é o que veste.

### Contra o contrato

AGENTS.md, "Fronteiras que mudam decisões": *"Guardas locais de escrita pessoal,
expressiva e Recordar preservam autoria/prática"*. A volta introduz dois métodos
cuja regex é feita de vocabulário de arrependimento e de silêncio em conversa —
o léxico exato do desabafo — e a única guarda existente não cobre nem o texto
curto nem o texto factual.

### O que eu recomendo (não corrigi — não é o meu papel)

Nenhuma das três exige mexer na ordem nem tirar método:

1. **A mais barata e a que fecha o buraco medido:** aplicar o portão dos 120 aos
   métodos que falam de sentimento, não à Expressiva. Hoje o `continue` é uma
   linha; a inversão é outra linha.
2. Ou: subir a Expressiva para antes do laço, com o teto de 120 substituído por
   "casa a regex da Expressiva **e** nenhum método anterior casou".
3. Em qualquer caso, o teste tem de conter **um desabafo sem palavra de
   sentimento** e **um desabafo curto**, senão ele continua provando o caso fácil.

---

## 2. O gatilho inalcançável do Exame da noite — a minha leitura

**Aceito. Não é lista mínima, e não é o que segura esta volta.**

Primeiro, confirmei o alcance do problema em vez de acreditar nele. Gerei uma
frase concreta para **cada ramo** de cada regex dos sete (147 sondas, expandindo
alternâncias e classes) e roteei todas contra o catálogo real:

```
147 sondas -> 146 caem no próprio método
              1 desvia:  «olhando o dia de hoje»  exameDaNoite -> dia
```

O desvio é exatamente o que ele nomeou, e é o **único**. O autorrelato dele
sobre isto está completo e correto.

Por que aceito:

- **O método não nasce parcialmente morto.** `\bolhando o dia de hoje\b` é 1 de
  8 frases de gatilho do Exame da noite. As outras sete disparam — provei em
  tela com "me arrependi", e por sonda com "exame da noite", "passei o dia em
  revista", "não devia ter feito", "perdi a paciência", "hoje eu fiz". Nenhuma
  capacidade fica inalcançável para o autor.
- **A frase engolida é genuinamente ambígua.** *"Olhando o dia de hoje…"* é tão
  Dia quanto Exame, e o Dia é a rota mais velha e mais usada. Perder para ele
  não é um erro de roteamento; é a resolução razoável de um empate.
- **Consertar aqui significaria editar a regex do Dia** — um dos 21, dentro de
  uma volta de colagem. É exatamente o tipo de alargamento de escopo que rouba a
  frase de outro método sem ninguém medir. Volta de roteamento é o lugar certo.
- A fragilidade está dita no commit, no ADR e no EVOLUCAO. A regra da casa
  ("fragilidade dita é honestidade") se aplica.

**O que eu poria na lista mínima no lugar disso**, e vale mais que o conserto:
não existe teste que garanta que uma frase de gatilho **alcança** o método que a
declara. Sem ele, todo método futuro pode nascer com ramos mortos e ninguém
saber. O script que escrevi para esta revisão é a implementação: gerar uma
frase por ramo a partir de `Catalogo.todos` e afirmar que ela roteia para o dono
do ramo. É um teste de dado, sem UI, e cobre os 28 de uma vez. Entrego o
gerador junto com este relatório se o orquestrador quiser.

---

## 3. As três frases de proveniência — **passam**

Conferidas linha a linha contra `regua-da-proveniencia.md` do branch
`Vitorepf/metodos-m1`. As três aplicam o conserto **prescrito pela régua**,
praticamente palavra por palavra, e nenhum método sai do catálogo:

| ficha | o que a régua exigia | o que está no JSON | veredito |
|---|---|---|---|
| **Decisão** | grau real E; dizer "prática atribuída a Kahneman, sem texto dele que a descreva"; o artigo de 2009 é "evidência vizinha, não a origem"; e o DOI ao lado fazia supor grau A | fonte reescrita com as duas frases exatas; **o DOI saiu** | ✅ |
| **Primeiros princípios** | uma frase na **adaptação**: "Aristóteles não propõe este exercício; o Traço toma dele a noção de princípio e monta o resto" | está na `adaptacao`, exatamente, sem tirar `funcao: lente` | ✅ |
| **Inversão** | "discursos, sem transcrição de referência localizada"; e marcar Jacobi como atribuição | "…discursos (1986 em diante), **sem transcrição de referência localizada**, citando **uma frase atribuída** a Carl Jacobi" | ✅ |

Nenhuma das três alega eficácia; nenhuma perde informação; nenhuma sobe o grau.

**Observação, não achado:** a régua manda, na sua lista de bolso, *"Qual é o grau
— A, B, C, D ou E? Escreva-o na ficha, com essas palavras"*. Nenhuma das três
escreve a letra. Mas os **consertos prescritos** pela própria régua também não a
escrevem, e ele seguiu os consertos. Se o dono quiser a letra na ficha, é
decisão nova e vale para os 28, não uma falha desta volta.

**As sete fichas novas também passam a régua**, e com folga — cada uma diz o que
a fonte não contém: Hamming ("é uma palestra… Hamming não afirma que responder à
pergunta melhore o trabalho de alguém"), Cinco porquês (cita Minoura e o BMJ
2017 **contra** o próprio método), Classe de referência ("nada disso mede uma
pessoa usando as próprias lembranças como classe"), Exame da noite ("sem estudo…
nem nada que o Traço possa alegar"). Bastiat e Sêneca com tradução nomeada e
"lida integralmente". Este é o melhor trabalho da volta.

---

## 4. Roteamento sem falso positivo — refeito com as minhas frases

Não usei nenhuma das 74 dele. Escrevi 58 frases próprias (44 de autor real +
14 curtas emocionais) e 147 sondas geradas dos ramos. Método: réplica fiel de
`AnaliseLocal.detectarGesto` em Swift com `NSRegularExpression` (mesma engine do
app), rodada contra o `Metodos.json` de `4d1e80a` e o de `32e91f1`.

**Ganhos reais confirmados** (frases que nasceram sem casa e agora têm método
certo, sem roubar ninguém): Subtração ×2, Classe de referência ×2, Cinco
porquês ×2, Hamming ×2, O que se vê ×2 — todas corretas.

**Conserto do Se–então confirmado:** `"Sempre quebra quando o deploy é sexta"`
saiu de seEntao → cincoPorques; `"Sempre queria ter aprendido violão"` saiu de
seEntao → silêncio. Nada que era do Se–então se perdeu.

**Falsos positivos que eu achei e ele não:**

| severidade | frase | vai para | por quê |
|---|---|---|---|
| **alto** | os 22 desabafos da §1 | colunaEsquerda / exameDaNoite | o portão dos 120 e o léxico estreito da Expressiva |
| médio | "Ele sempre quebra a promessa e eu sempre acredito de novo, é um ciclo velho." | **cincoPorques** | `\bsempre quebra\b` é regex de falha técnica aplicada a uma nota de relação; o "conserto" do Se–então entregou esta frase ao método errado, não ao certo |
| médio | "Estou trabalhando errado nisso, sinto que o esforço não está indo pro lugar certo." | **perguntaHamming** | 82 caracteres com "sinto" — abaixo dos 120, a Expressiva nem é consultada |
| baixo | "Essa tela virou um monstro, complicada demais pra quem chega agora." | **spec** | `\btela\b` do spec (índice 2) come `\bvirou um monstro\b` da Subtração (21). Pré-existente por posição, mas é ramo novo perdendo para ramo velho — a mesma família do §2, e não está nomeado |

O terceiro e o quarto são pequenos. O primeiro não é.

**Efeito colateral não nomeado:** os métodos da pasta do autor (`doAutor`) são
carregados **depois** do bundle (`Catalogo.recarregar`). Eles agora competem
atrás de 28 built-ins em vez de 21 — a chance de um método escrito pelo autor
nunca disparar subiu junto. É consequência da arquitetura, não desta volta, mas
esta volta a agrava e o ADR não a menciona.

---

## 5. A tela

Tudo com `xcrun simctl io <meu UDID> screenshot` (não com a captura do maestro,
que fotografa build velho), app reinstalado da árvore deste commit.

| captura | o que prova |
|---|---|
| `m3-rev-01-hamming-proveniencia.png` | Perfil → Métodos: **"28 do app"**, os sete listados com origem, e **A pergunta de Hamming aberta** com FONTE / FUNÇÃO / O QUE O TRAÇO ADAPTOU. Método novo com proveniência viva na tela |
| `m3-rev-02-desabafo-vestido.png` | o desabafo factual vestido de **Coluna da esquerda** — o achado alto, na tela |
| `m3-rev-03-curto-emocional.png` | a linha curta com "chorei" vestida de **Exame da noite**, com o cartão "isto é o seu dia pedindo julgamento — dos seus atos." |
| `m3-01-vinte-e-oito.png`, `m3-02-proveniencia-exame.png` (dele) | abertos e conferidos: conteúdo real, batem com o que ele declara |

O fluxo `maestro/metodos-m3.yaml` é honesto no que diz de si — o comentário no
topo admite que ele **não** prova roteamento, só a chegada do catálogo à tela.
Eu provei o roteamento na tela por fora, com os motores desligados, e é aí que
o achado apareceu.

**O que eu NÃO consegui capturar, e digo:** a proveniência de um método novo
**dentro da Lente** (o "De onde vem" de `LenteView.swift:83`). Três tentativas
falharam por dois motivos, nenhum deles defeito desta volta: o botão "Lente"
vive na `bottomBar` e o cartão vestido a cobre; e a trava do instrumento
(`com-trava.sh`) ficou ocupada por outro worker durante a janela restante.
O mesmo componente (`LinhasDeProveniencia`) está provado com método novo em
`m3-rev-01` pelo caminho do Perfil, então a capacidade está demonstrada — só
não pela porta da Lente. Não conto isto como achado; conto como prova que falta.

---

## 6. Contrato

| item | veredito |
|---|---|
| ADR 2026-09-06e no **fim** da SPEC | ✅ `SPEC.md:2871`, última seção do arquivo, ocorrência única |
| numeração única (V12=05y, V11=06a, V18=06b, F3b=06c, F4=06d, **M3=06e**, A1=06f) | ✅ `grep -c "ADR 2026-09-06e" SPEC.md` = 1 |
| EVOLUCAO coerente | ✅ e mais honesto que a média: nomeia os seis desvios abertos, os três da M4 e o botão sem destino como voltas próprias |
| teste do `\b` fixando o Se–então | ✅ `oSeEntaoNaoCasaDentroDeOutraPalavra`, com os dois casos que casavam errado **e** os três que sempre foram dele |
| **o ADR diz a verdade sobre a proteção** | ❌ **não.** "protegida pela ordem do arquivo, e por nada mais" é falso: a proteção é ordem **+** o teto de 120. E a regra permanente que o ADR institui ("nenhum método cuja regex mencione conversa, silêncio, arrependimento ou sentimento entra antes da Expressiva") é **obedecida pelos sete** e mesmo assim o roubo acontece. Um contrato que dá confiança falsa é pior que um contrato ausente: o próximo worker vai colar um método novo obedecendo a regra e achando que está seguro |
| "0 desvio em 74 frases" | ⚠️ verdadeiro para a amostra dele, apresentado como propriedade. Nas minhas 58 frases há 22 desvios |
| "build sem aviso" | ⚠️ 4 avisos no target de teste, pré-existentes |

---

## Scorecard (mínimo 9; abaixo disso é CORRIGIR ANTES)

| dimensão | nota | evidência |
|---|---|---|
| **Visão** | **9** | fecha as três faculdades vazias nomeadas (simplificação, direção, consequência) e a linha do EVOLUCAO cresce com lacuna nova declarada. Entra no ciclo de multiplicar a mente: sete instrumentos que o autor não tinha |
| **Contrato** | **7** | ADR única no fim da SPEC, EVOLUCAO coerente, "fora" nomeado item a item — mas a afirmação central sobre a proteção é falsa e a regra permanente que ele institui não protege. §6 |
| **Correção** | **6** | suíte 723/125 verde e `TEST SUCCEEDED` no meu UDID; o `\b` fixado por teste; a guarda de encadeamento correta. Mas o comportamento que a volta declara como sua razão de existir — a proteção da escrita pessoal — está coberto por um teste que só exercita o caso que passa. §1 |
| **Jornada real** | **8** | as duas capturas dele são reais e batem; reproduzi Perfil + proveniência + roteamento no meu simulador. Desconto: a jornada foi andada só no caminho feliz; a nota pessoal, que é a que importa nesta volta, não foi olhada na tela por ele |
| **Design** | **7** | `design-router` **não carregado e não citado**, e a volta despeja copy nova na tela: 7 × 4–5 rótulos de campo, 7 frases de reconhecimento no cartão, 7 blocos de proveniência na Lente e no Perfil. A copy tem defeito de tom conferido na tela: `m3-rev-03` mostra "isto é o seu dia pedindo julgamento — dos seus atos." servido a quem escreveu que chorou. Não dou n/a: a copy é a superfície desta volta |
| **Simplicidade** | **7** | `curva-zero` não citado, e a jornada da escrita mudou: notas que ficavam livres agora chegam vestidas com 4–5 campos. O caminho comum ficou mais barulhento, não menos — medido em 22 de 58 frases minhas. Poder avançado continua encontrável (Perfil → 28 do app) |
| **Movimento** | **n/a** | nenhuma animação, curva, duração ou transição tocada; zero linha em `Tema` e zero em view |
| **Componentes** | **n/a** | nenhum componente criado ou alterado; `LinhasDeProveniencia` e `CamposFormaView` são reusados sem uma linha de diff |
| **Acessibilidade** | **n/a** | zero código de view no diff; as linhas novas são instâncias do componente da volta 16, cuja ordem de leitura, alvo de 44 pt e Dynamic Type já foram provados lá. A volta não muda estrutura, só quantidade |
| **Performance** | **9** | medido: pior caso do roteador (texto que não casa nada, percorre o catálogo inteiro) **3,47 ms → 7,00 ms** por análise, 21 → 28 métodos com 3 regex cada. Roda em `autoTask`, debounced na pausa (`Sessao.swift:376-377`), não por tecla — cabe. A curva é linear no número de métodos e vai pedir atenção antes de 50 |
| **Privacidade e autoria** | **5** | **achado alto.** Escrita pessoal roteada para formas de exercício, reproduzido na tela em `m3-rev-02` e `m3-rev-03`; 22 de 58 frases minhas. Contraria AGENTS.md, "guardas locais de escrita pessoal e expressiva preservam autoria". O selo em si continua íntegro (a Expressiva aceita segue fora da rede, do Retrato, da Trajetória e do Trabalho — conferido em `AnaliseRemota:37`, `Retrato:31`, `AcessoTrabalho:48`): o defeito é que o autor deixa de **chegar** à rota selada |
| **Estado honesto** | **8** | ADR e EVOLUCAO nomeiam o que ficou de fora com precisão rara, inclusive o desvio que ele mesmo achou. Descontos: "build sem aviso" é falso e "0 desvio em 74 frases" é amostra apresentada como propriedade |
| **Complexidade** | **9** | +627 linhas de **dado**, zero linha de código de produção, zero dependência nova. Sete métodos por sete fichas — sem abstração, sem configuração, sem código. É a forma certa desta entrega |
| **Fora do app** | **n/a** | nenhum widget, Intent, Ilha, StandBy, App Group ou `Superficie` tocado |
| **Relato** | **8** | commit e ADR legíveis por quem não abre terminal, com prova colada e escopo fechado. Desconto: a manchete ("0 desvio", "protegida pela ordem") não se sustenta fora da amostra do autor |

**Quatro dimensões abaixo de 9: Correção (6), Design (7), Simplicidade (7),
Contrato (7) — e Privacidade e autoria (5) é o que decide.**

---

## Achados, por severidade

### ALTO — 1 achado, bloqueia

**A1. A escrita pessoal é roteada para métodos novos.** O portão dos 120
caracteres pula a Expressiva e promove `colunaEsquerda` e `exameDaNoite` a
primeiro-a-casar; acima dos 120, o léxico de dez palavras da Expressiva não
cobre o desabafo factual. 22 de 58 frases minhas; 14 de 14 linhas curtas com
palavra de sentimento. Reproduzido na tela: `m3-rev-02`, `m3-rev-03`.
Dono da área: quem colou os sete (a correção é de dado ou de uma linha em
`AnaliseLocal.swift:99` — decisão do orquestrador). §1.

### MÉDIO — 3

**M1. O ADR institui uma regra que não protege.** "Nenhum método cuja regex
mencione conversa, silêncio, arrependimento ou sentimento entra antes da
Expressiva" é obedecida pelos sete e o roubo acontece assim mesmo. O próximo
worker vai confiar nela. A regra precisa citar o teto de 120. §6.

**M2. O teste da proteção prova o caso fácil.** `oDesabafoLongoContinuaExpressivo`
usa dois desabafos saturados de vocabulário da Expressiva. Falta um desabafo
factual (sem palavra de sentimento) e um curto. §1.

**M3. "Ele sempre quebra a promessa…" cai em Cinco porquês.** Nota de relação
entregue a um método de causa raiz de falha técnica. Efeito do conserto do `\b`,
que devolveu a frase — mas ao método errado. §4.

### BAIXO — 4

**B1.** "build sem aviso" é falso: 4 avisos (2 únicos) em
`ConferenciaTrabalhoTests.swift:381`, pré-existentes de `73b1ebc`. Não são desta
volta; a frase é que não pode ficar.

**B2.** "0 desvio em 74 frases" é amostra do próprio autor apresentada como
propriedade do catálogo.

**B3.** `\bvirou um monstro\b` (Subtração, 21) perde para `\btela\b` (spec, 2).
Mesma família do desvio nomeado, não nomeada.

**B4.** Os métodos da pasta do autor agora competem atrás de 28 built-ins em vez
de 21. Consequência de arquitetura agravada por esta volta, não dita no ADR.

### Sem achado

Proveniência das três fichas corrigidas (§3) · proveniência das sete fichas
novas · 28 ids únicos · zero botão morto · guarda de encadeamento sobre
`Catalogo.todos` · conserto do `\b` · o teste alheio consertado sem afrouxar ·
suíte 723/125 · ADR no fim da SPEC com número único · EVOLUCAO coerente ·
as duas capturas dele, conferidas por conteúdo.

---

## Instrumento

Build e `xcodebuild test` no **iPhone 17 Pro Max `6033B043-F436-41F9-B4F8-2D9E67761980`**,
maestro com `--device` do mesmo UDID, tudo sob `ferramentas/orca/com-trava.sh`.
Havia 8 simuladores ligados: nenhum toque por coordenada, nenhum `shutdown`.
O meu simulador já estava ligado quando cheguei — **não o desliguei**, pela regra
de nunca desligar o que não se ligou. O iPhone 17 `1A46B6D3` do dono não foi
tocado. PNGs em `sips -Z 1000`, todos abaixo de 400 KB. Nada editado, nada
commitado.

**Réplica do roteador** (Swift + `NSRegularExpression`, mesma engine do app),
com as frases e as sondas, preservada em `ferramentas/orca/m3-rev-provas/`:

```
rota.swift    réplica de AnaliseLocal.detectarGesto + classificar
frases.txt    44 frases minhas de autor real
frases2.txt   14 linhas curtas com vocabulário da Expressiva
sondas.txt    147 sondas, uma por ramo de regex dos sete novos

# como refazer (não precisa de Xcode nem de simulador):
swift ferramentas/orca/m3-rev-provas/rota.swift Traco/Modelo/Metodos.json \
  < ferramentas/orca/m3-rev-provas/frases2.txt
```

O gerador de sondas está pronto para virar o teste de alcance que proponho
no §2.
