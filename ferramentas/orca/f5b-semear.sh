#!/bin/bash
# F5b: semeia um Destaque (ou não) e UM compromisso com início e duração em
# minutos, e relança o app — que reconcilia e sobe as Live Activities pelo
# caminho real (ADR 05u). Uso: f5b-semear.sh <UDID> <inicio-min> <duracao-min> [destaque|sem-destaque] [titulo]
# Ex.: f5b-semear.sh $U 40 60 destaque        -> as duas atividades vivas
#      f5b-semear.sh $U 1 2 sem-destaque      -> acaba em 3 min: o estado "acabou"
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
SUP="$GRUPO/superficie.json"; MARCA=$(mktemp)
xcrun simctl launch "$U" app.traco >/dev/null
for _ in $(seq 1 30); do [ "$SUP" -nt "$MARCA" ] && break; sleep 1; done
rm -f "$MARCA"
sleep 2   # a reconciliação das atividades vem depois da publicação
xcrun simctl terminate "$U" app.traco 2>/dev/null || true
[ -n "$(find "$SUP" -newer "$PLIST" 2>/dev/null)" ] || { echo "f5b-semear: o app NÃO publicou $SUP em 30 s" >&2; exit 1; }
echo "semeado: $TITULO em +${INICIO} min por ${DURACAO} min, $DESTAQUE ($(stat -f %Sm -t %H:%M:%S "$SUP"))"
