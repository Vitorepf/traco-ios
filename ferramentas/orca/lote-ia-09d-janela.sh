#!/bin/bash
# LOTE-4: a emenda da Q3 (a GRANDEZA no lugar da "comparação com o teto"),
# medida sozinha. UMA janela, UMA instalação, três fumaças, tudo sob a mesma
# trava. Só a fixture da Q3 — a Q4 mede na janela dela.
#
# Cópia generalizada da `lote-ia-09c-janela.sh`: RAIZ e PREFIXO saem do
# ambiente para que a próxima medida REUSE este arquivo em vez de copiá-lo
# de novo (a cadeia 09/09b/09c é a dívida que isto fecha).
set -u
D=B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9
BID=app.traco
RAIZ="${RAIZ:-/Users/vitorepf/orca/workspaces/traco-ios/q3-c}"
PREFIXO="${PREFIXO:-lote09d}"
APP="$RAIZ/build/Build/Products/Debug-iphonesimulator/Traco.app"
OUT="${1:?diretorio de saida}"
L=/tmp/traco-instrumento.lock
# a guarda dos 30 min de com-trava.sh não olha o PID e esta sequência é UMA
# chamada longa por desenho. Morre com o script.
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
  # modelo vazio = NÃO exportar: "" não é nil no Swift e viraria modelo em branco
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

# 1) fumaça ANTES da instalação — a conta lida com o binário velho
rodar $PREFIXO-fumaca-1-antes.jsonl q2-fumaca.json "" "" 180

# 2) A ÚNICA instalação da janela. Install POR CIMA: sem uninstall/erase/clearState.
echo "[$(hora)] INSTALL (unico da janela): xcrun simctl install $D $APP"
xcrun simctl install $D "$APP" || { echo "INSTALL FALHOU"; exit 3; }
echo "[$(hora)] binario DEPOIS: $(sha "$(xcrun simctl get_app_container $D $BID app)/Traco")"
echo "[$(hora)] dylib  DEPOIS:  $(sha "$(xcrun simctl get_app_container $D $BID app)/Traco.debug.dylib")"

# 3) fumaça DEPOIS da instalação — a conta sobreviveu ao install por cima?
rodar $PREFIXO-fumaca-2-pos-install.jsonl q2-fumaca.json "" "" 180

# 4) os dois modelos na MESMA janela, sem reinstalar, no padrão de produção
rodar $PREFIXO-q3-grok-4.3.jsonl q3-responder-nas-notas.json "responderNasNotas" grok-4.3 1500
rodar $PREFIXO-q3-grok-4.5.jsonl q3-responder-nas-notas.json "responderNasNotas" grok-4.5 1500

# 5) fumaça FIM
rodar $PREFIXO-fumaca-3-fim.jsonl q2-fumaca.json "" "" 180

echo "[$(hora)] binario FIM:    $(sha "$(xcrun simctl get_app_container $D $BID app)/Traco")"
echo "[$(hora)] JANELA ENCERRADA"
