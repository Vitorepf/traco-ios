# G4 da volta 12 — Página e Caderno (julgar do design)

Julgador: Claude Opus 5, sessão própria, 06/09/2026. Worktree `volta-12-pagina`,
topo `6e80ace`. Skills carregadas antes de qualquer captura: `design-router`
(fases **Mover**, **Julgar**, **Portão** — as três que cabem ao G4) e
`curva-zero` (a Página é a porta de entrada da escrita). Não editei nem commitei
código.

Simulador: **iPhone 17 Pro C2416CBC** — o meu. `TRACO_SEM_MODELO=1` no ambiente
(motor local, nada gasto na conta do dono), Dynamic Type e Reduzir Movimento
restaurados ao fim (`large`, RM 0), simulador desligado. O iPhone 17 `1A46B6D3`
do dono não foi tocado, e nenhum simulador alheio foi ligado ou desligado.
Instrumento: maestro **só para dirigir** (`--device` preso ao meu UDID, sob
`ferramentas/orca/com-trava.sh`); **toda prova de tela é `xcrun simctl io` preso
ao meu UDID** — screenshot ou vídeo com quadros nativos extraídos por `ffmpeg`,
porque o `takeScreenshot` do maestro não isola com seis simuladores ligados
(lei da ESTEIRA).

---

## Veredito: **CORRIGIR ANTES**

Design **6**, Simplicidade **6**, Movimento **7**, Componentes **9**.

A decisão central da volta está certa e eu a reconfirmei com filme meu: **a régua
e as ações não somem mais sob o dedo**, em nenhum dos dois modos. O que derruba a
volta é o preço que ninguém mediu: com o teclado de pé — o único estado em que se
escreve — **o cartão da forma vestida come o papel inteiro**. O autor escreve e
não vê o que escreveu. A auditoria V9 dizia que o cartão substituía a régua e as
ações; hoje ele substitui **a página**. O defeito não acabou: mudou de lugar, e o
lugar novo é pior, porque o que ele cobre agora é o trabalho do autor.

Achei também a **quinta ocorrência da classe A1** — o encaixe desenhado em duas
geometrias, com texto legível sobre texto legível, com E sem Reduzir Movimento —
e ela está no caminho principal da volta: o toque em "Abrir os campos".

---

## O que se confirmou, e é bom (comparação antes/depois, fase Mover)

| o que | prova minha |
|---|---|
| a régua e as quatro ações **nunca somem** enquanto o cartão vive | `g4-v12-cartao-come-o-papel.png` (simctl, `large`, RM 0) e os 146 quadros de `g4-v12-com-rm.mp4`: régua, "Trabalhar nisto" e as quatro ações estão em **todos** |
| a **chegada** do cartão é revelação, não dissolução | `g4-v12-chegada-limpa-rm.png`, dez quadros nativos consecutivos (80–89) com **Reduzir Movimento ligado**: o cartão cresce de baixo para cima e revela; o texto do papel continua legível e nada dissolve sobre ele. O ganho da V12-C é real |
| **soltar a forma** ("Deixar como nota") é corte limpo | `g4-v12-soltar-limpo-rm.png` e `g4-v12-soltar-com-rm.mp4`, RM ligado: quadro n = cartão, quadro n+1 = cartão fora, quadro n+2 = o texto de volta. Sem fantasma, sem duas geometrias. **Esta é a experiência de controle que prova que o A3 abaixo não é do cartão sair** |
| o **teclado não desce** ao vestir a forma | o foco e o caret sobrevivem em todos os quadros; digitei 37 caracteres depois de o cartão chegar e todos entraram no texto (`g4-v12-escreve-as-cegas.png`, painel 4) |
| o **arquivo pela borda** é gesto, não animação | `f6`, 113 quadros: a camada entra empurrando, com sombra e escurecimento na aresta, seguindo o dedo — interrompível, e nada de texto sobre texto |
| a página **vazia** é calma e honesta | `g4-v12-vazia.png`: data, papel, régua. Nada mais |
| a folha dos campos é bem construída | título como cabeçalho, "voltar" em tinta, "Deixar como nota" fora do âmbar, três campos e "Virar Se–então" |

