# Orca no Traço — como usar, o que deu errado, e como montar de novo

Data: 08/09/2026. Fontes: os dois transcritos do orquestrador (Fable 5.1, 05/09 13:18 → 06/09 12:35, sessão `3d1d55dd`; Opus 5, 06/09 12:41 → 07/09 01:56, sessão `ea792f6c`), o LACO, a ESTEIRA, os briefs em `papeis/`, e a referência do próprio binário (`orca skills get orchestration` e `orca-cli`). Números e horas vêm dos transcritos; horas em UTC-3.

## 1. O Orca em três objetos

- **Worktree**: um checkout do repo que o Orca acompanha, com id `<repoId>::<caminho>`, comentário, status de quadro e terminais. Hoje só existe o principal: `main` em `/Users/vitorepf/develop/traco-ios`.
- **Terminal**: uma aba com um agente TUI (`claude`, `codex`, `grok`) ou um shell. Tem `handle` (`term_…`); lê-se (`terminal read`), escreve-se (`terminal send`) e espera-se (`terminal wait --for tui-idle`).
- **Run → Task → Dispatch**: o Run é só namespace e caixa de entrada do coordenador; a Task é o trabalho; o Dispatch é UMA tentativa da Task num terminal. O worker responde com `worker_done` (uma vez, `--outcome succeeded|failed`), pergunta com `ask`, e o coordenador espera com `check --wait`.

## 2. O laço supervisionado, como o Orca manda

```bash
orca status --json
orca orchestration run-create --objective "<objetivo>" --json           # ou run-use --id <run> para retomar
orca orchestration task-create --spec "$(cat spec.md)" --task-title "<curto>" --display-name "Opus 5 · implementador V20" --json
orca orchestration worker-start --task <task> --worktree new-child --name volta-20-<tema> --base-branch main \
  --agent claude --model opus --effort high --display-name "Opus 5 · implementador V20" --setup run --json
# demais workers da MESMA volta: --worktree path:/Users/vitorepf/orca/workspaces/traco-ios/volta-20-<tema>
# mesmo juiz de novo (re-G3/re-G4): --worktree path:<...> --terminal <handle do juiz>
orca orchestration check --ack <delivery> --wait --types worker_done,escalation,question --timeout-ms 540000 --json 2>/dev/null
orca orchestration reply --id <msg> --body "<resposta>" --json
orca orchestration worker-release --dispatch <dispatch> --json          # depois de CADA worker_done não reaproveitado
orca worktree set --worktree active --comment "<estado curto>" --json
orca worktree rm --worktree path:<...> --json                           # já apaga o branch
```

O que o guia diz e a equipe confirmou na prática:
- `check --wait` que volta vazio é checkpoint, não falha; tarefa de código leva 15 a 60 min. Heartbeat e atividade no terminal são "vivo", não "pronto".
- `check --wait --json` imprime keepalive no stderr a cada 15 s: `2>/dev/null` e decodificar só o stdout (a equipe usou `raw_decode` em laço e guardou o `deliveryId` num arquivo para o `--ack` seguinte). Timeout acima de 600 s é movido para background pelo Claude Code e o waiter fica preso (`waiter_exists`): usar 540000 ms.
- Um waiter por Run. Retry só do dispatch MAIS RECENTE (`--retry-of <ctx>`), e ele não herda colocação: repetir `--worktree` e `--agent`.
- Worker não despacha sub-worker (profundidade 1). Falha de `worker-start` sai com `error.code` (`task_not_startable`, `inject_rejected`, `selector_not_found`, `terminal_worktree_mismatch`, `runtime_error`): ler `nextSteps`, não repetir igual.
- `run-use --id <run>` retoma um Run de outro terminal; `--takeover-legacy` só funciona no terminal coordenador vivo.
- Seletor de worktree que funciona é `path:/…`; `name:` deu `selector_not_found` nas duas sessões.
- `terminal send` a um agente parado em prompt (update do Codex, "Hooks need review", pedido de permissão do Claude) devolve `agent_prompt_blocked`/`agent_prompt_stalled`: resolver no terminal à mão e depois reatar.
- `terminal rename` aceita só `--title`; `--display-name` é do `worker-start`/`task-create`.
- `send --to dispatch:<id>` pode chegar ao worker só com o assunto se o `check` dele consumir o corpo antes de ler: conteúdo que o worker precisa vai no spec ou em arquivo no worktree.
- `worktree rm` já apaga o branch; o `git branch -d` seguinte sempre deu "not found".
- No zsh, `echo ====` quebra (`=cmd`); dezenas de "erros" nas duas sessões eram isso.

## 3. Quem faz o quê (papéis em `papeis/`)

