# V12-B — a Página paga a dívida: o fantasma do `.sheet`, o aviso e a Pílula que ninguém enxerga

Worker: Claude Opus 5, papel de front-end e design, 08/09/2026, worktree
`volta-v12b-pagina` (nascido de `main` em `499623c`).

**Instrumento.** Simulador **iPhone 17 Pro Max `6033B043`**, ligado por mim.
`TRACO_SEM_MODELO=1` no ambiente do app (motor local; nada gasto na conta do
dono). Todo `xcodebuild` e `xcodebuild test` sob `ferramentas/orca/com-trava.sh`.
**Nenhum maestro** — havia quatro e depois cinco simuladores ligados na máquina,
e a lei da ESTEIRA proíbe apoiar veredito no maestro nessa condição. **Toda prova
de tela é `xcrun simctl io` preso ao meu UDID**, screenshot ou vídeo com quadros
nativos extraídos por `ffmpeg`. Estado devolvido ao fim: `content_size` =
`large`, `ReduceMotionEnabled` = 0. Nenhum simulador alheio foi ligado,
desligado ou reinstalado.

**Um incidente de instrumento, declarado.** A meio da sessão outro worker
rearranjou as janelas do Simulator e a MINHA ficou **exatamente empilhada** com a
do `iPhone 17 Pro C2416CBC` (a da volta L2), nas mesmas coordenadas. Entre o meu
`AXRaise` e o meu clique, a janela do vizinho subiu, e uns toques meus caíram
lá — o que se vê na captura que tirei do vizinho é o app **Ajustes**, na página
"Siri, Ditado e Privacidade", com uma seleção de texto. Nada do app Traço foi
tocado, nada foi escrito, nenhum dado do vizinho mudou. Assim que percebi, movi a
MINHA janela para o segundo monitor, onde nenhuma outra janela pousa, e o
problema não voltou. **Fica como lei nova para quem dirigir por coordenada com
vários simuladores: não basta trazer a janela para a frente — é preciso que ela
não divida coordenadas com ninguém.**

---

## As seis fases do `design-router`

### 1. Ancorar — o contrato antes da solução

Pessoa e situação: o autor a escrever, teclado de pé, a forma vestida sozinha.
Tarefa principal: **escrever e ver o que escreveu**; abrir os campos sem que
nada nasça por cima do texto nem por cima do que ele ia tocar. Plataforma:
iPhone, pt-BR, mundo claro. Restrições vigentes: `Tema.swift` é da volta L2 e
não se toca (nenhum token novo foi preciso); a lei do movimento (ADR 05y) já
escolheu o corte e a lista congelada do portão do movimento **só pode descer**.

Rota escolhida na tabela do roteador: **redesenho de tela existente** — logo,
começar pelo diagnóstico, não pelo layout.

### 2. Auditar antes de tocar — e metade dos defeitos já tinha caído

Antes de escrever uma linha, reproduzi na tela viva os três defeitos que os
relatórios acusam. **Dois deles já não existem como descritos.**

| o que o relatório diz | o que a tela viva mostra | veredito |
|---|---|---|
| **Toast**: `PaginaView.swift:303`, `padding(.bottom, 88)` chutado, o aviso nasce sobre a barra de ações (A1 da revisão da V19) | **o `88` não existe mais**: `git log -S` mostra que o commit `5937943` da V12 apagou o número e mudou o aviso para dentro do encaixe (`acima:` do `CadernoView`), como IRMÃO da barra no mesmo `VStack`. Estruturalmente o aviso não pode cobrir a barra | **caiu antes desta volta** — mas ver A abaixo |
| **Item 2 do re-G4** (AX5 com cartão e teclado: "Mais ações da nota" acima do teclado, "Deixar como nota" inteiro, topbar fora da barra de status) | **passa nos três, sem eu tocar em nada**: `v12b-antes-ax5-vestida.png` (AX5, RM 0, teclado de pé, forma vestida) mostra a topbar em 97 pt — abaixo da barra de status —, o texto do autor em duas linhas, "Trabalhar nisto" e "Mais ações da nota" inteiros ACIMA do teclado; e `v12b-ax5-saidas-no-menu.png` mostra o menu `•••` do cartão com **"Abrir os campos" e "Deixar como nota" inteiros**, sem corte | **já estava certo** |
| **Fantasma do `.sheet`** (A5: ~110 ms sobre o texto do autor, igual com e sem RM) | **vivo, e maior do que o relatado** | **confirmado** |
| **`Pilula` desabilitada** 1,53:1 | **vivo**, e com um chamador (`RecordarView`) já a contorná-lo à mão | **confirmado** |

