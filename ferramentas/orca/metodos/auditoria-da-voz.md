# Auditoria da voz do app

Trilha Métodos · volta M11 · 06/09/2026 · a missão nova.

O Traço fala com o autor em dezenas de lugares. Esta auditoria procura, com a
régua da trilha, três doenças na **voz do app** — não no catálogo:

- **(a) afirmar um fato** sobre o mundo ou sobre as pessoas, na própria voz, sem
  fonte;
- **(b) alegar eficácia**, sua ou de um método;
- **(c) dar a resposta do autor** em vez de forma, informação ou pergunta — a
  violação da fronteira em si.

## Como varri, e o que isso não cobre

Li o código em `main` (que já tem a volta 16). Extraí toda cadeia de texto que
chega ao autor — `Text(`, `Label(`, `Button(`, `accessibilityLabel/Hint`,
`navigationTitle`, `mostrarToast`, `Vazio(`, `conteudo.title` das notificações —
dos **149 arquivos Swift** do app e do widget, e depois li à mão as telas de
maior tráfego: Página e cartão da análise, Lente, Recordar, Perfil, Padrões,
estados vazios, avisos e notificações.

**O que isto não cobre:** (1) texto que a IA gera em tempo de execução — auditei
os **contratos** que o governam, não as saídas; (2) cinco voltas estão editando
views agora (Página/Caderno, Trabalho, ditado, widgets, Markdown), então uma
frase pode ter mudado depois que eu li — marco abaixo quais achados caem em
arquivo em obra; (3) não abri simulador: é leitura de código.

---

# Os achados

## 1. «ele aprende com você» — doença (b)

**Onde:** `Traco/Pagina/CartaoAnaliseView.swift:35`, na dica de acessibilidade
dos botões *serviu / não serviu* do cartão da sábia. **Arquivo em obra pela volta
da Página — este achado precisa ir para quem está lá dentro.**

**Hoje:**
> "Diz ao Traço se esta pergunta valeu — ele aprende com você"

**Por que cai:** alegação de eficácia do próprio app. Fui ver o que acontece de
fato (`Traco/Modelo/Degraus.swift:26`): o sinal entra numa janela de **duas**
respostas por forma — duas seguidas "não serviu" descem um degrau, duas "serviu"
sobem um, limitado a 0–4. Isso é um contador com memória de dois, e é honesto;
"aprende com você" descreve outra coisa, maior e vaga.

**Corrigido:**
> "Diz ao Traço se esta pergunta valeu — duas respostas iguais seguidas mudam o
> que ele cobra nesta forma"

**Por que a correção é melhor que a frase de hoje, e não só mais honesta:** ela
dá ao autor a razão de responder. "Aprende com você" não diz o que fazer com o
botão; "duas seguidas mudam o que ele cobra" diz — e transforma o sinal em
instrumento.

## 2. «O que o Traço aprendeu de você» — doença (b), e a mais visível

**Onde:** `Traco/Perfil/PerfilView.swift:159`, título de seção do Perfil.

**Hoje:**
> "O que o Traço aprendeu de você"

**Por que cai:** o que aparece **debaixo desse título** é, literalmente
(`Traco/Modelo/Sinais.swift:110-117`):

> "12 sinais desde 3 de setembro."

Mais a linha dos degraus por forma. É uma **contagem**, e o título a chama de
aprendizado. O `VISAO-PRODUTO` é explícito sobre isto: *"O modelo deve distinguir
observação, relato e hipótese"* — e uma contagem é observação. Chamá-la de
aprendizado é subir um degrau que ninguém mediu.

**Corrigido:**
> "O que o Traço contou de você"

Ou, se o dono quiser a linha mais longa e mais clara:
> "O que o Traço registrou — contagem, não conclusão"

**Nota:** o parágrafo logo abaixo, na mesma tela, é exemplar e não deve mudar:
*"Você soltou três vezes seguidas: X. Por isso o Traço passou a sugerir em vez de
vestir. Abrir uma por vontade própria devolve o vestir."* — fato, regra e como
desfazer. É esse o padrão da casa; o título é que destoa dele.

