#!/bin/bash
# Portão mecânico do Traço (auditoria 17/09): o "verde" era declarado à mão e um
# commit que não compilava já entrou em main (4c7e4aa2 conta o 77af1072).
#
#   ferramentas/portao.sh                 compila app + testes e roda a suíte no 17e
#   ferramentas/portao.sh <UDID>          idem, em outro simulador
#   ferramentas/portao.sh --compilar      só compila (sem simulador, sem trava)
#   ferramentas/portao.sh --instalar      instala o pre-commit (vale para todos os worktrees)
#
# O pre-commit só compila, e só quando o commit leva .swift ou project.yml.
# TRACO_SEM_PORTAO=1 git commit … pula (commit só de documento em árvore quebrada).
# ponytail: compila a ÁRVORE do worktree, não o índice — um commit parcial com o
# resto quebrado é recusado à toa; stash do resto se um dia isso incomodar.
set -euo pipefail
RAIZ=$(git rev-parse --show-toplevel)
cd "$RAIZ"
SIM_PADRAO=8A5B6500-D263-4BBE-AEF6-E04DDB0993B0 # iPhone 17e: a suíte roda aqui, nunca no Air da conta
DD="$RAIZ/build-portao"

compilar() {
  command -v xcodegen >/dev/null && xcodegen generate -q
  local log; log=$(mktemp -t portao)
  if ! xcodebuild build-for-testing -project Traco.xcodeproj -scheme Traco \
      -destination 'generic/platform=iOS Simulator' -derivedDataPath "$DD" \
      CODE_SIGNING_ALLOWED=NO >"$log" 2>&1; then
    grep -E '\.swift:[0-9]+:[0-9]+: error|error: ' "$log" | grep -v patternForKey | sort -u | head -20 >&2
    echo "portão: NÃO COMPILA (log em $log)" >&2
    return 1
  fi
  echo "portão: compila"
}

case "${1:-}" in
  --instalar)
    HOOK="$(git rev-parse --git-common-dir)/hooks/pre-commit"
    cat >"$HOOK" <<'EOF'
#!/bin/bash
[ "${TRACO_SEM_PORTAO:-}" = 1 ] && exit 0
git diff --cached --name-only | grep -qE '\.swift$|^project\.yml$' || exit 0
exec "$(git rev-parse --show-toplevel)/ferramentas/portao.sh" --compilar
EOF
    chmod +x "$HOOK"
    echo "portão: pre-commit instalado em $HOOK"
    ;;
  --compilar)
    compilar
    ;;
  *)
    command -v xcodegen >/dev/null && xcodegen generate -q
    UDID="${1:-$SIM_PADRAO}"
    log=$(mktemp -t portao-suite)
    # assinado (o simulador recusa binário sem assinatura: error 163); a trava
    # serializa com as outras voltas; sem paralelo, que pendura com vários simuladores ligados
    "$RAIZ/ferramentas/orca/com-trava.sh" xcodebuild test -project Traco.xcodeproj \
      -scheme Traco -destination "platform=iOS Simulator,id=$UDID" -derivedDataPath "$DD-suite" \
      -parallel-testing-enabled NO >"$log" 2>&1 || true
    grep -E '\.swift:[0-9]+:[0-9]+: error' "$log" | sort -u | head -20 >&2 || true
    # a linha "Test run with N tests" do Swift Testing conta errado quando há
    # teste pulado (711 com 1323 passando, 17/09): a conta vem das linhas
    ok=$(grep -c '✔ Test ' "$log" || true)
    falhas=$(grep -c '✘ Test .* failed' "$log" || true)
    pulados=$(grep -c '➜ Test ' "$log" || true)
    grep -E '✘ Test .* (failed|recorded an issue)' "$log" | head -20 >&2 || true
    if grep -q '\*\* TEST SUCCEEDED \*\*' "$log" && [ "$falhas" = 0 ] && [ "$ok" -gt 0 ]; then
      echo "portão: verde — $ok passaram, $pulados pulados com motivo, 0 falhas"
      exit 0
    fi
    echo "portão: VERMELHO — $ok passaram, $falhas falharam, $pulados pulados (log em $log)"
    exit 1
    ;;
esac
