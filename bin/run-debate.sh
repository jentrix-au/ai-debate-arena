#!/usr/bin/env bash
# Launch all debate sessions + dashboard in parallel.
#   ./bin/run-debate.sh <slug> [--dry-run] [--configure]
#
# Casting (which engine/model plays which role) lives in debates/<slug>/run.conf.
# On an interactive launch you get a one-line prompt: Enter (or 5s timeout) keeps
# run.conf exactly as is (manual edits respected); 'c' opens a per-role model
# dialog whose choices are written back into run.conf. --configure forces the
# dialog; non-interactive runs never prompt.
#
# Engines: claude | codex | ollama  (ollama = local model via `codex --oss`,
# requires `ollama serve` running and the model pulled).
#
# Launch targets:
#   - tmux installed      → one tmux session, 4 tiled panes (dashboard, M, A, B)
#   - macOS w/o tmux      → 4 Terminal.app windows
#   - otherwise / dry-run → prints the commands to run manually
#
# Claude Code prompt-injection note: `claude "prompt"` is documented to start the
# REPL with the prompt, but a known race can leave the REPL idle (and a first-run
# trust dialog can swallow the queued prompt). So: in tmux, claude starts WITHOUT
# the prompt and we type it through the pty once the REPL is ready (auto-accepting
# a trust dialog); in Terminal.app the positional prompt is kept and also copied
# to the clipboard (recovery = ⌘V + Enter). Codex/ollama ingest positional
# prompts reliably.
#
# Safe to re-run mid-debate: agents re-derive state from STATE.md + exchange/.
set -euo pipefail

slug=''; dry=0; configure=0
for arg in "$@"; do
  case "$arg" in
    --dry-run)   dry=1 ;;
    --configure) configure=1 ;;
    -*)          echo "unknown flag: $arg"; exit 1 ;;
    *)           slug="$arg" ;;
  esac
done
[ -n "$slug" ] || { echo "usage: run-debate.sh <slug> [--dry-run] [--configure]"; exit 1; }

root="$(cd "$(dirname "$0")/.." && pwd)"
d="$root/debates/$slug"
conf="$d/run.conf"
[ -f "$conf" ]      || { echo "ERROR: $conf not found (copy templates/run.conf.template)"; exit 1; }

# Re-init run state if missing (fresh clone: exchange/output/human/STATE.md are
# gitignored as potentially personal — recreate empty scaffolding).
if [ ! -f "$d/STATE.md" ]; then
  echo "No STATE.md — initializing fresh run state for '$slug' (cloned repo?)."
  mkdir -p "$d/exchange" "$d/human" "$d/output"
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
  [ -f "$d/human/INBOX.md" ] || cat > "$d/human/INBOX.md" <<'EOF'
# HUMAN INBOX
Drop notes here anytime; the moderator reads this at every gate.
Prefix a line with `DIRECTIVE:` to make it binding. Anything else is advisory.
EOF
fi

# defaults, overridden by run.conf
A_ENGINE=codex;  A_MODEL=gpt-5.5; A_FLAGS=''
B_ENGINE=claude; B_MODEL=opus;    B_FLAGS=''
M_ENGINE=claude; M_MODEL=opus;    M_FLAGS=''
CLAUDE_COMMON_FLAGS='--permission-mode acceptEdits'
CODEX_COMMON_FLAGS='--sandbox workspace-write'
MATERIALS_DIRS=''
DASH_PORT=8787
# shellcheck disable=SC1090
source "$conf"

casting_line() {
  echo "M=$M_ENGINE/$M_MODEL  A=$A_ENGINE/$A_MODEL  B=$B_ENGINE/$B_MODEL"
}

# ── casting dialog ──────────────────────────────────────────────────────────
choose_role() { # $1 label  $2 var prefix (M|A|B)   → may update <P>_ENGINE/MODEL/FLAGS
  local p="$2" cur_e cur_m cur_f c
  eval "cur_e=\$${p}_ENGINE; cur_m=\$${p}_MODEL; cur_f=\$${p}_FLAGS"
  echo ""
  echo "── $1 — current: $cur_e / $cur_m ${cur_f:+($cur_f)}"
  echo "   1) claude  opus              2) claude  sonnet         3) claude  haiku"
  echo "   4) codex   gpt-5.5 (xhigh)   5) codex   gpt-5.5        6) ollama  local model (codex --oss)"
  echo "   7) custom  (engine/model/flags)"
  printf "   Enter) keep current.  choice: "
  read -r c || c=''
  case "$c" in
    1) printf -v "${p}_ENGINE" claude; printf -v "${p}_MODEL" opus;   printf -v "${p}_FLAGS" '' ;;
    2) printf -v "${p}_ENGINE" claude; printf -v "${p}_MODEL" sonnet; printf -v "${p}_FLAGS" '' ;;
    3) printf -v "${p}_ENGINE" claude; printf -v "${p}_MODEL" haiku;  printf -v "${p}_FLAGS" '' ;;
    4) printf -v "${p}_ENGINE" codex;  printf -v "${p}_MODEL" gpt-5.5
       printf -v "${p}_FLAGS" '%s' '-c model_reasoning_effort="xhigh"' ;;
    5) printf -v "${p}_ENGINE" codex;  printf -v "${p}_MODEL" gpt-5.5; printf -v "${p}_FLAGS" '' ;;
    6) printf "   ollama model (e.g. llama3.3, qwen2.5-coder:32b): "
       read -r m; [ -n "$m" ] || { echo "   (empty — keeping current)"; return 0; }
       printf -v "${p}_ENGINE" ollama; printf -v "${p}_MODEL" '%s' "$m"; printf -v "${p}_FLAGS" ''
       echo "   note: requires 'ollama serve' running and 'ollama pull $m' done." ;;
    7) printf "   engine [claude|codex|ollama]: "; read -r e
       case "$e" in claude|codex|ollama) ;; *) echo "   (invalid — keeping current)"; return 0 ;; esac
       printf "   model: "; read -r m; [ -n "$m" ] || { echo "   (empty — keeping current)"; return 0; }
       printf "   extra flags (Enter for none): "; read -r f
       printf -v "${p}_ENGINE" '%s' "$e"; printf -v "${p}_MODEL" '%s' "$m"; printf -v "${p}_FLAGS" '%s' "$f" ;;
    '') ;;  # keep
    *) echo "   (unrecognized — keeping current)" ;;
  esac
  conf_dirty=1
}

