# G4 da volta L1 — latência da descoberta. Julgar do design.

**Interrompido por ordem do dono às 23h de 06/09**, com o julgamento formado e as
medidas feitas. O que ficou por medir está listado no fim, na ordem em que eu
retomaria. Não editei código e não commitei código: só este relatório e as minhas
capturas.

Meu simulador: iPhone 17 Pro Max `6033B043-F436-41F9-B4F8-2D9E67761980`, o único
que liguei e o único que toquei. Topo julgado: `747f651`.

Skills carregadas antes de olhar a tela: `design-router` (fases **Mover**,
**Julgar**, **Portão** — as três do meu papel) e `curva-zero`.

---

## Instrumento, declarado

Três simuladores estiveram ligados na máquina durante o meu trabalho
(`B91C8DEF`, `34CC3F94` e o meu). Pela lei da ESTEIRA, **nenhuma linha deste
relatório se apoia em asserção do maestro** — não usei maestro em momento nenhum.

Dirigi o meu simulador sem maestro, por um caminho que quero deixar escrito
porque foi a parte que me custou tempo: levantei a janela do MEU simulador pelo
nome (`AXRaise` na janela cujo título contém "Pro Max"), medi a janela
(`100,96`, `405×931`), calibrei a escala contra a tela do aparelho
(440×956 pt → fator 0,9205 em x, 0,9215 em y, topo da tela do aparelho 50 pt
abaixo do topo da janela por causa da barra de título) e daí em diante todo
toque e todo arrasto saiu de dois scripts de três linhas (`/tmp/tap.sh`,
`/tmp/drag.sh`) em coordenadas do aparelho. **Isso resolve o beco do cliclick
que cai na janela do vizinho:** o problema não era o cliclick, era clicar em
coordenada de tela sem levantar e medir a janela certa antes. Toda prova de tela
é `xcrun simctl io <meu UDID> screenshot`.

Build meu, sob `com-trava.sh`: `** BUILD SUCCEEDED **`. Semeadura pelo
`ferramentas/orca/semear-latencia.py` do próprio repositório, modos A e B, mais
um estado vazio que eu produzi apagando `ZNOTA`/`ZTRABALHO` do meu contêiner.

**Sabido e não conto como achado:** a série é semeada, o simulador não viaja no
tempo, e isso já está na ADR, na EVOLUCAO e no relato. O ida-e-volta pelo app já
foi provado no G3 e eu não o repeti.

---

## A pergunta central, respondida primeiro

> O autor olha essa seção e entende **que capacidade dele está sendo mostrada** —
> o tempo que ele leva para descobrir que errou — ou parece mais uma lista de
> pendências?

**Entende. E a seção não o faz sentir devendo.** Essa é a parte difícil do
contrato e ela foi cumprida. Procurei o placar disfarçado item por item e não
achei nenhum:

| o que eu procurei | o que a tela tem |
|---|---|
| número grande no topo | não há número solto; o topo é uma frase em `Tema.chrome` |
| ordem que parece ranking | os meses estão em ordem **cronológica**, não por valor; ordenar por duração viraria pódio e ninguém ordenou |
| palavra que parece nota | nenhuma: "meta", "sequência", "streak", "%" não aparecem |
| "melhorou/piorou" | a tela **descreve e não conclui** — `emPalavras` não tem um só adjetivo de juízo |
| cor de bom e ruim | nenhuma. Todos os quatro estados saem no mesmo cinza (`tintaFraca`). Isso é o acerto mais importante da seção |
| verbo de obrigação | nenhum. "devido" é definido no próprio parágrafo como estado, e "em aberto há 17 dias" é uma **duração**, não uma cobrança |
| ação a cumprir | nada é tocável. Não há chevron, não há botão, não há alvo. A seção só se lê |

E o parágrafo de abertura diz, com as palavras do dono, as três coisas que o
contrato exigia: "não há nada a preencher aqui", "hipótese sem resposta é
informação", "abandonar é resultado". A tela cumpre o que o parágrafo promete.

**Onde a leitura escorrega — e é um achado real.** No MODO B (18 em aberto, que é
o estado do dono daqui a alguns meses, `g4-l1-modo-b-dezoito-abertos.png`) a
frase-resumo é:

