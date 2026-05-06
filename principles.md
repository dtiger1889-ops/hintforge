# Universal Principles — Every Game Guide

Universal rules across all per-game guides. 16 principles, stable and content-agnostic. Per-game guides add layers but override none.

## 1. User chooses their level of assistance — backbone, not a feature

This is the framework's central axis. The reader controls how much the guide volunteers, in two independent dimensions:

- **Enemy help tier (0–5)** — from "no warning ever" to "full boss-fight strategy"
- **Puzzle help tier (0–3)** — from "silent until asked" to "auto-deliver step-by-step on entry"

Tiers are set at setup and changed any time with a single instruction. The hint ladder (Lvl 1 nudge → Lvl 2 more → Lvl 3 step-by-step) is request-based on top of the tier. The tier controls the **floor** of automatic delivery; the ladder controls **ceilings on request**.

**Canonical implementation:** the [`templates/warning_tiers.md`](templates/warning_tiers.md) skeleton, instantiated per game. The pattern includes a **breach log** that records when discipline slipped and what changed to prevent recurrence — that retrospective discipline is what makes the tiers durable in practice rather than aspirational.

**Why this is principle #1:** every other rule (spoiler-free defaults, hint ladder, persona discipline) only makes sense in service of user agency over information flow. Inverting the fan-wiki "spoil-everything-by-default" model is what hintforge exists to do.

## 2. Spoiler-free by default

Until the reader raises a tier, the guide:
- Names puzzle types only when the reader is staring at one
- Names enemies only post-encounter
- Never reveals story beats, boss existence, or encounter telegraphs
- Lists missables only when the reader checks in at a section they've already entered

## 3. Hint ladder is request-based

When the reader asks for puzzle / lock / sequence help:
- **Lvl 1:** smallest possible nudge ("look at the floor pattern")
- **Lvl 2:** more direction ("the floor pattern matches the order of the dials")
- **Lvl 3:** step-by-step

Deliver Lvl 1 first. Escalate only on request. Per-puzzle Lvl 2 / Lvl 3 requests are one-off — they do NOT change the warning tier.

## 4. Every claim cites a source

Sources have weight. Live in-game observation > known-good wiki > YouTube comment > Reddit thread > vibes. Every fact links back to where it came from. Use [`templates/claim_format.md`](templates/claim_format.md) for the structured form. Claims that survived contradiction (tested, worked) outweigh claims never challenged.

## 5. Blocked sources are tracked, not abandoned

When a source is paywalled / Cloudflare-blocked / video-only, log it in `limitations.md` with the URL preserved. The reader can open it manually. Reach is finite; admit it.

## 6. Don't invent solutions

If no source has the answer, say so. Link the closest source. Suggest a way to find out (try it in-game, ask a community). Never fabricate steps that weren't in any source.

## 7. Persona is voice-only

A game-themed persona (a glove AI, a save-station terminal, a companion NPC) flavors the *delivery* of information. It must NEVER:
- Withhold information ("I'd tell you, but it's more fun to discover")
- Invent information to fit the character
- Override warning tiers
- Speak in serious / safety-relevant contexts (real-world tech issues, save corruption, money)

## 8. Platform/control translation

If reader's platform differs from a source's platform, translate. PC mouse+keyboard ≠ controller; mobile ≠ desktop. Note the reader's platform once in CHECKPOINT.md, translate every quoted instruction.

## 9. CHECKPOINT.md is the resumption surface

A fresh session — local, Cowork, or another contributor — should be able to resume by reading CHECKPOINT.md cold. Status, location, inventory, open threads, next step. Overwrite in place, ≤80 lines.

## 10. Each fact is structured for aggregation (load-bearing for the future aggregator)

Even when the prose reads naturally, every claim exposes: source, contributor, confidence, last-verified, `enemy-tier`, `puzzle-tier`, `category`. The reader doesn't need to see the metadata; the aggregator will. See [`templates/claim_format.md`](templates/claim_format.md). **Born-structured beats retrofitted-structured** — once the framework has thousands of claims across games, retrofitting metadata is a nightmare.

## 11. Spoiler discipline must propagate upstream (when distribution lands)

When guides are GitHub-distributed and multi-contributor, the aggregator must NOT propagate a spoiler-laden contribution into the spoiler-free canonical guide. Every claim and section needs explicit tier metadata (`enemy-tier` and `puzzle-tier`) so the merge is filterable. Single largest risk to the multi-contributor model — solve in template evolution before opening repos to outside contributors.

## 12. Transparent operations — no sneaking

Every action the framework takes is visible to the user. The non-technical user who pastes a setup command into their AI bot must be able to trust that:

- **No hidden dependencies** are installed without disclosure. If the framework needs Python, a CLI tool, or a package — say so, ask permission, and explain why.
- **No filesystem changes outside the declared scope.** The framework writes only to `hintforge/` and the per-game folder it creates. No edits to home dotfiles, system paths, or unrelated projects.
- **No background processes, daemons, or `phone-home` behavior.** The framework runs only when the user's AI bot is invoking it. Nothing schedules itself to run later. Nothing emits telemetry.
- **No privilege elevation.** No UAC prompts, no `sudo`, no admin rights. Everything lives in user-writable space.
- **Every web fetch is announceable.** When the framework researches a game (the auto-research bootstrap, when it ships), the URLs being fetched are surfaced to the user. The user can see what's being read and why.
- **No silent auto-commit / auto-push.** When git is used for distribution, pushing to a remote is always an explicit user action, never automatic.

