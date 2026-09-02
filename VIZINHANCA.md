# Vizinhança do Traço — os 41 semelhantes

> Mapa de concorrência por EIXO da spec. Nenhum app do mercado tem a proposta do
> Traço, porque a proposta é um cruzamento: o que existe são apps fortes em UM
> dos cinco eixos e cegos nos outros quatro.
> A leitura útil não é quem está perto no geral — é quem já resolveu o eixo que
> ainda vai ser construído aqui.
> Eixos derivados de SPEC.md (§2, §3, §6, §7, §8, §9, §12, §17, §19).
> Verificação: páginas oficiais de produto e App Store, setembro de 2026.
> Plataforma e alegações refletem o que o fabricante publica.
> Apps sem relação com a proposta, mas com mecanismo aproveitável: `REFERENCIAS.md`.

## Contagem

41 apps. Por eixo: método e forma 12 · markdown-arquivo 9 · IA que recusa 9 ·
memória ativa 7 · captura e arquivo 4.

**No melhor caso um app cobre dois eixos. Nenhum cruza os cinco.**

Dois aparecem marcados **⊘ polo invertido**: ocupam o eixo pela ponta contrária,
executando bem a tese oposta. Não são concorrentes fracos — são o contraexemplo
mais útil da lista. A Notion é um terceiro caso, mais ambíguo: o produto ocupa o
eixo do método, e só a IA dele inverte o eixo da recusa.

## Os cinco eixos

| Eixo | Spec | Definição |
|---|---|---|
| **Markdown-arquivo** | §10 · §19.2 | A nota é um arquivo de texto no disco, e a página nunca mostra a marcação. O autor não digita `#` nem cerca. |
| **Método e forma** | §6 · §8 · §17 | O app carrega métodos validados (WOOP, se–então, expressiva) e veste a forma sobre as palavras do autor, sem que ele saiba o nome dela. |
| **IA que recusa** | §2 · §19.4 | A IA nunca insere texto. Lista fechada: rotear, avisar, uma pergunta, recordar, padrões, calar. Algoritmo antes de modelo. |
| **Memória ativa** | §7 | Esconder a nota, escrever de memória, revelar lado a lado. Esquecer dói, e a dor é o treino. |
| **Captura e arquivo** | §3 · §16 · FILA | Abrir no cursor sem lista na frente, e capturar um traço de fora do app — widget, App Intent, folha de compartilhamento, Spotlight. Buscar serve para agir, não para lembrar. |

## Os cinco vizinhos que importam

Ordenados por quanto do Traço já resolveram, não por qualidade de produto.

1. **iA Writer** — Dois eixos de quatro, e os dois mais difíceis de imitar:
   arquivo de texto no disco e uma posição pública sobre autoria diante da IA.
   Falta método e falta memória.
2. **Rescript Journal** — Implementa o §8 quase à risca, e então entrega o texto
   da sua pior noite para a IA analisar. É o vizinho mais próximo e o
   contraexemplo mais útil, no mesmo app.
3. **Edda** — Alguém já provou que dá para vender verificação determinística
   como poder, sem modelo dentro. É a doutrina algoritmo-primeiro do §19.4 num
   mercado diferente.
4. **Bear** — O único que veste a marcação ao vivo com acabamento de app pago.
   Mostra o teto do que se consegue sem esconder o marcador — e onde o Traço
   começa a ser outra coisa.
5. **Reflection** — A única IA comercial cuja unidade de saída é uma pergunta
   tirada do seu próprio texto. Só que ela não para na pergunta.

---

## Eixo 1 · Markdown-arquivo (§10 · §19.2)

> A nota é um arquivo de texto no disco, e a página nunca mostra a marcação.

#### iA Writer — iOS · macOS · Windows
<https://ia.net/writer>

**Compartilha.** Arquivo `.md` no disco, página escura e mínima. O Authorship
marca o que é seu e escurece o que veio da IA — mesma tese de autoria.

