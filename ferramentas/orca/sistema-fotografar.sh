#!/bin/bash
# SISTEMA (ADR 10k) — instala o build e fotografa as telas da varredura em large:
# Perfil (topo e dois passos abaixo), Padrões, Calendário em lista.
# Uso: sistema-fotografar.sh <UDID> <Traco.app> <saida> — sob com-trava.sh, no aparelho de suíte (teste 4)
set -u
D="${1:?udid}"; APP="${2:?Traco.app}"; OUT="${3:?saida}"; BID=app.traco
mkdir -p "$OUT"
hora()   { date '+%H:%M:%S'; }
espera() { perl -e "select(undef,undef,undef,$1)"; }
tocar()  { orca emulator tap $1 $2 --device "$D" >/dev/null 2>&1; echo "[$(hora)] toque $3"; }
foto()   { xcrun simctl io "$D" screenshot "$OUT/$1" >/dev/null 2>&1; echo "[$(hora)] foto $1"; }
# rolagem curta e SEM duração: com "duration" o arrasto vira toque longo e não rola;
# sem ela rende várias vezes o que se pede (memória)
rolar()  { orca emulator gesture --points "[{\"type\":\"begin\",\"x\":0.5,\"y\":$1},{\"type\":\"move\",\"x\":0.5,\"y\":$(echo "($1+$2)/2" | bc -l)},{\"type\":\"end\",\"x\":0.5,\"y\":$2}]" --device "$D" >/dev/null 2>&1; echo "[$(hora)] rolar $1→$2"; }
Y=0.947; NOTAS=0.151; CAL=0.330; PAD=0.510; PERFIL=0.689

pkill -f "serve-sim.*$D" 2>/dev/null && espera 2
orca emulator attach "$D" --json >/dev/null 2>&1 || { echo "attach FALHOU"; exit 1; }
xcrun simctl ui "$D" content_size large
xcrun simctl install "$D" "$APP" || exit 3
INST="$(xcrun simctl get_app_container "$D" $BID app)/Traco"
cmp -s "$INST" "$APP/Traco" && echo "[$(hora)] cmp: binario instalado e o meu" || { echo "cmp: DIFERENTE"; exit 3; }
xcrun simctl launch --terminate-running-process "$D" $BID >/dev/null 2>&1
espera 3
tocar 0.02 0.5 "puxador do arquivo"; espera 2
tocar $PERFIL $Y perfil; espera 2; foto perfil-1.png
rolar 0.70 0.64; espera 1.5; foto perfil-2.png
rolar 0.70 0.64; espera 1.5; foto perfil-3.png
rolar 0.70 0.64; espera 1.5; foto perfil-4.png
tocar $PAD $Y padroes; espera 3; foto padroes-1.png
rolar 0.70 0.64; espera 1.5; foto padroes-2.png
tocar $CAL $Y calendario; espera 2; foto calendario.png
