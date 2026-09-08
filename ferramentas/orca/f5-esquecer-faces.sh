#!/bin/bash
# Faz o simulador ESQUECER as faces já desenhadas (F5, lição de instrumento).
#
# O `chronod` guarda em `Library/chronod/chrono.sql` o DESENHO PRONTO de cada
# entrada, não só a linha do tempo. Depois de instalar um build novo, matar o
# chronod e o SpringBoard NÃO basta: ele restaura o desenho do disco, e a casa
# volta a mostrar o código velho (visto na tela, 08/09: o médio insistia nos
# atalhos que este branch já tinha apagado, com o binário instalado sem eles).
# Apagar o banco com o aparelho DESLIGADO é o que força o redesenho.
#
# Uso: f5-esquecer-faces.sh <UDID>   (deixa o aparelho ligado e replanta)
set -e
U="$1"
D="$HOME/Library/Developer/CoreSimulator/Devices/$U/data"
xcrun simctl shutdown "$U" 2>/dev/null || true
sleep 3
rm -rf "$D/Library/chronod" "$D/Library/Caches/com.apple.chronod" "$D/Library/Caches/com.apple.chrono"
xcrun simctl boot "$U"
xcrun simctl bootstatus "$U" -b >/dev/null   # espera o boot de verdade, não o relógio
echo "faces esquecidas"
