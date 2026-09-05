#!/bin/bash
# ADR 2026-09-04p — a entrada do Mac, provada no simulador: planta um .md em
# Documents/Traço/entrada e um método em Documents/Traço/metodos, relança o
# app e confere que a nota entrou e o método está no catálogo.
#
#   ./maestro/entrada-do-mac.sh
set -u
cd "$(dirname "$0")/.."
M=~/bin/maestro
xcrun simctl spawn booted launchctl setenv TRACO_SEM_MODELO 1
# um arranque limpo cria o contêiner
$M test maestro/launch-vazio.yaml >/dev/null 2>&1
C=$(xcrun simctl get_app_container booted app.traco data)
mkdir -p "$C/Documents/Traço/entrada" "$C/Documents/Traço/metodos"
cat > "$C/Documents/Traço/entrada/do-mac.md" <<'MD'
---
criada: 2026-09-04T10:00:00Z
gesto: Leitura
---

li que a atenção é finita e o autor defende que ela se treina
MD
cat > "$C/Documents/Traço/metodos/cornell.json" <<'JSON'
{"id":"cornell","nome":"Cornell","origem":"Walter Pauk","campos":[{"id":"pistas","rotulo":"Pistas"},{"id":"notas","rotulo":"Notas"},{"id":"resumo","rotulo":"Resumo, nas minhas palavras"}],"roteamento":["\\bcornell\\b"],"movimento":"Cornell: pistas à esquerda, notas à direita, resumo embaixo. O passo que se pula é o resumo nas próprias palavras.","pergunta":"E o resumo, nas suas palavras?","reconhecimento":"isto é uma anotação de aula que pede Cornell.","filtro":"Cornell"}
JSON
$M test maestro/entrada-do-mac.yaml && echo "entrada: ok" || { echo "entrada: FALHOU"; exit 1; }
