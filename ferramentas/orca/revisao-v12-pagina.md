# G3 da volta 12 — Página e Caderno até 9 (revisão independente)

Revisor: Claude Opus 5, sessão própria, 06/09/2026. Worktree `volta-12-pagina`,
topo `337a22e`. Diff de código `0d0d007..5937943`; docs e evidência no range
inteiro `0d0d007..337a22e`. Simulador do revisor: **iPhone 17 Pro C2416CBC** —
ligado, usado, restaurado (`content_size large`, `ReduceMotionEnabled` false,
`TRACO_SEM_MODELO` limpo, privacidade reposta, app desinstalado) e deixado
ligado só porque não estava ligado por mim antes desta sessão; nenhum simulador
alheio foi tocado. Todo `xcodebuild` e todo maestro passaram por
`ferramentas/orca/com-trava.sh`. O revisor não editou nem commitou código.

**Veredito: CORRIGIR ANTES.** Cinco dimensões abaixo de 9 (Movimento 6,
Correção 7, Design 8, Acessibilidade 8, Estado honesto 8). A decisão central da
volta — o pé não some mais — **está provada e é boa**. O que a derruba é que a
lei que a ADR escreve para o movimento não é a que está na tela, e que a
migração para `.cartao` apagou, sem declarar, as camadas que separavam o aviso
de falha do papel.

---

## O que se confirmou (instrumento e números do implementador)

| declaração | conferência do revisor |
|---|---|
| suíte 716/0 em 125 suítes na árvore mesclada | **reproduzida**: `✔ Test run with 716 tests in 125 suites passed after 10.604 seconds.` no C2416CBC, via `com-trava.sh xcodebuild test` |
| build sem aviso novo | confirmado: só os dois pré-existentes, `ConferenciaTrabalhoTests.swift:381` (`var 'd'`/`var 'p'` nunca mutados) |
| Swift do app +158 −213 = −55 líquidas | confirmado: `git diff --shortstat 0d0d007..5937943 -- 'Traco/*.swift'` → 10 arquivos, +158 −213 |
| testes +33, nenhum arquivo de código novo | confirmado; `--diff-filter=A -- '*.swift'` volta vazio |
| balanço bruto +18 contra o HEAD do merge | confirmado: range inteiro +234 −216 = +18, a F3 entrou junto (declarado) |
| `CartaoBotaoStyle` apagado, seis estilos e não sete | confirmado: `PressaoDiscreta`, `PressaoClara`, `BotaoPrimario`, `BotaoCompacto`, `BarraBotaoStyle`, `AcaoTrabalhoStyle` |
| ADR 05y no fim da SPEC, em ordem com a 05w | confirmado, nessa ordem; EVOLUCAO coerente nas duas linhas tocadas |
| aba do arquivo com 44 pt de alvo | **medido, não aceito**: `aba-arquivo` = **44 × 104 pt** no dump de hierarquia. Também medidos: `abrir-campos` 166×44, `trabalhar-nisto` 362×44, `Analisar` 84×44 |
| fluxos maestro | **VARREDURA VERDE** em 7 fluxos tocados pela mudança (`aba-arquivo`, `gesto-camadas`, `auto-analise`, `barra-de-baixo`, `caderno-regua`, `forma-folha`, `ax5`). `maestro/varrer.sh` recusa rodar (6 simuladores de outros workers ligados; desligá-los é proibido) — rodei o mesmo roteiro preso ao meu UDID, com `TRACO_SEM_MODELO=1`, por `com-trava.sh` |

**A decisão central está provada na tela.** `v12-rev-large-assentado.png` e
`v12-rev-aviso-regua-pe.png` (minhas capturas, `large`, teclado de pé) mostram a
pilha assentada: aviso/cartão → régua (`Título · Seção · Lista · Numerada ·
Tarefa | Todas ⌨`) → `Trabalhar nisto` → `Analisar · Recordar · Anexar · Lente`,
sem sobreposição. A tira `v12-pe-quadros.png` faz o contraste honesto: na linha
de main o pé some e não volta; nas duas do branch ele está em todos os quadros.

**Os limites declarados são limites de verdade, não desculpa:**

- `BarraBotaoStyle` troca a opacidade do **fundo** (0,85 → 1), não do rótulo —
  não mexe no contraste do texto. Desenho do dono (05f). Legítimo.
- A régua cede ao cartão **só em AX**: `esconderRegua: sessao.cartao != nil &&
  tamanhoTexto.isAccessibilitySize`. Em `large` a régua fica, e eu vi.
- A oscilação da aba na página vazia: não a reproduzi de forma diferente do que
  ele descreve; aceito como anterior à volta e como item de FILA.
- O cartão "sem conta": o simulador responde mesmo. Aceito.

**A guarda de `Camadas` é sã.** `Sessao.irPara` recusa de forma **síncrona**
(timer ligado → `confirmacao`; `salvar` falso → `return`), então o getter
`sessao.aba != .escrever` ainda devolve o valor velho quando
`if arquivoAberto != alvo` roda no quadro seguinte. A correção pega. Falta o
teste (ver Correção).

**O degradê responde ao G4 da V8, inclusive em AX5.** Recorte a 3× de
`AX-cartao.png` (meu, AX5): "deseio com" some em fade até o branco, sem corte
seco a meio glifo.

**A linha "lendo…" melhorou de lei.** O ponto pulsante com
`.repeatForever` saiu e entrou o `LinhaDeEstado` que já existia — que por ADR
05t não tem glifo nem laço. Menos código e menos movimento perpétuo.

---

## Achados

### ALTO

