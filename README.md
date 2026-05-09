# Hintforge

**An agentic framework for spoiler-controlled, activity-tracking game guides.**

A guide for any game, on any system, where you choose how much help you want and it logs your progress so you can pick up easily even after a long time away. It's a loyal sidekick — customized to your spoiler preferences and interaction style — that tags along and helps you out. Markdown + structured-claim convention, OS- and agent-agnostic, consumed by a local AI agent that reads and writes files you control.

---

## What hintforge does — today and planned

**Working today** (verified on Windows 11 + Claude Desktop, Pro/Max tier):

- ✅ Two-dial, user-controlled assistance: enemy tier 0–5 + puzzle tier 0–3, set at setup, changeable any time.
- ✅ Spoiler-free defaults with a request-based hint ladder (Lvl 1 nudge → Lvl 2 → Lvl 3 step-by-step).
- ✅ Persona-flavored delivery — a game-themed voice layer that flavors *how* information is delivered, never *what*.
- ✅ Structured-claim citation format — every fact carries source, contributor, confidence, last-verified, and tier metadata, written in a form a future aggregator can parse.
- ✅ One-paste setup wizard with optional pre-fill (`setup_answers.txt`) — answer in a text file ahead of time for the cheapest possible setup, or leave it blank and the wizard asks you live.
- ✅ Three opt-in capability modules:
  - **PTT** (push-to-talk) — hold a hotkey to talk to the agent via local Whisper transcription.
  - **TTS** (read-aloud) — Stop hook speaks each agent reply through your speakers in a persona-aware voice.
  - **save-watcher** — reads the game's save file at session start to populate location / inventory / state into the agent's context.
- ✅ Transparent file-scope design — the framework instructs the agent to confine writes to the framework folder and the per-game folder; no telemetry, no daemons, no privilege elevation, no auto-commits.
- ✅ Token-heavy operations (research, content sweeps) are opt-in and flagged before they run; the default is "ask as questions arise" rather than batching research up front. For deep research specifically, see the handoff path below — works with Claude's built-in Research, Gemini Deep Research, ChatGPT Deep Research, or Perplexity.
- ✅ Stale-session detection — when a fresh session opens on a guide last played >30 days ago, the bot offers a controls + open-thread refresher before resuming. Default threshold 30 days, configurable; safe default is "yes refresh" if the user gives no answer.

**Roadmap:**

- 🗺 Multi-contributor aggregator with percentage-based truth — multiple players' agents push observations to a per-game repo; the aggregator weighs claims by source quality and contributor track record and emits a canonical guide.
- 🗺 Static HTML wiki generator with reader-side tier filters — replaces fan-wiki sites with consensus-merged, spoiler-controlled output.
- 🗺 Pluggable persona library + cross-platform TTS (macOS `say`, Linux `piper`).
- 🗺 Screenshot-by-command (`/screenshot` slash command + vision-model interpretation of the focused window).
- 🗺 Mobile / hands-free voice loop — extend PTT/TTS so a player can walk around with phone + headphones and talk to the guide.
- 🗺 Offline + local-LLM mode with periodic deep-research drip-feed from generous online free tiers.
- 🗺 Mod awareness & suggestions — optional, token-heavy add-in. Recommends mods by category (QOL, cosmetic, add-ins); surfaces community picks on demand; contextually checks for QOL mods when a player flags something in the game as annoying. Complete-overhaul mods are out of scope (they make the guide itself obsolete).
- 🗺 Steam integration (opt-in, privacy-first) — supply your own Steam Web API key to mine your owned-games + playtime + achievement history into a personal playstyle profile, ground recommendations in what you actually play, and track achievement progress alongside the active guide. Key stays on your machine; no third-party server, no telemetry, no account linkage beyond the calls you authorize. Read-only against the public Steam Web API; off by default.
- 🗺 SKILL.md portability refactor — restructure the framework so each guide repo is natively consumable as a SKILL.md-spec agent skill, making hintforge portable to OpenClaw, Codex CLI, and Cursor agents without modification. Currently Claude Code-native; SKILL.md compatibility is planned and the architecture is designed with this in mind.

---

## Why hintforge exists

Fan-wiki pages dump every spoiler on you the moment you land — assuming you can see the page through the ads. There's no setting for "I want a hint about *this* puzzle but not the boss fight in two hours."

hintforge inverts that: **information is opt-in.** Want more? Ask. Want less? Lower the tier back down.

