# Folder Structure — Per-Game Decisions

Not every game needs every folder. Use when deciding which subfolders to create for a new guide.

## Standard subfolders

### `puzzles/`
Use when the game has discrete logic puzzles or environmental challenges that the player needs hints for.

Structure:
- `index.md` — keyword → file mapping ("if the player says 'lock' → `lockpicking.md`"). Plus visual identification ("if you see X on screen, look in Y").
- `puzzle_types.md` — visual identification gallery (optional, useful when puzzle types look similar).
- One file per puzzle category — `keypad_codes.md`, `lockpicking.md`, etc.
- Each file: short overview → hint ladder format (Lvl 1 / Lvl 2 / Lvl 3) → known examples → sources.

Skip if the game has no puzzles (pure action games, narrative games).

### `[areas]/` — discrete optional locations

Game-specific name — use whatever the game itself calls them, since that's what players will type when asking. Examples by genre:
- Open-world action-adventure with shrines / trials → `shrines/` or `trials/`
- Soulslike with optional zones → `optional_areas/`
- Open-world RPG with many dungeons → `dungeons/` (probably restrict to standout ones — there are too many)
- Survival horror — maybe just merge into `sections/`
- Metroidvania with optional rooms → `optional_zones/`
- Sci-fi shooter with testing-ground / arena chambers → `chambers/` or `arenas/`

Each file: location/access (no spoilers about *getting* there), rewards (with conflicts noted), hint ladder for any puzzles inside.

Use when the game has reusable, content-dense optional zones worth indexing separately from the main path.

### `nav/`

Use when the game has spatial navigation worth structuring: dungeon-crawlers, hub-and-spoke games, open worlds with discrete zones, or any game where "where do I go?" is a frequent in-play question. Skip for `narrative-no-nav` games (Tetris-like, pure visual novels, games with no meaningful spatial orientation).

