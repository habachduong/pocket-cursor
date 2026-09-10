@echo off
setlocal EnableExtensions
cd /d "%~dp0"

echo.
echo === PocketCursor: mo Cursor voi CDP ===
echo.
echo LUU Y: Chi dong cua so Cursor KHONG tat process.
echo Cursor thuong con chay ngam ^(tray / background^).
echo Script nay se KILL toan bo Cursor.exe roi mo lai co CDP.
echo.
echo Neu dang co unsaved work: Save truoc, roi nhan phim bat ky.
echo.
pause

echo.
echo [1/4] Kill toan bo Cursor.exe ...
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

echo [2/4] Xac nhan khong con process...
powershell -NoProfile -Command "if (Get-Process -Name 'Cursor' -ErrorAction SilentlyContinue) { exit 1 } else { exit 0 }"
if errorlevel 1 (
  echo VAN CON Cursor.exe. Thu Task Manager End task, roi chay lai file nay.
  pause
  exit /b 1
)

echo [3/4] Mo Cursor + CDP...
if not exist ".venv\Scripts\python.exe" (
  echo LOI: thieu .venv
  pause
  exit /b 1
)

".venv\Scripts\python.exe" start_cursor.py
if errorlevel 1 (
  echo.
  echo start_cursor.py that bai.
  pause
  exit /b 1
)

echo.
echo [4/4] Kiem tra CDP...
powershell -NoProfile -Command ^
  "try {" ^
  "  $r = Invoke-WebRequest http://127.0.0.1:9222/json/version -UseBasicParsing -TimeoutSec 8;" ^
  "  Write-Host 'CDP OK'; Write-Host $r.Content; exit 0" ^
  "} catch {" ^
  "  Write-Host 'CDP FAIL:' $_.Exception.Message; exit 1" ^
  "}"
if errorlevel 1 (
  echo.
  echo CDP chua len. Chay lai file nay.
  pause
  exit /b 1
)

echo.
echo OK — CDP san sang. Chay start_bridge.bat
pause
endlocal