## 3. «muleta» como rótulo da Lente — doença (a), com ressalva

**Onde:** `Traco/Analise/Lente.swift:33-38` (a lista) e a folha da Lente.
**Confiança menor que os dois de cima, e digo por quê.**

**Hoje:** a Lente classifica como **muletas** uma lista fechada que inclui "acho
que", "um pouco", "bastante", "na verdade", "meio que".

**Por que pode cair:** chamar uma palavra de muleta afirma qual é a função dela
naquela frase — e uma lista de palavras não sabe isso. "Acho que" é muleta num
lugar e é a marca honesta de incerteza em outro; o catálogo inteiro tem métodos
que pedem exatamente esse hedge (a Atualização pede um número justamente porque
"acho que" é vago; a Inversão diz "costuma ser", e a régua da trilha manda
temperar). O app aponta como defeito o que ele mesmo ensina a fazer.

**A ressalva, que é forte:** a tela já diz *"Muletas, frases feitas, passivas e
adjetivos repetidos. **Só aponta.**"*, a contagem é verdadeira, e a tradição
editorial (iA Writer, Hemingway) usa esse vocabulário há décadas — é grau D
declarável. Se o dono achar que "só aponta" basta, este achado morre, e eu aceito.

**Corrigido, se ele quiser mexer:** trocar o rótulo da categoria de "Muletas"
para **"Repetidas"** ou **"Palavras de apoio"**, e manter tudo o mais. Custo: uma
palavra. Ganho: a Lente conta, e quem julga é o autor — que é o que a própria
tela promete.

## 4. «Falta o obstáculo. O que, em você, costuma atrapalhar isto?» — borderline (a)

**Onde:** `Traco/Analise/AnaliseLocal.swift:16` (`avisoOettingen`).

A primeira metade é fato verificável sobre o texto (não há obstáculo interno
escrito). A segunda contém um **"costuma"** que atribui ao autor um hábito que o
app não observou. É o mesmo verbo que a régua manda usar para temperar — e aqui
ele tempera na direção errada: em vez de suavizar uma afirmação do app, ele
afirma algo sobre a pessoa.

**Corrigido:** *"Falta o obstáculo. O que, em você, pode atrapalhar isto — não o
relógio, não os outros?"* — troca "costuma" por "pode" e alinha com a pergunta do
WOOP, que já tem esse recorte no catálogo.

**Confiança:** baixa. É uma palavra, e o método do WOOP existe justamente porque
a pessoa erra o obstáculo. Registro para o dono decidir; não defendo com força.

---

# Varridos e limpos

Estes eu li inteiros procurando as três doenças e **não achei nenhuma**. Vale
tanto quanto achado, e alguns são exemplares.

| onde | veredito |
|---|---|
| `AnaliseLocal` — os outros quatro avisos | limpos. "A frase aqui é sua. O Traço não escreve." é a fronteira dita em oito palavras |
| `CartaoAnaliseView` (fora do achado 1) | limpo. "As suas palavras, com forma. Nenhuma mudou." e "A resposta vem aqui, nunca na nota" |
| `PaginaView` | limpo. "Classifica o que você escreveu. Não escreve na nota." · "Só aponta." · "colar é gesto seu" |
| `LenteView` (fora do achado 3) | limpo. A recusa é factual: "esse trecho não está no seu texto." |
| `RecordarView` e `Prova` | limpos. "A escada não muda." · "Abre a seguinte. Sem contagem." — o app diz o que faz, não o que você é |
| `Vazio` (estados vazios) | limpos, e minúsculos: "nada aqui ainda." · "nenhuma trancada." |
| `FechoExpressivaView` | limpo. "Escrita encerrada." · Selar / Queimar. Nenhum juízo sobre o que foi escrito |
| `PadroesView` | limpo, e é o melhor texto do app: **"Dois períodos, lado a lado. Sem nota, sem seta: quem lê é você."** |
| Notificações (`Revisoes`) | limpas por construção: **`body = ""` em todas**. O título é uma palavra fixa ou o texto do próprio autor. Uma notificação sem corpo é a fronteira aplicada onde ninguém olha |
| `TracoWidget` | limpo. Só o texto do autor, a hora e "sem dados · abra o Traço" |
| `PerfilView` (fora do achado 2) | limpo, e detalhado: "Notas trancadas e expressivas jamais vão à rede." · "o Traço só escreve, nunca lê de volta" |
| Imperativos que achei (4) | todos legítimos: "Escreva de memória primeiro", "Escreva [[o título de outra nota]]" — são **forma**, ensinam a operar o app, não respondem pelo autor |

