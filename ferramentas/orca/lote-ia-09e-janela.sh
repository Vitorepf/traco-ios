#!/bin/bash
# LOTE-5 (Q4-C) — a Q3-C ocupou o nome 09d na mesma hora: a guarda que apaga deixou de virar silêncio (ADR 2026-09-09s)
# e os dois consertos de prompt da emenda à 09i. UMA janela, UMA instalação por
# cima no aparelho da CONTA, os dois modelos, três fumaças. Sob a mesma trava.
set -u
D=B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9   # aparelho da CONTA: só sonda e captura
BID=app.traco
RAIZ=/Users/vitorepf/orca/workspaces/traco-ios/q4-c
APP=/Users/vitorepf/Library/Developer/Xcode/DerivedData/Traco-bvscsnaukjkuykexchbrtdmlirih/Build/Products/Debug-iphonesimulator/Traco.app
OUT="${1:?diretorio de saida}"
L=/tmp/traco-instrumento.lock
( while :; do touch "$L" 2>/dev/null; sleep 60; done ) & TOUCHER=$!
trap 'kill $TOUCHER 2>/dev/null' EXIT

docs() { echo "$(xcrun simctl get_app_container $D $BID data)/Documents"; }
hora() { date -u +%Y-%m-%dT%H:%M:%SZ; }
sha()  { shasum -a 256 "$1" | awk '{print $1}'; }

rodar() { # saida fixture liberar modelo timeout
  local saida="$1" fix="$2" lib="${3:-}" mod="${4:-}" tmo="${5:-600}"
  local DOCS; DOCS="$(docs)"
  rm -f "$DOCS/avaliacoes-ia.jsonl"
  cp "$RAIZ/prova/$fix" "$DOCS/$fix"
  echo "[$(hora)] INICIO $saida  fixture=$fix liberar='$lib' modelo='${mod:-<padrao>}'"
  local -a MODENV=(); [ -n "$mod" ] && MODENV=(SIMCTL_CHILD_TRACO_AVALIAR_MODELO="$mod")
  env SIMCTL_CHILD_TRACO_AVALIAR_IA="$fix" SIMCTL_CHILD_TRACO_AVALIAR_LIBERAR="$lib" \
    ${MODENV[@]+"${MODENV[@]}"} \
    xcrun simctl launch --terminate-running-process $D $BID || echo "launch FALHOU"
  local i=0
  while [ $i -lt $((tmo/2)) ]; do
    grep -q '"evento":"fim"' "$DOCS/avaliacoes-ia.jsonl" 2>/dev/null && break
    sleep 2; i=$((i+1))
  done
  cp "$DOCS/avaliacoes-ia.jsonl" "$OUT/$saida" 2>/dev/null
  echo "[$(hora)] FIM    $saida  linhas=$(wc -l < "$OUT/$saida" 2>/dev/null) fimGravado=$(grep -c '"evento":"fim"' "$OUT/$saida" 2>/dev/null)"
}

echo "[$(hora)] binario ANTES:  $(sha "$(xcrun simctl get_app_container $D $BID app)/Traco")"
echo "[$(hora)] a instalar:     $(sha "$APP/Traco")"

# 1) fumaça ANTES: a conta responde com o binário que já estava lá
rodar lote09e-fumaca-1-antes.jsonl q2-fumaca.json "" "" 180

# 2) A ÚNICA instalação da janela. Por cima: sem uninstall/erase/clearState.
echo "[$(hora)] INSTALL (unico da janela): xcrun simctl install $D $APP"
xcrun simctl install $D "$APP" || { echo "INSTALL FALHOU"; exit 3; }
echo "[$(hora)] binario DEPOIS: $(sha "$(xcrun simctl get_app_container $D $BID app)/Traco")"

# 3) fumaça DEPOIS: a conta sobreviveu ao install por cima?
rodar lote09e-fumaca-2-pos-install.jsonl q2-fumaca.json "" "" 180

# 4) os 12 casos × 3, nos dois modelos, SEM reinstalar entre eles
rodar lote09e-q4-grok-4.3.jsonl q4-instigar-contrapor-casos.json "instigar,contrapor" grok-4.3 2400
rodar lote09e-fumaca-3-meio.jsonl q2-fumaca.json "" "" 180
rodar lote09e-q4-grok-4.5.jsonl q4-instigar-contrapor-casos.json "instigar,contrapor" grok-4.5 2400
rodar lote09e-fumaca-4-fim.jsonl q2-fumaca.json "" "" 180

echo "[$(hora)] binario FIM:    $(sha "$(xcrun simctl get_app_container $D $BID app)/Traco")"
echo "[$(hora)] JANELA ENCERRADA"
