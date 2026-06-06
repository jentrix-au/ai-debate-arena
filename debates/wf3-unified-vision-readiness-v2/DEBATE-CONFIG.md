# DEBATE CONFIG - WF3 Unified Vision Production Readiness V2

## Decision question

Should `/Users/andreyshatilov/debate-arena/debates/wf3-vs-wf4/output/UNIFIED-VISION.md`
be accepted as the implementation basis for the workplace ADF-to-modern-stack program, or
must it be revised before implementation; if revised, what concrete target architecture,
gates, artifacts, fixtures, baselines, and rollout sequence should replace it?

## Desired output type

**Implementation basis**

The final must include concrete gates, owners, artifacts, acceptance tests, baselines,
fixtures, source-critical classifiers, operator exception limits, and stop/go rules. A
directional recommendation alone is not enough.

## Source materials

| # | Path | What it is | Evidence authority | Primarily backs |
|---|------|-----------|--------------------|-----------------|
| 1 | /Users/andreyshatilov/debate-arena/debates/wf3-vs-wf4/output/UNIFIED-VISION.md | Prior brainstorm/debate synthesis under review | generated-synthesis | Shared |
| 2 | /Users/andreyshatilov/debate-arena/debates/wf3-vs-wf4 | Prior debate record, sign-offs, clash map, and trail | generated-synthesis | Shared |
| 3 | /Users/andreyshatilov/wf3-testing/docs/adf-conversion/workflow-3 | Workflow 3 / v3.2 conveyor documentation | guidance | Side A / shared |
| 4 | /Users/andreyshatilov/wf3-testing/docs/adf-conversion/workflow-4 | Workflow 4 blackboard documentation, incidents, source-grounded evidence PRD | guidance | Side B / shared |
| 5 | /Users/andreyshatilov/wf3-testing/AGENTS.md | Active project control instructions for the ADF conversion repo | guidance | Shared |
| 6 | /Users/andreyshatilov/harness/reports/kb-ab-test/phaseB-subset-quality-findings-2026-06-05.md | KB-harness capstone: zero-leak quality still failed parity | executed | Side B / shared |
| 7 | /Users/andreyshatilov/harness/reports/kb-ab-test/hybrid-placement-phase-a4-findings-2026-06-05.md | KB-harness hybrid placement leak findings | executed | Shared |
| 8 | /Users/andreyshatilov/harness/reports/kb-ab-test/out-of-tree-phase-a-findings-2026-06-04.md | KB-harness out-of-tree placement null result | executed | Shared |
| 9 | /Users/andreyshatilov/harness/reports/kb-ab-test/anchor-or-drop-phase-a3-findings-2026-06-04.md | KB-harness anchor-or-drop residual findings | executed | Shared |
| 10 | /Users/andreyshatilov/debate-arena/debates/wf3-unified-vision-readiness/output/UNIFIED-VISION.md | Previous readiness debate final output to compare against | generated-synthesis | Shared |
| 11 | /Users/andreyshatilov/debate-arena/debates/wf3-unified-vision-readiness/STATE.md | Previous readiness debate gate log / process trace | generated-synthesis | Shared |

Agents read materials in place. Nobody writes into these directories.

Authority note: generated plans, debate artifacts, agent notes, summaries, and consensus
files may guide investigation, but they are not authority for source, schema, behavior,
verification, rollout, or completion claims unless this debate is explicitly about those
generated artifacts.

## Side A

- **Identity/stance:** Production pragmatist and implementation owner. Defend the prior
  readiness decision's core direction as substantially correct, but strengthen it into the
  smallest executable implementation contract required by the updated debate protocol.
- **Champions:** Accept workflow-3/v3.2 as the conversion engine, import workflow-4
  source-authority gates into v3, block production conversion until P0 gates pass, and keep
  full v4 behind a v3-plus-gates pilot.
- **Opening assignment:** Show which parts of the previous readiness output are already
  usable, identify only the missing concrete artifacts/fixtures/baselines needed to satisfy
  the improved protocol, and propose a first implementation slice that can start safely.
- **Session:** Codex CLI, gpt-5.5, reasoning effort xhigh

## Side B

- **Identity/stance:** Source-grounding reliability auditor. Challenge the previous
  readiness output as still too soft unless it names exact files/scripts/schemas/fixtures,
  source-critical classifiers, operator exception bounds, and baseline measurement.
- **Champions:** Revise before implementation into an enforceable contract. Treat the
  previous debate final as generated synthesis only; require primary/executed/operator
  authority for rollout claims and forbid production conversion until gates exist and pass.
- **Opening assignment:** Identify where the previous output still permits bypass, especially
  around freeze-critical classification, operator overrides, vague baselines, and generic
  owner/artifact language. Propose the minimum revision that would satisfy the new protocol.
- **Session:** Codex CLI, gpt-5.5, reasoning effort xhigh

## Moderator

- **Identity/stance:** Neutral program-risk moderator. Optimize for an implementation-ready
  final under the improved protocol. Explicitly compare whether v2 produces a stronger flow
  and final than the previous readiness debate.
- **Session:** Codex CLI, gpt-5.5, reasoning effort xhigh

## Proposed decision criteria (moderator finalizes in P0; advocates may contest in P1)

1. Evidence authority and source-grounded correctness - weight 25
2. Implementation contract concreteness: files, scripts, schemas, reports, fixtures - weight 25
3. Production stop/go safety and bypass resistance - weight 20
4. Baseline, reviewer/grader, defect taxonomy, and scale/no-scale clarity - weight 15
5. Delivery risk, migration cost, and preservation of v3 strengths - weight 10
6. Fair v4 pilot path against v3 plus gates - weight 5

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
- **Phases:** standard P0-P5; moderator may extend to <=10 total (PROTOCOL §7)
- **Output:** `output/UNIFIED-VISION.md` per PROTOCOL §9. The final output must be directly
  comparable to the previous readiness output and explicitly state what improved.
- **Language:** English