---

## Achados

### A1 — ALTO. O cartão come o papel: 413 pt de encaixe para 33 pt de página

**Estado:** `large`, RM 0, teclado de pé, forma vestida pela análise automática.
Medido em `g4-v12-cartao-come-o-papel.png` (captura nativa `simctl`, 1206×2622 =
874 pt):

| faixa | pt |
|---|---|
| base de "Notas / Concluir" | 94 |
| **papel visível** | **94 → 127 = 33 pt** |
| cartão WOOP | 127 → 369 (**242 pt**) |
| régua | 401 → 413 |
| "Trabalhar nisto" | 457 → 469 |
| Analisar · Recordar · Anexar · Lente | 506 → 518 |
| topo do teclado | 540 |
| **encaixe inteiro** | **127 → 540 = 413 pt = 47% da tela** |

Nesses 33 pt **não cabe uma linha de corpo**, e o que o autor escreveu —
"quero correr de manhã" — **não está na tela**. Sobra a ponta do caret. O mesmo
estado com Reduzir Movimento ligado: quadros 90, 95 e 100 de
`g4-v12-com-rm.mp4`, papel vazio entre a topbar e o cartão.

**Mecanismo, no código:** `CartaoAnaliseView.swift:75` — `.frame(maxHeight:
acoesNoPe ? 440 : 380)`. O teto do cartão é **absoluto**, não uma fração do que
sobra. Com teclado (334 pt) e o pé que se recusa a ceder
(`PaginaView.swift:537`, `.fixedSize(horizontal: false, vertical: true)`), quem
paga a conta é a única parte elástica: o papel. O comentário do próprio arquivo
promete o contrário — "o pé não cede ao cartão: se falta altura, é o texto do
cartão que rola" —, e o texto do cartão de fato rola **dentro do teto de 440**;
o que não existe é um **piso para o papel**.

**Correção verificável:** o teto do cartão passa a ser `min(440, altura
disponível − piso do papel − pé)`, com piso declarado (proposta: três linhas de
corpo, ≈90 pt, e o caret sempre visível). Critério de aceite: no mesmo fluxo,
com teclado de pé em `large`, a linha escrita continua na tela.

### A2 — ALTO. Escrever às cegas: a ferramenta se impõe, e é a resposta à pergunta do dono

Repeti o cenário do dono — autor escrevendo depressa uma ideia que não quer
perder. Fluxo `depressa.yaml`: escrevi "quero correr de manhã", esperei o cartão
chegar e **continuei escrevendo** " e nadar à noite quando der, sem falta"
(37 caracteres).

`g4-v12-escreve-as-cegas.png`, quatro painéis: nos três primeiros — quadros 950,
1000 e 1035 do filme, durante e depois da digitação — **nenhum caractere aparece
na tela**. No quarto, depois de tocar "Deixar como nota", a frase inteira volta
de uma vez: `02-soltou.png` mostra "quero correr de manhã e nadar à noite quando
der, sem falta". Vinte e quatro quadros amostrados do mesmo trecho (`f2`,
940–1036) são idênticos entre si: o papel não muda enquanto se digita.

O foco não se perdeu — esse ganho da V12-C é verdadeiro — mas **o texto é
digitado num papel invisível**. Não é um piscar de 150 ms: dura o tempo inteiro
em que o cartão está de pé, que é até o autor tocar num botão dele, tocar em
Concluir ou preencher um campo.

**A resposta literal à pergunta:** *acabou de verdade ou só mudou de lugar?*
**Mudou de lugar.** A V9 viu o cartão tomar a régua e as ações; a volta salvou a
régua e as ações e entregou o papel no lugar delas. Do ponto de vista de quem
escreve, a troca piorou: a régua é ferramenta, o papel é o trabalho.

### A3 — ALTO. A quinta ocorrência da classe A1, no caminho principal da volta

Gatilho: **tocar em "Abrir os campos"** no cartão da forma vestida — o caminho
que a própria ADR 05y usa para descrever a jornada.

