#!/bin/bash
# Serializa build, teste e maestro entre workers: só um por vez na máquina.
# Uso: ferramentas/orca/com-trava.sh xcodebuild ...   |   com-trava.sh ./maestro/varrer.sh ...
L=/tmp/traco-instrumento.lock
# Trava velha demais é trava órfã: em 06/09 um driver do maestro pendurou e
# segurou o instrumento por 50 min com seis workers parados atrás. Nada legítimo
# aqui passa de 30 min (a suíte integral leva ~8 s, o build alguns minutos).
until mkdir "$L" 2>/dev/null; do
  if [ -n "$(find "$L" -maxdepth 0 -mmin +30 2>/dev/null)" ]; then
    echo "com-trava: trava presa há mais de 30 min por '$(cat "$L/dono" 2>/dev/null)' — retomando" >&2
    rm -rf "$L"
    continue
  fi
  sleep 5
done
{ echo "pid $$"; echo "$*"; date; } > "$L/dono" 2>/dev/null
trap 'rm -rf "$L"' EXIT
"$@"
