# Referências de fora — 33 apps sem relação com o Traço

> Nenhum app aqui tem relação com a proposta do Traço. São apps de câmera,
> carteira, leitura, foto, timer e palavra-do-dia que já resolveram, com
> orçamento e anos de ajuste, um problema que está ABERTO na fila.
> A lista está organizada pelos itens de `FILA.md` e pelos defeitos da `SPEC.md`,
> não por categoria de App Store — porque referência sem problema atrelado vira
> moodboard.
> Telas verificadas no Mobbin em setembro de 2026; os links levam à tela citada
> quando ela existe lá, e ao site oficial quando não.
> Concorrência por eixo da spec: `VIZINHANCA.md`.

## Contagem e legenda

33 apps: 29 espalhados por 7 problemas abertos, mais 4 contraexemplos no rodapé.
Dos 29: **24 para roubar** e **5 para recusar**.

- **✓ roubar** — mecanismo para adotar.
- **✕ recusar** — o app resolveu o mesmo problema pela via que a spec proíbe.
  Vale mais como régua negativa que como inspiração.

Duas telas do mesmo recurso com intenções opostas ensinam mais rápido que dez
telas boas. Há dois pares assim aqui: Fotos da Apple × Google Fotos no selo, e
TIDE × Life Reset no timer.

---

## 1 · Formas sem fricção e o botão que veste a nota

**Fonte:** FILA · P1 alta · §17

**O problema.** Hoje a régua abre grid vazio cru para tabela: funcional, não
premium. O dono pediu construtor visual por toque para TODOS os formatos, e um
botão que veste a nota inteira de uma vez. O autor nunca pode precisar entender
a forma.

#### ✓ Craft
<https://mobbin.com/screens/e98ab0b4-9fb4-40da-88fc-c62edb474d7e>

**O mecanismo.** Toque na célula abre uma folha chamada Editar tabela com verbos
nomeados — inserir linha, mover coluna à esquerda, apagar linhas — e cada verbo
tem um glifo que mostra qual eixo se move.

**No Traço.** É o portal vestido do §19.2 pronto: a estrutura muda por verbo,
nunca por sintaxe. O autor lê inserir linha e vê o desenho da linha; não existe
pipe nem hífen em lugar nenhum.

#### ✕ monday.com
<https://mobbin.com/screens/3423eb72-4d52-4265-9638-4b8a181da785>

**O mecanismo.** Grade densa com adicionar coluna, adicionar grupo, novo item e
busca rápida, tudo visível ao mesmo tempo na tela do telefone.

**No Traço.** O retrato exato do que a tabela não pode virar. Vale guardar como
régua negativa: se o construtor começar a parecer isto, ele falhou o hicks-law
antes de falhar o gosto.

#### ✓ Atalhos (Apple)
<https://support.apple.com/guide/shortcuts/welcome/ios>

**O mecanismo.** Ação é um bloco físico que encaixa em outro. Você monta lógica
sem escrever sintaxe, e o bloco carrega o nome do que faz.

**No Traço.** O modelo mental para a régua de 12 e a folha das 124: a forma é
objeto que se pega, não comando que se lembra. O próprio Taio copiou isso e o
§17 pede o oposto do menu.

#### ✓ Numbers
<https://www.apple.com/numbers/>

**O mecanismo.** A tabela é um objeto com alças nas bordas. Arrastar a alça cria
coluna; a estrutura cresce pelo contorno, sem menu.

**No Traço.** Resolve o crescer por toque da tabela sem gastar barra inferior. A
alça é descobrível por estar no objeto, o que dispensa a memória que o §17
proíbe exigir.

#### ✕ Notion
<https://www.notion.com>

**O mecanismo.** Barra invertida abre a paleta de blocos. Rápido, poderoso, e
depende de você lembrar o nome do bloco que quer.

