# F5b-C — o corte em AX5 e as seis fases (resposta ao re-G3 de `revisao-f5b-ilha.md`)

**Papel:** FORA DO APP (Fable 5.1). **Worktree:** `volta-f5b-ilha`, sobre `d4975bf` (a re-recusa), que está sobre `0abdc4c` (a F5b-B). **Aparelho:** iPhone 17 Pro Max `6033B043`, o único que usei; já estava ligado e fica ligado. Avisei no comentário do worktree `main` ao começar (05:11) e ao terminar. Não toquei no Pro do Grok `C2416CBC`.
**Instrumento:** todo `xcodebuild`, `xcodebuild test` e `orca emulator` por `com-trava.sh`; nas cadeias instalar+semear+capturar **segurei a trava uma vez** (`TRAVA_MINHA=1`, padrão do `f5b-filmar.sh`). Prova de tela é `xcrun simctl io 6033B043 screenshot`. Nenhum maestro, mouse, voz, VoiceOver, Siri ou iPad. A árvore de AX da casa/bloqueada devolve 503 — nenhuma conclusão vem dela.

## O que o revisor pediu e o que cada pedido recebeu

### 1. O cartão da tela bloqueada não corta mais em AX5

**Causa, vista na tela e não inferida.** O relógio do canto do cartão (`Text(_, style: .relative)` na tela trancada, `.timer` ao acordar) tinha `.frame(maxWidth: 92, alignment: .trailing)`. Em AX5 "39 minutos" precisa de mais que 92 pt: "39 minut…". Tirar o teto resolve o corte mas revela por que o teto existia: **o `Text` de data é guloso** — toma toda a largura que a linha oferece e encosta o conteúdo à esquerda dela — e o relógio foi grudar em "PRÓXIMO" (`f5bc-instrumento-sem-teto-relogio-a-esquerda.png`, AX5, "34 minutos" inteiro mas colado ao rótulo). Com `multilineTextAlignment(.trailing)` e sem teto, o texto nunca corta e volta ao canto. É a mesma família dos dois glifos da F5b (o dígito da expandida, o "a" de "acabou"): uma medida em pt que não sobrevive ao tamanho de letra.

Diff de produto (uma linha sai, uma entra, mais comentário): `TracoWidget/TracoWidget.swift`, cartão do `CompromissoVivo`.

**Efeito colateral bom:** a contagem ao acordar ("39:43"/"39:26") passa a encostar na mesma borda que a hora "06:01". Antes ficava uns 40 pt para dentro (`f5bb-ax5-bloqueada-ao-acordar.png`, "39:39" solto) — era a mesma caixa gulosa, alinhada à esquerda.

**Pares refeitos, mesmo estado, mesmo binário, log ao lado.** Estado: Dentista em +40 min por 60 min, Destaque vivo, semeado pela rota real (`f5b-semear.sh`, saída `semeado: Dentista em +40 min por 60 min, destaque (05:21:32); 2 atividade(s) a subir no liveactivitiesd`). Binário: `cmp` igual entre o build e o instalado nos dois dylibs (`Traco.debug.dylib`, `TracoWidget.debug.dylib`). Tamanho lido de volta a cada passo (`lido: large` / `lido: accessibility-extra-extra-extra-large`), restaurado a `medium` e lido de volta (`restaurado: medium`).

| superfície | `large` | AX5 | o que se vê |
|---|---|---|---|
| bloqueada (trancada) | `f5bc-large-bloqueada.png` 05:21:42 | `f5bc-ax5-bloqueada.png` 05:21:59 | "39 minutos" **inteiro, no canto direito**, nas duas; "PRÓXIMO" e o relógio maiores em AX5 (prova de que o tamanho aplicou no cartão) |
| bloqueada ao acordar | `f5bc-large-bloqueada-ao-acordar.png` 05:21:45 | `f5bc-ax5-bloqueada-ao-acordar.png` 05:22:01 | contagem "39:43" / "39:26" inteira e alinhada à borda da hora |
| Ilha compacta (casa) | `f5bc-large-ilha-compacta.png` 05:21:38 | `f5bc-ax5-ilha-compacta.png` 05:21:55 | a Ilha é do compromisso ("39:50" / "39:33") — a Ilha não escala, como a ADR já dizia |

Logs: `f5bc-log-large.log` (a semeadura: `Starting activity` `5D33D25F…` e `84B1A73B…` às 05:21:31, stale às 07:01:29 = fim do compromisso) e `f5bc-log-ax5.log` (janela 05:21:50 → 05:22:07: **nenhuma** atividade subiu ou caiu entre as capturas AX5).

**Honestidade sobre a casa em AX5:** nos 5 s entre mudar o tamanho e fotografar, os rótulos da casa do SpringBoard **não** reescalaram (em `f5bc-ax5-ilha-compacta.png` estão iguais aos de `large`); o cartão da bloqueada reescalou no mesmo passe. A prova de que AX5 aplicou é o cartão e o `content_size` lido de volta, não a casa.