**Diverge.** A página É markdown: o autor digita `#` e cerca. Nenhum método,
nenhuma memória, e a IA fica fora do app (o Authorship só rotula o que você
colou).

#### Bear — iOS · macOS
<https://bear.app>

**Compartilha.** Estiliza a marcação ao vivo enquanto você digita — o parente
mais próximo do vestir a forma do §17. Zero IA escritora.

**Diverge.** Os marcadores continuam à vista, e o autor ainda precisa saber
digitá-los. Banco SQLite, não arquivo. Sem método e sem memória.

#### Obsidian — iOS · desktop
<https://obsidian.md>

**Compartilha.** Pasta de `.md` no disco, local-first de verdade. Plugins trazem
repetição espaçada e modelo local — os quatro eixos existem, em peças soltas.

**Diverge.** Markdown cru na cara, e montar os eixos é trabalho do usuário: cada
plugin exige lembrar de um recurso, o que o §17 chama de bug.

#### Taio — iOS · macOS
<https://taio.app>

**Compartilha.** Editor markdown sobre sistema de arquivos aberto, CommonMark,
feito por equipe pequena para iOS.

**Diverge.** Ferramenta de power-user: ações em JavaScript, multi-tab,
wikilinks, barra de ferramentas de marcação. É o oposto da página nua.

#### Runestone — iOS
<https://runestone.app>

**Compartilha.** Texto puro, um dev só, compra única, declaradamente sem sinos e
assobios. A disciplina de escopo que o Traço persegue.

**Diverge.** É editor de código com realce de sintaxe. Nenhuma noção de nota,
método ou memória.

#### Craft — iOS · macOS
<https://www.craft.do>

**Compartilha.** O app de notas mais bem acabado do iOS: nativo, rápido, com
motion caro e exportação em Markdown. Prova que dá para ser premium sem virar
Electron.

**Diverge.** Bloco em nuvem, não arquivo no disco — o `.md` é export, não a
verdade. E tem assistente de IA que escreve, resume e traduz dentro do
documento.

#### Evernote — iOS · desktop · web
<https://evernote.com>

**Compartilha.** O antepassado de tudo: capturar qualquer coisa e achar depois.
Inventou o web clipper e a busca dentro de imagem.

**Diverge.** Formato fechado que virou a lição do setor sobre lock-in. Hoje é
suíte com tarefa, calendário e IA — e nada da nota é arquivo seu.

#### Apple Notes — iOS · macOS
<https://www.apple.com/notes/>

**Compartilha.** A âncora de design declarada no §11: é o bloco que a pessoa já
conhece, e a régua do que parece nativo.

**Diverge.** Não é arquivo. E o Apple Intelligence escreve, resume e reescreve
dentro da nota — o oposto exato da regra de ferro.

#### Beaver Notes — desktop
<https://beavernotes.com>

**Compartilha.** Local-first, MIT, e a promessa impressa na home: sem nuvem, sem
IA, sem rastreio.

**Diverge.** Electron no desktop, sem iOS. A recusa é de privacidade, não de
método: nada roteia nem cobra memória.

---

## Eixo 2 · Método e forma (§6 · §8 · §17)

> O app carrega métodos validados e veste a forma sobre as palavras do autor.

#### WOOP app — iOS · Android
<https://apps.apple.com/us/app/woop-app/id790247988>

**Compartilha.** O WOOP do §6 pela mão da própria Oettingen, com os quatro
passos na ordem obrigatória e o obstáculo interno como eixo.

**Diverge.** Um método só, em formulário fechado. Não existe página em branco,
nem texto livre antes da forma: você entra já dentro do molde.

#### Rescript Journal — iOS
<https://rescriptjournal.com/expressive-writing/>

**Compartilha.** O §8 inteiro, e explícito: protocolo Pennebaker de 15–20 min,
ciclo de 4 dias sobre o mesmo evento, escrita privada e não corrigida.

