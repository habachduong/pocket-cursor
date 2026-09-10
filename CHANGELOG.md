# Changelog

Fork maintained by **Daniel Ha** (`duonghb@dataq.vn`).

Upstream: [qmHecker/pocket-cursor](https://github.com/qmHecker/pocket-cursor) (MIT).

## Cursor compatibility

| Cursor IDE | Status | Notes |
|---|---|---|
| **3.19.x** (tested **3.19.13**) | Supported | Current target. Agent transcript, Run/Skip, thinking headers. |
| 3.18 and older | Partial | Legacy `[data-click-ready]` confirmations still work; 3.19 DOM is the main path. |
| Newer than 3.19 | Best-effort | UI class names change often — report issues with Cursor version. |

## Fork improvements — Daniel Ha

### Cursor 3.19 agent UI

- Read the new transcript (`data-message-role`, `data-message-kind`, `.markdown-root`) instead of removed Composer classes.
- Detect Run / Skip / Allowlist as `button.ui-button` and `ui-shell-tool-call__*-btn`, not only `[data-click-ready]`.
- Sanitize `data-tool-call-id` (two IDs separated by newline) so Telegram `callback_data` stays under 64 bytes.
- Scan **every** Cursor window each tick for pending Run/Skip, including cards skipped at monitor init.

### Confirmations on Telegram

- Short hash keys for inline buttons (`BUTTON_DATA_INVALID` fix).
- If Telegram rejects the keyboard, still send the command as text.
- After Run on Telegram **or** on the PC, remove Run/Skip and mark the message ✅ / ⏭.
- Pressing Run when Cursor already executed shows “Đã chạy trên Cursor” and hides the buttons.

### Multi-window chats

- Remember per-chat progress. Switching back forwards the **latest turn** that happened while unfocused (DOM only keeps the last turn).
- Pending Run/Skip is scanned on all workspaces, not only the focused window.

### Thinking / waiting spam

- Consecutive `Thought briefly` / `Thought 2s` / `Thinking` / `Waiting` collapse to **one** Telegram message.

### Windows

- Find Cursor in `C:\Program Files\cursor\` as well as `%LOCALAppData%`.
- `start_bridge.bat` / `start_cursor_cdp.bat` for local Python venv + Node on PATH.
- CDP reconnect when the eval WebSocket drops (`socket is already closed`).
- Bridge stays up if CDP is missing at start (Telegram poller still runs).

### Stability

- Do not `sys.exit` when CDP is down.
- Reconnect overview eval sockets and notify Telegram.
- Init skip no longer drops an already-visible pending Run forever.