### 2. As seis fases do `design-router`, como foram aplicadas

Rota escolhida na skill: **ajuste local de componente** (estados afetados, sistema existente, mudança e verificação local). Não é redesenho; não abri moodboard, token novo nem crítico em série.

1. **Ancorar.** Pessoa/situação: o autor olha o iPhone trancado, em AX5, para saber quanto falta para o compromisso. Tarefa: ler o relógio do canto sem abrir nada. Resultado observável: "39 minutos" e "39:26" inteiros, no canto, em `large` e AX5, trancada e ao acordar. Plataforma: Live Activity na tela bloqueada do iPhone (o simulador renderiza; StandBy não). Restrições vigentes: nada de redesenho (spec), tokens de `Tema.swift`, **sem encolher texto** (ADR 08h: o corte honesto não encolhe), o cartão é o material do sistema. Escopo: uma linha do cartão. Evidência de partida: `f5bb-ax5-bloqueada.png` (corte) contra `f5bb-large-bloqueada.png` (inteiro).
2. **Sistema.** Nada novo: `Tema.miudo.weight(.medium).monospacedDigit()` e `.secondary` continuam; o âmbar e o rótulo "PRÓXIMO" não mudam. Precedente no mesmo arquivo: a `compactTrailing` já usa `multilineTextAlignment(.trailing)` na contagem. Regra que fica: **teto em pt num texto que escala é dívida** — o mesmo defeito voltaria em qualquer tamanho acima do medido. Regra que fica, a segunda: o `Text` de data é guloso; quem o põe numa `HStack` alinha, não mede.
3. **Construir.** Sai `.frame(maxWidth: 92, alignment: .trailing)`, entra `.multilineTextAlignment(.trailing)`; `lineLimit(1)` fica (se um dia não couber, corta com reticências em vez de quebrar a linha do rótulo). Sem wrapper, sem `minimumScaleFactor`, sem `fixedSize` (a F5b já viu o `fixedSize` esvaziar a expandida). Build `** BUILD SUCCEEDED **`, `grep -c warning:` = 0, duas vezes (o passo intermediário sem alinhamento e o final).
4. **Mover.** Nenhum movimento tocado: a contagem é o `.timer` do sistema, sem curva nem duração do Traço; a troca trancada→acordar é do iOS. Reduzir Movimento não muda o que esta volta alterou (a F5b já tem `f5b-ilha-movimento-reduzido.mp4` para a Ilha). Sem vídeo novo porque nenhuma transição mudou — declarado, não omitido.
5. **Julgar.** Matriz por estado, conferida na captura e não no nome do arquivo: as seis capturas acima, mais o passo intermediário que **não serviu** (`f5bc-instrumento-sem-teto-relogio-a-esquerda.png`) — está versionado porque é o achado que explica o teto original. Defeito material aberto: nenhum que eu tenha visto nas seis. Risco não testado: `.relative` com "1 hora"/"2 horas" (mais curto que "59 minutos", não corta por construção) e título de duas linhas em AX5 (outra linha do cartão, fora do escopo, sem regressão possível por esta mudança). Preferência estética que fica de fora: a caixa gulosa continua gulosa; só a âncora mudou.
6. **Portão.** Suíte integral por `com-trava.sh`, `-parallel-testing-enabled NO`, no `6033B043`: `✔ Test run with 949 tests in 153 suites passed after 55.355 seconds.` / `** TEST SUCCEEDED **`; `✔ Test "ADR 08v: o conteúdo que sobe (request, update e recado) carrega a relevância — o compromisso vence a Ilha" passed after 0.004 seconds.`; `grep -c warning:` = 0. Não há teste de unidade para um alinhamento de `Text` (a suíte não renderiza o widget): a prova de Correção desta mudança é o par de capturas, e está dito. ADR 08v estendida; EVOLUCAO fecha a lacuna nas duas linhas de "Fora do app".

### 3. O grupo de controle, com o nome certo

O que a F5b-B chamou de "o controle que eu não planejei" é um **grupo de controle** e é a prova mais limpa da ADR 08v, porque prova **por ausência**:

