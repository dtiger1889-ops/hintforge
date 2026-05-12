# [GAME NAME] — CHECKPOINT
Last updated: YYYY-MM-DD HH:MM UTC
Last played: YYYY-MM-DD
<!-- `Last played:` is the ISO 8601 date (YYYY-MM-DD) the user last actually played the game. Distinct from `Last updated:`, which tracks edits to this file. Bump `Last played:` at the end of a play session. If this date is >30 days from today's date, `setup_wizard.md` Step 10's stale-session detection offers a controls refresher before resuming. -->

## Status
[1–2 lines: where the player is right now. Map / area / quest / save state. Be specific — a fresh session resumes from this.]

## Player
- **Name:** [PLAYER_NAME — what the persona calls them; default "Player"]
- **Address style:** [PLAYER_ADDRESS — `he` / `she` / `they` / free-form; defaults to `they`]

## Goal
Spoiler-controlled playthrough on [PLATFORM]. Cowork acts as live reference for [puzzles, items, missables, areas, ...] — no story, no enemy reveals (unless tier raised).

## Key decisions
- [Platform + control scheme]
- Spoiler tier settings (see `warning_tiers.md`)
- [Game-specific constraints — e.g. "no DLC", "Hardcore mode", "100% run", "permadeath"]

## Open threads
- [Things the player is stuck on, tracking, flagged for follow-up. One bullet each. Include the question + the closest known answer + what's still uncertain.]

## Inventory (if relevant)
- **Carried:** [...]
- **Stored:** [...]
- **Loadout / build:** [...]

## Player position (omit if `localization-mechanism class` in `nav/architecture.md` is `none` — e.g., procedural roguelikes with abstract level structure, narrative-only games, puzzle games. This file survives any wipe-and-regen of the guide; never auto-overwritten.)

```yaml
player_position:
  current_zone: unknown      # zone-id from nav/architecture.md; "unknown" until first session
  last_known_gate: unknown   # gate name from nav/<zone>.md sequential gates list
  reachable_zones: []        # computed from zone graph + current position; update at session end
  last_updated: YYYY-MM-DD
  confidence: unknown        # high=just told/witnessed · medium=last session · low=inferred · unknown=no data
  # lookahead_n: 2           # uncomment + tune if persona Rule 2 fires too early (lower) or misses warnings (raise)
```

## Progress timeline
- [x] [Major milestone reached]
- [x] [Next major milestone reached]
- [ ] **NEXT:** [What's queued up]

## Files that matter
- `CLAUDE.md` — folder rules, hint-ladder format, spoiler discipline
- `mechanics.md` — core game-system rules, mechanics, modes (stable)
- `limitations.md` — blocked sources
- `puzzles/index.md` / `[areas]/index.md` / `items/` / `sections/` — lookup hubs
- `persona.md` — voice toggle
- `warning_tiers.md` — tier flags

## Next step
[1 line: bot-orientation marker for session resume — area name, quest stage, structural position. NOT a preview of upcoming game content. The player doesn't see this as guidance; the bot reads it to re-orient. See Principle #2.]

## Harness changelog
### v1 — YYYY-MM-DD HH:MM UTC
- Project created from `../../hintforge/templates/`. Subfolders chosen: [list]. Personas chosen: [PERSONA1] / [PERSONA2], active: [DEFAULT]. Warning tiers: enemies [N], puzzles [N].
