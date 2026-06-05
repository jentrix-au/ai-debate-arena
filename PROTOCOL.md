# DEBATE PROTOCOL (universal)

Structured constructive controversy between two AI advocates and an AI moderator, run as
three independent CLI sessions that coordinate **only through files in this folder**.
The moderator is the loop controller: after every phase it issues a gate decision
(CONTINUE / EXTEND / FINALIZE / HALT). Nothing proceeds without a gate.

## 1. Roles

- **MODERATOR (M)** — neutral process owner. Sole writer of `STATE.md` and `output/`.
  Frames the question and decision criteria, maps clashes, runs every gate, writes the
  final synthesis. M advocates for decision quality only — never for a side.
- **ADVOCATE A / ADVOCATE B** — argue the side assigned in `DEBATE-CONFIG.md` as strongly
  as the evidence allows. Goal hierarchy: (1) the correct final decision, (2) your side
  winning. Changing your mind is allowed and must be declared explicitly in the artifact
  where it happens (`POSITION CHANGE: <what and why>`).
- **HUMAN OWNER** — may drop notes into `human/INBOX.md` at any time. Agents never write
  there. M reads it at every gate.

## 2. Control plane — STATE.md

Single writer: **M**. Everyone else treats it as read-only. Schema:

```yaml
phase: <int>
phase_name: <string>
status: awaiting-both | awaiting-A | awaiting-B | moderator-working | finalized | halted
awaiting_files:
  - exchange/P1-A-position.md
notes_for_participants: <one line>
extension_phases_used: <n> of 5
gate_log:
  - "G0 2026-06-05: opened P1"
```

## 3. Files and signaling

- All debate artifacts live in `exchange/`, named `P<phase>-<ROLE>-<slug>.md`
  (e.g. `P1-A-position.md`, `P2-M-clash-map.md`).
- A file counts as **delivered** only when its last line is the end marker:
  `<!-- END <ROLE> P<phase> -->`. Readers: if the marker is missing, wait 15s and re-read
  (the writer may still be streaming).
- **Write zones (hard rule):** A writes only `exchange/P*-A-*.md`; B writes only
  `exchange/P*-B-*.md`; M writes `exchange/P*-M-*.md`, `STATE.md`, and `output/*`.
  Nobody edits another role's files. Nobody writes inside the source-material directories.
- **Evidence rule:** every factual claim about the materials cites `path §section` (or
  line range). Verbatim quotes ≤25 words. Ideas not present in the materials are tagged
  `[NEW]`. Evidence > assumptions.

## 4. Autopilot loop (turn-taking)

Every session runs this loop and never exits until `status` is `finalized` or `halted`:

1. Read `STATE.md`.
2. If `awaiting_files` contains a file **you** must write → do the work, write the file,
   end with the marker.
3. Otherwise poll: run `sleep 30` up to 3 times per shell call (keep each call ≤100s to
   respect CLI timeouts), then return to step 1. Repeat indefinitely. Do not conclude the
   session because "nothing is happening" — waiting is part of your job.
4. M only: when all awaited files are delivered → run the gate (§6), update `STATE.md`.

**Relay fallback:** if a session dies or is interrupted, resume it (`claude --continue` /
`codex resume`) or re-paste its START prompt. The protocol is stateless-on-disk: every
agent must be able to re-derive where things stand purely from `STATE.md` + `exchange/`.

## 5. Standard phases

| Phase | Who | Artifact | Content |
|---|---|---|---|
| **P0** Brief | M | `P0-M-brief.md` | Decision question (from config), proposed weighted criteria (contestable), materials index, schedule. |
| **P1** Positions | A,B parallel | `P1-<R>-position.md` ≤1200 words | Thesis; case for your side mapped to criteria; top weaknesses of the other side (cited); optional criteria amendments. **Independence rule:** write yours before opening the opponent's P1. |
| **G1** | M | `P1-M-clash-map.md` | Genuine disagreements vs talking-past-each-other; finalized criteria; ≤5 targeted questions per side. |
| **P2** Rebuttals | A,B parallel | `P2-<R>-rebuttal.md` ≤1000 words | Quote→respond to the opponent's strongest claims; answer M's questions; explicit concessions list (may be empty). |
| **G2** | M | gate note in STATE | Update clash map. Prime EXTEND hook: did a promising third path emerge? |
| **P3** Steelman | A,B parallel | `P3-<R>-steelman.md` ≤800 words | (a) Opponent's case at its strongest, in your own words; (b) your concessions; (c) what evidence would change your mind. |
| **G3** | M | gate note | Fairness check. Each advocate certifies the opponent's steelman of their position at the top of their P4 file: `CERT: fair` or `CERT: misrepresented — <why>`. |
| **P4** Convergence | A,B parallel | `P4-<R>-vision.md` ≤1200 words | Your complete unified vision: chosen base (may be the opponent's side); prioritized improvement backlog — each item: what, why, provenance (A-side / B-side / NEW), effort S/M/L, risk; migration risks; open questions. |
| **G4** | M | gate note | Diff the two visions. Material conflicts remain → EXTEND with focused mini-phases. Aligned enough → P5. |
| **P5** Synthesis | M, then A,B | `output/UNIFIED-VISION-DRAFT.md`, then `P5-<R>-signoff.md` | Advocates reply `CONCUR` or `OBJECT: <≤300 words>`. M may revise the draft once; persistent objections go verbatim into the Dissent Register. M writes `output/UNIFIED-VISION.md`, sets `status: finalized`. |

## 6. Gates — the loop control

At every gate M must, in this order:

1. Read `human/INBOX.md`. Lines starting `DIRECTIVE:` are binding; everything else is
   advisory. Acknowledge new items in `gate_log`.
2. Validate delivered artifacts (markers, length caps, citation discipline, no strawman).
   Defective artifact → set `status` back to the responsible side with a one-line fix note.
3. Decide and log one line:
   - **CONTINUE** — open the next standard phase.
   - **EXTEND** — insert a focused extra phase (§7).
   - **FINALIZE** — jump to P5 early (only if positions have genuinely converged).
   - **HALT** — unrecoverable problem; explain in `notes_for_participants`, await human.

## 7. Extensions

A standard run is 6 gated steps (P0–P5). M may insert up to **5 extra phases (total ≤10
working phases)** when a promising path deserves exploration. Each extension requires
`P<k>-M-extension-brief.md` stating: the goal, the single question in scope, the expected
artifact, and why it could change the decision. Advocates may request one inside any
artifact via `REQUEST-EXTENSION: <topic>`; M decides at the next gate.

## 8. Conduct

Attack arguments, never the author or the other model. No appeals to authority or model
identity. No strawmanning — engage the strongest version of the opposing case. No scope
invention: improvements must trace to the materials or carry `[NEW]`. Length caps are
hard limits. Civility is mandatory; vigor is expected.

## 9. Output contract — output/UNIFIED-VISION.md

1. **Decision** — chosen base, one sentence.
2. **Rationale** — scored against the final criteria (table).
3. **Improvement backlog** — P0/P1/P2 priorities; each item: what, why, provenance
   (A-side / B-side / NEW), effort S/M/L, risk.
4. **Migration risks and mitigations.**
5. **Open questions** for the human owner.
6. **Dissent register** — verbatim objections, if any.
7. **Trail index** — ordered list of `exchange/` files for auditability.
