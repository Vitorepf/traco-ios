#!/bin/zsh
set -euo pipefail
UDID=${1:-1A46B6D3-71A6-49C0-BB2C-D73FCD43CABF}
xcrun simctl terminate "$UDID" app.traco >/dev/null 2>&1 || true
sleep 0.3
LOG=$(mktemp)
xcrun simctl spawn "$UDID" log stream --style compact --predicate 'eventMessage CONTAINS "TRACO_PAGINA_PRONTA"' > "$LOG" 2>&1 &
STREAM=$!
sleep 0.4
START=$(python3 -c 'import time; print(time.perf_counter())')
xcrun simctl launch --console "$UDID" app.traco > /tmp/traco-launch-console.txt 2>&1 &
for i in $(seq 1 80); do
  if grep -q TRACO_PAGINA_PRONTA /tmp/traco-launch-console.txt 2>/dev/null || grep -q TRACO_PAGINA_PRONTA "$LOG" 2>/dev/null; then
    python3 -c "import time; print(f'LAUNCH_MS {int((time.perf_counter() - $START) * 1000)}')"
    kill $STREAM 2>/dev/null || true
    sleep 0.35
    xcrun simctl io "$UDID" screenshot /tmp/traco-verify/17-launch.png
    exit 0
  fi
  sleep 0.025
done
kill $STREAM 2>/dev/null || true
echo LAUNCH_TIMEOUT
exit 1
