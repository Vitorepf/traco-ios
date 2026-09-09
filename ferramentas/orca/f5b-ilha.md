# F5b — a Ilha do compromisso vivo, nos estados que ninguém tinha visto

**Papel:** FORA DO APP (Fable 5.1). **Worktree:** `volta-f5b-ilha`, sobre `fef7a14` (main). **Aparelho:** iPhone 17 Pro Max `6033B043-F436-41F9-B4F8-2D9E67761980`, o único que usei. O spec dizia "está desligado — ligue"; **eu o encontrei já ligado** às 20:38 (não sei quem ligou) e o desliguei ao fim, porque é o meu por spec. Nenhum outro simulador foi tocado; `C2416CBC`, `34CC3F94`, `C7341E64` e `A1DF082C` nem por engano.
**Skills:** `design-router` carregada antes de qualquer edição, pela fase 5 (auditar antes de tocar), como o spec mandou. Fases: **Ancorar** (a linha G0 do spec; o brief; as capturas da F1/F4/F5; `CompromissoVivo`/`DestaqueVivo` lidos inteiros, e os chamadores de `reconciliar`/`atualizarAtividade` um a um); **Sistema** (nenhum token novo: `Tema.ambar`, `Tema.meta`, `Tema.miudo` seguem; nenhuma cor, fonte ou espaço inventado — o único número novo é o recuo de 10 pt da região inferior da expandida, que existe para o canto da Ilha não comer a primeira letra); **Construir** (três mudanças de código, abaixo); **Mover** (dois vídeos, com e sem Reduzir Movimento — a Ilha anima pelo sistema, o Traço não escreve curva); **Julgar** (cada estado fotografado ANTES e DEPOIS, abaixo); **Portão** (scorecard no fim). `curva-zero` não se aplica: não há jornada nem formulário; a Ilha é uma superfície de um toque, e o toque já existia.
**Instrumento:** todo `xcodebuild` por `com-trava.sh`; todo `orca emulator` por `f5b-emu.sh`, que reata o meu UDID antes de cada ação e passa por `com-trava.sh` — **segurei a trava em cada toque**, e nos dois filmes segurei-a uma vez para o filme inteiro (`TRAVA_MINHA=1`), porque na primeira tentativa cada toque esperou a suíte da volta Q e o vídeo ganhou 100 s parado. Prova de tela é `xcrun simctl io 6033B043 screenshot`, sempre. Nenhum maestro, nenhum mouse, nenhuma voz, nenhum VoiceOver. A árvore de AX (`orca emulator ax`) devolve 503 na casa e na tela bloqueada (limite conhecido, ESTEIRA); as capturas foram conferidas contra o **log do `liveactivitiesd`** do mesmo instante (`Starting activity` com os ids e o `staleDate`), que é a segunda medida independente que a lei pede.

## O que a auditoria (fase 5) encontrou antes de eu tocar em código

| estado | o que a tela mostrou | captura |
|---|---|---|
| duas atividades vivas, casa | a Ilha compacta é do **Destaque** ("terminar o ca…"); o compromisso a 40 min não aparece. O `liveactivitiesd` mostra as duas a subir às 20:40:49 (`E32BEF94` stale à meia-noite = Destaque; `359FF65C` stale às 22:20 = fim do compromisso) | `f5b-antes-ilha-compacta-destaque-esconde.png` |
| duas vivas, bloqueada | só o cartão do Destaque; o do compromisso está na pilha atrás, invisível | `f5b-antes-bloqueada-so-destaque.png` |
| expandida do compromisso | contagem "36:1\|5": o último dígito cortado pelo teto de 76 pt | `f5b-antes-ilha-expandida-corte.png` |
| compacta, AX5, duas vivas | "terminar o ca…" com reticências limpas — **o "t" cortado da F4 não está mais na tela**; a compacta é idêntica em `large` e AX5 (a Ilha não escala com Dynamic Type) | `f5b-ax5-ilha-compacta-destaque.png`, `f5b-ax5-ilha-compacta-compromisso.png` |
| bloqueada, AX5 | o cartão escala (rótulo e frase maiores) | `f5b-ax5-bloqueada-destaque.png` |
| mínima | não existe com duas do mesmo app: o iOS mostra uma e empilha a outra (F1 D9, confirmado de novo) | — |

