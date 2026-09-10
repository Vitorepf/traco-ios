#!/bin/bash
# Serializa build, teste e maestro entre workers: só um por vez na máquina.
# Uso: ferramentas/orca/com-trava.sh xcodebuild ...   |   com-trava.sh ./maestro/varrer.sh ...
# 10/09 (ADR 10g): `TRAVA` escolhe a trava. A ordem das 12h40 manda as janelas
# de IA correrem em PARALELO, "cada uma com a trava do próprio UDID", e a
# `lote-ia-09d-janela.sh` já lia `TRAVA` para manter a dela fresca — mas aqui o
# caminho era fixo, então quem seguia a ordem segurava uma trava e mantinha
# fresca OUTRA. Sem argumento, nada muda: build e suíte continuam na global.
L="${TRAVA:-/tmp/traco-instrumento.lock}"
# Trava velha demais é trava órfã: em 06/09 um driver do maestro pendurou e
# segurou o instrumento por 50 min com seis workers parados atrás. Nada legítimo
# aqui passa de 30 min (a suíte integral leva ~8 s, o build alguns minutos).
until mkdir "$L" 2>/dev/null; do
  # A primitiva é `mkdir`, então a trava TEM de ser um diretório. Em 10/09 ela
  # virou um arquivo comum de 0 byte e dois workers giraram sem poder entrar:
  # `mkdir` falha para sempre, e sem `$L/dono` a guarda de PID também cega.
  # Só a de 30 min salvava — meia hora de instrumento parado. Isto custa 2 linhas.
  if [ -e "$L" ] && [ ! -d "$L" ]; then
    echo "com-trava: a trava virou ARQUIVO; removendo para destravar" >&2
    rm -f "$L"; continue
  fi
  D=$(head -1 "$L/dono" 2>/dev/null | awk '{print $2}')
  if [ -n "$D" ] && ! kill -0 "$D" 2>/dev/null; then
    echo "com-trava: dono $D morreu sem soltar a trava — retomando" >&2
    rm -rf "$L"; continue
  fi
  if [ -n "$(find "$L" -maxdepth 0 -mmin +30 2>/dev/null)" ]; then
    echo "com-trava: trava presa há mais de 30 min por '$(cat "$L/dono" 2>/dev/null)' — retomando" >&2
    rm -rf "$L"; continue
  fi
  sleep 5
done
{ echo "pid $$"; echo "$*"; date; } > "$L/dono" 2>/dev/null
trap 'rm -rf "$L"' EXIT
"$@"