- **Tratamento:** binário com a 08v (`nm` com `relevanciaNaIlha`), duas atividades a partir da projeção `superficie.json`, a Ilha mostra o **compromisso** (`f5bb-large-ilha-compacta.png`, `f5bb-ax5-ilha-compacta.png`; hoje `f5bc-large-ilha-compacta.png`, `f5bc-ax5-ilha-compacta.png`).
- **Controle:** o `xcodebuild test` de outra volta (03:59:51 e 04:06:59) instalou no mesmo aparelho um binário **sem** a 08v (`cmp` diferente, `nm` sem `relevanciaNaIlha`); o install encerrou as atividades, o iOS relançou o app por "Activity ended" e o arranque (`reconciliar`, ADR 05u) reergueu as duas **a partir da mesma projeção** — `f5bb-log-controle.log`, ids `2F19AAAE…`/`C496A60E…` às 04:07:00. A Ilha voltou ao **Destaque** (`f5bb-controle-sem-relevancia-ilha-compacta.png`, 04:13:05, "terminar o ca…").
- **Uma variável:** mesmo aparelho, mesma projeção, mesmo par de atividades, mesmo estado semeado; só o `relevanceScore` presente ou ausente.

Por que vale mais que uma captura a mais: nenhuma captura **com** a 08v distingue "a relevância decidiu" de "o iOS escolheu por outro critério que por acaso coincide" (ordem de subida, id, hora). O controle é o que fecha essa porta. O daemon não registra `relevanceScore` — declarado e aceito — e por isso a prova é a tela com e sem. Está agora escrito assim na ADR 08v.

## Instrumento — o que custou e o que fica

- **O iOS pergunta "Deseja continuar permitindo as Atividades ao Vivo do app Traço?"** por cima do cartão, no meio de uma janela de captura (`f5bc-instrumento-dialogo-atividades.png`). O `tap` do `orca emulator` na **pilha fechada** abre a pilha em vez de acertar o botão; só com a pilha aberta o botão recebe o toque (0.72, 0.70 no Pro Max). Respondi "Permitir Sempre" e refiz o par `large` limpo.
- **Trancada mostra `.relative`, acordada mostra `.timer`** para o mesmo `contando()`: o iOS renderiza o cartão trancado num instante que não é o do acordar. As duas formas passam pelo mesmo `Text` e pelos mesmos modificadores, então o conserto cobre as duas — e as capturas mostram as duas.
- O `xcodebuild test` da suíte trocou o binário do `6033B043` pelo host de teste **depois** das capturas (mesmo código); quem for capturar depois de mim reinstala.
- Mesmo caminho da F5b-B para lock/acordar/destrancar: `button lock` tranca, `button home` acorda sem destrancar, o gesto de (0.5, 0.97) a (0.5, 0.3) destranca.

## Provas de máquina (`com-trava.sh`, `-destination id=6033B043-…`)

- Build: `** BUILD SUCCEEDED **`, `grep -c warning:` = **0** (duas vezes).
- Suíte integral, `-parallel-testing-enabled NO`, primeira corrida inteira: `✔ Test run with 949 tests in 153 suites passed after 55.355 seconds.` / `** TEST SUCCEEDED **`, `grep -c warning:` = 0. `xcresult`: `/tmp/dd-f5bc/Logs/Test/Test-Traco-2026.09.09_05-23-18--0300.xcresult`.
- Aparelho restaurado: `content_size medium` lido de volta às 05:22:07; tela na casa; simulador ligado.
- Commit: um só no branch `Vitorepf/volta-f5b-ilha`, sem mesclar; SHA no `worker_done`.

## Scorecard (preenchido por mim; a nota é do revisor)

| dimensão | nota | por quê |
|---|---|---|
| Visão | 9 | inalterada: o compromisso se anuncia sem abrir o app, agora legível em qualquer tamanho de letra |
| Contrato | 9 | ADR 08v diz a causa (texto guloso), o conserto, o que não serviu e o controle com nome; EVOLUCAO fecha a lacuna |
| Correção | 9 | suíte 949 verde na primeira corrida; a mudança é de layout e a prova dela é o par de capturas, dito sem fingir teste |
| Jornada real | 9 | seis estados vistos e conferidos no conteúdo, mesmo estado semeado pela rota real, log da janela |
| Design | 9 | as seis fases acima, cada uma com o que fez; nenhum token novo; um só ajuste, no lugar da causa |
| Simplicidade | n/a | sem jornada nova; `curva-zero` dispensada, como o revisor julgou válido |
| Movimento | n/a | nada tocado; declarado na fase Mover |
| Componentes | n/a | nenhum |
| Acessibilidade | 9 | AX5 sem corte na bloqueada trancada e ao acordar, `large` idem, tamanho lido de volta; VoiceOver proibido, declarado como limite |
| Performance | n/a | — |
| Privacidade e autoria | 9 | nada novo sai do app |
| Estado honesto | 9 | o passo que não serviu está versionado; a casa que não reescalou em 5 s está dita; o diálogo do sistema está dito |
| Complexidade | 9 | −1 linha de produto +1, mais comentário; nenhuma dependência |
| Fora do app | 9 | a superfície tocada (cartão da bloqueada) provada nos dois tamanhos e nos dois instantes; Ilha conferida de novo; controle por ausência nomeado |
| Relato | 9 | este arquivo, com as seis fases |
