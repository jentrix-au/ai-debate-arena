# DEBATE CONFIG — <short title>

## Decision question

<One sentence. The single question the debate must answer. The final UNIFIED-VISION.md
is the binding answer to exactly this question.>

## Desired output type

Choose one and delete the rest:

- **Recommendation only:** final may choose a direction, but does not authorize
  implementation.
- **Implementation basis:** final must include concrete gates, owners, artifacts,
  acceptance tests, baselines, fixtures, and stop/go rules.
- **Production stop/go:** final must define what is allowed now, what is blocked, and the
  exact evidence required to scale.

## Source materials

| # | Path | What it is | Evidence authority | Primarily backs |
|---|------|-----------|--------------------|-----------------|
| 1 | /absolute/path/... | <description> | primary / executed / human-decision / generated-synthesis / guidance | Side A / Side B / shared |

Agents read materials in place. Nobody writes into these directories.

Authority note: generated plans, debate artifacts, agent notes, summaries, and consensus
files may guide investigation, but they are not authority for source, schema, behavior,
verification, rollout, or completion claims unless this debate is explicitly about those
generated artifacts.

## Side A

- **Identity/stance:** <e.g. "Embody the author of <doc>. Defend its core philosophy.">
- **Champions:** <which option/workflow/approach>
- **Session:** <CLI + model, e.g. Codex CLI, gpt-X, reasoning effort xhigh>

## Side B

- **Identity/stance:** <e.g. "Principal challenger. Advocate <alternative> as the base.">
- **Champions:** <which option/workflow/approach>
- **Session:** <CLI + model>

## Moderator

- **Session:** <CLI + model>

## Proposed decision criteria (moderator finalizes in P0; advocates may contest in P1)

1. <criterion> — weight <n>
2. ...

## Readiness floor

If the final answer claims implementation or production readiness, it must name:

- required gates and stop/go rules;
- owner roles;
- exact files/scripts/schemas/reports/fixtures to create or change, or `[TBD-BLOCKER]`;
- acceptance tests and pass/fail thresholds;
- source-critical claim classifier;
- baseline/workload/reviewer or grader for comparison;
- operator exception limits and audit trail.

## Process settings

- **Mode:** autopilot (file polling per PROTOCOL §4); relay fallback documented in README
- **Phases:** standard P0–P5; moderator may extend to ≤10 total (PROTOCOL §7)
- **Output:** `output/UNIFIED-VISION.md` per PROTOCOL §9
- **Language:** English