Diagnóstico: o defeito que impede a tarefa (o compromisso que **está acontecendo** não se anuncia porque o Destaque o esconde) vem antes do acabamento (o dígito cortado). Os dois se corrigem com o menor diff possível; nada mais foi redesenhado.

## O que fecha, item a item do spec

**1. A Ilha MÍNIMA — fotografada, não declarada.** Duas atividades do Traço não bastam (acima). Subi um segundo app com uma Live Activity vazia (`ferramentas/orca/f5b-outra/`: xcodegen + 30 linhas de Swift; instrumento, não produto — o `simctl install` recusou o primeiro build por falta de `CFBundleVersion` no appex, está no LEIA) e a Ilha encolheu as duas para o círculo. A do Traço é só o ícone, como o `minimal` já desenhava: **estrela âmbar** para o Destaque (`f5b-ilha-minima-destaque.png`, encostada; o app descartável solto à direita) e **calendário** para o compromisso (`f5b-ilha-minima-compromisso.png`; em AX5 igual, `f5b-ilha-minima-compromisso-ax5.png`). Nada a mudar: no círculo só cabe o ícone, e o ícone diz de que é.

**2. O FIM da atividade — fotografado nas três superfícies.** Semeei um compromisso de 1 min começando em 1 min (`f5b-semear.sh 6033B043 1 1 sem-destaque`). Antes do fim: compacta "0:22" e expandida "0:18" com a cápsula (`f5b-fim-1-*.png`). No fim (`staleDate` = fim, o `liveactivitiesd` acorda em "Marking activities stale"): compacta **calendário + "acabou"** (`f5b-fim-2-compacta-acabou.png`; em AX5 igual, `f5b-fim-2-compacta-acabou-ax5.png`), expandida **"Dentista / acabou"** sem contagem e sem cápsula (`f5b-fim-2-expandida-acabou-antes.png` — e aqui a curva do canto da Ilha comia o "a" de "acabou", a linha mais baixa da região; o recuo passou de 4 para 10 pt, `f5b-fim-2-expandida-acabou-depois.png`), bloqueada **"PRÓXIMO / Dentista 21:29 / acabou"**, sem o relógio relativo do topo (`f5b-fim-2-bloqueada-acabou.png`; a captura traz também o segundo pedido do sistema, "Deseja continuar permitindo as Atividades ao Vivo do app Traço?", que o iOS faz sozinho depois de algumas atividades — não é do Traço e não se responde por ele). **Por quanto tempo:** **na Ilha, o "acabou" saiu sozinho em menos de 12 minutos** (às 21:30:45 estava; às 21:42:33 a Ilha estava vazia, `f5b-fim-3-ilha-vazia-12min.png`, sem o app ter aberto e sem nenhuma linha de encerramento no `liveactivitiesd`); **na tela bloqueada o cartão "acabou" continuava aos 14 minutos** (`f5b-fim-3-bloqueada-acabou-14min.png`) e continua até o app voltar à cena e reconciliar. É o desenho honesto que o ActivityKit permite: não existe fim agendado — só `staleDate` — e o app só encerra quando volta à cena (`reconciliar`, em `TracoApp.aoAbrir` e no `didBecomeActive`). O que a tela diz nesse intervalo é a verdade: acabou. Fica no RUMO, para o aparelho do dono, medir quanto tempo o iOS deixa o "acabou" de pé antes de o retirar sozinho (o simulador não reproduz o teto de horas do sistema numa sessão de trabalho).

**3. A compacta com DUAS disputando, em AX5 — o "t" cortado caiu sozinho.** Conferido na tela antes de mexer (`f5b-ax5-ilha-compacta-destaque.png`, duas vivas, AX5): "terminar o ca…", reticências inteiras. E a razão de ser da F4 ter visto o "t": a Ilha **não escala** com Dynamic Type — a compacta em AX5 é pixel a pixel a mesma do `large` — então o corte que o juiz viu não era do tamanho de letra; era um quadro isolado de outra origem, e não se reproduz. Sai do RUMO. O que ESTA volta viu de glifo cortado foi outro: o "a" de "acabou" na expandida, comido pela curva do canto (item 2), e o dígito da contagem (abaixo).