The user is non-technical and trusts the framework by trusting the link they were sent. The framework must earn that trust by being inspectable in plain language. Easter eggs (passive flavor text) are fine; covert behaviors are not.

## 13. Token-aware execution

Heavy operations (game research, content sweeps, multi-source fetching) must be **opt-in with cost disclosure**, never auto-running by default.

**Why:** the framework's primary users are paid AI-bot subscribers. A Claude Pro user has roughly 45 messages per 5-hour window. If setup auto-launches research that burns 30–50 messages on day one, the user hits their cap before getting any guide value. Research and guide-use must be separable so the user can budget across both.

**How to apply:**
- Core setup wizard is lightweight (~10–15 turns max) when the user picks the default skips. It does **not** trigger research at completion.
- Research is invoked by an explicit user action (a slash command, a verbal "research the puzzles", a paste). The framework names the operation and offers size estimates: "minimal (~5 messages, top 3 topics)", "standard (~20 messages, all categories sketched)", "deep (~50+ messages, full coverage)".
- Per-question just-in-time research is fine and cheap — 1–2 fetches per asked question. That's how the guide normally fills in over time.
- Before any operation that will use ≥10 messages, surface the estimate and ask consent.
- The user may set a token-budget preference at setup ("I'm on Pro, keep heavy ops opt-in"; "I'm on Max, I don't mind if you use 50 messages"); store in CHECKPOINT.

**Heavy optional setup steps that should default to skipped on Pro tier** (each carries a ⚠️ warning in `setup_wizard.md`):
- **Save-watcher setup** (~10–30 messages) — parsing per-game save formats is trial-and-error; only worth it for users who want live save-state awareness.
- **Read-aloud / TTS hook** (~5–15 messages) — voice tuning is iterative; "TTS" should be defined in plain language at first mention since it's jargon to most users.
- **Standard or Deep research at setup time** (~20–50+ messages) — better to defer; per-question lookup covers the same ground spread over normal play.

The user on Pro should be able to run the full setup, ask 30 specific guide questions, and never approach their cap — because heavy operations only happen when they explicitly request them, and the wizard's defaults skip the heavy optional steps.

## 14. OS-portable + bot-portable by design

The framework is markdown + a structured-claim convention. **That core is portable.** What's locked to a specific environment:

- **Windows-specific:** TTS hook (Windows SAPI), default file paths, PowerShell snippets in setup
- **Claude-Code-specific:** `.claude/` hook configs, slash commands, certain skill formats
- **Cowork-specific:** the SessionStart/PreCompact hook reliance, Telegram dispatch

A Mac/Linux user, or a non-Claude AI bot, should be able to consume the markdown templates directly. OS-specific add-ons need contributor adaptation (TTS-on-macOS, save_watcher path defaults, bot-specific session-start mechanics). See [`os_compatibility.md`](os_compatibility.md) for the verified-running matrix and adaptation roadmap.

**The ask of any new contributor's environment:** read markdown, write markdown, fetch URLs, run a script. Anything beyond that is optional.

## 15. Median preferences + harm reduction

Defaults serve the most common player; opt-ins and tier controls protect the minority who want a different experience. Never degrade the default to accommodate an edge case — gate the edge case instead.

This is the *why* behind principles 1–3: spoiler-free defaults + request-based ladders + user-set tiers exist because the median reader wants to be surprised by the game, and the minority who want maximum guidance can lift the floor without imposing it on anyone else. When a future feature creates tension between two reader populations, the resolution is always the same shape: pick the default that serves the larger group, then build an opt-in for the other.

## 16. Source-side discipline

Prefer fewer high-quality canonical sources over many low-quality ones. A handful of authoritative references — patch notes, datamine dumps, the dev's own changelog, a wiki entry that's survived community editing — outweighs a dozen forum posts that all parrot one another. Volume isn't evidence; it's noise that looks like evidence.

Record what was searched and rejected, not just what was kept. A `limitations.md` entry that says "checked GameFAQs forum and two Reddit threads, three answers contradicted each other, none cited a save-file dump" is more useful than silently dropping those sources — both for the next contributor deciding whether to redo the search, and for the reader gauging how confident a claim really is. Principle #5 covers blocked sources; this one covers rejected ones.

Don't paper over thin sourcing with volume. Citing five YouTube comments doesn't make a fact more true than citing one. If three weak sources agree, that's still one weak claim, not three — agreement among echoes is a single source. When the canonical source isn't reachable, say so per Principle #5 and stop, rather than substituting a longer chain of weaker ones.

**How to apply:**
- Before logging a claim, ask: is there a more canonical source I haven't checked? Patch notes, datamines, dev posts, in-game text usually beat aggregator wikis, which beat forum posts, which beat vibes.
- When a search comes up empty or contradictory, log the search itself in `limitations.md` — query terms, sources checked, why they were rejected. This is the rejection trail; future searches start where this one stopped.
- Treat agreement among low-quality sources as a single weak source, not as N corroborating ones. The metadata `confidence: low` belongs on it.
- Don't pad citation lists. One strong source beside one weak one reads as ambiguous; one strong source alone reads as canonical.