- **Sem Reduzir Movimento** (`g4-v12-fantasma-sem-rm.png`, quadros nativos
  438–443 de um filme a 28,1 fps = **6 quadros ≈ 215 ms**)
- **Com Reduzir Movimento** (`g4-v12-fantasma-com-rm.png`, quadros 107–116 a
  27,1 fps = **10 quadros ≈ 370 ms**)

Em ambos, no mesmo quadro e na mesma faixa, dois textos legíveis:

| por cima | por baixo |
|---|---|
| "Abrir os campos" · "Deixar como nota" | "RESULTADO (O MELHOR DESFECHO)" e o campo vazio |
| "Trabalhar nisto" | "isto é um desejo com obstáculo / pela frente." |
| "Analisar · Recordar · Anexar · Lente" | "Qual é o hábito ou o medo seu que…" |
| "Todas" (régua) | "OBSTÁCULO INTERNO (O SEU HÁBITO/MEDO)" |

O cartão é desenhado em **duas posições ao mesmo tempo** (botões numa geometria,
corpo noutra, ~380 px de distância). É a assinatura exata do A1 — e é a mesma
fotografia que a ADR 05y descreve como morta: *"o pé do cartão ('Abrir os
campos'/'Deixar como nota') e o pé da página ('Trabalhar nisto' e as ações)
dissolvidos SOBRE o texto do cartão"*.

**Não é o cartão sair.** Fiz a experiência de controle: o mesmo cartão saindo por
"Deixar como nota", com RM ligado, **corta limpo**
(`g4-v12-soltar-limpo-rm.png`). O que distingue o caminho defeituoso é o que
acontece junto: `abrir-campos` chama `sessao.instigarSePreciso()` **e**
`mostrarCampos = true` no mesmo toque (`CartaoAnaliseView.swift:242`,
`PaginaView.swift:405`) — mudança do cartão e apresentação da folha no mesmo
quadro. Não bissectei além disso; é achado de tela, e a bissecção é do
implementador, que já acertou a causa duas vezes por experimento.

**Correção verificável:** no toque em "Abrir os campos", nada legível sobre nada
legível, em nenhum dos dois modos — provado por quadros nativos, como aqui.
Caminho barato a testar primeiro: derrubar o cartão sem animação
(`Transaction.disablesAnimations`, como o `onChange(of: camposComResposta)` já
faz em `PaginaView.swift:158`) antes de apresentar a folha.

### A4 — ALTO. AX5 com o cartão: a página transborda em cima e embaixo

`g4-v12-ax5-cartao.png` (AX5, RM 0, teclado de pé, forma vestida). Quatro coisas
na mesma captura:

1. **"Mais ações da nota" está DEBAIXO do teclado** — `g4-v12-ax5-pe-sob-teclado.png`,
   ampliação 1:1 da faixa: o rótulo aparece borrado atrás do vidro do teclado.
   Em AX esse menu é a **única** porta para Analisar, Recordar, Anexar e Lente
   (V12-B). Quer dizer: no tamanho em que a volta declarou que "as ações nunca
   mais somem sob o dedo", elas somem sob o **teclado**.
2. **"Deixar como nota" está cortado em "Deixar"** — o pé do cartão tem
   `.fixedSize(vertical: true)` (`CartaoAnaliseView.swift:69`) dentro de um teto
   de 440 pt: pede mais altura do que o teto dá, e o `cartao(.flutuante)` corta.
3. **"Notas" e "Concluir" desenhados por cima da barra de status e da ilha** — dá
   para ler o relógio "20:1" através do "Notas". A pilha transborda para cima
   pelo mesmo motivo que transborda para baixo.
4. **Papel = 0 pt.** Nem a frase, nem os campos.

Um mecanismo só: com o teclado de pé em AX5, cartão (teto 440) + "Trabalhar
nisto" + menu não cabem, e o VStack transborda para fora do seu frame nas duas
pontas em vez de dar ao papel — ou ao cartão — o que falta.

**Nota de evidência:** as capturas AX5 da própria volta
(`v12-antes-ax5-vestida.png`, `v12-depois-ax5-vestida.png`) estão **com o teclado
recolhido**, onde tudo cabe. O estado que falha nunca foi fotografado.

