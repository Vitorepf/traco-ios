**Veredito: NÃO PASSA.** Dois consertos, um por linha:
1. **O fantasma de "Abrir os campos" continua no topo `b49ee0f`**, com e sem Reduzir Movimento (3 de 3 tomadas, ~100 ms sem RM, ~125 ms com RM): por ~2–3 quadros de layout o cartão perde o material e o rótulo "OBSTÁCULO INTERNO (O SEU HÁBITO/MEDO)" do papel fica legível **entre a linha do cartão e as suas saídas**; no quadro seguinte o cartão está numa segunda geometria. Conserto: o cartão sai da tela (transação sem animação) **antes** de a folha subir, ou o papel não reflui enquanto o teclado desce; aceite: tira de quadros nativos **tela inteira**, sem par legível, nos dois modos.
2. **O autor escreve às cegas assim que o texto passa da altura do papel — em AX5 com o encaixe vazio e em `large` com o cartão**: as linhas novas e o caret entram por baixo do pé (AX5: 0 pixels de caret em 4 amostras com teclado e 3 sem; `large`: 370 caracteres, as duas últimas linhas e o caret sob o cartão). O frame do papel corre por baixo do encaixe (`Página` até y = 0,667 em AX5 e até 0,45 em `large`, dentro do cartão), então o `TextEditor` julga o caret visível quando não está. Conserto: o inset inferior do papel tem de cobrir o encaixe inteiro (pé, régua e cartão) em todo tamanho; aceite: digitar até passar do papel, em `large` com cartão e em AX5 sem ele, e ver a linha do caret acima da régua.

# G4 final da V12 — a Página paga a dívida (julgar do design)

Juiz: Claude Fable 5.1, sessão própria, 08/09/2026, 13h30–14h15. Worktree
`volta-v12b-pagina`, topo **`b49ee0f`**, build meu (`xcodebuild build` sob
`com-trava.sh`, `-derivedDataPath build`), **desinstalado e instalado** no meu
aparelho, conferido por símbolo (`nm Traco.debug.dylib | grep Pilula.*tinta` = 1,
binário de 13:36). Skills carregadas antes de qualquer captura: `design-router`
(fases **Mover, Julgar, Portão**) e a `curva-zero` como régua da Simplicidade.
Não editei arquivo do branch, não comitei; este relatório e as capturas
`g4f-*` são o único acréscimo, untracked.

**Instrumento.** iPhone 17 Pro Max **`6033B043`**, o meu. `TRACO_SEM_MODELO=1`
via `launchctl setenv` no simulador (motor local; nada gasto na conta de
ninguém). **Nenhum maestro, nenhum mouse**: direção por `orca emulator`
(`tap`/`ax`, coordenadas 0..1), **toda prova de tela por `xcrun simctl io
6033B043`** (screenshot, ou `recordVideo` com quadros nativos extraídos por
`ffmpeg` e carimbo de tempo do `ffprobe`). Estado do aparelho no fim: `large`,
`ReduceMotionEnabled = 0`, "Connect Hardware Keyboard" devolvido a `true` (era
`true` ao chegar; desliguei-o para ter o teclado de software na tela — sem isso
o item 4 não se fotografa), helper morto. Nenhum simulador proibido foi tocado;
o que aconteceu com o helper está na seção "Instrumento", porque afetou outros.

---

## Mover — antes/depois na tela viva, e o que a volta afirma contra o que se vê

| afirmação da volta | o que vi no topo `b49ee0f` | veredito |
|---|---|---|
| **1.** `alignment: .bottom` fecha o vão do toast **e** o fantasma do `.sheet` ("uma geometria, nenhum par legível na mesma faixa") | O **vão** fechou: em `large`, forma vestida e teclado de pé, o cartão pousa a **358 → 468 pt** e a régua a **484 pt** (`g4f-large-vestida-teclado.png`, `g4f-ax-j06.txt`), os mesmos ~15 pt que a volta mediu. O **salto de 176 pt** também sumiu: nos meus três filmes o cartão está na mesma altura enquanto o teclado começa a descer. Mas o **par legível está lá** (achado A1 abaixo): o `.sheet` que a volta diz não pintar fantasma nenhum continua a pintar um, e a ADR 08f afirma o contrário | **metade verdadeira** |
| **2.** O `88` já tinha caído; o item 2 do re-G4 já passava | Conferido no G3 por `git show 5937943` e por mim na tela: AX5 com cartão e teclado, topbar a **66 pt** (barra de status termina em 44), "Trabalhar nisto" **430–500 pt** e "Mais ações da nota" **505–630 pt**, teclado a **655** (`g4f-ax5-vestida-teclado.png`, `g4f-ax-j16a.txt`); menu do cartão com "Abrir os campos" e "Deixar como nota" **inteiros** (`g4f-ax5-saidas-no-menu.png`) | **passa** |
| **3.** `Pilula` desabilitada 1,53:1 → 5,04:1, contorno duplicado apagado | Medido por mim em `g4f-large-recordar-pilula.png` ("Revelar" desabilitado, memória vazia): tinta mais escura **(104,104,108) = #68686C**, fundo (244,244,242), **5,04:1**; hairline de **um** pixel (RGB 227) em cima e em baixo da cápsula. Recorte 1:1 em `g4f-large-recordar-pilula-1x.png`: cápsula inteira, sem preenchimento, tinta legível — lê como controle desligado, não como texto solto. Em AX5 idem (`g4f-ax5-recordar-pilula.png`) | **passa** |
| **4.** O encaixe vazio com teclado de pé (726 pt) foi consertado com `.fixedSize` | Em `large`: seis linhas digitadas com o encaixe vazio e o teclado de pé, papel **118 → 480 pt** (362 pt, `Página` h=0,3787), caret visível na sexta linha, régua logo abaixo (`g4f-large-vazio-teclado-6-linhas.png`). A caixa opaca da V12-B não existe. Mas assim que o texto passa da altura do papel — AX5 com o encaixe vazio, `large` com o cartão — **a linha do caret entra por baixo do encaixe** (achado A2) | **a caixa da V12-B caiu; o texto ainda é coberto quando cresce** |
| **5.** O quadro longo era o `fotografar()` do teste | Li o protocolo das 21 rodadas e a sonda por quadro; não refiz a medida. A causa está isolada com número (captura 127–162 ms na main thread; 6/6 limpas fora das janelas). Aceito como está: é medida do teste, não desenho | **aceito (não remedido)** |

