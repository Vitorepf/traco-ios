#!/bin/bash
# F5b: uma ação do `orca emulator` no MEU aparelho, reatando antes — o helper é
# um só na máquina e outra volta rouba o attach entre duas chamadas (ESTEIRA).
# Tudo sob com-trava.sh; com TRAVA_MINHA=1 o chamador já segura a trava (o
# f5b-filmar.sh a toma uma vez para o filme inteiro, senão cada toque espera a
# suíte de outra volta e o vídeo ganha um minuto parado).
# Uso: f5b-emu.sh <UDID> <subcomando> [args...]
U="$1"; shift
acao() {
  orca emulator attach "$U" --json >/dev/null 2>&1
  orca emulator "$@" --device "$U" --json
}
if [ "${TRAVA_MINHA:-0}" = 1 ]; then acao "$@"; else
  exec "$(dirname "$0")/com-trava.sh" bash -c '
    U="$1"; shift
    orca emulator attach "$U" --json >/dev/null 2>&1
    orca emulator "$@" --device "$U" --json' _ "$U" "$@"
fi
