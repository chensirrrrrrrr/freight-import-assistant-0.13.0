@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Launcher.ps1" -Action Status
if errorlevel 1 echo Operation failed. See the message above.
pause
