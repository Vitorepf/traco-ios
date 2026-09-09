#!/bin/bash
# F5b: filma a Ilha do compromisso — entrada, troca de estado e saída — por
# `simctl io recordVideo` (captura de tela, sem áudio). Uso:
#   f5b-filmar.sh <UDID> <saida.mp4>
# Pré-condição: tela DESTRANCADA na casa, app instalado, nenhum Destaque vivo
# (senão a Ilha é do Destaque — D9 da F1, ADR 08v corrige pela relevância).
# Cada `orca emulator` passa por f5b-emu.sh (trava + reatar).
set -e
U="$1"; SAIDA="$2"; AQUI="$(cd "$(dirname "$0")" && pwd)"
EMU="$AQUI/f5b-emu.sh"
ILHA_X=0.5; ILHA_Y="${ILHA_Y:-0.025}"          # centro da Ilha no 17 Pro Max
LEMBRAR_X="${LEMBRAR_X:-0.24}"; LEMBRAR_Y="${LEMBRAR_Y:-0.099}"   # a cápsula na expandida (medida em f5b-ilha-expandida.png)
xcrun simctl io "$U" recordVideo --codec h264 -f "$SAIDA" >/dev/null 2>&1 &
REC=$!
sleep 2
# 1. entrada: o app publica e a atividade sobe
"$AQUI/f5b-semear.sh" "$U" 30 60 sem-destaque >/dev/null
sleep 3
# 2. expandir: toque longo na Ilha (vários pontos parados = pressão de ~1 s)
PONTOS='[{"type":"begin","x":0.5,"y":'$ILHA_Y'}'
for _ in $(seq 1 12); do PONTOS="$PONTOS"',{"type":"move","x":0.5,"y":'$ILHA_Y'}'; done
PONTOS="$PONTOS"',{"type":"end","x":0.5,"y":'$ILHA_Y'}]'
"$EMU" "$U" gesture "$PONTOS" >/dev/null
sleep 2.5
# 3. troca de estado: "Lembrar em 10 min" vira "lembro às HH:MM"
"$EMU" "$U" tap "$LEMBRAR_X" "$LEMBRAR_Y" >/dev/null
sleep 3
"$EMU" "$U" button home >/dev/null
sleep 2
# 4. saída: o compromisso já passou; o app reconcilia e encerra a atividade
"$AQUI/f5b-semear.sh" "$U" -120 60 sem-destaque >/dev/null
sleep 3
kill -INT $REC; wait $REC 2>/dev/null || true
echo "filmado: $SAIDA ($(du -h "$SAIDA" | cut -f1))"
