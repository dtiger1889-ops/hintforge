# Ingestion — Research Cascade Result Integration

This procedure runs in a **fresh session, separate from setup**, when research result files (P1 / P2 / P3 from the cascade in [`setup_wizard.md`](setup_wizard.md) Step 8) are ready to integrate into a game guide. Triggered by the user typing "ingest the research" or attaching a result file directly.

> **Why this is its own file.** Ingestion is the largest single context load this guide will see. Loading the full setup wizard alongside the result file wastes context on first-run setup steps (environment check, player name, tier dials, persona research, TTS/PTT, subfolder shape) that ingestion doesn't care about. This file carries only what the ingestion session needs.

## Pre-flight

- The session is **fresh** — Step 10 of the setup wizard tells the user to start a new chat before saying "ingest the research." If the current session shows wizard-setup activity above, ask the user to restart in a fresh session before continuing.
- The session is **opened inside the game folder** (`Guides/<game>/`), not at workspace root or inside `hintforge/`. The agent's working directory determines which game's research gets ingested.
- The framework lives at `../hintforge/` relative to the game folder.

## Procedure

### 1. Find the result file

Check `<game>/research_inbox/` subdirectories in order: `p1/`, `p2/`, `p3/`. Pick up any file that isn't `.gitkeep`. Ingest in phase order — P1 first (creates `architecture.md` scaffold), then P2 (extends it), then P3 (patches gaps).

If the user attached a file directly, use that instead and ask which phase it belongs to. If all inboxes are empty and no file was attached, ask the user where the result is.

### 2. Read the brief and result

Read the corresponding phase brief from `<game>/research_briefs/p1.txt` (or `p2.txt`, `p3.txt`) first (so the bot knows what was asked), then the result file(s).

Read [`../hintforge/templates/claim_format.md`](templates/claim_format.md) to confirm the metadata convention before writing.

### 3. Spoiler classification pass (mandatory, runs as a separate sub-agent)

Deep research is generated unfiltered; spoiler scoping happens here. Spawn a `general-purpose` Agent with the result file(s) plus the user's current `enemy_tier` and `puzzle_tier`. The sub-agent's job:

1. Read every fact in the result. Validate or assign a per-fact `spoiler:` tag — `none` / `progression` / `late-game` / `story` / `dlc:<name>`. Untagged content is unsafe; the sub-agent must classify everything.
2. For each fact, derive the metadata `enemy-tier` and `puzzle-tier` from its spoiler tag. `none` → tier 0; `progression` → 1; `late-game` → 2; `story` → 3; `dlc:<name>` → tier-of-dlc-content + dlc flag.
3. Output a classified version of the result with each fact prefixed by its tags, preserving original wording verbatim. No omissions; high tiers get tagged for gated display, not deleted.
4. Surface ambiguous calls in a short report — facts where the spoiler tier wasn't clear from context — for the main agent to confirm with the user before appending.

**Why a separate agent:** holding "go maximum depth" and "filter by spoiler tier" in the same context produces shallow research; classification needs the full result in front of it without the depth-pressure that produced the result. The split also makes tier raises cheap later — the user advances, the main agent re-runs the *display* filter against already-classified content, no re-research needed.

### 4. Distribute classified facts by vector tag

Do not overwrite existing content; append or create per-file.

| Vector tag | Destination |
|---|---|
| `nav` | `nav/<zone>.md` — create from `templates/nav_zone.md` if the file doesn't exist |
| `structure` | `nav/architecture.md` — zone-graph edges, optional content registry entries, support topology, locks-and-keys |
| `puzzle` | `puzzles/<puzzle_name>.md` |
| `item` | `items/<category>.md` |
| `boss` | per-game mapping (optional-zone boss → discrete-zone file; main-story boss → `sections/<area>.md`) |
| `enemy` | `reference.md` or `warning_tiers.md` |
| `lore` | `sections/<area>.md` |
| `mechanic` | `reference.md` or `meta_explainer.md` |
| `missable` | primary-vector destination + index entry in `sections/<area>.md` |

