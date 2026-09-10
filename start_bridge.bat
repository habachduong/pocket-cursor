@echo off
setlocal
cd /d "%~dp0"
set "PATH=%LOCALAPPDATA%\Programs\nodejs;%LOCALAPPDATA%\Programs\uv;%USERPROFILE%\.local\bin;%PATH%"
set "PUPPETEER_CACHE_DIR=%USERPROFILE%\.cache\puppeteer"
if not exist ".venv\Scripts\python.exe" (
  echo Missing .venv. Recreate with: uv venv --python 3.12
  exit /b 1
)
echo Starting PocketCursor bridge...
".venv\Scripts\python.exe" -X utf8 pocket_cursor.py
if errorlevel 1 (
  echo.
  echo Bridge da dung. Neu bao thieu TELEGRAM_BOT_TOKEN, mo file .env va dan token vao dong TELEGRAM_BOT_TOKEN=
  pause
)
endlocal
