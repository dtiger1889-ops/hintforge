# Hintforge corpus format

This document specifies the on-disk shape of a Hintforge corpus — the contract between the **builder** (which produces corpora) and the **reader** (which consumes them at runtime). It is an internal reference for framework maintainers and future contributors; end users never read it. They run the builder, which produces the right shape automatically, and run the reader, which expects that shape automatically.

The format has three normative layers: a **universal core** that every corpus has, a set of **vector extensions** that vary by game, and a **runtime discovery mechanism** that lets the reader figure out which extensions exist in the current corpus.

## 1. Universal core

A directory is a Hintforge corpus if and only if it contains the four universal published directories and six universal files listed below. The reader can assume every corpus has these and route to them by name.

**Universal directories** (always present, always populated unless the game genuinely lacks content for them):

| Directory | Purpose |
|---|---|
| `nav/` | Per-zone routing files plus the architecture-level `architecture.md` (zone graph, optional content registry, support topology, locks-and-keys, vector list). Source of truth for routing (Rule 1), lookahead (Rule 2), backtrack (Rule 3), reachability (Rule 4), and locks (Rule 5). |
| `items/` | Item index plus per-item or per-category files (weapons, consumables, crafting materials, etc.). |
| `sections/` | Per-chapter or per-region narrative-walkthrough files. Lookup target for "what happens in section X?" |
| `_overflow/` | Catch-all for content that doesn't fit cleanly elsewhere. May be empty. |

**Universal files** (always present at the corpus root):

| File | Purpose |
|---|---|
| `CHECKPOINT.md` | Live session state: `player_position` block (current zone, last gate, confidence, last updated), spoiler-dial settings, open threads, phase tracking. Reader reads at session start; updates on every position update. |
| `CLAUDE.md` | Per-game harness rules — game name, persona cast names, tier defaults, pointers to the reader skill. |
| `controls.md` | Game's control scheme; lookup target for "what button does X?". |
| `settings.md` | Game's in-engine settings menu structure mirrored verbatim from the game (NOT industry-category labels). |
| `limitations.md` | Blocked sources, rejected sources, known research gaps. |
| `warning_tiers.md` | Per-game enemy-tier (0–5) and puzzle-tier (0–3) definitions plus the breach log. |

**Excluded from the published corpus by definition.** These exist in some directories on disk during authoring or runtime, but are not part of the corpus format and the reader does not look for them:

- **Builder-only paths:** `research_briefs/`, `research_inbox/` (including its `p1/`, `p2/`, ..., `_processed/` subfolders). These are scratch space the builder uses while authoring.
- **Platform/runtime paths:** `ptt/`, `save_state/`, `.claude/`. These are local runtime infrastructure, not corpus content.

A reader scanning a directory for "is this a corpus?" checks the universal directories and files. The presence of builder-only or platform/runtime paths does not affect the answer.

## 2. Vector extensions

In addition to the universal core, a corpus may carry one or more **vector extensions** — top-level directories whose presence depends on the game's content shape. These are not universal: a narrative-only game has no `enemies/`; a linear puzzle game has no `optional_zones/`. Forcing every corpus to ship every extension as an empty folder is unworkable, so the builder creates only the extensions the game needs (decided at setup-wizard time from game-type answers) and the reader discovers them at runtime.

**Known vector extensions and semantics:**

| Extension | Used when | Empirical examples |
|---|---|---|
| `puzzles/` | Game has discrete puzzles with hint ladders and solutions | Portal, Atomic Heart |
| `enemies/` | Game has combat with enemies worth indexing | Atomic Heart |
| `endings/` | Game has multiple endings worth indexing separately | Stanley Parable |
| `paths/` | Game has branching narrative paths worth indexing | Stanley Parable |
| `optional_zones/` | Open-world game with side content keyed to zones | Atomic Heart |
| `mechanics/` | Systems-heavy game where mechanics deserve dedicated files | FTL (single file rather than directory in that corpus) |
| `testing_grounds/` | Game has isolated challenge spaces distinct from main flow | Atomic Heart (game-specific) |

Corpora may declare new extensions. The list above reflects what has been observed across five game corpora (Atomic Heart live; Portal, FTL, Stanley Parable, Battletech benched in `experiments/experiments_aggregate.md`). A new game type that needs a new vector category — e.g. `factions/` for a politics-heavy strategy game — adds it via the builder wizard's "declare additional vectors" step and lists it in the corpus's `architecture.md` vector list.

**File counts vary by more than an order of magnitude across vectors and games.** `nav/` ranges from 2 files (Stanley Parable) to 46 (Atomic Heart). `puzzles/` ranges from 0 to 15 (Portal). The reader must handle empty-or-near-empty universal-core folders and variable populations within extensions.

## 3. Runtime discovery mechanism

Because the vector-extension set varies per corpus, the reader cannot enumerate them in its body. It discovers them at session start using a two-tier mechanism:

**Primary: vector list in `nav/architecture.md`.** The corpus's `architecture.md` carries a `Vector extensions` section listing the extension folders this corpus uses and a one-line semantic for each. Format:

```markdown
## Vector extensions

- `puzzles/` — discrete puzzle files with hint ladders, indexed by `puzzles/index.md`
- `enemies/` — enemy files indexed by `enemies/index.md`
- `optional_zones/` — side content keyed to parent zone IDs from the zone graph
```

The reader reads this section at session start, registers each extension and its semantic, and routes topical questions accordingly.

