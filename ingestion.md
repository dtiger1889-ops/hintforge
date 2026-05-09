# Ingestion — Research Cascade Result Integration

This procedure runs in a **fresh session, separate from setup**, when research result files (P1 / P2 / P3 from the cascade in [`setup_wizard.md`](setup_wizard.md) Step 8) are ready to integrate into a game guide. Triggered by the user typing "ingest the research" or attaching a result file directly.

> ⚠️ **Spoiler heads-up — read before triggering ingestion.** Ingestion produces large LLM-visible output: the model prints fact text, file contents, table rows, and tier-tagged claims as it writes them. The *guide files* respect spoiler tiers via gating, but the *ingestion process* does not — anything in the result file (boss names, late-game mechanics, missable timings, character fates) will scroll past in the terminal. There is no clean fix for this — it's a structural property of running an LLM over spoiler-rich content. If you're spoiler-averse and haven't played the game yet, **shrink the terminal window to a sliver** — wide enough to see the status line ("Incubating… Nm Ns") so you know when it finishes, narrow/short enough that fact text is clipped off.

> 🧠 **Run ingestion on a mid-tier model with extended thinking OFF.** Ingestion is structural: read result, validate spoiler tags, route facts to files by vector, update CHECKPOINT, refresh downstream briefs. None of those steps benefit from extended-thinking reasoning chains. If `[RESEARCH_MODE]` is `handoff`, the deep reasoning has already been externalized to the deep-research tool that produced the result file — paying for thinking locally too is double-billing. Top-tier models (Opus-class) are also overkill; mid-tier (Sonnet-class) handles the work. Verify before triggering: most CLIs surface the model name and "thinking" status in their model picker or status line.

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
2. **Combat content has three sub-vectors that classify differently — tag at the fact level, not the section level.** This split mirrors the tier rules in [`templates/warning_tiers.md`](templates/warning_tiers.md) Tier 0, which gates "Boss existence hidden" and "Permitted: post-encounter help on request" as separately enforced rules:
    - **Tactics** (weakness, phase breakdown, weapon recommendation, missable-achievement preconditions): `progression` for mainline bosses, `late-game` for chapters past the global PoNR, `story` only for final-boss specifics tied to a narrative reveal. Persona delivers post-encounter on request.
    - **Lore / cutscene** (who the boss is, narrative role, character relationships): `story`, regardless of where in the game it appears. Persona delivers only on explicit opt-in.
    - **Existence** (the fact a boss appears in zone X): `progression`. The persona enforces "Boss existence hidden" from `warning_tiers.md` Tier 0 at read-time — the integrator still writes the fact into the destination file (zone files, architecture's locks-and-keys table, encounter index) so the persona has it when the player encounters the boss and asks for help.

    Common error: collapsing all three into `story` because a cutscene sits next to a fight in the result. A research line like "Belyash appears in a Theatre cutscene revealing X, weak to flamethrower-from-side-angle" carries lore (`story`), existence (`progression`, gated by Tier 0 at read-time), and tactics (`progression`, available post-encounter). Tag each separately.
3. For each fact, derive the metadata `enemy-tier` and `puzzle-tier` from its spoiler tag. `none` → tier 0; `progression` → 1; `late-game` → 2; `story` → 3; `dlc:<name>` → tier-of-dlc-content + dlc flag.
4. Output a classified version of the result with each fact prefixed by its tags, preserving original wording verbatim. No omissions; high tiers get tagged for gated display, not deleted.
5. Surface ambiguous calls in a short report — facts where the spoiler tier wasn't clear from context — for the main agent to confirm with the user before appending.

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
| `controls` | `controls.md` (game-folder root) — create if absent |
| `settings` | `settings.md` (game-folder root) — create if absent |
| `build` | `items/builds.md` — create if absent; or merge into existing `items/<category>.md` (e.g. `items/abilities.md`) when the build is ability-focused |
| `missable` | primary-vector destination + index entry in `sections/<area>.md` |
| `mechanic` | `reference.md` or `meta_explainer.md` (true fallback — only when no more-specific vector applies) |

**For `nav` and `structure` facts:** if `nav/` doesn't exist, create it (stub `index.md` + scaffold `architecture.md` from templates). Set `status: research-integrated` on each newly written file. After writing all per-zone files, run a consistency pass: every edge declared in a zone file must appear in `architecture.md`'s edge table, and vice versa. Drift between them is a bug.

**For `landmark` and `hybrid` localization-mechanism classes:** also write the P2 brief's localization-toolkit output to `nav/localization.md` (create from `templates/localization.md` if absent). Skip for `map-system` and `none`-class games.

**For all other vectors:** preserve tabular structure; don't flatten tables to prose.

### 5. Tag each new section with inline metadata

`_source: <tool> <date> · confidence: <high|medium|low> · enemy-tier: <N> · puzzle-tier: <N> · category: mainline · spoiler: <tier>_`

- **Confidence:** `high` if a verifiable fact corroborated by ≥2 independent sources (separate authors / publications, not the same wiki mirrored elsewhere); `medium` if (a) value may vary by patch (item weights, exact damage numbers), or (b) only one source corroborates, or (c) all sources are forum-thread / community-consensus rather than walkthrough / wiki / dev statement; `low` if inferred from indirect evidence. **Source count beats source authority** — a single high-authority claim is `medium`, not `high`. If the spoiler-classification sub-agent flagged a fact as single-source or contested in its report, the integrator must downgrade confidence regardless of how the source phrased itself.
- **`enemy-tier` and `puzzle-tier`** come from the classification pass, not the user's current settings — that way display-time filtering can compare the user's *current* tier against the *content's* tier and gate accordingly.
- **Default `category` is `mainline`;** use `easter-egg` for hidden / side-objective content and `lore` for worldbuilding (hidden until the reader opts in).
- **Write content, gate display.** Classification tags are read-time display filters, not write-time skip switches. When a fact classifies as `enemy-tier: 3` or `spoiler: story`, write the content into its destination file with inline metadata; the persona handles tier-based reveal at read-time. Do **not** write placeholder stubs (e.g. `_[hidden at current tier — raise tier to access]_`) in lieu of real content — placeholders strand content the user opted into seeing once they raise a tier. The only exception is `dlc:<name>` content from a phase not yet ingested (no content exists to write).
- **No inline meta-confirmation language.** Confidence and corroboration are recorded on the `_source: … · confidence: <tier>_` metadata line and the trailing `[Confirmed: <sources>]` line. Don't repeat it as parenthetical "(CONFIRMED — …)" inside table cells, sentence bodies, or gate-condition descriptions — the metadata lines already carry that signal, and the inline form creates reader noise. Same rule for "(verified)", "(SOURCED)", "(updated)", etc. — keep meta out of the prose.

### 6. Phase-specific behavior

- **P1 ingestion.** First run — creates `nav/architecture.md` scaffold (zone graph, chapter↔zone mapping, optional content registry, source-language set) plus all per-chapter content distributed by vector. Most content lands here.
- **P2 ingestion.** Extends an existing `nav/architecture.md` (adds support topology + locks-and-keys sections); creates per-zone gate-list files (`nav/<zone>.md`); writes `nav/localization.md` for `landmark` and `hybrid` games. P1 must be ingested first.
- **P3 ingestion.** Patches gaps + DLC. May extend the zone graph (DLC-introduced zones), optional content registry (DLC quests), and locks-and-keys table (DLC items unlocking base-game content). Merges into existing `architecture.md`; doesn't replace.

### 7. Corpus reconciliation (P2 / P3 only — skip for P1)

For every gap-fill resolution this phase produced that **drops, contradicts, supersedes, or rewords** prior-phase content, locate the orphaned content in the corpus and edit it. Grep the destination subfolders (`sections/`, `items/`, `nav/`, `puzzles/`, `optional_zones/`, `controls.md`, `settings.md`) for the original claim — search anchors include distinctive phrases, the `[Single source — verify]` flag, and the section heading the prior phase wrote it under. For each match:

- **Drop:** delete the entry. Do not leave a "DROPPED — see CHECKPOINT" note in the corpus; the persona reads only the corpus at runtime, not CHECKPOINT.
- **Contradict:** rewrite with the new resolution and an updated `_source:` line. Strip the prior `[Single source — verify · class:<class>]` flag.
- **Supersede:** replace the old value (e.g. canonical Neuropolymer cost numbers replacing range estimates).
- **Reword:** rewrite to match the resolution's phrasing.

**Source-class informs partial vs. full drops.** If the prior-phase verify-flag carried `class:editorial-non-en` (VGTimes.ru, StopGame.ru, DTF.ru, 4Gamer.net, gry-online.pl, etc.) and this phase's gap-fill could not corroborate the claim from English sources, the default is **partial drop** — keep the underlying mechanic with a translation-conflation caveat, drop only the unsupported sub-claim. Non-Anglophone editorial sources for non-Anglophone-developed games disproportionately carry mechanics English coverage misses; that is the entire reason the cascade has an internationalization rule. A full drop on a single `editorial-non-en` source requires a positive contradiction from another source, not just absence of English corroboration.

**Why this step exists.** Resolutions captured only in `CHECKPOINT.md` leak past read-time gating: the persona reads from `sections/`, `items/`, `nav/`, etc., not from CHECKPOINT. A "DROPPED" entry in the CHECKPOINT changelog with the original claim still in `sections/<chapter>.md` means the player gets the dropped claim served at read-time without any of the contradiction context. **Corpus state must reflect the resolution, not just metadata.**

### 8. Update `CHECKPOINT.md`

- `Research preferences: cascade-handoff (P1 ingested YYYY-MM-DD from <source-tool>; P2: ingested/pending/skipped; P3: ingested/pending/skipped)`
- Add a `## Harness changelog` entry: which phase was ingested, which subfolders received content, approximate token count, any caveats. **For P2/P3, also list each gap-fill resolution and the corpus file/line it acted on** (e.g. "Granny Zina ammo storage — DROPPED, removed `sections/ch2_forester.md` lines 42–44") so the changelog and corpus stay legible against each other.

### 9. Refresh downstream briefs (mandatory)

After CHECKPOINT is updated and before the file is moved aside, re-read every `<game>/research_briefs/p<N>.txt` for N greater than the just-ingested phase. For each one:

1. **Hard-code now-established facts.** Anything the just-ingested phase confirmed (zone-id list, chapter ↔ zone mapping, content categories present, localization-mechanism class, NORA / save-station / fast-travel inventory) should be written into the downstream brief verbatim, not left as an open question.
2. **Remove resolved hedges.** Any `if X is true` / `assuming the game has Y` / `confirm whether…` clause whose answer is now known gets deleted or rewritten as a stated fact.
3. **Sharpen open questions.** Questions the downstream brief asked are now scoped against the established context — researchers should not be asked to re-derive what's already known.
4. **Skip if no downstream brief exists** (e.g. P3 ingested without P2/P3 successors). Skip with a one-line note in the recap.

This step exists because researchers receiving a stale downstream brief will redo upstream work and miss the actual gap. The cascade is only as good as the downstream-brief refresh between phases.

### 10. Move the ingested file aside

Move the ingested file out of `research_inbox/<phase>/` into `research_inbox/<phase>/_processed/` (create the subfolder if needed) so a future "ingest the research" run doesn't double-process it.

### 11. Show the user a recap

One-screen summary: subfolders touched, sections added per subfolder, any `confidence: medium` flags, downstream briefs refreshed (with a one-line summary of changes per brief), corpus reconciliation actions (which prior-phase claims were dropped / rewritten / superseded — with file paths), anything the brief asked for that the result didn't cover. Also sanity-check the first line of every newly-created file to confirm the H1 header rendered cleanly (a class of Write-tool collision artifact that's invisible until a reader opens the file).

## Integration discipline (applies across all phases)

- **Research fills empty gates; live-observed wins on conflicts about embodied detail.** When research output and user-flagged live-observed content disagree, embodied detail (in-game text the user transcribed, witnessed sequence, recorded gameplay) wins. Research only fills gaps.
- **Per-file `status:` field is required.** Each output file carries `status: scaffold | research-integrated | live-observed | reconciled` in top-line frontmatter, so the persona and future integrator know what authority the file carries.
- **Architecture-vs-zone-file consistency.** Per-zone files reference the zone graph by edge ID. Edge declarations in zone files must match `architecture.md`'s graph. Drift is lint-checkable; integration includes a consistency pass at step 4.
- **One brief writes to ~5 destination files.** Integration is route-and-distribute, not dump-into-one-file.

## Regeneration safety

When the guide is wiped and regenerated from a refreshed cascade pass, the preservation rule from [`instantiation.md`](instantiation.md) applies: `CHECKPOINT.md`, loadouts, user-flagged live-observed truths, and infrastructure (`.claude/`, PTT/TTS, save-watcher, persona customization) survive. Everything else gets regenerated. Ingestion is the regen path's main mechanism — it's how the new content lands in the wiped folder.