**No Traço.** É a fricção nomeada na lei do dono: exigir lembrar de alguma coisa
para deixar bonito quebra o uso. Serve para provar por que o Traço veste sozinho
em vez de oferecer paleta.

---

## 2 · A folha: papel, física e profundidade

**Fonte:** FILA · mandato ao vivo 01/set · nota 7

**O problema.** Palavra do dono: páginas como caderno de folhas, arrastar a nota
como quem arrasta uma folha, sem senso tático eu sinto a página. Abertos:
folha-visual da nota aberta, arrastar a nota na lista como folha, e elevar a
estrutura geral.

#### ✓ Apple Wallet
<https://www.apple.com/wallet/>

**O mecanismo.** Cartões empilhados com uma faixa de cada um aparecendo.
Arrastar um revela o de baixo, e a pilha respira: o que está atrás encolhe e
escurece.

**No Traço.** É o peek de folha na lista que está aberto na fila. A pilha também
ensina a profundidade que o §21 exige: quem desliza por cima precisa de sombra e
de escurecimento atrás, senão lê como conteúdo sendo apagado.

#### ✓ Clear
<https://apps.apple.com/app/clear-todos/id493136154>

**O mecanismo.** Lista de 2012 sem um único botão: puxar para criar, arrastar
para completar, pinçar para inserir entre duas linhas. Cada gesto tem háptico
próprio.

**No Traço.** Prova que zero chrome é vendável e prazeroso, que é a aposta do
§3. E o pinçar para inserir entre linhas é candidato direto para nascer bloco no
meio da nota.

#### ✓ Things 3
<https://culturedcode.com/things/>

**O mecanismo.** O Magic Plus é um botão que se arranca da barra e se arrasta
até o ponto exato da lista onde a coisa vai nascer. O motion tem massa, e nada
anima durante a digitação.

**No Traço.** A pílula Nova do §20 pode ganhar isso sem virar quarto destino. É
também o padrão-ouro de contenção: o app mais premiado do iOS não anima
enquanto o autor escreve, igual ao §11.

#### ✓ Family
<https://benji.org/family-values>

**O mecanismo.** Carteira cripto conhecida só pelo movimento: molas
interrompíveis, um objeto por driver, e o autor da equipe escreveu o ensaio
explicando cada decisão.

**No Traço.** É a leitura de apoio para as leis do §21. A mola que não acelera
na chegada e o gesto que herda a velocidade do dedo estão resolvidos e
documentados ali.

#### ✓ Paper (FiftyThree)
<https://en.wikipedia.org/wiki/Paper_(Fiftythree_app)>

**O mecanismo.** Encerrado, mas o arquivo de vídeos continua: papel com grão,
tinta que assenta, e a folha virando com peso. Ganhou Apple Design Award por
isso.

**No Traço.** A única referência que resolveu folha de verdade em tela. Vale como
alvo visual da folha-visual aberta, sem copiar o skeuomorfismo pesado.

---

## 3 · Dynamic Type: escalar conteúdo ou travar o chrome

**Fonte:** SPEC §22 · defeito aberto

**O problema.** A entrelinha cresce e a letra não, porque todo o Tema usa
`system(size:)` em ponto fixo. A decisão do dono está pendente entre escalar
tudo, e aceitar que a régua vire outra coisa, ou escalar só o conteúdo e travar
o chrome.

#### ✓ Apple Books
<https://mobbin.com/screens/a83c87b2-ce0a-450a-a685-eef410d5628b>

**O mecanismo.** A folha de temas não pede seis ajustes. Oferece seis temas
NOMEADOS — Original, Quiet, Paper, Bold, Calm, Focus — cada um um retângulo com
Aa desenhado no próprio tema, e esconde o resto atrás de Personalizar.

**No Traço.** Dissolve a decisão do §22: em vez de perguntar ao dono escalar
tudo ou travar o chrome, embale as duas respostas como modos de leitura
nomeados. O nome carrega o pacote de decisões, e Dynamic Type deixa de ser um
sim ou não.

