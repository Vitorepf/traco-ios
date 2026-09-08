#!/bin/bash
# Uma captura da casa, com o ambiente que a face precisa.
# Uso: f5-fotografar.sh <UDID> <saida.png> [tema] [tamanho]
#   tema: light | dark          tamanho: large | accessibility-extra-extra-extra-large
#
# O `chronod` guarda o tamanho de tipo, o tema E o desenho pronto de cada
# entrada: sem matá-lo ANTES do SpringBoard a face volta do cache, com o
# ambiente velho e às vezes com o código velho (visto na tela, 08/09, quando o
# médio insistiu em mostrar os atalhos que este branch já tinha apagado).
set -e
U="$1"; SAIDA="$2"; TEMA="${3:-light}"; TAM="${4:-large}"
xcrun simctl ui "$U" appearance "$TEMA" >/dev/null
xcrun simctl ui "$U" content_size "$TAM" >/dev/null
sleep 1
xcrun simctl spawn "$U" launchctl kill 9 system/com.apple.chronod 2>/dev/null || true
sleep 2
xcrun simctl spawn "$U" launchctl kill 9 system/com.apple.SpringBoard 2>/dev/null || true
sleep 15
xcrun simctl io "$U" screenshot "$SAIDA" >/dev/null 2>&1
echo "$(date +%H:%M:%S)  $SAIDA  ($TEMA, $TAM)"
