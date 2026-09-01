#!/bin/bash
# Varredura E2E com o aparelho GARANTIDO.
#
# Em 01/set uma noite inteira de vereditos saiu errada porque havia DOIS
# simuladores booted: o maestro escolheu um por conta própria (iPhone 17 Pro) e
# os `simctl install` iam para o outro (iPhone 17). O maestro rodava contra uma
# cópia velha do app — telas antigas nas capturas, falhas que não existiam,
# correções que "não pegavam". Este roteiro recusa rodar nessa condição.
#
#   ./maestro/varrer.sh              # tudo
#   ./maestro/varrer.sh maestro/x.yaml ...
set -u
cd "$(dirname "$0")/.."

BOOTED=$(xcrun simctl list devices booted | grep -c "(Booted)")
if [ "$BOOTED" -ne 1 ]; then
    echo "PARADO: $BOOTED simuladores booted — o maestro escolhe um e o install vai para outro."
    xcrun simctl list devices booted
    echo "Desligue os extras: xcrun simctl shutdown <UDID>"
    exit 2
fi

APP=build/Build/Products/Debug-iphonesimulator/Traço.app
if [ ! -d "$APP" ]; then
    echo "PARADO: não há build em $APP"
    exit 2
fi
xcrun simctl install booted "$APP" || exit 2

FLUXOS=${@:-$(ls maestro/*.yaml maestro/cenarios/*.yaml)}
FALHAS=""
for f in $FLUXOS; do
    ~/bin/maestro test "$f" >/dev/null 2>&1 || FALHAS="$FALHAS $(basename $f .yaml)"
done
echo "--- varredura ---"
echo "FALHAS:${FALHAS:- nenhuma}"
