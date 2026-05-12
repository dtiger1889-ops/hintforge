# Stitch and Zipper — Post-Ingestion Synthesis Pass
<!-- hintforge · post-ingestion synthesis · two phases: zipper (reconciliation) then stitch (edge synthesis) -->

This procedure runs in a **fresh session inside the game folder** after at least P1 ingestion is complete. Triggered by the user typing "run stitch", "run zipper", or "run stitch and zipper."

> 🧠 **Run on a mid-tier model (Sonnet-class) with extended thinking OFF.** Same cost discipline as ingestion. Each phase targets $0.50–1.00; both together under $2.

## Two separate passes, two separate triggers

Stitch and zipper are triggered independently. Running them together is the default recommendation, but either can run alone:

- `"run stitch"` — edge synthesis only
- `"run zipper"` — redundancy reconciliation only
- `"run stitch and zipper"` — both, **zipper first then stitch**

**Why separate.** Cost isolation: a stitch run on a large corpus may use most of a session budget. Zipper on a clean corpus may cost almost nothing. Keeping them independent lets the user break up cost and re-run either without paying for both.

**Ordering when run together: zipper first, then stitch.** Zipper's role-split and merge resolutions clean up structural redundancy before stitch counts source files. If stitch runs first, a duplicated file reads as two independent sources and inflates confidence artificially. Zipper deduplicates first so stitch's source-count is a real signal.

---

## Phase A — Zipper (reconciliation)

### What it does

Surveys the corpus for content written redundantly along different axes — two files with substantially overlapping data organized differently. Operates on file structure, headings, metadata lines, and vector tags. Does not read substantive claim content to characterize overlap; uses each file's section headings and `_source:` metadata to determine what dimension it covers.

Focus targets:
- Two index files covering the same content category (e.g., a `paths/index.md` and `endings/index.md` documenting the same per-ending data along different axes)
- Per-zone enemy lists that duplicate `enemies/`-folder catalog entries
- Per-section item drops that duplicate `items/`-folder entries
- Any two files where heading structure and vector tags substantially overlap

### Spoiler discipline

Zipper reads headings, metadata lines, and vector tags only. When characterizing a file's contents in a proposal, it uses the file's own headings and vector tags — not the content beneath them. If a heading is itself spoiler-tagged (e.g., a boss name as an H2 with `spoiler: late-game`), zipper redacts it in the proposal using the same tier-gating the persona uses at read-time: `[late-game content — heading redacted at current tier]`. Read the user's current tier setting from CHECKPOINT before surfacing anything.

### Output: proposals only

Zipper never writes autonomously. For each overlap found, zipper presents:

```
Overlap detected: [file-path-A] ↔ [file-path-B]

A owns: [dimension described using headings/tags only]
B owns: [dimension described using headings/tags only]
Overlap: [what the two share, described structurally]

Resolution options:
(a) Merge — consolidate into [primary file], remove [secondary file], update cross-refs.
(b) Sharpen role split — A owns [dimension X], B owns [dimension Y], cross-ref both ways.
    A keeps: [heading list]. B keeps: [heading list]. Shared content moves to: [primary].
(c) Accept as design — both files intentionally cover this dimension; add a note to each
    explaining the design choice so future contributors do not re-flag it.

Your choice (a / b / c):
```

User picks; zipper writes the chosen resolution. No autonomous structural decisions.

### Zipper facilitates stitch

After role-split or merge resolutions, each fact has one canonical home. Stitch's source-count for high-confidence edges then reflects genuinely independent documentation, not echoes of the same data in two files.

---

## Phase B — Stitch (edge synthesis)

### What it does

Reads the corpus and writes additive cross-reference edges between separately-documented systems. Does not rewrite existing claims, does not invent facts, does not pull from external sources. If an edge requires content the corpus does not have, that is a P3 gap, not a stitch finding.

Focus categories:
- PoNR / lockout / missable / sequencing dependencies (action in System A affects state in System B)
- Recurrence of the same NPC or resource across topic files
- Mechanic-stack interactions (item interacts with status interacts with enemy class)

### Corpus size check (mandatory first step)

Before reading any file content, stitch scans the file list and reports:

```
Corpus inventory: [N] files, approximately [X] KB total.
```

If total corpus size exceeds 150 KB, stitch asks the user whether to proceed in one pass or scope to specific subdirectories. Large corpora risk context-limit pressure mid-pass, which produces incomplete edge detection. Scoping to subdirectories (e.g., `nav/` + `mechanics.md` first, then `items/` + `sections/` in a second pass) avoids truncation and keeps cost predictable. CHECKPOINT carries a `stitch_scope:` field so a scoped pass can be resumed without re-reading already-processed directories.

### Confidence thresholds

**High confidence — auto-write edge to `dependencies.md` and inline cross-ref to both endpoint files.**

Two or more corpus files in different topic directories independently describe a state or action in System A and a state or action in System B in terms that imply a dependency. Neither file needs to name the dependency explicitly — convergence is enough.

Example: a mechanics file documents that overloading a relay system disrupts nearby electrical systems. A separate navigation file documents that a generator sequence requires uninterrupted electrical state. Two files, different directories, overlapping state-space — high confidence. Write the edge.

Operationally: auto-write when 2+ files from 2+ different topic directories independently document both endpoints of the proposed edge. Two mentions within the same directory do not qualify.

**Medium confidence — propose to user before writing.**

One file mentions System A and System B in proximity, or the dependency is inferable from a shared resource (same item, same NPC, same region) but no file explicitly documents both endpoints. Present the proposed edge with a one-sentence rationale and ask for confirmation.

```
Proposed edge (medium confidence): [System A] ↔ [System B]
Rationale: [one sentence citing the source files and the shared state]
Source: [file-path-A] + [file-path-B]
Write this edge? (yes / no / reword):
```