**Remembering where you left off can be difficult.** Complex games demand a lot up front: crafting systems, skill trees, gear builds, hotkey layouts you spent an hour customizing. Then life happens. Come back six weeks later and you're staring at a skill tree you don't recognize, a control layout you've half-forgotten, and quest context that's gone cold. The usual workaround is Googling "how do I play X again" and landing on a five-year-old forum post that's slightly wrong for the current patch. hintforge keeps that context alongside your save — when you tell it you're returning after a break, it reconstructs what you had going without spoiling where the story goes. No plot hints. No boss previews. Just "here's your build, here's what you were doing, and here are the four buttons you always forget."

It's also designed as a framework for **multi-contributor truth aggregation** — players' agents push observations to a shared repo, an aggregator merges them into percentage-based truth, and a static HTML wiki gets generated. Not there yet, but guides created with this framework are meant to be not only shareable but mergeable.

---

## Quick start

### What you need

- **A local AI agent that reads and writes markdown in folders you control.** hintforge is intended to run on any such agent. It's been tested on **Claude Desktop on Windows 11, Pro/Max tier**, which is the supported recipe today. Other surfaces — Claude Code (CLI), Cursor, Aider, MCP-enabled bots — should work but are untested.

- **Don't use Cowork or browser claude.ai for this.** Files don't persist locally between sessions, which breaks the framework's whole storage model. More importantly, Cowork tends to *hallucinate* framework rules instead of loading and following the per-folder `CLAUDE.md` file the framework relies on. The supported agent acts as an interactive file reader: it loads the framework's `CLAUDE.md` on startup and is instructed to stay inside the rules it finds there and confine writes to the declared folder scope. The wizard is designed to detect an unsupported environment and warn before doing any work. **If you're going to use another agent,** you'll need to rename the `CLAUDE.md` files to whatever that system reads first when opening a project directory.

### Recommended path: pre-fill `setup_answers.txt`

**If you want to reduce agent work,** open `setup_answers.txt` in any text editor and fill in what you can — game name, what you want the agent to call you, hint tiers, etc. Anything filled in there, the wizard skips the live question for. Anything left blank, it asks live.