| papel | agente | quando | brief |
|---|---|---|---|
| orquestrador | `claude --model opus` (Fable quando a semanal permite) | um só; sobe por `equipe.sh` | orquestrador.md |
| implementador | `--agent claude --model opus --effort high` | Modelo, Trabalho, Análise, Corpus, SwiftData, concorrência | implementador.md |
| front-end | Fable (`--model fable`) ou Opus | SwiftUI, Tema, Componentes, movimento; fases do design-router | frontend.md |
| fora do app | Fable/Opus, permanente | widgets, Ilha, intents, Siri, controles | fora-do-app.md |
| revisor (G3) e juiz de design (G4) | Fable/Opus em sessão própria, no mesmo worktree | build, `xcodebuild test` em UDID próprio, maestro, diff; SÓ reporta | revisor.md |
| pesquisador de métodos | Opus, permanente | só `ferramentas/orca/metodos/`, nunca Swift | pesquisador-metodos.md |
| consultor | `--agent codex` (GPT-6-Astra) | ESCASSO: arquitetura e contrato difícil; uma consulta por volta; acima de 85% da cota nenhuma | consultor-astra.md |
| reserva | `--agent grok` | fora do time de código | — |

Custo crescente: Grok < Opus < Fable < Astra. Qualidade em código medida por eles: Fable ≥ Astra ≈ Opus ≫ Grok.

## 4. As duas sessões, em uma tabela

| | Fable, 05/09 13:18 → 06/09 05:40 | Opus, 06/09 12:41 → 22:56 |
|---|---|---|
| Voltas mescladas | V1 a V10, F1, F2, F3, V9 (13) | V16, F3b, A1-A4, V11, A5, V18, M1-M15 (7 + trilha) |
| Voltas abertas ao fim | V12, V16, F3b | V12, F4, M3, L1, V19, A6 |
| `worker-start` | dezenas, `--worktree current` nas voltas 1-3 | 87 em 10h25 (um a cada 7 min), 33 encadeados no mesmo terminal |
| `check --wait` | 78 | 124 (por `espera.sh`, 9 min cada) |
| Consultas Astra | 3 (Codex 62% → 66%) | 0 (71% sem uso, apesar de 3-4 recusas em V11, V18 e F4) |
| Claude semanal | 8% → 54% | 55% → 72% (virou às 20:00) → 4% |
| Fim | "You've reached your Fable limit" às 05:40, com 3 workers vivos | ordem do dono às 22:56; parada limpa |
| Custo da sessão do orquestrador | não registrado | US$ 107, 373 k tokens de saída, 179 M de cache lido |

Passadas por volta no dia 06: V11 e V18 com oito cada (G3, B, re-G3, C, re-G3, G4, D, re-G4); F4, a de "prioridade máxima", nove e não mesclou; as mescladas levaram de 2h11 (A5) a 8h09 (V18).

## 5. O que deu errado com modelos e papéis, em ordem

