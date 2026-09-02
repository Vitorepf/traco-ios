#!/bin/bash
# Roda um conjunto de fluxos sob CONDIÇÕES DE APARELHO que a varredura normal
# nunca varia: corpo de letra do sistema, aparência clara, contraste aumentado.
# É onde moram os defeitos que só aparecem na mão de quem precisa deles.
#
#   ./maestro/condicoes.sh [fluxo ...]
set -u
cd "$(dirname "$0")/.."

# a mesma lei do varrer.sh: com dois simuladores o veredito sai falso
BOOTED=$(xcrun simctl list devices booted | grep -c "(Booted)")
if [ "$BOOTED" -ne 1 ]; then
    echo "PARADO: $BOOTED simuladores booted — desligue os extras: xcrun simctl shutdown <UDID>"
    exit 2
fi
UDID=$(xcrun simctl list devices booted | grep -oE '[0-9A-F-]{36}' | head -1)
M=("$HOME/bin/maestro" --udid "$UDID")
if [ $# -gt 0 ]; then FLUXOS=("$@"); else FLUXOS=(maestro/caderno-lista.yaml maestro/notas-e-recordar.yaml maestro/perfil.yaml maestro/padroes.yaml maestro/forma-folha.yaml); fi
LOGS=/tmp/traco-verify/condicoes
mkdir -p "$LOGS"
TOTAL=0

restaurar() {
    xcrun simctl ui booted content_size medium >/dev/null 2>&1
    xcrun simctl ui booted appearance dark >/dev/null 2>&1
    xcrun simctl ui booted increase_contrast disabled >/dev/null 2>&1
}
trap restaurar EXIT

roda() {
    local rotulo="$1"; shift
    local falhas=""
    for f in "${FLUXOS[@]}"; do
        local nome
        nome=$(basename "$f" .yaml)
        "${M[@]}" test "$f" > "$LOGS/$rotulo-$nome.log" 2>&1 || { falhas="$falhas $nome"; TOTAL=$((TOTAL + 1)); }
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
echo "--- fim: $TOTAL falha(s); logs em $LOGS ---"
[ "$TOTAL" -eq 0 ]