**Achado A (meu, e é o que ficou do toast).** O `88` saiu, mas o que entrou não
foi uma medida: foi um **vão**. Medido em `v12b-antes-large-vestida.png`
(`large`, RM 0, teclado de pé, forma vestida), sobre captura nativa 1320×2868:

| faixa | pt |
|---|---|
| cartão da forma vestida | 284,3 → 393,3 |
| **vão vazio** | **393,3 → 480,0 = 86,7 pt** |
| fio da régua | 480,0 |

O aviso e o cartão flutuavam a 86,7 pt da barra, no meio do papel — **sobre o
texto do autor**, que é exatamente o que a `curva-zero` proíbe esconder. A
promessa da ADR ("vive no fluxo do pé") era verdadeira na árvore e falsa na tela.

**Achado B (a causa comum, e é uma só).** `CadernoView.swift` dá ao encaixe
`.frame(maxHeight: tetoDoEncaixe)` — **sem alinhamento**. Sem alinhamento o
conteúdo fica CENTRADO na caixa; e a caixa é o teto, que cresce 334 pt quando o
teclado desce. Daí saem os dois defeitos:

- em repouso, o ocupante flutua a meia altura da caixa → o vão de 86,7 pt;
- ao apresentar a folha, o teclado desce, o teto dobra, o centro muda de lugar e
  o cartão **salta ~176 pt no mesmo gesto** → duas geometrias no ar, que é a
  assinatura da classe A1.

`v12b-fantasma-antes.png` (quadros nativos 43, 45, 49, 53, 57, 59 de
`v12b-fantasma-antes.mp4`, quadros nativos a 27–30 fps): quadro 43 o cartão é branco e está em baixo;
quadro 45 ele está **176 pt acima**, e **sem o material do cartão** — chapado no
papel; quadros 57 e 59 ele desce outra vez enquanto a folha sobe. Três alturas
diferentes num gesto só.

**A causa NÃO é o `.sheet` e NÃO é a lei do movimento.** O defeito é idêntico
com e sem Reduzir Movimento (o juiz do re-G4 já tinha notado, e confirmo): o que
a lei governa desapareceria sob RM, e este não desaparece. O `.sheet` não pintava
fantasma nenhum — ele só **revelava** um encaixe que já flutuava.

### 3. Sistema — o que se reusa, o que não se cria

Nenhum token novo. `Tema.swift` não foi tocado (é da volta L2). A tinta da
cápsula desabilitada usa `Tema.tintaFraca`, que já existe e já é o "terceiro
nível de tinta que se lê"; o contorno usa `Tema.linha`, a hairline de estrutura
do app. Nenhuma curva, duração ou `withAnimation` novo — a lista congelada do
portão do movimento (volta P1) **só desce**.

### 4. Construir — a menor mudança que resolve cada causa

**(i) O encaixe cola no pé.** `CadernoView.swift`:
`.frame(maxHeight: tetoDoEncaixe, alignment: .bottom)`. Uma palavra.

**(ii) A pilha do encaixe passa a ser explícita.** `PaginaView.acimaDoPe` chega
ao `CadernoView` dentro de um `AnyView`; apagado o tipo, o `TupleView` deixa de
ser achatado pela pilha de baixo e os ocupantes espalhavam-se pela caixa. Um
`VStack(alignment: .leading, spacing: 0)` fecha isso.

**(iii) A `Pilula` desabilitada.** `tintaMorta` → `tintaFraca`, mais uma hairline
que guarda a cápsula. A tinta saiu do `body` para
`Pilula.tinta(ativa:cheia:forma:)` — decisão de acessibilidade não pode voltar a
1,53:1 sem alguém ver.

