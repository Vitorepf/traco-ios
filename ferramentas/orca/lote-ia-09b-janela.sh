#!/bin/bash
# LOTE-2: mesmas duas fixtures em dois modelos, uma janela, SEM instalar.
# Varia TRACO_AVALIAR_MODELO e só ele. Tudo sob a mesma trava.
set -u
D=B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9
BID=app.traco
RAIZ=/Users/vitorepf/orca/workspaces/traco-ios/lote-ia-09
ESPERADO=e9983ddb5a0f6d91b20c42e38b801eb889aac85112b56bd4da946830a5a96e71
OUT="${1:?diretorio de saida}"
L=/tmp/traco-instrumento.lock
# mesma razão da janela anterior: a guarda dos 30 min não olha o PID, e esta
# sequência é UMA chamada longa por desenho. Morre com o script.
# So toca a trava se ela AINDA for o diretorio do dono: sem o teste, um `touch`
# depois de a trava ser solta CRIA UM ARQUIVO no lugar dela, e ai `mkdir` falha
# para sempre e a casa inteira para (10/09, aconteceu duas vezes).
( while :; do [ -d "$L" ] && touch "$L" 2>/dev/null; sleep 60; done ) & TOUCHER=$!
trap 'kill $TOUCHER 2>/dev/null' EXIT

docs() { echo "$(xcrun simctl get_app_container $D $BID data)/Documents"; }
hora() { date -u +%Y-%m-%dT%H:%M:%SZ; }

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

INSTALADO=$(shasum -a 256 "$(xcrun simctl get_app_container $D $BID app)/Traco" | awk '{print $1}')
echo "[$(hora)] binario instalado: $INSTALADO"
if [ "$INSTALADO" != "$ESPERADO" ]; then echo "ABORTA: sha256 nao bate com $ESPERADO"; exit 2; fi
echo "[$(hora)] sha256 BATE — NAO instalo"

rodar lote09b-fumaca-1-antes.jsonl q2-fumaca.json "" "" 180

# BLOCO A — grok-4.5 (primeiro: se a janela esticar, corto o 4.6, não as repetições)
rodar lote09b-q3-grok-4.5.jsonl q3-responder-nas-notas.json      "responderNasNotas"  grok-4.5 1500
rodar lote09b-q4-grok-4.5.jsonl q4-instigar-contrapor-casos.json "instigar,contrapor" grok-4.5 2400

rodar lote09b-fumaca-2-entre.jsonl q2-fumaca.json "" "" 180

# BLOCO B — grok-4.6
rodar lote09b-q3-grok-4.6.jsonl q3-responder-nas-notas.json      "responderNasNotas"  grok-4.6 1500
rodar lote09b-q4-grok-4.6.jsonl q4-instigar-contrapor-casos.json "instigar,contrapor" grok-4.6 2400

rodar lote09b-fumaca-3-fim.jsonl q2-fumaca.json "" "" 180
echo "[$(hora)] JANELA ENCERRADA"