### M1 — MÉDIO. A evidência da volta evita o estado que a volta decide

`v12-antes-large-vestida.png` e `v12-depois-large-vestida.png` — o par
antes/depois do estado central — também estão **com o teclado recolhido**. Nas
duas, o texto do autor aparece e tudo cabe. A decisão da volta é sobre o que
acontece **sob o dedo**, e sob o dedo o teclado está de pé. Sem esse estado no
par, o antes/depois prova o caso fácil. (Não é acusação de má-fé: o Re-G3 do
revisor filmou com teclado, e é por isso que a pilha assentada foi aceita. Falta
no acervo da volta, não na cabeça de ninguém.)

### M2 — MÉDIO. Sob Reduzir Movimento o encaixe não corta: encolhe mais rápido

Pergunta do contrato: *"sob Reduzir Movimento, corta seco?"* **Não, e por
desenho.** `Tema.movimento(.deslocamento, …, reduzido:)` devolve `fadeReduzido`
(`Tema.swift:184`), que é `.easeOut(duration: 0.15)` — uma **duração**, não uma
opacidade. A geometria continua animando, só que em 150 ms em vez de 400.
Medido: a chegada do cartão com RM ligado leva **oito quadros nativos** (82–89 na tira de dez) de
crescimento (`g4-v12-chegada-limpa-rm.png`).

Nesse caso o resultado é bom — o encaixe cresce e **revela**, nada dissolve. Mas
é essa mesma regra que faz a classe A1 voltar: **todo `.deslocamento` sob RM
continua sendo uma interpolação temporizada de um container cujos filhos são
texto legível**; basta o SwiftUI trocar a árvore no meio para virar
cross-dissolve de duas geometrias. Enquanto a lei disser "deslocamento vira fade"
e a implementação entregar "deslocamento mais curto", cada volta vai reencontrar
o mesmo fantasma noutro gatilho — três, quatro, agora cinco.

### B1 — BAIXO. Responder à pergunta sem ver o texto

A folha dos campos (`estado-agora.png`) mostra WOOP, os três campos e "Virar
Se–então" — **não mostra a nota**. O autor responde "qual é o hábito ou o medo
seu que vai impedir?" sem ter à vista a frase que gerou a pergunta. `curva-zero`,
§2: comparar/revisar pede visão simultânea. Uma linha com o texto da nota no topo
da folha resolve.

### B2 — BAIXO. Dois detalhes de acabamento

- A folha abre **sem teclado**: o autor toca "Abrir os campos" e precisa de mais
  um toque para começar a escrever no primeiro campo.
- A data "Domingo, 6 de setembro" continua na tela por ≥16 quadros depois do
  primeiro caractere (`primeiro-char.png`), embora o comentário de
  `PaginaView.swift:264` diga "some no primeiro caractere". Cosmético.

---

## Julgar — a Página é onde o autor escreve

**Ela sai da frente?** Vazia, sim: data, papel, régua, nada mais
(`g4-v12-vazia.png`). Escrevendo, sim, até a análise automática vestir a forma —
e a partir daí **não**: 47% da tela vira aparato e o papel vira 33 pt (A1, A2).

**A régua e as ações fixas acima do pé ajudam ou fazem barulho?** Ajudam. Estão
sempre no mesmo lugar, o alvo não se move, e é o ganho real da volta
(fitts-law: alvo estável vale mais que alvo grande). Enquanto se escreve elas são
silenciosas — cinza, sem âmbar, sem movimento. Nada a corrigir aqui.

**O cartão da forma vestida cobre o quê?** Em `large`, com teclado: o texto do
autor e os campos da forma. Em AX5: isso, mais a barra de status em cima e o menu
de ações embaixo. Cobre exatamente o que a `curva-zero` proíbe esconder — o
estado do trabalho —, e não esconde nada de custo ou consequência, que seria
pior.

**Densidade em AX5 com o cartão aberto:** insustentável (A4). Cinco elementos
disputam 874 pt: topbar, papel, cartão de 440, "Trabalhar nisto", menu. Dois
perdem por transbordo e um (o papel) por completo.