**Fallback: filesystem listing.** If `architecture.md` has no `Vector extensions` section (corpus is mid-construction, or the maintainer hasn't populated the list), the reader lists top-level directories in the corpus, excludes the four universal-core directories (`nav/`, `items/`, `sections/`, `_overflow/`) and known platform/runtime directories (`ptt/`, `save_state/`, `.claude/`), and treats the remainder as vector extensions with unknown semantics. The reader still routes to them on best-guess name matching but flags the missing manifest to the maintainer.

**Mismatch tolerance.** When the manifest lists an extension but the folder is absent (or vice versa), the reader logs a diagnostic and prefers what is actually on disk. Manifest drift is a maintenance bug, not a runtime failure.

## 4. Claim format

Every fact in a corpus that could be falsified is structured as a **claim** with metadata. This makes prose readable by humans AND parseable by the future aggregator agent. Two acceptable formats: **inline** (italicized metadata line beneath the prose claim) and **block** (heading + bullet metadata) — pick whichever reads better.

**Required fields:**

- `claim` — the factual statement, exact and testable. Uncertainty goes in `confidence`, not in the claim text.
- `source` — where it came from. URL preferred; in-game observation acceptable.
- `contributor` — who added or last-verified.
- `confidence` — `high` / `medium` / `low`.
- `last-verified` — date the claim was last re-checked against reality.
- `enemy-tier` — `0`–`5`. Minimum enemy-spoiler tier required to see this claim.
- `puzzle-tier` — `0`–`3`. Minimum puzzle-spoiler tier required to see this claim.
- `category` — `mainline` | `easter-egg` | `lore`. Defaults to `mainline`.

**Recommended:**

- `spoiler` — `none` | `progression` | `late-game` | `story` | `dlc:<name>`. The ingestion sub-agent assigns this tag and derives `enemy-tier` / `puzzle-tier` from it via:
  - `none` → tier 0
  - `progression` → tier 1
  - `late-game` → tier 2
  - `story` → tier 3
  - `dlc:<name>` → tier of DLC content + DLC flag

**Optional (post-distribution):**

- `conflicts-with` — other claims this contradicts.
- `game-version` — patch/version verified against.
- `platform` — platform-specific notes.

Opinions, recommendations, tier rankings, hint-ladder Lvl 1 nudges, section overviews, and procedural advice are **not** claims and should not carry metadata. Prose is fine.

The authoritative working version of this convention lives at `_builder/templates/claim_format.md`.

## 5. Architecture-level structures

`nav/architecture.md` is the corpus's structural spine. It carries five primitives the reader depends on:

1. **Zone graph** — nodes (zones) and edges (transitions). Each edge has `type` (`story-gate | one-way | optional | hub-spoke | fast-travel | conditional`), `direction` (`bidirectional | one-way src→tgt`), `condition`, `point_of_no_return` (`none | permanent | chapter-bound | missable-trigger | point-of-divergence`), and notes. Also includes a **game-type label**, **localization-mechanism class**, **entry node**, **hub nodes**, and **source-language set**.
2. **Chapter ↔ zone mapping** — links narrative structure to spatial structure.
3. **Optional content registry** — table of optional content (items, quests, challenges) with unlock condition, access window, parent zone, recommended chapter, failure mode.
4. **Support topology** — connections between hub zones and the services they offer (vendors, fast-travel, save points, upgrade stations).
5. **Locks-and-keys** — table mapping every lockable element to the key item that opens it, plus a `lock_visible_before_key` flag for Rule 5 notifications.

Plus the **vector list** described in §3.

The authoritative template lives at `_builder/templates/architecture.md`.

## 6. Status field and update discipline

Every per-zone file (and every claim-bearing file produced by ingestion) carries a `status` field at the top with one of these values:

- `scaffold` — placeholder, no substantive content yet. The reader treats scaffolds as "not yet researched" and falls through to web search for the topic.
- `research-integrated` — content populated from a research cascade pass.
- `live-observed` — content corrected from live play observation (highest authority).
- `reconciled` — multiple sources merged with conflicts resolved.

The reader uses `status` to decide whether to answer from the file or fall through to web search. A file with `status: scaffold` and no substantive content is treated as if absent.

**Update discipline.** Live observation > research cascade > web search. When live play contradicts a research-integrated file, the live observation wins and the status moves to `live-observed`. Stitch-and-zipper passes (post-ingestion synthesis) may move a file from `research-integrated` or `live-observed` to `reconciled` once cross-system edges are written and conflicts resolved.

## 7. Spoiler tier annotation syntax

Beyond the per-claim `enemy-tier` / `puzzle-tier` fields, file-level spoiler annotation appears at the top of any file whose **entire** contents sit above a particular tier (e.g., a boss-strategy file that should be invisible at tier 0). Format:

```markdown
---
min-enemy-tier: 2
min-puzzle-tier: 0
---
```

The reader checks this header before routing to the file. If the reader's current dials are below the minimums, the file is treated as if it does not exist for that session.

Per-game `warning_tiers.md` defines what each tier number means for that game's specific enemy roster and puzzle catalog.

The authoritative template lives at `_builder/templates/warning_tiers.md`.

## 8. Where this document lives

This file is `docs/corpus-format.md` inside the **builder** repo (currently at `_builder/docs/corpus-format.md` on the `split-prep` branch; final location is `docs/corpus-format.md` at the builder repo root after Phase 3). The builder is what produces the format, so the format spec lives with the producer. The reader repo's README will link here for anyone who wants the detail. There is no separate corpus-format repo; an internal contract reference with no end-user audience does not warrant one.
