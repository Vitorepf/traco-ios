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

## Terceira passada (MAC-0-C), 09/09 11:31–12:12 — o Mac destrancado, a pasta espelhada nasceu, o bot existe

Worker: Fable 5.1, branch `Vitorepf/volta-mac-0`. Conferido antes de tocar em qualquer coisa: `CGSessionCopyCurrentDictionary()` às 11:31 **sem** `CGSSessionScreenIsLocked` (a tela estava aberta o tempo todo). Mouse tomado às 11:32 e devolvido às 12:12, com aviso no comentário do worktree `main` nas duas pontas. Só dois apps foram tocados: **Espelhamento do iPhone** e **Grok Bot**. Voz, VoiceOver, iPad e simulador: não tocados.

O que mudou desde a segunda passada: a **MAC-1 mesclou** (`8bdc591`). O `servidor.py` do checkout principal responde a `tools/list` com **12 ferramentas**, incluindo `traco_agenda` e `traco_decisoes`; `ferramentas/grokbot/casos/` (README + seis casos) e `CASOS.md` estão no `main`.

### Tarefa 1 — a pasta espelhada, pelo caminho do produto: FEITA

No iPhone do dono, pelo Espelhamento: Buscar › Traço › alça da borda esquerda (arquivo) › aba Perfil › rolar até DADOS › "Espelhar numa pasta (iCloud Drive…)" › seletor do sistema › Explorar › iCloud Drive › "…" › Nova Pasta › `Traço` › entrar › Abrir. O Perfil passou a mostrar **"Espelhando em “Traço”"** e o app publicou na hora (`Corpus.escreverEspelho` roda ao escolher a pasta). No Mac, 20 s depois:

```
~/Library/Mobile Documents/com~apple~CloudDocs/Traço/Traço/
  LEIA-ME.md  INDICE.md  traco-corpus.md  calendario.json  .espelho-ad98cd0f.json  notas/21666fb0-….md
```

Repare na forma: o app grava uma subpasta `Traço/` **dentro** da pasta escolhida. O `servidor.py` apontado para `…/CloudDocs/Traço` (o caminho do `.cursor/mcp.json`) **acha a pasta** — `traco_buscar` devolve `[]` para "Traço" (nenhuma nota fala do app), e `traco_agenda` devolve a mensagem honesta:

> Sem agenda.md ainda. O app a escreve na pasta espelhada quando você abre o Traço no iPhone; se a pasta é antiga, abra o app uma vez.

O `agenda.md` não existe porque o **build instalado no iPhone do dono é anterior à MAC-1** (é o código de `Corpus.swift:494` de 09/09 que o escreve). Instalar build no iPhone do dono não é desta volta; fica declarado.

Nada além desse caminho foi tocado no iPhone. O app ficou aberto no Perfil.

### Tarefa 2 — o servidor `traco` no Grok Bot: LIMITE DO APP, declarado

O Grok Bot 0.44.0 **não tem tela de cadastro de servidor MCP local**. Apurado no bundle (`app.asar`) e na interface:

- Não há "espaço de trabalho": o app é um chat de bots, sem pasta aberta. O `.cursor/mcp.json` do repositório é lido pelo agente da Cursor em workspace, **não por este app**. O commit `5808a56` não erra, mas não alcança o Grok Bot.
- A configuração de MCP vem da **conta Cursor, na nuvem** (`GetMcpConfig`/`SetMcpConfig`, `configJson` com `mcpServers`); servidores stdio dessa configuração rodam "no computador do Grok Bot" (`mcpBoxServers` do `settings.json` é só a lista dos habilitados). O único método de escrita (`addServer(name, configJson)`) não tem chamador na interface; as strings pt-BR do bundle não têm "Adicionar servidor"; não há deeplink `grokbot://…/mcp/install`.
- O Marketplace tem a categoria "MCP" (catálogo hospedado) e "Seus plugins" com 21 instalados. O único "Adicionado manualmente" do dono, **GrokBotDev**, é **HTTP** (`https://mcp.grokbot.dev/mcp`), com "Falha ao carregar o conector" — captura 06. O cadastro manual acontece fora do app (site cursor.com, configuração de MCP da conta).

