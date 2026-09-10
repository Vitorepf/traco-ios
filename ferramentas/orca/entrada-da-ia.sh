#!/bin/bash
# ENTRADA (ADR 10i) — a jornada de perguntar à sábia pela marca "?", em `large`,
# TELA INTEIRA com o pé (lei de 10/09 17h). Serve ao teste 4 (sem conta: a
# folha diz que precisa da conta) e ao aparelho de CONTA (resposta real).
# No aparelho de conta: instala por cima UMA vez, com cmp; nunca erase,
# uninstall, clearState ou xcodebuild test.
# Uso: entrada-da-ia.sh <UDID> <saida-dir> <Traco.app> "<pergunta em US-ASCII>" [conta]
set -u
D="${1:?udid}"; OUT="${2:?saida}"; APP="${3:?Traco.app}"; PERGUNTA="${4:?pergunta}"; CONTA="${5:-}"
BID=app.traco
LER=/Users/vitorepf/orca/workspaces/traco-ios/instigar/build/f5-ler
mkdir -p "$OUT"
hora()   { date '+%H:%M:%S'; }
espera() { perl -e "select(undef,undef,undef,$1)"; }
sha()    { shasum -a 256 "$1" | awk '{print $1}'; }
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
           orca emulator tap $xy --device "$D" >/dev/null 2>&1; echo "[$(hora)] toquei [$2] em $xy"; espera 1.5; }
toque()  { orca emulator tap "$1" "$2" --device "$D" >/dev/null 2>&1; echo "[$(hora)] toquei ($1,$2)"; espera 1.5; }
lento()  { python3 -c '
import json,sys
de, ate = float(sys.argv[1]), float(sys.argv[2]); n = 8
p  = [{"type": "begin", "x": 0.5, "y": de}]
p += [{"type": "move", "x": 0.5, "y": de + (ate - de) * i / n} for i in range(1, n + 1)]
p += [{"type": "move", "x": 0.5, "y": ate}, {"type": "end", "x": 0.5, "y": ate}]
print(json.dumps(p))' "$1" "$2"; }
rolar()  { orca emulator gesture "$(lento "$1" "$2")" --device "$D" >/dev/null 2>&1; espera 1.5; }
le()     { "$LER" "$OUT/$1" | grep -i -m1 "$2"; }
conta()  { foto "$1-a.png"
  if [ -z "$(achar "$1-a.png" "Perfil")" ]; then tocar "$1-n.png" "Notas" || return 1; fi
  tocar "$1-p.png" "Perfil" || return 1
  espera 1.5; foto "$1-perfil.png"
  echo "[$(hora)] CONTA ($1): $(le "$1-perfil.png" "conectada\|precisa da sua conta\|sem conta")"
  tocar "$1-b.png" "Notas" >/dev/null || true
}

pkill -f "serve-sim.*$D" 2>/dev/null && espera 2
orca emulator attach "$D" --json >/dev/null 2>&1 || { echo "attach FALHOU"; exit 1; }
xcrun simctl bootstatus "$D" -b >/dev/null || { echo "BOOT FALHOU"; exit 2; }
xcrun simctl ui "$D" content_size large
echo "[$(hora)] APARELHO: $D  tamanho: $(xcrun simctl ui "$D" content_size 2>/dev/null)"

INST="$(xcrun simctl get_app_container "$D" $BID app 2>/dev/null)/Traco"
echo "[$(hora)] binario ANTES : $(sha "$INST" 2>/dev/null)"
echo "[$(hora)] a instalar    : $(sha "$APP/Traco")"
if [ -n "$CONTA" ]; then xcrun simctl launch "$D" $BID >/dev/null 2>&1; espera 2; conta 00 || exit 1; fi
if cmp -s "$INST" "$APP/Traco"; then echo "[$(hora)] o binario instalado JA E O MEU — sem instalar de novo"
else xcrun simctl install "$D" "$APP" || { echo "INSTALL FALHOU"; exit 3; }; fi
INST="$(xcrun simctl get_app_container "$D" $BID app)/Traco"
cmp -s "$INST" "$APP/Traco" && echo "[$(hora)] cmp: o binario instalado E O MEU" || { echo "[$(hora)] cmp: BINARIO DIFERENTE"; exit 3; }
xcrun simctl launch --terminate-running-process "$D" $BID >/dev/null 2>&1; espera 3
if [ -n "$CONTA" ]; then conta 01 || exit 1; fi

# ir às Notas (o app abre na Página; "Notas" no alto leva ao arquivo)
foto 00-a.png; [ -z "$(achar 00-a.png "Perfil")" ] && { tocar 00-n.png "Notas" || exit 4; }
espera 1

xcrun simctl io "$D" recordVideo --codec h264 -f "$OUT/entrada-15s-large.mp4" >/dev/null 2>&1 & VID=$!
T0=$(date +%s.%N)
espera 1.5; foto 01-lista-large.png
# a marca "?" no título: à direita, na linha de base do título
toque 0.895 0.100; espera 1.5; foto 02-folha-vazia-large.png
orca emulator type "$PERGUNTA" --device "$D" >/dev/null 2>&1; espera 1.5; foto 03-escrita-large.png
# enviar: o botão de seta no fim da linha "?"
XY=$(achar 03-escrita-large.png "pergunte" ); 
toque 0.895 0.150; espera 2.5; foto 04-pensando-large.png
# esperar a resposta (conta) ou a linha de sem-conta (teste 4)
for i in $(seq 1 60); do
  foto 05-espera.png
  if [ -n "$(le 05-espera.png "serviu\|precisa da sua conta\|nao respondeu\|não respondeu")" ]; then break; fi
  espera 5
done
mv "$OUT/05-espera.png" "$OUT/05-resposta-large.png"; echo "[$(hora)] resposta: $(le 05-resposta-large.png "serviu\|precisa da sua conta\|respondeu")"
rolar 0.85 0.30; espera 1; foto 06-cauda-large.png
tocar 07-a.png "Fechar" && espera 1.5; foto 07-lista-de-volta-large.png
kill -INT $VID 2>/dev/null; wait $VID 2>/dev/null
PAREDE=$(python3 -c "import sys;print(round($(date +%s.%N)-$T0,1))")
echo "[$(hora)] parede: ${PAREDE}s"
DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT/entrada-15s-large.mp4")
ffmpeg -v error -y -i "$OUT/entrada-15s-large.mp4" -vf "setpts=PTS*15/$DUR,fps=30" -an "$OUT/entrada-15s-large.retimado.mp4" \
  && mv "$OUT/entrada-15s-large.retimado.mp4" "$OUT/entrada-15s-large.mp4"
echo "[$(hora)] video: $(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT/entrada-15s-large.mp4") s (bruto $DUR s)"

# a segunda porta: "?" escrito na busca abre a mesma folha
tocar 08-a.png "buscar" && orca emulator type "? " --device "$D" >/dev/null 2>&1; espera 1.5; foto 08-porta-busca-large.png
tocar 09-a.png "Fechar" >/dev/null || true; espera 1
# a mesma marca em Padrões
tocar 10-a.png "Padrões" && espera 1.5; foto 10-padroes-large.png
toque 0.895 0.100; espera 1.5; foto 11-padroes-leva-as-notas-large.png
tocar 12-a.png "Fechar" >/dev/null || true
if [ -n "$CONTA" ]; then conta 12 || true; fi
rm -f "$OUT"/*-a.png "$OUT"/*-n.png "$OUT"/*-p.png "$OUT"/*-b.png
echo "[$(hora)] FIM"