**For `nav` and `structure` facts:** if `nav/` doesn't exist, create it (stub `index.md` + scaffold `architecture.md` from templates). Set `status: research-integrated` on each newly written file. After writing all per-zone files, run a consistency pass: every edge declared in a zone file must appear in `architecture.md`'s edge table, and vice versa. Drift between them is a bug.

**For `landmark` and `hybrid` localization-mechanism classes:** also write the P2 brief's localization-toolkit output to `nav/localization.md` (create from `templates/localization.md` if absent). Skip for `map-system` and `none`-class games.

**For all other vectors:** preserve tabular structure; don't flatten tables to prose.

### 5. Tag each new section with inline metadata

`_source: <tool> <date> · confidence: <high|medium|low> · enemy-tier: <N> · puzzle-tier: <N> · category: mainline · spoiler: <tier>_`

- **Confidence:** `high` if the source named a verifiable fact, `medium` if the value might vary by patch (item weights, exact damage numbers), `low` if it's an inference.
- **`enemy-tier` and `puzzle-tier`** come from the classification pass, not the user's current settings — that way display-time filtering can compare the user's *current* tier against the *content's* tier and gate accordingly.
- **Default `category` is `mainline`;** use `easter-egg` for hidden / side-objective content and `lore` for worldbuilding (hidden until the reader opts in).

### 6. Phase-specific behavior

- **P1 ingestion.** First run — creates `nav/architecture.md` scaffold (zone graph, chapter↔zone mapping, optional content registry, source-language set) plus all per-chapter content distributed by vector. Most content lands here.
- **P2 ingestion.** Extends an existing `nav/architecture.md` (adds support topology + locks-and-keys sections); creates per-zone gate-list files (`nav/<zone>.md`); writes `nav/localization.md` for `landmark` and `hybrid` games. P1 must be ingested first.
- **P3 ingestion.** Patches gaps + DLC. May extend the zone graph (DLC-introduced zones), optional content registry (DLC quests), and locks-and-keys table (DLC items unlocking base-game content). Merges into existing `architecture.md`; doesn't replace.

### 7. Update `CHECKPOINT.md`

- `Research preferences: cascade-handoff (P1 ingested YYYY-MM-DD from <source-tool>; P2: ingested/pending/skipped; P3: ingested/pending/skipped)`
- Add a `## Harness changelog` entry: which phase was ingested, which subfolders received content, approximate token count, any caveats.

### 8. Move the ingested file aside

Move the ingested file out of `research_inbox/<phase>/` into `research_inbox/<phase>/_processed/` (create the subfolder if needed) so a future "ingest the research" run doesn't double-process it.

### 9. Show the user a recap

One-screen summary: subfolders touched, sections added per subfolder, any `confidence: medium` flags, anything the brief asked for that the result didn't cover.

## Integration discipline (applies across all phases)

- **Research fills empty gates; live-observed wins on conflicts about embodied detail.** When research output and user-flagged live-observed content disagree, embodied detail (in-game text the user transcribed, witnessed sequence, recorded gameplay) wins. Research only fills gaps.
- **Per-file `status:` field is required.** Each output file carries `status: scaffold | research-integrated | live-observed | reconciled` in top-line frontmatter, so the persona and future integrator know what authority the file carries.
- **Architecture-vs-zone-file consistency.** Per-zone files reference the zone graph by edge ID. Edge declarations in zone files must match `architecture.md`'s graph. Drift is lint-checkable; integration includes a consistency pass at step 4.
- **One brief writes to ~5 destination files.** Integration is route-and-distribute, not dump-into-one-file.

## Regeneration safety

When the guide is wiped and regenerated from a refreshed cascade pass, the preservation rule from [`instantiation.md`](instantiation.md) applies: `CHECKPOINT.md`, loadouts, user-flagged live-observed truths, and infrastructure (`.claude/`, PTT/TTS, save-watcher, persona customization) survive. Everything else gets regenerated. Ingestion is the regen path's main mechanism — it's how the new content lands in the wiped folder.