Escalado ao coordenador às 12:00 (`msg_70836266ccb8`) com duas saídas: (a) autorizar o navegador só em cursor.com para cadastrar `traco` stdio com o comando do `.cursor/mcp.json`; (b) deixar declarado como limite. Sem resposta até o fecho; segui pela (b). `~/.grokbot/settings.json` **não foi alterado** (os ids 3037497, 3237977 e 3432659 seguem como estavam).

### Tarefa 3 — o bot "Traço": FEITO

Criado por "Novo chat › Criar novo Bot" e renomeado nos ajustes do bot (o app confirma "Renomeado para Traço"). Nome `Traço`, rótulo `segundo cérebro`, e na Descrição (o campo de instruções deste app) o texto de `ferramentas/grokbot/casos/README.md` + os seis casos (01, 02, 03, 08, 09, 11) do `main`, seguido do bloco **"Regras de origem"** de `CASOS.md` — 10 093 bytes. As regras de origem foram para a descrição do bot porque **não há servidor cadastrado** e portanto não há id para `mcpCustomInstructionsByServerId`; o texto diz isso.

### Tarefa 4 — a prova, de uso: duas respostas honestas, sem chamada MCP

- **"bom dia"** (12:05) → "Bom dia. Vou ver o que você tem hoje." e depois **"Ainda não tenho o conector do Traço ligado aqui — sem ele não leio sua agenda."** (captura 08). Não chamou `traco_agenda`: não existe servidor cadastrado. É a mensagem honesta que a tarefa pede como prova mínima, vinda do bot.
- **"o que eu já pensei sobre o Traço?"** (12:07) → o bot, com execução local liberada no Mac (`localToolPermission: always`), disse "Achei o servidor no Mac. Conferindo a pasta espelhada e a agenda." e respondeu (12:09): **"Nas suas notas do Traço, não achei nada sobre o Traço. Busquei por “Traço”, “traco” e variações — zero hit. Tem uma nota só no corpus (`21666fb0-9ec5-49a6-af4e-3087497ef2b6`, 1 set 2026): “Gostaria de começar a ler”. Não fala do app. Isto é meu, não achei nota: o que sei do produto está fora do vault (código/docs no Mac), não é pensamento seu gravado aqui."** (captura 09). **Cita o id** e marca a opinião como do bot — as regras de origem valeram. Mas leu a pasta pela execução local, **não por `traco_buscar`**: a transcrição não mostra cartão de ferramenta MCP, e não há servidor. Não vendo isso como chamada MCP.

Dois defeitos do instrumento nesta prova: `orca computer type-text` **dobrou o texto** ("bom dia" saiu "bom diabom dia", "traco" saiu "tracotraco") e o campo do compositor colou o placeholder junto ("…Mensagem para Traço"); e `paste-text` anexou à segunda mensagem **uma imagem pequena que estava na área de transferência** (um fragmento de interface, capturas 09). Registrado; não desconta nota do app.

### Scorecard (preenchido pelo worker; a nota é do revisor)

| dimensão | nota | evidência |
|---|---|---|
| 1. Pasta espelhada criada pelo caminho do produto | 9 | capturas 01–04; pasta no Mac com `notas/`, `INDICE.md`, `traco-corpus.md`; `traco_buscar` responde contra ela |
| 2. Servidor `traco` visível no Grok Bot com ferramentas | não executável neste app | não há cadastro de servidor local no Grok Bot 0.44; configuração é da conta Cursor (nuvem); escalado, sem resposta |
| 3. Bot "Traço" com README + seis casos + regras de origem | 9 | captura 07; texto de 10 093 bytes gravado na Descrição; "Renomeado para Traço" |
| 4. Prova de uso | parcial, honesta | "bom dia" → mensagem honesta de conector ausente (08); "o que eu já pensei" → cita id, marca opinião do bot (09), mas por execução local, não por MCP |
| 5. Mouse devolvido e tudo o que tocou registrado | feito | comentários no worktree `main` às 11:32 e 12:12; tabela abaixo |

