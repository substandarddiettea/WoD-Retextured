
:: retextured v1.0 by foxware

::see the readme for info on usage.



@echo off
setlocal enabledelayedexpansion
:: "C:\Program Files (x86)\Steam\steamapps\common\War of Dots\assets\skins\countryballs"
:: config, mostly unimportant

cd /d "%~dp0"

set "WODROOT=C:\Program Files (x86)\Steam\steamapps\common\War of Dots"

set "GAME=%WODROOT%\game.exe"
for %%g in ("%GAME%") do set "GAME_NAME=%%~nxg"
set "IMGDIR=pack"
set "BACKUPDIR=backup"
set "REPLACEMENTDIR=%WODROOT%\assets\skins\countryballs"

:: ensures the script is running correctly
cd /d "%~dp0"

if not exist "%IMGDIR%" (
    echo [error] image pack not found: %IMGDIR%
    pause
    exit /b 
)
if not exist "%GAME%" (
    echo "[error] game not found: %GAME%,, whoops!"
    pause
    exit 
)


echo "launching %GAME%..."
start "" "%GAME%"
echo "[info] waiting 8 seconds for %GAME% to start fully"
timeout /t 8 /nobreak >nul

tasklist /fi "IMAGENAME eq %GAME_NAME%" 2>nul | find /i /n "%GAME_NAME%" >nul
if errorlevel 1 (
    echo "[error] it seems the game did not properly start, this may just be an issue with timings! please try again."
    pause
    exit /b 1
)

echo "[info] file verification bypassed! beginning file replacement..."

:: backs up the original files, then injects the new ones over the countryballs folder

echo "[info] backing up original files. if this is your first launch, it will take a while to set up."

if not exist "%BACKUPDIR%" mkdir "%BACKUPDIR%"

for %%f in ("%IMGDIR%\*.png") do (
    set "filename=%%~nxf"

    if exist "%REPLACEMENTDIR%\!filename!" (
        copy /y "%REPLACEMENTDIR%\!filename!" "%BACKUPDIR%\!filename!" >nul
    )

    copy /y "%%f" "%REPLACEMENTDIR%\!filename!" >nul
    echo "[info] replaced !filename!"
)

echo.
echo "[info] pack active, monitoring game status..."
echo "[info] DO NOT close this window while the game is running, or your original files will be lost!"

:MONITOR_LOOP
:: SPIES ON YOU!!! just kidding, it just checks if the game is still running
tasklist /fi "IMAGENAME eq %GAME_NAME%" 2>nul | find /i /n "%GAME_NAME%" >nul
if "%ERRORLEVEL%"=="0" (
    :: waiting 2 whole seconds to check again
    timeout /t 2 /nobreak >nul
    goto MONITOR_LOOP
)

:: cleans up the original files and restores them to the game folder
echo "[info] game closed, restoring original files..."
if exist "%BACKUPDIR%" (
    for %%f in ("%BACKUPDIR%\*.png") do (
        set "filename=%%~nxf"
        copy /y "%BACKUPDIR%\!filename!" "%REPLACEMENTDIR%\!filename!" >nul
        echo "[info] restored !filename!"
    )
    rmdir /s /q "%BACKUPDIR%"
)

echo "[info] original files restored, exiting..."
timeout /t 0.5 /nobreak >nul
exit /b
