# MAC-0 — o Grok Bot configurado de ponta a ponta

Volta de configuração do Mac do dono, 08/09/2026 à noite. Worker: Fable 5.1, branch `Vitorepf/volta-mac-0`. Exceção única à lei do mouse (ESTEIRA, `6613a72`): computer-use do Orca só no Grok Bot (`com.anysphere.sand`) e no Espelhamento do iPhone (`com.apple.ScreenContinuity`). Voz, VoiceOver, iPad e simulador: não tocados.

## O que já estava feito (conferido, não refeito)

- `.cursor/mcp.json` declara o servidor `traco` com `python3 /Users/vitorepf/develop/traco-ios/ferramentas/traco-mcp/servidor.py '/Users/vitorepf/Library/Mobile Documents/com~apple~CloudDocs/Traço'`.
- Autoteste do servidor do checkout principal: `python3 servidor.py --autoteste` → `autoteste ok`.
- `~/.grokbot/settings.json`: `mcpBoxServers: []`, `mcpCustomInstructionsByServerId` com três servidores (ids 3037497, 3237977, 3432659). Não alterados.

## Achados antes de tocar em qualquer coisa

1. **A tela do Mac estava bloqueada** (`CGSSessionScreenIsLocked = 1` desde 21:23). Com a tela bloqueada a acessibilidade não expõe janela nenhuma: o Grok Bot (pid 68362) e o Espelhamento (pid 60681) rodavam, mas `orca computer get-app-state` devolvia `window_not_found` para os dois. Escalado ao coordenador às 21:46; o worker não desbloqueia a máquina de ninguém.
2. **O servidor apontado pelo `.cursor/mcp.json` não tem `traco_agenda` nem `traco_decisoes`.** Elas existem só no `servidor.py` do worktree da MAC-1 (`/Users/vitorepf/orca/workspaces/traco-ios/volta-mac-1`), ainda não mesclado. Lista real do servidor do main, por `tools/list` via stdio: `traco_contrato, traco_indice, traco_notas, traco_nota, traco_buscar, traco_sentidos, traco_corpus, traco_semana, traco_escrever, traco_metodo_escrever`. Sem a MAC-1 mesclada, "bom dia" não pode chamar `traco_agenda`.
3. **A pasta espelhada não existe no Mac** (`~/Library/Mobile Documents/com~apple~CloudDocs/Traço`). Chamada real ao servidor com esse caminho (`traco_buscar`, termo "Traço"):

   > A pasta do Traço não está em /Users/vitorepf/Library/Mobile Documents/com~apple~CloudDocs/Traço. Escolha uma pasta no app (Perfil › Espelhar numa pasta) ou passe o caminho como argumento.

   É a mensagem honesta que a tarefa pede como prova mínima.

## Scorecard (preenchido pelo worker; a nota é do revisor)

| dimensão | nota | evidência |
|---|---|---|
| 1. Pasta espelhada criada pelo caminho do produto | não executado | tela bloqueada: o Espelhamento não expôs janela em duas horas (21:40–23:17) |
| 2. Servidor `traco` visível no Grok Bot com ferramentas | não executado | idem; fora do app, o servidor do main responde a `tools/list` com 10 ferramentas, sem `traco_agenda`/`traco_decisoes` |
| 3. Bot "Traço" com README + seis casos + regras de origem | não executado | texto pronto para colar (ver "Como retomar"); nada colado |
| 4. Prova de uso | parcial, fora do app | só a mensagem honesta do servidor por stdio (acima); nenhuma resposta do bot |
| 5. Mouse devolvido e tudo o que tocou registrado | feito | o cursor nunca foi tomado, nas duas passadas; tabela abaixo |

## Capturas

Nenhuma de tela: com a tela bloqueada o provedor não captura janela (`window_not_found`). A única prova é a saída do servidor por stdio, colada acima.

## Espera e escalada

- 21:46 escalada ao coordenador (msg_35fb8a9f8a82) e pergunta bloqueante (thread msg_2a13b94fd20c) com duas dúvidas: desbloquear o Mac, e qual `servidor.py` cadastrar no Grok Bot enquanto a MAC-1 não mescla (a: worktree da MAC-1; b: esperar a mesclagem; c: provar só com o main).
- A pergunta expirou três vezes (22:16, 22:47, 23:17), retomada pela mesma thread, sem resposta. Heartbeat a cada 5 min. `CGSSessionScreenIsLocked` continuou 1 até 23:17.
- Sem o dono na máquina, a exceção do mouse não tem como ser exercida. A volta fecha como **falha por bloqueio**, sem nada desfeito e sem nada configurado.

## Como retomar (para quem pegar a volta com a tela aberta)