**Low confidence — do not propose.**

The connection exists only via a shared named entity that appears in many places (e.g., the player character, a universal currency) and there is no documented state interaction between the systems. Skip silently.

### Output: `dependencies.md` + inline cross-refs

Stitch writes two things per high-confidence or user-confirmed edge:

1. A row in `dependencies.md` at game-folder root (created on first stitch run from [`templates/dependencies.md`](templates/dependencies.md) if absent).
2. An inline cross-ref appended to the relevant section in each endpoint file:

```
> **Cross-system dependency** — see `dependencies.md` DEP-[NNN]: [one-sentence summary of the dependency].
```

### When the persona references `dependencies.md`

The persona does not scan `dependencies.md` on every response. Triggers:

- **Explicit cross-system query.** Player asks something naming or implying two systems ("does X affect Y", "will doing A break B", "can I still get [item] if I already [action]"). Persona checks dependencies before answering from corpus or web.
- **Zone entry with pending gates.** When orienting to a new zone at session start via `player_position` in CHECKPOINT, persona checks the `## PoNR / lockout edges` table for any edge where that zone is an endpoint and a precondition is unmet.
- **Lookahead proximity.** When `last_known_gate` is within `lookahead_n` steps of a PoNR edge endpoint, persona surfaces the warning at the appropriate tier.
- **On-request.** "What should I know before I do X?" — explicit permission to surface all relevant dependency edges without the player having named them.

---

## CHECKPOINT — Phase state and readiness

### Phase-readiness check

Any natural-language query that implies "what should I do next" or names a phase triggers a readiness check. The model reads `## Phase state` from CHECKPOINT and responds with: what is complete, what is next and whether its preconditions are met, and if preconditions are not met, what is blocking and what the user can do (run the missing phase, or explicitly skip it with a reason recorded in the `skipped (reason)` field).

Preconditions:
- P2 requires P1 ingested or explicit skip-acknowledge.
- P3 requires P2 ingested or skip-acknowledge.
- Stitch requires at least P1 ingested.
- Zipper has no hard precondition but is most useful post-P1.

This handles re-entry cleanly. A player who skipped P2 and wants to run it later says "I want to go back and do P2 ingestion" — the check reads CHECKPOINT, confirms P1 is complete, and starts the P2 ingestion session. A player returning after a break says "what's next" and gets a one-line status read.

### `stitch_stale` flag

Set to `true` automatically when any corpus file receives a new `live-observed` claim after the `stitch:` date. The persona reads this flag at session start and surfaces a one-time notice:

> Heads up — the corpus has had new live-observed facts added since the last stitch run. Cross-system hints may be incomplete. Say "run stitch" to update, or ignore this if the additions were minor.

The flag resets to `false` when stitch completes.

---

## Session shapes

### Zipper session

1. User opens a fresh session inside the game folder and says "run zipper" (or "run stitch and zipper").
2. Model reads CHECKPOINT: confirms at least P1 is ingested. Reads `## Phase state`. Reads user's current tier for spoiler discipline.
3. Model scans file list (headings, metadata, vector tags only — no content reads yet). Reports files surveyed.
4. For each overlap detected: presents the three-option proposal. Waits for user choice. Writes the chosen resolution.
5. Updates `## Phase state` in CHECKPOINT: `zipper: complete YYYY-MM-DD`. Adds `## Harness changelog` entry listing overlaps found and resolutions chosen.

### Stitch session

1. User opens a fresh session inside the game folder and says "run stitch" (or continues from zipper in the same session if running both and corpus is small enough).
2. Model reads CHECKPOINT: confirms zipper has run (or user has explicitly accepted running stitch on an un-zippered corpus). Reads `stitch_scope:` if set.
3. **Corpus size check (mandatory).** Scans file list, reports total count and approximate KB. If over 150 KB, asks whether to proceed full or scoped.
4. Model reads corpus files per scope. For each high-confidence edge: writes to `dependencies.md` and inline cross-refs. For each medium-confidence edge: proposes to user and waits for confirmation before writing.
5. Updates `## Phase state` in CHECKPOINT: `stitch: complete YYYY-MM-DD`, `stitch_stale: false`, `stitch_scope: full` (or scoped list). Adds `## Harness changelog` entry: edges written (with DEP-IDs), edges proposed and outcomes, any edges skipped with reason. Adds row to `dependencies.md` stitch run log.

---

## Builder/reader split

Stitch and zipper are builder tasks. The reader-side persona (the skill a player downloads to use a pre-built guide) does not run either pass. A reader who downloads a pre-built guide and wants to extend or update it needs the builder skill.

The reader persona carries this disclaimer:

> Running stitch, zipper, ingestion, or aggregation contributions requires the builder skill. If you downloaded a pre-built guide and want to update or extend it, see the hintforge framework.

A player who runs hintforge in week 1 (sparse external knowledge base) and wants to re-run ingestion + stitch in month 2 (richer knowledge base) needs the builder skill for the re-run. The `## Phase state` block in CHECKPOINT makes re-running any phase from natural language straightforward.

---

## What is out of scope

- **New research.** If an edge requires content the corpus does not have, that is a P3 gap or a fresh research run, not stitch.
- **Unpromoted live-observed truths.** Player narration that remains only in CHECKPOINT or session context is not read by stitch. Once a live-observed truth is promoted to a corpus file edit with a `contributor:` tag, it is in scope.
- **Rewriting existing claims.** Stitch adds connections; zipper restructures redundancy. Neither rewrites facts.
- **`persona.md`, `warning_tiers.md`, and hint-ladder logic.** Stitch does not modify these files. The persona's reference behavior expands — it now has `dependencies.md` to consult — but its voice, tier rules, and escalation logic are untouched.
