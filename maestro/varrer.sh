#!/bin/bash
# Varredura E2E com o aparelho GARANTIDO e o build GARANTIDO.
#
# Em 01/set uma noite inteira de vereditos saiu errada porque havia DOIS
# simuladores booted: o maestro escolheu um por conta própria (iPhone 17 Pro) e
# os `simctl install` iam para o outro (iPhone 17). O maestro rodava contra uma
# cópia velha do app — telas antigas nas capturas, falhas que não existiam,
# correções que "não pegavam". Este roteiro recusa rodar nessa condição.
#
# Fotografar um build velho é o mesmo bug, um nível acima (radiografia 02/set):
# por isso o roteiro COMPILA antes de instalar, sempre — e termina com código 1
# quando um fluxo falha, para `&&`, hook e CI conseguirem barrar em cima dele.
#
#   ./maestro/varrer.sh                  # tudo
#   ./maestro/varrer.sh maestro/x.yaml   # um ou mais fluxos
# (quem tem certeza de que build/ é o atual chama `maestro test` direto; o
# roteiro não oferece atalho para o bug que existe para fechar)
set -u
cd "$(dirname "$0")/.."

BOOTED=$(xcrun simctl list devices booted | grep -c "(Booted)")
if [ "$BOOTED" -ne 1 ]; then
    echo "PARADO: $BOOTED simuladores booted — o maestro escolhe um e o install vai para outro."
    xcrun simctl list devices booted
    echo "Desligue os extras: xcrun simctl shutdown <UDID>"
    exit 2
fi
UDID=$(xcrun simctl list devices booted | grep -oE '[0-9A-F-]{36}' | head -1)

APP=build/Build/Products/Debug-iphonesimulator/Traço.app
echo "compilando para $UDID…"
xcodebuild build -project Traco.xcodeproj -scheme Traco \
    -destination "platform=iOS Simulator,id=$UDID" \
    -derivedDataPath build -quiet || { echo "PARADO: o build falhou"; exit 2; }
if [ ! -d "$APP" ]; then
    echo "PARADO: não há build em $APP"
    exit 2
fi
xcrun simctl install "$UDID" "$APP" || exit 2

LOGS=/tmp/traco-verify/varredura
mkdir -p "$LOGS"
if [ $# -gt 0 ]; then FLUXOS=("$@"); else FLUXOS=(maestro/*.yaml maestro/cenarios/*.yaml); fi
FALHAS=()
for f in "${FLUXOS[@]}"; do
    nome=$(basename "$f" .yaml)
    if ~/bin/maestro --udid "$UDID" test "$f" > "$LOGS/$nome.log" 2>&1; then
        echo "ok     $nome"
    else
        echo "FALHA  $nome   (log: $LOGS/$nome.log)"
        FALHAS+=("$nome")
    fi
done
echo "--- varredura ---"
if [ ${#FALHAS[@]} -eq 0 ]; then
    echo "FALHAS: nenhuma"
    exit 0
fi
echo "FALHAS: ${FALHAS[*]}"
exit 1
