# G4 da volta F4 — os widgets da tela de início

**Papel:** julgar do design (`design-router`), sessão própria, sem tocar em código.
**Worktree:** `f4-widgets`, topo `0aca3f3`. **G3:** aprovado na terceira passada.
**Aparelho:** iPhone Air `64F7B8B4-CBBD-4449-A51E-19E1A1A077B4`, iOS 26.5, build
deste worktree (`xcodebuild` limpo, **0 avisos**, instalado às 21:24 de 06/09).
**Fases do `design-router` cumpridas:** Ancorar (contrato e produto existente),
Sistema (`Tema.swift`, componentes do alvo), **Mover**, **Julgar**, **Portão**.
`curva-zero` carregada para o estado vazio.

**Veredito: RECUSADO. Nenhuma das cinco dimensões chega a 9.**

O print de hoje ficaria **muito** diferente — e melhor. Mas ele ainda mente sobre
o tamanho do dia, e o defeito nº 5 do dono ("densidade errada: o médio usava 4x2
para uma frase") continua reproduzível em dois lugares que esta volta tocou.

---

## 0. Instrumento — a galeria não travou porque eu não passei por ela

Três sessões de revisão esbarraram na galeria "Adicionar Widget". Eu não abri a
galeria. Os quatro widgets foram plantados escrevendo direto o
`data/Library/SpringBoard/IconState.plist` do aparelho (uma entrada por widget,
`widgetIdentifier` = o *kind* do WidgetKit, `gridSize` = `small`/`medium`) e
matando o SpringBoard. É plantio real: quem desenha é a extensão de verdade,
lendo o instantâneo de verdade. **Custo: ~40 segundos por estado, sem toque
nenhum.** Fica registrado para as próximas voltas — a galeria deixou de ser um
bloqueio da esteira.

Cópia de segurança do original em `IconState.plist.bak-g4` no próprio aparelho.

**O que o instrumento me negou:** a janela do meu simulador fechou e não voltou
(o app só reabre o "External Display" desse aparelho). Sem janela não há
`cliclick`, e sem `cliclick` não há **toque**. Logo: não filmei o dedo marcando
o feito. Digo isso abaixo, na fase Mover, sem tentar disfarçar — e, como manda a
tarefa, não desconto nota por isso.

Prova de tela: `xcrun simctl io <UDID> screenshot`, sempre. Nenhuma asserção de
maestro foi usada (havia cinco simuladores ligados). Dynamic Type e Reduzir
Movimento restaurados ao fim.

---

## 1. MOVER

**Nota: 8.**

### O que encontrei

Uma varredura no alvo inteiro por `animation`, `contentTransition`,
`transaction`, `withAnimation`, `Movimento`, `reduceMotion`:
**nenhuma ocorrência em `TracoWidget/`.** Os widgets da casa não declaram um
único movimento. A única coisa que anda no alvo é `Text(style: .timer)`, e ela
mora na Live Activity — outra superfície.

**Reduzir Movimento: respeitado.** Liguei `ReduceMotionEnabled`, reiniciei o
aparelho e recapturei o mesmo estado: `g4-f4-reduzir-movimento.png` é idêntico
a `g4-f4-feito.png` no que é do widget. Respeitado, sim — mas *por ausência*.
Não há o que reduzir. Isso é uma virtude barata; conto como acerto, não como
mérito.

### O achado da fase

**H — o toque de feito não tem eco na própria superfície.**
`BotaoFeito` é um `Button(intent:)` e não traz `.invalidatableContent()`. Sem
ele o sistema não desenha o estado pendente enquanto o intent roda e a linha do
tempo recarrega: o dono toca o círculo e a superfície fica **exatamente igual**
até a recarga chegar. É o gesto de assinatura do Traço fora do app, e é o único
lugar do widget onde movimento tem função. Uma linha resolve.

Corolário menor: `BlocoProximo` desenha a hora com `monospacedDigit()` mas sem
`.contentTransition(.numericText())` — quando a entrada vira, o número troca em
corte seco.

### O que não pude filmar

O toque. A janela do aparelho não reabre, e sem janela não há toque. O que
consegui gravar (`recordVideo` atravessando uma recarga por app) mostra o app,
não a transição do widget, e não vale como prova — não o anexei. **Se houvesse
janela, o que se veria é o crossfade padrão do WidgetKit**, porque o código não
pede nada além disso. Essa parte eu afirmo pela leitura, não pela filmagem.

---

## 2. JULGAR — os quatro widgets na casa, nos dois temas

Plantei pequeno do Traço, pequeno do Próximo, médio do Traço e médio do Próximo
na mesma página, e olhei como o dono olharia.

### Antes e depois

`f4-antes-inicio-claro.png` (o print que abriu a volta) contra
`g4-f4-casa-claro.png` (hoje, 21:28, dado semeado pelo caminho real).

O que morreu, e eu confirmo na tela:
- a linha "atualizado às 13:23" **não existe mais** em nenhuma das quatro faces;
- os dois atalhos de largura inteira com filete no meio ("parece menu de
  sistema") viraram uma faixa compacta de cabeçalho;
- o médio deixou de gastar 4x2 numa frase: `g4-f4-medio-proximo.png` traz três
  compromissos com hora, assunto e sino, alinhados em três colunas;
- há marca: ponto âmbar no rótulo, âmbar na hora iminente, âmbar no círculo do
  feito, âmbar na ação — e tudo por token de `Tema`. Nenhum valor solto.

**Isso parece o Traço?** Parece. E a prova mais forte não é o widget: é
`g4-f4-rotas.png`, onde as três rotas abrem o app e o app é o *mesmo papel*, a
*mesma tinta*, o *mesmo âmbar*. As quatro superfícies pertencem ao mesmo
produto. Esse era o defeito nº 4 e ele está resolvido.

### Tema escuro

`Tema` é uma paleta clara fixa (ADR 02h, "papel, não tela") e o widget carrega
`containerBackground(Tema.fundo)`. Em modo escuro (`g4-f4-casa-escuro.png`) as
quatro faces continuam creme sobre uma casa escura. **Não é acidente e não é
defeito**: é a mesma decisão do app, e visto na tela dá identidade forte — papel
pregado numa parede escura. Registro o custo, que é real e não paguei eu: às
23h, quatro retângulos a ~95% de luminância são a coisa mais brilhante da tela
de um app cuja proposta é calma. Fica como dívida de rumo, não como achado.

### `critique-visual-hierarchy`

No estado povoado a hierarquia **diz o que vem agora**. No médio do Traço
(`g4-f4-medio-traco.png`) a ordem de leitura é: marca → a única coisa de hoje
(17pt, círculo âmbar) → filete → a agenda (15/12pt). O ponto de entrada é o
certo e o filete faz trabalho de verdade.

Uma observação, não um achado: no pequeno do Próximo a **hora** é 28pt e o
**assunto** 15pt. O elemento mais alto da página é o que menos identifica o
compromisso; "22:09" sozinho não diz o que vem. É defensável (a hora é a
resposta, e o âmbar marca iminência), mas a razão de 1,9× entre os dois é a
maior da face e está na direção contrária à do médio, onde o assunto ganha peso.
Duas faces do mesmo widget respondendo à mesma pergunta com hierarquias opostas.

### `critique-information-density` — **aqui está o pior**

**Achado A (alto) — "+2 depois" afirma um número que não é verdade.**

Semeei **cinco** compromissos no calendário e li o instantâneo publicado:

```
no calendario: 5 eventos
na superficie: 3 -> [('Café com o Pedro','22:03'), ('Ligar para a Marta','22:03'), ('Dentista','22:28')]
```

`ProximoCompromisso.candidatas = 3` — a superfície nunca carrega mais que três.
E o pequeno imprime, em `g4-f4-cinco-de-cinco.png`, **"+2 depois"**. Não é um
"há mais": é uma **contagem exata, derivada de uma lista que o widget sabe estar
cortada**. O dono lê "+2 depois" e acredita que o dia dele tem três coisas.
Tem cinco.

O `+N depois` entrou nesta volta (`cfd04fc`); o corte em três é da F2. A volta
que introduziu o número é a dona do número. E é exatamente a segunda metade da
pergunta central: *nada velho passando por novo, nada prometido que não vá
acontecer.* Um número errado é pior que nenhum, porque encerra a dúvida.

**Achado B (alto) — o médio do Traço larga a agenda e deixa a área vazia.**

Mesmo estado de cinco: `g4-f4-medio-traco-2-de-5.png`. Com Destaque posto o
médio mostra `prefix(2)`, **dois** de três publicados (de cinco reais), **não
diz "+N"** e deixa uma faixa vazia de cerca de uma linha e meia de agenda no pé
do cartão. O pequeno, com um terço da área, conta que há mais; o médio, com o
triplo, não conta nada. O defeito nº 5 do dono, na versão silenciosa.

O médio do Próximo (`g4-f4-medio-proximo-3-de-5.png`) mostra três e também não
diz que há mais — mesmo pecado, meia dose.

**Achado C (alto) — AX5 corta o nome do compromisso.**

A tarefa listou "as quatro famílias em AX5 nos dois temas **sem reticências**"
como já provado. **Não está.** Em `g4-f4-ax5-reticencias.png` (claro) e
`g4-f4-casa-ax5-escuro.png` (escuro), o pequeno do Próximo mostra:

> **Café com o Pe…**

Dezesseis caracteres, um título trivial. A F4-D levou `Oferta`, `Velho` e a
linha do Destaque para `minimumScaleFactor(0.6)` justamente porque 0,85 não
chega em 155 pt; **`BlocoProximo` ficou para trás com 0,85** — e é a peça do
pequeno, a família mais usada. É a mesma família de defeito que já derrubou esta
volta duas vezes, agora no nome do compromisso, que é a informação.

**Achado D (alto) — em AX5 o médio do Traço volta a ser uma frase em 4x2.**

`g4-f4-casa-ax5-claro.png`. Em tamanho de acessibilidade o médio do Traço perde
a agenda (`!tipo.isAccessibilitySize`) **e** os atalhos do cabeçalho (mesma
guarda), e nada entra no lugar: sobra o rótulo, uma linha de Destaque e cerca de
**55% de cartão morto**. É a foto do defeito nº 5 reconstituída, para o leitor
que mais precisa de ajuda. O `quadroVazio` teve o cuidado de sobreviver em AX5
("o poder muda de lugar, não some") — o caso povoado não teve.

### `critique-affordance` e `curva-zero` no vazio

`g4-f4-vazio.png` e `g4-f4-vazio-ax5.png`.

**O que ficou bom:** o médio do Traço vazio é um quadro de ofertas com três
ações reais, uma âmbar (primária) e duas neutras — uma ação dominante, e a
recuperação sobrevive em AX5 com duas das três. Isso é `curva-zero` bem feito:
o vazio virou começo.

**Achado E (alto) — o médio do PRÓXIMO vazio nunca virou quadro.**
Só o widget do Traço ganhou `quadroVazio`. O médio do Próximo vazio é *uma
frase e um link*, com ~55% de cartão em branco embaixo (visível em
`g4-f4-vazio.png`, quarto cartão). Calendário vazio é o estado mais comum de
todos num app de escrita. O defeito nº 5, literal, no widget irmão.

**Achado G (médio-alto) — alvo de toque abaixo de 44 pt.**
Medi as três ofertas do quadro no arquivo em 3×: **passo de ~32 pt entre
centros**, glifos de 11–13 pt, e a área tocável de cada `Link` é a altura do
`HStack` (~15–17 pt), separada por 8 pt de vão morto. O mínimo da própria
ESTEIRA é 44 pt. Três destinos diferentes empilhados a 32 pt: um polegar que
erra "Nova nota" abre o calendário. Vale igual para os dois atalhos do
cabeçalho do médio.

**Achado I (médio) — o quadro de ofertas lê como lista de Ajustes.**
Três linhas glifo+palavra, alinhadas à esquerda, sem contêiner, sem separador,
sem chip, espaçadas por igual. É a forma que o dono recusou pelo nome —
"parece menu de sistema". A volta matou esse desenho no estado povoado e o
ressuscitou no estado vazio.

**Achado F (médio) — o risco do feito não chega à tela.**
`linhaDoDestaque` declara `.strikethrough(d.feito, color: Tema.tintaFraca)`.
Marquei o Destaque como feito pelo caminho real e ampliei:
`g4-f4-feito-sem-risco.png`. **Não há risco nenhum.** O feito é dito só pelo
disco cinza e pelo texto acinzentado. Hipótese para quem for corrigir: a
convivência de `strikethrough` com `minimumScaleFactor` na mesma `Text`. O que
eu afirmo é o observável — o código promete um traço e a tela não tem traço.

**Achado J (baixo) — "Desatualizado." no pequeno leva a "Nova nota".**
`g4-f4-desatualizado.png`. No pequeno o rodapé diz "Desatualizado." e o rótulo
de voz diz "Abra o Traço para atualizar", mas o `widgetURL` da face continua
`traco://nova`: o toque abre uma nota em branco. Funciona (abrir o app
republica), mas a promessa e o destino não são a mesma frase.

### O que confirmei que está certo

- **As três rotas levam a algo específico** (`g4-f4-rotas.png`): `traco://nova`
  abre a nota com cursor e teclado; `traco://recordar` abre o cartão de
  recordação; `traco://calendario` abre o dia 6 com os três compromissos e o
  marcador do agora. "Um toque faz uma coisa" — passa, e fecha o A6 do G3.
- **O estado honesto sai em toda combinação** (`g4-f4-desatualizado.png`): com
  Destaque, sai no rodapé das duas famílias; sem Destaque, é o miolo com a ação.
  A R1 está fechada e a lei está fora da view, com teste.
- **Reduzir Movimento** não muda pixel nenhum.
- **A validade é honesta no limite**: com três candidatas, `validoAte` é o fim
  da última — o widget não inventa a quarta, diz "desatualizado". Correto, e é o
  que torna o "+2 depois" ainda mais estranho: o sistema sabe que a lista é
  parcial e mesmo assim publica um número fechado.

---

## 3. A PERGUNTA CENTRAL

> O dono olha a tela de início e **sabe o que vem agora, sem abrir o app**?
> E o que ele vê é **verdade**?

**Sabe o que vem agora: sim**, no dia comum, em tamanho normal. É a maior
diferença entre `f4-antes-inicio-claro.png` e `g4-f4-casa-claro.png`, e não é
pequena: onde havia uma frase e um carimbo de hora, há a única coisa de hoje, os
três próximos com hora, assunto e a que horas o alarme toca. O print de hoje
ficaria diferente.

**É verdade: não inteiramente.** Num dia de cinco compromissos ele vê dois (no
médio do Traço) e lê "+2 depois" quando faltam quatro. Nada do que está escrito
é velho — a volta matou isso —, mas **o que está escrito não é tudo, e o widget
afirma que é**. Em tamanho de acessibilidade ele vê menos ainda, e o nome do
compromisso vem cortado.

A volta trocou "mentira por antiguidade" (o widget parado nove horas) por
"mentira por corte" (o dia inteiro reduzido a três, e contado errado). É uma
troca boa. Não é a chegada.

---

## 4. PORTÃO

| dimensão | nota | por quê, em uma linha |
|---|---|---|
| **Design** | **8** | identidade real e hierarquia certa no estado povoado; reticências no nome do compromisso em AX5 (C), risco do feito ausente (F), quadro de ofertas com forma de lista de sistema (I) |
| **Simplicidade** (`curva-zero`) | **8** | vazio do Traço virou começo e sobrevive em AX5; vazio do Próximo continua 4x2 para uma frase (E), e a recuperação do "desatualizado" aponta para o destino errado (J) |
| **Movimento** | **8** | Reduzir Movimento respeitado e provado, mas por ausência; o gesto de assinatura não tem eco na superfície (H) |
| **Componentes** | **8** | sete peças pequenas, nome em pt, reusadas nas duas famílias, e a lei do estado extraída da view com teste (`EstadoNaFace`, `LinhasDoEstado`) — mas moram no arquivo do widget e não em `Traco/Componentes`, sem preview, e `BlocoProximo` ficou fora do token de escala que os irmãos adotaram (C) |
| **Fora do app** | **7** | superfície entregue e capturada em todos os estados, um toque faz uma coisa (provado), nada protegido exposto, orçamento respeitado — mas a face **afirma um número falso** (A) e larga a maior parte do dia sem dizer (B, D) |

**Veredito: RECUSADO.** Mínimo da esteira é 9; a mais alta aqui é 8.

**O caminho mais curto para o 9** (na ordem em que eu corrigiria):
1. **A** — ou o instantâneo passa a carregar quantos há, ou o "+N depois" deixa
   de ser número quando a lista está cortada. Uma das duas; não as duas metades.
2. **C** — `BlocoProximo` no mesmo `minimumScaleFactor(0.6)` dos irmãos.
3. **B + D** — o médio mostra os três publicados quando cabem, diz o que não
   mostrou, e em AX5 põe *alguma coisa* onde hoje há 55% de vazio.
4. **E** — o vazio do médio do Próximo vira quadro, como o do Traço.
5. **G** — 44 pt nas ofertas e nos atalhos do cabeçalho.
6. **F** e **H** — o risco aparece; o toque tem eco (`.invalidatableContent()`).

---

## 5. Dívida para o RUMO

- **Tema claro fixo em modo escuro.** Decisão coerente com a ADR 02h e boa para
  identidade; o custo noturno (quatro cartões a ~95% de luminância na casa
  escura) é real e ainda não foi pesado por ninguém. Merece uma volta própria,
  não um remendo aqui.
- **Hierarquia inversa entre pequeno e médio do Próximo** (hora 28pt/assunto
  15pt contra assunto em peso no médio). Escolher uma e valer para as duas.
- **Componentes do widget fora de `Traco/Componentes`, sem preview.** Enquanto
  vivem no arquivo do widget, a esteira não consegue julgá-los como componentes.
- **Linhas de agenda que parecem itens de lista e não são endereçáveis:** o
  médio do Próximo leva sempre a `traco://calendario`, nunca ao compromisso
  tocado. Defensável hoje, dívida quando houver tela de compromisso.
- **Feito o Destaque, o pequeno do Traço passa o resto do dia mostrando uma
  tarefa concluída** enquanto há compromissos por vir. A relevância cai (5), o
  que resolve na Pilha Inteligente; numa casa fixa, não resolve.

---

## 6. Três linhas para o LACO

- Os widgets deixaram de falar de si mesmos e passaram a falar do dia: onde
  havia "atualizado às 13:23" e uma frase em quatro por dois, há a única coisa
  de hoje, três compromissos com hora, assunto e alarme, e um vazio que oferece
  três ações reais — e as três rotas abrem exatamente o que prometem.
- O G4 recusa mesmo assim: num dia de cinco compromissos a face mostra dois e
  escreve "+2 depois", que é um número fechado sobre uma lista que ela sabe
  cortada; em tamanho de acessibilidade o nome do compromisso sai "Café com o
  Pe…" e o médio do Traço volta a ser uma frase com 55% de cartão vazio.
- Ninguém precisou da galeria "Adicionar Widget": plantar os quatro widgets
  escrevendo o `IconState.plist` e matando o SpringBoard custa 40 segundos por
  estado — a esteira ganhou de volta a superfície que três revisões não
  conseguiram fotografar.

---

### Capturas (todas minhas, iPhone Air, build deste worktree)

| arquivo | estado |
|---|---|
| `g4-f4-casa-claro.png` | quatro widgets, dia povoado, tema claro, 21:28 |
| `g4-f4-casa-escuro.png` | o mesmo em tema escuro |
| `g4-f4-casa-ax5-claro.png` / `g4-f4-casa-ax5-escuro.png` | AX5 nos dois temas |
| `g4-f4-ax5-reticencias.png` | recorte: "Café com o Pe…" no pequeno do Próximo |
| `g4-f4-cinco-de-cinco.png` | cinco compromissos no calendário, três na face |
| `g4-f4-medio-traco-2-de-5.png` | recorte: dois de cinco e faixa vazia no pé |
| `g4-f4-medio-proximo-3-de-5.png` | recorte: três de cinco, sem "+N" |
| `g4-f4-vazio.png` / `g4-f4-vazio-ax5.png` | quadro de ofertas e o vazio do Próximo |
| `g4-f4-desatualizado.png` | estado honesto nas quatro faces |
| `g4-f4-feito.png` / `g4-f4-feito-sem-risco.png` | feito marcado; ampliação sem risco |
| `g4-f4-reduzir-movimento.png` | Reduzir Movimento ligado |
| `g4-f4-rotas.png` | `traco://nova`, `traco://recordar`, `traco://calendario` |
| `g4-f4-curtos.png` / `g4-f4-medio-traco.png` / `g4-f4-medio-proximo.png` | recortes de leitura |
