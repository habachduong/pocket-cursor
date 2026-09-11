# Changelog

Fork maintained by **Daniel Ha** (`duonghb@dataq.vn`) · GitHub: [habachduong/pocket-cursor](https://github.com/habachduong/pocket-cursor)

Upstream: [qmHecker/pocket-cursor](https://github.com/qmHecker/pocket-cursor) (MIT).

## Cursor compatibility

| Cursor IDE | Status | Notes |
|---|---|---|
| **3.19.x** (tested **3.19.13**, **3.19.19**) | Supported | Agent transcript DOM, Run/Skip, Windows CDP after update |
| 3.18 and older | Partial | Legacy `[data-click-ready]` still works; 3.19 DOM is the main path |
| Newer than 3.19 | Best-effort | UI class names change often — report issues with Cursor version |

## Windows: CDP after Cursor update (3.19.19+)

**Problem:** After Cursor updates itself, it often relaunches **without** `--remote-debugging-port`. Closing editor windows is **not** enough — dozens of `Cursor.exe` processes keep running in the background. On **Windows 11**, `wmic` was removed, so the old launcher thought Cursor was not running, opened a second window, and CDP never attached.

**Fix (this fork):**
- Detect Cursor via PowerShell `Get-CimInstance` (no `wmic`)
- Treat “flags in command line but `/json` dead” as **no CDP**
- `start_cursor_cdp.bat` force-kills all `Cursor.exe`, then launches with:
  `--remote-debugging-port=9222 --remote-debugging-address=127.0.0.1 --remote-allow-origins=http://localhost:9222`
- Clear messages: closing windows ≠ quitting Cursor

## Fork improvements — Daniel Ha

### 2026-09-11 (this machine)

- `start_pocket.bat`: one launcher — kill Cursor, wait for CDP port 9222, then start the Telegram bridge. Finds Node.js from a winget user install.
- `start_bridge.bat`: look up winget Node on PATH; venv hint uses `python -m venv`.
- Run/Skip on Telegram is **text + buttons only** (no markdown/card screenshot on each approval).
- `/mode`, `/ask`, `/agent`: switch Cursor Agent vs Ask from Telegram.
- Do not forward thinking / `Thought briefly` / Waiting to Telegram, so the main reply is not blocked behind status bubbles.

### Cursor 3.19 agent UI

- Read the new transcript (`data-message-role`, `data-message-kind`, `.markdown-root`) instead of removed Composer classes.
- Detect Run / Skip / Allowlist as `button.ui-button` and `ui-shell-tool-call__*-btn`, not only `[data-click-ready]`.
- Sanitize `data-tool-call-id` (two IDs separated by newline) so Telegram `callback_data` stays under 64 bytes.
- Scan **every** Cursor window each tick for pending Run/Skip, including cards skipped at monitor init.

### Confirmations on Telegram

- Short hash keys for inline buttons (`BUTTON_DATA_INVALID` fix).
- Single send path for approvals (scan + monitor) to avoid **duplicate** Run/Skip messages.
- Dedup by tool id and command text.
- After Run on Telegram **or** on the PC, remove Run/Skip and mark the message ✅ / ⏭.
- Pressing Run when Cursor already executed shows “already ran” and hides the buttons.

### Multi-window chats

- Remember per-chat progress. Switching back forwards the **latest turn** that happened while unfocused (DOM only keeps the last turn).
- Pending Run/Skip is scanned on all workspaces, not only the focused window.

### Thinking / waiting spam

- Consecutive `Thought briefly` / `Thought 2s` / `Thinking` / `Waiting` are **not** sent to Telegram (they used to collapse to one message; they still delayed the main text).

### Windows

- Find Cursor in `C:\Program Files\cursor\` as well as `%LOCALAPPDATA%`.
- `start_bridge.bat` / `start_cursor_cdp.bat` for local Python venv + Node on PATH.
- CDP reconnect when the eval WebSocket drops (`socket is already closed`).
- Bridge stays up if CDP is missing at start (Telegram poller still runs).

### Stability

- Do not `sys.exit` when CDP is down.
- Reconnect overview eval sockets and notify Telegram.
- Init skip no longer drops an already-visible pending Run forever.