## Os contratos que impedem a doença (c) — e funcionam

A violação mais grave — o app dar a resposta do autor — é a que está **melhor
defendida**, e não por sorte: está escrita em código.

- **`AnaliseRemota` e `AnaliseDeBordo`**: contrato fechado. A IA devolve um
  rótulo de lista fixa, nunca texto. *"Qualquer outra chave, texto livre ou
  explicação = resposta inválida."*
- **`AnaliseLocal.avisos`**: um dicionário fechado é *"a ÚNICA porta entre um
  rótulo da IA e uma frase na tela"*. Rótulo fora da lista = silêncio.
- **`Sabia.parseContraparte`** (`Sabia.swift:326`): resposta que começa em
  *"você deve / faça / escreva / tente / comece / pare de / precisa / deve"* é
  **descartada**. É a doença (c) barrada por regex, e eu não sabia que existia.
- **`Sabia.sistemaCalibrar`**: *"PERGUNTAS, nunca vereditos. Proibido dar nota,
  medir acerto, elogiar, diagnosticar ou aconselhar. Quem conclui sobre o próprio
  juízo é ela."* — e a pergunta só passa se citar um fragmento literal do que o
  autor escreveu.
- **`TrabalhoView`**: três frases que negam explicitamente o que esta auditoria
  caça — *"Não é o app avaliando você, nem prova de que você aprendeu"* ·
  *"não avalia você, não corrige o texto e não prova aprendizagem"* ·
  *"Delegar não exige aprender a executar tudo"*.

---

# A conclusão que a varredura dá

**A voz do app está em bom estado, e as doenças se concentram num lugar só: onde
o app fala DE SI MESMO.**

Os dois achados firmes são as duas vezes em que o Traço descreve a própria
capacidade — "aprende com você", "aprendeu de você". Nas centenas de frases em
que ele fala **do autor** ou **do que ele mesmo faz**, o padrão é rigoroso: diz o
fato, diz a regra, diz como desfazer, e devolve a decisão.

Faz sentido: a fronteira foi pensada contra o risco de a IA responder pelo autor,
e esse risco está coberto por contrato em quatro lugares. **O ponto cego é o
marketing de si** — a frase simpática sobre o que o app faz, escrita por quem
está orgulhoso do que construiu, num lugar onde ninguém procura fonte.

É a mesma doença do `avisoWood` (M5) e das seis frases de `movimento` (M8), num
terceiro disfarce. Nas três vezes, a correção não perdeu nada: ficou mais curta,
mais concreta e mais útil.

## O que eu faria na próxima rodada desta missão

1. **As saídas da IA, não só os contratos.** Auditei o que o código permite; não
   auditei uma resposta real da sábia. Com um punhado de saídas gravadas dá para
   ver se o contrato aperta na prática — e é onde a doença (c) apareceria.
2. **Os textos do Trabalho e do Calendário**, que varri por palavra-chave mas não
   li linha a linha — e o Trabalho está em obra agora.
3. **As frases do `design-router` e da ESTEIRA**, que o autor lê como dono do
   processo e não como usuário. A régua vale para elas também.