**Nota sobre o acervo da volta.** As tiras `v12b-fantasma-depois-*.png` estão
**cortadas no cartão**: não mostram a faixa de baixo, onde a folha sobe e o pé
viaja — exatamente a crítica que o re-G4 fez ao acervo da V12-D. E a V12-C, que
mudou a geometria do encaixe depois desses filmes (`fixedSize`), **não refilmou**
("não volta por construção"). O par `v12b-recordar-antes/depois` é de um build
intermediário (a tinta do "Revelar" já é #68686C nos dois; o que muda é a
hairline dobrada), não do `main`: prova o contorno apagado, não o contraste.

## Julgar

### A1 — ALTO. O fantasma de "Abrir os campos" está vivo no topo, nos dois modos

Estado: `large`, forma vestida pela análise automática ("isto é um desejo com
obstáculo pela frente"), **teclado de pé**, toque em "Abrir os campos"
(`abrir-campos`, y = 0,45). Três filmes nativos, tela inteira:

| filme | quadros com par legível | duração (ffprobe) |
|---|---|---|
| `g4f-fantasma-sem-rm.mp4` (RM 0) | q29 → q38 (`g4f-fantasma-sem-rm-quadros-28-34.png`, `-35-41.png`, zoom em `g4f-fantasma-sem-rm-zoom.png`) | 2,395 → 2,515 s ≈ **120 ms** |
| `g4f-fantasma-sem-rm-2.mp4` (RM 0, mesma página, voltar e abrir de novo) | q34 → q39 (`g4f-fantasma-sem-rm-2-quadros-33-40.png`, `-zoom.png`) | 2,93 → 3,01 s ≈ **80–100 ms** |
| `g4f-fantasma-com-rm.mp4` (**RM 1**) | q35 → q44 (`g4f-fantasma-com-rm-quadros-34-41.png`, `-42-49.png`, `-zoom.png`) | 3,083 → 3,207 s ≈ **125 ms** |

O que os quadros mostram, na mesma faixa de 0,20 a 0,50 da tela:

- o cartão **perde o material** (fundo branco e sombra somem) já no primeiro
  quadro depois do toque, mas a sua linha e as suas duas saídas continuam
  desenhadas na mesma altura;
- o papel, refluído para a altura sem teclado, **atravessa o cartão**: o rótulo
  "OBSTÁCULO INTERNO (O SEU HÁBITO/MEDO)" aparece legível **entre "isto é um
  desejo com obstáculo p…" e "Abrir os campos / Deixar como nota"**, a caixa do
  campo "RESULTADO" por baixo das saídas, "SE [OBSTÁCULO], ENTÃO EU" na faixa da
  régua (onde só sobra "Todas") e "Virar Se–então" por baixo de "Analisar ·
  Recordar";
- em q36 (sem RM) e q42 (com RM) o título do cartão e o rótulo do papel ficam
  **literalmente sobrepostos**; em q40 e q42–q44 o cartão desce ~40 px
  enquanto a folha sobe: **duas geometrias** do encaixe no mesmo gesto.

É o que o re-G4 chamou de A5 e a volta veio fechar. A volta fechou **o salto de
176 pt** e o vão — isso é verdade e está nos meus quadros. Não fechou o par
legível: `alignment: .bottom` prende o cartão ao pé, mas o papel por baixo
continua a refluir para o layout sem teclado enquanto o cartão ainda está na
tela, e o `.sheet` compõe as duas árvores. **A construção não basta; faltava a
prova, e a prova diz não.** O defeito é idêntico com e sem RM — não é a lei do
movimento (ADR 05y/08e), como a volta e o re-G4 disseram —, mas isto não o torna
aceitável: é o caminho principal da ADR 05y, e a ADR 08f afirma em letra
"nenhum par legível na mesma faixa".

Duração honesta: ~100 ms é menos que os ~215 ms do G4 original e igual aos
~110 ms do re-G4. O que mudou nesta volta é a **afirmação**, não o pixel.

### A2 — ALTO. Assim que o texto passa da altura do papel, o autor escreve debaixo do encaixe

**Em AX5, encaixe vazio.** Teclado de pé, forma solta por "Deixar como nota",
40 caracteres na página; digitei 120 caracteres pelo teclado de software,
depois mais 60.

- `g4f-ax5-vazio-teclado.png` (e `g4f-ax-j17.txt`, `g4f-ax-j19.txt`): o papel
  mostra **três linhas** e a régua logo abaixo; **nenhuma** das linhas
  digitadas está na tela e **não há caret** (varredura da cor do caret,
  calibrada em `g4f-large-vazio-teclado-6-linhas.png` onde ele aparece: 0
  pixels em 4 amostras a 0,35 s, que cobrem o ciclo do piscar). A árvore diz
  onde o papel está: `Página` de y = 0 a **0,667** — o frame do papel corre
  **por baixo** de "Trabalhar nisto" (0,45–0,52) e de "Mais ações da nota"
  (0,53–0,66) até o teclado;
- com o teclado abaixado (`g4f-ax5-vazio-semteclado.png`, 3 amostras) o
  texto digitado aparece — "manha eu ficar / na cama depois / do alarme…" — e a
  **última linha está cortada por "Trabalhar nisto"**, ainda sem caret visível.

**Em `large`, com o cartão.** Página nova, 370 caracteres digitados de uma vez
com o teclado de pé; a forma vestiu a meio (`g4f-large-vestida-teclado-texto-longo.png`,
`g4f-ax-j21.txt`): o papel mostra sete linhas até "…comeca cedo com o", o
cartão logo abaixo — e as duas linhas seguintes ("sangue a circular … cafe da
manha") **e o caret não estão na tela**. A árvore: `Página` de 0,123 a
**0,451**, isto é, o frame do papel entra **77 pt dentro do cartão**
(0,374–0,490). O `TextEditor` mantém o caret "visível" dentro de um frame que
o encaixe cobre. Com o teclado abaixado (`g4f-large-vestida-semteclado-texto-longo.png`)
o resto do texto reaparece.

**O contraste com o que passa:** com seis linhas e o encaixe vazio em `large`
(`g4f-large-vazio-teclado-6-linhas.png`) o caret está à vista — porque o
texto ainda cabia no papel. O piso do papel (re-G4, item 1) garante três
linhas de papel; não garante que o papel role para mostrar a linha que se
escreve, e é isso que falha. É o "escrever às cegas" do G4 original (A2)
**de volta pela rolagem**: a V12-C mediu o inset (192 pt) com o teclado
físico e o papel rolado por programa até o fim — nunca com o caret a puxar a
rolagem e o cartão de pé. Uma volta que veio consertar "o cartão cobre o
texto" entrega o texto novo debaixo do cartão a partir da oitava linha.

(Limite: em AX5 a inserção caiu no meio do texto porque toquei dentro da frase
para focar; em `large` foi ao fim, numa página nova. A conclusão é a mesma nos
dois: em nenhuma das 11 amostras a linha do caret esteve visível.)

### O que passa, e é bom

- **O vão e o salto acabaram** — a decisão de prender o encaixe ao pé é a
  certa e está provada nos meus quadros: o cartão não muda de altura enquanto
  o teclado desce (A1 é sobre o papel por baixo, não sobre o cartão a saltar).
- **AX5 com cartão e teclado** (item 2 do re-G4): as três condições, na tela,
  medidas acima.
- **A `Pilula` desabilitada** lê como desligada; a hairline única voltou ao peso
  do sistema; o teste de contraste guarda a conta.
- **O piso do papel em `large`**: 160 pt com o cartão, 362 pt sem ele, texto e
  caret sempre à vista.
- O item 4 (par `*-vestida` com teclado de pé) está refeito por mim em `large`
  e AX5 (`g4f-large-vestida-teclado.png`, `g4f-ax5-vestida-teclado.png`), e o
  estado é o que decide: forma vestida, teclado de pé.

### A travessia da `curva-zero`

Roteiro: *escrever → a forma veste sozinha → abrir os campos → concluir.*

| estado | o que vi |
|---|---|
| vazio | data, papel, régua; o cursor já está lá (`j03`) |
| escrever | enquanto o texto cabe no papel, texto e caret à vista; **quando passa da altura do papel, o caret some sob o encaixe** — AX5 sem cartão, `large` com cartão (A2) |
| a forma veste | 0 toques; o cartão explica em uma linha e dá as duas saídas (`large`) ou o menu "•••" (AX5, saídas inteiras) |
| abrir os campos | 1 toque em `large`, 2 em AX5 — **empate com o antes**, medido pela volta e coerente com a árvore que li; **~100 ms de par legível** na entrada (A1) |
| voltar | "voltar" devolve a página com a forma vestida e o cartão no lugar (usei isto para o segundo filme) |
| desfazer | "Deixar como nota" a um toque, no cartão e no menu |
| erro/falha | não exercitado (o G3 cobriu; a volta não tocou) |

**Empate satisfaz?** Como contagem, sim: a volta moveu geometria, não
controles, e o roteiro não cresceu. Como Simplicidade da tela, **não chega a
9 nesta volta**: a auditoria V9 deu 6 porque o cartão cobria o trabalho; hoje
o trabalho fica à vista enquanto cabe no papel, mas a partir daí o autor volta a
escrever sem ver (A2) e o gesto principal ainda mostra o encaixe em duas geometrias (A1). O que
falta para 9 não é um toque a menos: é o caret sempre visível em todo tamanho e
o gesto de abrir a folha cortar limpo.

## Portão

| dimensão | nota | por quê |
|---|---|---|
| **Design** | **7** | Ancorar, Auditar, Sistema, Construir e Mover estão cumpridos e são bons (o encaixe cola no pé, o vão virou medida, a cápsula desligada existe). Julgar e Portão falham no que a volta afirma: o par legível está no gesto principal (A1) e o encaixe cobre a linha que se escreve quando o texto cresce (A2). Tokens: só `Tema` (`tintaFraca`, `linha`, `fundo`, `margem`); `lineWidth: 0.5` é a convenção que já existia em 26 lugares, não é token novo nem solto desta volta |
| **Simplicidade** | **7** | empate declarado e medido (1/1, 2/2), caminho comum evidente; cai por escrever às cegas quando o texto cresce (A2) — a `curva-zero` proíbe esconder o estado do trabalho |
| **Movimento** | **7** | nenhuma curva nova, nenhum `withAnimation`, a regex do `PortaoDoMovimentoTests` de `main` sobre o diff dá **zero**; o salto de 176 pt saiu (ganho real, provado). Cai por A1: par legível ~100 ms nos dois modos, no gesto que a ADR 08f declara limpo |
| **Componentes** | **9** | `Pilula.tinta(ativa:cheia:forma:)` fora do `body`, hairline no componente, preview com ligada/desligada lado a lado, `PilulaContrasteTests`; o contorno à mão do chamador saiu (−4). Um lugar só |
| (Acessibilidade, fora da minha lista) | 7 | AX5 com cartão passa (item 2); AX5 com encaixe vazio e texto a crescer reprova (A2); a `Pilula` desabilitada expõe `enabled=false` com rótulo inteiro (árvore lida por mim: `Revelar en=False`) |

**Nenhuma das quatro chega a 9. NÃO PASSA.** Os dois consertos estão na
primeira linha. E a **ADR 08f precisa dizer a verdade**: o que fechou foi o
vão e o salto; o par legível de ~100 ms no toque em "Abrir os campos" continua,
nos dois modos, e ou some ou entra na ADR com o número.

## Instrumento — o que aconteceu e fica registrado

- **O helper do `orca emulator` é um só na máquina** (já na ESTEIRA). Cada
  `attach` meu tirou o helper de outro worktree, e o deles tirou o meu: às
  13:36 (tirei o de `A1DF082C`), 13:44 e 13:47 (de `C2416CBC`), 13:53, 13:56,
  13:57, 13:58, 13:59, 14:01 (de `A1DF082C`, que reatava entre as minhas
  sessões). Com o helper alheio ativo, **`tap --device <meu>` recusa** ("No
  active emulator for this worktree") — nenhum toque meu caiu em aparelho
  alheio —, mas **`ax --device <meu>` devolve a árvore do aparelho do outro
  sem avisar** (li a tela de início do `A1DF082C` julgando ler a minha). Guarda
  que usei: `orca emulator list` antes de cada toque e de cada leitura
  (`meu.sh`), e a captura sempre por `simctl io` preso ao UDID. Quem dirigir
  hoje precisa disto.
- **`orca emulator type` entra pelo teclado físico** e só funciona com "Connect
  Hardware Keyboard" ligado — e com ele ligado o teclado de software nunca
  aparece. Para fotografar o item 4 desliguei a preferência do MEU UDID
  (`DevicePreferences.<UDID>.ConnectHardwareKeyboard = 0`, reboot) e digitei
  **tocando as teclas do teclado de software** (posições lidas da árvore AX,
  ~0,6 s por caractere). O `gesture` do helper não fez toque longo (colar não
  serviu). Restaurado a `true` no fim.
- **O diálogo de notificações** apareceu depois do primeiro "Concluir" e engoliu
  uma digitação inteira (o re-G4 já tinha visto); permiti e repeti.
- **O helper não sobrevive ao reboot do simulador** com o mesmo pid: reata.
- O app **não morreu** nenhuma vez (pid `87010` durante toda a sessão em
  `large`; `43029` depois do reboot para RM).

## Limites honestos

- Não medi VoiceOver nem Instruments; a sábia não foi exercitada
  (`TRACO_SEM_MODELO=1`).
- O A2 em `large` foi visto com o cartão de pé; `large` com encaixe vazio e
  texto mais alto que o papel não foi digitado (o cartão veste antes).
- Não refiz o `CadernoHitchesTests`; aceitei a causa isolada pela V12-D por
  leitura do protocolo.
- Não bissectei o A1 além do gatilho e dos quadros; a correção é do
  implementador. O caminho barato a testar primeiro continua o do G4 original:
  derrubar o cartão sem animação **e** não deixar o papel refluir enquanto a
  folha não cobre a tela (ou só apresentar a folha depois de o cartão sair).

## Capturas e filmes desta sessão (`ferramentas/orca/g4f-*`)

| arquivo | o que prova |
|---|---|
| `g4f-large-vestida-teclado.png` + `g4f-ax-j06.txt` | item 4, `large`: forma vestida, teclado de pé, papel 118–278 pt, cartão 358–468, régua 484 |
| `g4f-large-vazio-teclado-6-linhas.png` + `g4f-ax-j08.txt` | item 4, `large`: encaixe vazio, seis linhas e caret visíveis, papel 118–480 pt |
| `g4f-large-vestida-teclado-rm.png` | o mesmo estado com Reduzir Movimento ligado, antes do filme |
| `g4f-fantasma-sem-rm.mp4`, `-quadros-28-34.png`, `-35-41.png`, `-zoom.png` | **A1**, sem RM, tomada 1 |
| `g4f-fantasma-sem-rm-2.mp4`, `-2-quadros-33-40.png`, `-2-zoom.png` | **A1**, sem RM, tomada 2 |
| `g4f-fantasma-com-rm.mp4`, `-quadros-34-41.png`, `-42-49.png`, `-zoom.png` | **A1**, com RM |
| `g4f-large-campos.png` | a folha dos campos depois do gesto (`large`) |
| `g4f-ax5-vestida-teclado.png` + `g4f-ax-j16a.txt` | item 2 e item 4, AX5: topbar 66 pt, cartão, "Trabalhar nisto" e "Mais ações da nota" acima do teclado |
| `g4f-ax5-saidas-no-menu.png` + `g4f-ax-j16b.txt` | item 2: as duas saídas inteiras no menu do cartão |
| `g4f-ax5-vazio-teclado.png` + `g4f-ax-j17.txt`, `g4f-ax-j19.txt` | **A2**: AX5, encaixe vazio, texto digitado fora da tela, sem caret, papel até 0,667 |
| `g4f-ax5-vazio-semteclado.png` | **A2**: o mesmo com o teclado abaixado — a última linha cortada por "Trabalhar nisto" |
| `g4f-large-vestida-teclado-texto-longo.png` + `g4f-ax-j21.txt` | **A2** em `large`: 370 caracteres, cartão de pé, as duas últimas linhas e o caret fora da tela; papel até 0,451 (dentro do cartão) |
| `g4f-large-vestida-semteclado-texto-longo.png` | o resto do texto reaparece com o teclado abaixado |
| `g4f-large-recordar-pilula.png`, `-1x.png` | `Pilula` desabilitada: #68686C, 5,04:1, hairline única |
| `g4f-ax5-recordar-pilula.png` | a mesma cápsula em AX5 |

---

# re-G4 — o fantasma e a escrita visível, na tela (V12-E, topo `aafdc72`)

**Veredito: NÃO PASSA — por pouco, e por um achado novo.** Os dois consertos que pedi estão feitos e provados por mim na tela: **A1 fechou** (três tomadas, 222 quadros nativos, **zero** quadros com duas superfícies, sem e com Reduzir Movimento) e **A2 fechou** (o caret está à vista nos quatro estados, no fim e no meio, `large` e AX5; antes eram 0 pixels em 11 amostras). O que segura a volta: **B1 — em AX5 com cartão e teclado, a segunda linha de "Mais ações da nota" ficou 15 pt debaixo do teclado** (a pilha nova empurra o pé 36 pt para baixo; no topo anterior o botão tinha 26 pt de ar), e o relato afirma "INTEIROS" com uma foto que mostra o corte — é o item 2 do re-G4 anterior a regredir. Dois consertos de texto vão junto: a ADR 08f diz que "a folha cobre a tela nos dois instantes" do corte, e ao abrir não cobre (87–89 ms de papel nu com o teclado de pé, medidos); e as capturas "meio" do acervo com cartão mostram o `xyz` no FIM do texto. Conserto único de tela: o encaixe não pode transbordar sob o teclado em AX5 — o pé inteiro acima do teclado, com o piso do papel a ceder ou o pé a encolher; aceite: `Mais ações da nota` inteiro acima do teclado em AX5 com cartão, medido por pixel como abaixo.

Juiz: Claude Fable 5.1, sessão própria, 08/09/2026, 17h–18h. Worktree
`volta-v12b-pagina`, topo **`aafdc72`**, build meu (`build-for-testing`, esquema
`TracoUITests`, sob `com-trava.sh`, `-derivedDataPath build`,
`-parallel-testing-enabled NO` — havia cinco simuladores ligados). Não editei
arquivo do branch nem comitei; este acréscimo e as capturas `g4g-*` são
untracked. Skills: `design-router` (Mover, Julgar, Portão) e `curva-zero`.

**Instrumento.** iPhone 17 Pro Max **`6033B043`**, o meu. Nenhum mouse, nenhum
maestro, **nenhum `orca emulator`** — o helper estava anexado ao `64F7B8B4`
(de outra volta) e anexar o roubaria; o condutor foi o alvo `TracoUITests` da
própria V12-E (`xcodebuild test-without-building -destination id=<meu>`), que
só toca o UDID que recebe, com uma cópia do `v12e-conduzir.sh` em scratch que
não espera 180 s quando não há cartão. **Toda prova de tela por `xcrun simctl
io 6033B043`** (screenshot e `recordVideo`, quadros por `ffmpeg`, tempo por
`ffprobe`). `TRACO_SEM_MODELO=1` por `launchctl setenv`. "Connect Hardware
Keyboard" desligado para o meu UDID (reboot) e **devolvido a 1** no fim; RM
ligado por `defaults` + reboot e **devolvido a 0**; `large`; app parado.

**O que o aparelho escondia.** As duas primeiras corridas não vestiram a forma
(`g4g-large-autoanalise-desligada.png`): o contêiner do app no meu UDID tinha
`autoAnalise = false` (última entrada 16:57 — a sessão anterior deixou a
análise automática desligada, provavelmente pelo menu da nota em AX5). Não é
defeito do código; é estado. Religuei (`plutil` + `killall cfprefsd`) e deixei
ligado, que é o padrão. Quem for medir depois de mim: conferir isto antes de
culpar a análise.

## Mover — o gesto refilmado por mim, e os quatro estados

**A1, "Abrir os campos"** (`large`, forma vestida, teclado de software de pé,
480 caracteres). Por quadro, dois detectores de pixel: a barra ocre do cartão
(x 90–140, cor do caret, ≥ 60 px) e a pega cinza da folha (`g4g-quadros-*.txt`).

| tomada | quadros | último com cartão | primeiro sem cartão, régua e pé | borda da folha entra | folha cobre a faixa do cartão | quadros com duas superfícies |
|---|---|---|---|---|---|---|
| sem RM, 1 (`g4g-abrir-sem-rm-1.mp4`) | 74 | q26 2,210 s | q27 2,228 s | q33 2,317 s | ~q40 2,392 s | **0** |
| sem RM, 2 (`g4g-abrir-sem-rm-2.mp4`) | 82 | q28 2,162 s | q29 2,175 s | q36 2,262 s | — | **0** |
| com RM (`g4g-abrir-com-rm.mp4`) | 66 | q25 2,228 s | q26 2,250 s | q32 2,337 s | — | **0** |

Lido quadro a quadro nas tiras (`g4g-abrir-sem-rm-1-quadros-21-44.png`,
`g4g-abrir-com-rm-quadros-20-44.png`, `g4g-abrir-sem-rm-1-tira-corte.png`):
no quadro do corte o teclado **ainda está inteiro de pé**; cartão, régua e pé
somem juntos, o papel toma a faixa inteira até o teclado e mostra o texto desde
a primeira linha mais os seus campos ("RESULTADO (O MELHOR DESFECHO)", a caixa,
"OBSTÁCULO INTERNO…"); o teclado desce a partir do quadro seguinte e a folha
sobe por cima. **Não há quadro com o rótulo do papel entre a linha do cartão e
as saídas** — o par que eu tinha medido em ~100/125 ms não existe mais, nos
dois modos. Comparação de tomadas: antes ~100 ms sem RM e ~125 ms com; agora 0
em 3 de 3. A prova continua amostrada (uma câmera a ~60 fps quando a tela
muda); aceito isso como o conselho aceitou.

**A2, o caret.** Detector calibrado no meu G4 (cor (217,165,66), barra de 81
px em `large`, 204 px em AX5); quatro amostras a 0,35 s por estado, que cobrem
o ciclo do piscar. "Ligada" = a amostra em que o caret está aceso.

| estado | caret (ligada) | onde está o encaixe | antes (G4) |
|---|---|---|---|
| `large`, cartão, fim (`g4g-large-cartao-fim.png`) | 81 px, y = 343 pt, na última linha | cartão logo abaixo (~378 pt), régua, pé, teclado 641 | 0 px, linha sob o cartão |
| `large`, cartão, fim, **RM** (`g4g-large-cartao-fim-rm.png`) | 81 px, 343 pt | idem | — |
| `large`, cartão, "meio"* (`g4g-large-cartao-meio.png`) | 81 px, 343 pt | idem | — |
| AX5, cartão, fim (`g4g-ax5-cartao-fim.png`, `-rm.png`) | 204 px, y = 295 pt, "pensar. abc\|" | cartão com "•••", "Trabalhar nisto", "Mais ações…" (B1) | 0 px |
| `large`, vazio, fim (`g4g-large-vazio-fim.png`) | 81 px, 431 pt, dez linhas de papel | régua logo abaixo | — |
| `large`, vazio, **meio de verdade** (`g4g-large-vazio-meio.png`) | 81 px, 159 pt, "lendo e xyz\|escrevendo" na 2ª linha | — | — |
| AX5, vazio, fim (`g4g-ax5-vazio-fim.png`) | 204 px, 313 pt | régua, "Trabalhar nisto" e "Mais ações da nota" inteiros | 0 px em 7 amostras |

\* O condutor toca o papel a 12 % da altura do `TextEditor` e digita `xyz`:
só com o encaixe vazio em `large` isso caiu no meio do texto. Com cartão
(`large` e AX5) e em AX5 vazio o `xyz` entrou **no fim** — e a captura do
autor `v12e-large-cartao-meio.png` mostra o mesmo "abcxyz" no fim. O "meio"
na tela está provado num estado, não em quatro; o teste hospedado cobre o meio
por programa (E ⊆ P, 31/31 e 44/44), e isso eu li, não refiz.

**Resposta à pergunta da volta inteira:** sim, o autor vê o que escreve. Em
todo estado que digitei, a linha do caret está acima do encaixe, e o papel
rolou sozinho até ela (com o cartão a chegar inclusive: em `large` o cartão
veste a meio da digitação e a linha continua à vista no quadro seguinte).

## Julgar

### B1 — MÉDIO-ALTO. Em AX5 com cartão, o pé entrou debaixo do teclado

Estado: AX5, forma vestida (menu "•••"), teclado de software de pé. Três
imagens do topo `aafdc72` — a do autor (`v12e-ax5-cartao-fim.png`) e as minhas
sem e com RM — contra a minha do topo anterior (`g4f-ax5-vestida-teclado.png`).
Linhas de glifos do botão "Mais ações da nota", medidas por pixel na coluna
x 300–1000 (`g4g-ax5-pe-zoom.png`, `g4g-ax5-pe-compara.png`):

| topo | "Mais ações" | "da nota" | topo do teclado | o que sobra |
|---|---|---|---|---|
| `b49ee0f` (G4) | 1550–1700 px | 1739–1851 px, **113 px inteiros** | 1929 px (643 pt) | 78 px = **26 pt de ar** |
| `aafdc72` (autor, eu sem RM, eu com RM — iguais) | 1658–1808 px | 1847–**1913** px, **67 de 113 px** | 1924 px (641 pt) | **46 px = 15 pt sob o teclado**; botão 108 px (36 pt) mais baixo |

O botão continua tocável na primeira linha, e as duas saídas seguem inteiras
dentro do menu. Mas é um controle com 41 % da segunda linha debaixo do teclado,
no estado exato que o item 2 do re-G4 anterior certificou "inteiro", e a
volta escreve "Trabalhar nisto e Mais ações da nota INTEIROS acima do
teclado" sobre uma foto que mostra o corte. Causa que leio no código: o encaixe
deixou de ser `.safeAreaInset` (que reservava a sua altura toda acima do
teclado) e virou irmão numa `VStack` com o papel preso ao piso; em AX5 piso +
cartão + pé passam da altura livre e a pilha **transborda por baixo**. Com o
encaixe vazio (sem cartão) cabe, e o pé está inteiro (`g4g-ax5-vazio-fim.png`).

### O corte antes da subida — mais limpa, não invisível (pergunta 3)

O que a pessoa vê no toque: cartão, régua e pé **desaparecem no mesmo quadro**,
com o teclado ainda inteiro; o papel cresce para a faixa toda, **volta ao topo
do texto** (a linha que ela acabou de escrever desce ~145 pt) e mostra as
suas caixas de campo; ~90 ms depois entra a borda da folha e ~160 ms depois a
folha cobre a faixa onde o cartão estava. É um corte seco com salto de conteúdo
— uma terceira composição entre as duas que interessam —, igual sem e com RM.
Comparado ao fantasma: **melhor**, porque cada quadro é uma superfície só e
nada legível se sobrepõe; a invariante do conselho vale em todos os quadros
que li. Não é o que a ADR descreve: "a folha cobre a tela nos dois instantes"
é falso na abertura (papel nu, medido). O dedo a caminho do pé: o alvo some e
um toque atrasado cai no papel (move o caret; a folha cobre logo em seguida) —
não há alvo destrutivo por baixo, "Concluir" e a barra não se movem. Aceito o
custo; a ADR tem de nomeá-lo como é. **A volta da folha não foi filmada por
mim** (o condutor termina em "aberto" e não acrescentei código a um worktree
partilhado com o revisor): por leitura, com "voltar" o encaixe volta atrás da
folha ainda de pé; com arrasto para baixo o `isPresented` só cai no fim e o
encaixe entra por corte numa tela nua enquanto o teclado sobe. Fica como
limite e como pergunta para a próxima volta.

### Portão do movimento, tokens, telas, ADR (pergunta 4)

- A regex do portão (`TemaTests`: `duration:\s*[0-9.]+|\.spring\(response:|dampingFraction:|interpolatingSpring\(`) sobre as linhas acrescentadas em `Traco/`, `TracoTests/`, `TracoUITests/`: **0**. O `.animation(Tema.gaveta…)` do `CadernoView` está no lado `-` e no `+`: movido, não novo.
- Nenhuma cor, fonte, `padding(n)` ou `frame` literal nas linhas acrescentadas; `Tema.swift` intacto; **nenhum `struct … : View` novo**. As duas transações sem animação (`folhaEmCena`, `reguaEmCena`) são cortes, e cortes é o que a ADR 08f decide.
- A ADR citada no código é a **08f** (3 vezes); a correção da frase falsa ("nenhum par legível") está no `SPEC.md`, com o meu número.

### Acessibilidade (pergunta 5)

AX5 com cartão e AX5 vazio, teclado de pé: caret à vista nos dois, papel de
três linhas, régua e ações acima do teclado no vazio. **"Sem clipe" falha com
o cartão** (B1). Não medi VoiceOver.

### Os limites declarados — aceito os três

Prova amostrada (o conselho avisou; eu contei 222 quadros e o oráculo de
pixels fica no RUMO); teclado "EMULADO" dentro da suíte integral (dito, e o
teste sozinho subiu o teclado real — li o relato, não refiz); o alvo
`TracoUITests` (usei-o; ele dirige só o UDID que recebe, e o helper alheio
ficou intacto). Um limite que a volta não declarou: **em AX5 o gesto não se
filma pelo condutor** — "Abrir os campos" está dentro do menu e o
`abrir-campos` não existe como botão —, então o A1 em AX5 está provado por
construção (mesmo `abrirCampos`), não por quadro.

### A travessia da `curva-zero`

| estado | o que vi no topo `aafdc72` |
|---|---|
| escrever além do papel | a linha e o caret sempre à vista; o papel rola sozinho (fim e, no vazio, meio) |
| a forma veste | 0 toques; a linha continua à vista quando o cartão chega |
| abrir os campos | 1 toque em `large`; corte seco, sem par; a folha nasce inteira (`g4g-large-estados.png`) |
| AX5 | 2 toques via menu; caret à vista; **"Mais ações da nota" com a segunda linha sob o teclado com cartão** |
| voltar / soltar | não exercitado nesta sessão (limite acima) |

Empate de toques mantido. A Simplicidade chega a 9 pelo que a volta veio
fazer; o que a segura é o pé em AX5.

## Portão

| dimensão | nota | por quê |
|---|---|---|
| **Design** | **8** | A1 e A2 fechados e provados por mim; cai por B1 — um controle 15 pt sob o teclado em AX5, no estado certificado antes, afirmado inteiro |
| **Simplicidade** | **9** | o autor vê o que escreve em todo estado; empate de toques; "Deixar como nota" a um toque em `large` e no menu em AX5 |
| **Movimento** | **9** | 0 pares em 3 tomadas e 222 quadros, sem e com RM; nenhuma curva nova; o custo do corte (~90 ms de papel nu, salto de ~145 pt na linha ativa) é aceitável e está medido — a ADR tem de descrevê-lo assim, não como "coberto" |
| **Componentes** | **9** | nada novo em Componentes; `EscritaVisivel` é utilitário do Caderno, sem estado |
| (Acessibilidade, fora da minha lista) | 7 | caret à vista em AX5 com e sem cartão; pé sob o teclado com cartão (B1) |

**Design em 8: NÃO PASSA.** Um conserto de tela (B1) e dois de texto (a frase
da ADR sobre o corte; o "meio" do acervo com cartão é fim). Quando o pé em AX5
voltar a ficar inteiro acima do teclado — medido por pixel como acima, sem e
com RM —, esta volta passa: o que ela veio consertar está consertado.

## Capturas e filmes desta sessão (`ferramentas/orca/g4g-*`)

| arquivo | o que prova |
|---|---|
| `g4g-abrir-sem-rm-1.mp4`, `-2.mp4`, `g4g-abrir-com-rm.mp4` | **A1** refilmado: três tomadas |
| `g4g-quadros-sem-rm-1.txt`, `-sem-rm-2.txt`, `-com-rm.txt` | por quadro: barra do cartão e pega da folha, com tempo |
| `g4g-abrir-sem-rm-1-quadros-21-44.png`, `g4g-abrir-com-rm-quadros-20-44.png` | as tiras em volta do corte |
| `g4g-abrir-sem-rm-1-tira-corte.png` | quadros inteiros q26 → q44: o teclado de pé no corte, o papel nu, a folha a subir |
| `g4g-large-cartao-fim.png`, `-fim-rm.png`, `-meio.png`, `g4g-large-estados.png` | **A2** em `large` com cartão (caret 343 pt) e a folha |
| `g4g-ax5-cartao-fim.png`, `-fim-rm.png`, `g4g-ax5-estados.png` | **A2** em AX5 com cartão (caret 295 pt) — e **B1** |
| `g4g-large-vazio-fim.png`, `-meio.png`, `g4g-ax5-vazio-fim.png`, `g4g-vazio-estados.png` | **A2** com o encaixe vazio; o único "meio" de verdade |
| `g4g-ax5-pe-compara.png`, `g4g-ax5-pe-zoom.png` | **B1**: `b49ee0f` × `aafdc72`, a linha do teclado marcada |
| `g4g-large-autoanalise-desligada.png` | o estado que o aparelho escondia (análise automática desligada) |

# re-G4 (segundo) — o pé inteiro, e o par que sobrou é do sistema (V12-G, topo `0840424`)

**Veredito: PASSA.** B1 fechou e eu o medi de novo, com o meu olho e o meu pixel: em AX5 com o cartão e o teclado de pé, "Mais ações da nota" termina em **630,0 pt** e o `inputView` começa em **638** — **8 pt de ar**, sem e com Reduzir Movimento, iguais ao décimo (o condutor no meu Pro Max deu os mesmos frames que o autor mediu no Pro). O par que sobrou em AX5 (`UIMenu` a dissolver sobre os rótulos, ~65–70 ms) **é do sistema**, fica como limite declarado e não desconta. O custo dos 15 pt do cartão no iPhone de 874 pt é **aceitável e está dito**. Sobra **um conserto de texto na 08f** (T1, abaixo): a frase "a folha cobre a tela nos dois instantes" continua lá e continua falsa na abertura — é contrato, não tela, e vai ao G5 como uma frase a trocar antes do merge.

Juiz: Claude Fable 5.1, sessão própria, 08/09/2026, 18h15–18h35. Worktree `volta-v12b-pagina`, topo **`0840424`**, build meu (`build-for-testing`, esquema `TracoUITests`, sob `com-trava.sh`, `-derivedDataPath build`, `-parallel-testing-enabled NO` — sete simuladores ligados). Não editei arquivo do branch nem comitei; este acréscimo e as capturas `g4h-*` são untracked. Skills: `design-router` (Mover, Julgar, Portão).

**Instrumento.** iPhone 17 Pro Max **`6033B043`**, o meu (440×956 pt, captura 1320×2868). Nenhum mouse, nenhum maestro, nenhum `orca emulator`, nenhum `ax --device`; o condutor é o `TracoUITests` da V12-F/G (`test-without-building -destination id=<meu>`, `-autoAnalise <true/>` pelo próprio teste), com a cópia do `v12e-conduzir.sh` em scratch a fotografar e a filmar por **`xcrun simctl io 6033B043`** (quadros nativos por `ffmpeg -vsync passthrough`, tempos por `ffprobe`). "Connect Hardware Keyboard" posto a `0` para o meu UDID (reboot) e **devolvido a `1`** no fim; RM ligado por `defaults` no UDID + reboot e **devolvido a `0`**; `C2416CBC` e os outros cinco intocados. Os frames do condutor estão em `g4h-medidas-ax5-cartao*.txt`; a leitura por pixel em `g4h-pe-pixels.txt`.

## 1. O pé inteiro em AX5, sem e com RM

| | sem RM | com RM |
|---|---|---|
| `testAX5ComCartao` | passed (46,9 s) | passed (46,5 s) |
| "Trabalhar nisto" (XCUITest) | 430,3–499,7 | idem |
| "Mais ações da nota" (XCUITest) | 504,7–**630,0** | idem |
| `inputView` (topo real do teclado) | **638** | 638 |
| caixa branca do botão, por pixel (coluna central) | 504,7–630,0; fundo 630–638; cinza do teclado a partir de **639** | idem |
| pixel escuro mais baixo do texto do pé (retângulo do botão) | **617,3** pt, nas 4 capturas | 617,3, nas 4 |
| cartão recolhido | 331,7–397,3, cantos inteiros | idem |

`g4h-ax5-cartao-fim-{1,4}.png` e `-rm-fim-{1,4}.png`, lidas por mim antes desta tabela: "Trabalhar nisto", "Mais ações" e "da nota" inteiros, ar até a primeira fila de teclas, caret à vista em "pensar. abc|", o cartão "isto é um d…" com os cantos de cima redondos (no Pro Max cabe tudo, como a 08f diz). Nota de instrumento: no meu aparelho o teclado de software subiu **sem** barra preditiva (a primeira fila de teclas começa em 639); no Pro do autor a barra "Não / O / E" existia e o `inputView` ficava 44 pt acima de `app.keyboards`. O `medirPe` escolhe o mais alto dos dois, então a régua vale nos dois casos — mas quem for medir noutro aparelho deve saber que a barra preditiva não é garantida.

## 2. O par que sobrou: é do sistema

Refilmei os dois modos (`g4h-ax5-cartao-abrir.mp4`, 90 quadros; `g4h-ax5-cartao-rm-abrir.mp4`, 73 quadros) e li as tiras q30–q53 (`g4h-ax5-sem-rm-quadros-30-53.png`, `g4h-ax5-com-rm-quadros-30-53.png`; assinatura por quadro em `g4h-quadros-*.txt`):

| | sem RM | com RM |
|---|---|---|
| último quadro com o pé | q33 (2,320 s) | q33 (2,217 s) — pé desfocado atrás do menu |
| encaixe cortado (cartão, régua e pé fora) | **q34 (2,337 s)** | **q34 (2,242 s)** |
| menu do sistema a sair sobre os rótulos do papel | q35–q44 (2,350–2,422 s, **~70 ms**; encolhe e dissolve) | q36–q41 (2,250–2,318 s, **~65 ms**; só dissolve) |
| pega da folha entra | q40 (2,388 s) | q40 (2,300 s) |
| folha cobre a faixa | q45+ | q43+ |

**Em nenhum quadro do desvanecer há cartão, régua ou pé** — o encaixe já saiu por corte um ou dois quadros antes de o menu começar a sumir, nos dois modos. O que fica legível ao mesmo tempo é "Abrir os campos / Deixar como nota" (a `UIMenu` que o UIKit desenha para o `Menu` do SwiftUI, `CartaoAnaliseView.portaDaProsa`) sobre "RESULTADO (O MELHOR DESFECHO)" e "OBSTÁCULO INTERNO (O SEU HÁBITO/MEDO)", que são conteúdo do papel por desenho. Julgado contra a invariante, com as palavras dela: *em cada quadro apresentado enquanto a Página recebe escrita, a linha ativa e o caret pertencem à área livre do papel; nenhuma outra superfície desenha nessa área.* Nesses quadros a Página **não recebe escrita**: o menu é modal, o teclado já desceu quando ele abriu (dois segundos antes, no toque do autor na linha do cartão), e o caret não está em cena. E a superfície que dissolve não é nossa: quem a apresenta e quem a despede é o UIKit, ao selecionar a ação; o `Menu` do SwiftUI não expõe conclusão do descarte, e a única forma de "não provocar" o par seria atrasar `abrirCampos` por um número chutado até o menu sumir — o que trocaria um limite do sistema por uma constante nossa. Não somos nós que provocamos o menu naquele instante: o autor o abriu, o autor o fechou ao escolher. **Limite declarado, não desconta.** A 08f já o diz na prova da V12-G ("superfície do UIKit, não do encaixe"); pedi só que continue dito com o número.

O papel nu continua a existir e continua medido: do corte à pega da folha são **6 quadros nos dois modos** (q34–q39: ~50 ms sem RM, ~45 ms com RM, no Pro Max; no Pro do autor, q27→q35 na V12-F, os 87–89 ms que medi no re-G4 anterior). É o custo do corte que aceitei da outra vez e aceito agora.

## 3. Os 15 pt do cartão no iPhone de 874 pt

Não tenho o Pro; li `v12g-ax5-cartao-pe-inteiro.png` (o do autor, 1206×2622): o cartão recolhido nasce sem o recuo de cima — o canto superior é reto, o trilho dourado começa na borda — e a linha "isto é um…" com o "•••" está inteira. É a regra da metade da 05y a valer contra o cartão e não contra o texto, e no meu Pro Max o mesmo cartão tem os cantos inteiros. **Aceitável**: não é regressão desta volta (por leitura do autor, `b49ee0f` já cortava o mesmo cartão nesse aparelho — não medi eu), o teto é contrato com teste (`CadernoTetoTests`), e a alternativa — o cartão ganhar do piso — é decisão de outra volta. Dívida nomeada para o RUMO, uma linha: quando o teto não dá o recuo, uma variante do cartão recolhido sem o recuo de 16 (em vez de recortá-lo) teria os cantos inteiros no 874 pt sem tocar a regra.

## Portão

| dimensão | nota | por quê |
|---|---|---|
| **Design** | **9** | B1 fechado e medido por mim: 8 pt de ar, texto do pé 21 pt acima do teclado, sem e com RM; cartão e caret inteiros; o custo do 874 pt está dito com número |
| **Simplicidade** | **9** | jornada intocada (nenhum toque a mais ou a menos; o condutor da V12-F é a régua) |
| **Movimento** | **9** | nenhuma curva nova, `Tema` intacto; 0 pares do encaixe nos dois modos; o par que resta é a `UIMenu` do sistema (~65–70 ms), limite declarado; papel nu ~45–50 ms no Pro Max, medido |
| **Componentes** | **9** | nada novo em Componentes; +1 linha de layout em `CadernoView`, +30 no condutor |

- **Tokens:** nenhum novo; a única linha de app é `.fixedSize(horizontal: false, vertical: true)`.
- **Movimento vindo de `Tema`:** nenhum `withAnimation`, duração ou curva entrou; `Tema.swift` não está no diff.
- **Nenhuma tela nova:** confirmado no `--stat` do commit (`CadernoView`, o condutor, SPEC, EVOLUCAO, capturas).
- **A ADR é a 08f:** a seção "O pé é rígido na pilha (V12-G)" descreve o que a tela faz — a causa (proposta aceita pelo `frame(minHeight:)`, pilha a meio), o conserto, os 8 pt, o custo dos 15 pt, o menu do sistema com número, a régua do `inputView`. Conferido contra o diff e contra a minha tela.
- **T1 — achado de contrato, não de design (uma frase):** em "O que esta seção não muda" a 08f ainda diz *"ao abrir a folha o encaixe some por corte e, ao voltar, reaparece por corte — a folha cobre a tela nos dois instantes"*. Na abertura é falso, e a própria ADR se contradiz duas linhas acima ("do toque até a folha cobrir a tela, a única superfície na faixa é o papel"): entre o corte e a pega da folha há **6 quadros de papel nu** (q34–q39 aqui; q27–q34 no Pro da V12-F), ~45–90 ms conforme o aparelho. Pedi este conserto no re-G4 anterior e a V12-G não o fez. Não segura o design — a tela está certa e o custo está medido —, mas a 08f já mentiu uma vez nesta volta e não pode ir ao merge com a frase. Troca proposta: *"ao abrir, o encaixe some por corte e o papel fica só, nu, por ~6 quadros (45–90 ms, medido) até a folha subir; ao voltar, reaparece por corte atrás da folha ainda de pé"*.

## Capturas e filmes desta sessão (`ferramentas/orca/g4h-*`)

| arquivo | o que prova |
|---|---|
| `g4h-ax5-cartao-fim-{1..4}.png`, `g4h-ax5-cartao-rm-fim-{1..4}.png` | **B1 fechado**: o pé inteiro em AX5 com cartão, sem e com RM, quatro amostras cada |
| `g4h-pe-pixels.txt` | a coluna central por pixel (caixa 504,7–630,0; teclado a partir de 639) e o pixel escuro mais baixo do pé (617,3) nas 4+4 capturas |
| `g4h-medidas-ax5-cartao.txt`, `-rm.txt` | os frames do condutor (`inputView` 638; "Mais ações da nota" 504,7–630,0) |
| `g4h-ax5-cartao-abrir.mp4`, `g4h-ax5-cartao-rm-abrir.mp4` | "Abrir os campos" refilmado nos dois modos |
| `g4h-ax5-sem-rm-quadros-30-53.png`, `g4h-ax5-com-rm-quadros-30-53.png` | as tiras do corte: q34 sem encaixe, o menu do sistema a sair sobre os rótulos, a folha a subir |
| `g4h-quadros-sem-rm.txt`, `-com-rm.txt` | por quadro: tempo, pixels do pé, brancos, escurecimento do fundo |
| `g4h-ax5-cartao-digitado-{1,4}.png`, `-meio-{1,4}.png`, `-folha.png` (e `-rm-`) | os outros estados do condutor: escrita, meio, folha aberta |