1. **Codex não subiu** (05/09 13:20): `~/.codex/config.toml` com `ultra` (o válido é `xhigh`), binário 0.133 pedindo update, depois "Hooks need review". O Orca bloqueia o `terminal send` nesses prompts; o dono atualizou, o orquestrador aceitou no terminal e anexou o terminal ocioso com `worker-start --terminal`.
2. **Grok (front) bloqueado pelo pbxproj velho** (13:25): `xcodegen generate` antes do primeiro build. Às 14:26 o Grok saiu do time de código: "inventa resposta 1 vez em 3 quando não sabe".
3. **Codex aposentado como implementador** (14:15): 62% da cota semanal no primeiro dia. Virou consultor escasso.
4. **Dois workers no mesmo checkout** (14:06, `--worktree current`): o WIP de um quebrou o build do outro. Nasceu a regra do worktree por volta (15:10) e o `com-trava.sh`.
5. **Simulador alheio desligado** (14:18): o worker da V2 derrubou o simulador de teste da V1 e matou duas rodadas da suíte. Regra: ninguém desliga o que não ligou; UDID de cada worker vai no spec.
6. **Worktree nascido em base velha** (15:33): faltou `--base-branch main`.
7. **Colisões no iPhone do dono** (18:31, 20:43): dois workers dirigindo o mesmo simulador; app reinstalado do zero, widgets fora da casa. Regra: simulador do dono só sob `com-trava.sh`, e só para jornada real.
8. **Janela de sessão estourou com voltas abertas** (21:50, "resets 10:50pm"): cinco horas paradas. A regra dos 85% veio tarde.
9. **Dois Fables no mesmo worktree (V10 A/B)**: corpo de mensagem perdido, commit pendente bloqueando o outro.
10. **Worker decidiu fora do escopo** (F2 trocou `PRODUCT_NAME`) e abriu gate ao dono; e o **medidor `fableWeekly` ficou parado em 15% a noite inteira** enquanto o limite real estourava às 05:40. O "modo Fable máximo" foi decidido sobre um número morto. O vigia acordou o orquestrador 14 vezes contra um limite que nenhum "continue" resolve.
11. **Retomada em Opus** (06/09 12:41): `/model opus` nos terminais vivos preservou o contexto dos dois workers derrubados; deu certo.
12. **Orquestrador parado 36 min num `AskUserQuestion`** (13:37): o dono é assíncrono. Virou a DIRETRIZ §6: decide-se pelo teste da reversibilidade.
13. **Astra nunca chamado** no dia 06, apesar da regra "duas recusas abrem consulta".
14. **Maestro não isola** (17:05): com mais de um simulador ligado, o driver do vizinho responde pela porta 7001. Lei na ESTEIRA.
15. **macOS derrubou o simulador do dono** por pressão de memória com seis simuladores ligados (16:19, pageouts ~1 M).
16. **Trava do instrumento órfã, duas vezes** (19:21, 20:06): seis workers parados 50 min. `com-trava.sh` passou a expirar em 30 min e liberar quando o dono morre.
17. **Galeria de widgets trava** (três revisões perdidas): plantar pelo `IconState.plist`.
18. **`SPEC.md` conflitou em 5 de 5 merges** (cada volta anexa a ADR no mesmo ponto); o orquestrador "que não implementa" resolveu merges, patchou o `com-trava.sh` duas vezes, matou processos e rodou `xcodebuild` 19 vezes.
19. **Auditoria V9 desatualizada** só descoberta às 22:14, depois de um dia despachando por ela.

## 6. O que fazer diferente ao montar de novo

- **Cota**: ler os três campos de `orca account list --json` a cada espera E cruzar com o texto de limite do próprio Claude; ao primeiro "limit", trocar modelo ou pausar. Abaixar paralelismo aos 70% da sessão e não abrir volta a menos de 2 h do reset.
- **Vigia**: se for religar o `app.traco.vigia`, ele tem de reconhecer "Fable limit" e "session limit" e agir (trocar modelo ou calar), e o `tui-idle` de 60 s dá falso positivo contra esperas de 9 min. Sem isso, melhor desligado; a continuidade real veio do stop-hook do Orca ("You have 1 orchestration message").
- **Astra**: usar. Duas recusas na mesma volta abrem consulta; V11, V18 e F4 teriam custado menos passadas.
- **Spec por arquivo** (o que funcionou): brief do papel + `comum.md` + linha G0 + arquivos vedados + UDID próprio + número de ADR atribuído pelo orquestrador + formato do fecho.
- **Re-G3 e re-G4 no mesmo terminal do juiz** (`--terminal`), com "você é o mesmo revisor que recusou".
- **Segurar a volta que cria o dano até a que o fecha estar em main** (M3 esperou a guarda da A5).
- **Conferir a auditoria na tela viva antes da primeira linha**; auditoria com mais de um dia é hipótese.
- **Evidência leve no worker**: PNG ≤ 400 KB (`sips -Z 1000`), vídeo ≤ 3 MB. Dois worktrees chegaram com 85 a 126 MB.
- **Menos frentes, mais fecho**: sete frentes em paralelo produziram seis voltas a um passo do merge que ninguém fechou. Três frentes e um revisor livre fecham mais.
- **Uma pessoa resolve `SPEC.md`**: cada volta anexa a ADR no fim; o merge costura em ordem cronológica por script e confere que não sobrou marcador. O script usado na limpeza de 07/09 está no LACO.

## 7. Estado de hoje e como subir

Cotas em 08/09 pela manhã: Claude sessão 4%, semanal 10%, Fable semanal 6%; Codex semanal 2%. Só `main` existe. A dívida das seis voltas mescladas sem portão está no RUMO ("A limpeza de 07/09"). A sessão anterior do orquestrador é `ea792f6c-9fcb-4ca6-a995-9edfd3e083cb`.

```bash
ferramentas/orca/equipe.sh "<objetivo da primeira volta>"
```

O script cria a aba "Orquestrador · Opus 5" no worktree ativo, espera `tui-idle`, manda o brief (que começa pelo estado de 08/09) e o objetivo. Para retomar a sessão anterior com memória, numa aba nova: `claude --model opus --dangerously-skip-permissions --resume ea792f6c-9fcb-4ca6-a995-9edfd3e083cb`, dizendo na primeira mensagem que só existe `main`.