> "4 descobertas com as duas datas · a do meio levou 13 dias · 2 sem a data da
> descoberta · **18** em aberto · 2 abandonadas"

A medida lidera a frase, o que está certo. Mas cinco fatos num só período colado
por "·" fazem o olho parar no número que destoa, e o número que destoa é o **18**.
Logo abaixo, a lista abre com quatro linhas seguidas de "em aberto há 119 dias /
118 dias / 117 dias / 17 dias". Nada ali é cobrança, mas o *inventário* fica em
primeiro e a *capacidade* fica no meio.

Não peço para esconder o 18 — esconder os abertos é exatamente o viés de
sobrevivência que esta ideia veio combater, e mantê-los ao lado dos fechados é a
decisão mais correta do modelo. Peço uma quebra de linha: **a medida numa linha,
a composição do resto numa segunda linha mais quieta**. Mesma informação, mesmo
número, e o resumo volta a ter uma manchete só. É uma linha de código.

---

## A decisão que me pediram para julgar: tirar a barra

**Foi certa, e eu não a devolveria.**

A barra normalizada pela série codificava **posição no ranking, não duração**: um
mês de mediana 300 dias e outro de mediana 1 dia enchiam a pista igual. Isso não
é um gráfico ruim, é um gráfico que **afirma uma coisa falsa** — e numa seção cujo
contrato inteiro é estado honesto, um encoding mentiroso é pior do que nenhum.
Tirar foi coerência, não desistência.

**A série ainda se lê?** Sim, no estado que eu vi
(`g4-l1-secao-inteira.png`): três linhas de forma idêntica — mês · duração ·
contagem — alinhadas, varríveis, com a contagem ao lado para o autor descontar
sozinho um mês de `n=1`. Virou **texto honesto**, não lista ilegível.

**Falta apoio visual? Não — e vou dizer qual seria e por que cada um falha**,
porque a pergunta merece resposta e não encolher de ombros:

- **Escala absoluta em dias.** É a única honesta e não cabe: num intervalo real de
  1 a 300 dias em 340 pt de largura, todo mês bom vira um traço invisível. Mostra
  o pior mês e apaga o resto. Já está dito na tarefa e eu confirmo.
- **Escala logarítmica.** Desonesta por outra porta: comprime justamente a
  diferença que interessa (9 dias contra 90) e ninguém a lê sem legenda.
- **Sparkline / barra renormalizada.** Volta ao defeito de origem com outra forma.
- **Dot plot com eixo em dias.** É o único desenho honesto que existe aqui, e
  precisa de altura vertical que o Perfil não tem para dar. Não vale.

**O que falta não é escala, é horizonte.** A `paraTela` corta os registros em doze
com cota por estado — decisão boa, conferida na tela, os quatro estados sobrevivem
ao corte. Mas **a lista de meses não tem corte nenhum**: `ForEach(lista)` sobre
`s.meses` inteiro (`PerfilView.swift:258`). Com três meses semeados fica ótimo. No
aparelho do dono, com a série real de dois anos, são 24 linhas — e em AX5, 24 × 3
linhas de texto. A barra era o que deixava muitos meses serem lidos de relance; ela
saiu (com razão) e o teto não entrou no lugar dela.

