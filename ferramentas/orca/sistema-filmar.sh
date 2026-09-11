#!/bin/bash
# SISTEMA (ADR 10k) — 15 s em large, tela inteira com o pé: o Perfil em linhas no papel,
# o cabeçalho que recolhe e abre (Conta, Quem responde), a rolagem até os interruptores
# em carvão, os Padrões com a contagem no cabeçalho e a agenda do calendário em lista.
# Uso: sistema-filmar.sh <UDID> <Traco.app> <saida> — sob com-trava.sh, no aparelho de suíte (teste 4)
set -u
D="${1:?udid}"; APP="${2:?Traco.app}"; OUT="${3:?saida}"; BID=app.traco
mkdir -p "$OUT"
hora()   { date '+%H:%M:%S'; }
espera() { perl -e "select(undef,undef,undef,$1)"; }
tocar()  { orca emulator tap $1 $2 --device "$D" >/dev/null 2>&1; echo "[$(hora)] toque $3"; }
foto()   { xcrun simctl io "$D" screenshot "$OUT/$1" >/dev/null 2>&1; echo "[$(hora)] foto $1"; }
# rolagem SEM "duration" nos pontos
# os pontos do meio vão por printf: o `bc` escreve ".666" sem o zero, o JSON sai
# inválido e o gesto morre calado — foi o que deixou o primeiro filme sem rolar
rolar()  { M1=$(perl -e "printf '%.3f', $1-($1-$2)/3"); M2=$(perl -e "printf '%.3f', $1-2*($1-$2)/3")
           orca emulator gesture --points "[{\"type\":\"begin\",\"x\":0.5,\"y\":$1},{\"type\":\"move\",\"x\":0.5,\"y\":$M1},{\"type\":\"move\",\"x\":0.5,\"y\":$M2},{\"type\":\"end\",\"x\":0.5,\"y\":$2}]" --device "$D" >/dev/null 2>&1; echo "[$(hora)] rolar $1→$2"; }
Y=0.947; CAL=0.330; PAD=0.510; PERFIL=0.689
CONTA=0.174; QUEM_ABERTA=0.467; QUEM_FECHADA=0.235; LISTA_X=0.103; LISTA_Y=0.796

pkill -f "serve-sim.*$D" 2>/dev/null && espera 2
orca emulator attach "$D" --json >/dev/null 2>&1 || { echo "attach FALHOU"; exit 1; }
xcrun simctl ui "$D" content_size large
echo "[$(hora)] tamanho: $(xcrun simctl ui "$D" content_size)"
xcrun simctl install "$D" "$APP" || exit 3
INST="$(xcrun simctl get_app_container "$D" $BID app)/Traco"
cmp -s "$INST" "$APP/Traco" && echo "[$(hora)] cmp: binario instalado e o meu" || { echo "cmp: DIFERENTE"; exit 3; }
# o filme devolve as seções ao estado em que as achou: Conta fecha e abre, Quem
# responde abre e fecha — a corrida seguinte começa do desenho de fábrica
xcrun simctl launch --terminate-running-process "$D" $BID >/dev/null 2>&1
espera 3
tocar 0.02 0.5 "puxador do arquivo"; espera 2
tocar $PERFIL $Y perfil; espera 2

xcrun simctl io "$D" recordVideo --codec h264 -f "$OUT/sistema-15s-large.mp4" >/dev/null 2>&1 & VID=$!
T0=$(perl -MTime::HiRes=time -e 'printf "%.2f", time')
espera 1.0
tocar 0.5 $CONTA "recolhe Conta"; espera 1.1
tocar 0.5 $QUEM_FECHADA "abre Quem responde"; espera 1.4
tocar 0.5 $QUEM_FECHADA "recolhe Quem responde"; espera 0.8
tocar 0.5 $CONTA "abre Conta"; espera 0.9
# 0,10 de tela leva aos interruptores (o arrasto rende várias vezes, memória)
rolar 0.70 0.60; espera 1.5
tocar $PAD $Y padroes; espera 1.6
tocar $CAL $Y calendario; espera 1.0
tocar $LISTA_X $LISTA_Y "calendario em lista"; espera 2.8
kill -INT $VID 2>/dev/null; wait $VID 2>/dev/null
T1=$(perl -MTime::HiRes=time -e 'printf "%.2f", time')
echo "[$(hora)] parede: $(echo "$T1 - $T0" | bc) s"
foto 05-calendario-lista.png
# O recordVideo só grava quadro quando a tela MUDA: a tela parada no fim não entra,
# e o relógio dele ainda estica (memória). Segura o último quadro (a tela estava
# mesmo parada) e corta nos 15 s exatos, reencodando.
ffmpeg -v error -y -i "$OUT/sistema-15s-large.mp4" -vf "fps=60,tpad=stop_mode=clone:stop_duration=3" -t 15 \
  -c:v libx264 -pix_fmt yuv420p -crf 20 "$OUT/tmp.mp4" && mv "$OUT/tmp.mp4" "$OUT/sistema-15s-large.mp4"
echo "[$(hora)] duração: $(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT/sistema-15s-large.mp4") s"
