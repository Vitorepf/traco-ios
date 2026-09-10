#!/bin/bash
# LOTE-8 (Q4-F, tentativa 2) — a MESMA fixture do LOTE-6, byte a byte (SHA
# `da012e21…`), com UMA alavanca trocada no `sistemaContrapor`: o que ela já
# descartou é DADO, e quanto mais ela fecha, mais o contraponto se aperta no
# que sobra. Fixture idêntica é o que faz a comparação com o LOTE-6 valer
# linha a linha — nada mais mudou no pedido.
#
# UMA janela, UMA instalação por cima no aparelho da CONTA, tudo dentro da
# MESMA chamada de com-trava.sh: soltar a trava entre o install e a corrida é
# o mesmo que não travar.
# `instigar` NÃO corre: fica de fora desta volta por ordem, e medir o que não
# volta só gasta janela.
set -u
D=34CC3F94-FDB5-4575-A4F5-80271829A18B   # aparelho da CONTA desta volta: só sonda e captura
BID=app.traco
RAIZ=/Users/vitorepf/orca/workspaces/traco-ios/q4-c
APP="$RAIZ/build/Build/Products/Debug-iphonesimulator/Traco.app"
OUT="${1:?diretorio de saida}"
FIX=q4c-contrapor-cego-casos.json
L=/tmp/traco-instrumento.lock
# So toca a trava se ela AINDA for o diretorio do dono (lei do 09e).
( while :; do [ -d "$L" ] && touch "$L" 2>/dev/null; sleep 60; done ) & TOUCHER=$!
trap 'kill $TOUCHER 2>/dev/null' EXIT

docs() { echo "$(xcrun simctl get_app_container $D $BID data)/Documents"; }
hora() { date -u +%Y-%m-%dT%H:%M:%SZ; }
sha()  { shasum -a 256 "$1" | awk '{print $1}'; }
# O `Traco` de 59 k e so o lancador; o codigo — e o prompt — vive no
# .debug.dylib. Conferir o lancador da "igual" com a alavanca trocada.
shadyl() { shasum -a 256 "$1/Traco.debug.dylib" | awk '{print $1}'; }

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

echo "[$(hora)] estado do $D: $(xcrun simctl list devices | grep $D)"
xcrun simctl boot $D 2>/dev/null
xcrun simctl bootstatus $D -b || { echo "BOOT FALHOU"; exit 2; }
xcrun simctl get_app_container $D $BID app >/dev/null 2>&1 || { echo "APP NAO INSTALADO no aparelho da conta"; exit 2; }

echo "[$(hora)] dylib ANTES:  $(shadyl "$(xcrun simctl get_app_container $D $BID app)")"
echo "[$(hora)] a instalar:   $(shadyl "$APP")"
echo "[$(hora)] fixture nova:   $(sha "$RAIZ/prova/$FIX")"

# 1) fumaça ANTES: a conta responde com o binário que já estava lá
rodar lote09h-fumaca-1-antes.jsonl q2-fumaca.json "" "" 180
conta() { grep -o '"contaGrokLigada":[a-z]*' "$OUT/$1" | tail -1; }
echo "[$(hora)] CONTA ANTES: $(conta lote09h-fumaca-1-antes.jsonl)"
grep -q '"contaGrokLigada":true' "$OUT/lote09h-fumaca-1-antes.jsonl" || {
  echo "[$(hora)] ⛔ CONTA CAIDA ANTES DE QUALQUER COISA — nao instalo, nao corro"; exit 4; }

# 2) A ÚNICA instalação da janela. Por cima: sem uninstall/erase/clearState.
echo "[$(hora)] INSTALL (unico da janela): xcrun simctl install $D $APP"
xcrun simctl install $D "$APP" || { echo "INSTALL FALHOU"; exit 3; }
echo "[$(hora)] dylib DEPOIS: $(shadyl "$(xcrun simctl get_app_container $D $BID app)")"
cmp -s "$APP/Traco.debug.dylib" "$(xcrun simctl get_app_container $D $BID app)/Traco.debug.dylib" \
  && echo "[$(hora)] cmp: o dylib instalado E o meu produto de build" \
  || { echo "[$(hora)] ⛔ cmp: o dylib instalado NAO e o meu"; exit 6; }

# 3) fumaça DEPOIS: a conta sobreviveu ao install por cima?
rodar lote09h-fumaca-2-pos-install.jsonl q2-fumaca.json "" "" 180
echo "[$(hora)] CONTA DEPOIS DO INSTALL: $(conta lote09h-fumaca-2-pos-install.jsonl)"
grep -q '"contaGrokLigada":true' "$OUT/lote09h-fumaca-2-pos-install.jsonl" || {
  echo "[$(hora)] ⛔ CONTA CAIU NO INSTALL POR CIMA — comando: xcrun simctl install $D $APP"; exit 5; }

# 4) os 8 casos × 3, nos dois modelos, SEM reinstalar entre eles.
# LIBERAR=contrapor continua sendo passado de propósito: no candidato a rota já
# é `soGrok` e a chave não é consultada, mas o JSONL grava
# `operacoesLiberadasParaAvaliacao` igual ao do LOTE-5 — a corrida sai
# comparável linha a linha com a de ontem.
rodar lote09h-q4-grok-4.3.jsonl $FIX contrapor grok-4.3 1800
rodar lote09h-fumaca-3-meio.jsonl q2-fumaca.json "" "" 180
rodar lote09h-q4-grok-4.5.jsonl $FIX contrapor grok-4.5 1800
rodar lote09h-fumaca-4-fim.jsonl q2-fumaca.json "" "" 180

echo "[$(hora)] CONTA NO FIM: $(conta lote09h-fumaca-4-fim.jsonl)"
echo "[$(hora)] dylib FIM:    $(shadyl "$(xcrun simctl get_app_container $D $BID app)")"
cmp -s "$APP/Traco.debug.dylib" "$(xcrun simctl get_app_container $D $BID app)/Traco.debug.dylib" \
  && echo "[$(hora)] cmp FIM: continua o meu" || echo "[$(hora)] ⛔ cmp FIM: trocaram o dylib no meio"

# 5) A CAPTURA do cartão real, dentro da mesma trava. Toque pela árvore de AX,
# nunca por coordenada cega: o script imprime onde tocou e o que apareceu.
"$RAIZ/ferramentas/orca/q4e-cartao.sh" "$D" "$OUT" "$RAIZ/build/f5-ler" || echo "[$(hora)] CAPTURA FALHOU (a janela de medida continua válida)"

echo "[$(hora)] JANELA ENCERRADA"
