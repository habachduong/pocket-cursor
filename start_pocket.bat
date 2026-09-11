@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

set "PATH=%LOCALAPPDATA%\Programs\nodejs;%LOCALAPPDATA%\Programs\uv;%USERPROFILE%\.local\bin;%PATH%"
for /d %%D in ("%LOCALAPPDATA%\Microsoft\WinGet\Packages\OpenJS.NodeJS.LTS*\node-v*-win-x64") do set "PATH=%%D;%PATH%"
set "PUPPETEER_CACHE_DIR=%USERPROFILE%\.cache\puppeteer"

echo.
echo === PocketCursor: Cursor + CDP + Bridge ===
echo.
echo LUU Y: Chi dong cua so Cursor KHONG tat process.
echo Script nay se KILL toan bo Cursor.exe, mo lai co CDP,
echo doi CDP san sang, roi moi chay Telegram bridge.
echo.
echo Neu dang co unsaved work: Save truoc, roi nhan phim bat ky.
echo.
pause

if not exist ".venv\Scripts\python.exe" (
  echo LOI: thieu .venv. Chay: python -m venv .venv
  pause
  exit /b 1
)
if not exist ".env" (
  echo LOI: thieu file .env. Copy .env.example roi dien TELEGRAM_BOT_TOKEN.
  pause
  exit /b 1
)

echo.
echo [1/5] Kill toan bo Cursor.exe ...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='SilentlyContinue';" ^
  "1..8 | ForEach-Object {" ^
  "  Get-Process -Name 'Cursor' -ErrorAction SilentlyContinue | Stop-Process -Force;" ^
  "  Get-CimInstance Win32_Process -Filter \"Name='Cursor.exe'\" | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue };" ^
  "  Start-Sleep -Milliseconds 800;" ^
  "  if (-not (Get-Process -Name 'Cursor' -ErrorAction SilentlyContinue)) { exit 0 }" ^
  "};" ^
  "if (Get-Process -Name 'Cursor' -ErrorAction SilentlyContinue) { Write-Host 'VAN CON Cursor'; exit 1 } else { Write-Host 'Da tat het Cursor'; exit 0 }"

if errorlevel 1 (
  echo.
  echo LOI: Khong kill het Cursor. Mo Task Manager -^> End task "Cursor", roi chay lai.
  pause
  exit /b 1
)

timeout /t 2 >NUL

echo [2/5] Xac nhan khong con process...
powershell -NoProfile -Command "if (Get-Process -Name 'Cursor' -ErrorAction SilentlyContinue) { exit 1 } else { exit 0 }"
if errorlevel 1 (
  echo VAN CON Cursor.exe. Thu Task Manager End task, roi chay lai file nay.
  pause
  exit /b 1
)

echo [3/5] Mo Cursor + CDP...
".venv\Scripts\python.exe" start_cursor.py
if errorlevel 1 (
  echo.
  echo start_cursor.py that bai.
  pause
  exit /b 1
)

echo.
echo [4/5] Doi CDP (port 9222)...
set "CDP_OK=0"
for /L %%I in (1,1,20) do (
  if "!CDP_OK!"=="0" (
    echo Cho CDP... lan %%I/20
    powershell -NoProfile -Command "try { Invoke-WebRequest http://127.0.0.1:9222/json/version -UseBasicParsing -TimeoutSec 3 | Out-Null; exit 0 } catch { exit 1 }"
    if !errorlevel! EQU 0 (
      echo CDP OK
      set "CDP_OK=1"
    ) else (
      timeout /t 2 >NUL
    )
  )
)
if not "!CDP_OK!"=="1" (
  echo.
  echo CDP chua len sau ~40 giay. Chay lai file nay.
  pause
  exit /b 1
)

echo Doi Cursor UI load xong...
timeout /t 3 >NUL

echo.
echo [5/5] Bat Telegram bridge...
echo Cua so nay GIU MO — tat = Ctrl+C.
echo.
".venv\Scripts\python.exe" -X utf8 restart_pocket_cursor.py
if errorlevel 1 (
  echo.
  echo Bridge dung / loi. Xem dong ERROR phia tren:
  echo  - TELEGRAM_BOT_TOKEN = thieu token trong file .env
  echo  - CDP / Cursor       = Cursor chua mo duoc debug port 9222
  echo  - Telegram API       = mang/timeout toi api.telegram.org
  pause
)
endlocal
