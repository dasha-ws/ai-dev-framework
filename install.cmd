@echo off
rem Windows launcher only. All installation logic lives in scripts\install.ps1.
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\install.ps1"
set "INSTALL_EXIT=%ERRORLEVEL%"
pause
exit /b %INSTALL_EXIT%
