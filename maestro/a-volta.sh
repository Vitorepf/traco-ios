#!/bin/bash
# ADR 2026-09-04v — a volta que cobra, provada em qualquer hora do dia: planta
# um Dia de ONTEM pela entrada (ADR 04p), relança o app e confere que as Notas
# abrem com "O que roubou o dia?" e que o toque leva ao campo.
#
#   ./maestro/a-volta.sh
set -u
cd "$(dirname "$0")/.."
M=~/bin/maestro
xcrun simctl spawn booted launchctl setenv TRACO_SEM_MODELO 1
$M test maestro/launch-vazio.yaml >/dev/null 2>&1
C=$(xcrun simctl get_app_container booted app.traco data)
mkdir -p "$C/Documents/Traço/entrada"
ONTEM=$(date -v-1d +%Y-%m-%dT12:00:00Z)
cat > "$C/Documents/Traço/entrada/dia-de-ontem.md" <<MD
---
criada: $ONTEM
gesto: Dia
---

hoje eu preciso fechar o orçamento; depois responder os e-mails e revisar o texto
MD
$M test maestro/a-volta.yaml && echo "a volta: ok" || { echo "a volta: FALHOU"; exit 1; }
