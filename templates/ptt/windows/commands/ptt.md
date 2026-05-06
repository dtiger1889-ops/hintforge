---
description: Start, stop, or check the push-to-talk daemon (Numpad+ to talk into Claude Code)
allowed-tools: Bash, PowerShell
argument-hint: [start|stop|status]
---

Run this PowerShell command. Report stdout to me verbatim in one short sentence — do not speak in persona, do not add commentary.

```
powershell -NoProfile -ExecutionPolicy Bypass -File ".claude/ptt_control.ps1" -Action "$ARGUMENTS"
```

If `$ARGUMENTS` is empty, the script defaults to `start`. Valid values: `start`, `stop`, `status`. The script is idempotent — running `/ptt` twice in a row will not double-launch the daemon.

> **Path note:** the relative path `.claude/ptt_control.ps1` resolves against the Claude Code session's current working directory, which should be the per-game folder. If the slash command fails with "file not found," verify the session is opened in `Guides/<game>/`, not somewhere else.
