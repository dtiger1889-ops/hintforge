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

### Write threshold

Stitch writes only edges where the corpus already documents the dependency clearly enough that no judgment call from the user is needed. The criterion is **corpus convergence:** 2+ files in 2+ different topic directories independently describe both endpoints. Neither file needs to name the dependency explicitly — convergence is enough.

Example: a mechanics file documents that overloading a relay system disrupts nearby electrical systems. A separate navigation file documents that a generator sequence requires uninterrupted electrical state. Two files, different directories, overlapping state-space — write the edge.

**Everything else is skipped silently.** Single-source mentions; two mentions within the same directory; dependencies inferable only from a shared named entity (same NPC, same currency); proximity-only co-occurrence — none of these are surfaced to the user as proposals. The prior "medium confidence — ask the user" flow produced rubber-stamp confirmations that did not actually screen for edge quality, and surfacing the proposal text leaks gameplay spoilers in chat (see Chat output discipline below). If a borderline case becomes important later, a future stitch pass over a richer corpus will pick it up at the write threshold.

Skipped edges are not logged in `dependencies.md` or in chat. The harness changelog in CHECKPOINT may carry a one-line aggregate ("N borderline candidates skipped — single-source") if the contributor would benefit from knowing the corpus is close but not converged. Never enumerate skipped edges individually; that re-introduces the spoiler-leak the threshold was raised to prevent.

### Output: `dependencies.md` + inline cross-refs

Stitch writes two things per high-confidence or user-confirmed edge:

1. A row in `dependencies.md` at game-folder root (created on first stitch run from [`templates/dependencies.md`](templates/dependencies.md) if absent).
2. An inline cross-ref appended to the relevant section in each endpoint file:

```
> **Cross-system dependency** — see `dependencies.md` DEP-[NNN]: [one-sentence summary of the dependency].
```

### Chat output discipline

Stitch is a builder operation, but the builder is often also a future player who has not seen the rest of the corpus yet. Edge descriptions are full strategy spoilers (boss kill orders, achievement requirements, ability counters, missable lockouts). Stitch must not surface them in chat.

**Allowed in chat:**
- Corpus inventory line (file count + approximate KB) before reading begins.
- Procedural blockers that genuinely require user input (e.g., scope decision when corpus > 150 KB).
- A bare completion line: `Stitch complete. N edges written: DEP-[A] through DEP-[B]. See dependencies.md.` IDs only — no titles, no rationales, no tables of contents.

**Prohibited in chat:**
- Edge titles, summary descriptions, or content of any kind. No "DEP-018: Kill Natasha first to clear Owl spawns" style line — that's a strategy spoiler shoved at someone who may be mid-playthrough.
- Tables, lists, or per-edge before/after diffs that include any portion of the edge body.
- Re-reading the rationale for a written edge into chat at the end of the run.

All edge content lives in `dependencies.md` and in the harness changelog inside CHECKPOINT — both files the contributor can open deliberately. The chat surface is for procedural status only.

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
4. Model reads corpus files per scope. For each edge meeting the **write threshold** (2+ files, 2+ topic directories): writes to `dependencies.md` and inline cross-refs, no chat surface. Edges that do not meet the threshold are skipped silently — never proposed in chat.
5. Updates `## Phase state` in CHECKPOINT: `stitch: complete YYYY-MM-DD`, `stitch_stale: false`, `stitch_scope: full` (or scoped list). Adds `## Harness changelog` entry listing DEP-IDs written (IDs only — no descriptions), plus an optional aggregate skip count if borderline candidates were common. Adds row to `dependencies.md` stitch run log.
6. Chat reply at end of session: bare completion line per **Chat output discipline** above. No edge tables, titles, or rationales.

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