### Capturas

`ferramentas/orca/mac-0-c-01…09.png`: 01 Traço aberto no iPhone; 02 Perfil › Dados; 03 pasta `Traço` criada no iCloud Drive; 04 "Espelhando em Traço"; 05 Grok Bot › Seus plugins (21 instalados, sem `traco`); 06 GrokBotDev, "Adicionado manualmente", HTTP; 07 bot Traço criado com instruções; 08 resposta a "bom dia"; 09 resposta a "o que eu já pensei".

### Lições de instrumento (para a ESTEIRA)

- No Espelhamento do iPhone, **`orca computer scroll`, `drag` e arrasto por CGEvent não rolam** (semântica de ponteiro, como iPad com trackpad); rola só a **roda em linhas** (`CGEvent(scrollWheelEvent2Source:units:.line)`, ~36 linhas ≈ 28 pt; 1 200 linhas para descer o Perfil). Cliques e teclado funcionam.
- O seletor de pastas do iOS ignora "Abrir" e "<" **dentro da pasta recém-criada**; sair para a lista, entrar de novo pela busca e aí "Abrir" funciona.
- Um aviso do macOS sobre a janela espelhada engole toques na barra de cima; mover a janela (`System Events … set position`) resolve sem mouse.
- `type-text` dobra caracteres no Grok Bot e no Espelhamento; `set-value` grava campos do Grok Bot de verdade (o nome persistiu); `paste-text` leva junto o que estiver na área de transferência.

### Tudo o que tocou no Mac do dono (terceira passada)

| quando | onde | o quê | antes → depois |
|---|---|---|---|
| 11:32 | cartão do worktree `main` no Orca | comentário "COMEÇANDO a usar o mouse" | — |
| 11:32 | Terminal, sem cursor | `open -a "iPhone Mirroring"`, `open -a "Grok Bot"` | Espelhamento não rodava → rodando; Grok Bot já rodava |
| 11:32–11:44 | Espelhamento do iPhone (janela) | cliques, roda, teclado no iPhone do dono: Buscar › Traço › Perfil › Dados › Espelhar › iCloud Drive › Nova Pasta "Traço" › Abrir | pasta `iCloud Drive/Traço` não existia → criada; Traço "Espelhando em Traço"; app deixado aberto no Perfil |
| 11:42 | janela do Espelhamento | movida de x=616 para x=200 (fugir do aviso) e **devolvida a 616,66** às 12:10 | igual ao início |
| 11:45–12:11 | Grok Bot (janela) | menu da conta › Configurações (Geral, Computador) só lidos; Marketplace › Seus plugins › pstack, GrokBotDev só lidos; "Novo chat › Criar novo Bot"; ajustes do bot novo: Nome, Rótulo, Descrição gravados; duas mensagens enviadas ao bot "Traço"; campo de busca do Marketplace deixado vazio | um bot novo "Traço" (com uma conversa de 2 perguntas); nenhum outro bot, plugin ou ajuste alterado |
| 12:12 | cartão do worktree `main` no Orca | comentário "TERMINEI; mouse devolvido" | — |
| — | `~/.grokbot/settings.json`, `~/.cursor/mcp.json`, plugins instalados, outros bots, simuladores, iCloud fora de `Traço/` | **nada** | inalterados |

**Para o revisor:** o bot "Traço" está de pé no Grok Bot; repita "bom dia" nele. Sem o servidor cadastrado na conta Cursor, a resposta certa continua sendo a de conector ausente. *(Corrigido na quarta passada, abaixo: um cadastro stdio na conta não entra no Grok Bot — o app recusa qualquer servidor com `command`.)*

## Quarta passada (MAC-0-D), 09/09 12:20–12:55 — sem mouse: o stdio não chega ao Grok Bot, e isso é do produto

Decisão do coordenador sobre a escalação da MAC-0-C: (b), declarar o limite. Nesta passada **nada foi tocado no Mac** — sem mouse, sem navegador, sem cursor.com; só leitura do bundle do app, dos docs públicos da Cursor e do servidor por stdio. Branch atualizado com o `main` (`0f4a014`, mesclagem limpa).

