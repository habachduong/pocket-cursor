@echo off
setlocal
cd /d "%~dp0"
set "PATH=%LOCALAPPDATA%\Programs\nodejs;%LOCALAPPDATA%\Programs\uv;%USERPROFILE%\.local\bin;%PATH%"
set "PUPPETEER_CACHE_DIR=%USERPROFILE%\.cache\puppeteer"
if not exist ".venv\Scripts\python.exe" (
  echo Missing .venv. Recreate with: uv venv --python 3.12
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
