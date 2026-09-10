#!/bin/bash
# LOTE-9 (Q4-F, ADR 2026-09-10d) — a TERCEIRA alavanca: o ESQUEMA DA SAÍDA.
# A MESMA fixture do LOTE-6/7/8, byte a byte (SHA `da012e21…`).
#
# O que muda em relação ao 09h: os DOIS braços correm no MESMO dylib, e o
# ANTIGO sai por ambiente (`TRACO_AVALIAR_CONTRAPOR_ANTIGO=1`). Sem isto,
# comparar esquema com pedido é comparar dois binários e ficar com a dúvida de
# qual rodou. Cada linha do JSONL grava `bracoContrapor` e
# `pedidoContraporSHA256`, então a dúvida morre linha a linha.
#
# Quatro corridas, UMA instalação, tudo dentro da MESMA chamada de com-trava.sh.
set -u
D=B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9   # aparelho da CONTA desta volta (teste 2)
BID=app.traco
RAIZ=/Users/vitorepf/orca/workspaces/traco-ios/q4-c
APP="$RAIZ/build/Build/Products/Debug-iphonesimulator/Traco.app"
OUT="${1:?diretorio de saida}"
FIX=q4c-contrapor-cego-casos.json
L=/tmp/traco-instrumento.lock
( while :; do [ -d "$L" ] && touch "$L" 2>/dev/null; sleep 60; done ) & TOUCHER=$!
trap 'kill $TOUCHER 2>/dev/null' EXIT

docs() { echo "$(xcrun simctl get_app_container $D $BID data)/Documents"; }
hora() { date -u +%Y-%m-%dT%H:%M:%SZ; }
sha()  { shasum -a 256 "$1" | awk '{print $1}'; }
shadyl() { shasum -a 256 "$1/Traco.debug.dylib" | awk '{print $1}'; }

rodar() { # saida fixture liberar modelo braco timeout
  local saida="$1" fix="$2" lib="${3:-}" mod="${4:-}" antigo="${5:-}" tmo="${6:-600}"
  local DOCS; DOCS="$(docs)"
  rm -f "$DOCS/avaliacoes-ia.jsonl"
  cp "$RAIZ/prova/$fix" "$DOCS/$fix"
  echo "[$(hora)] INICIO $saida  fixture=$fix liberar='$lib' modelo='${mod:-<padrao>}' antigo='${antigo:-0}'"
  local -a EXTRA=(); [ -n "$mod" ] && EXTRA+=(SIMCTL_CHILD_TRACO_AVALIAR_MODELO="$mod")
  [ -n "$antigo" ] && EXTRA+=(SIMCTL_CHILD_TRACO_AVALIAR_CONTRAPOR_ANTIGO="$antigo")
  env SIMCTL_CHILD_TRACO_AVALIAR_IA="$fix" SIMCTL_CHILD_TRACO_AVALIAR_LIBERAR="$lib" \
    ${EXTRA[@]+"${EXTRA[@]}"} \
    xcrun simctl launch --terminate-running-process $D $BID || echo "launch FALHOU"
  local i=0
  while [ $i -lt $((tmo/2)) ]; do
    grep -q '"evento":"fim"' "$DOCS/avaliacoes-ia.jsonl" 2>/dev/null && break
    sleep 2; i=$((i+1))
  done
  cp "$DOCS/avaliacoes-ia.jsonl" "$OUT/$saida" 2>/dev/null
  echo "[$(hora)] FIM    $saida  linhas=$(wc -l < "$OUT/$saida" 2>/dev/null) fimGravado=$(grep -c '"evento":"fim"' "$OUT/$saida" 2>/dev/null) braco=$(grep -o '"bracoContrapor":"[a-z-]*"' "$OUT/$saida" | sort -u | tr '\n' ' ')"
}

echo "[$(hora)] estado do $D: $(xcrun simctl list devices | grep $D)"
xcrun simctl bootstatus $D -b || { echo "BOOT FALHOU"; exit 2; }
xcrun simctl get_app_container $D $BID app >/dev/null 2>&1 || { echo "APP NAO INSTALADO no aparelho da conta"; exit 2; }

