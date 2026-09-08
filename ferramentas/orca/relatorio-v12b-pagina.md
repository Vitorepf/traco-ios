# Volta 12-B — a correção do G3 da Página

Implementador: Claude Opus 5, 06/09/2026. Worktree `volta-12-pagina`, sobre
`337a22e` (sem worktree novo, sem rebase). Simulador: **iPhone 17 Pro
C2416CBC** — o que o orquestrador me deu; nenhum outro foi tocado nem desligado.
Todo `xcodebuild` e todo maestro por `ferramentas/orca/com-trava.sh`. Tamanho de
texto e Reduzir Movimento foram alterados e **restaurados** (`content_size
large`, `ReduceMotionEnabled` false).

Veredito atacado: **CORRIGIR ANTES** (`revisao-v12-pagina.md`), cinco dimensões
abaixo de 9. A lista mínima do revisor tem cinco itens; cada um abaixo com a
prova ao lado. O que o revisor aprovou — a pilha inteira de pé em `large`, o
alvo 44×104 da aba, o −55 do commit da V12, nenhum componente novo — não foi
desfeito.

---

## `design-router` — as seis fases

**1. Ancorar.** Pedido: reabrir o portão, não redesenhar a tela. Pessoa: o autor
escrevendo, com o teclado de pé, quando a forma veste sozinha (§17.3). Resultado
verificável: a régua nunca legível em duas posições nem sobre a linha de base do
pé, nos dois modos de movimento; o aviso com aresta; dois comportamentos com
teste; a quinta ação em AX5 sem rolagem. Plataforma iPhone, pt-BR.

**2. Sistema.** Nada novo: `Tema.linha`, `Tema.sombraContato`, `Tema.gaveta`,
`Cartao`, `Trilho`. O único token que sobrou de morador — `Tema.Duracao.pulso` —
foi apagado (B3).

**3. Auditar antes de tocar** (é correção de redesenho, então começa aqui).
Reproduzi o A1 no meu simulador, com o build de `337a22e` instalado, antes de
mexer numa linha: `v12b-pe-quadros.png` linha 1 (sem RM) e linha 2 (com RM) são
gravação de hoje, minha, do build recusado — a régua legível em duas posições,
uma delas na linha de base de "Trabalhar nisto", o pé inteiro pálido e o texto
do cartão em duas alturas. Depois **bissectei a causa por experimento**, não por
leitura: transição dos filhos, `.transaction`, `.id` por caso e `.clipped()`
foram testados um a um e **nenhum** apagou o fantasma. O que apagou está no
item 1.

**4. Construir.** Cinco correções, uma por item da lista. Abaixo.

**5. Mover.** A lei que a ADR escreve passou a ser a que a tela faz: quem anima é
a ALTURA do encaixe, o conteúdo CORTA. Filmado nos dois modos, nos dois builds.

**6. Julgar e Portão.** São do G3 e do G4, em sessão própria. Aqui vai a
evidência com a lei ao lado; a autoavaliação abaixo é declaração, não veredito.

---

## Item 1 — MOVIMENTO (A1): a causa era a identidade do encaixe

O revisor deu a orientação certa pela metade. `AnyView` e o `.move(edge:
.bottom)` da régua são parte, mas não bastam: com os dois corrigidos o fantasma
continuava, e **o pé inteiro** — "Trabalhar nisto" e as quatro ações, que não
estão dentro do cartão — aparecia duplicado em duas geometrias. Um quadro cru a
1× mostrou que o texto da nota ("quero correr de manha") ficava ÚNICO e nítido
enquanto só o encaixe ghostava: não era transição de filho, era **a árvore
inteira do encaixe sendo substituída**.

A causa: `CadernoView.body` pendurava o `.safeAreaInset` direto em
`paginaCaderno`, que é um `_ConditionalContent` — `paginaUna` escolhe entre ter
e não ter `abaixo`. Vestir a forma cria os campos, `abaixo` vira não-nil, o ramo
troca e o SwiftUI **recria toda a árvore, encaixe incluído**, com fade cruzado:
a antiga desenhada no layout velho, a nova no novo. O texto não denunciava
porque é igual nos dois; o pé, que muda de altura, sim.

Três mudanças, cada uma provada necessária por um build próprio:

1. `ZStack(alignment: .top) { paginaCaderno }` — o encaixe passa a pendurar numa
   identidade estável. Sozinha, apaga a duplicação do pé.