save_conf() { # rewrite role keys in run.conf, preserving everything else
  RC_SET="$(printf 'M_ENGINE\x1e%s\x1fM_MODEL\x1e%s\x1fM_FLAGS\x1e%s\x1fA_ENGINE\x1e%s\x1fA_MODEL\x1e%s\x1fA_FLAGS\x1e%s\x1fB_ENGINE\x1e%s\x1fB_MODEL\x1e%s\x1fB_FLAGS\x1e%s' \
    "$M_ENGINE" "$M_MODEL" "$M_FLAGS" "$A_ENGINE" "$A_MODEL" "$A_FLAGS" "$B_ENGINE" "$B_MODEL" "$B_FLAGS")" \
  python3 - "$conf" <<'PY'
import os, re, shlex, sys
path = sys.argv[1]
pairs = [kv.split("\x1e", 1) for kv in os.environ["RC_SET"].split("\x1f")]
text = open(path, encoding="utf-8").read()
for key, val in pairs:
    line = key + "=" + shlex.quote(val)   # shlex.quote('') == "''"
    pat = re.compile(rf"^{re.escape(key)}=.*$", re.M)
    if pat.search(text):
        text = pat.sub(line.replace("\\", "\\\\"), text, count=1)
    else:
        text += "\n" + line + "\n"
open(path, "w", encoding="utf-8").write(text)
print(f"updated {path}")
PY
}

conf_dirty=0
if [ "$configure" = 1 ]; then
  echo "Casting for '$slug': $(casting_line)"
  choose_role "Moderator"  M
  choose_role "Advocate A" A
  choose_role "Advocate B" B
elif [ -t 0 ] && [ "$dry" = 0 ]; then
  echo "Casting: $(casting_line)"
  printf "Enter = launch as configured (5s default) · c = change models: "
  ans=''; read -r -t 5 ans || true; echo
  if [ "$ans" = c ] || [ "$ans" = C ]; then
    choose_role "Moderator"  M
    choose_role "Advocate A" A
    choose_role "Advocate B" B
  fi
fi
if [ "$conf_dirty" = 1 ]; then
  save_conf
  echo "New casting: $(casting_line)"
fi

# ── command construction ────────────────────────────────────────────────────
prompt_for() { echo "Read prompts/START-$1.md and follow it exactly."; }

build_cmd() { # $1 role-suffix  $2 engine  $3 model  $4 role-flags  $5 with_prompt(0|1)
  local p; p="$(prompt_for "$1")"
  case "$2" in
    claude)
      local add=''
      for m in $MATERIALS_DIRS; do add+=" --add-dir $m"; done
      if [ "$5" = 1 ]; then echo "claude --model $3 $CLAUDE_COMMON_FLAGS$add $4 \"$p\""
      else echo "claude --model $3 $CLAUDE_COMMON_FLAGS$add $4"; fi ;;
    codex)
      echo "codex $CODEX_COMMON_FLAGS --model $3 $4 \"$p\"" ;;
    ollama)
      echo "codex --oss $CODEX_COMMON_FLAGS --model $3 $4 \"$p\"" ;;
    *) echo "echo 'ERROR: unknown engine $2 (use claude|codex|ollama)'; read -r" ;;
  esac
}

mkdir -p "$d/.run"
gen() { # $1 name  $2 command  $3 clipboard-prompt ('' = none)
  {
    echo '#!/usr/bin/env bash'
    echo "cd \"$d\""
    echo "echo \"▶ $1\""
    if [ -n "$3" ] && command -v pbcopy >/dev/null 2>&1; then
      printf 'printf %%s %q | pbcopy\n' "$3"
      echo "echo \"   prompt copied to clipboard — if the session comes up idle: ⌘V then Enter\""
    fi
    echo "exec $2"
  } > "$d/.run/$1.command"
  chmod +x "$d/.run/$1.command"
}

