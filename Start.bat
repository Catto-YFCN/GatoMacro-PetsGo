@echo off
setlocal EnableDelayedExpansion
chcp 65001 > nul
cd %~dp0

:: Check if the AHK script and executable exist, then run the macro
if exist "main.ahk" (
    if exist "lib\AHK\AutoHotKey.exe" (
        if not [%~3]==[] (
            set /a "delay=%~3" 2>nul
            echo Starting main.ahk in !delay! seconds.
            <nul set /p =Press any key to skip . . .
            timeout /t !delay! >nul
        )
        start "" "%~dp0lib\AHK\AutoHotKey.exe" "%~dp0main.ahk" %*
        exit
    ) else (
        echo AutoHotkey executable missing.
        pause
    )
) else (
    echo AHK script main.ahk missing.
    pause
)
pause