1. Confira o bloqueio antes de tudo: um swift de três linhas lendo `CGSessionCopyCurrentDictionary()["CGSSessionScreenIsLocked"]`. Se for 1, pare e escale.
2. Decida o servidor: `traco_agenda` só existe no `servidor.py` do worktree da MAC-1. Ou a MAC-1 mescla antes, ou o cadastro no Grok Bot aponta provisoriamente para `/Users/vitorepf/orca/workspaces/traco-ios/volta-mac-1/ferramentas/traco-mcp/servidor.py` (e o relatório diz isso).
3. Texto do bot: `cat casos/README.md casos/01-*.md casos/02-*.md casos/03-*.md casos/08-*.md casos/09-*.md casos/11-*.md` do worktree da MAC-1 (9,3 KB). Regras de origem: o bloco "Regras de origem, para todos os casos" de `ferramentas/grokbot/CASOS.md` vai em `mcpCustomInstructionsByServerId` sob o id que o app der ao servidor `traco`. Não tocar nos ids 3037497, 3237977 e 3432659.
4. A janela do Grok Bot está no display da esquerda (`window-state.json`: x=-3674). `orca computer` não abre app fechado; `open -a "Grok Bot"` abre sem cursor.

## Tudo o que tocou no Mac do dono

| quando | onde | o quê | antes → depois |
|---|---|---|---|
| 21:40 | Terminal (sem cursor) | `open -a "Grok Bot"`, `open -a "iPhone Mirroring"` | ambos já rodavam; nenhum ganhou janela (tela bloqueada) |
| 21:41 | Grok Bot, menu Window (System Events, sem cursor) | clique em Window › Grok Bot | sem efeito visível (tela bloqueada) |
| 21:40 | Cartão do worktree `main` no Orca | comentário "COMEÇANDO a usar o mouse" | — |
| 23:18 | Cartão do worktree `main` no Orca | comentário "TERMINEI; mouse devolvido" | — |
| — | `~/.grokbot/settings.json`, Grok Bot (telas), Espelhamento, iPhone, simuladores, pasta do iCloud | **nada** | inalterados |

## Segunda passada (MAC-0-B), 09/09 00:18–00:30 — a tela continuava trancada

O despacho dizia que o dono tinha desbloqueado o Mac. Não tinha, ou trancou de novo antes de eu chegar:

- `CGSessionCopyCurrentDictionary()` às 00:18 e às 00:29: `CGSSessionScreenIsLocked = 1`, `CGSSessionScreenLockedTime = 1788913383` (08/09 21:23:03). O macOS grava um carimbo novo a cada bloqueio; o carimbo ser o mesmo da primeira passada diz que a tela não foi destrancada em momento nenhum entre 21:23 e 00:29.
- `orca computer list-windows --app com.anysphere.sand` → `windows: []` (pid 68362); `--app com.apple.ScreenContinuity` → `windows: []` (pid 60681). Os dois apps rodam, nenhum expõe janela.
- Sem tela, nenhuma das cinco tarefas anda: a 1 precisa do Espelhamento, a 2 e a 3 do Grok Bot, a 4 do bot respondendo, a 5 fica sem o que registrar.

Conferido de novo sem mouse, tudo igual à primeira passada: pasta espelhada ausente; `.cursor/mcp.json` aponta para o `servidor.py` do checkout principal (o caminho estável que o despacho pede); `autoteste ok`; `tools/list` do main com 10 ferramentas, sem `traco_agenda`/`traco_decisoes`; `traco_buscar` devolve a mensagem honesta de pasta ausente; `settings.json` intocado. A MAC-1 está em `fc125b1` (G3 recusado), só no branch dela.

**Escalada e espera:** escalação `msg_87c00e997757` às 00:19; pergunta bloqueante (thread `msg_366d22aed625`) com duas opções, prazo de 10 min, expirou às 00:29 sem resposta. Como a ordem desta passada era parar e dizer em vez de esperar horas, a volta fecha aqui: **falha por bloqueio, nada configurado, nada desfeito**. O cursor não foi tomado; nenhum comentário de "começando a usar o mouse" foi feito porque o mouse não foi usado.

**Duas respostas que mudam a próxima retomada (vieram no despacho da MAC-0-B):**
1. O servidor cadastrado aponta para o caminho estável `/Users/vitorepf/develop/traco-ios/ferramentas/traco-mcp/servidor.py`, nunca para o worktree da MAC-1. O item 2 de "Como retomar" acima fica cancelado.
2. "bom dia" → `traco_agenda` fica **declarado em aberto** até a MAC-1 mesclar. A prova possível hoje é "o que eu já pensei sobre o Traço?" → `traco_buscar` citando ids, e só depois da pasta espelhada existir (tarefa 1); antes disso a resposta certa é a mensagem de pasta ausente.

**Para quem retomar:** confira o bloqueio primeiro, pelo carimbo `CGSSessionScreenLockedTime` — se ele mudou para depois do último destrancamento do dono, a tela trancou de novo (o Mac trava sozinho por inatividade; vale pedir ao dono que fique com a tela aberta durante a volta ou que a destranque e avise no momento).

| 09/09 00:18–00:29 | Terminal (sem cursor) | leitura de estado: `CGSessionCopyCurrentDictionary`, `orca computer list-windows`, `servidor.py --autoteste`, `tools/list` e `traco_buscar` por stdio | nada alterado no Mac |
