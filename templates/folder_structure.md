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

### `items/`
Universal — every game has things the player carries. Suggested split (adjust to genre):

- `weapons.md`
- `consumables.md` (heals, buffs, throwables)
- `abilities.md` (skills, spells, glove-style mechanics)
- `upgrades.md` (skill trees, talents, neuromods)
- `materials.md` (crafting components)
- `collectibles.md` (audio logs, lore items, missables)

Per item: synonyms (top), description, source(s) where to get it, hint ladder if puzzle-locked.

For RPG-heavy games consider also: `armor.md`, `enchantments.md`, `mounts.md`, etc. Genre-driven.

### `sections/`
Main-path regions. **Missables-only by default — no story.**

Use when the game is region-based (open-world chunks, chapter maps). One file per region. Each: list of missable acquirables (collectibles / blueprints / audio logs), spoiler-free description of how to find each, sealed-section warnings if applicable.

Skip if the game is fully linear with no missables (rare).

## Files at game-folder root

- `CLAUDE.md` — folder rules (≤30 lines hard cap)
- `CHECKPOINT.md` — playthrough state (≤80 lines)
- `reference.md` — stable build/mechanics info that doesn't fit a category
- `persona.md` — voice toggle
- `warning_tiers.md` — tier flags
- `limitations.md` — blocked sources

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
