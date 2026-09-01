#!/bin/bash
# Roda um conjunto de fluxos sob CONDIÇÕES DE APARELHO que a varredura normal
# nunca varia: corpo de letra do sistema, aparência clara, contraste aumentado.
# É onde moram os defeitos que só aparecem na mão de quem precisa deles.
#
#   ./maestro/condicoes.sh [fluxo ...]
set -u
cd "$(dirname "$0")/.."
M=~/bin/maestro
FLUXOS=${@:-"maestro/caderno-lista.yaml maestro/notas-e-recordar.yaml maestro/perfil.yaml maestro/padroes.yaml maestro/forma-folha.yaml"}

restaurar() {
    xcrun simctl ui booted content_size medium >/dev/null 2>&1
    xcrun simctl ui booted appearance dark >/dev/null 2>&1
    xcrun simctl ui booted increase_contrast disabled >/dev/null 2>&1
}
trap restaurar EXIT

roda() {
    local rotulo="$1"; shift
    local falhas=""
    for f in $FLUXOS; do
        $M test "$f" >/dev/null 2>&1 || falhas="$falhas $(basename $f .yaml)"
    done
    printf "%-28s %s\n" "$rotulo" "${falhas:-ok}"
}

echo "--- condições de aparelho ---"

xcrun simctl ui booted content_size accessibility-extra-extra-extra-large >/dev/null 2>&1
roda "corpo XXXL"

xcrun simctl ui booted content_size extra-small >/dev/null 2>&1
roda "corpo XS"

xcrun simctl ui booted content_size medium >/dev/null 2>&1
xcrun simctl ui booted appearance light >/dev/null 2>&1
roda "aparência clara"

xcrun simctl ui booted appearance dark >/dev/null 2>&1
xcrun simctl ui booted increase_contrast enabled >/dev/null 2>&1
roda "contraste aumentado"

restaurar
echo "--- fim ---"