#### ✓ Fable
<https://mobbin.com/screens/8ed9301b-98de-4652-8715-c364cd8d8cab>

**O mecanismo.** A versão magra do mesmo padrão: claro e escuro separados,
quatro tipos por nome, UM controle de tamanho de Aa pequeno a Aa grande, e dois
interruptores.

**No Traço.** É o teto de complexidade aceitável para um app de uma página. Se
precisar de ajuste de leitura, cabe nisto — e a página continua sendo o produto.

#### ✓ Instapaper
<https://www.instapaper.com>

**O mecanismo.** Medida de linha, tipo e brilho num só painel, e o painel morre
ao toque fora. Nada dele sobra na tela de leitura.

**No Traço.** Confirma que o ajuste de tipo é folha efêmera, nunca barra
permanente. Encaixa na regra do §20: na escrita não há chrome nenhum.

---

## 4 · O selo: conteúdo que se recusa a abrir

**Fonte:** SPEC §8 · reabrir trancada

**O problema.** Reabrir uma expressiva exige dupla confirmação e Face ID, e a
cópia precisa desencorajar sem mentir: reler o desabafo reacende o que a escrita
encerrou.

#### ✓ Apple Photos
<https://mobbin.com/screens/01f45e7a-2178-4ecf-9f80-8a8fc6a56bbf>

**O mecanismo.** O álbum Oculto substitui TODO o conteúdo pela declaração do
bloqueio: um cadeado cinza, a frase use Face ID, e a ação de furar é um link de
texto discreto, Ver álbum. Nenhum botão gordo.

**No Traço.** É a hierarquia exata que o §8 quer. O selo se anuncia e a saída
existe, mas ela não convida — o peso visual está no bloqueio, não na ação de
rompê-lo.

#### ✕ Google Photos
<https://mobbin.com/screens/fcd75ad4-24d9-49af-a3e3-c1edf8fb746c>

**O mecanismo.** A pasta bloqueada mostra uma ilustração simpática e um botão
azul cheio, Abrir com Face ID, centrado e convidativo.

**No Traço.** O mesmo recurso com a intenção invertida: aqui o produto QUER que
você abra. Comparar as duas telas é a aula mais curta sobre por que a cópia e o
peso do botão são o método, não decoração.

#### ✓ 1Password
<https://1password.com>

**O mecanismo.** O cofre é o modelo mental inteiro: tranca sozinho, e a tela
trancada não vaza nem o nome do que guarda.

**No Traço.** Sustenta a regra do §16 de que trancada não entra na busca. Vale
conferir como eles tratam captura de tela e trocador de apps, duas rotas que o
selo ainda pode vazar.

#### ✓ Signal
<https://signal.org>

**O mecanismo.** Mensagens temporárias com o relógio visível ao lado do nome da
conversa. O desaparecimento é estado declarado do canal, não acidente nem
promessa em letra miúda.

**No Traço.** Ensina a mostrar destruição futura sem drama. Serve para o Queimar
do §8, que precisa ser verdade em todas as rotas — e para a nota queimada que
aparece na lista com os minutos e a linha de sentido.

---

## 5 · O timer que não negocia

**Fonte:** SPEC §8 · 15 minutos

**O problema.** O timer da expressiva é visível e discreto, e ao fim a nota grava
e sela. Sair no meio tranca. A tentação de todo app de timer é oferecer uma
saída confortável.

#### ✓ TIDE
<https://mobbin.com/screens/5d524f74-de16-47e9-b9c0-8daa440e3621>

**O mecanismo.** O tempo é o único elemento da tela, em cima de uma cena parada.
Sem barra, sem pausa, sem progresso. Uma palavra abaixo dos números diz o que
está acontecendo.

**No Traço.** É o timer-instrumento que a campanha visual já aprovou, levado ao
limite. Confirma que dá para ocupar a tela inteira com o tempo sem competir com
a escrita.

