# OS + Bot Compatibility

What environments hintforge runs on today, and how to extend it elsewhere.

## Verified-running setup

Verified against a real per-game guide running on:

- **OS:** Windows 11 Pro
- **Shell:** bash + PowerShell available
- **AI bot:** Claude Code (CLI) + Claude Code Cowork sessions
- **Hooks:** SessionStart, PreCompact (Claude Code-specific)
- **TTS:** Windows SAPI (Microsoft Zira voice) via PowerShell

Everything else is **untested but designed to be portable**. Surface gaps in your per-game CHECKPOINT and propose template revisions via PR.

## What's portable vs. what's locked

### Universal (works anywhere)

- **All markdown content** — `principles.md`, templates, per-game guide files. Plain markdown, no OS or bot assumptions.
- **The structured-claim convention** — [`templates/claim_format.md`](templates/claim_format.md) is just markdown metadata. Any AI agent that reads markdown can parse it.
- **The hint ladder + warning tier system** — pure content discipline, no platform dependency.
- **The tier filter logic** (`enemy-tier` and `puzzle-tier`) — a future wiki generator could be written in any language for any OS.
- **The aggregator model** (planned) — language-agnostic; whoever builds it picks the stack.

### Windows-locked (today)

- **TTS hook:** the documented pattern uses Windows SAPI via a PowerShell hook script. The setup wizard scaffolds one for Windows users. Mac (`say`) and Linux (`espeak` / `festival`) hook variants are not yet specified. Contribution opportunity.
- **Default file paths:** templates currently show `C:\Users\<user>\Documents\Claude\<game>\` style paths. The setup wizard ([`setup_wizard.md`](setup_wizard.md)) parameterizes workspace root so the user's actual path goes in. Mac/Linux users supply `~/Claude/<game>/` or wherever.
- **PowerShell snippets** in some scripts (e.g. timestamp generation: `[System.DateTime]::UtcNow.ToString(...)`). Trivial to translate to bash (`date -u +"%Y-%m-%d %H:%M UTC"`).
- **Save game directory defaults:** Windows games typically save to `C:\Users\<user>\AppData\Local\<GAME>\` or `%APPDATA%\<GAME>\`. Mac save locations (often `~/Library/Application Support/<game>/`) and Linux (often `~/.local/share/<game>/` or via Proton `~/.steam/steam/steamapps/compatdata/<id>/pfx/...`) need per-game research. The setup wizard parameterizes save-dir input rather than baking platform assumptions.

### Claude-Code-locked (today)

- **`.claude/settings.json` hook configs.** SessionStart, PreCompact, Stop hooks are a Claude Code feature. Other AI bots have analogous mechanisms (e.g. system prompts, custom instructions, MCP server integrations) but the wiring is bot-specific.
- **Slash commands** (e.g. `/loop`, `/schedule`). Claude Code-specific; the framework doesn't currently rely on any, but instantiated guides may want them.
- **Skill files** (`.skill` archives). Claude Code-specific packaging.

### Cowork-locked (today)

- **Telegram dispatch + scheduled tasks.** Cowork-specific; the framework doesn't require them. Instantiated guides may use them for "remind me about my open thread weekly" style ergonomics, but it's optional.
- **`SessionStart` hook auto-printing CHECKPOINT.md.** Useful but not required — without it, the user just opens CHECKPOINT.md manually. The AI bot follows the same startup sequence either way.

## Bot-portability: what any AI agent needs to consume hintforge

Minimum capability bar for an AI agent to be a useful hintforge contributor or consumer:

1. **Read markdown files** in a folder structure
2. **Write markdown files** (create/edit, with line-precise edits ideally)
3. **Fetch URLs** for source-citation lookup (research; aggregator)
4. **Run a script** (Python or shell) for optional save_watcher / setup wizard
5. **Take user input across multiple turns** (for the setup wizard)

Anything beyond that is bonus. Notably **NOT required**: vision (no screenshots needed for core flow), code execution sandboxing, persistent memory across sessions (CHECKPOINT.md is the persistence layer), or specific tool-use protocols.

Bots known to clear the bar today:
- Claude Code (verified-running)
- Claude Desktop (markdown-aware via files; setup wizard via slash command would be Phase-3 work)
- Cursor / Continue / Aider (markdown-aware code agents — would work for content edits, not yet tested for the full guide flow)
- Custom MCP-enabled bots (anything with file-system tools)

Bots that probably can't (today):
- Pure chat-only LLMs without filesystem tools (ChatGPT web, vanilla Claude.ai) — they could *help write* a guide but couldn't maintain one
- Voice-only assistants (no markdown read/write)

## Adaptation roadmap

When hintforge ships GitHub publishing, each per-game repo should include:

1. **A platform-aware setup wizard** that detects OS and prompts appropriately (file path defaults, TTS availability, etc.)
2. **A bot-detection step** that identifies which AI agent is reading the repo and surfaces compatibility caveats
3. **A `compatibility.md`** in the repo root that mirrors this file's structure for that specific game

The future aggregator should:

1. Run as a CI job (GitHub Actions, GitLab CI, etc.) — language-agnostic on the merge side
2. Accept contributions from any AI bot regardless of OS, as long as commits parse against [`templates/claim_format.md`](templates/claim_format.md)

## How to extend hintforge to a new platform

If you're running a non-Windows OS or a non-Claude bot:

1. **Use the framework as-is for content** — markdown templates work everywhere.
2. **Skip the locked add-ons** that don't apply (TTS hook, `.claude/` configs).
3. **Adapt path defaults** in your local setup — point the wizard at your actual filesystem layout.
4. **Document your gaps** in your per-game CHECKPOINT under "Adaptation notes" so the next person hitting the same OS/bot has a head start.
5. **Propose template revisions** if you find anything in the universal layer that turned out to be Windows-leaking. PR back to hintforge.

## Honest disclosure for shared guides

Any per-game guide published to GitHub should include a "Tested on:" line in its README:

```
Tested on: Windows 11 + Claude Code + Cowork
Likely-works on: Mac/Linux + Claude Code, Claude Desktop, Cursor, any markdown-aware AI agent
Known gaps: TTS hook is Windows-only; save_watcher paths assume Windows defaults
```

This sets honest expectations and invites contribution to fill the gaps.
