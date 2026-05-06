# Claim Format — Structured Facts for Aggregation

Every fact in a per-game guide exposes: source, contributor, confidence, last-verified, two spoiler dials (enemy-tier and puzzle-tier), and a category. This makes prose readable for humans AND parseable by the future aggregator agent (see `hintforge/distribution.md`).

**Born-structured beats retrofitted-structured.** Once thousands of facts exist across multiple games, retrofitting metadata is brutal. Apply the convention from claim #1.

## The minimum unit: a claim

A claim is any factual statement that could be wrong. Examples:
- "The keypad code in the lower vault is 4719"
- "The hidden chest in the riverside cottage sits behind the false wall, not in the cellar"
- "The Aegis Talisman costs 60 mana shards to craft"
- "Fire arrows do 2x damage to wooden enemies"

Opinions, recommendations, and tier rankings are **not** claims in this sense — they're advice / interpretation, no truth-value to aggregate. Don't structure them.

## The convention — two acceptable formats

Pick whichever reads better for the context.

### Inline (lightweight, for prose-flowing facts)

> The hidden chest in the riverside cottage sits behind the false wall, not in the cellar.
> _source: comrade-7 live observation 2026-03-12 · confidence: high · enemy-tier: 0 · puzzle-tier: 0 · category: mainline · conflicts: community-wiki page_

The metadata line is italicized and starts with `_source:` — easy to scan, doesn't break prose flow.

### Block (heavyweight, for high-stakes facts where the metadata is itself worth surfacing)

```
### Code 4719 — Lower-vault keypad
- **claim:** the keypad in the lower vault opens with `4719`
- **source:** audio log near the corpse, mumbled "four... seven... one nine"
- **contributor:** guidekeeper
- **confidence:** medium (mumbles can mislead — sometimes the audible numbers are a red herring and the real code is on a poster nearby)
- **last-verified:** 2026-03-12
- **enemy-tier:** 0 (no enemy info)
- **puzzle-tier:** 1 (gives the answer to a side puzzle)
- **category:** easter-egg (hidden behind an optional side-objective vault)
- **conflicts-with:** none yet
```

## Field meanings

- **claim** — the factual statement, exact and testable. Avoid hedging language ("probably", "I think") — uncertainty goes in `confidence`, not in the claim text.
- **source** — where it came from. URL is best; in-game observation is acceptable; "vibes" is not. For in-game observations, include what was observed and when.
- **contributor** — who added or last-verified the claim. GitHub identity once published; local handle until then.
- **confidence** — `high` / `medium` / `low`. Use the binary `verified` / `unverified` if a graded scale is overkill for the project.
- **last-verified** — date the claim was last re-checked against reality. Stale claims (>1 game version old) flagged for re-verification.
- **enemy-tier** — `0`–`5`. Minimum enemy-spoiler warning tier (from `warning_tiers.md`) the reader must be at to see this claim. `0` = no enemy info revealed. Higher tiers gate enemy abilities, boss mechanics, late-game roster, etc.
- **puzzle-tier** — `0`–`3`. Minimum puzzle-spoiler tier the reader must be at. `0` = no puzzle solution revealed (location-only is fine). Higher tiers gate hints, partial solutions, and full answers to puzzles / codes / sequences.
- **category** — `mainline` | `easter-egg` | `lore`. Defaults to `mainline` if omitted. See "Category and lore opt-in" below.
- **conflicts-with** — other claims this contradicts. If the aggregator sees a conflict, it picks the higher-weighted side and surfaces the alternative.

### Category and lore opt-in

`mainline` claims are visible to any reader past the spoiler dials. `easter-egg` claims cover hidden / optional / side-objective content and are visible by default but tagged so the aggregator can group them. `lore` claims (worldbuilding, codex entries, narrative backstory not required for play) are **hidden by default** — the reader must explicitly opt in (e.g., "show me the lore stuff") before the renderer surfaces them. Authors don't need to set `category: mainline` explicitly; it's the default.

Optional fields once distribution ships:
- **game-version** — which patch/version this was verified against (e.g. `1.5.0`, `pre-DLC2`, `post-launch-patch-2`).
- **platform** — if the claim is platform-specific (e.g. PC-only mod compatibility).

## What the aggregator will do (preview — not built yet)

When multiple contributors push claims about the same fact:
1. Group claims by topic (the slug / heading they're attached to).
2. Compare evidence weights: live in-game observation > known wiki > social media > vibes.
3. Compare contributor track records (claims they made that survived contradiction).
4. Compute percentage-of-truth: e.g. "5 of 7 contributors say `4719`; 2 say `0719` — surface `4719` as canonical, `0719` as conflict, with confidence delta."
5. Tag the canonical claim with consensus metadata.
6. Filter rendered output by reader's enemy-tier and puzzle-tier independently — claims above either dial are hidden entirely. `category: lore` claims are hidden unless the reader opts in.

The aggregator does NOT do this today. The convention exists now so claims born in early per-game guides can be aggregated when the aggregator ships.

## Why prose still works for the reader

A reader doesn't need to see metadata to use the guide. The aggregator parses metadata; the reader reads prose. Both can coexist — markdown footnotes / italics / blockquotes hide structure cleanly. A static-site renderer (planned) can strip metadata entirely, leaving only the prose claim.

## When NOT to add claim metadata

- **Persona-flavored intros / outros** — voice, not facts.
- **Hint-ladder Lvl 1 nudges** — interpretive, not factual ("look at the floor pattern" isn't falsifiable).
- **Section overviews** — descriptive, not falsifiable.
- **Build recommendations** — opinion, not claim ("the Iron Mace is the best melee weapon" — that's a community-consensus tier ranking, not a verifiable fact).
- **Workflow / procedural advice** — "open the wheel with Tab" is platform doc, not a claim worth aggregating.

When in doubt: **if the claim could be falsified by another contributor's observation, structure it.** Otherwise, prose is fine.

## Evolution

This is v1 of the convention. Likely revisions once an aggregator parses real claims:
- Confidence scale (binary vs. graded, or numeric 0.0–1.0)
- Conflict format (free-text vs. ID references)
- Contributor identity scheme (GitHub username vs. signed cryptographic identity)
- Game-version tagging granularity
- ~~Spoiler-tier sub-fields (enemy-tier vs. puzzle-tier vs. story-tier)~~ — resolved: split into independent `enemy-tier` (0–5) and `puzzle-tier` (0–3) dials, plus a `category` field (`mainline | easter-egg | lore`). Now canonical, see above.

When revising, propose changes via PR and propagate to existing per-game guides.
