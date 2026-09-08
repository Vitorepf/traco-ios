#!/bin/bash
# Um toque no MEU simulador, sem maestro e sem chute de coordenada.
#
# A janela do aparelho é achada pelo NOME (nunca por posição), e o retângulo da
# TELA vem do próprio acessibility da janela (o `AXGroup` de 393×854 = a tela
# de 402×874 pt escalada). Fração da tela → ponto do Mac. Com quatro janelas
# abertas, é isto que impede o toque de cair no vizinho.
#
# Uso: f5-tocar.sh <nome-da-janela> <fx> <fy> [ms-segurando]
set -e
NOME="$1"; FX="$2"; FY="$3"; MS="${4:-150}"
osascript -e "tell application \"System Events\" to tell process \"Simulator\" to perform action \"AXRaise\" of (first window whose name contains \"$NOME\")"
osascript -e 'tell application "Simulator" to activate'
sleep 1
read -r X Y W H < <(osascript <<OSA
tell application "System Events" to tell process "Simulator"
  set g to first UI element of (first window whose name contains "$NOME") whose role is "AXGroup"
  set p to position of g
  set s to size of g
  return ((item 1 of p) as string) & " " & ((item 2 of p) as string) & " " & ((item 1 of s) as string) & " " & ((item 2 of s) as string)
end tell
OSA
)
PX=$(python3 -c "print(int($X + $FX * $W))")
PY=$(python3 -c "print(int($Y + $FY * $H))")
cliclick m:$PX,$PY w:200 dd:$PX,$PY w:$MS du:$PX,$PY
echo "toque em ($FX,$FY) -> $PX,$PY (tela $X,$Y ${W}x${H})"
