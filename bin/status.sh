#!/usr/bin/env bash
# Show debate state: ./bin/status.sh <slug>   (or run from inside a debate dir with no args)
set -euo pipefail

if [ $# -ge 1 ]; then
  root="$(cd "$(dirname "$0")/.." && pwd)"
  d="$root/debates/$1"
else
  d="$(pwd)"
fi
[ -f "$d/STATE.md" ] || { echo "ERROR: no STATE.md in $d" >&2; exit 1; }

echo "================ STATE ================"
cat "$d/STATE.md"
echo
echo "============== EXCHANGE ==============="
ls -1t "$d/exchange" 2>/dev/null | grep -v '^README.md$' || echo "(empty)"
echo
echo "=============== OUTPUT ================"
ls -1 "$d/output" 2>/dev/null || echo "(empty)"
echo
last="$(ls -1t "$d/exchange" 2>/dev/null | grep -v '^README.md$' | head -1 || true)"
if [ -n "${last:-}" ]; then
  echo "---- tail of latest artifact ($last) ----"
  tail -5 "$d/exchange/$last"
fi