2. Régua, aviso, cartão e "lendo…" entram e saem por `.transition(.identity)`.
   `.move(edge: .bottom)` desliza a régua POR CIMA do rodapé, e o `.clipped()` é
   do VStack inteiro — não separa irmão de irmão.
3. `.id(casoDoCartao(cartao))` no cartão: a troca de CASO é troca de view. Sem
   ela — medido no build sem o item 3 — o texto de `.forma` dissolvia sobre o de
   `.vestida` nas mesmas linhas. Dentro do mesmo caso a identidade fica, então a
   resposta da sábia chega sem reiniciar o "serviu / não serviu".

**Prova: `v12b-pe-quadros.png`**, quatro linhas de seis quadros a 30 fps, todas
do C2416CBC, mesmo roteiro:

| linha | build | Reduzir Movimento | o que se vê |
|---|---|---|---|
| 1 | V12 `337a22e` | desligado | régua em duas posições, uma sobre "Trabalhar nisto"; pé pálido; cartão em duas alturas |
| 2 | V12 `337a22e` | **ligado** | o mesmo cross-fade |
| 3 | V12-B | desligado | a régua CORTA; o encaixe cresce e revela o cartão; o pé sólido em todos os quadros |
| 4 | V12-B | **ligado** | a mesma lei |

Vídeos: `v12b-vestir.mp4` e `v12b-rm-vestir.mp4` (5 s, ≤ 57 KB).

## Item 2 — ESTADO HONESTO + DESIGN (M2): a aresta voltou, e ao material

Corrigi onde todos os chamadores passam, não no aviso: `Cartao` devolve

- o **fio** `Tema.linha` 0,5 a todo branco sobre o papel (`.papel` e
  `.flutuante`), e
- a **segunda sombra**, a de CONTATO (r2 y1, SISTEMA-CLARO §1.5), ao
  `.flutuante`.

**Decisão explícita sobre a sombra de contato: ela VOLTA** — o material da casa
tem duas sombras, e sem a de contato o cartão paira sem tocar o papel. Está
declarado na ADR 05y. **`luzBorda` fica de fora**, também declarado: é branco
sobre branco no mundo claro, perda nula (o revisor já tinha medido isso).

Achado que o revisor não pegou e que é do mesmo defeito: a migração também
apagou o `strokeBorder(Tema.linha, lineWidth: 1)` dos **três portais do
`PortalArquivoView`**, que existia em main (`git show 0d0d007:…`). Corrigir no
`Cartao` conserta os três de graça.

**Medida**, coluna x=600, mesmo estado nos dois builds (`a600`/`d440`, quadros
crus a 1206×2622):

| borda | V12 | V12-B |
|---|---|---|
| topo do cartão | papel 242 → branco 252, sem degrau | 242 → **238** → 252 |
| base do cartão | 252 → 230 (chapado) | 252 → **238** → **205** → 217 → 219 → 222 → … → 229 |

O 238 é o fio; o 205 é a sombra de contato; a cauda é a ambiente. Capturas:
`v12b-aresta-cartao.png` (A/B do canto), `v12b-aviso-aresta.png` (o aviso a 2×,
com aresta nos quatro lados).

**O que toquei fora da minha volta, declarado:** `Traco/Componentes/Cartao.swift`
(o material) e `Traco/Tema.swift` (só o item 5). O fio de `.papel` alcança o
cartão da sábia e o campo de busca das Notas, além dos três portais do caderno —
restauração no caderno, refinamento nas Notas. Nenhum outro arquivo de outra
volta foi tocado.

## Item 3 — CORREÇÃO (M1): os dois testes que faltavam

Os dois comportamentos viviam onde teste não chega: um ramo dentro de um
`DragGesture` e uma expressão dentro de um `body`. Extraí a **aritmética** de
cada um, sem mudar o comportamento:

- `Trilho.posicaoAposRecusa(alvoPedido:arquivoAberto:largura:)` — `nil` quando o
  binding aceitou (nada a re-cravar, senão a mola re-acelera na chegada) e a
  posição do estado REAL quando recusou. É a re-G3 da V7, que já voltou uma vez
  justamente por não ter teste.
- `PaginaView.esconderRegua(cartao:tamanho:)` — a régua cede ao cartão só em
  tamanho AX.

