#!/bin/bash
# Vigia do laço: a cada chamada, se o orquestrador está parado e a janela de sessão
# do Claude tem folga, manda ele continuar. Sai calado em qualquer outro caso.
# Agendado por launchd (app.traco.vigia) a cada 10 min. Log em ~/Library/Logs/traco-vigia.log
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
# A cadeira se PERGUNTA, não se decora: o handle fixo já apontou para a sessão errada
# (10/09, uma terceira sessão de orquestrador foi acordada por um H desatualizado).
RUN=run_ba86df7ee906
H=$(orca orchestration run-show --id "$RUN" --json 2>/dev/null | node -pe 'JSON.parse(require("fs").readFileSync(0)).result.run.coordinator_handle' 2>/dev/null)
[ -z "$H" ] || [ "$H" = undefined ] && H=term_c68d9dfa-795f-4778-9c4d-eb046e7d767c
LOG=~/Library/Logs/traco-vigia.log
say(){ echo "$(date '+%F %T') $*" >> "$LOG"; }
orca status --json 2>/dev/null | grep -q '"reachable": true' || { say "orca fora"; exit 0; }
# se a semanal acabou, o laço cumpriu a ordem: não reacender
SEM=$(orca account list --json 2>/dev/null | node -pe 'JSON.parse(require("fs").readFileSync(0)).result.rateLimits.claude.weekly.usedPercent' 2>/dev/null)
if [ -n "$SEM" ] && [ "${SEM%.*}" -ge 98 ]; then say "semanal em ${SEM}%, laço encerrado por cota"; exit 0; fi
# cota: só confia no valor se foi atualizado há menos de 15 min (o Orca guarda o último visto)
read USO IDADE < <(orca account list --json 2>/dev/null | node -pe 'const c=JSON.parse(require("fs").readFileSync(0)).result.rateLimits.claude;c.session.usedPercent+" "+Math.round((Date.now()-c.updatedAt)/60000)' 2>/dev/null)
if [ -n "$USO" ] && [ "${IDADE:-999}" -lt 15 ] && [ "${USO%.*}" -ge 98 ]; then say "sessão em ${USO}% (há ${IDADE} min), espero"; exit 0; fi
# não cutucar mais de uma vez a cada 30 min
ULT=$(grep reacendi "$LOG" 2>/dev/null | tail -1 | cut -c1-19); [ -n "$ULT" ] && [ $(( $(date +%s) - $(date -j -f "%Y-%m-%d %H:%M:%S" "$ULT" +%s) )) -lt 1800 ] && { say "cutuquei há pouco"; exit 0; }
if ! orca terminal show --terminal "$H" --json 2>/dev/null | grep -q '"ok": true'; then
  say "orquestrador sumiu; subo outro"
  cd /Users/vitorepf/develop/traco-ios && NOVO=$(./ferramentas/orca/equipe.sh "Retomada pelo vigia: leia ferramentas/orca/papeis/laco-evolucao.md, ESTEIRA.md, RUMO.md e LACO.md; workers em Opus 5 enquanto a cota do Fable nao voltar; faça run-use no laço run_ba86df7ee906, processe o inbox e continue de onde parou.") && say "novo orquestrador: $NOVO"
  exit 0
fi
# parado = TUI ociosa por 60 s
orca terminal wait --terminal "$H" --for tui-idle --timeout-ms 60000 --json 2>/dev/null | grep -q '"ok": true' || { say "trabalhando"; exit 0; }
orca terminal send --terminal "$H" --text "Vigia: a janela de sessão do Claude voltou (uso ${USO}%). Continue o laço conforme ferramentas/orca/papeis/laco-evolucao.md: processe o inbox pendente (worker_done, question), feche o que está em G3/G5, e reabra voltas até ter duas ou três em edição mais a trilha fora do app. Registre no LACO a pausa e a retomada." --enter --json >/dev/null 2>&1 && say "reacendi (sessão ${USO}%)"
