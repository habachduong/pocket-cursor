@echo off
setlocal
cd /d "%~dp0"
set "PATH=%LOCALAPPDATA%\Programs\nodejs;%LOCALAPPDATA%\Programs\uv;%USERPROFILE%\.local\bin;%PATH%"
REM Node.js from winget user install (portable zip)
for /d %%D in ("%LOCALAPPDATA%\Microsoft\WinGet\Packages\OpenJS.NodeJS.LTS*\node-v*-win-x64") do set "PATH=%%D;%PATH%"
set "PUPPETEER_CACHE_DIR=%USERPROFILE%\.cache\puppeteer"
if not exist ".venv\Scripts\python.exe" (
  echo Missing .venv. Recreate with: python -m venv .venv
  exit /b 1
)
echo Starting PocketCursor bridge (kill old instance if any)...
REM Always restart: avoids "already running" when a previous bridge is still alive
".venv\Scripts\python.exe" -X utf8 restart_pocket_cursor.py
if errorlevel 1 (
  echo.
  echo Bridge dung / loi. Xem dong ERROR phia tren:
  echo  - TELEGRAM_BOT_TOKEN = thieu token trong file .env
  echo  - CDP / Cursor       = chay start_cursor_cdp.bat truoc
  echo  - Telegram API       = mang/timeout toi api.telegram.org
  pause
)
endlocal