**Diverge.** A IA analisa tom emocional, tema recorrente e resume o arco da sua
dor. É exatamente o que o §2 proíbe, no ponto mais sensível do produto.

#### MindScribber — iOS
<https://apps.apple.com/us/app/mindscribber-trauma-stress/id6473088330>

**Compartilha.** Traz a escrita expressiva como intervenção com base em
pesquisa, não como enfeite de bem-estar.

**Diverge.** Vem embalado com mood tracker, inventário de estresse, jogos de
emoção, citações motivacionais e vídeos relaxantes. O §12 proíbe quase tudo
isso.

#### Zenpen — web · PWA
<https://zenpen.app/>

**Compartilha.** Timer de 10–15 min e o texto some 30 segundos depois — o
Queimar do §8 já existe em produção, e é o argumento dele na home.

**Diverge.** Destrói tudo, inclusive o que o Traço preserva: a linha de sentido.
Sem login, sem arquivo, sem roteamento — é um exercício, não um caderno.

#### Mindsera — iOS · web
<https://www.mindsera.com>

**Compartilha.** Usa modelos mentais como enquadramento da entrada: é a ideia de
forma aplicada ao diário, e o catálogo é o valor do produto.

**Diverge.** A IA escreve o retorno — análise, coaching, retrato do seu
pensamento. O catálogo serve à IA para produzir prosa, não para vestir a sua.

#### Reflection — iOS · web
<https://www.reflection.app/>

**Compartilha.** A IA devolve UMA pergunta de acompanhamento tirada do que você
acabou de escrever — literalmente o item 3 da lista fechada do §2.

**Diverge.** E também escreve padrões, resumos semanais, revisões anuais e itens
de ação. A pergunta é a porta; atrás dela a IA fala o tempo todo.

#### Rosebud — iOS · web
<https://www.rosebud.app/>

**Compartilha.** A pergunta como motor do diário, e memória de longo prazo entre
entradas — o que o §9 chama de Padrões.

**Diverge.** É conversa, e chat é não-objetivo no §12. A IA responde, consola e
elogia; os próprios depoimentos dizem preferir isto ao terapeuta.

#### Stoic — iOS
<https://www.stoicapp.com>

**Compartilha.** Prática guiada de manhã e de noite, com IA de toque leve — mais
reflexiva que coach.

**Diverge.** O app dá o prompt; a página nunca fica nua. No §3 o vazio é
intencional, e nenhuma dica pode ocupá-lo.

#### Grid Diary — iOS
<https://griddiaryapp.com>

**Compartilha.** Grade de perguntas fixas para matar a fricção do começo — o
mesmo problema que o §17 ataca.

**Diverge.** Resolve por prompt pronto, não por forma que nasce da palavra do
autor. O Traço recusa esse atalho por decisão de spec.

#### Day One — iOS · macOS
<https://dayoneapp.com>

**Compartilha.** O arquivo de diário mais maduro do iOS: busca, seções por data,
export sério.

**Diverge.** Sem método e sem recusa. A lista de cartões É o altar — o
anti-padrão nomeado no §3.

#### Notion — iOS · web · desktop
<https://www.notion.com>

**Compartilha.** Popularizou a ideia de que estrutura é vocabulário: o bloco é
uma forma com nome, e o template mais usado do mundo é uma forma pronta em
campos vazios.

**Diverge.** A estrutura vem por barra invertida — você precisa lembrar o nome
do bloco, que é a fricção nomeada na lei do dono. Nuvem obrigatória, e a Notion
AI escreve a página inteira se você pedir.

#### Clover — iOS · macOS · web
<https://cloverapp.com>

**Compartilha.** Documentos Surface tratam a nota como espaço, não linha: pensar
não é linear, e a forma é onde a coisa está na tela. Notas diárias com tarefa
que rola para o dia seguinte.

