# DEBATE CONFIG — ADF conversion: workflow-3 vs workflow-4

## Decision question

Which workflow — workflow-3 or workflow-4 — should we take as the **basis** for our ADF
conversion improvements, and what exactly should those improvements be?

## Source materials

| # | Path | What it is | Primarily backs |
|---|------|-----------|-----------------|
| 1 | /Users/andreyshatilov/wf3-testing/docs/adf-conversion/workflow-4/SOURCE-GROUNDED-EVIDENCE-PRD.md | The PRD whose author Side A embodies | Side A |
| 2 | /Users/andreyshatilov/wf3-testing/docs/adf-conversion/workflow-4/ | Full workflow-4 project docs | Side A |
| 3 | /Users/andreyshatilov/wf3-testing/docs/adf-conversion/workflow-3/ | Full workflow-3 project docs | Side B |

Agents read materials in place. Nobody writes into these directories. Explore both
directories fully — supporting docs, examples, and test artifacts all count as evidence.

## Side A

- **Identity/stance:** Embody the **author of SOURCE-GROUNDED-EVIDENCE-PRD.md**. Defend
  workflow-4 and its source-grounded-evidence philosophy as the right basis. You know
  this PRD inside out — argue it the way its author would, with full conviction and full
  command of its details.
- **Champions:** workflow-4 as the base for improvements
- **Session:** Codex CLI — GPT 5.5, reasoning effort `xhigh`

## Side B

- **Identity/stance:** **Principal challenger.** Advocate workflow-3 as the base.
  Stress-test every claim in the PRD: hidden costs, complexity, unproven assumptions,
  edge cases workflow-3 already handles. Surface what workflow-3 does better and why
  starting from it is the safer or stronger path.
- **Champions:** workflow-3 as the base for improvements
- **Session:** Claude Code CLI — Opus 4.8

## Moderator

- **Session:** Claude Code CLI — Opus 4.8 (separate session from Side B)

## Proposed decision criteria (moderator finalizes in P0; advocates may contest in P1)

1. Correctness / evidence-groundedness of conversion output — weight 30
2. Robustness and edge-case coverage — weight 20
3. Implementation and operational complexity — weight 15
4. Maintainability and extensibility — weight 15
5. Migration cost and risk from the current state — weight 10
6. Performance and cost at scale — weight 10

## Process settings

- **Mode:** autopilot (file polling per PROTOCOL §4); relay fallback documented in README
- **Phases:** standard P0–P5; moderator may extend to ≤10 total if a promising path
  emerges (PROTOCOL §7)
- **Output:** `output/UNIFIED-VISION.md` — the single agreed vision: chosen base workflow
  plus a prioritized improvement backlog
- **Language:** English