### O achado que muda o pedido: não é "trinta segundos do dono"

O despacho pedia o trecho stdio para o dono colar na configuração MCP da conta. **Esse trecho não funcionaria em tela nenhuma do Grok Bot**, e a prova está em três lugares:

1. **Código do app (0.44.0, `app.asar`).** No fluxo que liga um servidor da conta: `if ("command" in config) → { status: "not-supported", reason: "stdio_unsupported" }`. Toda entrada com `command` é recusada antes de qualquer tentativa. A mensagem pt-BR do bundle para esse estado: *"<nome> é executado no computador do Grok Bot e não usa login pelo navegador. Configure as credenciais dele nas configurações de ambiente."* — "computador do Grok Bot" é a máquina do bot na nuvem, não o Mac do dono; lá não existe `/Users/vitorepf/…` nem o iCloud Drive.
2. **A Cursor, por escrito.** Kevin Neilson (staff), fórum da Cursor, 13/08/2026: *"Grok Bot does not attach MCP servers that run on your own machine, whether that's stdio or something listening on localhost."* O que vale: *"remote HTTP/SSE MCP and catalog connectors where they exist, and the Bot's cloud browser everywhere else"* (`forum.cursor.com/t/does-grok-bot-support-local-mcp-e-g-workflowy/168182`).
3. **Docs (`cursor.com/docs/context/mcp`).** stdio é transporte local do Cursor IDE (`.cursor/mcp.json` do projeto, `~/.cursor/mcp.json` global); servidores de equipe ficam em *Dashboard › Integrations & MCP* e são remotos.

O que a MAC-0-C viu bate com isso: o único "Adicionado manualmente" do dono (GrokBotDev) é HTTP. O `.cursor/mcp.json` do repositório (`5808a56`) segue certo **para o Cursor IDE e para agentes em nuvem que abrem o repositório**, e irrelevante para o Grok Bot.

### O que fica pronto, e para quem

**Para o dono, hoje: nada a colar que ligue o servidor ao Grok Bot.** Não há tela, nem no app nem na conta, onde um servidor local entre. Pedir a ele que cole o stdio seria mandá-lo fazer algo que o app recusa.

**O trecho, no lugar onde ele funciona hoje (Cursor IDE, não o Grok Bot).** Já está em `.cursor/mcp.json` do repositório; para valer em qualquer projeto, o mesmo bloco em `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "traco": {
      "command": "python3",
      "args": [
        "/Users/vitorepf/develop/traco-ios/ferramentas/traco-mcp/servidor.py",
        "/Users/vitorepf/Library/Mobile Documents/com~apple~CloudDocs/Traço"
      ]
    }
  }
}
```

Onde, segundo o próprio bundle do Grok Bot: *"Open Cursor's Customize page > MCPs"* (a tela de MCP do Cursor IDE). Não vi essa tela nesta volta; o caminho é o do texto do app.

**O que ele vê quando funciona**, em qualquer cliente que ligue o servidor — resposta real de `tools/list` do servidor do `main`, colhida às 12:25 contra a pasta espelhada:

`traco_contrato, traco_indice, traco_notas, traco_nota, traco_buscar, traco_sentidos, traco_corpus, traco_semana, traco_agenda, traco_decisoes, traco_escrever, traco_metodo_escrever` — 12 ferramentas. Se `traco_agenda` e `traco_decisoes` não aparecem, o cliente pegou um `servidor.py` anterior à MAC-1.

**O caminho que chega ao Grok Bot é volta de código, não clique:** o servidor precisa de transporte HTTP e de uma URL pública (o bot fala da nuvem); aí entra como conector manual, como o GrokBotDev, com `{"mcpServers":{"traco":{"url":"https://<url pública>/mcp"}}}` — a URL só existe quando a volta existir, por isso o placeholder. Dívida nomeada no RUMO como **MAC-0-E**, com a alternativa mais barata logo abaixo.

