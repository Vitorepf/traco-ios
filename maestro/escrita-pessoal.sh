#!/bin/bash
# ADR 2026-09-06h (volta A-B) — a escrita pessoal CALA o modelo, provado na
# tela com o degrau de cima LIGADO. O simulador não tem conta xAI nem Apple
# Intelligence, então `TRACO_MODELO_FALSO` (só em DEBUG) põe um modelo de
# mentira no lugar: ele veste QUALQUER nota de WOOP.
#
# Dois fluxos, nesta ordem, e o primeiro é o controle: sem ele o segundo não
# mede nada, porque "nenhum cartão" também é o que se vê com o modelo desligado.
#
#   ./maestro/escrita-pessoal.sh [udid]
set -u
cd "$(dirname "$0")/.."
D=${1:-booted}
M=$(command -v maestro || echo ~/bin/maestro)
xcrun simctl spawn "$D" launchctl setenv TRACO_MODELO_FALSO woop
trap 'xcrun simctl spawn "$D" launchctl unsetenv TRACO_MODELO_FALSO' EXIT
$M --device "$D" test maestro/escrita-pessoal-modelo-veste.yaml \
  && echo "controle (o modelo veste): ok" || { echo "controle: FALHOU"; exit 1; }
$M --device "$D" test maestro/escrita-pessoal-cala-o-modelo.yaml \
  && echo "guarda (o desabafo fica do autor): ok" || { echo "guarda: FALHOU"; exit 1; }
