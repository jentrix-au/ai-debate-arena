# DEBATE CONFIG — v4 blackboard direction review

## Decision question

Given the original intent for workflow v4 as a blackboard/map-to-sources contract, the current
state of workflow v4 and workflow v3.2, and the latest v3.2/source-authority updates, what is the
best engineering direction and best starting point for ADF-to-modern-stack conversion?

## Desired output type

- **Production stop/go:** final must define what is allowed now, what is blocked, and the exact
  evidence required to scale.

The final must also include an engineering recommendation, a ranked option set, a first 1-2 week
implementation slice, and a fair pilot/comparison plan.

## Human intent under review

The user's hypothesis is that v3.2 lost/corrupted information while creating complicated contracts,
and v4 was meant to fix this with a blackboard scheme:

- the contract should be a compact rule/map layer, not a rewritten source of truth;
- the source of truth should remain original code, documentation, user guides, database, UI,
  executed verification, and operator decisions;
- collection agents should parse available sources and publish a blackboard with links and hashes
  to those sources;
- agents should fill gaps collaboratively and challenge unsupported claims;
- when converting a concrete ADF form, agents should use original sources as final authority and the
  contract only as the navigation map and execution rules.

The debate must test whether current v4 actually implements this, whether v3.2 plus the latest
authority gates is a better near-term route, and what exact starting point best preserves source
truth while reducing delivery risk.

## Source materials

| # | Path | What it is | Evidence authority | Primarily backs |
|---|------|-----------|--------------------|-----------------|
| 1 | /Users/andreyshatilov/wf3-testing/AGENTS.md | Active control instructions and production/pilot status | guidance | Shared |
| 2 | /Users/andreyshatilov/wf3-testing/docs/adf-conversion/workflow-3/ | Workflow v3.2 documentation, stage specs, gates, authority policy, changelog | guidance | v3.2 baseline / shared |
| 3 | /Users/andreyshatilov/wf3-testing/docs/adf-conversion/workflow-4/ | Workflow v4 blackboard docs, PRD, changelog, recovery retrospective, pilot docs | guidance | v4 baseline / shared |
| 4 | /Users/andreyshatilov/wf3-testing/docs/adf-conversion/authority-policy.json | Current machine-readable authority model shared by v3 and v4 | guidance / policy | Shared |
| 5 | /Users/andreyshatilov/wf3-testing/.claude/scripts/source-authority-gate.py | Current deterministic source-authority gate implementation | executable / guidance | Shared |
| 6 | /Users/andreyshatilov/wf3-testing/docs/adf-conversion/workflow-3/fixtures/source-authority/ | Positive and adversarial authority-gate fixtures | executable test fixtures | Shared |
| 7 | /Users/andreyshatilov/wf3-testing/docs/adf-conversion/PIPELINE-REGISTRY-V4.json | Current v4 registry manifest | generated/runtime state | Shared |
| 8 | /Users/andreyshatilov/wf3-testing/docs/adf-conversion/pipeline-registry-v4/ | Current v4 registry shards if present | generated/runtime state | Shared |
| 9 | /Users/andreyshatilov/wf3-testing/.v4/ | Current v4 claim store, questions, agent cards, and SVR reports if present | generated/runtime state | Shared |
| 10 | /Users/andreyshatilov/wf3-testing/docs/adf-conversion/SCS_CO_*/ | Current per-form conversion artifacts, semantic/realization contracts, verification, gate reports | generated + executed artifacts; must inspect evidence class | Shared |
| 11 | /Users/andreyshatilov/debate-arena/debates/wf3-vs-wf4/output/UNIFIED-VISION.md | Prior workflow-3 vs workflow-4 debate result | generated-synthesis | Shared |
| 12 | /Users/andreyshatilov/debate-arena/debates/wf3-unified-vision-readiness-v2/output/UNIFIED-VISION.md | Prior readiness debate final implementation contract | generated-synthesis | Shared |
| 13 | /Users/andreyshatilov/debate-arena/debates/wf3-unified-vision-readiness-v2/output/P0-IMPLEMENTATION-PROMPT.md | Prompt used to implement P0-0..P0-3 source-authority gates | generated-synthesis / implementation prompt | Shared |
| 14 | /Users/andreyshatilov/debate-arena/debates/wf3-unified-vision-readiness-v2/ | Prior debate trail and sign-offs | generated-synthesis | Shared |
| 15 | /Users/andreyshatilov/harness/reports/kb-ab-test | KB harness reports if present; use only if readable | executed / generated depending on file | Shared |

