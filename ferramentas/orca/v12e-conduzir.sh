#!/bin/bash
# uso: conduzir.sh <UDID> <pasta-saida> <nome> — acompanha UM caso do XCUITest: fotografa em cada fase e filma "Abrir os campos"
# V12-F: `falhou.pronto` (escrito pelo teste com o motivo dentro) encerra a condução na hora, com o motivo na saída.
U=$1; S=$2; N=$3; P=/tmp/v12e
rm -rf $P; mkdir -p $P
espera() {
  for i in $(seq 1 900); do
    [ -f $P/$1.pronto ] && return 0
    [ -f $P/falhou.pronto ] && { echo "PRÉ-CONDIÇÃO falhou antes de '$1': $(cat $P/falhou.pronto)"; xcrun simctl io $U screenshot $S/v12e-$N-falhou.png >/dev/null 2>&1; return 1; }
    sleep 0.2
  done; echo "sem sinal $1"; return 1
}
segue() { touch $P/$1.segue; }
espera digitado || exit 1
for i in 1 2 3 4; do xcrun simctl io $U screenshot $S/v12e-$N-digitado-$i.png >/dev/null 2>&1; sleep 0.35; done; segue digitado
espera fim || exit 1
for i in 1 2 3 4; do xcrun simctl io $U screenshot $S/v12e-$N-fim-$i.png >/dev/null 2>&1; sleep 0.35; done; segue fim
espera meio || exit 1
for i in 1 2 3 4; do xcrun simctl io $U screenshot $S/v12e-$N-meio-$i.png >/dev/null 2>&1; sleep 0.35; done; segue meio
if [ -f $P/sem-cartao.pronto ] || { sleep 1; [ -f $P/sem-cartao.pronto ]; }; then
  xcrun simctl io $U screenshot $S/v12e-$N-sem-cartao.png >/dev/null 2>&1; segue sem-cartao
  echo "condução $N concluída (caso sem cartão)"; exit 0
fi
espera gravar || exit 1
xcrun simctl io $U recordVideo --codec h264 --force $S/v12e-$N-abrir.mp4 > $S/rec-$N.log 2>&1 &
REC=$!; sleep 2; segue gravar
espera aberto; R=$?; sleep 1; kill -INT $REC; wait $REC 2>/dev/null
xcrun simctl io $U screenshot $S/v12e-$N-folha.png >/dev/null 2>&1; segue aberto
[ $R -eq 0 ] && echo "condução $N concluída" || { echo "condução $N: a folha não abriu"; exit 1; }
