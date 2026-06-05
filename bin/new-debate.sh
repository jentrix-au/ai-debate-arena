#!/usr/bin/env bash
# Scaffold a new debate: ./bin/new-debate.sh <slug>
set -euo pipefail

slug="${1:?usage: new-debate.sh <slug>   e.g. new-debate.sh 2026-07-01-api-redesign}"
root="$(cd "$(dirname "$0")/.." && pwd)"
d="$root/debates/$slug"

[ -e "$d" ] && { echo "ERROR: $d already exists" >&2; exit 1; }

mkdir -p "$d/exchange" "$d/human" "$d/output" "$d/prompts"
cp "$root/PROTOCOL.md" "$d/PROTOCOL.md"
cp "$root/templates/DEBATE-CONFIG.template.md" "$d/DEBATE-CONFIG.md"
cp "$root/templates/run.conf.template" "$d/run.conf"
cp "$root"/prompts/START-*.md "$d/prompts/"

cat > "$d/STATE.md" <<'EOF'
# DEBATE STATE — single writer: MODERATOR
phase: 0
phase_name: setup
status: awaiting-moderator
awaiting_files:
  - exchange/P0-M-brief.md
notes_for_participants: Debate not started. Moderator boots first.
extension_phases_used: 0 of 5
gate_log: []
EOF

cat > "$d/human/INBOX.md" <<'EOF'
# HUMAN INBOX
Drop notes here anytime; the moderator reads this at every gate.
Prefix a line with `DIRECTIVE:` to make it binding. Anything else is advisory.
EOF

cat > "$d/exchange/README.md" <<'EOF'
Debate artifacts land here as P<phase>-<ROLE>-<slug>.md (see ../PROTOCOL.md §3).
A file is delivered only when its last line is `<!-- END <ROLE> P<phase> -->`.
EOF

echo "Created $d"
echo "Next: 1) edit $d/DEBATE-CONFIG.md (topic/sides) and $d/run.conf (models)"
echo "      2) launch everything: ./bin/run-debate.sh $slug"
