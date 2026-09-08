#!/bin/bash
# Semeia o estado do Traço no simulador da volta F5 e relança o app, que
# publica a superfície. Uso: f5-semear.sh <UDID> <cenario>
# cenários: dia | vazio | feito | curto (três compromissos de 1 min: vira
# "desatualizado" sozinho em ~4 min, que é o caminho real)
set -e
U="$1"; CENARIO="${2:-dia}"
LINHA="${LINHA:-terminar o capítulo do meio antes de dormir}"
DATA=$(xcrun simctl get_app_container "$U" app.traco data)
GRUPO=$(xcrun simctl get_app_container "$U" app.traco group.app.traco)
PLIST="$GRUPO/Library/Preferences/group.app.traco.plist"
DIA=$(date +%Y-%m-%d)
ID="${ID:-$(uuidgen)}"   # ADR 08h: a prova do toque precisa do id de uma nota REAL
CAL="$DATA/Documents/Traço/calendario.json"
mkdir -p "$(dirname "$CAL")" "$(dirname "$PLIST")"

iso() { date -v+"$1"M -u +%Y-%m-%dT%H:%M:%SZ; }

case "$CENARIO" in
  vazio)
    echo '[]' > "$CAL"
    /usr/libexec/PlistBuddy -c "Delete :destaqueLinha" "$PLIST" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Delete :destaqueDia" "$PLIST" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Delete :destaqueId" "$PLIST" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Delete :destaqueFeitoEm" "$PLIST" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Delete :destaqueFeitoId" "$PLIST" 2>/dev/null || true
    ;;
  *)
    if [ "$CENARIO" = curto ]; then
      cat > "$CAL" <<JSON
[{"id":"$(uuidgen)","titulo":"Curto 1","inicio":"$(iso 1)","fim":"$(iso 2)","notas":"","diaInteiro":false,"repeteEm":[],"avisoMinutos":null},
 {"id":"$(uuidgen)","titulo":"Curto 2","inicio":"$(iso 2)","fim":"$(iso 3)","notas":"","diaInteiro":false,"repeteEm":[],"avisoMinutos":null},
 {"id":"$(uuidgen)","titulo":"Curto 3","inicio":"$(iso 3)","fim":"$(iso 4)","notas":"","diaInteiro":false,"repeteEm":[],"avisoMinutos":null}]
JSON
    else
      cat > "$CAL" <<JSON
[{"id":"$(uuidgen)","titulo":"Dentista","inicio":"$(iso 45)","fim":"$(iso 105)","notas":"","diaInteiro":false,"repeteEm":[],"avisoMinutos":15},
 {"id":"$(uuidgen)","titulo":"Revisão com o time","inicio":"$(iso 180)","fim":"$(iso 240)","notas":"","diaInteiro":false,"repeteEm":[],"avisoMinutos":0},
 {"id":"$(uuidgen)","titulo":"Jantar com a Ana","inicio":"$(iso 420)","fim":"$(iso 540)","notas":"","diaInteiro":false,"repeteEm":[],"avisoMinutos":null}]
JSON
    fi
    /usr/libexec/PlistBuddy -c "Delete :destaqueLinha" "$PLIST" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :destaqueLinha string $LINHA" "$PLIST"
    /usr/libexec/PlistBuddy -c "Delete :destaqueDia" "$PLIST" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :destaqueDia string $DIA" "$PLIST"
    /usr/libexec/PlistBuddy -c "Delete :destaqueId" "$PLIST" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :destaqueId string $ID" "$PLIST"
    /usr/libexec/PlistBuddy -c "Delete :destaqueFeitoEm" "$PLIST" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Delete :destaqueFeitoId" "$PLIST" 2>/dev/null || true
    if [ "$CENARIO" = feito ]; then
      /usr/libexec/PlistBuddy -c "Add :destaqueFeitoEm string $DIA" "$PLIST"
      /usr/libexec/PlistBuddy -c "Add :destaqueFeitoId string $ID" "$PLIST"
    fi
    ;;
esac

# o app lê a cópia em memória do cfprefsd: sem matar o daemon o plist novo
# não chega (lição da F4-D)
xcrun simctl spawn "$U" launchctl kill 9 system/com.apple.cfprefsd.xpc.daemon 2>/dev/null || true
xcrun simctl terminate "$U" app.traco 2>/dev/null || true
sleep 1
SUP="$GRUPO/superficie.json"; MARCA=$(mktemp)   # a superfície tem de ser mais nova que o lançamento
xcrun simctl launch "$U" app.traco >/dev/null
# espera fixa não é prova (F4-G): num contêiner recém-instalado 4 s não bastaram e
# o widget ficou em "Não consegui ler o Traço." — esperar o arquivo, ou falhar
for _ in $(seq 1 30); do [ "$SUP" -nt "$MARCA" ] && break; sleep 1; done
rm -f "$MARCA"
xcrun simctl terminate "$U" app.traco 2>/dev/null || true
[ -n "$(find "$SUP" -newer "$PLIST" 2>/dev/null)" ] || { echo "f5-semear: o app NÃO publicou $SUP em 30 s" >&2; exit 1; }
echo "semeado: $CENARIO ($(stat -f %Sm -t %H:%M:%S "$SUP") $SUP)"
