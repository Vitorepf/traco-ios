# F5b-B — a prova reprodutível da Ilha (resposta ao G3 de `revisao-f5b-ilha.md`)

**Papel:** FORA DO APP (Fable 5.1). **Worktree:** `volta-f5b-ilha`, sobre `abd09b0` (a recusa), que está sobre `05acc35` (a F5b). **Aparelho:** iPhone 17 Pro Max `6033B043`, o único que usei; **já estava ligado** quando cheguei e **fica ligado** (outra volta o usou durante esta, ver "Instrumento"). Avisei no comentário do worktree `main` ao começar (03:43), na colisão (04:0x) e ao terminar.
**Skills:** o portão do `design-router` disparou no arranque; **não desenhei nada** — a volta é de prova (teste, semeadura, captura, log), e o spec manda "nada de redesenho novo". Registro isso em vez de fingir as seis fases.
**Instrumento:** todo `xcodebuild` e todo `orca emulator` por `com-trava.sh` — nas cadeias de captura **segurei a trava uma vez** (`TRAVA_MINHA=1` dentro do wrapper, padrão do `f5b-filmar.sh`), porque outra volta rodava `xcodebuild test` no meu UDID entre duas chamadas. Prova de tela é `xcrun simctl io 6033B043 screenshot`. Nenhum maestro, mouse, voz, VoiceOver ou iPad.

## O que o revisor pediu e o que cada pedido recebeu

### 1. O teste segura o wiring, não a constante

O `ActivityContent` que sobe ao ActivityKit — `request`, `update` e o recado do intent — passa a nascer de **um construtor por atividade**: `ProximoCompromisso.conteudo(de:recado:)` e `DestaqueDoDia.conteudo(_:agora:)`. Os cinco sites que montavam `ActivityContent` à mão viraram chamadas ao construtor; não sobra nenhum `ActivityContent(` fora deles nos dois arquivos. O teste `ForaDoAppTests.aIlhaEDoCompromisso` lê `relevanceScore` (1 e 0), `staleDate` (= fim) e o estado do conteúdo construído, inclusive o do recado.

**Prova de que o teste morde** (mutação: apaguei `relevanceScore: relevanciaNaIlha` do construtor do compromisso, rodei `-only-testing:TracoTests/ForaDoAppTests`, restaurei):

```
✘ Test "ADR 08v: o conteúdo que sobe (request, update e recado) carrega a relevância — o compromisso vence a Ilha" recorded an issue at ForaDoAppTests.swift:323:9: Expectation failed: (compromisso.relevanceScore → 0.0) > (destaque.relevanceScore → 0.0)
✘ Test "ADR 08v: …" failed after 0.018 seconds with 5 issues.
✘ Test run with 25 tests in 1 suite failed after 0.292 seconds with 5 issues.
```

(A primeira tentativa com `-only-testing:…/aIlhaEDoCompromisso` correu **0 testes** — o id de Swift Testing não bate assim; está dito para ninguém repetir.)

**O segundo risco do revisor** (atividade já viva não recebe o score novo): `ActivityContent.difere(de:relevancia:)` compara estado **e** relevância; os dois `reconciliar` usam-no. Coberto no mesmo teste (`difere(de: estado, relevancia: 0)` é verdadeiro com estado igual).

**Limite declarado:** a suíte não exercita o ActivityKit (ADR 05u isola `atividades()` em teste). Um `ActivityContent` montado à mão fora do construtor não seria visto — é o que a revisão de código guarda. A prova em runtime é a tela, abaixo.

### 2. A semeadura publica pela rota real, e qualquer um reproduz

Causa confirmada como o revisor rastreou: o arranque só reconcilia a projeção que já está no disco. Correção mínima, com precedente (`TRACO_AVALIAR_IA`): em DEBUG, `TRACO_REPUBLICAR_CALENDARIO` no ambiente faz `TracoApp.aoAbrir` chamar `ProximoCompromisso.publicar(eventos, cal:)` — **a mesma função** que `CalendarioAgenda.publicarProximo`, o editor (`Sessao`) e o intent chamam ao gravar um compromisso. `f5b-semear.sh` lança com `SIMCTL_CHILD_TRACO_REPUBLICAR_CALENDARIO=1`, **exige o título semeado dentro de `superficie.json`** (não mais "arquivo mais novo") e, com `LOG=<arquivo>`, grava o `liveactivitiesd` do instante.

