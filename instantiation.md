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

## Step 3 — Decide subfolder shape

Game-specific. From `templates/folder_structure.md`:

- **puzzles/** — if the game has discrete logic / environmental puzzles
- **areas/** (or genre-appropriate name: _shrines/_, _dungeons/_, _zones/_, _polygons/_) — discrete optional locations
- **items/** — weapons / consumables / abilities / collectibles, split by category
- **sections/** — main-path regions, missables-only callouts (no story)

Drop folders the game doesn't need. Add ones it does.

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

## After instantiation: feedback loop

After ~1 week of use, revisit `hintforge/templates/` and revise based on what didn't fit:
- Did a placeholder turn out to need three options instead of two?
- Did the suggested folder structure miss an important category for this genre?
- Did the persona pattern need more guidance for non-AI-character voices?

Templates are living — propose revisions via PR.