**4. Movimento — dois vídeos.** `f5b-ilha-movimento.mp4` (25 s) e `f5b-ilha-movimento-reduzido.mp4` (25 s, `ReduceMotionEnabled=1` escrito no plist do aparelho e lido de volta; restaurado a 0 no fim e lido de volta), os dois pelo mesmo roteiro `f5b-filmar.sh`: **entrada** (o app abre, publica, a Ilha ganha o compromisso com a contagem), **troca de estado** (toque longo expande; toque em "Lembrar em 10 min" vira o recado "avisos desligados no iPhone" — o estado honesto de um contêiner recém-instalado sem permissão de avisos, o mesmo que a F1 fotografou), **saída** (o app reconcilia um compromisso passado e encerra; a Ilha volta ao vazio). O que muda com Reduzir Movimento: a expansão deixa de esticar e vira fusão; a troca de estado já era fusão nos dois. A Ilha anima pelo sistema; o Traço não escreve curva nem duração nela — o portão do movimento continua com a lista vazia.

## As três mudanças de código (e duas que NÃO servem, provadas)

| mudança | onde | prova |
|---|---|---|
| **o compromisso vence a Ilha**: `relevanceScore` 1 no `ActivityContent` do compromisso (request e update); o Destaque fica no 0 padrão, nomeado | `ProximoCompromisso.swift` (`relevanciaNaIlha`, 2 usos), `DestaqueDoDia.swift` (`relevanciaNaIlha`, 1 uso) | `f5b-depois-ilha-compacta-compromisso-vence.png` (as duas vivas — log às 21:06:30 e 21:06:31 — e a Ilha mostra "39:51"); na bloqueada o cartão do compromisso passa a ficar por cima e o Destaque atrás (`f5b-depois-bloqueada-dois-vivos.png`, pilha aberta em `f5b-depois-bloqueada-pilha-aberta.png`) |
| **a contagem da expandida não corta**: sai o `.frame(maxWidth: 76)` + `.multilineTextAlignment(.trailing)` | `TracoWidget.swift`, região `trailing` | `f5b-depois-ilha-expandida.png` ("29:07" inteiro; os dígitos ficam à esquerda da caixa que o `.timer` reserva para h:mm:ss, a folga à direita) |
| **o canto não come o "acabou"**: recuo horizontal da região inferior de 4 para 10 pt | `TracoWidget.swift`, região `bottom` | `f5b-fim-2-expandida-acabou-depois.png` |
| ✗ `fixedSize(horizontal: true)` na contagem | — | deixa a expandida **vazia** (só o ícone `leading` desenha), reproduzido duas vezes: `f5b-instrumento-fixedsize-expandida-vazia.png` |
| ✗ `.multilineTextAlignment(.trailing)` sem teto | — | corta de novo, "29:4\|8": `f5b-instrumento-alinhada-corta.png` |

Teste novo: `ForaDoAppTests.aIlhaEDoCompromisso` — fixa `ProximoCompromisso.relevanciaNaIlha > DestaqueDoDia.relevanciaNaIlha`. É um teste de contrato de uma constante, e digo isso: a prova de que a ordem FUNCIONA é a captura; o teste impede que alguém zere a relevância sem ler a ADR.

## Instrumento — o que custou e o que fica para os próximos

- **Toque na tela bloqueada só por gesto.** `orca emulator tap` não aciona botão nenhum na tela bloqueada (três tentativas em "Permitir", nada); `gesture` com begin/move/move/end no mesmo ponto aciona. O toque longo que expande a Ilha é um `gesture` com ~40 pontos `move` parados (1,1 s).
- **O helper perde o aparelho entre duas chamadas** (outra volta reata): `f5b-emu.sh` reata antes de cada ação. Com a suíte de outra volta na trava, cada toque espera minutos — o filme se faz com a trava segura uma vez (`TRAVA_MINHA=1`).
- **`uninstall` traz de volta o pedido "Permitir Atividades ao Vivo"**, e ele só se responde na tela bloqueada. `install` por cima **manteve o `.appex` idêntico ao build** nas quatro vezes desta volta (conferido por `cmp` do `TracoWidget.debug.dylib`), ao contrário do que a memória da F5 registrou — conferir sempre, não presumir.
- **Instalar por cima encerra as atividades vivas**; toda captura depois de um `install` é com estado ressemeado.
- Scripts que ficam: `f5b-semear.sh` (um compromisso com início e duração em minutos, com ou sem Destaque, negativo para "já passou"), `f5b-emu.sh`, `f5b-movimento.sh` (Reduzir Movimento on/off lendo de volta), `f5b-filmar.sh`, e o app `f5b-outra/`.

