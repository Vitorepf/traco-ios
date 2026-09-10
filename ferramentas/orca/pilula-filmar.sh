#!/bin/bash
# PÍLULA — 15 s em large, tela inteira com o pé: a cápsula anda pelas quatro abas,
# Escrever abre a página (a pílula sai), o gesto da borda devolve o arquivo.
# Uso: pilula-filmar.sh <UDID> <Traco.app> <saida> — sob com-trava.sh, no aparelho de suíte (teste 4)
set -u
D="${1:?udid}"; APP="${2:?Traco.app}"; OUT="${3:?saida}"; BID=app.traco
mkdir -p "$OUT"
hora()   { date '+%H:%M:%S'; }
espera() { perl -e "select(undef,undef,undef,$1)"; }
tocar()  { orca emulator tap $1 $2 --device "$D" >/dev/null 2>&1; echo "[$(hora)] toque $3"; }
foto()   { xcrun simctl io "$D" screenshot "$OUT/$1" >/dev/null 2>&1; echo "[$(hora)] foto $1"; }
borda()  { orca emulator gesture '[{"type":"begin","x":0.01,"y":0.5},{"type":"move","x":0.04,"y":0.5},{"type":"move","x":0.10,"y":0.5},{"type":"move","x":0.20,"y":0.5},{"type":"move","x":0.35,"y":0.5},{"type":"move","x":0.55,"y":0.5},{"type":"end","x":0.55,"y":0.5}]' --device "$D" >/dev/null 2>&1; echo "[$(hora)] borda"; }
Y=0.947; NOTAS=0.151; CAL=0.330; PAD=0.510; PERFIL=0.689; ESCREVER=0.885

pkill -f "serve-sim.*$D" 2>/dev/null && espera 2
orca emulator attach "$D" --json >/dev/null 2>&1 || { echo "attach FALHOU"; exit 1; }
xcrun simctl ui "$D" content_size large
echo "[$(hora)] tamanho: $(xcrun simctl ui "$D" content_size)"
xcrun simctl install "$D" "$APP" || exit 3
INST="$(xcrun simctl get_app_container "$D" $BID app)/Traco"
cmp -s "$INST" "$APP/Traco" && echo "[$(hora)] cmp: binario instalado e o meu" || { echo "cmp: DIFERENTE"; exit 3; }
xcrun simctl launch --terminate-running-process "$D" $BID >/dev/null 2>&1
espera 3
tocar 0.02 0.5 "puxador do arquivo"; espera 2

# os quadros parados, fora da janela filmada
foto 01-notas.png
tocar $CAL $Y calendario; espera 1.5; foto 02-calendario.png
tocar $PAD $Y padroes;   espera 1.5; foto 03-padroes.png
tocar $PERFIL $Y perfil; espera 1.5; foto 04-perfil.png
tocar $NOTAS $Y notas;   espera 1.5

xcrun simctl io "$D" recordVideo --codec h264 -f "$OUT/pilula-15s-large.mp4" >/dev/null 2>&1 & VID=$!
T0=$(perl -MTime::HiRes=time -e 'printf "%.2f", time')
espera 1.5
tocar $CAL $Y calendario; espera 1.8
tocar $PAD $Y padroes;    espera 1.8
tocar $PERFIL $Y perfil;  espera 1.8
tocar $NOTAS $Y "notas (tres casas)"; espera 2
tocar $ESCREVER $Y escrever; espera 2.4
borda; espera 2.2
kill -INT $VID 2>/dev/null; wait $VID 2>/dev/null
T1=$(perl -MTime::HiRes=time -e 'printf "%.2f", time')
echo "[$(hora)] parede: $(echo "$T1 - $T0" | bc) s"
foto 05-volta.png
