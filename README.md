# Debate Arena

Moderated AI-vs-AI debate environment ("constructive controversy"). Three independent
CLI agent sessions — **Advocate A**, **Advocate B**, **Moderator** — argue two competing
options through a gated protocol and converge on one signed decision:
`output/UNIFIED-VISION.md` (chosen option + scored rationale + prioritized,
provenance-tagged improvement backlog + dissent register).

The agents coordinate **purely through files** in a shared debate folder — no APIs, no
message bus. Any mix of Claude Code and Codex CLI, any topic: point the config at your
materials, define the two sides, run one command. A live dashboard shows the whole
debate in the browser.

```
debate-arena/
├── README.md                  # you are here
├── PROTOCOL.md                # universal rules: roles, phases, gates, file conventions
├── dashboard.html             # live web UI (served by bin/serve.sh)
├── prompts/START-*.md         # universal role prompts (moderator, advocate A/B)
├── templates/
│   ├── DEBATE-CONFIG.template.md   # topic/sides/materials template
│   └── run.conf.template           # per-role engine/model template
├── bin/
│   ├── new-debate.sh          # scaffold a new debate
│   ├── run-debate.sh          # launch all sessions + dashboard in parallel
│   ├── serve.sh / serve.py    # dashboard server (stdlib-only, localhost)
│   └── status.sh              # CLI peek at any debate's state
└── debates/<slug>/            # one folder per debate
    ├── DEBATE-CONFIG.md       #   what is debated: question, sides, materials (edit)
    ├── run.conf               #   how it runs: engine+model per role, ports (edit)
    ├── PROTOCOL.md            #   frozen copy for this debate
    ├── STATE.md               #   control plane — moderator is sole writer
    ├── prompts/               #   frozen role prompts
    ├── exchange/              #   the debate: P<phase>-<ROLE>-<slug>.md
    ├── human/INBOX.md         #   your channel into the debate
    └── output/                #   UNIFIED-VISION.md lands here
```

## How it works

There is no cross-session message bus — the **moderator is the loop**. It is the sole
writer of `STATE.md`; after every phase it runs a gate and decides **CONTINUE / EXTEND /
FINALIZE / HALT**. Advocates poll `STATE.md` in short `sleep` cycles, act when a file
with their name appears in `awaiting_files`, and wait otherwise. A file counts as
delivered only when it ends with an `<!-- END <ROLE> P<n> -->` marker.

Standard run is 6 gated steps — **P0 brief → P1 positions → P2 rebuttals → P3 forced
steelman → P4 convergence proposals → P5 synthesis with CONCUR/OBJECT sign-off** — and
the moderator may extend to 10 phases total when a promising path emerges. Every factual
claim must cite the source materials (`path §section`); surviving dissent is recorded
verbatim, not erased. Full rules: [PROTOCOL.md](PROTOCOL.md).

## Prerequisites

