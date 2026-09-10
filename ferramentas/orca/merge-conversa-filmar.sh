#!/bin/bash
# MERGE-CONVERSA — o vídeo de 15 s da conversa com a sábia em `main`, com as
# duas dívidas do G4 fechadas: a "Referência:" e a linha das fontes citam a
# NOTA (título com teto), e "serviu | não serviu" pesa o que diz (meta).
# Aparelho de SUÍTE (teste 4), em `large`, sem conta: a resposta é o ensaio
# em Debug (`-ensaio-resposta-longa-nas-notas`, resposta MEDIDA de 568
# grafemas com quatro fontes cujo título é a nota inteira — o caso da dívida 1).
# Uso: merge-conversa-filmar.sh <UDID> <saida-dir> <Traco.app>
set -u
D="${1:?udid}"; OUT="${2:?saida}"; APP="${3:?Traco.app}"
BID=app.traco
LER=/Users/vitorepf/orca/workspaces/traco-ios/instigar/build/f5-ler
mkdir -p "$OUT"
hora()   { date '+%H:%M:%S'; }
espera() { perl -e "select(undef,undef,undef,$1)"; }
foto()   { xcrun simctl io "$D" screenshot "$OUT/$1" >/dev/null 2>&1; echo "[$(hora)] foto $1"; }
achar()  { "$LER" "$OUT/$1" --xy | ALVO="$2" python3 -c '
import os,sys
alvo=os.environ["ALVO"]; a=alvo.lower(); cand=[]
for l in sys.stdin:
    p=l.rstrip("\n").split("\t",1)
    if len(p)==2 and a in p[1].lower():
        t=p[1].strip(); cand.append((0 if t==alvo else 1 if t.lower()==a else 2, len(t), p[0]))
if cand: print(sorted(cand)[0][2])'; }
tocar()  { local xy; foto "$1"; xy=$(achar "$1" "$2"); [ -z "$xy" ] && { echo "[$(hora)] NAO ACHEI [$2] em $1"; return 1; }
           orca emulator tap $xy --device "$D" >/dev/null 2>&1; echo "[$(hora)] toquei [$2] em $xy"; }
lento()  { python3 -c '
import json,sys
de, ate = float(sys.argv[1]), float(sys.argv[2]); n = 8
p  = [{"type": "begin", "x": 0.5, "y": de}]
p += [{"type": "move", "x": 0.5, "y": de + (ate - de) * i / n} for i in range(1, n + 1)]
p += [{"type": "move", "x": 0.5, "y": ate}, {"type": "end", "x": 0.5, "y": ate}]
print(json.dumps(p))' "$1" "$2"; }
rolar()  { orca emulator gesture "$(lento "$1" "$2")" --device "$D" >/dev/null 2>&1; }

pkill -f "serve-sim.*$D" 2>/dev/null && espera 2
orca emulator attach "$D" --json >/dev/null 2>&1 || { echo "attach FALHOU"; exit 1; }
xcrun simctl bootstatus "$D" -b >/dev/null || { echo "BOOT FALHOU"; exit 2; }
xcrun simctl ui "$D" content_size large
echo "[$(hora)] APARELHO DE SUITE: $D  tamanho: $(xcrun simctl ui "$D" content_size 2>/dev/null)"

xcrun simctl install "$D" "$APP" || { echo "INSTALL FALHOU"; exit 3; }
INST="$(xcrun simctl get_app_container "$D" $BID app)/Traco"
cmp -s "$INST" "$APP/Traco" && echo "[$(hora)] cmp: o binario instalado E O MEU" || { echo "[$(hora)] cmp: BINARIO DIFERENTE"; exit 3; }
xcrun simctl launch --terminate-running-process "$D" $BID -autoAnalise '<true/>' -ensaio-resposta-longa-nas-notas >/dev/null 2>&1
espera 3

# a jornada, 15 s de parede: a folha, as fontes que nomeiam a nota, o retorno leve
xcrun simctl io "$D" recordVideo --codec h264 -f "$OUT/conversa-main-15s-large.mp4" >/dev/null 2>&1 & VID=$!
T0=$(date +%s.%N)
espera 2.5;  foto 01-folha-large.png
rolar 0.80 0.35; espera 2
foto 02-cauda-large.png
tocar 03-a.png "notas suas" && espera 2.5
foto 03-fontes-large.png
tocar 04-a.png "serviu" && espera 2.5
foto 04-anotado-large.png
espera 1
kill -INT $VID 2>/dev/null; wait $VID 2>/dev/null
PAREDE=$(python3 -c "import sys;print(round($(date +%s.%N)-$T0,1))")
echo "[$(hora)] parede: ${PAREDE}s"
# recordVideo estica o carimbo de tempo (09/09: 15,5 s → 21,4 s); retimar ao de parede
DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT/conversa-main-15s-large.mp4")
ffmpeg -v error -y -i "$OUT/conversa-main-15s-large.mp4" -vf "setpts=PTS*$PAREDE/$DUR,fps=30" -an "$OUT/conversa-main-15s-large.retimado.mp4" \
  && mv "$OUT/conversa-main-15s-large.retimado.mp4" "$OUT/conversa-main-15s-large.mp4"
echo "[$(hora)] video: $(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT/conversa-main-15s-large.mp4") s (bruto $DUR s)"
rm -f "$OUT"/*-a.png
echo "[$(hora)] FIM"
