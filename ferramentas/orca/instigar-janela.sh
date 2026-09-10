#!/bin/bash
# LOTE-INSTIGAR (volta INSTIGAR) — a alavanca CONDICIONADA À MATÉRIA, os dois modelos e
# o caso cego do `instigar`. UMA janela, UMA instalação por cima no aparelho da
# CONTA, tudo dentro da MESMA chamada de com-trava.sh: soltar a trava entre o
# install e a corrida é o mesmo que não travar.
#
# O UDID é PARÂMETRO: esta volta entra no primeiro aparelho de conta que soltar,
# e o relato diz qual foi. NUNCA `xcodebuild test` aqui; nunca erase/uninstall.
#
# A fixture é NOVA (`instigar-cego-casos.json`): os DOZE casos do LOTE-5 entram
# byte a byte e os dois cegos vêm depois. A comparação com o LOTE-5 é por ID de
# caso, não por SHA de arquivo — o SHA muda por construção.
#
# ADR 10c, dívida do RUMO fechada aqui: além do HASH nos dois extremos, a janela
# guarda o TEXTO do prompt extraído do binário instalado. Hash prova qual binário
# rodou; só o texto deixa o G3 conferir o que ele dizia depois que outro build
# substituiu o `.dylib`.
set -u
D="${1:?UDID do aparelho de CONTA}"
OUT="${2:?diretorio de saida}"
BID=app.traco
RAIZ=/Users/vitorepf/orca/workspaces/traco-ios/instigar
APP="$RAIZ/build/Build/Products/Debug-iphonesimulator/Traco.app"
FIX=instigar-cego-casos.json          # candidato: 12 do LOTE-5 + 2 cegos
FIXBASE=instigar-cego-base-casos.json # base: só os 8 de instigar (o contrapor
                                      # não muda de braço; medi-lo ali é gastar
                                      # janela do aparelho da conta para nada)
L=/tmp/traco-instrumento.lock
mkdir -p "$OUT"
# Só toca a trava se ela AINDA for o diretório do dono (lei do 09e).
( while :; do [ -d "$L" ] && touch "$L" 2>/dev/null; sleep 60; done ) & TOUCHER=$!
trap 'kill $TOUCHER 2>/dev/null' EXIT

docs() { echo "$(xcrun simctl get_app_container $D $BID data)/Documents"; }
hora() { date -u +%Y-%m-%dT%H:%M:%SZ; }
sha()  { shasum -a 256 "$1" | awk '{print $1}'; }

rodar() { # saida fixture liberar modelo timeout braço
  local saida="$1" fix="$2" lib="${3:-}" mod="${4:-}" tmo="${5:-600}" braco="${6:-}"
  local DOCS; DOCS="$(docs)"
  rm -f "$DOCS/avaliacoes-ia.jsonl"
  cp "$RAIZ/prova/$fix" "$DOCS/$fix"
  echo "[$(hora)] INICIO $saida  fixture=$fix liberar='$lib' modelo='${mod:-<padrao>}' pedido='${braco:-candidato}'"
  local -a MODENV=(); [ -n "$mod" ] && MODENV=(SIMCTL_CHILD_TRACO_AVALIAR_MODELO="$mod")
  local -a PEDENV=(); [ -n "$braco" ] && PEDENV=(SIMCTL_CHILD_TRACO_AVALIAR_PEDIDO="$braco")
  env SIMCTL_CHILD_TRACO_AVALIAR_IA="$fix" SIMCTL_CHILD_TRACO_AVALIAR_LIBERAR="$lib" \
    ${MODENV[@]+"${MODENV[@]}"} ${PEDENV[@]+"${PEDENV[@]}"} \
    xcrun simctl launch --terminate-running-process $D $BID || echo "launch FALHOU"
  local i=0
  while [ $i -lt $((tmo/2)) ]; do
    grep -q '"evento":"fim"' "$DOCS/avaliacoes-ia.jsonl" 2>/dev/null && break
    sleep 2; i=$((i+1))
  done
  cp "$DOCS/avaliacoes-ia.jsonl" "$OUT/$saida" 2>/dev/null
  echo "[$(hora)] FIM    $saida  linhas=$(wc -l < "$OUT/$saida" 2>/dev/null) fimGravado=$(grep -c '"evento":"fim"' "$OUT/$saida" 2>/dev/null)"
}
conta() { grep -o '"contaGrokLigada":[a-z]*' "$OUT/$1" | tail -1; }

echo "[$(hora)] APARELHO DE CONTA desta janela: $D"
echo "[$(hora)] estado: $(xcrun simctl list devices | grep $D)"
xcrun simctl boot $D 2>/dev/null
xcrun simctl bootstatus $D -b || { echo "BOOT FALHOU"; exit 2; }
xcrun simctl get_app_container $D $BID app >/dev/null 2>&1 || { echo "APP NAO INSTALADO no aparelho da conta"; exit 2; }

echo "[$(hora)] binario ANTES:  $(sha "$(xcrun simctl get_app_container $D $BID app)/Traco")"
echo "[$(hora)] a instalar:     $(sha "$APP/Traco")"
echo "[$(hora)] fixture candidato: $(sha "$RAIZ/prova/$FIX")"
echo "[$(hora)] fixture base:      $(sha "$RAIZ/prova/$FIXBASE")"

