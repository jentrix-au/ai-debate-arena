#!/usr/bin/env bash
# Serve the debate dashboard: ./bin/serve.sh [slug] [port]
set -euo pipefail
slug="${1:-}"
port="${2:-8787}"
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

# default slug = first debate folder found
if [ -z "$slug" ]; then
  slug="$(ls -1 debates 2>/dev/null | head -1 || true)"
fi

echo "Debate Arena dashboard"
echo "  → http://localhost:${port}/dashboard.html?debate=${slug}"
echo "  (Ctrl+C to stop)"
exec python3 "$root/bin/serve.py" "$port"