Testes em `TracoTests/TemaTests.swift`:
`camadaDevolveAPosicaoQuandoOBindingRecusa` (quatro casos: recusa abrindo,
recusa fechando, aceita nos dois sentidos) e `reguaSoCedeAoCartaoEmTamanhoAX`
(AX1 e AX5 escondem; xSmall/large/xxxLarge não; sem cartão nada esconde).

## Item 4 — ACESSIBILIDADE (M3): "Trabalhar nisto" saiu do menu

Escolhi a primeira opção do revisor. Em AX o pé volta a ter **"Trabalhar nisto"
como botão visível**, como era antes da volta, e o menu "Mais ações da nota"
carrega as **quatro** restantes. Quatro cabem sem rolagem; cinco não cabiam.
*(Corrigido na V12-C, Re-G3: a frase "cinco ações a um toque" NÃO fica de pé —
em AX só "Trabalhar nisto" está a um toque; as outras quatro seguem a dois,
abrir o menu e tocar. A ADR não repete a frase; era este relato que exagerava.)*

O que o menu único resolvia — o rótulo espremido a "Mais ações d…" — continua
resolvido: o problema era as quatro ações LADO A LADO, não duas linhas
empilhadas. Custo assumido e declarado na ADR: em AX o pé ocupa duas linhas, e é
o texto do cartão que rola por elas — o pé não cede.

Prova: `v12b-ax5-pe.png` (AX5, cartão em cena: "Trabalhar nisto" e "Mais ações
da nota" inteiros, sem truncar) e `v12b-ax5-menu.png` (menu aberto: Lente,
Anexar, Recordar, Analisar, as quatro desenhadas, sem rolagem).

## Item 5 — RELATO/CONTRATO (B2, B3)

- **B2** corrigido em `relatorio-v12-pagina.md`: a maior captura é
  `v12-antes-large-sabia.png`, **397 KB** (era "328 KB").
- A afirmação "nenhum cross-fade entre irmãos" foi **requalificada no lugar onde
  estava**: marcada como intenção e não tela, com ponteiro para este relato e
  para a tira nova. Não a apaguei — apagar é esconder que ela existiu.
- **B3, destino de `Tema.Duracao.pulso`: apagada.** O único consumidor saiu na
  V12; o único uso restante era o fixture de `TemaTests.lacoPara`, que agora
  escreve 0,7 na própria linha. A classe `Movimento.laco` **fica**, com
  comentário dizendo que não tem consumidor no app e por quê: é a lei de quem
  tentar repetir sem fim outra vez, e `lacoPara` a mantém honesta.

## Item 6 — A VOZ (fora da lista do G3, pedido do orquestrador)

`CartaoAnaliseView.swift:35` prometia «Diz ao Traço se esta pergunta valeu — ele
aprende com você»: alegação de eficácia do próprio app, sem dono na tela. Fui ver
o que acontece de fato. `Degraus.ajuste` (`Traco/Modelo/Degraus.swift:26`) olha
os **dois últimos** sinais de pergunta **desta forma** e só mexe se os dois
concordarem: dois "não serviu" descem um degrau, dois "serviu" sobem, e
`instigar` prende o resultado entre 0 e 4. Nenhum aprendizado além disso.

Passou a dizer: «Diz ao Traço se esta pergunta valeu — duas respostas iguais
seguidas mudam o que ele cobra nesta forma».

**Sobre "conferir na tela que não corta": a frase é um `accessibilityHint`, e o
iOS não DESENHA hint** — ele é falado pelo VoiceOver, que não trunca. Não existe
superfície de corte para ela em `large` nem em AX5; o que é desenhado ali são os
dois rótulos "serviu" e "não serviu", que não mudaram.

**Limite honesto:** não consegui exercitar na tela o estado que mostra esse par.
Ele só aparece com a sábia respondendo (`perguntaDaSabia` no cartão `.vestida`,
ou o cartão `.resposta`), e neste simulador o botão `perguntar-sabia` não chegou
a aparecer em duas tentativas de roteiro (`sabia.yaml`, `sabia2.yaml`: o texto
com "?" vestiu WOOP e o botão da pergunta não entrou no pé do cartão). Não
inventei captura: os dois estados do cartão que EU consigo pôr na tela estão em
`v12b-large-assentado.png` e `v12b-ax5-pe.png`, e nenhum deles mudou. Se você
quiser a prova falada de ponta a ponta, ela precisa de uma volta com a sábia
respondendo de verdade — aí eu filmo o VoiceOver.