### O que a prova do "bom dia" mostra de fato

- **Captura 08 (`mac-0-c-08`)**: "bom dia" → *"Bom dia. Vou ver o que você tem hoje."* e *"Ainda não tenho o conector do Traço ligado aqui — sem ele não leio sua agenda."* Não há cartão de ferramenta, não houve chamada a `traco_agenda`, e o texto é o que as instruções coladas na Descrição mandam dizer quando não há conector. **É o bot falando sozinho, honesto. Não é o caso 11 funcionando.** O caso 11 segue não provado, e não pode ser provado pelo bot até a MAC-0-E; além disso o `agenda.md` só nasce com o build da MAC-1 instalado no iPhone do dono (não instalado).
- **Captura 09 (`mac-0-c-09`)**: "o que eu já pensei sobre o Traço?" → *"Achei o servidor no Mac. Conferindo a pasta espelhada e a agenda."* e a resposta que cita o id `21666fb0-…` e marca a opinião como do bot. Aqui o bot **rodou comandos no Mac do dono** pela permissão "Executar um comando no seu computador local" (`localToolPermission: always`, já estava assim) e leu a pasta espelhada. É o caso 1 respondendo na **forma certa (cita id, marca opinião)** por uma **rota que não é o MCP**, contra um corpus de uma nota. **Indício, não prova**: nada garante que ele use `traco_buscar` nem que respeite `traco_contrato`.

Essa rota local alcança o Mac — o que a nuvem do bot não alcança por MCP, o "computador local" alcança por comando. Fica no RUMO como alternativa à MAC-0-E: um modo de linha de comando em `servidor.py` (`--chamar traco_agenda`) e uma linha nas instruções do bot. É código, e é de outra volta.

### Scorecard (preenchido pelo worker; a nota é do revisor)

| dimensão | nota | evidência |
|---|---|---|
| 1. Pasta espelhada criada pelo caminho do produto | 9 | MAC-0-C, capturas 01–04; pasta com `notas/`, `INDICE.md`, corpus; `tools/list` e `traco_agenda` respondem contra ela |
| 2. Servidor `traco` visível no Grok Bot | não executável no produto | `stdio_unsupported` no código; Cursor (13/08/2026); nenhum servidor local entra no Grok Bot |
| 3. Bot "Traço" com README + seis casos + regras de origem | 9 | MAC-0-C, captura 07 |
| 4. Prova de uso | parcial, honesta | 08: bot sozinho, sem MCP; 09: caso 1 por execução local, indício |
| 5. Mouse devolvido e tudo registrado | feito | nesta passada o mouse não foi tomado; fecho no comentário do worktree `main` |

### Tudo o que tocou no Mac do dono (quarta passada)

| quando | onde | o quê |
|---|---|---|
| 12:20–12:55 | Terminal, sem cursor | leitura: `app.asar` (grep), `servidor.py` por stdio (`tools/list`), `ls` da pasta espelhada, docs públicos da Cursor por WebFetch |
| — | Grok Bot, Espelhamento, iPhone, `~/.grokbot/`, `~/.cursor/mcp.json`, cursor.com, simuladores | **nada** |

## Quinta passada (MAC-0-E), 09/09 13:44–14:05 — o servidor chega ao bot por comando local, e é provado no Mac

Worker: Fable 5.1, branch `Vitorepf/volta-mac-0` sobre `d98f508`. **Autorização do dono às 12h15
("pode configurar o Grok Bot")**, que suspendeu só nesta tarefa a exceção de dados do dono: sessão já
logada, Mac destrancado (`CGSSessionScreenIsLocked` ausente às 13:45), nenhuma senha digitada, nada
comprado, nenhum outro servidor. Aviso no comentário do worktree `main` às 13:45 e às 14:04. Voz,
VoiceOver, iPad e simuladores: não tocados. Aparelhos: nenhum (o `B91C8DEF` ficou com a Q2-E).

### 1. A configuração de MCP da conta, vista com os próprios olhos: não há onde cadastrar