Como reproduzir, do zero:

```
U=6033B043-F436-41F9-B4F8-2D9E67761980
ferramentas/orca/com-trava.sh xcodebuild -project Traco.xcodeproj -scheme Traco -destination id=$U -derivedDataPath /tmp/dd build
xcrun simctl install $U /tmp/dd/Build/Products/Debug-iphonesimulator/Traco.app
LOG=/tmp/semeadura.log ferramentas/orca/f5b-semear.sh $U 40 60 destaque 'Dentista'
# → "semeado: Dentista em +40 min por 60 min, destaque (HH:MM:SS); 2 atividade(s) a subir no liveactivitiesd"
xcrun simctl io $U screenshot /tmp/ilha.png     # a Ilha mostra a contagem do compromisso
```

Saída real desta volta: `semeado: Dentista em +40 min por 60 min, destaque (04:16:20); 2 atividade(s) a subir no liveactivitiesd`.

### 3. Pares `large`/AX5, mesmo estado, log versionado do mesmo instante

Estado único nas seis capturas: Dentista em +40 min por 60 min, Destaque vivo, binário desta volta (`cmp` igual ao build nos dois dylibs; `nm` com `relevanciaNaIlha`).

| superfície | `large` | AX5 (`accessibility-extra-extra-extra-large`, lido de volta) | o que se vê |
|---|---|---|---|
| Ilha compacta (casa) | `f5bb-large-ilha-compacta.png` 04:16:27 | `f5bb-ax5-ilha-compacta.png` 04:18:18 | **o compromisso** ("39:50" / "37:59"); a Ilha é idêntica nos dois; os rótulos da casa escalam (prova de que AX5 aplicou) |
| tela bloqueada | `f5bb-large-bloqueada.png` 04:16:31 | `f5bb-ax5-bloqueada.png` 04:16:42; `f5bb-ax5-bloqueada-ao-acordar.png` 04:16:38 | o cartão do compromisso **por cima** nas duas; em AX5 o canto corta **"39 minut…"** (em `large`, "39 minutos" inteiro); ao acordar mostra "39:39" |

Logs: `f5bb-log-large.log` (a semeadura: `Starting activity` `69B2771C…` e `D7ACE4DC…` às 04:16:19–20, stale mais cedo às **05:56:18** = 04:16:18 + 100 min, o fim do compromisso) e `f5bb-log-ax5.log` (a janela inteira 04:16:19 → 04:18:19: **nenhuma** atividade subiu ou caiu entre as seis capturas). **O daemon não registra `relevanceScore`** — grep em todos os processos do simulador; a prova dele é qual das duas a Ilha mostra.

### O controle que eu não planejei — e que é a prova mais limpa

Às 03:59:51 e 04:06:59 outro worker rodou `xcodebuild test -destination id=6033B043` (sem avisar no comentário). Cada corrida instalou **o binário dele** — sem a 08v: `cmp` diferente, `nm` sem `relevanciaNaIlha` — o install encerrou as duas atividades, o iOS relançou o app por "Activity ended" e o arranque (ADR 05u, `reconciliar`) **reergueu as duas a partir da mesma projeção** (`f5bb-log-controle.log`, ids `2F19AAAE…`/`C496A60E…` às 04:07:00). Resultado na tela: **a Ilha voltou ao Destaque** (`f5bb-controle-sem-relevancia-ilha-compacta.png`, 04:13:05, "terminar o ca…"). Mesmo estado, mesma projeção, mesmo aparelho, só o `relevanceScore` diferente — antes/depois com uma variável. Depois reinstalei o meu build segurando a trava e refiz tudo (os pares acima).

### O que ficou como hipótese

`f5b-instrumento-alinhada-corta.png` mostra "29:48" inteiro; a ADR 08v passa a dizer que o corte por `multilineTextAlignment(.trailing)` **não foi provado**. A escolha de deixar os dígitos à esquerda da caixa do `.timer` se sustenta pela captura `f5b-depois-ilha-expandida.png` sozinha. Sem recaptura: seria mexer em código de produto só para fotografar um defeito hipotético.

