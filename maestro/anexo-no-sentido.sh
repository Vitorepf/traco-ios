#!/bin/bash
# ADR 2026-09-04y — o anexo entra no sentido: planta um PDF de orçamento em
# Anexos e uma nota pela entrada que só diz "o relatório está no anexo";
# a busca por sentido "reunião de orçamento com finanças" tem de achá-la.
#
#   ./maestro/anexo-no-sentido.sh
set -u
cd "$(dirname "$0")/.."
# O aparelho pode ser DITO (TRACO_SIM): a máquina tem o Air da conta e o
# simulador da suíte ligados ao lado (17/09).
ALVO=${TRACO_SIM:-booted}
M="$HOME/bin/maestro ${TRACO_SIM:+--udid $TRACO_SIM}"
xcrun simctl spawn "$ALVO" launchctl setenv TRACO_SEM_MODELO 1
$M test maestro/launch-vazio.yaml >/dev/null 2>&1
C=$(xcrun simctl get_app_container "$ALVO" app.traco data)
ID=7B1C2D3E-4F50-4A61-B172-83C4D5E6F708
mkdir -p "$C/Documents/Traço/entrada" "$C/Library/Application Support/Traco/Anexos"
T=$(mktemp).txt
echo "Relatório do orçamento trimestral: receita, despesa e caixa da equipe de finanças. A reunião de orçamento confere o trimestre." > "$T"
cupsfilter "$T" > "$C/Library/Application Support/Traco/Anexos/$ID.pdf" 2>/dev/null
cat > "$C/Documents/Traço/entrada/relatorio.md" <<MD
---
criada: 2026-09-04T10:00:00Z
---

o relatório está no anexo

[arquivo:orcamento.pdf](traco://file/$ID)
MD
$M test maestro/anexo-no-sentido.yaml && echo "anexo no sentido: ok" || { echo "anexo no sentido: FALHOU"; exit 1; }
