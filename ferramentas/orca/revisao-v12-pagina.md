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