- **`cursor.com/dashboard/integrations`** (captura `mac-0-e-01`): Source Control (GitHub) e
  Integrations (Slack, Teams, Linear, Jira, Sentry). **Nenhuma seção de MCP** — a conta é Free
  (vitordsny@gmail.com), e o "Integrations & MCP" dos docs é de equipe.
- **`cursor.com/dashboard/settings`** (captura `mac-0-e-02`, rolada até o fim): Privacy, Profile,
  Appearance, Pull Requests, Active Sessions, Log Out/Delete. **Nada de MCP.**
- **No app 0.44** (`app.asar`, por Python sobre o `strings`): `addServer(name, configJson)` existe e
  grava na conta por `SetMcpConfig`, mas **não tem chamador em tela nenhuma**; "Adicionado
  manualmente" (`hO1TWp`) é só o rótulo de qualquer servidor da conta que não seja de equipe. Há
  um caminho de leitura de servidores stdio da conta (`fetchStdioRuntimeConfig`) — eles rodam "no
  computador do Grok Bot", a máquina na nuvem (portas 1337/6080, noVNC, `egressTunnel`), onde não
  existe `/Users/vitorepf`. A recusa `stdio_unsupported` da MAC-0-D é do fluxo de login desses
  servidores. Conclusão igual à da MAC-0-D, agora vista: **não há tela, no site nem no app, onde
  um servidor da máquina do dono entre.** Não abri o Cursor IDE (3.19.7, instalado, fechado): o
  `~/.cursor/mcp.json` dele só tem `atlas-open-brain`, e o IDE não é o Grok Bot.

Sem forçar: fui à **rota 1 do RUMO** (`--chamar`), a mais curta.

### 2. O que mudou no código (diff de 3 arquivos + relato)

- **`ferramentas/traco-mcp/servidor.py`**: `servidor.py [pasta] --chamar <ferramenta> ['{json}']`
  imprime o que `tools/call` devolveria; sem ferramenta, a lista de uso. `pasta_padrao()` ignora
  argumento que começa com `--`. E um **bug que esvaziava tudo**: o app grava numa subpasta
  `Traço/` DENTRO da pasta escolhida (`PastaEspelho.swift:96`), e o `.cursor/mcp.json` aponta para
  a escolhida — `Pasta.existe()` dava verdadeiro e `traco_buscar` devolvia `[]` porque `notas/`
  estava um nível abaixo. Agora `Pasta` desce para `Traço/` quando `notas/` só existe lá. Duas
  linhas no autoteste cobrem as duas coisas (`autoteste ok`). Medida antes/depois pelo caminho do
  `mcp.json`: `traco_buscar '{"termo":"ler"}'` → `[]` antes, a nota `21666fb0-…` depois;
  `traco_corpus` → "Sem traco-corpus.md ainda" antes, o corpus depois.
- **`ferramentas/grokbot/casos/README.md`**: seção "Como você chama as ferramentas no Grok Bot"
  — a linha do comando, três exemplos, e a proibição de ler a pasta por `ls`/`cat`/`grep`.
- **`ferramentas/grokbot/CASOS.md`** (topo) e **`ferramentas/orca/RUMO.md`** (MAC-0-E paga; resto
  com dono). Sem ADR: a decisão é a rota 1 já escrita na ADR 09m; a letra 09p não foi usada.

### 3. Tela a tela no Grok Bot

1. Botão direito no bot "Traço" da barra lateral › **Editar perfil** abre o painel Configurações
   (captura `mac-0-e-03`: Nome "Traço", Rótulo "segundo cérebro", Descrição).
2. **Descrição regravada** com README (já com a seção nova) + casos 01, 02, 03, 08, 09, 11 + bloco
   "Regras de origem" (10 678 bytes). `set-value` do helper **não persiste** neste campo (o painel
   reabriu com o texto antigo); o que persistiu foi clicar no campo, `cmd+a`, `paste-text`
   (área de transferência), e sair do campo. Reaberto: começa em "# As instruções…", contém a
   seção nova uma vez só, e termina em "…vem marcada" (captura `mac-0-e-04`, campo rolado ao fim).
   **O caminho na Descrição é o deste worktree** (`orca/workspaces/traco-ios/volta-mac-0/…`), porque
   o `--chamar` só existe aqui até mesclar; o README do repositório traz o caminho estável. Trocar
   na mesclagem é do orquestrador (RUMO).