**Diverge.** Parado desde 2022 — a última versão na App Store é a 1.1.4, de
setembro daquele ano. Vale como leitura de ideia, não como concorrente vivo:
nuvem, colaboração e planner diário são não-objetivos do §12.

---

## Eixo 3 · IA que recusa (§2 · §19.4)

> A IA nunca insere texto. Algoritmo antes de modelo.

#### Just Write — web
<https://www.justwrite.page/no-ai/>

**Compartilha.** Sem IA por princípio, e a justificativa é a do Traço: um
rascunho meio sugerido não soa como você. Impõe uma regra dura — não dá para
editar nem apagar o que já saiu.

**Diverge.** Web e localStorage, sem arquivo. A recusa é total: não há a parte
multiplicadora, só a ausência.

#### Signal vs Noise — desktop
<https://noirsonance.com/product/signal-vs-noise/>

**Compartilha.** Recusa escrita na página de produto — nenhum algoritmo
tentando terminar seu pensamento — e uma regra que destila o texto de 200 para
100, 50 e uma frase.

**Diverge.** Desktop, offline, feito para letra e ideia curta. Não é caderno:
nada cresce ali, só encurta.

#### Edda — desktop
<https://edda.ink/writing-software-without-ai.html>

**Compartilha.** A doutrina do §19.4 virada produto: verificação
determinística, por regra, offline, sem modelo nenhum dentro. Recusar IA não é
recusar poder.

**Diverge.** É estúdio de romance — EPUB, worldbuilding, beta-readers. Nenhum
método de pensamento, nenhuma memória, nenhum iOS.

#### Flowstate — iOS · macOS
<https://www.hailoverman.com/flowstate>

**Compartilha.** Atrito como método, e em iOS: pare cinco segundos e o texto
desaparece. O app impõe a regra em vez de facilitar.

**Diverge.** É punição, não roteamento. Nada sobrevive para virar nota, e a
regra é única — não há catálogo que se ajuste ao gesto.

#### The Most Dangerous Writing App — web
<https://www.themostdangerouswritingapp.com>

**Compartilha.** Mesmo mecanismo do Flowstate, grátis e de código aberto. Prova
que a regra dura tem público.

**Diverge.** Sessão isolada no navegador, sem arquivo e sem continuidade. Some
quando fecha a aba.

#### Write or Die — web
<https://writeordie.com/>

**Compartilha.** Consequência para a pausa, com graus de severidade escolhidos
pelo autor.

**Diverge.** Gamifica a dor com som e cor. Sem método, sem arquivo, sem nada
depois da sessão.

#### 750 Words — web
<https://750words.com>

**Compartilha.** Cota diária de escrita privada, sem leitor do outro lado —
escrever é o produto, não publicar.

**Diverge.** Vive de streak, medalha e estatística do seu texto. O §12 proíbe
streak e gamificação por nome.

#### Freewrite — hardware
<https://getfreewrite.com>

**Compartilha.** A recusa levada ao extremo material: aparelho de e-ink que só
rascunha, sem edição confortável, sem navegador, sem IA.

**Diverge.** É hardware caro e um só gesto. Nenhuma forma, nenhuma memória,
nenhum arquivo local seu.

#### ⊘ Otter.ai — iOS · web · **polo invertido**
<https://otter.ai>

**Compartilha.** Está no mesmo eixo pela ponta invertida, e por isso é a régua
mais limpa que existe: a promessa impressa é nunca mais tomar nota.

**Diverge.** A IA faz o gesto inteiro no seu lugar — transcreve, resume por
tópico, extrai o que ficou combinado e manda para o CRM. Se isto funcionasse
para pensar, o Traço não teria razão de existir; é a dívida cognitiva do
Kosmyna vendida como produtividade.

---

## Eixo 4 · Captura e arquivo (§3 · §16 · FILA)

> Abrir no cursor sem lista na frente, e capturar um traço de fora do app.

