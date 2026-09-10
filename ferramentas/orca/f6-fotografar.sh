#!/bin/bash
# F6: uma captura da TELA BLOQUEADA, dada por boa só quando o texto esperado
# está nela (OCR por f5-ler). Tranca conferindo pela árvore (button lock numa
# tela já trancada destranca). Uso: f6-fotografar.sh <UDID> <saida.png> <texto> [vezes]
# Espera-se TRAVA_MINHA=1 (o chamador segura a trava) — cada ação passa por f5b-emu.sh.
set -e
U="$1"; SAIDA="$2"; TEXTO="$3"; VEZES="${4:-1}"
AQUI="$(cd "$(dirname "$0")" && pwd)"; EMU="$AQUI/f5b-emu.sh"
LER="${TMPDIR:-/tmp}/f5-ler"; [ "$LER" -nt "$AQUI/f5-ler.swift" ] || swiftc -O -o "$LER" "$AQUI/f5-ler.swift"
trancada() { "$EMU" "$U" ax 2>/dev/null | grep -q "Passe o dedo para cima para desbloquear"; }
xcrun simctl terminate "$U" app.traco 2>/dev/null || true
for _ in 1 2 3; do
  trancada && break
  "$EMU" "$U" button home >/dev/null; sleep 1.5; "$EMU" "$U" button lock >/dev/null; sleep 3
done
trancada || { echo "f6-fotografar: não trancou" >&2; exit 1; }
T0=$(date +%s); QUADRO="${SAIDA%.png}.nao-pronta.png"
while :; do
  xcrun simctl io "$U" screenshot "$QUADRO" >/dev/null 2>&1 || { sleep 2; continue; }
  N=$("$LER" "$QUADRO" | tr '\n' ' ' | tr -s ' ' | grep -o -F -i -- "$TEXTO" | wc -l | tr -d ' ')
  if [ "$N" -ge "$VEZES" ]; then mv "$QUADRO" "$SAIDA"; echo "$(date +%H:%M:%S)  $SAIDA — '$TEXTO' ×$N em $(( $(date +%s) - T0 )) s"; exit 0; fi
  [ $(( $(date +%s) - T0 )) -ge 60 ] && { echo "f6-fotografar: '$TEXTO' não apareceu em 60 s; último quadro em $QUADRO — não é evidência" >&2; exit 1; }
  sleep 3
done