for spec in "moderator MODERATOR M" "advocate-a ADVOCATE-A A" "advocate-b ADVOCATE-B B"; do
  set -- $spec; name=$1; suffix=$2; r=$3
  eng_var="${r}_ENGINE"; mod_var="${r}_MODEL"; flg_var="${r}_FLAGS"
  cmd="$(build_cmd "$suffix" "${!eng_var}" "${!mod_var}" "${!flg_var}" 1)"
  clip=''; [ "${!eng_var}" = claude ] && clip="$(prompt_for "$suffix")"
  gen "$name" "$cmd" "$clip"
done
gen dashboard "$root/bin/serve.sh $slug $DASH_PORT" ''

URL="http://localhost:$DASH_PORT/dashboard.html?debate=$slug"
echo "Debate: $slug"
echo "  M  ($M_ENGINE/$M_MODEL): $(build_cmd MODERATOR  "$M_ENGINE" "$M_MODEL" "$M_FLAGS" 1)"
echo "  A  ($A_ENGINE/$A_MODEL): $(build_cmd ADVOCATE-A "$A_ENGINE" "$A_MODEL" "$A_FLAGS" 1)"
echo "  B  ($B_ENGINE/$B_MODEL): $(build_cmd ADVOCATE-B "$B_ENGINE" "$B_MODEL" "$B_FLAGS" 1)"
echo "  UI: $URL"
echo

if [ "$dry" = 1 ]; then
  echo "[dry-run] launch scripts written to $d/.run/ — nothing started."
  exit 0
fi

# ── tmux path: claude panes get the prompt typed in via the pty when ready ──
if command -v tmux >/dev/null 2>&1; then
  s="debate-$slug"
  if tmux has-session -t "$s" 2>/dev/null; then
    echo "tmux session '$s' already exists — attaching. (kill it: tmux kill-session -t $s)"
  else
    tmux new-session -d -s "$s" -c "$d" "bash .run/dashboard.command"

    # inject_when_ready <pane> <prompt> — waits for the Claude REPL, auto-accepts a
    # trust dialog, then types the prompt through the pty (same as a human typing).
    inject_when_ready() {
      pane="$1"; p="$2"
      for i in $(seq 1 45); do
        out="$(tmux capture-pane -pt "$pane" 2>/dev/null || true)"
        case "$out" in
          *"Do you trust"*|*"Yes, proceed"*) tmux send-keys -t "$pane" Enter; sleep 2 ;;
          *"? for shortcuts"*)
            tmux send-keys -t "$pane" -l "$p"; sleep 0.4
            tmux send-keys -t "$pane" Enter
            return 0 ;;
        esac
        sleep 1
      done
      tmux display-message "debate: a Claude pane never became ready — paste its prompt manually" 2>/dev/null || true
    }

    for spec in "moderator MODERATOR M" "advocate-a ADVOCATE-A A" "advocate-b ADVOCATE-B B"; do
      set -- $spec; name=$1; suffix=$2; r=$3
      eng_var="${r}_ENGINE"; mod_var="${r}_MODEL"; flg_var="${r}_FLAGS"
      eng="${!eng_var}"
      with_prompt=1; [ "$eng" = claude ] && with_prompt=0
      cmd="$(build_cmd "$suffix" "$eng" "${!mod_var}" "${!flg_var}" "$with_prompt")"
      pane="$(tmux split-window -t "$s" -c "$d" -PF '#{pane_id}' "$cmd")"
      tmux select-pane -t "$pane" -T "$name" 2>/dev/null || true
      tmux select-layout -t "$s" tiled
      if [ "$eng" = claude ]; then
        inject_when_ready "$pane" "$(prompt_for "$suffix")" &
      fi
    done
    tmux set-option -t "$s" pane-border-status top >/dev/null 2>&1 || true
  fi
  ( sleep 2; command -v open >/dev/null && open "$URL" ) >/dev/null 2>&1 &
  if [ -n "${TMUX:-}" ]; then
    echo "Already inside tmux — switch with: tmux switch-client -t $s"
  else
    exec tmux attach -t "$s"
  fi

# ── macOS Terminal path: positional prompt + clipboard fallback ──
elif [ "$(uname)" = "Darwin" ]; then
  open -a Terminal "$d/.run/dashboard.command"
  sleep 1
  open -a Terminal "$d/.run/moderator.command"
  open -a Terminal "$d/.run/advocate-a.command"
  open -a Terminal "$d/.run/advocate-b.command"
  ( sleep 2; open "$URL" ) &
  echo "Opened 4 Terminal windows (dashboard, M, A, B) + browser."
  echo "If a Claude window sits idle: its prompt is on the clipboard — ⌘V then Enter."
  echo "(Tip: 'brew install tmux' makes this fully automatic next time.)"
else
  echo "No tmux and not macOS — run these in 4 terminals:"
  printf '  bash %s/.run/%s.command\n' "$d" dashboard "$d" moderator "$d" advocate-a "$d" advocate-b
fi