#### ✕ Life Reset
<https://mobbin.com/screens/a15a78ef-29e5-4468-9c51-a779802e42cb>

**O mecanismo.** Pomodoro com mais um minuto, pular, pausar e barra de progresso
arrastável, sobre arte animada.

**No Traço.** Cada controle desses é uma negociação, e o §8 não negocia: o
método é não ter volta. Boa lista do que NÃO colocar perto do timer.

#### ✓ One Sec
<https://one-sec.app>

**O mecanismo.** Interpõe uma respiração forçada entre o seu toque e o app que
você ia abrir. O atrito é o produto inteiro, e ele é vendido como cuidado, não
como castigo.

**No Traço.** É a prova comercial de que atrito deliberado tem mercado — a mesma
aposta do aviso e do véu. E o tom deles é o tom que o §15 pede: sem citação
acadêmica, sem sermão.

#### ✕ Forest
<https://www.forestapp.cc>

**O mecanismo.** A sessão tem aposta material: sair mata a árvore. Funciona, e
constrói floresta, moeda e ranking em cima disso.

**No Traço.** A aposta é interessante; a economia em volta é streak e XP,
proibidos por nome no §12. Serve para marcar onde a ideia acaba e a gamificação
começa.

---

## 6 · Uma coisa por tela, tipografia como produto

**Fonte:** SPEC §3 · §11 · eixo Mente

**O problema.** A página em branco escura com cursor pronto precisa parecer
intencional, não vazia. E a régua de palavras é vocabulário visual: a tipografia
É a interface.

#### ✓ Vocabulary
<https://mobbin.com/screens/210a6545-c412-4173-99ce-7404038e257f>

**O mecanismo.** Uma palavra serifada no centro geométrico de uma tela de papel,
a pronúncia numa pílula pequena, uma linha de definição. Todo o chrome virou
pílulas flutuantes empurradas para as bordas — perfil e coroa no alto, quatro
ícones e Praticar no rodapé — e o miolo é só a palavra.

**No Traço.** É a resposta visual ao §3 que ainda não existe aqui: o vazio não é
falta, é enquadramento. Reparar que o conteúdo não divide espaço com nada, e que
o chrome não forma barra — flutua, e some se preciso. É exatamente a arquitetura
do §20, onde escrever não é aba.

#### ✓ Calm
<https://mobbin.com/screens/64c4a0bc-3157-442e-8d4b-7eb5f080c277>

**O mecanismo.** Citação serifada centrada sobre fundo desfocado, autor em corpo
pequeno abaixo, e um único Continuar contornado no rodapé. Nada mais existe na
tela.

**No Traço.** O molde do cartão fixo não-editável do §9: a pergunta dos Padrões
pode ocupar a tela assim, com UMA saída. Uma pergunta por tela obriga a
responder, não a navegar.

#### ✓ NYT Games
<https://www.nytimes.com/games>

**O mecanismo.** Um quebra-cabeça por dia. Acabou, acabou: a tela final agradece
e manda voltar amanhã, sem oferecer mais nada para consumir.

**No Traço.** Escassez como desenho, e a recusa de prender. Encaixa na tese do
§3 de que reler os cartões à noite é o anti-padrão — o app tem que saber
terminar.

#### ✓ Halide
<https://halide.cam>

**O mecanismo.** Câmera pro cujos controles moram fora da tela até serem
chamados por gesto. O visor nunca perde área para botão.

**No Traço.** É a lei do §20 provada em app pago e premiado: a ferramenta séria
esconde o painel e devolve a tela ao trabalho. A barra de Analisar, Recordar e
Anexar pode aprender daí.

#### ✓ Kindle
<https://www.amazon.com/kindle>

**O mecanismo.** Tipografia hinted à mão, margens que respeitam o polegar, e a
virada de página como evento silencioso. Décadas de ajuste em cima de uma coisa
só: ler.

