#!/bin/bash
# F5b: semeia um Destaque (ou não) e UM compromisso com início e duração em
# minutos, e relança o app pela ROTA REAL de publicação: com
# TRACO_REPUBLICAR_CALENDARIO no ambiente, o arranque (DEBUG) lê calendario.json
# e chama `ProximoCompromisso.publicar(eventos, cal:)` — a mesma função que a
# agenda, o editor e o intent chamam ao gravar um compromisso — que publica a
# projeção e sobe a Live Activity; o Destaque sobe por `reconciliar` (ADR 05u).
# O G3 da F5b recusou a versão anterior: sem o gancho, o arranque só reconciliava
# a projeção velha e o compromisso semeado nunca ia ao ar.
# Uso: f5b-semear.sh <UDID> <inicio-min> <duracao-min> [destaque|sem-destaque] [titulo]
# Ex.: f5b-semear.sh $U 40 60 destaque        -> as duas atividades vivas
#      f5b-semear.sh $U 1 2 sem-destaque      -> acaba em 3 min: o estado "acabou"
# Com LOG=<arquivo>, grava o log do `liveactivitiesd` desde o lançamento (as
# linhas "Starting activity" com id e staleDate são a segunda medida, a que a
# captura se confere) — versione-o ao lado das capturas.
set -e
U="$1"; INICIO="${2:-40}"; DURACAO="${3:-60}"; DESTAQUE="${4:-destaque}"; TITULO="${5:-Dentista}"
LINHA="${LINHA:-terminar o capítulo do meio antes de dormir}"
DATA=$(xcrun simctl get_app_container "$U" app.traco data)
GRUPO=$(xcrun simctl get_app_container "$U" app.traco group.app.traco)
PLIST="$GRUPO/Library/Preferences/group.app.traco.plist"
DIA=$(date +%Y-%m-%d); ID="${ID:-$(uuidgen)}"
CAL="$DATA/Documents/Traço/calendario.json"
mkdir -p "$(dirname "$CAL")" "$(dirname "$PLIST")"
iso() { local m="$1"; case "$m" in -*) ;; *) m="+$m";; esac; date -v"${m}"M -u +%Y-%m-%dT%H:%M:%SZ; }
cat > "$CAL" <<JSON
[{"id":"$(uuidgen)","titulo":"$TITULO","inicio":"$(iso "$INICIO")","fim":"$(iso $((INICIO + DURACAO)))","notas":"","diaInteiro":false,"repeteEm":[],"avisoMinutos":null}]
JSON
for k in destaqueLinha destaqueDia destaqueId destaqueFeitoEm destaqueFeitoId; do
  /usr/libexec/PlistBuddy -c "Delete :$k" "$PLIST" 2>/dev/null || true
done
if [ "$DESTAQUE" = destaque ]; then
  /usr/libexec/PlistBuddy -c "Add :destaqueLinha string $LINHA" "$PLIST"
  /usr/libexec/PlistBuddy -c "Add :destaqueDia string $DIA" "$PLIST"
  /usr/libexec/PlistBuddy -c "Add :destaqueId string $ID" "$PLIST"
fi
xcrun simctl spawn "$U" launchctl kill 9 system/com.apple.cfprefsd.xpc.daemon 2>/dev/null || true
xcrun simctl terminate "$U" app.traco 2>/dev/null || true
sleep 1
SUP="$GRUPO/superficie.json"; DESDE=$(date "+%Y-%m-%d %H:%M:%S")
SIMCTL_CHILD_TRACO_REPUBLICAR_CALENDARIO=1 xcrun simctl launch "$U" app.traco >/dev/null
# a prova de publicação é o TÍTULO semeado dentro da projeção, não a data do arquivo
for _ in $(seq 1 30); do grep -q "\"titulo\":\"$TITULO\"" "$SUP" 2>/dev/null && break; sleep 1; done
sleep 3   # a subida das atividades vem depois da publicação (fila)
xcrun simctl terminate "$U" app.traco 2>/dev/null || true
grep -q "\"titulo\":\"$TITULO\"" "$SUP" 2>/dev/null \
  || { echo "f5b-semear: o app NÃO publicou '$TITULO' em $SUP em 30 s" >&2; exit 1; }
LINHAS=$(xcrun simctl spawn "$U" log show --start "$DESDE" --style compact \
  --predicate 'process == "liveactivitiesd"' 2>/dev/null | grep -Ei 'starting activity|marking activities stale|activity ended [0-9A-F]|launched process for reason' || true)
if [ -n "${LOG:-}" ]; then
  { echo "# f5b-semear $U $INICIO $DURACAO $DESTAQUE '$TITULO' — desde $DESDE"; echo "$LINHAS"; } > "$LOG"
fi
VIVAS=$(echo "$LINHAS" | grep -c 'Starting activity' || true)
echo "semeado: $TITULO em +${INICIO} min por ${DURACAO} min, $DESTAQUE ($(stat -f %Sm -t %H:%M:%S "$SUP")); $VIVAS atividade(s) a subir no liveactivitiesd"
