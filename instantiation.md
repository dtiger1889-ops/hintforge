# Instantiating a New Game Guide — Manual Flow

Manual step-by-step for spinning up a guide. Follow when you want full control over the choices.

> **Prefer an AI-driven prompted setup?** Use [`setup_wizard.md`](setup_wizard.md) instead. It walks the user through the same decisions as guided prompts. This file is the reference when you want to do it yourself, audit what the wizard would do, or customize beyond what the wizard supports.

> **OS notes:** examples below use Windows 11 paths because that's the verified-running setup. Mac/Linux users substitute their own workspace root and save-game paths. See [`os_compatibility.md`](os_compatibility.md) for what's portable vs. locked.

## Step 1 — Create the per-game folder under `Guides/`

```
<workspace>/Guides/<game_name>/
```

Lowercase, snake_case. The per-game folder lives inside `Guides/`, which is itself a sibling of `hintforge/`. **Do not** put a guide inside `hintforge/` — the framework is published as a public git repo, and guides each become their own repo when distribution lands.

If `Guides/` doesn't exist yet, create it first.

## Step 2 — Copy the templates

| Template | Destination | What to do |
|---|---|---|
| `templates/claude_md.md` | `<game>/CLAUDE.md` | Fill `[GAME]`, `[PLATFORM]`, `[PERSONA1]`, `[PERSONA2]`, and `[HINTFORGE_VERSION]` placeholders. Trim to ≤30 lines. |
| `templates/checkpoint.md` | `<game>/CHECKPOINT.md` | Set initial status (just-starting / mid-playthrough), goal, current location. |
| `templates/persona.md` | `<game>/persona.md` | Pick two voices native to the game. One active by default. |
| `templates/warning_tiers.md` | `<game>/warning_tiers.md` | Set initial enemy & puzzle tiers. Default: enemies 0, puzzles 1. |
| `templates/folder_structure.md` | _read, don't copy_ | Decide which subfolders the game actually needs. |
| `templates/limitations.md` | `<game>/limitations.md` | Skeleton, fill as research blocks appear. |
| `templates/claim_format.md` | _read, don't copy_ | Convention for how to write facts. Apply throughout content. |

### Resolving `[HINTFORGE_VERSION]`