**A conta, colada** (WCAG 2.2 §1.4.3, luminância relativa):

| tinta | papel #F4F4F2 | chip #E8E8E6 | superfície #FFFFFF | névoa #EBEBEA |
|---|---|---|---|---|
| `tintaMorta` #C7C7CC (antes) | **1,53:1** | 1,37:1 | 1,68:1 | 1,41:1 |
| `tintaFraca` #68686C (agora) | **5,04:1** | **4,52:1** | **5,55:1** | **4,65:1** |

≥ 4,5:1 em **todo** fundo onde uma cápsula pousa no mundo claro. Quem diz
"desligado" passa a ser o **preenchimento que sai**, não o texto que apaga.

**(iv) O contorno à mão da `RecordarView` (com autorização do orquestrador).**
`RecordarView.swift:330-336` já desenhava a MESMA hairline no chamador, com o
comentário "desabilitada a `Pilula` fica sem fundo: sem o contorno ela volta a
ser o texto solto". Subida a regra para o componente, a linha passava a ser
desenhada duas vezes. Perguntei por `ask`; o orquestrador autorizou a deleção com
duas condições, ambas cumpridas:

- **a razão do chamador continua atendida pelo componente**, provado na tela:
  `v12b-recordar-antes.png` e `v12b-recordar-depois.png`, mesmo estado ("Revelar"
  desabilitado porque a memória está vazia). A pílula continua a ler como
  **desligada, não como texto solto** — cápsula inteira, tinta legível. E a
  hairline voltou ao peso do sistema: o pixel da borda mede **RGB 211 antes**
  (0,08 sobre 0,08 ≈ 0,153 de alfa) e **RGB 227 depois** (≈ 0,079, que é
  `Tema.linha`);
- **é o único chamador com contorno à mão**: `grep -rn "Capsule().strokeBorder(Tema.linha"` devolve só ele.

### 5. Mover — e o portão do movimento