**A correção que eu assino:** os últimos 12 meses, e a frase de apoio passa a dizer
o horizonte ("nos últimos 12 meses, o tempo do meio entre as descobertas de cada
mês"). Uma linha de `prefix`, uma palavra na copy, e o problema deixa de existir
para sempre — sem gráfico nenhum.

**Um segundo detalhe de honestidade que a saída da barra não resolveu:** um mês com
uma descoberta só imprime "setembro de 2026 · 2 dias · 1 descoberta" sob o título
"o tempo do meio entre as descobertas daquele mês". Chamar de "tempo do meio" o
único valor que existe é um exagero minúsculo, e a contagem ao lado o desarma —
mas é grátis dizer "1 descoberta · levou 2 dias" quando `quantas == 1`. Mesmo
número, sem estatística falsa.

---

## 1. JULGAR — como o autor olharia

Ver as capturas `g4-l1-chegada-ao-cartao.png`, `g4-l1-secao-inteira.png`,
`g4-l1-registros-fim.png`, `g4-l1-vazio.png`.

**O que está certo e é difícil:** o silêncio da paleta. Quatro estados, um cinza
só. Nenhuma volta anterior deste app resistiu tão bem à tentação de colorir.

**Dois defeitos de sistema, provados, pequenos de corrigir:**

**(a) A seção usa um token que o próprio Tema reserva para fora do app.**
`Tema.miudo` está documentado em `Tema.swift:75` como *"12 — só FORA do app
(ADR 05u): a faixa compacta da Ilha e o rodapé do widget não têm 15pt"*. Rodei a
varredura:

```
$ grep -rn "Tema.miudo" Traco
Traco/Perfil/PerfilView.swift:256
Traco/Perfil/PerfilView.swift:285
```

**Os dois únicos usos dentro do app, no app inteiro, são as duas linhas que esta
volta acrescentou.** E a linha 285 é justamente a que carrega a medida
("descoberto · levou 9 dias"): o número que a seção existe para mostrar está no
menor corpo tipográfico do produto, num degrau reservado ao rodapé de um widget.
O degrau de apoio dentro do app é `Tema.meta` (15, "metadado, legenda, apoio") e
é exatamente o que essas duas linhas são.

**(b) A hierarquia dentro de cada registro é quase nula em tamanho padrão.** O par
é `Tema.miudo` + `tintaFraca` em cima e `.footnote` + `tintaSuave` embaixo: 12 pt
contra 13 pt, e dois cinzas que o próprio `Tema.swift:23` descreve como *"ficou
perto do `tintaSuave` — dois cinzas que quase se encostam. Um deles deve morrer
(FILA)"*. Em `g4-l1-secao-inteira.png` as duas linhas de cada registro lêem-se
como uma massa só — e é isso, mais do que a ordem, que faz a lista parecer parede
no MODO B. Em AX5 o par se separa e funciona (`g4-l1-ax5-registros.png`), o que
confirma que o problema é de degrau, não de conceito.

Contraste, medido do Tema e não do olho: `tintaFraca` 5,04:1 e `tintaSuave` 5,7:1
sobre o papel. Ambos passam. Não há achado de acessibilidade de cor aqui.

**Densidade dentro de um Perfil que a V9 já dava 7,7 com Simplicidade 6.** Esta é
a nota que mais pesa e a medida é minha. Varri o Perfil inteiro em AX5, com passos
de arrasto iguais, capturando cada passo (40 capturas). O cartão da latência
começa a aparecer no passo 9 e termina no passo 15: **sozinho, ~6 a 7 telas cheias
de rolagem em AX5**, contra ~1,5 de "A sábia e você" e ~2 de "Férias". Em tamanho
padrão ele é o cartão mais alto do Perfil, e não cabe numa tela. E isso com três
meses e doze registros — com a lista de meses sem teto, esse número só cresce no
aparelho onde a série é de verdade.

**No estado vazio** (`g4-l1-vazio.png`) o cartão gasta sete linhas de prosa para
entregar zero dado — o parágrafo explicativo sai inteiro antes de haver o que
explicar. O vizinho "A sábia e você" resolve o mesmo momento com uma linha
("ainda não há retrato — ele nasce das suas notas e dos sinais"). O texto vazio da
latência, porém, acerta no essencial e eu registro o acerto: ele diz que a série
nasce de coisas **que o autor já faz**, e não pede nada em troca da medida.

## 2. MOVER — há movimento?

**Não há, e está certo.** Nenhuma animação, nenhuma transição, nenhum
`withAnimation` na seção. É uma superfície de leitura: mover números que medem
honestidade seria decoração em cima de um contrato de sobriedade, e o portão
aceita a ausência desde que dita — fica dita aqui.

Uma observação de estado, não de movimento: `serieDaLatencia` nasce vazia e só é
preenchida no `.task`, de modo que o texto "ainda não há série" é o primeiro a ser
desenhado e depois troca sem transição. Na prática não se vê, porque a seção está
longe do topo da rolagem. Fica anotado como risco, não como defeito visto:
`lerLatencia()` é síncrona no MainActor e faz um `Versoes.listar` por decisão —
o próprio código já admite isso num comentário `ponytail:`. No aparelho do dono,
com centenas de decisões, essa troca pode virar visível. Não é dimensão minha;
vai para o RUMO.

## 3. `curva-zero` — o autor ganha isto sem fazer nada a mais?

**Ganha. Sem ressalva.** Conferido no código e na tela:

- Nenhum campo novo nasceu nesta volta. `lerLatencia()` lê `trabalhos` e `notas`
  que já existem; a medida sai de `Hipotese.data`/`avaliadaEm` e do par
  espero/aconteceu que já eram gravados.
- Nada na seção é tocável, alternável ou preenchível. Não há um só alvo.
- O texto vazio não pede trabalho novo: manda propor hipótese num Trabalho e
  escrever Decisão com data de conferir — as duas coisas que o autor já fazia
  antes da volta existir.

**Uma tensão que eu resolvo a favor do que está lá:** o autor lê "devido · em
aberto há 17 dias · publicar o vídeo ou refazer o roteiro" e não tem como ir dali
até a nota. É uma lacuna de recuperação pelo manual da `curva-zero`. Mas tornar a
linha tocável transformaria a seção em fila de trabalho, que é precisamente a
cobrança que o contrato proíbe. **Deixar sem toque é a escolha certa** — só deve
ser escrita como decisão na ADR, e não ficar parecendo esquecimento.

---

## Portão

| dimensão | nota | evidência |
|---|---|---|
| **Design** | **8** | Paleta silenciosa, nenhum placar, nenhum encoding mentiroso — o conceito está certo. Abaixo de 9 por dois fatos de token, ambos provados por `grep` e pelo comentário do próprio `Tema.swift`: `Tema.miudo` é usado dentro do app pela primeira vez em todo o produto contra a reserva explícita da ADR 05u, e cai na linha que carrega a medida; e o par 12pt/`tintaFraca` + 13pt/`tintaSuave` não produz hierarquia legível em tamanho padrão (`g4-l1-secao-inteira.png`). |
| **Simplicidade** | **7** | Medida minha em AX5, 40 capturas com passo constante: o cartão sozinho ocupa ~6–7 telas cheias (passos 9 a 15), contra ~1,5 do vizinho, dentro de um Perfil que já vinha com Simplicidade 6. A lista de meses **não tem teto** (`PerfilView.swift:258`) enquanto a de registros tem — no aparelho onde a série é real, é o pedaço que cresce sem limite, e é justamente de onde a barra saiu. |
| **Movimento** | **9** | Ausência deliberada numa superfície de leitura, dita e aceita. Nada a respeitar em Reduzir Movimento porque nada se move. |
| **Componentes** | **9** | Reusa `.emCartao()` e `rotulo(...)`, segue a anatomia de cartão que o Perfil já tinha, nomes em português, sem duplicata. Os dois construtores novos são privados e sem preview — como **todas** as outras oito seções do arquivo; é padrão herdado, não introduzido, e não desconto por ele. |

### Veredito

**NÃO PASSA**, por Design 8 e Simplicidade 7 — e faço questão de dizer o que isso
*não* significa: a pergunta central foi respondida bem, a seção não cobra, o
contrato de estado honesto está cumprido na tela, e tirar a barra foi a decisão
certa. O que separa esta volta do 9 são quatro correções pequenas e todas
verificáveis:

1. **Teto de 12 meses na lista de meses**, com o horizonte dito na copy
   ("nos últimos 12 meses…"). É o que substitui a barra sem mentir. (`prefix`)
2. **`Tema.miudo` → `Tema.meta`** nas duas linhas: sai o token reservado a fora do
   app, e a medida deixa de ser o menor texto do produto.
3. **Quebrar a frase-resumo em duas linhas** — a medida sozinha, a composição
   (sem data / em aberto / abandonadas) numa segunda linha mais quieta. Nenhum
   número sai; o "18" para de ser manchete.
4. **`quantas == 1` diz "1 descoberta · levou 2 dias"**, sem chamar de "tempo do
   meio" o único valor que existe.

Nenhuma delas mexe no modelo, em teste, ou no que a seção mede.

### Dívida para o RUMO

- **Decisão não tem porta para `abandonado`.** Já está no RUMO e eu confirmo pela
  tela: a hipótese abandona quando o Trabalho encerra, a decisão não abandona
  nunca. A que o autor nunca vai responder fica devida para sempre — e é o único
  lugar da seção onde o instrumento cria uma dívida que o autor não pode quitar.
  Enquanto não houver o gesto de "não vou conferir esta", nenhum ajuste de
  tipografia resolve isso.
- **Extrair os cartões do `PerfilView`.** 935 linhas, nove seções inline; esta
  volta somou 125 (+15%) ao arquivo que a auditoria já apontava como a pior tela.
  Não é falta desta volta, é a conta acumulada.
- **`lerLatencia()` síncrona no MainActor**, um `Versoes.listar` por decisão. O
  código já admite. Medir no aparelho do dono antes de otimizar.
- **Um dos dois cinzas deve morrer** (`Tema.swift:23`, já na FILA). Esta seção é
  a segunda superfície a pagar o preço deles.

### Três linhas para o LACO

- A medida existe e não cobra: quatro estados, um cinza só, nada tocável, nenhuma
  palavra de meta ou sequência — o autor lê o tempo que leva para descobrir que
  errou, não uma lista do que deve.
- Tirar a barra foi certo: ela desenhava posição na fila e não duração, e as
  palavras dizem a mesma série sem mentir; falta só um teto de meses no lugar
  dela, porque no aparelho do dono a lista cresce sem fim.
- Não passou por dois motivos pequenos e provados: a linha que carrega a medida
  está no degrau tipográfico reservado a fora do app, e o cartão sozinho ocupa
  seis telas em AX5 dentro do Perfil que já era o problema.

---

## O que ficou por medir (ordem em que eu retomaria)

1. **Modo escuro** da seção — não cheguei a olhar; os dois cinzas podem se
   comportar diferente no escuro e é onde a hierarquia (b) pode piorar ou sumir.
2. **MODO B em AX5** — vi o MODO B em tamanho padrão e o MODO A em AX5; falta o
   cruzamento, que é o pior caso real (18 abertos × corpo grande).
3. **VoiceOver real**, com a fala ligada. Conferi no código que cada registro é
   `accessibilityElement(children: .combine)` e que os identificadores existem,
   mas não escutei a leitura. As linhas de mês **não** são combinadas — cada
   `Text` é um elemento; provavelmente certo, não verificado no ouvido.
4. **Alvo de 44 pt** — não se aplica: não há um só alvo na seção. Registro como
   n/a com motivo, não como aprovado.

## Capturas deste G4

| arquivo | o que prova |
|---|---|
| `g4-l1-secao-inteira.png` | a seção inteira em tamanho padrão, MODO A: rótulo, parágrafo, resumo, três meses em palavras (sem barra) e o começo dos registros |
| `g4-l1-chegada-ao-cartao.png` | como o cartão chega ao olho vindo do vizinho de cima ("A sábia e você"), para julgar densidade em contexto |
| `g4-l1-registros-fim.png` | o fim da lista de registros e a fronteira com o cartão "Métodos" |
| `g4-l1-modo-b-dezoito-abertos.png` | o pior caso: 18 em aberto, o "18" na frase-resumo e as quatro linhas de "em aberto há 119/118/117/17 dias" abrindo a lista; e a prova de que "SEGREDO SELADO" não vaza |
| `g4-l1-modo-b-fim-da-lista.png` | o corte por estado sobrevivendo no MODO B: descobertos e abandonados ainda presentes com 18 abertos na frente |
| `g4-l1-vazio.png` | o estado vazio: sete linhas de prosa para zero dado, e o texto que não pede nada em troca da medida |
| `g4-l1-ax5-cabecalho.png` | AX5: o rótulo e o começo do parágrafo enchendo a tela, sem clipe e sem truncar |
| `g4-l1-ax5-resumo-e-meses.png` | AX5: a frase-resumo de cinco fatos ocupando seis linhas, e a primeira linha de mês |
| `g4-l1-ax5-paragrafo-ocupa-tela.png` | AX5, passo 10 de 40: o parágrafo explicativo sozinho ocupando uma tela inteira |
| `g4-l1-ax5-registros.png` | AX5, passo 14 de 40: os registros — e a prova de que em corpo grande o par de cinzas **se** separa, ao contrário do tamanho padrão |