Agents read materials in place. Nobody writes into these directories.

Authority note: generated plans, debate artifacts, agent notes, summaries, contracts, and consensus
files may guide investigation, but they are not authority for source, schema, behavior,
verification, rollout, or completion claims unless the debate is explicitly evaluating those
generated artifacts as artifacts.

## Option set that must be examined

The final may choose one option or a staged combination, but it must explicitly evaluate all of
these:

1. Continue raw v3.2 without the new authority gates.
2. v3.2 production engine plus mandatory source-authority gates.
3. Original "blackboard as map to sources" v4, with contracts demoted to source indexes/rules.
4. Current full v4 blackboard/claim-store architecture as production base.
5. Hybrid: v3.2 stage conveyor plus a source-grounded blackboard/evidence index before Stage 5.
6. Pilot-only v4, judged against v3.2 plus gates on representative forms.
7. Rewrite/simplify v4 around a narrower evidence packet instead of full multi-agent substrate.
8. Pause conversion scale-out until a benchmark/harness proves authority correctness.

## Side A

- **Identity/stance:** Principal architect defending the user's original v4 idea: blackboard as
  source-grounded evidence map, compact rule contract, multi-agent gap filling, and no generated
  artifact as final authority.
- **Champions:** A rebuilt or corrected v4 direction, but must concede where current v4 deviates
  from the original idea or where v3.2 gates are the safer interim mechanism.
- **Session:** Codex CLI, high-reasoning model.

## Side B

- **Identity/stance:** Principal delivery and reliability engineer defending the safest production
  path under observed failures, delivery pressure, and available executed evidence.
- **Champions:** v3.2 plus source-authority gates and measured pilot discipline, but must concede
  where v3.2's contract-heavy conveyor risks information loss and where a blackboard/evidence index
  is structurally superior.
- **Session:** Claude or Codex CLI, high-reasoning model.

## Moderator

- **Session:** Claude or Codex CLI, high-reasoning model.
- **Special instruction:** Do not allow a binary "v3 vs v4" answer unless it genuinely dominates
  the option set. Force the final to separate near-term production path, long-term architecture,
  and first implementation slice.

## Proposed decision criteria (moderator finalizes in P0; advocates may contest in P1)

1. Preservation of source truth / resistance to information loss — weight 25
2. Evidence authority and fail-closed behavior — weight 20
3. Delivery reliability for complex ADF forms — weight 15
4. Implementation complexity and operational cost — weight 15
5. Ability to exploit multi-agent collaboration without creating second truth — weight 10
6. Observed results from current v3.2/v4 runs and latest updates — weight 10
7. Future extensibility beyond ADF Oracle -> React Spring — weight 5

## Readiness floor

If the final answer claims implementation or production readiness, it must name:

- required gates and stop/go rules;
- owner roles;
- exact files/scripts/schemas/reports/fixtures to create or change, or `[TBD-BLOCKER]`;
- acceptance tests and pass/fail thresholds;
- source-critical claim classifier;
- baseline/workload/reviewer or grader for comparison;
- operator exception limits and audit trail;
- what may use generated artifacts only as maps;
- what must read original primary/executed/operator evidence before code changes;
- how agents should handle gaps, contradictions, stale evidence, and derived-only claims;
- how to measure whether the blackboard approach improves on v3.2 plus gates.

## Process settings

- **Mode:** autopilot (file polling per PROTOCOL §4); relay fallback documented in README
- **Phases:** standard P0-P5; moderator should extend if needed to compare more than the two
  advocate positions
- **Output:** `output/UNIFIED-VISION.md` per PROTOCOL §9
- **Language:** English