Nenhuma animação nova. O que mudou no movimento foi **tirar** um: o salto de
176 pt do encaixe deixou de existir, e o cartão passa a viajar **com o teclado**,
que é o relógio que o próprio comentário do `CadernoView` diz querer ("quem
carrega o movimento é o teclado"). `withAnimation` novo: zero; curva literal
nova: zero; `.transition` nova: zero.

### 6. Julgar e Portão — o antes/depois na tela viva

**Fantasma, sem Reduzir Movimento.** `v12b-fantasma-depois-sem-rm.png` (quadros
119, 121, 123, 125, 127, 129 de `v12b-fantasma-depois-sem-rm.mp4`): o cartão está **na mesma altura nos
seis quadros**, com o seu material, enquanto o teclado desce e a folha sobe. Uma
geometria. Nenhum par legível na mesma faixa.

**Fantasma, com Reduzir Movimento.** `v12b-fantasma-depois-com-rm.png` (quadros
45–55 de `v12b-fantasma-depois-com-rm.mp4`, `ReduceMotionEnabled = 1`): o mesmo. Nenhum par legível.

**O vão virou medida.** Mesmo estado, mesma régua de medida
(`v12b-depois-large-vestida.png`):

| | antes | depois |
|---|---|---|
| cartão | 284,3 → 393,3 pt | 358,3 → **467,3** pt |
| **vão até o fio da régua** | **86,7 pt** | **12,7 pt** |
| fio da régua | 480,0 pt | 480,0 pt |

Os 12,7 pt são o `.padding(.bottom, 12)` do próprio cartão mais o fio. **Nenhuma
constante entrou no lugar do 88**: quem mede é o layout, e é isso que a ADR diz
em uma linha.

**O aviso, nos quatro estados pedidos** — em nenhum ele cobre a barra de ações:

| estado | captura | onde o aviso fica |
|---|---|---|
| teclado de pé, `large`, RM 0 | `v12b-toast-teclado-de-pe.png` | colado acima da régua, que está acima de "Trabalhar nisto" |
| teclado fechado, `large`, RM 0 | `v12b-toast-sem-teclado.png` | colado acima de "Trabalhar nisto" |
| **AX5**, teclado de pé | `v12b-toast-ax5.png` | acima da régua; "Trabalhar nisto" e "Mais ações da nota" inteiros abaixo dele |
| **Reduzir Movimento ligado**, teclado de pé | `v12b-toast-com-rm.png` | idem ao primeiro |

**Itens 2 e 4 do re-G4, refeitos no estado exato.**

- **Item 4 — o par que decide, COM O TECLADO DE PÉ**:
  `v12b-antes-large-vestida.png` / `v12b-depois-large-vestida.png` e
  `v12b-antes-ax5-vestida.png` / `v12b-depois-ax5-vestida.png`. Os quatro na
  forma **vestida** (o cartão traz `gesto.reconhecimento`, "isto é um desejo com
  obstáculo p…", o mesmo WOOP do G4), com o teclado de pé, que é o estado que o
  acervo da V12 nunca tinha fotografado.
- **Item 2 — AX5 não transborda**: passa, e passava **antes** de eu tocar em
  nada. As três condições estão em `v12b-antes-ax5-vestida.png` e
  `v12b-ax5-saidas-no-menu.png`. Não consertei o que já estava consertado; o que
  o depois mostra é que a mudança **não regrediu** o AX5 e ainda colou o cartão
  ao pé.

---

## Diferenças com o que os relatórios diziam

1. **O `88` já não existia.** A revisão da V19 é de uma árvore anterior ao merge
   da V12. O que sobrou do achado não é o número: é o vão de 86,7 pt que o
   substituiu, e esse eu medi e fechei.
2. **O item 2 do re-G4 já passava.** Fotografado antes de qualquer mudança minha.
3. **A quinta ocorrência da classe A1 não era do `.sheet` nem da lei do
   movimento**; era do `.frame(maxHeight:)` sem alinhamento. Uma palavra fecha os
   dois defeitos.
4. **O "Abrir os campos" mudou de casa.** O cartão `.forma` hoje oferece "Abrir a
   forma WOOP" (que veste, e faz os campos nascerem NO papel); só o cartão
   `.vestida` traz "Abrir os campos", que é o que abre a folha. Quem for
   reproduzir o gatilho precisa da forma **vestida pela análise automática**, não
   da forma proposta.

## O que esta volta NÃO prova

- **VoiceOver e Instruments não foram medidos.** Os achados são geometria e
  leitura de tela.
- **A sábia não foi exercitada** (`TRACO_SEM_MODELO=1`; nada gasto na conta).
- **Estados de falha e sem permissão** não foram reexercitados; a volta não os
  tocou.
- **A `Pilula` desabilitada foi fotografada numa tela só** (o "Revelar" do
  Recordar) e no preview. Os outros chamadores herdam a mesma tinta pelo mesmo
  método, e o teste cobre as seis formas — mas isso é código, não tela.
- **O aviso com RM foi fotografado com teclado de pé, não nos quatro estados
  cruzados com RM.** O aviso não tem movimento próprio que RM altere; a posição é
  a mesma nos quatro.
- **`v12b-fantasma-antes.png` e o par `*-antes-*` foram tirados da árvore com o
  build de `main`**; o par `*-depois-*` do build desta volta. Mesmo simulador,
  mesmo estado, mesmo método de medida.

## Portão do movimento e complexidade

- `withAnimation` novo: **0**. Curva literal nova: **0**. `.transition` nova: **0**.
- **O líquido do código NÃO é negativo, e não vou fingir que é.**
  `git diff --numstat -- Traco/ TracoTests/`: **+107 / −62 = +45**. Ignorando a
  reindentação do bloco que virou `VStack` (`git diff -w`): **+59 / −14 = +45** —
  o mesmo número, logo o crescimento é real e não é espaço em branco. Por arquivo:

  | arquivo | + | − | o que é |
  |---|---|---|---|
  | `CadernoView.swift` | 9 | 1 | **uma** linha de código (o `alignment: .bottom`); as outras 8 são o comentário que conta o porquê |
  | `PaginaView.swift` (`-w`) | 9 | 1 | 2 de código (abre/fecha do `VStack`), 7 de comentário |
  | `Pilula.swift` | 39 | 6 | a `static func tinta`, o `contorno`, o wrapper do `capsula`, o preview de desabilitado alargado, e ~11 linhas de comentário com a conta |
  | `RecordarView.swift` | 3 | 7 | **−4**: o contorno à mão apagado |

  O que cresce é **comentário, preview e o estado desabilitado que a volta veio
  entregar**; o `TracoTests/PilulaContrasteTests.swift` (67 linhas) é o portão. A
  regra "cada volta que migra para Componentes é líquida-negativa" **não foi
  cumprida** nesta volta: só a `RecordarView` devolveu linhas. É achado meu contra
  mim, e fica assim escrito para o revisor decidir.

## Verificação

```
✔ Test run with 890 tests in 144 suites passed after 8.249 seconds.
```

`xcodebuild build` **sem aviso**; `xcodebuild test` no UDID `6033B043`, sob
`com-trava.sh`, depois da última mudança de código.

## Scorecard (preenchido por mim; a nota final é do revisor independente)

| dimensão | nota | por quê |
|---|---|---|
| Visão | 9 | fecha três dívidas nomeadas do RUMO na tela onde o autor passa mais tempo; ciclo multiplicar, lacuna "Direção visual e uso simples" atualizada no EVOLUCAO |
| Contrato | 9 | ADR 08f curta, com a causa medida, o que muda e o que não muda; SPEC e EVOLUCAO coerentes com o código |
| Correção | 9 | 890/144 verde; teste novo (`PilulaContrasteTests`) para o comportamento novo, com a conta da WCAG dentro |
| Jornada real | 9 | escrever → vestir → abrir os campos percorrido na tela viva em `large` e AX5, com e sem RM; aviso nos quatro estados; itens 2 e 4 do re-G4 refeitos |
| Design | 9 | o encaixe passa a ler como o que a ADR sempre disse que era: colado ao pé, acima da régua. O vão de 86,7 pt era desenho por acidente |
| Simplicidade | 9 | nenhum passo, decisão ou tela a mais; o caminho comum encurta em compreensão (o aviso deixa de nascer sobre o texto) |
| Movimento | 9 | um movimento a MENOS (o salto de 176 pt); nada de curva nova; provado em quadros nativos com e sem RM |
| Componentes | 9 | o estado desabilitado sobe para `Pilula`, um lugar só, com preview e teste; um contorno à mão apagado no chamador |
| Acessibilidade | 9 | 1,53:1 → 5,04:1 medidos e colados; AX5 conferido na tela viva antes e depois; alvos e menu intactos |
| Performance | n/a | a volta não toca lista, editor nem parser; nenhuma medida feita, e nenhuma é devida |
| Privacidade e autoria | n/a | nenhuma rota de dados tocada |
| Estado honesto | 9 | o aviso — que é a superfície do estado honesto na Página — deixa de nascer sobre o trabalho do autor |
| Complexidade | 8 | **+45 linhas líquidas** no código de app, não negativo: uma palavra fecha os dois defeitos de layout, mas o estado desabilitado da `Pilula` (com preview, conta e portão) e os comentários que contam a causa custaram linhas. Só a `RecordarView` devolveu (−4). Não cumpri a regra da fila, e digo-o em vez de arredondar |
| Fora do app | n/a | nada fora do app |
| Relato | 9 | seis linhas no fecho, com caminho de cada captura |

## Seis linhas para o LACO

1. O fantasma do `.sheet` não era do `.sheet` nem da lei do movimento: o encaixe
   da Página estava **centrado** numa caixa cuja altura dobra quando o teclado
   desce, e por isso o cartão saltava ~176 pt no mesmo gesto em que a folha subia.
2. Uma palavra — `alignment: .bottom` — fecha isso e o vão de 86,7 pt entre o
   aviso e a barra ao mesmo tempo; provado em quadros nativos com e sem Reduzir
   Movimento, e medido pixel a pixel (12,7 pt agora, que é o padding e nada mais).
3. O `padding(.bottom, 88)` que a revisão da V19 acusou **já tinha caído** no
   merge da V12; o que sobrou era o vão que o substituiu, e nenhum número novo
   entrou no lugar dele.
4. O item 2 do re-G4 (AX5 com cartão e teclado) **já passava antes de eu tocar em
   nada** — está fotografado assim; o item 4 foi refeito nos quatro estados, com
   o teclado de pé, que é o estado que o acervo da V12 nunca tinha.
5. A `Pilula` desabilitada sai de 1,53:1 para 5,04:1 no papel e passa a guardar a
   cápsula; o contorno à mão que a `RecordarView` tinha foi apagado com
   autorização, e a hairline voltou ao peso do sistema (RGB 211 → 227).
6. Limite do instrumento, declarado: com as janelas de dois simuladores
   empilhadas nas mesmas coordenadas, `AXRaise` não basta — alguns toques meus
   caíram nos Ajustes do simulador vizinho antes de eu mover a minha janela para
   um monitor só meu. Nada do Traço do vizinho foi tocado.

## Capturas desta volta

| arquivo | o que prova |
|---|---|
| `v12b-fantasma-antes.png` | o cartão em três alturas num gesto só, ao tocar "Abrir os campos" (quadros nativos) |
| `v12b-fantasma-depois-sem-rm.png` | a mesma faixa, mesma altura nos seis quadros |
| `v12b-fantasma-depois-com-rm.png` | idem, com Reduzir Movimento ligado |
| `v12b-antes-large-vestida.png` | item 4: `large`, RM 0, **teclado de pé**, forma vestida — vão de 86,7 pt |
| `v12b-depois-large-vestida.png` | o mesmo estado, vão de 12,7 pt |
| `v12b-antes-ax5-vestida.png` | item 2 e item 4: AX5, teclado de pé, forma vestida — topbar fora da barra de status, "Mais ações da nota" acima do teclado, papel visível |
| `v12b-depois-ax5-vestida.png` | o mesmo estado depois, com o cartão colado ao pé |
| `v12b-ax5-saidas-no-menu.png` | item 2: "Abrir os campos" e "Deixar como nota" **inteiros** no menu do cartão, em AX5 |
| `v12b-toast-teclado-de-pe.png` | o aviso acima da régua, teclado de pé |
| `v12b-toast-sem-teclado.png` | o aviso acima de "Trabalhar nisto", teclado fechado |
| `v12b-toast-ax5.png` | o aviso em AX5, com as duas ações inteiras abaixo dele |
| `v12b-toast-com-rm.png` | o aviso com Reduzir Movimento ligado |
| `v12b-fantasma-antes.mp4` · `v12b-fantasma-depois-sem-rm.mp4` · `v12b-fantasma-depois-com-rm.mp4` | os filmes de onde saíram as três tiras, para quem quiser outros quadros |
| `v12b-recordar-antes.png` | "Revelar" desabilitado com a hairline dobrada (RGB 211) |
| `v12b-recordar-depois.png` | o mesmo com uma hairline só (RGB 227) e a cápsula intacta |

## Dívida que esta volta deixa nomeada

1. **`Pilula` desabilitada fotografada numa tela só.** Os outros chamadores
   (`NotasView`, `CadernoView`, `TrabalhosView`, `CalendarioFichaSistema`) herdam
   a tinta pelo método, mas ninguém os viu desligados na tela.
2. **`TrabalhoView` contorna o componente** (`levouAoObstaculo`, "Bloqueio:
   nenhuma ação desta folha some"). A razão dela era, em parte, o contraste que
   esta volta acabou de consertar; vale reler se o desvio ainda se paga. É área
   do Trabalho, não toquei.
3. **Em AX5, o texto do autor rola por baixo da topbar** ("Notas"/"Concluir" sem
   fundo próprio): visto em `47-s`/`57-s` da minha sessão. Não é da lista desta
   volta e não regrediu com ela, mas está na tela.
4. **A lei nova do instrumento** (janelas empilhadas) merece uma linha na ESTEIRA.