echo "[$(hora)] dylib ANTES:  $(shadyl "$(xcrun simctl get_app_container $D $BID app)")"
echo "[$(hora)] a instalar:   $(shadyl "$APP")"
echo "[$(hora)] fixture:      $(sha "$RAIZ/prova/$FIX")"

conta() { grep -o '"contaGrokLigada":[a-z]*' "$OUT/$1" | tail -1; }

# 1) fumaça ANTES do install
rodar lote09i-fumaca-1-antes.jsonl q2-fumaca.json "" "" "" 180
echo "[$(hora)] CONTA ANTES: $(conta lote09i-fumaca-1-antes.jsonl)"
grep -q '"contaGrokLigada":true' "$OUT/lote09i-fumaca-1-antes.jsonl" || {
  echo "[$(hora)] ⛔ CONTA CAIDA ANTES DE QUALQUER COISA — nao instalo, nao corro"; exit 4; }

# 2) A ÚNICA instalação da janela. Por cima: sem uninstall/erase/clearState.
echo "[$(hora)] INSTALL (unico da janela): xcrun simctl install $D $APP"
xcrun simctl install $D "$APP" || { echo "INSTALL FALHOU"; exit 3; }
echo "[$(hora)] dylib DEPOIS: $(shadyl "$(xcrun simctl get_app_container $D $BID app)")"
cmp -s "$APP/Traco.debug.dylib" "$(xcrun simctl get_app_container $D $BID app)/Traco.debug.dylib" \
  && echo "[$(hora)] cmp: o dylib instalado E o meu produto de build" \
  || { echo "[$(hora)] ⛔ cmp: o dylib instalado NAO e o meu"; exit 6; }

# 3) fumaça DEPOIS do install
rodar lote09i-fumaca-2-pos-install.jsonl q2-fumaca.json "" "" "" 180
echo "[$(hora)] CONTA DEPOIS DO INSTALL: $(conta lote09i-fumaca-2-pos-install.jsonl)"
grep -q '"contaGrokLigada":true' "$OUT/lote09i-fumaca-2-pos-install.jsonl" || {
  echo "[$(hora)] ⛔ CONTA CAIU NO INSTALL POR CIMA — comando: xcrun simctl install $D $APP"; exit 5; }

# 4) os quatro braços, no MESMO dylib, sem reinstalar entre eles.
#    O ANTIGO corre PRIMEIRO em cada modelo: se a conta cair no meio, o que
#    sobra é a linha de base, e não a do candidato.
rodar lote09i-antigo-grok-4.3.jsonl  $FIX contrapor grok-4.3 1  1800
rodar lote09i-esquema-grok-4.3.jsonl $FIX contrapor grok-4.3 "" 1800
rodar lote09i-fumaca-3-meio.jsonl    q2-fumaca.json "" "" ""    180
echo "[$(hora)] CONTA NO MEIO: $(conta lote09i-fumaca-3-meio.jsonl)"
rodar lote09i-antigo-grok-4.5.jsonl  $FIX contrapor grok-4.5 1  1800
rodar lote09i-esquema-grok-4.5.jsonl $FIX contrapor grok-4.5 "" 1800
rodar lote09i-fumaca-4-fim.jsonl     q2-fumaca.json "" "" ""    180

echo "[$(hora)] CONTA NO FIM: $(conta lote09i-fumaca-4-fim.jsonl)"
echo "[$(hora)] dylib FIM:    $(shadyl "$(xcrun simctl get_app_container $D $BID app)")"
cmp -s "$APP/Traco.debug.dylib" "$(xcrun simctl get_app_container $D $BID app)/Traco.debug.dylib" \
  && echo "[$(hora)] cmp FIM: continua o meu" || echo "[$(hora)] ⛔ cmp FIM: trocaram o dylib no meio"
echo "[$(hora)] JANELA ENCERRADA"