3. Três mensagens ao bot Traço pelo campo de prompt (`paste-text` + Return; o `type-text` dobra
   texto). O AX do campo cola o placeholder "Mensagem para Traço" ao valor e o balão enviado mostra
   isso ("bom diaMensagem para Traço"): defeito do instrumento/app, igual ao da MAC-0-C.

### 4. A prova, de uso — do servidor ou do bot sozinho?

O Grok Bot **não mostra cartão de comando** na transcrição. A régua foi um **vigia de processos no
Mac** (`ps -axo pid,ppid,command` a cada 50 ms), guardado em `ferramentas/orca/mac-0-e-vigia.txt`:
todo `servidor.py --chamar` que rodou, com hora, e o pai **68403 = `local-exec-daemon` do Grok
Bot**. Isso é o bot executando o servidor; não é inferência pelo texto.

| hora | pergunta | comandos vistos no Mac (pai 68403) | resposta do bot | veredito |
|---|---|---|---|---|
| 13:56:35 | "bom dia" (sem vigia) | — | "Sem agenda ainda. O app escreve esse arquivo quando você abre o Traço no iPhone…" | **indício**: texto igual ao do servidor, mas sem vigia não conto |
| 13:57:59 | "bom dia" | 13:58:05 `--chamar traco_agenda '{"dias": 2}'` | 13:58:08 "Ainda sem `agenda.md`. Abre o Traço no iPhone com o espelho ligado — o app escreve o arquivo sozinho." (captura `mac-0-e-05`) | **DO SERVIDOR.** Caso 11 provado até onde o corpus permite: `agenda.md` só nasce com build posterior à MAC-1 no iPhone do dono — não instalado, por ordem |
| 13:58:53 | "o que eu já pensei sobre o Traço?" (antes da correção da subpasta) | 13:58:57 `traco_buscar` "Traço"; 13:59:02 `traco_buscar` "traco", "app", "escrever", "bloco de notas"; 13:59:06 `traco_corpus` | 13:59:09 "Não achei nota sua sobre o Traço… O corpus ainda não está na pasta espelhada. Isto é meu, não achei nota…" (captura `mac-0-e-06`) | **DO SERVIDOR**, fiel ao que o servidor devolveu (`[]` e "Sem traco-corpus.md") — que estava errado pelo bug da subpasta, corrigido em seguida |
| 14:02:24 | idem, depois da correção — **enviada junto com um rascunho do dono** (§5) | 14:02:35 `traco_buscar` "Traço", "simulador", "Grok Bot", "espelho", "iPhone"; `traco_contrato` | 14:02:39 "Sobre o que você já pensou no Traço: ainda zero. Busquei … — nada. Sem id, não invento." + explicação marcada "Isto é meu" (captura `mac-0-e-07`) | **DO SERVIDOR.** Caso 1 na forma certa: só cita id quando há nota; a única nota (`21666fb0`, "Gostaria de começar a ler") não fala do Traço, então não há id a citar. **A citação de id fica por provar** num corpus com nota sobre o assunto |

Comparação com a MAC-0-C: às 12:09 o bot leu a pasta com `ls`/`cat` por conta própria e citou o id
"por fora"; agora a Descrição proíbe isso e o vigia não viu nenhum comando fora do `servidor.py`.

### 5. Incidente: um rascunho do dono foi enviado ao bot por mim (14:02:24)

