#!/bin/bash
# Sobe o orquestrador da equipe Orca no worktree ativo do traco-ios e, se houver
# objetivo, já o entrega. Uso: ferramentas/orca/equipe.sh ["objetivo"]
set -eu
cd "$(dirname "$0")/../.."
P=ferramentas/orca/papeis
H=$(orca terminal create --worktree active --title "Orquestrador · Fable 5.1" --command "claude --model fable --dangerously-skip-permissions" --json | node -pe 'JSON.parse(require("fs").readFileSync(0)).result.terminal.handle')
orca terminal wait --terminal "$H" --for tui-idle --timeout-ms 90000 --json >/dev/null
orca terminal send --terminal "$H" --text "$(cat $P/orquestrador.md)

Briefs dos workers: $P/arquiteto.md, $P/frontend.md, $P/revisor.md — inclua o brief no --spec de cada task.${1:+

OBJETIVO: $1}" --enter --json >/dev/null
echo "orquestrador: $H"
