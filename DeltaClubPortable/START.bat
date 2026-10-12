@echo off
setlocal
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\start.ps1" %*
if errorlevel 1 (
    echo.
    echo Startup failed. Read the message above before closing this window.
) else (
    echo.
    echo Startup finished. If the browser did not open, visit:
    echo   Admin: http://localhost:3000/login
    echo   H5:    http://localhost:5174/
)
pause