**A1 — Movimento: o cross-fade entre irmãos legíveis existe, com e sem Reduzir
Movimento.** A ADR 05y decide "quem anima é a ALTURA do container (§21)" e o
comentário que ficou em `PaginaView.acimaDoPe` diz "um sai, o outro entra". O
comentário que foi **apagado** do antigo `rodapeUnico` era o mais preciso:
*"cross-fade deixava as DUAS barras legíveis nas mesmas linhas por um quadro
inteiro (g111; g112: a régua legível DENTRO do cartão)"*. Esse defeito está de
volta.

Evidência, na ordem em que pesa:

1. **Na evidência do próprio implementador.** `v12-pe-quadros.png`, última
   coluna, **linhas 2 e 3** (branch sem RM e branch **com** RM) — recorte a 4×
   em `v12-rev-quadros-ultima.png`: a régua `Título Seção Lista Numerada Tarefa
   | Todas ⌨` está legível em **duas posições ao mesmo tempo**, uma delas na
   **mesma linha de base** de `Trabalhar nisto`; e o texto do cartão anterior
   ("vai impedir — não o relógio, não os outros?", "⇢ Virar Se–então", "Abrir os
   campos", "Deixar como nota") dissolve **sobre** o texto do cartão novo, nas
   mesmas linhas. A tira é apresentada no relato como prova de que o pé
   permanece — permanece —, mas a mesma tira contém o defeito.
2. **Reproduzido por mim, independente.** `v12-rev-cruzamento-regua-pe.png`
   (C2416CBC, `large`, **sem** Reduzir Movimento, captura cheia do maestro): a
   régua inteira está legível, fantasma, exatamente sobre a pílula de
   `Trabalhar nisto`.

Que seja transitório não o salva: a linha 3 da tira é **com Reduzir Movimento**,
e sob RM dois textos legíveis não se dissolvem um no outro. A causa provável
(orientação, não correção — quem corrige é o dono da área): `acima` é um
`AnyView` cujo **conteúdo** troca dentro de uma identidade só, então o SwiftUI
faz cross-fade de conteúdo; e a régua sai por `.transition(.move(edge:
.bottom))`, que a desliza **por cima** do rodapé — o `.clipped()` está no VStack
inteiro e não separa irmão de irmão.

Derruba **Movimento**. Pela regra da ESTEIRA ("o revisor confere a citação
contra o que está na tela"), a fase **Mover** do `design-router` está citada mas
não se sustenta.

### MÉDIO

**M2 — Design/Estado honesto: a migração para `.cartao` apagou camadas sem
declarar.** Nenhuma das duas perdas está na ADR, no relato ou no "o que ficou de
fora".

- Cartão da análise: antes `superficieAlta` + `Sombra.flutuante` + **segunda
  sombra de contato** (`sombraContato`, r2 y1) + borda de luz (`luzBorda`) +
  traço `Tema.linha` 0,5. Depois, `.cartao(.flutuante)` = preenchimento + **uma**
  sombra. `luzBorda` é branco sobre branco no tema claro (perda nula), mas a
  sombra de contato e o fio de 0,5 são reais. O raio não mudou (`raio` =
  `raioCartao` = 12) — isso está certo.
- **Aviso/toast**: antes `superficieAlta` + `linha` 0,5 + `sombraContato`.
  Depois `.cartao(.papel)` = **sem sombra e sem borda**. Sobre `Tema.fundo`
  (#F4F4F2) um bloco branco sem aresta é a separação mais fraca da página — e é
  nessa superfície que mora a linha de gravação recusada da ADR 05s. O comentário
  do próprio `Tema` diz por que isso importa: *"um retângulo mais claro SEM borda
  lê como buraco, não como objeto acima do plano"*.

Derruba **Design** e **Estado honesto**. O acerto estrutural — o aviso vive no
fluxo, acima do pé, e não cobre mais a barra — eu confirmei na tela
(`v12-rev-aviso-regua-pe.png`); o que falta é a aresta.

**M1 — Correção: nenhum dos sete comportamentos novos tem teste.** O único teste
novo (+33 linhas) é um lint de fonte:
`paginaECadernoCitamComponentesENaoPressionamPorOpacidade` faz grep de
`tracking(Tema.trackingLabel)`, `PressaoDiscreta()`, `Mola` sob `.deslocamento` e
`.opacity(configuration.isPressed`. É uma boa guarda de regressão de estilo e não
prova nada do que a volta decidiu. Sem teste ficam, entre outros: `Camadas`
devolvendo a posição quando o binding recusa (um ramo dentro de um gesto, e é a
**re-**G3 da V7 — já voltou uma vez), e `esconderRegua` passar a depender de AX.
A ESTEIRA pede "comportamento novo coberto por teste"; a suíte está verde sobre
o comportamento velho.

**M3 — Acessibilidade: "cinco ações a um toque" não é o que a tela faz.** Nada
se perdeu — dumpei a árvore com o menu aberto em AX5 e as cinco estão lá:
`Lente da língua` [16,135], `Anexar arquivo` [16,261], `Recordar` [16,387],
`Analisar` [16,513], `Trabalhar nisto` [16,639]. Mas com o cartão em cena o menu
é mais alto que a tela: em `v12-rev-ax5-menu.png` só **Anexar, Recordar,
Analisar e Trabalhar nisto** estão desenhados; **Lente** só aparece depois de
rolar (`v12-rev-ax5-menu-rolado.png`), e aí quem sai é `Trabalhar nisto`. O iOS
ancora o menu para cima, então o "primeiro" da ADR fica por **último** na tela.
A frase da curva-zero ("mesmo poder a um toque") e a da ADR ("'Trabalhar nisto'
primeiro") não são o que se vê. Para o VoiceOver está tudo certo; para o olho em
AX5 uma das cinco exige uma rolagem sem afordância — e antes desta volta
`Trabalhar nisto` era um botão visível no pé.

### BAIXO

- **B1** Duas capturas "depois" são **byte a byte idênticas** (md5) às "antes":
  `v12-depois-ax5-arquivo.png` e `v12-depois-large-vazia-com-aba.png`. Bate com
  o diff de 0 px declarado, e o conteúdo delas é real (conferi: é a camada Notas
  em AX5, com "Todas · WOOP · S…" e "nada aqui ain…"). Mas um arquivo idêntico
  não testemunha sozinho o build do branch — os outros pares diferem no relógio,
  então a identidade aqui é sorte ou cópia. Cura: `simctl status_bar` fixo, para
  a identidade ser de projeto.
- **B2** O relato diz "27 PNG, maior 328 KB". A maior é
  `v12-antes-large-sabia.png`, **397 KB**.
- **B3** `Tema.Duracao.pulso` ficou órfã: o único consumidor (o ponto do
  "lendo…") saiu nesta volta, e o comentário dela ainda diz "o laço do ponto
  'lendo…'". A classe `.laco` também não tem mais usuário fora de um `switch`.
- **B4** Literais de geometria novos sem token: degradê `height: 24`, teto do
  cartão `440` em AX, `padding(.leading, 15)`. O lint novo não pega geometria —
  são comentados, mas ficam.
- **B5** Performance foi declarada "n/a: nenhuma medida feita" enquanto entrou um
  `onScrollGeometryChange` no ScrollView do cartão. O fecho devolve `Bool`, então
  o `action` só dispara na troca — não vi hitch e não meço o que não medi; fica
  como nota, não como achado.

---

## Scorecard

| dimensão | nota | evidência |
|---|---|---|
| Visão | **10** | entra no ciclo MULTIPLICAR pela porta de entrada da escrita; fecha a lacuna nomeada "Direção visual e uso simples" — diff do EVOLUCAO no range, linha reescrita com a 05y |
| Contrato | **9** | ADR 05y no fim da SPEC, depois da 05w, em ordem cronológica; EVOLUCAO coerente nas duas linhas tocadas. −1: B3 (token órfã com comentário que aponta para o que foi apagado) |
| Correção | **7** | suíte reproduzida por mim, `✔ 716 tests in 125 suites passed after 10.604 s`, e VARREDURA VERDE em 7 fluxos; mas o único teste novo é um lint de fonte — nenhum dos sete comportamentos da ADR tem teste, incluindo a re-G3 da V7 (M1) |
| Jornada real | **9** | seis estados × `large`/AX5 × main/branch; conferi o conteúdo de `v12-depois-ax5-vestida`, `v12-depois-large-vestida`, `v12-depois-ax5-arquivo` e reproduzi três estados por conta própria. −1: B1 |
| Design | **8** | tokens e Componentes citados, nenhum literal de cor/tracking solto (lint novo), raio inalterado; mas `.cartao` apagou a sombra de contato e o fio do cartão e **toda** a aresta do aviso, sem declarar (M2); B4 |
| Simplicidade | **9** | curva-zero com os quatro itens, e o atrito nomeado é o que a V9 mediu (o toque em "Todas" caindo no cartão); passos e decisões não crescem (escrever e concluir seguem 2 toques, 0 decisões); `CartaoBotaoStyle` apagado; −55 linhas |
| Movimento | **6** | **A1**: régua legível em duas posições e sobre a linha de base de `Trabalhar nisto`, e cartão velho dissolvendo no novo — na tira do próprio implementador (`v12-pe-quadros.png`, última coluna, linhas 2 e 3, **com e sem RM**) e reproduzido em `v12-rev-cruzamento-regua-pe.png`. Crédito pelo `repeatForever` do "lendo…" apagado e pela célula nova com `Duracao.media` easeOut |
| Componentes | **10** | nenhum componente novo; seis estilos no repositório e o comentário atualizado bate com `grep ": ButtonStyle"`; Página e Caderno passam a citar `.rotulo`, `.cartao`, `Pilula`, `CabecalhoDeFolha`, `.discreto`, `.primario`, `.compacto` |
| Acessibilidade | **8** | alvos **medidos**: `aba-arquivo` 44×104, `abrir-campos` 166×44, `trabalhar-nisto` 362×44, `Analisar` 84×44; menu AX mantém as cinco ações na árvore (dump colado acima); degradê sem corte seco em AX5. Mas **M3**: em AX5 com o cartão, a quinta ação só existe depois de rolar |
| Performance | **n/a** | nada de lista, parser ou editor novo; nenhuma medida feita, e não invento uma. Nota B5 |
| Privacidade e autoria | **10** | o diff é inteiro de camada de vista: nenhuma rota de dados, nenhum selo, nada que publique, gaste ou envie. O `UIPasteboard` do "Copiar" é anterior e continua atrás do toque do autor |
| Estado honesto | **8** | acerto real e visto na tela: o aviso e a linha de gravação recusada (05s) vivem no fluxo **acima** do pé e não cobrem mais a barra (`v12-rev-aviso-regua-pe.png`). Mas a superfície da falha perdeu sombra e borda (M2) — é agora a menos separada da página |
| Complexidade | **10** | −55 linhas líquidas de Swift do app, medidas; zero arquivos de código novos; um estilo e um `repeatForever` a menos. Regra da 05v cumprida |
| Fora do app | **n/a** | nenhum widget, Ilha ou intent nesta volta. A F3 que entrou pelo merge é da trilha dela, não desta volta |
| Relato | **9** | seis fases, curva-zero, tabela de pixels, linha literal da suíte, autoavaliação declarada como declaração. −1: B2 e o fato de a tira ser oferecida como prova de "nenhum cross-fade" quando a última coluna dela mostra um |

**Portão das skills.** `design-router`: as seis fases estão citadas; conferi
cinco contra a tela e passam — inclusive "auditar antes de tocar" (as
`v12-antes-*.png` são de main mesmo: a linha 1 da tira mostra o pé sumindo, e os
pares antes/depois diferem em todo estado que mudou). A fase **Mover** é a que
não se sustenta (A1). `curva-zero`: os quatro itens estão lá e o atrito nomeado
é o que a V9 mediu; só a frase de AX não bate com a tela (M3).

---

## Lista mínima para reabrir o portão

1. **Movimento (A1)** — tirar o cross-fade entre a régua/pé e o conteúdo do
   cartão, com e sem Reduzir Movimento. Prova: uma tira de quadros do branch em
   que a régua nunca apareça em duas posições nem sobre a linha de base do pé.
2. **Estado honesto + Design (M2)** — devolver a aresta ao aviso (um estilo de
   `Cartao` que mantenha `Tema.linha`), e decidir explicitamente se o cartão fica
   sem a sombra de contato — declarando na ADR se ficar.
3. **Correção (M1)** — dois testes: `Camadas` devolvendo a posição quando o
   binding recusa, e `esconderRegua` só em tamanho AX.
4. **Acessibilidade (M3)** — ou `Trabalhar nisto` volta a ser botão fora do menu
   em AX, ou a ADR e o relato passam a dizer a rolagem como custo (e a frase
   "cinco ações a um toque" sai).
5. **Relato/Contrato (B2, B3)** — corrigir "maior 328 KB" (é 397 KB), retirar ou
   requalificar a afirmação "nenhum cross-fade entre irmãos", e dar destino a
   `Tema.Duracao.pulso`.

Nada dos itens 1–4 é conversa de gosto: cada um tem uma captura ou uma medida
neste arquivo. Os itens 2 e 5 são de uma linha cada.

## Capturas do revisor

`ferramentas/orca/v12-rev-*.png` — todas do C2416CBC, `≤ 1000 px`:

| arquivo | o que mostra |
|---|---|
| `v12-rev-large-assentado.png` | `large`, cartão em cena, pé inteiro à vista: a decisão central, assentada |
| `v12-rev-aviso-regua-pe.png` | `large`, teclado de pé: aviso → régua → `Trabalhar nisto` → quatro ações, sem sobreposição |
| `v12-rev-cruzamento-regua-pe.png` | **A1**: régua legível sobre a linha de base de `Trabalhar nisto`, sem Reduzir Movimento |
| `v12-rev-quadros-ultima.png` | **A1**: última coluna de `v12-pe-quadros.png` a 4× — régua em duas posições, cartão velho sobre o novo, linhas 2 e 3 (sem e com RM) |
| `v12-rev-ax5-menu.png` | **M3**: menu único em AX5, quatro ações desenhadas |
| `v12-rev-ax5-menu-rolado.png` | **M3**: depois de rolar aparece `Lente` e sai `Trabalhar nisto` |

---

# Re-G3 — a correção (topo `69bec69`)

Mesmo revisor, sessão nova, 06/09/2026. Julguei **só** os cinco itens da lista
mínima, o item da voz e as regressões que a correção possa ter causado; o resto
do scorecard acima continua valendo. Simulador C2416CBC, restaurado ao fim
(`content_size large`, RM desligado, `TRACO_SEM_MODELO` limpo, privacidade
reposta, app desinstalado); o iPhone 17 do dono não estava sequer ligado. Todo
`xcodebuild` e todo maestro por `com-trava.sh`, maestro preso ao meu UDID.
Worktree temporário em `337a22e` criado e **removido**. Não editei nem commitei
código.

**Veredito: CORRIGIR ANTES — mas pequeno.** Quatro dos seis itens estão
fechados e provados por mim. Restam três coisas: um resíduo do A1 que eu filmei,
e duas linhas de documento que ficaram no desenho velho.

## Instrumento, reproduzido por mim

| declaração | conferência |
|---|---|
| suíte **718/0 em 125 suítes** | **reproduzida**: `✔ Test run with 718 tests in 125 suites passed after 7.132 seconds.` no C2416CBC |
| build sem aviso novo | confirmado — **zero** avisos no log desta passada |
| correção **+124 −16** no Swift do app, **63 de comentário** | confirmado ao número: `git diff --shortstat 337a22e..69bec69 -- 'Traco/*.swift'` = 124/16; das 124 adicionadas, 63 casam `^\s*(//\|///)` |
| a volta inteira vira **+53** | confirmado: −55 (V12) + 108 (V12-B) = +53 |
| os comentários são mecanismo, não prosa | **confirmado**: li as 63. Cada bloco nomeia a armadilha, o porquê e o achado (`_ConditionalContent` que troca de ramo; `.move(edge:.bottom)` que desliza por cima do rodapé; `.clipped()` que é do VStack e não separa irmãos; identidade do cartão por caso). Nenhuma linha é elogio ou narrativa |

Precisão que o número redondo esconde, sem reabrir a decisão do orquestrador: o
código **sozinho** da correção é **+61 −10 = +51**, e o da volta inteira é
**+217 −189 = +28**. Não é empate; é crescimento declarado de 28 linhas de
código sobre a base tocada. A decisão de aceitar é do orquestrador e está
tomada — fica só o número certo no papel.

## Item a item

**1 — A1, o cross-fade. PARCIALMENTE corrigido.**

O que eu apontei **está corrigido, e eu filmei**. Gravei os meus próprios
vídeos no 69bec69 e extraí a 30 fps a faixa do pé, nos dois modos: em nenhum
quadro a régua aparece em duas posições, nem sobre a linha de base de
"Trabalhar nisto". A régua sai por corte, não deslizando. A tira dele
(`v12b-pe-quadros.png`, linhas 3 e 4) diz a mesma coisa que a minha, e o
diagnóstico do `_ConditionalContent` é trabalho real, não conserto de sintoma.

**Mas a classe não morreu.** No instante em que os campos nascem, o pé do cartão
("Abrir os campos" / "Deixar como nota") e o pé da página ("Trabalhar nisto",
"Analisar Recordar Anexar Lente") **dissolvem por cima do texto do cartão**, nas
mesmas linhas, por ≈5 quadros (≈165 ms). Vale **com e sem** Reduzir Movimento.

- `v12reg3-cruzamento-cartao-rm.png` — recorte a 3× nativos, **Reduzir Movimento
  LIGADO**: lê-se "Abrir os campos" desenhado **sobre** o kicker "WOOP", logo
  acima de "isto é um desejo com obstáculo".
- `v12reg3-tira-sem-rm.png` e `v12reg3-tira-com-rm.png` — a mesma passagem,
  quadro a quadro, nos dois modos.

Não reconstruí a V12 para datar este par, então chamo de **resíduo da classe**,
não de regressão nova. Mas é a lei da própria 05y ("o CONTEÚDO corta") e é o
caminho principal: acontece toda vez que uma forma veste.

**2 — M2, a aresta. CORRIGIDO, e medido por mim.**

`Cartao` devolve o fio de `Tema.linha` 0,5 a `.papel` e `.flutuante` e a sombra
de contato a `.flutuante` — no MATERIAL, não no chamador, que é a correção
certa. Medido nas minhas capturas, coluna x=1120:

- **aviso** (`.papel`, onde mora a linha de gravação recusada da 05s): topo
  244 → **233** → 241 → 255; base 255 → **241** → **233** → 244. Fio dos dois
  lados, sem rampa de sombra — exatamente o que `.papel` deve fazer.
- **cartão** (`.flutuante`): base 255 → **241** → **208** → 219 → 222 → … → 230.
  Fio mais a rampa da sombra de contato. Bate com o que ele declarou (252 → 238 →
  205 → 217 → … → 229), a menos de ±3 de compressão.

A sombra de contato **voltou**, não ficou de fora, e a ADR a declara. O alcance
do fio a quem mais usa `.cartao(.papel)` está declarado na ADR ("restauração no
caderno, refinamento nas Notas") e eu conferi as Notas na tela
(`v12reg3-notas-fio.png`): o campo de busca ganha a aresta, nada quebra.

Ressalva baixa, não bloqueia: em main os três portais do caderno tinham
`strokeBorder(Tema.linha, lineWidth: 1)`, desenhado para DENTRO; o que voltou é
`stroke(…, lineWidth: 0.5)`, centrado no traçado. É metade do peso e meio ponto
para fora. A ADR chama de "restauração"; é restauração mais leve.

**3 — M1, os dois testes. CORRIGIDO.**

`Trilho.posicaoAposRecusa` e `PaginaView.esconderRegua` saíram de dentro do gesto
e do `body` para poderem ser provados, e os testes cobrem os RAMOS, não só o
caminho feliz: recusa nos dois sentidos, aceitação nos dois sentidos (`nil`,
para não re-cravar a mola), AX1 e AX5 verdadeiros, xSmall/large/xxxLarge falsos,
e cartão `nil` falso mesmo em AX5. É o que faltava.

**4 — M3, a quinta ação. CORRIGIDO, e visto na tela.**

`v12reg3-ax5-pe.png` (AX5, cartão em cena): "Trabalhar nisto" é botão, inteiro;
"Mais ações da nota" quebra em duas linhas mas **não trunca** — o defeito que o
menu único existia para resolver não voltou. `v12reg3-ax5-menu.png`: menu aberto
com **Lente, Anexar, Recordar, Analisar**, as quatro desenhadas, sem rolagem e
sem afordância escondida. O pé agora tem duas linhas e é o texto do cartão que
rola por elas — declarado na ADR como custo.

Ressalva baixa: a frase "cinco ações a um toque" continua não sendo o que a tela
faz — quatro delas seguem a dois toques (abrir o menu, tocar). O relato da V12-B
diz que a frase "fica de pé porque a tela passou a fazê-la"; não fica. A **ADR**
não repete a frase, então o contrato está certo; é o relato que exagera.

**5 — B2/B3. CORRIGIDO.**

"maior 397 KB — `v12-antes-large-sabia.png`" (o arquivo tem 406 310 bytes =
396,8 KiB ✓). A afirmação "nenhum cross-fade entre irmãos" foi requalificada no
lugar onde estava, marcada como intenção e não tela, com ponteiro — e não
apagada, que é a escolha certa. `Tema.Duracao.pulso` apagada; `Movimento.laco`
fica com comentário dizendo que não tem consumidor e por quê, e `lacoPara`
passou a escrever 0,7 na própria linha.

**6 — A voz. CORRIGIDO, e o mecanismo confere.**

Fui ler `Degraus.ajuste`: pega os **dois últimos** sinais de pergunta **desta
forma** (`suffix(2)`, `$0.forma == forma.rawValue`), e só mexe se os dois
concordarem (`allSatisfy`) — ±1, preso a 0–4 por `instigar`; o degrau escolhe
`instrucaoDeInstigar`, que é literalmente **o que o modelo é mandado cobrar**. A
frase nova — "duas respostas iguais seguidas mudam o que ele cobra nesta forma"
— descreve isso com fidelidade e é conferível. A antiga ("ele aprende com você")
era alegação de eficácia sem dono. Trocou promessa por mecanismo: é a direção
certa da voz do app.

Sobre "não corta em large e AX5": a frase é `accessibilityHint` (linha 43,
pendurada no `HStack` das duas saídas) e o iOS **não desenha hint** — não existe
superfície de corte em tamanho nenhum. O que é desenhado ali continua sendo
"serviu" e "não serviu", que a volta não tocou. O limite declarado (sem prova
falada) é limite de verdade: exige VoiceOver com humano.

## Os três fatos que o orquestrador pediu para confirmar

1. **A contagem.** Confirmada ao número: +124 −16, 63 de comentário, volta em
   +53; os comentários são mecanismo com referência ao achado, não prosa. O
   número exato do código sozinho está acima.
2. **`barra-de-baixo`: CONFIRMADO como pré-existente.** Construí o `337a22e`
   num worktree separado (build limpo, `derivedDataPath` próprio) e rodei o mesmo
   conjunto de fluxos, com o mesmo roteiro e o mesmo aparelho, nos dois builds.
   O conjunto de falhas saiu **idêntico, fluxo a fluxo**: `aba-arquivo
   auto-analise ax5 barra-de-baixo busca caderno-pdf caderno-regua forma-folha
   gesto-camadas` nos dois. Nenhum fluxo se comporta diferente entre `337a22e` e
   `69bec69` — a correção não mexeu na varredura. **FILA para `barra-de-baixo`.**
   Honestidade sobre o instrumento: hoje o meu roteiro preso ao UDID não passa do
   diálogo de notificação que volta depois de todo `clearState` neste aparelho
   (na revisão anterior os mesmos 7 fluxos correram verdes), então a varredura
   **não serve hoje como portão de aprovação** — serve, e serve bem, como
   comparação A/B, que era a pergunta.
3. **O par "serviu / não serviu" fora da tela.** Aceito e confirmado pela via
   estrutural: é `accessibilityHint`, e hint não se desenha. Não há captura a
   cobrar.

## Regressões que a correção causou

**R1 — Contrato: `EVOLUCAO.md` não foi tocado (0 linhas no commit).** A linha da
ADR05y continua dizendo três coisas que deixaram de ser verdade:

- "em AX o pé vira um menu só com **'Trabalhar nisto' dentro**" — é exatamente o
  desenho que o M3 recusou e que a V12-B reverteu;
- "suíte **714/0** em 125 suítes" — são 718/0;
- "shortstat **líquido-negativo**" — a volta é +53, e essa é justamente a
  afirmação que o orquestrador acabou de aceitar como não mais verdadeira.

A SPEC e a ADR foram reescritas com honestidade exemplar; a matriz ficou para
trás. A ESTEIRA pede os dois coerentes. É uma linha de conserto.

**R2 — Relato: `relatorio-v12-pagina.md` ficou no desenho velho em dois pontos.**
A curva-zero (linhas 75–76) ainda diz "para **um** menu que abre cinco ações:
menos ruído na tela, mesmo poder a um toque", e a autoavaliação (linha 148)
"em AX, cinco ações num menu em vez de duas linhas truncadas". Ele requalificou
a afirmação do movimento nesse mesmo arquivo (linha 44) e não fez o mesmo com a
de AX.

## Notas revistas

| dimensão | G3 | Re-G3 | por quê |
|---|---|---|---|
| Movimento | 6 | **8** | o par que eu filmei (régua em duas posições, régua sobre "Trabalhar nisto") **está morto** nos meus vídeos, nos dois modos; sobra um par da mesma classe — o pé sobre o texto do cartão quando os campos nascem, ≈165 ms, com e sem RM (`v12reg3-cruzamento-cartao-rm.png`). Muito mais estreito, mas ainda é a lei da 05y sendo quebrada no caminho principal |
| Correção | 7 | **9** | dois testes com cobertura de ramo, não de caminho feliz; suíte 718/0 reproduzida por mim; zero avisos; varredura sem diferença entre os dois builds |
| Design | 8 | **9** | fio e sombra de contato de volta **no material**, medidos por mim nas duas superfícies; alcance às Notas declarado na ADR e conferido na tela. −1 pelo `stroke` 0,5 onde main tinha `strokeBorder` 1 |
| Acessibilidade | 8 | **9** | "Trabalhar nisto" fora do menu, quatro ações desenhadas sem rolagem, rótulos inteiros — visto em AX5. A dica da voz passou de promessa a mecanismo, o que também é acessibilidade de texto |
| Estado honesto | 8 | **9** | a superfície da falha tem aresta de novo, medida na minha captura: 255 → 241 → 233 → 244 |
| Contrato | 9 | **8** | R1: EVOLUCAO com três afirmações vencidas, uma delas o "líquido-negativo" |
| Relato | 9 | **8** | R2: curva-zero e autoavaliação da V12 descrevem o desenho revertido; e "a frase 'cinco ações a um toque' fica de pé" exagera o que a tela faz |

Componentes 10, Complexidade 10, Visão 10, Privacidade 10, Jornada real 9,
Simplicidade 9 e Performance n/a seguem como estavam, por decisão do
orquestrador e porque nada na correção os toca.

## Lista mínima para o portão

1. **Movimento** — matar o par que sobrou: o pé do cartão e o pé da página não
   podem dissolver sobre o texto do cartão quando os campos nascem. Prova: a
   mesma tira de 30 fps, nos dois modos, sem dois textos legíveis na mesma linha.
   É o único item de código, e é um par, provavelmente um modificador.
2. **Contrato (R1)** — a linha da ADR05y no `EVOLUCAO.md`: o pé em AX, 718/0, e
   o balanço que deixou de ser negativo. Uma linha.
3. **Relato (R2)** — as duas frases de AX no `relatorio-v12-pagina.md`, e tirar
   o "fica de pé" do relato da V12-B. Duas linhas.

Os itens 2 e 3 são documento. O item 1 é o que separa a volta do merge.

## Capturas do revisor (Re-G3)

| arquivo | o que mostra |
|---|---|
| `v12reg3-cruzamento-cartao-rm.png` | **o resíduo do A1**, a 3× nativos, **com** Reduzir Movimento: "Abrir os campos" desenhado sobre o kicker "WOOP" |
| `v12reg3-tira-sem-rm.png` | a mesma passagem quadro a quadro, sem RM — a régua nunca duplica; o pé sobre o texto do cartão, sim |
| `v12reg3-tira-com-rm.png` | idem, com RM |
| `v12reg3-ax5-pe.png` | **M3 fechado**: AX5 com o cartão, "Trabalhar nisto" botão e "Mais ações da nota" inteiros |
| `v12reg3-ax5-menu.png` | **M3 fechado**: as quatro ações do menu desenhadas, sem rolagem |
| `v12reg3-aviso-aresta.png` | **M2 fechado**: o aviso com o fio de volta (perfil medido na coluna x=1120) |
| `v12reg3-notas-fio.png` | o alcance declarado do fio nas Notas: refinamento, não quebra |

---

## Re-G3, segunda passada (topo `6e80ace`) — fecho

Mesmo revisor, 06/09/2026. Julguei os três itens que eu tinha derrubado e a
pergunta que o orquestrador acrescentou: **a classe está fechada?** Simulador
C2416CBC, restaurado ao fim. Todas as minhas provas de tela vêm de
`simctl io` preso ao meu UDID — nunca de `takeScreenshot` do maestro, que não
isola com sete simuladores ligados. Não editei nem commitei código.

**Veredito: INTEGRAR — segue para o G4**, com uma condição de contrato de duas
linhas (abaixo). Os três itens estão fechados e provados por mim. A classe do A1
**não está fechada**: achei a terceira ocorrência, filmei, e ela é dívida do
RUMO, não desta volta.

### Instrumento

| declaração | conferência |
|---|---|
| suíte 718/125 verde | **reproduzida**: `✔ Test run with 718 tests in 125 suites passed after 8.694 seconds.` |
| build sem aviso | confirmado: **zero** avisos no log |
| Swift do app +19 −10, 13 de comentário, código −4 | confirmado ao número: 19 adicionadas, 13 casam `^\s*(//\|///)`; das 10 removidas, **nenhuma** é comentário → código **+6 −10 = −4** |
| a volta fecha em +62 | confirmado: −55 (V12) + 108 (V12-B) + 9 (V12-C) = **+62** |

### Item de código — a causa era o ramo, e o conserto vale

Confirmado na minha filmagem, nos dois modos. Na chegada do cartão
(`v12reg3b-vestir-limpo.png`, quadros nativos a 30 fps, sem RM): "lendo…" vira
cartão por **corte**, o pé fica em todos os quadros, nada dissolve sobre o texto
do cartão — e o **teclado não desce**, que é o ganho a mais que ele prometeu e
que é lei do dono (§3). No mesmo ponto, em `69bec69`, eu tinha lido "Abrir os
campos" desenhado sobre o kicker "WOOP". Está morto.

A página vazia não regrediu de comportamento, que era o risco real de embrulhar
o editor num `ScrollView`: com o teclado de pé, arrastar o papel para baixo
**não** recolhe o teclado nem rola — 486 px de diferença em 2,9 M, e são o
caret piscando. O `minHeight: geo.size.height` faz o conteúdo caber exato, então
o ScrollView fica inerte. Nota de higiene, não achado: o `v12c-vazia.png`
commitado está reamostrado para 460×1000, então **a prova de "0 px" não é
re-derivável do arquivo no repositório** — só dos originais dele.

### A pergunta do orquestrador: a classe NÃO está fechada

Procurei os outros `_ConditionalContent` do caminho e achei a terceira
ocorrência **no mesmo arquivo, um nível acima**:

```swift
// CadernoView.paginaCaderno — a mesma forma de dois ramos que a V12-C acabou
// de matar dentro de paginaUna
if let una = Caderno.paginaUna(texto) ?? (unaCrua && foco.wrappedValue && …) {
    paginaUna(una)
} else {
    paginaFatias
}
```

Ele troca de ramo quando o texto deixa de ser "uma página" **e quando o foco
muda** (`unaCrua && foco.wrappedValue`). Gatilho trivial: escrever um título e
apertar Enter — `paginaUna` devolve `nil` para título com `\n`.

Filmei, **com Reduzir Movimento LIGADO**, `# Plano do dia` + Enter + corpo:

- `v12reg3b-ramo-pe-some.png` — dezesseis quadros nativos consecutivos a 30 fps.
  Nos quadros 2140–2145 a régua e a barra inteira ("Trabalhar nisto · Analisar ·
  Recordar · Anexar · Lente") **somem do papel** e voltam noutra altura. Medido,
  não olhado: bandas de texto na faixa 30–62 % da tela = 6, 6, 6, 6, 6, **0, 0,
  0, 0, 0, 0**, 3, 4, 4, 5, 5.
- `v12reg3b-ramo-duas-geometrias.png` — no meio da troca o encaixe é desenhado
  em **duas geometrias ao mesmo tempo**: régua e "Trabalhar nisto" legíveis em
  duas posições no mesmo quadro. É a assinatura exata do A1.

Ou seja: o defeito que dá nome à volta — **o pé some sob o dedo** — ainda
acontece, por ~150 ms, quando o autor escreve um título e desce para o corpo.

Achei também uma quarta, mais barata: a **chegada** do pé. `rodape:
!paginaVazia || podeRecordar ? AnyView(bottomBar) : nil` entra sem `.identity`,
e nos primeiros caracteres "Trabalhar nisto" fica legível **em cima** de
"Numerada"/"Tarefa" da régua, com e sem RM
(`v12reg3b-pe-chega-sobre-regua.png`, RM ligado).

**Por que isso não derruba a volta.** Nenhuma das duas é regressão desta
correção nem das anteriores: `paginaCaderno` já tinha dois ramos antes de
`0d0d007`, e o pé sempre apareceu ao primeiro caractere. Estão fora do G0 desta
volta, e uma quarta rodada sobre a divisão una/fatias — que é questão de
estrutura, não de acabamento — custa mais ao dono do que entregar agora o que já
está provado. O autor bissectou por experimento duas vezes e acertou a causa das
duas; isso é o oposto de conserto de sintoma.

**Por que precisa de duas linhas antes do merge.** A ADR hoje diz "**Três
coisas** fazem isso ser verdade e não intenção" e o parágrafo da V12-C fecha
como se a classe estivesse resolvida. Está resolvida **nos dois lugares
tocados**, não na classe. Deixar isso implícito é exatamente o que a dimensão
Estado honesto proíbe.

### Os dois de texto

**`EVOLUCAO.md` — corrigido nos três pontos, e bem.** "em AX o pé tem
'Trabalhar nisto' como BOTÃO e as outras quatro no menu" (com o motivo e o
achado M3 ao lado); "suíte 718/0 em 125 suítes"; e o balanço deixou de dizer
"líquido-negativo" para dizer **"+62 linhas líquidas … portanto NÃO cumpre a
regra de shortstat líquido-negativo da 05v — a exceção foi aceita pelo
orquestrador e o motivo está declarado"**. Nomear a regra que se quebra é melhor
do que eu pedi.

**Os dois relatos — requalificados no lugar, não apagados.** `relatorio-v12`:
a curva-zero e a autoavaliação passaram a descrever o pé de duas linhas, cada
uma com a nota de que a frase anterior era o desenho revertido pela V12-B.
`relatorio-v12b`: a frase "cinco ações a um toque" está explicitamente derrubada
("em AX só 'Trabalhar nisto' está a um toque; as outras quatro seguem a dois"),
com a observação de que a ADR nunca repetiu a frase. Li os três documentos
contra o branch de hoje e não achei outra afirmação vencida.

### Notas revistas

| dimensão | Re-G3 | agora | por quê |
|---|---|---|---|
| Movimento | 8 | **9** | a chegada do cartão corta nos dois modos e o teclado não desce mais (`v12reg3b-vestir-limpo.png`); a causa foi achada, não mascarada. Nota **condicionada** à declaração abaixo: com a classe aberta e não declarada, cai para 8 |
| Contrato | 8 | **9** | EVOLUCAO corrigido nos três pontos, e o +62 nomeia a regra da 05v que quebra em vez de esconder |
| Relato | 8 | **9** | as três frases do desenho revertido requalificadas no lugar, com o motivo; nenhuma outra afirmação vencida nos três documentos |
| Correção | 9 | **9** | 718/0 reproduzida, zero avisos, código líquido −4 |
| Design | 9 | **9** | nada tocado desde a V12-B; a página vazia não regrediu de comportamento |
| Acessibilidade | 9 | **9** | nada tocado desde a V12-B |
| Estado honesto | 9 | **9** | condicionada à mesma declaração: a superfície da falha está certa, mas o contrato não pode dizer fechado o que está aberto |

Visão 10, Componentes 10, Privacidade 10, Complexidade 10, Jornada real 9,
Simplicidade 9, Performance n/a e Fora do app n/a seguem como estavam.

### Condição de contrato (duas linhas, para o G5)

1. **ADR 05y** — o parágrafo da V12-C fecha dizendo que a classe está tratada
   nos dois lugares tocados e **continua aberta em `CadernoView.paginaCaderno`**
   (troca de ramo una/fatias, dispara por título+Enter e por mudança de foco: a
   régua e a barra somem por ~150 ms e o encaixe é desenhado em duas geometrias,
   com e sem Reduzir Movimento — `v12reg3b-ramo-pe-some.png`), e no `rodape`
   opcional da `PaginaView`.
2. **RUMO** — uma volta nomeada para essa dívida, com o gatilho e as capturas
   acima. É a mesma correção de sempre: a diferença entre os ramos vira valor.

Sem essas duas linhas o merge afirma uma coisa que a tela não faz; com elas, a
volta entrega o que prometeu e diz onde ainda não chegou. **Passa ao G4.**

### Nota de instrumento

O `com-trava.sh` **deste worktree ainda é o antigo** (`until mkdir; trap rmdir`):
não retoma trava presa nem escreve o dono dentro dela. A melhoria que o
orquestrador descreveu não está neste branch — vale conferir antes do G5, para
que a volta não leve para main a versão que travou seis workers.

### Capturas desta passada

| arquivo | o que mostra |
|---|---|
| `v12reg3b-vestir-limpo.png` | **item de código fechado**: "lendo…" → cartão por corte, pé em todos os quadros, teclado de pé |
| `v12reg3b-ramo-pe-some.png` | **a classe aberta**: 16 quadros nativos, RM ligado — a régua e a barra somem por ~150 ms na troca de ramo una/fatias |
| `v12reg3b-ramo-duas-geometrias.png` | o encaixe desenhado em duas geometrias no mesmo quadro: régua e "Trabalhar nisto" em duas posições |
| `v12reg3b-pe-chega-sobre-regua.png` | a quarta ocorrência, barata: "Trabalhar nisto" legível sobre "Numerada"/"Tarefa" na chegada do pé, RM ligado |
