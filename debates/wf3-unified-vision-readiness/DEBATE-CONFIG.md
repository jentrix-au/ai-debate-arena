# DEBATE CONFIG - WF3 Unified Vision Production Readiness

## Decision question

Should `/Users/andreyshatilov/debate-arena/debates/wf3-vs-wf4/output/UNIFIED-VISION.md`
be accepted as the implementation basis for the workplace ADF-to-modern-stack program, or
must it be revised before implementation; if revised, what concrete target architecture,
gates, and rollout sequence should replace it?

## Source materials

| # | Path | What it is | Primarily backs |
|---|------|-----------|-----------------|
| 1 | /Users/andreyshatilov/debate-arena/debates/wf3-vs-wf4/output/UNIFIED-VISION.md | Final brainstorm/debate synthesis under review | Shared |
| 2 | /Users/andreyshatilov/debate-arena/debates/wf3-vs-wf4 | Prior debate record, sign-offs, clash map, and trail | Shared |
| 3 | /Users/andreyshatilov/wf3-testing/docs/adf-conversion/workflow-3 | Workflow 3 / v3.2 conveyor documentation | Side A / shared |
| 4 | /Users/andreyshatilov/wf3-testing/docs/adf-conversion/workflow-4 | Workflow 4 blackboard documentation, incidents, source-grounded evidence PRD | Side B / shared |
| 5 | /Users/andreyshatilov/wf3-testing/AGENTS.md | Active project constraints for the ADF conversion repo | Shared |
| 6 | /Users/andreyshatilov/harness/reports/kb-ab-test/phaseB-subset-quality-findings-2026-06-05.md | KB-harness capstone: zero-leak quality still failed parity | Side B / shared |
| 7 | /Users/andreyshatilov/harness/reports/kb-ab-test/hybrid-placement-phase-a4-findings-2026-06-05.md | KB-harness hybrid placement leak findings | Shared |
| 8 | /Users/andreyshatilov/harness/reports/kb-ab-test/out-of-tree-phase-a-findings-2026-06-04.md | KB-harness out-of-tree placement null result | Shared |
| 9 | /Users/andreyshatilov/harness/reports/kb-ab-test/anchor-or-drop-phase-a3-findings-2026-06-04.md | KB-harness anchor-or-drop residual findings | Shared |

Agents read materials in place. Nobody writes into these directories.

## Side A

- **Identity/stance:** Production pragmatist and implementation owner. Defend the unified
  vision as the correct implementation basis, with only targeted clarifications needed before
  work starts.
- **Champions:** Accept the unified vision's core decision: workflow-3/v3.2 as the shipping
  base, workflow-4 source-grounded authority discipline grafted as v3 gates and scheduling,
  and full v4 blackboard held behind a pilot gate.
- **Opening assignment:** Show why the unified vision is already implementable enough, identify
  the smallest edits required to prevent ambiguity, and produce a concrete first-sprint plan
  that keeps delivery moving.
- **Session:** Codex CLI, gpt-5.5, reasoning effort xhigh

## Side B

- **Identity/stance:** Source-grounding reliability auditor. Challenge the unified vision as
  too consensus-driven and too backlog-shaped for a critical workplace migration unless it is
  revised into an enforceable rollout contract.
- **Champions:** Revise before implementation: make P0/P1 gates mandatory entry criteria,
  demote debate consensus as authority, define source-grounded evidence objects, set a fair
  v4 pilot baseline against v3 plus gates, and add stop/go metrics for scaling.
- **Opening assignment:** Identify the highest-risk ambiguity in the unified vision, argue what
  must be blocked until evidence gates exist, and propose the minimum revised plan that would
  be safe to execute.
- **Session:** Codex CLI, gpt-5.5, reasoning effort xhigh

## Moderator

- **Identity/stance:** Neutral program-risk moderator. Optimize for a decision that is usable
  for a critical ADF modernization program, not for rhetorical consensus.
- **Session:** Codex CLI, gpt-5.5, reasoning effort xhigh

## Proposed decision criteria (moderator finalizes in P0; advocates may contest in P1)

1. Source-grounded correctness and authority control - weight 30
2. Production readiness and operational safety - weight 20
3. Implementation clarity: gates, owners, artifacts, and rollout sequence - weight 20
4. Delivery risk and migration cost - weight 10
5. Ability to preserve v3 strengths while importing v4 discipline - weight 10
6. Future extensibility and fair v4 pilot path - weight 10

## Process settings

- **Mode:** autopilot (file polling per PROTOCOL §4); relay fallback documented in README
- **Phases:** standard P0–P5; moderator may extend to ≤10 total (PROTOCOL §7)
- **Output:** `output/UNIFIED-VISION.md` per PROTOCOL §9. The final output must include:
  accepted/revised decision, explicit stop/go gates, first implementation slice, owner/artifact
  map, and dissent register.
- **Language:** English
