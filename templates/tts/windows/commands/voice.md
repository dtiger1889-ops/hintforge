---
description: Toggle the TTS voice on/off for this session
allowed-tools: Bash, PowerShell
---

Run this command via the **Bash tool** (the PowerShell tool has been observed to fail silently with exit 1 and no output — Bash is the reliable path):

```
powershell.exe -NoProfile -Command "& '.claude/toggle_tts.ps1'"
```

Report the new state to the user in one short sentence (just "Voice ON" or "Voice OFF" — no extra commentary, do not speak in persona). The script's stdout is either "TTS ON" or "TTS OFF". The script also silences any in-progress speech as a side effect, so this also acts as a "stop talking now" button.

**TTS is independent of this command.** The TTS Stop hook is registered globally in `~/.claude/settings.json` and fires on every assistant turn unless `.claude/tts_disabled.flag` exists in the game folder. A failed `/voice` invocation tells you nothing about whether speech will play — speech may still work even if the toggle command errors. Do NOT tell the user "TTS is not running" based on a tool failure. To actually check whether TTS will fire, look at `test -f .claude/tts_disabled.flag` (present = disabled, absent = enabled).

**Do not infer state from a tool failure.** If the command returns no output or a non-zero exit, say "the script invocation failed" and probe with `pwd` and `test -f .claude/toggle_tts.ps1` to diagnose.

> **Path note:** the relative path `.claude/toggle_tts.ps1` resolves against the Claude Code session's current working directory, which should be the per-game folder. If `test -f` confirms the script is missing, verify the session is opened in `Guides/<game>/`, not somewhere else.