#### Raycast (iOS) — iOS · iPadOS
<https://www.raycast.com/ios>

**Compartilha.** A melhor execução de app fora do app que existe hoje: botão de
Ação, Central de Controle, tela bloqueada, folha de compartilhamento, Atalhos,
teclado próprio e widget — todos entrando na mesma captura, sem tela
intermediária. As Notas do Raycast nasceram assim e viraram o conteúdo que a
base mais cria.

**Diverge.** Do outro lado da captura tem chat de IA com dezenas de modelos e
comandos que reescrevem texto selecionado. Nuvem obrigatória para sincronizar, e
exige iOS 18. É o mapa técnico do item aberto da fila, com o motor que o §2
proíbe.

#### Apple Reminders — iOS · macOS
<https://support.apple.com/guide/iphone/welcome/ios>

**Compartilha.** App Intents feitos como a Apple manda: Siri, Spotlight, folha
de compartilhamento e widget caem todos no mesmo lugar, sem passo
intermediário. É a referência de sistema para o item aberto da fila.

**Diverge.** É tarefa, não escrita: nada ali sustenta um parágrafo, muito menos
uma forma. Serve como aula de encanamento, não de produto.

#### Drafts — iOS · macOS
<https://getdrafts.com>

**Compartilha.** A porta de entrada do §3 é o slogan dele: onde o texto começa.
Abre direto no cursor, sem lista na frente, e a nota decide o destino depois de
existir.

**Diverge.** Passado o cursor, vira máquina de ações e destinos, com markdown
cru e sintaxe de automação. A lista volta ao centro, e nenhuma forma nasce da
palavra.

#### TickTick — iOS · Android · web · desktop
<https://ticktick.com>

**Compartilha.** Captura de qualquer lugar sem tela intermediária: widget, Siri,
folha de compartilhamento, e-mail e atalho global caem na mesma caixa de entrada,
e a data é lida de dentro da frase — "amanhã 9h" vira lembrete sem formulário.
Sem pasta na hora de criar: o destino se decide depois, como no Drafts.

**Diverge.** É tarefa, não escrita: existe lista de notas como tipo próprio, mas
a nota carrega o esquema da tarefa — prioridade, lembrete, coluna, responsável —
sem forma, sem selo e sem memória; ideia e senha ficam lado a lado, sem cadeado.
E atrás da captura vem a suíte — calendário, hábito com sequência, Pomodoro com
estatística, matriz de Eisenhower — e uma pontuação de conquista que sobe de
nível e compara você com os outros usuários. É o §12 quase inteiro, bem
executado.

---

## Eixo 5 · Memória ativa (§7)

> Esconder a nota, escrever de memória, revelar lado a lado.

#### ⊘ Fabric — iOS · web · desktop · **polo invertido**
<https://fabric.so>

**Compartilha.** Segundo cérebro que se organiza sozinho: engole artigo, PDF,
print, áudio e ideia, e depois acha por significado dentro de tudo.

**Diverge.** A frase de venda é a inversão exata do §7 — você acha as coisas por
significado, não por memória, e não precisa lembrar onde guardou. O Recordar
existe porque lembrar é o trabalho que constrói a mente. E os créditos de
pensamento são cobrança por computação, que a ADR 31j proíbe por nome.

#### RemNote — iOS · web · desktop
<https://www.remnote.com>

**Compartilha.** O cartão nasce dentro da nota, sem app separado, e o FSRS
agenda a cobrança. É a escada 3→7→21 do §19.2 num motor sério.

**Diverge.** Cobra pergunta→resposta com pista, não recall livre da própria
nota. E tem IA que escreve, gera cartão e resume.

#### Anki — iOS · desktop
<https://apps.ankiweb.net>

**Compartilha.** A régua do espaçamento, e a prova de que cobrar memória
funciona há vinte anos.

