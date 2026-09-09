#!/bin/bash
# F5b: liga/desliga Reduzir Movimento no simulador e confere lendo de volta.
# O `defaults write` por `simctl spawn` cai no cfprefsd do HOST (lição da F4-D);
# aqui o plist é escrito no disco do aparelho e o daemon é morto para reler.
# Uso: f5b-movimento.sh <UDID> on|off
set -e
U="$1"; MODO="$2"
P="$HOME/Library/Developer/CoreSimulator/Devices/$U/data/Library/Preferences/com.apple.Accessibility.plist"
python3 - "$P" "$MODO" <<'PY'
import plistlib, sys, os
p, modo = sys.argv[1], sys.argv[2]
d = plistlib.load(open(p, 'rb')) if os.path.exists(p) else {}
d['ReduceMotionEnabled'] = (modo == 'on')
plistlib.dump(d, open(p, 'wb'))
PY
xcrun simctl spawn "$U" launchctl kill 9 system/com.apple.cfprefsd.xpc.daemon 2>/dev/null || true
sleep 1
xcrun simctl spawn "$U" launchctl kill 9 system/com.apple.SpringBoard 2>/dev/null || true
sleep 8
echo "ReduceMotionEnabled agora: $(xcrun simctl spawn "$U" defaults read com.apple.Accessibility ReduceMotionEnabled 2>/dev/null || echo '?')"