## Limites declarados (não descontam nota)

- **StandBy**: não perseguido, por ordem do spec (a F4 provou que o simulador não renderiza).
- **Quanto tempo o iOS mantém o "acabou" sozinho** (o teto de horas do sistema) e **o toque no aparelho real**: pendentes no iPhone do dono.
- **VoiceOver falado**: proibido; a acessibilidade da Ilha se prova pela captura e pelo `accessibilityLabel` no código ("Lembrar em 10 minutos", "Marcar como feito: …"); a árvore de AX não responde na casa.
- O simulador estava ligado quando cheguei; digo em vez de fingir que o liguei.

## Provas de máquina (por `com-trava.sh`, `-destination id=6033B043-…`)

- Build: `** BUILD SUCCEEDED **`, `grep -c warning:` = **0** (sete builds nesta volta, todos sem aviso).
- Suíte integral, `-parallel-testing-enabled NO`: `✔ Test run with 949 tests in 153 suites passed after 55.527 seconds.` / `** TEST SUCCEEDED **`, `grep -c warning:` = 0 (main passava 934; esta volta traz 1 — o teste novo no log: `✔ Test "ADR 08v: com os dois vivos, a Ilha é do compromisso — a relevância dele é maior" passed after 0.001 seconds.`).
- Commit: um só, no branch `Vitorepf/volta-f5b-ilha`, sem mesclar; o SHA vai no `worker_done` (um relato não pode conter o SHA do commit que o contém).

## Scorecard (preenchido por mim; a nota é do revisor)

| dimensão | nota | por quê |
|---|---|---|
| Visão | 9 | ciclo multiplicar: o compromisso que está acontecendo se anuncia sem abrir o app — antes o Destaque o escondia; lacuna do EVOLUCAO reescrita |
| Contrato | 9 | ADR 2026-09-08v; EVOLUCAO; código coerente com as duas |
| Correção | 9 | teste de contrato novo; suíte verde; nenhuma rota maestro tocada |
| Jornada real | 9 | os quatro estados do spec vistos na tela: mínima, fim (3 superfícies), AX5 com duas vivas, movimento; antes e depois de cada correção |
| Design | 9 | fases citadas com o que cada uma decidiu; tokens do Tema; o único número novo (10 pt) tem a foto do porquê |
| Simplicidade | n/a | sem jornada nova; a Ilha continua um toque, uma coisa |
| Movimento | 9 | dois vídeos; a Ilha é do sistema; Reduzir Movimento provado por leitura do plist e pelo quadro da expansão |
| Componentes | n/a | nenhum componente novo; `LinhaDaAcao`/`CapsulaLembrar` seguem no lugar |
| Acessibilidade | 8 | AX5 provado onde escala (bloqueada) e onde não (Ilha); rótulos existem; VoiceOver falado proibido; árvore de AX indisponível na casa — declarado |
| Performance | n/a | nada de lista, editor ou parser |
| Privacidade e autoria | 9 | nada novo sai do app; a Ilha continua sem nota selada |
| Estado honesto | 9 | "acabou" nas três superfícies, o recado sem permissão no vídeo, os dois consertos que não serviram registrados com foto |
| Complexidade | 9 | +2 constantes, −2 modificadores, +1 recuo; scripts e o app descartável são instrumento em `ferramentas/orca/` |
| Fora do app | 9 | compacta, expandida, mínima, fim, bloqueada, AX5, vídeo — todos com captura real; StandBy declarado |
| Relato | 9 | este arquivo |
