@echo off
setlocal
cd /d "%~dp0"
echo.
echo Cursor dang mo se KHONG bat CDP duoc. Hay tat het cua so Cursor, roi chay file nay.
echo.
pause
".venv\Scripts\python.exe" start_cursor.py
endlocal
