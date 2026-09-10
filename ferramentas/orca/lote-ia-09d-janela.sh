#!/bin/bash
# LOTE-4: a emenda da Q3 (a GRANDEZA no lugar da "comparação com o teto"),
# medida sozinha. UMA janela, UMA instalação, três fumaças, tudo sob a mesma
# trava. Só a fixture da Q3 — a Q4 mede na janela dela.
#
# Cópia generalizada da `lote-ia-09c-janela.sh`: RAIZ e PREFIXO saem do
# ambiente para que a próxima medida REUSE este arquivo em vez de copiá-lo
# de novo (a cadeia 09/09b/09c é a dívida que isto fecha).
#
# 10/09 (ADR 10b), três generalizações e nenhuma cópia nova:
#   D     — o UDID vem do ambiente. Com três cadeiras de IA em paralelo, o
#           aparelho deixou de ser constante.
#   TRAVA — a trava é do PRÓPRIO UDID. A global punha as janelas em fila, e a
#           ordem de 10/09 12h40 é que elas corram juntas.
#   as CORRIDAS vêm como `saida:fixture:liberar:modelo:timeout`, e
#           `fixture` aceita caminho ABSOLUTO — prova com dado real mora fora
#           do repositório, em local de acesso restrito.
#
# 10/09 (G3 da 10b): o 6º campo, `pedido`, MORREU. O seletor de braço em Swift
#   que lia `TRACO_AVALIAR_PEDIDO` era costura de sonda da 10b e saiu no fecho
#   daquela volta; o `export` ficou aqui e a variável passou a não ter leitor.
#   Quem a usasse mediria o pedido ATUAL achando que mediu o anterior — a rota
#   que cala (DIRETRIZ §8), dentro do próprio medidor. Em vez de apagar em
#   silêncio, o campo PARAVA a corrida: quem quisesse dois braços devolvia o
#   seletor ao Swift primeiro. Os textos dos braços da 10b estão em
#   `prova/10b/pedido-candidato-{1,2}.txt`.
#
# 10/09 (ADR 10g): o 6º campo VOLTA, agora como `contexto`, e desta vez com
#   leitor: `AvaliacaoIA.bracoDoContexto` lê `TRACO_AVALIAR_CONTEXTO` e
#   `antigo` roda `Sabia.contextoDaPerguntaComoEraNa10b`. Toda linha do JSONL
#   sai com `contextoBraco`, então a corrida diz de si mesma qual montagem
#   rodou — a mesma cura que o `pedidoResponderSHA256` deu ao braço do pedido.
#   Se o leitor sair do Swift, este campo volta a PARAR a corrida.
# As três fumaças e a instalação única continuam obrigatórias e fixas.
set -u
D="${D:-B91C8DEF-B0A7-454A-95DE-5D7BA7B040A9}"
BID=app.traco
RAIZ="${RAIZ:-/Users/vitorepf/orca/workspaces/traco-ios/q3-c}"
PREFIXO="${PREFIXO:-lote09d}"
APP="$RAIZ/build/Build/Products/Debug-iphonesimulator/Traco.app"
OUT="${1:?diretorio de saida}"; shift
CORRIDAS=("$@")
L="${TRAVA:-/tmp/traco-instrumento.lock}"
# a guarda dos 30 min de com-trava.sh não olha o PID e esta sequência é UMA
# chamada longa por desenho. Morre com o script.
( while :; do touch "$L" 2>/dev/null; sleep 60; done ) & TOUCHER=$!
trap 'kill $TOUCHER 2>/dev/null' EXIT

docs() { echo "$(xcrun simctl get_app_container $D $BID data)/Documents"; }
hora() { date -u +%Y-%m-%dT%H:%M:%SZ; }
sha()  { shasum -a 256 "$1" | awk '{print $1}'; }

rodar() { # saida fixture liberar modelo timeout contexto
  local saida="$1" fix="$2" lib="${3:-}" mod="${4:-}" tmo="${5:-600}" ctx="${6:-}"
  local DOCS; DOCS="$(docs)"
  local src="$RAIZ/prova/$fix"; [ -f "$fix" ] && src="$fix"
  local nome; nome="$(basename "$fix")"
  rm -f "$DOCS/avaliacoes-ia.jsonl"
  cp "$src" "$DOCS/$nome" || { echo "fixture ausente: $src"; return 3; }
  fix="$nome"
  echo "[$(hora)] INICIO $saida  fixture=$fix ($(sha "$src" | cut -c1-12)) liberar='$lib' modelo='${mod:-<padrao>}' contexto='${ctx:-<novo>}'"
  # modelo vazio = NÃO exportar: "" não é nil no Swift e viraria modelo em branco
  local -a MODENV=(); [ -n "$mod" ] && MODENV=(SIMCTL_CHILD_TRACO_AVALIAR_MODELO="$mod")
  local -a CTXENV=(); [ -n "$ctx" ] && CTXENV=(SIMCTL_CHILD_TRACO_AVALIAR_CONTEXTO="$ctx")
  env SIMCTL_CHILD_TRACO_AVALIAR_IA="$fix" SIMCTL_CHILD_TRACO_AVALIAR_LIBERAR="$lib" \
    ${MODENV[@]+"${MODENV[@]}"} ${CTXENV[@]+"${CTXENV[@]}"} \
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

# 4) as corridas da volta, na MESMA janela e sem reinstalar
for c in ${CORRIDAS[@]+"${CORRIDAS[@]}"}; do
  IFS=: read -r _s _f _l _m _t _p <<<"$c"
  rodar "$_s" "$_f" "$_l" "$_m" "${_t:-600}" "${_p:-}"
done

# 5) fumaça FIM
rodar $PREFIXO-fumaca-3-fim.jsonl q2-fumaca.json "" "" 180

echo "[$(hora)] binario FIM:    $(sha "$(xcrun simctl get_app_container $D $BID app)/Traco")"
echo "[$(hora)] JANELA ENCERRADA"