If you skip the pre-fill, the wizard attempts to batch the remaining questions into one popup (or one chat message if the agent doesn't support popups) — answer them all together and setup finishes in two or three messages instead of nine.

### Setup scales to your token budget

Two paths:

- **Cheapest:** pre-answer `setup_answers.txt` yourself, then paste the prompt below. The wizard skips every question already answered and runs near-silently.
- **Most interactive:** open the folder in Claude Desktop and tell the agent to start with one prompt. It walks you through every question live.

Heavy optional modules (save-watcher, read-aloud / TTS, batch research) can be skipped on low usage caps like Claude Pro tier, and `setup_answers.txt` defaults them to skipped so the heavy modules don't run without your say-so. Ask your agent after step 10 to set them up if you want them. See [`principles.md`](principles.md) #13 for the full token-aware-execution stance.

### Deep-research handoff

If you have access to a deep-research tool — Claude's built-in Research, Gemini Deep Research, ChatGPT Deep Research, or Perplexity — hintforge can hand off the heaviest research step to whichever one you prefer. This is the default in `setup_answers.txt` (`research = handoff`).

Round-trip: Claude writes a brief to `<game>/research_brief.txt` → you paste it into the external tool → save the result file into `<game>/research_inbox/` → in a fresh Claude session say `ingest the research` and Claude distributes it into the guide's subfolders with source-tagged metadata. Step-by-step instructions for the file-drop are in [`OPEN ME if new to AI - How to prompt claude code.txt`](./OPEN%20ME%20if%20new%20to%20AI%20-%20How%20to%20prompt%20claude%20code.txt).

**Shortcut for claude.ai users:** if your plan supports Research mode + the Filesystem connector, paste the brief into a Research-mode chat with Filesystem enabled and tell it the absolute path to `<game>/research_inbox/p1/`. Claude can write the result file directly into the inbox folder — no manual copy/save step. Add `"don't summarize, only put it in the brief file"` to keep the chat clean while the artifact lands on disk. Then open a fresh Claude Code session at `<game>/` and say `ingest the research`.

### The pastable prompt

In Claude Desktop, paste the message between the lines below. Replace `[GAME]` (in two places) with the name of the game.

---

```
Hi Claude, please get the hintforge framework from
https://github.com/dtiger1889-ops/hintforge into my
~/Documents/hintforge/ folder. If I have git installed,
clone it; if not, just download the files via HTTP.

Then:

1. Read ~/Documents/hintforge/setup_answers.txt — I may
   have pre-filled some answers there. Use those instead
   of asking me live for the same things. If the file is
   missing or fields are blank, ask me live for those.
2. Read ~/Documents/hintforge/setup_wizard.md and walk
   me through anything still missing, in plain English.
3. I want to use it for [GAME].
4. Don't change anything outside ~/Documents/hintforge/
   and the new game folder you'll create at
   ~/Documents/Guides/<game>/.
5. After setup, just be ready to answer my questions
   about [GAME].

Tell me before doing anything that touches files, and
explain each step in plain English before doing it.
```

---

If someone shared a ZIP of this folder with you instead of a GitHub link, open `OPEN ME if new to AI - How to prompt claude code.txt` inside the ZIP for the same flow without GitHub.

---

## How the tiers work

Two independent dials. Set at setup, changed any time by saying "set my puzzle tier to 2" or similar.

### Enemy help tier (0–5)

| Tier | What you'll see |
|---|---|
| **0** | No warnings before fights. Surprises stay surprises. |
| **1** | Mob types named in route hints. Bosses still hidden. |
| **2** | Boss-fight existence flagged. No boss details. |
| **3** | Boss generically named + loadout suggestions. |
| **4** | + Crafting materials to stock before the fight. |
| **5** | Full move-by-move boss strategy. |

### Puzzle help tier (0–3)

| Tier | What you'll see |
|---|---|
| **0** | Silent until you ask. |
| **1** | On entry, the agent names the *kind* of puzzle. Doesn't volunteer hints. |
| **2** | + Automatic Lvl-1 nudge on entry. |
| **3** | + Automatic full step-by-step on entry. |

Independent of tiers, you can always escalate a specific puzzle by asking: "Lvl 1 hint please" → "Lvl 2" → "Lvl 3 step-by-step." That's a one-off, not a tier change.

---

## Principles — what shapes the framework

Load-bearing rules summarized. Full set (16 principles + rationale) in [`principles.md`](principles.md).

**User-controlled assistance is the backbone, not a feature.** The two tiers are first-class state, not a setting hidden in a config screen. Every other rule (spoiler discipline, the hint ladder, persona constraints) only makes sense in service of reader agency over information flow. Inverting the fan-wiki "spoil-everything-by-default" model is what hintforge exists to do.

**Spoiler-free defaults + a request-based hint ladder.** Until the reader raises a tier, the guide names puzzle types only when the reader is staring at one, names enemies only post-encounter, and never reveals story beats or boss existence. When the reader asks for help, the agent delivers the smallest possible nudge first (Lvl 1) and escalates only on request. The reader's curiosity ceiling is the only one that escalates.

**Every claim cites a source, in a structured form.** Sources have weight: live in-game observation > known-good wiki > YouTube comment > Reddit thread > vibes. Every fact links back to where it came from, and the metadata (source, contributor, confidence, last-verified, tier) is structured even when the prose reads naturally. This is load-bearing for the future aggregator — claims born structured beat claims retrofitted later, because once the framework has thousands of claims across games, retrofitting metadata is a nightmare.

**Median preferences + harm reduction.** Defaults serve the most common player; opt-ins and tier controls protect the minority who want a different experience. Defaults never degrade to accommodate an edge case — gate the edge case instead. This is the *why* behind the spoiler-free defaults: the median reader wants to be surprised by the game, and the minority who want maximum guidance can lift the floor without imposing it on anyone else. When two reader populations are in tension, the resolution is always the same shape: pick the default that serves the larger group, then build an opt-in for the other.

**Transparent operations — no sneaking.** The non-technical user who pastes a setup command into their AI bot must be able to trust the framework. That trust comes from two layers:

What the framework code itself contains (verifiable by reading the repo):
- No hidden dependencies installed by setup scripts.
- No background processes, daemons, or "phone home" behavior.
- No privilege elevation — no UAC, no `sudo`, no admin rights. Everything in user-writable space.
- No silent auto-commit / auto-push baked into any script. Git is only used at explicit request.

What the framework instructs the agent to do (relies on the agent following the rules in `CLAUDE.md`):
- Confine filesystem changes to the declared scope (`~/Documents/hintforge/` and the per-game folder it creates).
- Announce web fetches before running them.
- Announce file-touching actions before doing them.

The reader is non-technical and trusts the framework by trusting the link they were sent. The framework earns that trust by being inspectable in plain language. Easter-egg flavor text is fine; covert behavior is not.

**Token-aware execution.** Token-heavy operations (game research, content sweeps, multi-source fetching) are opt-in and flagged before they run. The primary users are paid AI-bot subscribers on capped plans — if setup auto-launches a research burst on day one, the reader hits their cap before getting any guide value. Research and guide-use are separable so the reader can budget across both. The setup wizard is lightweight by default; heavy optional steps (save-watcher, read-aloud / TTS, batch research) default to skipped on Pro tier.

**OS-portable + bot-portable by design.** The markdown core (templates, principles, claim format, tier logic) is portable anywhere. What's locked to a specific environment is quarantined: TTS hook (Windows SAPI), default file paths (Windows-flavored), PowerShell snippets in some scripts, and Claude-Code-specific hook configs in the optional modules. A non-Windows reader, or a non-Claude AI bot, can consume the markdown layer directly; OS-specific add-ons need contributor adaptation. The minimum capability bar for a useful agent: read markdown, write markdown, fetch URLs, run a script, take user input across multiple turns. See [`os_compatibility.md`](os_compatibility.md) for the full portability matrix.

---

## Status & compatibility

**Verified-running:**
- Windows 11 + Claude Desktop, Pro/Max tier — the supported recipe.

**Untested but designed to work** (the framework is intended to run here; gaps are likely):
- Windows 11 + Claude Code (CLI).
- Mac / Linux + Claude Desktop or Claude Code (markdown core is OS-agnostic; OS-specific add-ons will need adaptation).
- Other markdown-aware AI agents with persistent local filesystem access — Cursor, Aider, MCP-enabled bots.

**Known gaps:**
- TTS / read-aloud hook is Windows SAPI + edge-tts only today. Mac (`say`) and Linux (`piper`) variants are roadmap.
- Save-game default paths only enumerated for Windows.
- PowerShell snippets in some scripts; bash translations are trivial but unwritten.
- No installer wrapper yet — setup runs via the natural-language paste above.

**Known incompatibilities:**
- **Cowork** (Anthropic collaborative workspace) — session-scoped (files don't persist locally), and tends to hallucinate framework rules instead of loading and following the per-folder `CLAUDE.md`. The wizard is designed to detect this and warn before doing any work.
- **claude.ai in a browser** without a filesystem connector — same persistence problem.

Full portability matrix in [`os_compatibility.md`](os_compatibility.md).

---

## Folder map

| File | Purpose |
|---|---|
| [`CLAUDE.md`](CLAUDE.md) | Framework definition + hard rules (the file your AI agent reads on startup) |
| [`principles.md`](principles.md) | All 16 universal rules with rationale |
| [`setup_wizard.md`](setup_wizard.md) | First-run prompt-flow spec — the wizard your AI walks you through |
| [`os_compatibility.md`](os_compatibility.md) | Verified-running setup + portability roadmap |
| [`distribution.md`](distribution.md) | GitHub + aggregator + wiki-gen long-term vision |
| [`instantiation.md`](instantiation.md) | Manual setup flow (for advanced users who want to skip the wizard) |
| [`OPEN ME if new to AI - How to prompt claude code.txt`](./OPEN%20ME%20if%20new%20to%20AI%20-%20How%20to%20prompt%20claude%20code.txt) | Plain-text onboarding for users who got a ZIP-share instead of cloning |
| [`templates/`](templates/) | Skeletons the wizard copies + fills when you instantiate a new game (includes `ptt/`, `tts/`, `save_watcher/` optional modules) |

---

## Contributing

A full `CONTRIBUTING.md` lands alongside the multi-contributor aggregator — see [`CONTRIBUTING.md`](CONTRIBUTING.md) for the current stub (license inheritance + pointer back here). For now:

- Found a missing template field, an OS that doesn't work for you, or a content-discipline gap? Open an issue.
- PRs welcome — the framework's hard rules (in [`CLAUDE.md`](CLAUDE.md) and [`principles.md`](principles.md)) are the bar. Anything that violates spoiler discipline, transparent operations, or token-aware execution is a regression.

---

## License

Licensed under [CC BY-NC-SA 4.0](LICENSE). Free for personal, non-commercial, and creator use — share, remix, and adapt with attribution; derivatives must use the same license.

Commercial licensing available on request — see [`LICENSE`](LICENSE) for contact details.