Às 13:59 a janela do Grok Bot sumiu (0 janelas; o processo vivo; tela não bloqueada; o dono ativo
no Mac, ocioso 0–1 s, com Claude/Chrome na frente). Às 14:00:08 fiz `open -a "Grok Bot"` para ler
a resposta — **isso levantou a janela por cima do que o dono fazia**, e um "appl" apareceu no campo
do bot. Esperei o dono ficar 45 s sem tocar no Mac (14:02:20) e o script clicou no campo, mandou
`cmd+a` (o helper respondeu "provider unavailable": **não selecionou nada**), colou a pergunta e
deu Return. O campo tinha um rascunho do dono — *"Tá, o que eu não entendia é como é que vai
funcionar o Grok Bot, sabendo que, no meu iPhone, é de uma forma, e no simulado, tem outras notas.
Como é que vai funcionar isso?"* — e ele **foi enviado ao bot Traço junto com a minha pergunta**
(captura `mac-0-e-07`). O bot respondeu ao dono. Nada saiu da conta dele; o destinatário foi o
próprio bot. Escalado ao coordenador na hora (`msg_8d3218277ff2`); não apaguei nem editei nada da
conversa; não toquei mais no Grok Bot. **Lição para a ESTEIRA:** com o dono ativo no Mac (idle < 60
s) não se levanta janela nem se escreve em campo de texto; e `hotkey` do helper não é confiável —
conferir o valor do campo por AX antes de dar Return.

### Scorecard (preenchido pelo worker; a nota é do revisor)

| dimensão | nota | evidência |
|---|---|---|
| 1. Pasta espelhada criada pelo caminho do produto | 9 | continua lá (`…/CloudDocs/Traço/Traço/`: `notas/` com 1 nota, `INDICE.md`, `traco-corpus.md`, `LEIA-ME.md`); não refeita |
| 2. Servidor `traco` chega ao Grok Bot | 8 | pela rota 1 (`--chamar` + execução local), com o comando visto no Mac (`mac-0-e-vigia.txt`); não é MCP (o app não liga), e a Descrição aponta para o worktree até mesclar |
| 3. Bot "Traço" com README + seis casos + regras de origem | 9 | Descrição regravada e persistida com a seção nova (`mac-0-e-03`, `mac-0-e-04`) |
| 4. Prova de uso | 8 | "bom dia" → `traco_agenda` DO SERVIDOR; "o que eu já pensei" → `traco_buscar` DO SERVIDOR com "sem id, não invento"; citação de id por provar (corpus sem nota sobre o assunto); `agenda.md` depende de build no iPhone do dono |
| 5. Mouse devolvido e tudo registrado | 6 | devolvido às 14:04 com aviso; **mas** um rascunho do dono foi enviado ao bot (§5) |

### Capturas

`ferramentas/orca/mac-0-e-01…07`: 01 dashboard Integrations (sem MCP); 02 dashboard Settings (sem
MCP); 03 Configurações do bot Traço; 04 Descrição gravada, rolada ao fim; 05 "bom dia" respondido
pelo servidor; 06 "o que eu já pensei" antes da correção; 07 depois da correção, com o rascunho do
dono no balão. Registro do vigia: `mac-0-e-vigia.txt`.

### Tudo o que tocou no Mac do dono (quinta passada)

| quando | onde | o quê | antes → depois |
|---|---|---|---|
| 13:45 / 14:04 | cartão do worktree `main` | comentários "COMEÇANDO" e "TERMINEI" | — |
| 13:46–13:50 | Chrome (aba nova, sessão logada) | `cursor.com/dashboard/integrations` e `/settings`, só leitura; aba fechada ao fim | nada alterado na conta |
| 13:51–13:56 | Grok Bot › bot Traço › Editar perfil | Descrição regravada (10 678 bytes); Nome e Rótulo intocados | Descrição sem a seção → com a seção "Como você chama as ferramentas" |
| 13:56–14:02 | Grok Bot › bot Traço › chat | 3 mensagens: "bom dia" ×2, "o que eu já pensei sobre o Traço?" ×2 (a última com o rascunho do dono) | 4 pares a mais na conversa |
| 14:00:08 | Terminal | `open -a "Grok Bot"` (a janela tinha sumido) | janela de volta, por cima do que o dono fazia |
| — | `~/.grokbot/settings.json`, `~/.cursor/mcp.json`, plugins, outros bots, iPhone, Espelhamento, simuladores, iCloud | **nada** | inalterados |