Read line 2 of `hintforge/CLAUDE.md` (the framework's own version stamp, e.g. `<!-- v14 — 2026-05-02 -->`). Extract the `v<N>` token and substitute that string into `[HINTFORGE_VERSION]` on line 3 of the new guide's `CLAUDE.md`. The breadcrumb is set once at instantiation and stays fixed across future framework version bumps — it records *which version this guide was forged from*, not what's current. If the framework's version line is missing or malformed, stamp `v?` and note the discrepancy in the new guide's CHECKPOINT so it can be backfilled later.

## Step 3 — Initialize subfolder scaffold

The structure is **initialized**, not finalized — it refines during play via collision-based promotion (see below). From `templates/folder_structure.md`:

**Minimal scaffold (always create):**
- **items/** — even when no `items/<category>.md` files are created yet
- **sections/** — main-path regions, missables-only callouts (no story)
- **_overflow/** — staging area for content that doesn't fit existing folders yet
- **controls.md** at game-folder root — universal; every game has input
- **settings.md** at game-folder root — universal for any PC/console game with a settings menu

**Conditional folders (create only when the game actually has the content category):**
- **puzzles/** — if the game has discrete logic / environmental puzzles
- **nav/** — if the game has zone-traversal worth structuring (skip for `narrative-no-nav` and `map-system`-class games where in-game navigation is sufficient)
- **areas/** (or genre-appropriate name: _shrines/_, _dungeons/_, _zones/_, _polygons/_) — discrete optional locations
- **items/<category>.md** — `weapons.md`, `abilities.md`, `upgrades.md`, `consumables.md`, etc., per the game's actual content categories. Don't create empty stubs for categories the game doesn't have.

When in doubt, omit the conditional folder and let it emerge during play.

### Collision-based folder promotion

When the player asks twice about a content type that doesn't have a folder yet, write the claim to `_overflow/` and surface a promotion prompt: *"You've asked about X twice — should I create an `X/` folder and move these claims there?"*. Classification emerges from actual usage rather than upfront speculation. Folder reorganization is safe because semantics live in claim metadata (`category`, `enemy-tier`, `puzzle-tier`), not in folder location — moving claims between folders doesn't corrupt anything downstream.

## Step 4 — Add the project to the workspace ledger

Edit your workspace `CLAUDE.md` (the parent folder's, not hintforge's):
- Add a row to the Projects table with `Status: active`
- Set Purpose to a one-line description
- Bump the version stamp on line 2 and add a changelog entry to workspace `CHECKPOINT.md`

## Step 5 — Bootstrap CHECKPOINT.md

First session in the new folder, the model reads CHECKPOINT.md and finds placeholders. Fill in:
- Current location in the game
- Inventory snapshot (if mid-playthrough)
- Open threads (puzzles he's stuck on, items he's tracking)

## Step 6 — Optional: save-watcher

If the game has a parseable save format (JSON, plaintext, readable binary header):
- Write `<game>/save_watcher.py` reading `<save_dir>/<latest>.sav` for live ground-truth state
- Document which fields are reliable vs. flaky (e.g. some games store wall-clock-since-first-save in a "playtime" field, which diverges from actual play time — verify any field against the game's own UI before trusting it)
- Run on session-start to populate `<game>/save_state/latest.json`

If the save is encrypted or proprietary-binary, skip. Note in CHECKPOINT what was attempted.

## Step 7 — Optional: persona TTS hook

If the persona is fun enough to hear spoken aloud, the documented pattern (Windows SAPI + path-guarded PowerShell hook script in `<game>/.claude/`) is portable. A pluggable persona library with iconic AI voices is on the roadmap (see `distribution.md`); today, system TTS speaking the response text is the simple starter.

## Step 8 — Publish to GitHub (not yet documented)

Future flow — see `distribution.md` for the design. Until built:
- Local guide is the source of truth
- Sharing happens by handing the folder to another player

When the publishing wrapper ships, this section gets filled in with: GitHub repo creation, CI for claim-format validation, contributor onboarding, etc.

## Regeneration discipline — what survives a wipe-and-regen

A guide may eventually be wiped and regenerated from a refreshed cascade pass (new framework version, revised research, scrap-and-rebuild after structural drift). When that happens, the following survive — never auto-overwritten by regeneration:

1. **`CHECKPOINT.md`** — per-game state. Includes the `player_position` block when present. Survival is unconditional; a regeneration that touches CHECKPOINT.md is a bug.
2. **Loadouts** — the user's actually-played-with weapon trees, build choices, ability picks, spec selections. Wherever they live in the game folder (`mechanics.md`, a dedicated `loadouts.md`, etc.).
3. **Live-observed truths** the user has explicitly flagged as authoritative — in-game text the user transcribed, post-game-state routes the user discovered, save-station locations the user verified. Higher fidelity than research; supersedes research output on conflict (per the integration discipline at the bottom of `setup_wizard.md` Step 8).
4. **Infrastructure** — `.claude/` settings + hooks, push-to-talk / TTS module installs, save-watcher scripts, `persona.md` if it carries customization beyond the template defaults.

Everything else — scaffold files, single-research-run integrations, generic content distributed by the ingestion pass — is wiped and regenerated. Per-game preservation lists (the concrete file inventory for a specific game) are separate per-guide artifacts, drafted alongside the guide.

This rule exists because regeneration is a real workflow (atomic_heart scrap-and-rebuild precedent), not a hypothetical. Without a checked-in preservation list, every regen has to re-derive what to keep.

## After instantiation: feedback loop

After ~1 week of use, revisit `hintforge/templates/` and revise based on what didn't fit:
- Did a placeholder turn out to need three options instead of two?
- Did the suggested folder structure miss an important category for this genre?
- Did the persona pattern need more guidance for non-AI-character voices?

Templates are living — propose revisions via PR.
