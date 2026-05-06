---
description: Toggle the TTS voice on/off for this session
allowed-tools: Bash, PowerShell
---

Run this PowerShell command and report the new state to me in one short sentence (just "Voice ON" or "Voice OFF" — no extra commentary, do not speak in persona):

```
powershell -NoProfile -Command "& '.claude/toggle_tts.ps1'"
```

The script's stdout is either "TTS ON" or "TTS OFF". The script also silences any in-progress speech as a side effect, so this also acts as a "stop talking now" button.

> **Path note:** the relative path `.claude/toggle_tts.ps1` resolves against the Claude Code session's current working directory, which should be the per-game folder. If the slash command fails with "file not found," verify the session is opened in `Guides/<game>/`, not somewhere else.
