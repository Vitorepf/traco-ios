#!/bin/bash
# Serializa build, teste e maestro entre workers: só um por vez na máquina.
# Uso: ferramentas/orca/com-trava.sh xcodebuild ...   |   com-trava.sh ./maestro/varrer.sh ...
L=/tmp/traco-instrumento.lock
until mkdir "$L" 2>/dev/null; do sleep 5; done
trap 'rmdir "$L"' EXIT
"$@"
