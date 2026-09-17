#!/bin/bash
# Roda um conjunto de fluxos sob CONDIÇÕES DE APARELHO que a varredura normal
# nunca varia: corpo de letra do sistema, aparência clara, contraste aumentado.
# É onde moram os defeitos que só aparecem na mão de quem precisa deles.
#
#   ./maestro/condicoes.sh [fluxo ...]
set -u
cd "$(dirname "$0")/.."
# O aparelho pode ser DITO (TRACO_SIM): a máquina tem o Air da conta e o
# simulador da suíte ligados ao lado (17/09).
ALVO=${TRACO_SIM:-booted}
M="$HOME/bin/maestro ${TRACO_SIM:+--udid $TRACO_SIM}"
FLUXOS=${@:-"maestro/caderno-lista.yaml maestro/notas-e-recordar.yaml maestro/perfil.yaml maestro/padroes.yaml"}

restaurar() {
    xcrun simctl ui booted content_size large >/dev/null 2>&1
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

# DIRETRIZ §12 (10/09): tamanhos de letra de acessibilidade estão PROIBIDOS — só large.
xcrun simctl ui booted content_size large >/dev/null 2>&1
xcrun simctl ui booted appearance light >/dev/null 2>&1
roda "aparência clara"

xcrun simctl ui booted appearance dark >/dev/null 2>&1
xcrun simctl ui booted increase_contrast enabled >/dev/null 2>&1
roda "contraste aumentado"

restaurar
echo "--- fim ---"