Structure:
- `index.md` — routing rules and how the persona uses this folder. Universal nav discipline (no left/right directional language; flag the game's save / checkpoint mechanism on zone entry; 3-tip format for entry hints). Start from `templates/nav_index.md`.
- `architecture.md` — **required when nav/ exists.** Zone graph (nodes + typed edges), chapter ↔ zone mapping, optional content registry, support topology (save / checkpoint locations, fast-travel network, hub access), locks-and-keys table. This is the structural backbone for all cross-zone reasoning. Start from `templates/architecture.md`; populate via P1 and P2 research ingestion.
- `localization.md` — **required for `landmark` and `hybrid` localization-mechanism classes.** Start from `templates/localization.md`. Short reference: which in-game landmarks resolve to which zone-ids, what to ask the player when CHECKPOINT's `player_position` confidence drops below `high`. Populated during P2 research ingestion. Skip for `map-system` and `none`-class games where named regions or in-game maps are sufficient.
- One file per navigable zone (`<zone-id>.md`) — sequential gate list, entry/exit references to `architecture.md` by edge ID, optional branches, common confusions, sources. Start from `templates/nav_zone.md`; files created at P2 ingestion time, not during initial setup.

**Zone file naming:** use the canonical zone-id from `architecture.md` (e.g. `<zone-id>.md`). One file per zone — not one per chapter. Game-specific zone names (whatever the game itself calls its dungeons / regions / chambers) are encouraged.

**When "Navigation routing" is selected in Step 7:** create `nav/index.md` stub (from `templates/nav_index.md`) and `nav/architecture.md` scaffold (from `templates/architecture.md`) immediately. Per-zone files (`nav/<zone>.md`) populate during P2 research ingestion.

**Do not create nav/ if:** game-type-label is `narrative-no-nav`, or the game has a rich in-game map system (`map-system` class with `localization-mechanism class: none`) and nav questions are rare enough that per-question web-search covers them adequately.

#### Vector tag taxonomy (used during research ingestion)

Research output (P1 / P2 / P3) carries per-fact `vector:` tags so the integrator can route facts to the correct destination file. Twelve tags:

- `nav` — gate / zone-traversal facts → `nav/<zone>.md`
- `puzzle` — puzzle solutions, mechanics, reset behavior → `puzzles/<puzzle_name>.md`
- `item` — weapons, consumables, key items, blueprints → `items/<category>.md`
- `boss` — boss strategies, weaknesses, arena layout → per-game mapping
- `enemy` — non-boss enemy patterns, weaknesses → `mechanics.md` or `warning_tiers.md`
- `lore` — story beats, character arcs, world-building → `sections/<area>.md`
- `controls` — keybindings, control remaps, input device strategies → `controls.md`
- `settings` — settings that affect difficulty, perception, or QoL (organize by game's actual menu tabs, not industry categories) → `settings.md`
- `build` — loadout strategies, weapon/ability combinations, progression paths → `items/builds.md` (or merge into `items/abilities.md` when ability-focused)
- `structure` — zone-graph edges, optional content registry entries, support topology, locks-and-keys → `nav/architecture.md`
- `missable` — overlay tag (combine as `vector: item, missable: yes`) → primary-vector destination + index entry in `sections/<area>.md`
- `mechanic` — game-system mechanics not specific to one of the above (combat verbs, economy rules, save behavior, NG+) → `mechanics.md` or `meta_explainer.md`. Use when no more-specific vector applies; do not absorb `controls` / `settings` / `build` content into this bucket.

The integration step's job is route-and-distribute by tag. One brief writes to ~5 destination files. See `setup_wizard.md` Step 8 ingestion procedure for the routing table.

### `items/`
Most games have things the player carries — but the **specific split is driven by Stage 0 pre-research output, not by template default**. The pre-research step (`setup_wizard.md` Step 6.7) produces a content-categories inventory marking each of the following present / absent / uncertain. Create only the files Stage 0 marked present:

- `weapons.md`
- `consumables.md` (heals, buffs, throwables)
- `abilities.md` (skills, spells, glove-style mechanics)
- `upgrades.md` (skill trees, talents, neuromods)
- `materials.md` (crafting components)
- `cartridges.md` / `ammo.md` (per-weapon ammunition types when meaningfully distinct)
- `support_items.md` (utility items, traps, deployables)
- `builds.md` (recommended loadouts / playstyle combinations — `vector: build`)
- `collectibles.md` (audio logs, lore items, missables)

Per item: synonyms (top), description, source(s) where to get it, hint ladder if puzzle-locked.

For RPG-heavy games consider also: `armor.md`, `enchantments.md`, `mounts.md`, etc. Genre-driven.

**Do not pre-create empty stubs for absent categories.** Stage 0's "absent — N/A" answer means the file is not created at setup. If the category is later proven present mid-playthrough, promote it from `_overflow/` (see below).

### `_overflow/`
Staging area for content that doesn't have a permanent home yet — per the lazy-classification model. Created as part of the minimal scaffold regardless of Stage 0 results. When the player asks twice about a content type that has no folder yet, write the claim here and surface a promotion prompt: *"You've asked about X twice now — should I create an `X/` folder and move these claims there?"*. This honestly acknowledges that classification at setup time is always incomplete; classification emerges from actual usage patterns.

### `sections/`
Main-path regions. **Missables-only by default — no story.**

Use when the game is region-based (open-world chunks, chapter maps). One file per region. Each: list of missable acquirables (collectibles / blueprints / audio logs), spoiler-free description of how to find each, sealed-section warnings if applicable.

Skip if the game is fully linear with no missables (rare).

## Files at game-folder root

- `CLAUDE.md` — folder rules (≤30 lines hard cap)
- `CHECKPOINT.md` — playthrough state (≤80 lines)
- `controls.md` — **universal** (every game has input). Keybindings + control remaps (PC keyboard/mouse, controller, accessibility rebinds), with a "common remaps players make" section sourced from Stage 0.
- `settings.md` — **standard for any PC/console game with a settings menu** (i.e. nearly all). **Organize by the game's actual in-game menu tabs** (one `##` heading per tab), not by industry-standard categories like "Graphics" / "Audio" / "Accessibility." Games have wildly different settings menus and reorganize them across patches — the file structure must mirror what the player actually sees when they open Settings, so the persona can give accurate menu paths. If research doesn't confirm the exact tab names, flag them as unverified and correct from live observation.
- `mechanics.md` — core game-system rules, mechanics, modes, cross-zone tracking, patch awareness, accessibility. **Create whenever Stage 0 surfaces mechanic-class content** (combat verbs, system rules, game modes, economy mechanics, etc.) — most games have this. Title as "[Game] — Mechanics Reference" or similar; the content is the game's mechanic-class knowledge surface, not a generic catch-all.
- `persona.md` — voice toggle
- `warning_tiers.md` — tier flags
- `limitations.md` — blocked sources

**`controls.md` and `settings.md` are created by the wizard at instantiation, not deferred to research.** Stage 0 pre-research seeds initial content; per-question lookups fill gaps during play.

## Optional add-ons

### `save_state/` + `save_watcher.py`
If the game's save format is parseable. The documented pattern: a Python script that reads the latest save file's plain header, surfaces only fields the user can verify against the in-game UI (skip fields that look authoritative but drift — e.g. wall-clock-since-first-save masquerading as "playtime"), and writes a JSON snapshot to `save_state/latest.json` for the AI to read on session start. Don't force this — many games have encrypted or proprietary-binary saves. When attempted, document what was readable vs. what was encrypted in CHECKPOINT.

### `.claude/tts_hook.ps1` and `ptt/` — voice in/out (advanced)
If a persona is fun enough to hear spoken aloud, or you want a hands-free voice-conversation flow (push-to-talk + read-aloud), see [`optional_modules.md`](optional_modules.md) for the spec. Both are **code-intensive** — Python deps, manual `~/.claude/settings.json` edits, AHK or platform-equivalent for hotkeys. The wizard does not install these; they're contracts for future drop-in templates. Hook scripts are path-guarded so they only fire when the cwd matches an allowlisted game folder, which prevents them speaking in unrelated sessions if registered globally.

### `enhancements.md`
Pitch document explaining why this game's guide exists and how it improves on vanilla / fan-wiki play. Written in the game's persona voice. Useful when sharing the guide.

### `meta_explainer.md`
Canonical persona-voice cold-post explainer for social-media sharing. Written so it can be pasted into Discord / Reddit without context.

## Naming conventions

- Folder names: lowercase snake_case
- File names: lowercase snake_case .md
- Game-specific terms in folder names are **encouraged** if that's what the game calls them (`polygons/`, `shrines/`, `dungeons/`) — improves discoverability for someone familiar with the game and matches in-game vocabulary.

## When to add a new folder type

If a game has a content category that doesn't fit any of the above, add a folder. Document in the game's CLAUDE.md folder map. If the new category looks generalizable to other games, propose adding it to this template via PR.