**Diverge.** Não é lugar de escrever. O cartão é fabricado à parte, num segundo
momento — a fricção que o §17 chama de bug.

#### Mochi — iOS · web
<https://mochi.cards>

**Compartilha.** SRS limpo em markdown, formato aberto e portátil, desenho
minimalista. Anki para quem tem gosto.

**Diverge.** Cartões, não notas. Nenhuma forma de pensamento, nenhuma recusa de
IA como princípio.

#### Amplenote — web · iOS
<https://www.amplenote.com>

**Compartilha.** Notas, flashcards e tarefas no mesmo lugar, com repetição
espaçada embutida no fluxo de escrita.

**Diverge.** Suíte de produtividade com agenda e projeto — o §12 declara agenda
um não-objetivo. Markdown cru.

#### SuperMemo — Windows
<https://www.supermemo.com>

**Compartilha.** O algoritmo mais fundo que existe (SM-18) e a leitura
incremental — a ambição máxima de multiplicar leitura.

**Diverge.** UX de outra era, só Windows. Nada de escrita expressiva, forma ou
recusa.

#### Readwise — iOS · web
<https://readwise.io>

**Compartilha.** Ressurgimento diário do que você marcou, para que a leitura não
evapore.

**Diverge.** Traz palavras de outros, não suas, e por releitura passiva. O §3
nomeia reler cartões à noite como anti-padrão.

---

## O vão

Quatro coisas que ninguém nesta lista faz, e que valem mais que a soma das
semelhanças.

### 1. Ninguém cobra memória sem dar pista

Anki, RemNote, Mochi e SuperMemo cobram pergunta e esperam resposta: a pergunta
já é metade da lembrança. O Recordar do §7 esconde a nota inteira e pede o texto
de volta, sem pista e sem nota de avaliação — o olho compara. Isso é recall
livre, e não existe em nenhum app de notas do mercado.

### 2. Quem rota método usa formulário; quem tem IA boa deixa ela escrever

O WOOP app tem o método e nenhuma página em branco. O Rescript tem o protocolo e
entrega sua dor para o modelo resumir. Mindsera e Reflection têm catálogo e
roteamento, e usam os dois para produzir prosa. O auto-forma do §17 — IA que
veste sem tocar uma palavra — não tem precedente comercial.

### 3. Destruir o texto e preservar o sentido

O Zenpen é o único que apaga de verdade, e apaga tudo. O Queimar do §8 destrói o
texto por rota — arquivo, Spotlight, backup, revisão — e deixa sair só a linha
de sentido escrita pelo autor. Ninguém separa a dor que fecha do sentido que se
multiplica.

### 4. O mercado inteiro aposta que lembrar é problema da máquina

Fabric vende achar por significado, não por memória. Otter vende nunca mais
tomar nota. Raycast e Craft vendem o modelo certo respondendo sobre o seu
material. Todos estão certos sobre recuperação e errados sobre formação:
recuperar informação é trabalho de máquina, formar mente não é. O Traço é o
único que trata o esquecimento como o exercício, e não como o defeito a ser
patrocinado — e essa é a aposta que decide se ele tem razão de existir.

## A ameaça não é quem se parece

Nenhum app parecido aqui vai virar o Traço. O risco é o **Apple Notes**, que já é
a âncora de design do §11, já está instalado em todo iPhone, e cujo Apple
Intelligence caminha na direção contrária à regra de ferro — escrevendo,
resumindo e reescrevendo dentro da nota. Se escrever pelo autor virar o padrão do
sistema operacional, a frase do produto deixa de ser diferencial técnico e passa
a ser posição política.

O segundo risco é de linguagem: **Fabric, Otter e Raycast** estão ensinando o
mercado a chamar de segundo cérebro o arquivo que pensa no seu lugar. Quando o
autor de primeira viagem abrir o Traço, ele vai comparar com aquilo, e o §17 diz
que ele não pode precisar de manual para entender a diferença.
