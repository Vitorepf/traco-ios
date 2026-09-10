#!/bin/bash
# Uma janela: fumaça, UMA instalação, três fixtures, fumaça. Tudo sob a mesma trava.
set -u
D=B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9
BID=app.traco
APP=/tmp/dd-lote-ia-09/Build/Products/Debug-iphonesimulator/Traco.app
RAIZ=/Users/vitorepf/orca/workspaces/traco-ios/lote-ia-09
OUT="${1:?diretorio de saida}"
L=/tmp/traco-instrumento.lock
# a trava é reclamada por terceiros aos 30 min mesmo com o dono vivo; enquanto
# ESTA sequência corre, mantenho o mtime fresco. Para quando o script para.
( while :; do touch "$L" 2>/dev/null; sleep 60; done ) & TOUCHER=$!
trap 'kill $TOUCHER 2>/dev/null' EXIT

docs() { echo "$(xcrun simctl get_app_container $D $BID data)/Documents"; }
hora() { date -u +%Y-%m-%dT%H:%M:%SZ; }

rodar() { # saida fixture liberar timeout
  local saida="$1" fix="$2" lib="${3:-}" tmo="${4:-600}"
  local DOCS; DOCS="$(docs)"
  rm -f "$DOCS/avaliacoes-ia.jsonl"
  cp "$RAIZ/prova/$fix" "$DOCS/$fix"
  echo "[$(hora)] INICIO $saida  fixture=$fix liberar='$lib'"
  SIMCTL_CHILD_TRACO_AVALIAR_IA="$fix" SIMCTL_CHILD_TRACO_AVALIAR_LIBERAR="$lib" \
    xcrun simctl launch --terminate-running-process $D $BID || echo "launch FALHOU"
  local i=0
  while [ $i -lt $((tmo/2)) ]; do
    grep -q '"evento":"fim"' "$DOCS/avaliacoes-ia.jsonl" 2>/dev/null && break
    sleep 2; i=$((i+1))
  done
  cp "$DOCS/avaliacoes-ia.jsonl" "$OUT/$saida" 2>/dev/null
  echo "[$(hora)] FIM    $saida  linhas=$(wc -l < "$OUT/$saida" 2>/dev/null) fimGravado=$(grep -c '"evento":"fim"' "$OUT/$saida" 2>/dev/null)"
}

echo "[$(hora)] binario instalado ANTES: $(shasum -a 256 "$(xcrun simctl get_app_container $D $BID app)/Traco" | awk '{print $1}')"
rodar lote-fumaca-1-antes.jsonl q2-fumaca.json "" 180

echo "[$(hora)] INSTALL (unica): $APP  sha256(exec)=$(shasum -a 256 "$APP/Traco" | awk '{print $1}')"
xcrun simctl install $D "$APP"; echo "install exit=$?"
echo "[$(hora)] binario instalado DEPOIS: $(shasum -a 256 "$(xcrun simctl get_app_container $D $BID app)/Traco" | awk '{print $1}')"

rodar lote-fumaca-2-pos-install.jsonl q2-fumaca.json "" 180
rodar lote-q3-responder-nas-notas.jsonl  q3-responder-nas-notas.json     "responderNasNotas" 1200
rodar lote-q4-instigar-contrapor.jsonl   q4-instigar-contrapor-casos.json "instigar,contrapor" 1800
rodar lote-q2f-responder.jsonl           q2f-casos.json                   "responder" 1200
rodar lote-fumaca-3-fim.jsonl q2-fumaca.json "" 180
echo "[$(hora)] JANELA ENCERRADA"