---

## Prova

```
✔ Test run with 718 tests in 125 suites passed after 7.695 seconds.
```

Suíte integral no C2416CBC, por `com-trava.sh`. 716 do G3 + os 2 do item 3.
Build sem aviso novo (seguem os dois pré-existentes de
`ConferenciaTrabalhoTests.swift:381`).

**Varredura maestro.** Verdes no meu simulador, por `com-trava.sh`, presos ao
meu UDID: `aba-arquivo`, `gesto-camadas`, `caderno-regua`, `auto-analise`,
`forma-folha`. **`barra-de-baixo` falha** na asserção da sábia
(«.*a sábia (não respondeu|precisa|pela|pelo).*»): o cartão fica em "a sábia
pensa…" e não resolve. **Não é meu**: reinstalei o build de `337a22e` sem uma
linha minha e a MESMA asserção falha do mesmo jeito. É a sábia local pendurando
neste ambiente, em `ConversaNotas`, que não é arquivo desta volta.

**Complexidade — e aqui o número é contra mim.** Swift do app nesta correção:
**+124 −16**, dos quais **63 das 124 linhas somadas são comentário**. Código:
+61 −16. Somado ao commit da V12 (+158 −213 = −55), a volta inteira sai em
**+53 líquidas**, e portanto **deixa de ser líquido-negativa** — a regra da 05v
não se cumpre nesta volta. A troca foi consciente: os dois testes que o G3 pediu
exigiram tirar uma decisão de dentro de um gesto e outra de dentro de um `body`,
e a identidade por caso do cartão é um `switch` sobre um enum que não é meu para
alterar. Não escondo o número para limpar a tela.

**Capturas e vídeos desta volta** (`ferramentas/orca/v12b-*`, PNG ≤ 377 KB,
vídeos ≤ 57 KB e 5 s):

| arquivo | o que prova |
|---|---|
| `v12b-pe-quadros.png` | item 1: quatro linhas, dois builds × dois modos de movimento |
| `v12b-vestir.mp4`, `v12b-rm-vestir.mp4` | item 1 em movimento |
| `v12b-aresta-cartao.png` | item 2: o canto do cartão, antes e depois |
| `v12b-aviso-aresta.png` | item 2: o aviso com aresta nos quatro lados |
| `v12b-large-assentado.png` | a decisão central da volta, intacta |
| `v12b-ax5-pe.png` | item 4: "Trabalhar nisto" botão + menu, rótulos inteiros |
| `v12b-ax5-menu.png` | item 4: quatro ações desenhadas, sem rolagem |

**ADR.** A minha é a **2026-09-05y**, atribuída pelo orquestrador e já correta:
não mudei o número nem reordenei nada. Editei a 05y no lugar dela, no fim da
SPEC. Este worktree não mescla main — quando mesclar, a 05y fica depois da 05x
da volta 16.

**Escopo tocado.** `Traco/Pagina/PaginaView.swift`, `Traco/Caderno/CadernoView.swift`,
`Traco/App/Camadas.swift`, `Traco/Componentes/Cartao.swift`, `Traco/Tema.swift`,
`Traco/Pagina/CartaoAnaliseView.swift` (só a frase do item 6),
`TracoTests/TemaTests.swift`, `SPEC.md`, os dois relatos. Nada em
`Traco/Trabalho`, `Traco/Perfil`, `Traco/App/Intents`, `TracoWidget`,
`Traco/App/Sessao.swift`, `Traco/Modelo`, `Traco/Analise`.

## `curva-zero` — a jornada, no que esta volta mexeu

- **Jornada.** O autor escreve; a forma veste sozinha; o cartão anuncia e as
  ações continuam à mão. Em AX5 a mesma jornada, com o corpo de texto grande.
- **Resultado verificável.** Em AX5, as cinco ações da nota são alcançáveis sem
  rolar: "Trabalhar nisto" no pé e as outras quatro no menu, todas desenhadas
  (`v12b-ax5-menu.png`).
- **Atrito observado.** Medido pelo revisor no meu build: em AX5 com o cartão,
  a quinta ação só existia depois de uma rolagem sem afordância, e o iOS ancora
  o menu para cima, então a "primeira" da ADR ficava por último na tela.
- **Recuperação.** Nenhum caminho novo a aprender: o botão que sumiu voltou onde
  estava antes da volta. Quem já usava o menu continua achando lá as quatro.