## Instrumento — o que custou e o que fica

- **Helper `serve-sim-bin` de ontem responde `ok:true` e não injeta nada** (tap, gesture, button; a AX lia o meu aparelho). `orca emulator list --json` mostra um helper por UDID; matei **só o PID do meu** (26628) e reatei — sem `orca emulator kill`. O novo (35988) injeta.
- **`button lock` trava a tela; `side_button` não.** `button home` na bloqueada **não destranca**; destranca um `gesture` de deslizar de (0.5, 0.97) a (0.5, 0.3). Toque em botão de diálogo do sistema: `gesture` begin/move/move/end no centro do frame da AX.
- **Aparelho disputado:** o `xcodebuild test` alheio troca o binário e o iOS reergue as atividades com ele. Conferir por `nm`/`cmp` antes de qualquer captura; segurar a trava uma vez para instalar+semear+capturar.
- **Runner travado antes de conectar** na primeira corrida da suíte (`The test runner hung before establishing connection`, `** TEST FAILED **`, `teste-1-hung.log` no scratchpad); a segunda correu inteira — as duas saídas estão aqui.
- Os dois diálogos do sistema (notificações; "Permitir Atividades ao Vivo") aparecem em contêiner novo e só se respondem por gesto; "Não Permitir" mantém o estado honesto da F5b ("avisos desligados no iPhone").

## Provas de máquina (`com-trava.sh`, `-destination id=6033B043-…`, `-parallel-testing-enabled NO`)

- Build: `** BUILD SUCCEEDED **`, `grep -c warning:` = **0** (duas vezes: antes e depois da mutação).
- Suíte integral, 2ª corrida: `✔ Test run with 949 tests in 153 suites passed after 54.579 seconds.` / `** TEST SUCCEEDED **`, `grep -c warning:` = 0. Linha do teste: `✔ Test "ADR 08v: o conteúdo que sobe (request, update e recado) carrega a relevância — o compromisso vence a Ilha" passed after 0.004 seconds.`
- Mutação: `✘ Test run with 25 tests in 1 suite failed after 0.292 seconds with 5 issues.` (acima), fonte restaurado e conferido (`grep -c` = 1).
- Aparelho restaurado: `content_size medium` lido de volta às 04:18:19; tela na casa; **simulador ligado** (outra volta o usa).
- Commit: um só no branch `Vitorepf/volta-f5b-ilha`, sem mesclar; SHA no `worker_done`.

## Scorecard (preenchido por mim; a nota é do revisor)

| dimensão | nota | por quê |
|---|---|---|
| Visão | 9 | inalterada da F5b: o compromisso que está acontecendo se anuncia sem abrir o app |
| Contrato | 9 | o contrato de atualização da atividade viva fechou (`difere`), e a ADR diz o que é prova e o que é hipótese |
| Correção | 9 | teste que fica vermelho sem o wiring (mutação colada); suíte 949 verde; limite do ActivityKit em teste declarado |
| Jornada real | 9 | a semeadura publica pela mesma função da agenda/editor/intent; reproduzível do zero com quatro comandos |
| Design | n/a | nenhum desenho novo; portão disparou e foi declarado |
| Simplicidade | n/a | sem jornada nova |
| Movimento | n/a | nada novo |
| Componentes | n/a | nenhum |
| Acessibilidade | 8 | pares enquadrados e logados; achado novo em AX5 ("39 minut…") registrado como lacuna, não corrigido |
| Performance | n/a | — |
| Privacidade e autoria | 9 | nada novo sai do app; o gancho só existe em DEBUG e só relê o calendário local |
| Estado honesto | 9 | controle acidental relatado como acidente; hung colado; hipótese rebaixada a hipótese |
| Complexidade | 9 | +2 construtores, +1 extensão de 3 linhas, −5 montagens à mão, +1 gancho DEBUG de 6 linhas |
| Fora do app | 9 | prioridade provada por antes/depois com uma variável, em `large` e AX5, casa e bloqueada, com log versionado |
| Relato | 9 | este arquivo |
