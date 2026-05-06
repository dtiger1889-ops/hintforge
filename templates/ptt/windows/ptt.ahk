; Push-to-talk for Claude Code. Hold Numpad+ to record; release to transcribe and send.
; Requires AutoHotkey v2. Pairs with ptt_daemon.py (must be running).
;
; Architecture: this script signals the Python daemon via flag files in %TEMP%.
; Daemon does the actual mic capture and Whisper transcription, leaving this
; script as a thin hotkey + window-management layer.

#Requires AutoHotkey v2.0
#SingleInstance Force
SetTitleMatchMode 2  ; substring matching for window titles

; --- Config ---
START_FLAG  := A_Temp . "\ptt_start.flag"
STOP_FLAG   := A_Temp . "\ptt_stop.flag"
RESULT_FILE := A_Temp . "\ptt_result.txt"
READY_FILE  := A_Temp . "\ptt_ready.flag"

; --- Hotkey configuration ---
;
; CHANGE THIS to whichever key you want to hold to talk. The default is
; Numpad+ which only works on full-size keyboards with a numpad. If you
; don't have one, here are common alternatives:
;
;   "CapsLock"      ; capslock key (usually unused; common PTT pick)
;   "F13"           ; F13 key (rare on keyboards but available via macros / keyboard remappers)
;   "ScrollLock"    ; scroll lock (also commonly unused)
;   "RAlt"          ; right alt
;   "AppsKey"       ; the menu/applications key (right of right-alt on some keyboards)
;   "MButton"       ; middle mouse button (if your mouse has one and you don't already use it)
;   "XButton1"      ; mouse side button 1 (common on gaming mice)
;   "XButton2"      ; mouse side button 2
;
; AVOID:
;   - keys you use in-game (you'd toggle PTT instead of doing the in-game action)
;   - common modifiers (Ctrl, Alt, Shift, Win) — they break key combos
;   - letters/numbers — they'd intercept normal typing
;
; Full key reference: https://www.autohotkey.com/docs/v2/KeyList.htm
;
; The leading `*` makes the hotkey fire even with modifier keys held — important
; for talking while holding gameplay modifiers like sprint or crouch.
PTT_HOTKEY := "NumpadAdd"  ; <-- CHANGE THIS LINE

; Window match candidates for Claude Code desktop app. First match wins.
; "Claude ahk_exe claude.exe" requires both: window title contains "Claude"
; AND process is claude.exe — disambiguates the desktop app from the CLI
; (which is also named claude.exe but has no titled window).
CLAUDE_MATCHES := ["Claude ahk_exe claude.exe", "ahk_exe Claude.exe"]

; Exit hotkey (Ctrl+Alt+Q to quit the AHK script)
^!q::ExitApp()

; --- Hotkey handler ---
; Uses KeyWait instead of separate Up/Down handlers so we ignore keyboard
; auto-repeat ticks — the press handler runs once, blocks on KeyWait until
; physical release, then triggers transcription. This survives keyboards that
; emit synthetic up/down pairs during a hold.
;
; The HotIf-style dynamic registration below uses PTT_HOTKEY from above.
Hotkey "*" . PTT_HOTKEY, PttHandler

PttHandler(thisHotkey) {
    global PTT_HOTKEY, READY_FILE, RESULT_FILE, START_FLAG, STOP_FLAG, CLAUDE_MATCHES
    if !FileExist(READY_FILE) {
        ; Daemon not yet ready (still loading model). Silently ignore.
        return
    }

    ; Clear stale result, signal daemon to start.
    if FileExist(RESULT_FILE)
        FileDelete(RESULT_FILE)
    FileAppend("", START_FLAG)

    ; Block until the key is physically released. KeyWait polls real key
    ; state, so auto-repeat down-events during a hold are ignored.
    KeyWait(PTT_HOTKEY)

    ; Signal daemon to stop and transcribe.
    FileAppend("", STOP_FLAG)

    ; Wait for daemon to finish (max 10s).
    timeout := 10000
    elapsed := 0
    while (!FileExist(RESULT_FILE) && elapsed < timeout) {
        Sleep(50)
        elapsed += 50
    }
    if !FileExist(RESULT_FILE)
        return

    text := FileRead(RESULT_FILE, "UTF-8")
    FileDelete(RESULT_FILE)
    text := Trim(text)
    if (text = "")
        return

    ; Find Claude Code window.
    claudeHwnd := 0
    for match in CLAUDE_MATCHES {
        h := WinExist(match)
        if (h) {
            claudeHwnd := h
            break
        }
    }
    if (!claudeHwnd)
        return  ; Claude Code not running

    ; Save current foreground window so we can restore focus afterward.
    prevHwnd := WinGetID("A")

    ; Activate Claude, paste, send Enter, refocus prior.
    A_Clipboard := text
    WinActivate("ahk_id " . claudeHwnd)
    WinWaitActive("ahk_id " . claudeHwnd, , 0.7)
    Sleep(40)
    Send("^v")
    Sleep(60)
    Send("{Enter}")
    Sleep(60)
    if (prevHwnd && prevHwnd != claudeHwnd)
        WinActivate("ahk_id " . prevHwnd)
}
