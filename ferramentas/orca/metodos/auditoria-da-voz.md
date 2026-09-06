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

---
---

# Segunda varredura (M12): pelo padrão, não pela tela

A primeira passada foi por tela e achou duas frases. Esta foi **pelo padrão que a
primeira revelou**: toda frase em que o Traço descreve a própria capacidade —
rótulo de seção, texto de ajuda, estado vazio, nome de botão, descrição de
Atalho, galeria do widget, notificação.

**O que varri:** as cadeias que chegam ao autor nos 149 arquivos do app e do
widget, filtradas por *o app como sujeito* (o Traço, o app, ele) ou por verbo de
capacidade (aprende, entende, guarda, protege, sugere, calcula, decide,
reconhece, analisa, garante, sincroniza, ajuda, adapta…). Vinte e seis frases
casaram. **Fui ao código conferir cada uma que faz promessa verificável.**

Não há **onboarding** nem **texto de loja** no repositório. Se existirem fora
dele, são a superfície em que um app mais promete de si, e ninguém auditou.

## Achado 5 — a frase que promete MENOS do que o app faz

**Onde:** `Traco/Perfil/PerfilView.swift:209`, no texto de ajuda da seção
Métodos. **É o achado raro que o dono pediu para eu procurar.**

**Hoje:**
> "Cada método é um arquivo. Os seus vivem em Arquivos › Traço › metodos […] **O
> app lê ao abrir.**"

**O que o código faz:** `Sessao.recolherEntrada` chama `Catalogo.recarregar()`
sempre que aparece método novo na pasta — e ela é chamada em **três** lugares
(`PaginaView.swift:118, 198, 636`): no arranque, **a cada volta à cena ativa**
(`scenePhase == .active`) e na rota `anotar`. O comentário do próprio método diz:
*"Chamado no arranque e ao voltar à cena."*

**Por que é achado:** o autor que largar um método novo na pasta com o app aberto
lê "lê ao abrir" e conclui que precisa fechar e reabrir o Traço. Não precisa:
basta sair do app e voltar. **A frase custa ao autor um passo que o app não pede.**

**Corrigido:**
> "O app lê ao abrir — e toda vez que você volta para ele."

## Achado 6 — o app fala em primeira pessoa, contra a própria regra

**Onde:** `Traco/Analise/../Calendario/CalendarioSistema.swift:77`, em
`estadoEmPalavras`, que o Perfil mostra na linha do calendário.

**Hoje:**
> "ainda não **perguntei**. Abra o Calendário e **eu peço**."

**Por que cai:** o app vira interlocutor com um EU — e a regra contra isso está
escrita no próprio código, em `PadroesView.swift`:

> "'Li' dava um EU à IA — e o app não é interlocutor."

Não é preciosismo: um app que diz "eu peço" convida o autor a responder a
alguém, e não há ninguém. As outras três linhas da mesma função estão certas e
mostram o padrão — *"o iOS deu só escrita, e o Traço não escreve."*

**Corrigido:**
> "o Traço ainda não pediu acesso. Abra o Calendário e ele pede."

## Achado 7 — a galeria do widget promete o aviso sem a condição

**Onde:** `TracoWidget/TracoWidget.swift:463`, descrição do widget "Próximo
compromisso" na galeria. **Arquivo em obra pela volta dos widgets.**

**Hoje:**
> "O que vem a seguir, e a que horas o Traço **te avisa**."

**O que o código faz:** o aviso depende de duas coisas que o próprio app sabe
dizer quando falham — as notificações autorizadas (`CalendarioFicha.swift:145`:
*"Os avisos do Traço estão desligados no iPhone — nada vai tocar."*) e o teto de
64 pendentes do iOS (`CalendarioFicha.swift:164`). A galeria promete sem
condição o que a ficha do compromisso já sabe condicionar.

**E o tratamento:** "te avisa". O app trata o autor por **você** em todo o resto.

**Corrigido:**
> "O que vem a seguir, e a hora do aviso — quando os avisos estão ligados."

---

## Sete promessas que fui conferir no código, e são verdadeiras

Metade do valor desta varredura está aqui: **o app descreve a si mesmo com
precisão quase sempre**, e cada uma destas frases sobreviveu a uma leitura do
código que a implementa.

| frase | onde | o que o código faz |
|---|---|---|
| "o Traço nunca o edita nem o apaga" (compromisso do sistema) | `CalendarioFichaSistema:50` | **verdadeiro**: não há `.save(` nem `.remove(` sobre o `EKEventStore` em lugar nenhum; `CalendarioSistema` só tem `ler` |
| "o Traço lê todos […] e nunca escreve em nenhum" | `PerfilView:427` | **verdadeiro**, mesma verificação |
| "O iPhone guarda 64 avisos e já estão todos ocupados" | `CalendarioFicha:164` | **verdadeiro**, e melhor que isso: `Revisoes.teto = 64` é o teto **do iOS**, e a frase diz de quem é o limite |
| "essa você queimou. ficou a data e o que você entendeu." | `Sessao:1372` | **verdadeiro, linha por linha**: `queimar` sobrescreve o texto com espaços, esvazia, limpa os campos, e apaga versões, marcas, índice, avisos e ações derivadas. Sobrevivem `sentido` e `queimadaEm` — a linha e a data |
| "A ligação é sua; o app só a segue." | `RedeView:93` | **verdadeiro**: `Rede.ligacoes` lê `[[…]]` e o campo "Liga a". As sugestões completam título; quem liga é o autor |
| "Guarda uma frase no Traço sem abrir o app. Vira nota na próxima vez que ele abrir." | `Intencoes:28` | **verdadeiro**, e é a mesma rota do achado 5 — aqui a frase acertou |
| "Classifica o que você escreveu. Não escreve na nota." | `PaginaView:462` | **verdadeiro** por contrato: os dois motores devolvem rótulo de lista fixa |

Estas sete são o material da régua da voz — não porque sejam bonitas, mas porque
**cada uma sobrevive a alguém abrir o arquivo.**

## O que a segunda varredura confirma

O ponto cego é estreito e tem forma: **o app erra quando descreve a própria
capacidade em abstrato** ("aprende com você", "aprendeu de você") ou **quando
descreve o que faz sem a condição em que deixa de fazer** (o widget). Acerta
sempre que descreve uma operação concreta — o que grava, o que lê, o que apaga,
de quem é o limite.

A regra prática que sai daí está na régua: **se a frase tem o app como sujeito de
um verbo, abra a função antes de escrevê-la.** Foi o que transformou o achado 1
da M11 (o contador com memória de dois) e o achado 5 desta (as três chamadas de
`recolherEntrada`) de opinião em achado.
