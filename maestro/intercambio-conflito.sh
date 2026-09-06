#!/bin/bash
# ADR 2026-09-06a — o conflito na tela, de ponta a ponta e SEM mão no meio.
#
# Um conflito de verdade precisa das duas pontas: a versão que andou no Traço
# (parte 1 escreve) e o MESMO arquivo editado fora (este roteiro escreve, entre
# as duas partes). Um .md intocado nunca é conflito — o corpo é idêntico à
# versão de onde saiu —, e é por isso que o passo do "editor externo" existe.
# Aqui ele é script, não dedo: o fluxo roda inteiro sozinho.
#
# A pasta "No Meu iPhone" do Arquivos NÃO é o contêiner do app: sobrevive ao
# `clearState` e, na segunda passada, o exportador abre "Substituir Itens
# Existentes?" — alerta fora do processo, invisível ao maestro. Por isso a
# limpeza no começo, que também deixa UM item no seletor (tocado por ponto).
#
#   ./maestro/intercambio-conflito.sh [UDID]
set -u
cd "$(dirname "$0")/.."
M=~/bin/maestro
UDID=${1:-$(xcrun simctl list devices booted | sed -n 's/.*(\([0-9A-Fa-f-]\{36\}\)) (Booted).*/\1/p' | head -1)}
[ -n "$UDID" ] || { echo "intercambio conflito: nenhum simulador booted"; exit 2; }
ARQUIVOS="$HOME/Library/Developer/CoreSimulator/Devices/$UDID/data/Containers/Shared/AppGroup"
falhou() { echo "intercambio conflito: FALHOU ($1)"; exit 1; }

xcrun simctl spawn "$UDID" launchctl setenv TRACO_SEM_MODELO 1
find "$ARQUIVOS" -path "*/File Provider Storage/*" -name "traco-versao*.md" -delete 2>/dev/null

$M --device "$UDID" test maestro/intercambio-conflito.yaml || falhou "parte 1"

# O editor externo. A LINHA 1 é o envelope e sai intacta: sem ela o retorno é
# `semVinculo` e não há base para comparar.
MD=$(find "$ARQUIVOS" -path "*/File Provider Storage/*" -name "traco-versao.md" | head -1)
[ -n "$MD" ] || falhou "o .md exportado não apareceu em Arquivos"
T=$(mktemp)
head -1 "$MD" > "$T"
printf 'Versao 1 editada FORA do Traco.\n' >> "$T"
cp "$T" "$MD" || falhou "não consegui reescrever o .md"

$M --device "$UDID" test maestro/partes/intercambio-conflito-volta.yaml || falhou "parte 2"
echo "intercambio conflito: ok"