# 1) fumaça ANTES: a conta responde com o binário que já estava lá
rodar instigar-lote-fumaca-1-antes.jsonl q2-fumaca.json "" "" 180
echo "[$(hora)] CONTA ANTES: $(conta instigar-lote-fumaca-1-antes.jsonl)"
grep -q '"contaGrokLigada":true' "$OUT/instigar-lote-fumaca-1-antes.jsonl" || {
  echo "[$(hora)] ⛔ CONTA CAIDA ANTES DE QUALQUER COISA — nao instalo, nao corro"; exit 4; }

# 2) A ÚNICA instalação da janela. Por cima: sem uninstall/erase/clearState.
echo "[$(hora)] INSTALL (unico da janela): xcrun simctl install $D $APP"
xcrun simctl install $D "$APP" || { echo "INSTALL FALHOU"; exit 3; }
INSTALADO="$(xcrun simctl get_app_container $D $BID app)/Traco"
echo "[$(hora)] binario DEPOIS: $(sha "$INSTALADO")"
cmp -s "$INSTALADO" "$APP/Traco" && echo "[$(hora)] cmp: o binario no aparelho E o meu produto de build" \
  || { echo "[$(hora)] ⛔ cmp FALHOU — o binario no aparelho NAO e o meu"; exit 6; }

# 3) O TEXTO do prompt medido, do binário instalado, guardado junto do JSONL.
DYLIB="$(dirname "$INSTALADO")/Traco.debug.dylib"
[ -f "$DYLIB" ] || DYLIB="$INSTALADO"
# Os DOIS pedidos, porque o mesmo binário carrega os dois braços. O SHA que sai
# aqui é o que o app grava em `pedidoInstigarSHA256`: se um não bater com o
# outro no fim da janela, a corrida não mediu o que diz ter medido.
echo "[$(hora)] pedido CANDIDATO: $("$RAIZ/ferramentas/orca/instigar-prompt.py" "$DYLIB" \
  "Você é uma pessoa sábia lendo o rascunho" "só entra a que a nota deixou sem resposta." \
  "$OUT/instigar-lote-pedido-candidato.txt" | tr '\n' ' ')"
echo "[$(hora)] pedido BASE:      $("$RAIZ/ferramentas/orca/instigar-prompt.py" "$DYLIB" \
  "Você é uma pessoa sábia lendo o rascunho" "mesmo uma linha só dá o que perguntar — o quê, quando, o que era." \
  "$OUT/instigar-lote-pedido-base.txt" | tr '\n' ' ')"
echo "[$(hora)] dylib medido: $(sha "$DYLIB")"

# 4) fumaça DEPOIS: a conta sobreviveu ao install por cima?
rodar instigar-lote-fumaca-2-pos-install.jsonl q2-fumaca.json "" "" 180
echo "[$(hora)] CONTA DEPOIS DO INSTALL: $(conta instigar-lote-fumaca-2-pos-install.jsonl)"
grep -q '"contaGrokLigada":true' "$OUT/instigar-lote-fumaca-2-pos-install.jsonl" || {
  echo "[$(hora)] ⛔ CONTA CAIU NO INSTALL POR CIMA — comando: xcrun simctl install $D $APP"; exit 5; }

# 5) QUATRO braços, UM binário. A alavanca é o PEDIDO, e ele troca por ambiente
# (`TRACO_AVALIAR_PEDIDO=base`), com o SHA-256 de cada um gravado em toda linha
# do JSONL: "o binário era outro" deixa de ser uma dúvida possível. A base sai
# primeiro, para que uma janela interrompida no meio deixe a régua e não só o
# candidato. LIBERAR igual ao do LOTE-5 de propósito — o JSONL grava a mesma
# `operacoesLiberadasParaAvaliacao` e a corrida sai comparável linha a linha.
rodar instigar-lote-base-grok-4.3.jsonl      $FIXBASE instigar,contrapor grok-4.3 2400 base
rodar instigar-lote-base-grok-4.5.jsonl      $FIXBASE instigar,contrapor grok-4.5 2400 base
rodar instigar-lote-fumaca-3-meio.jsonl      q2-fumaca.json "" "" 180
rodar instigar-lote-candidato-grok-4.3.jsonl $FIX     instigar,contrapor grok-4.3 2400
rodar instigar-lote-candidato-grok-4.5.jsonl $FIX     instigar,contrapor grok-4.5 2400
rodar instigar-lote-fumaca-4-fim.jsonl       q2-fumaca.json "" "" 180

# 6) o braço de cada arquivo, pelo SHA que o próprio app gravou — não pelo nome
for f in "$OUT"/instigar-lote-base-*.jsonl "$OUT"/instigar-lote-candidato-*.jsonl; do
  echo "[$(hora)] $(basename "$f")  pedidoInstigarSHA256=$(grep -o '"pedidoInstigarSHA256":"[a-f0-9]*"' "$f" | sort -u | tr '\n' ' ')"
done

echo "[$(hora)] CONTA NO FIM: $(conta instigar-lote-fumaca-4-fim.jsonl)"
echo "[$(hora)] binario FIM:    $(sha "$(xcrun simctl get_app_container $D $BID app)/Traco")"
echo "[$(hora)] JANELA ENCERRADA"