### A travessia da `curva-zero`

Roteiro: *escrever → a forma veste sozinha → abrir os campos → concluir.*

| estado | o que vi |
|---|---|
| início/vazio | reconhece e começa sem inventar nada; o cursor já está lá |
| caminho comum | **não cresceu** — quatro passos, e vestir é grátis (não pede toque). Isto é conquista e continua de pé |
| a forma veste | o cartão explica o que aconteceu e oferece as duas saídas no pé dele. Certo. **Mas cobre o texto** (A1) |
| abrir os campos | um toque, folha inteira, todos os campos à vista. **Fantasma de ~370 ms na entrada** (A3); a folha não mostra a nota (B1) |
| voltar/retomar | "voltar" grava e volta; o texto está intacto; a forma continua vestida |
| concluir | disponível o tempo todo no topo, âmbar quando é a vez dele |
| desfazer | "Deixar como nota" a um toque, dentro do cartão e dentro da folha. Bom |
| erro/falha | não exercitado nesta sessão (o G3 cobriu o aviso de gravação) |
| AX5 | **reprova** (A4) |
| Reduzir Movimento | passa em chegada e soltar; **reprova** em abrir os campos (A3) |

Passos, decisões e telas **não cresceram** — a Simplicidade não cai por
contagem. Cai porque o caminho comum passou a esconder o trabalho do autor.

---

## Portão

| dimensão | nota | por quê |
|---|---|---|
| **Design** | **6** | a tela onde o autor passa mais tempo entrega 33 pt de papel contra 413 pt de aparato, e o texto escrito sai da tela (A1); em AX5 a pilha transborda nas duas pontas (A4). O cartão é bonito; a página deixa de ser página |
| **Simplicidade** | **6** | o caminho comum é evidente e não cresceu — isso é verdade e conta. Mas escrever às cegas (A2) e responder à pergunta sem ver o texto (B1) são carga cognitiva nova, exatamente onde a `curva-zero` manda não esconder o estado do trabalho |
| **Movimento** | **7** | chegada, soltar e a borda estão certos e provados nos dois modos — ganho real. Derruba: a quinta ocorrência da classe, no caminho principal, com E sem RM (A3), e o encaixe que não corta sob Reduzir Movimento (M2) |
| **Componentes** | **9** | `CartaoBotaoStyle` apagado, seis estilos e nenhuma duplicata; `.cartao(.papel/.flutuante)`, `BarraBotaoStyle`, `Tema.margem/alvo/gaveta/Duracao` em tudo que li nas duas views; nenhum literal solto de cor, raio ou duração. Os defeitos acima são de **layout e composição**, não do material |
| (Acessibilidade, fora da minha lista) | 6 | A4: o menu das quatro ações debaixo do teclado em AX5, rótulo cortado, topbar sobre a barra de status |

**Nenhuma das quatro chega a 9. Veredito: CORRIGIR ANTES.**

### Lista mínima para reabrir o portão

1. **Piso para o papel.** O teto do cartão (`CartaoAnaliseView.swift:75`) deixa
   de ser 440/380 fixos e passa a respeitar o que sobra: com teclado de pé em
   `large`, pelo menos três linhas de corpo e o caret visíveis. Aceite: repetir
   `depressa.yaml` e ver na tela o que se digita.
2. **AX5 não transborda.** Com cartão e teclado, "Mais ações da nota" acima do
   teclado, "Deixar como nota" inteiro, topbar fora da barra de status. Aceite:
   captura `simctl` no mesmo estado de `g4-v12-ax5-cartao.png`.
3. **A quinta ocorrência.** No toque em "Abrir os campos", nenhum par legível na
   mesma faixa, com e sem Reduzir Movimento. Aceite: tira de quadros nativos como
   `g4-v12-fantasma-com-rm.png`, limpa.
4. **O par antes/depois do estado que decide.** Refazer `*-large-vestida` e
   `*-ax5-vestida` **com o teclado de pé**. Sem isso o acervo da volta continua a
   provar o caso fácil.

### Dívida para o RUMO