**No Traço.** A régua de medida de linha e o corpo 17/26 do §11 têm ali um
comparativo honesto. Se a linha do Traço estiver mais larga que a do Kindle, ela
está errada.

---

## 7 · O app fora do app

**Fonte:** FILA · aberto M/L

**O problema.** Widget, App Intent, extensão de compartilhamento e Spotlight
estão abertos. O ponto é começar uma nota sem abrir o app, e sem que isso vire
um segundo produto.

#### ✓ Shazam
<https://www.shazam.com>

**O mecanismo.** O widget faz UMA coisa, num toque, e o resultado aparece
depois. Nenhuma configuração, nenhuma escolha.

**No Traço.** É o desenho do widget: um toque abre a página em branco com o
cursor pronto. Zero opção, porque decidir também é fricção.

#### ✓ Lembretes
<https://support.apple.com/guide/reminders/welcome/mac>

**O mecanismo.** App Intents bem-feitos: Siri, folha de compartilhamento,
atalho de teclado e Spotlight, todos entrando no mesmo lugar sem tela
intermediária.

**No Traço.** A referência técnica direta para o item aberto. Modelo de como uma
captura externa cai na nota sem inventar uma segunda porta de entrada.

#### ✓ Câmera na tela bloqueada
<https://support.apple.com/guide/iphone/take-photos-iph4722671e/ios>

**O mecanismo.** Uma ação de sistema, sem app aberto, sem autenticação, e o
resultado espera do outro lado.

**No Traço.** O teto de ambição para capturar um traço no instante em que ele
aparece — que é o problema real de quem escreve com TDAH, nomeado no §17.

---

## Ideias boas presas em produtos errados

Nestes quatro, a ideia serve e a embalagem é proibida. Vale saber separar antes
de olhar a tela, senão a gamificação entra de carona.

#### Duolingo

**A ideia que serve.** A estrutura de uma pergunta por vez, com dificuldade
adaptativa, é exatamente o que o Recordar quer.

**O limite que a spec impõe.** Vem grudada em ofensiva, XP, liga e notificação
culpando você. O §12 proíbe os quatro por nome, então só a estrutura atravessa.

#### Whoop / Oura

**A ideia que serve.** Devolvem padrão ao longo do tempo com autoridade visual,
que é a ambição do §9.

**O limite que a spec impõe.** Fazem isso virando tudo em NOTA de 0 a 100. O
§19.1 proíbe à IA pontuar, medir progresso ou dar nota — o Padrões devolve
pergunta, não placar.

#### BeReal

**A ideia que serve.** Janela de dois minutos e proibição de editar: a regra dura
cria honestidade, igual ao timer da expressiva.

**O limite que a spec impõe.** A honestidade existe para uma audiência. No Traço
não há leitor do outro lado, e é isso que faz a escrita funcionar.

#### Strava

**A ideia que serve.** Transforma registro bruto em identidade, e faz a pessoa
voltar por anos.

**O limite que a spec impõe.** Por kudos e segmento — desempenho social. É o
caminho oposto ao da nota que se sela e nunca se mostra.

---

## As três que eu puxaria primeiro

**Apple Books resolve o §22 sem decisão do dono.** O defeito de Dynamic Type está
parado esperando escolher entre escalar tudo ou travar o chrome. Temas nomeados
fazem as duas respostas caberem no mesmo app, e o autor escolhe uma palavra em
vez de seis sliders.

**Craft resolve a tabela crua que está P1 na fila.** A folha de verbos com glifo
por eixo é o construtor visual que o dono pediu, e o padrão se repete para todos
os formatos da régua sem inventar nada.

**Vocabulary é a régua do §3.** Uma unidade de conteúdo ocupando a tela toda, com
o chrome flutuando nas bordas, é o argumento visual de que a página em branco é
enquadramento e não falta. É a referência mais próxima do que o Traço quer
parecer, vinda de um app que ensina palavras.