| What | Why | Install |
|---|---|---|
| macOS or Linux, bash 3.2+ | scripts | — |
| Python 3.8+ (stdlib only) | dashboard server | usually preinstalled |
| [Claude Code CLI](https://code.claude.com/docs) | `claude` sessions | `npm install -g @anthropic-ai/claude-code` |
| [Codex CLI](https://developers.openai.com/codex/cli) | `codex` sessions | `npm install -g @openai/codex` |
| tmux *(optional, recommended)* | one-window launch + auto prompt injection | `brew install tmux` |

You only need the CLIs you actually cast (e.g. an all-Claude debate needs no Codex).

**Authentication is required before first use** — every Claude Code and Codex CLI on
the machine must be authorized or the sessions will fail at launch:

- **Claude Code:** run `claude`; on first launch it opens a browser to log in with your
  Claude.ai account (Pro/Max subscription) or Console API key. For non-interactive
  environments use `claude setup-token`. Re-auth: `/logout` in-session. Docs:
  [Claude Code → Authentication](https://code.claude.com/docs/en/authentication).
- **Codex CLI:** run `codex login`; it opens a browser for the ChatGPT OAuth flow
  (`--device-auth` for headless machines; API-key and access-token sign-in also
  supported). Check with `codex login status`. Docs:
  [Codex → Authentication](https://developers.openai.com/codex/auth).
- **Ollama engine:** no account — just `ollama serve` running and the model pulled.

Subscriptions/plans are whatever your accounts have — models are chosen per debate in
`run.conf`. The dashboard loads `marked.js` from a CDN for markdown rendering; without
internet it degrades to plain-text view.

## Install

```bash
git clone https://github.com/jentrix-au/ai-debate-arena.git
cd ai-debate-arena
chmod +x bin/*.sh        # only needed if the clone lost exec bits
```

No build step, no package install — scripts are bash + Python stdlib.

## Configure a debate

**Easiest — the dashboard wizard:** start the server (`./bin/serve.sh`), open the
dashboard, click **✚ New debate**. Six steps: basics (title/slug/decision question) →
sides (identity, champions, optional extra instructions per side) → materials (absolute
paths with live exists-on-disk validation) → criteria (weights with a Σ=100 check) →
casting (per-role presets incl. ollama) → review of the exact generated files. Finish
with **🚀 Launch sessions now** straight from the browser, or copy the terminal command.
A header dropdown switches between debates.

**Or from the CLI:**

```bash
./bin/new-debate.sh my-topic        # scaffolds debates/my-topic/
```

Edit two files in `debates/my-topic/`:

1. **`DEBATE-CONFIG.md`** — the substance: decision question, source-material paths
   (absolute paths on the machine where sessions run), Side A / Side B identities and
   stances, proposed decision criteria. This is what the agents read.
2. **`run.conf`** — the machinery: per-role `ENGINE` (`claude`|`codex`|`ollama` — the
   latter runs local models via `codex --oss`), `MODEL`, extra flags (e.g.
   `-c model_reasoning_effort="xhigh"`), `MATERIALS_DIRS` (claude gets `--add-dir` for
   each; codex reads them via its sandbox), permission flags, dashboard port. Edit by
   hand or via the casting dialog at launch.

Casting is free: any role on either CLI/model. Same model on both sides removes
capability asymmetry; mixed models sharpen the clash.

**Privacy note:** debate *run artifacts* (`exchange/`, `output/`, `human/`, `STATE.md`)
are gitignored — they can quote your private source materials. Only debate
*definitions* (`DEBATE-CONFIG.md`, `run.conf`, `prompts/`, `PROTOCOL.md`) are tracked.
After cloning, `run-debate.sh` auto-recreates empty run state for any tracked debate.
To keep entire debates out of git, switch the `.gitignore` to the commented `debates/`
rule. The bundled `debates/wf3-vs-wf4/` definition is an example — its
`MATERIALS_DIRS` points at the original author's machine; re-point before running.

## Run

```bash
./bin/run-debate.sh my-topic            # --dry-run previews; --configure forces the casting dialog
```

On an interactive launch you first see the current casting with a 5-second prompt:
**Enter keeps `run.conf` exactly as is** (manual edits respected), `c` opens a per-role
dialog — presets for Claude (opus/sonnet/haiku), Codex (gpt-5.5, with or without xhigh),
**ollama** (local models via `codex --oss`; needs `ollama serve` + the model pulled), or
fully custom engine/model/flags. Choices are written back into `run.conf` (only the nine
role keys are touched). Non-interactive runs never prompt.

Starts everything in parallel: with **tmux** → one session, 4 tiled panes (dashboard,
moderator, advocate A, advocate B) and your browser opens the dashboard; on **macOS
without tmux** → 4 Terminal windows. Safe to re-run mid-debate — agents re-derive state
from disk. Stop a tmux run: `tmux kill-session -t debate-<slug>`.

Watch from the CLI anytime: `./bin/status.sh my-topic`.

> **Claude Code prompt quirk:** `claude "prompt"` is documented to start the REPL with
> the prompt, but a known race can leave the session idle, and a first-run folder-trust
> dialog can swallow the queued prompt. The launcher compensates: in tmux it waits for
> the REPL to be ready, auto-accepts the trust dialog, and types the prompt through the
> pty; in Terminal.app it pre-copies the prompt to your clipboard — if a window sits
> idle, ⌘V + Enter. Codex ingests its positional prompt reliably.

### Manual launch (alternative)

Open three terminals, `cd debates/<slug>/`, start the **moderator first**:

```bash
# T1 — Moderator
claude --model opus --permission-mode acceptEdits --add-dir <materials-dir> \
  "Read prompts/START-MODERATOR.md and follow it exactly."
# T2 — Advocate A
codex --sandbox workspace-write --model gpt-5.5 -c model_reasoning_effort="xhigh" \
  "Read prompts/START-ADVOCATE-A.md and follow it exactly."
# T3 — Advocate B
claude --model opus --permission-mode acceptEdits --add-dir <materials-dir> \
  "Read prompts/START-ADVOCATE-B.md and follow it exactly."
```

Without `--permission-mode acceptEdits`, enable auto-accept in-session (Shift+Tab),
or you'll approve every file write by hand.

### CLI flag notes

- Claude Code: `--add-dir` grants read access to materials outside the cwd; `--model
  opus` picks the latest Opus — pin an exact version string for reproducibility.
- Codex: `--sandbox workspace-write` writes in the debate folder, reads elsewhere.
  With ChatGPT-account auth, `-codex`-suffixed model ids often 400 ("not supported when
  using Codex with a ChatGPT account") — use the plain id (`gpt-5.5`). See what your
  account allows: `codex debug models` or the in-session `/model` picker; if a listed
  model still 400s: `codex logout && codex login`, then `codex update`. `xhigh`
  reasoning effort is only supported by some model variants.

## Dashboard

```bash
./bin/serve.sh <slug>     # → http://localhost:8787/dashboard.html?debate=<slug>
```

Phase stepper, who's-blocking banner, both advocates' artifacts side-by-side with the
moderator's gates between them, word-count-vs-cap bars, gate log, output section with a
ready banner + raw-file links once `UNIFIED-VISION.md` exists. Click any card to read
the full rendered document. Auto-refreshes every 10s.

Debate artifacts are read-only in the browser. The interactive parts, all backed by
localhost-only endpoints in `bin/serve.py`: the **Human inbox** composer (appends to
`human/INBOX.md` — advisory, or binding with the DIRECTIVE toggle; ⌘/Ctrl+Enter sends;
the moderator reads it at every gate), the **✚ New debate** wizard (scaffolds and writes
configs server-side), the **debate switcher** dropdown, and **🚀 Launch** (fire-and-forget
`run-debate.sh`; tmux runs detached — attach with `tmux attach -t debate-<slug>`).

## Relay fallback (no autopilot)

If polling misbehaves or you want full supervision: tell each agent "switch to relay
mode — after writing your artifact, stop and wait for me", then type `go` in whichever
session should act next (`status.sh` shows whose move it is). Interrupted sessions
resume with `claude --continue` / `codex resume`, or just re-paste the START prompt —
the whole debate lives on disk, so any agent can re-derive where things stand.

## For AI agents

If you are an agent asked to participate: your entire contract is in the debate folder.
Read `PROTOCOL.md` (rules), `DEBATE-CONFIG.md` (your side and materials), `STATE.md`
(whose move it is), then follow your `prompts/START-<ROLE>.md`. Hard rules: write only
inside your own file zone (`exchange/P*-<YOUR-ROLE>-*.md`), never edit `STATE.md` unless
you are the moderator, end every artifact with your `<!-- END <ROLE> P<n> -->` marker,
cite every factual claim, and keep polling — waiting is part of the job.

## Troubleshooting

- **An advocate "finished" and idles** → its polling stopped; type: "resume your main
  loop per PROTOCOL §4". (Codex ends its turn after long waits by design.)
- **A file sits half-written** → readers wait for the `<!-- END ... -->` marker; if the
  writer died, resume that session and ask it to rewrite the artifact.
- **Moderator stalls at a gate** → ask it: "run the gate per PROTOCOL §6 now".
- **Debate drifts** → send `DIRECTIVE: refocus on <X>` from the dashboard inbox.
- **Endless extension** → hard cap is 10 phases; remind the moderator via DIRECTIVE.
- **Dashboard shows stale UI after an update** → hard-refresh (⌘⇧R).
- **Inbox send fails** → the server predates `serve.py`; restart `./bin/serve.sh`.