- **A classe A1 não se fecha por gatilho.** Três (título+Enter), quatro (chegada
  do pé) e agora cinco (abrir os campos). A causa comum não é cada ramo: é a lei
  de movimento reduzido, que troca deslocamento por deslocamento mais curto
  (M2). Uma volta que declare a regra — *o encaixe nunca é interpolado com dois
  textos legíveis em geometrias diferentes* — e a prenda a um teste ou a uma
  inspeção de tira de quadros vale mais que a sexta bissecção.
- **A folha dos campos sem o texto da nota** (B1).
- **`com-trava.sh` deste worktree ainda é o antigo** (o revisor já apontou):
  esperei ~7 min numa trava de outro worker sem saber de quem era. Confirmar
  antes do G5.

### Três linhas para o LACO

1. A volta cumpriu o que prometeu: régua e ações nunca mais somem sob o dedo, a
   chegada do cartão e o soltar cortam limpo nos dois modos, e o teclado não cai
   mais quando a forma veste — filmado por mim, com Reduzir Movimento ligado.
2. Mas com o teclado de pé o cartão ocupa 47% da tela e deixa 33 pt de papel: o
   autor escreve e não vê o que escreveu, e em AX5 o menu das quatro ações fica
   debaixo do teclado — o defeito da V9 não acabou, trocou a régua pelo papel.
3. E a classe do fantasma tem uma quinta ocorrência no caminho principal da
   volta, ao tocar "Abrir os campos": ~370 ms com Reduzir Movimento ligado, o
   encaixe em duas geometrias, com "Trabalhar nisto" legível sobre o texto do
   cartão.

---

## Capturas e filmes desta sessão

| arquivo | o que prova |
|---|---|
| `g4-v12-cartao-come-o-papel.png` | **A1**: `simctl`, `large`, teclado de pé — encaixe 413 pt, papel 33 pt, a frase escrita fora da tela |
| `g4-v12-escreve-as-cegas.png` | **A2**: três quadros digitando com o cartão de pé (nada aparece) + o quarto, depois de soltar, com a frase inteira |
| `g4-v12-fantasma-sem-rm.png` | **A3**: quadros 436–443, seis com duas geometrias legíveis |
| `g4-v12-fantasma-com-rm.png` | **A3 com Reduzir Movimento**: quadros 107–114 da mesma sobreposição |
| `g4-v12-soltar-limpo-rm.png` | a experiência de controle: soltar a forma corta limpo, RM ligado |
| `g4-v12-chegada-limpa-rm.png` | a chegada do cartão revela, não dissolve, RM ligado (e mostra os oito quadros de crescimento do M2) |
| `g4-v12-ax5-cartao.png` | **A4**: AX5 com cartão e teclado — papel 0, "Deixar" cortado, topbar sobre a barra de status |
| `g4-v12-ax5-pe-sob-teclado.png` | **A4**: "Mais ações da nota" atrás do vidro do teclado, ampliado |
| `g4-v12-vazia.png` | a página vazia, o estado calmo |
| `g4-v12-sem-rm.mp4` | vestir → abrir os campos, **sem** Reduzir Movimento (5,4 s) |
| `g4-v12-com-rm.mp4` | o mesmo, **com** Reduzir Movimento (5,4 s) |
| `g4-v12-soltar-com-rm.mp4` | soltar a forma, com Reduzir Movimento |

## Limites honestos desta prova

- **A sábia não foi julgada.** `TRACO_SEM_MODELO=1` desliga o motor remoto; a
  chegada de `.sabiaPensando` → `.resposta` não foi filmada e não entra em nota.
  Não gastei conta do dono para isto.
- **Não medi VoiceOver nem Instruments.** O A4 é geometria e leitura de tela, não
  leitor de tela.
- **Não bissectei o A3.** Isolei o gatilho e a experiência de controle; a causa é
  do implementador.
- **Estados de falha e sem permissão** não foram reexercitados: o G3 os cobriu e
  a volta não os tocou desde então.
- Um simulador, um UDID, toda prova por `simctl io`. Nenhum arquivo do branch foi
  editado; este relatório e as capturas `g4-v12-*` ficam untracked em
  `ferramentas/orca/`.
