
:: retextured v1.0 by foxware

:: see the readme for info on usage.


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
set "COUNTRYBALLSDIR=%WODROOT%\assets\skins\countryballs"
set "COLDWAR_DIR=%WODROOT%\assets\skins\coldwar"
set "AGINCOURT_DIR=%WODROOT%\assets\skins\agincourt"

:: ensures the script is running correctly
cd /d "%~dp0"

if not exist "%IMGDIR%" (
    echo [error] image pack not found: %IMGDIR%
    pause
    exit /b 
)
set "PACKCOUNT=0"
for /d %%d in ("%IMGDIR%\*") do (
    set /a PACKCOUNT+=1
    set "PACK!PACKCOUNT!=%%~fd"
    set "PACKNAME!PACKCOUNT!=%%~nxd"
)
if "%PACKCOUNT%"=="0" (
    echo [error] no pack folders found in %IMGDIR%
    pause
    exit /b 1
)

echo.
echo [info] available packs:
for /l %%n in (1,1,%PACKCOUNT%) do echo %%n. !PACKNAME%%n!
echo.
set "PACKCHOICE="
set /p "PACKCHOICE=select a pack for countryballs (blank to skip): "
if defined PACKCHOICE call set "COUNTRYBALLSPACK=%%PACK!PACKCHOICE!%%"
set "PACKCHOICE="
set /p "PACKCHOICE=select a pack for coldwar (blank to skip): "
if defined PACKCHOICE call set "COLDWARPACK=%%PACK!PACKCHOICE!%%"
set "PACKCHOICE="
set /p "PACKCHOICE=select a pack for agincourt (blank to skip): "
if defined PACKCHOICE call set "AGINCOURTPACK=%%PACK!PACKCHOICE!%%"
if not defined COUNTRYBALLSPACK if not defined COLDWARPACK if not defined AGINCOURTPACK (
    echo [error] no packs selected
    pause
    exit /b 1
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
    echo "[info] restoring original files..."
    if defined COUNTRYBALLSPACK call :RESTORE_PACK "%BACKUPDIR%\countryballs" "%COUNTRYBALLSDIR%"
    if defined COLDWARPACK call :RESTORE_PACK "%BACKUPDIR%\coldwar" "%COLDWAR_DIR%"
    if defined AGINCOURTPACK call :RESTORE_PACK "%BACKUPDIR%\agincourt" "%AGINCOURT_DIR%"
    if exist "%BACKUPDIR%" rmdir /s /q "%BACKUPDIR%"
    pause
    exit /b 1
)

echo "[info] file verification bypassed! beginning file replacement..."

:: backs up the original files, then injects the new ones over the countryballs folder

echo "[info] backing up original files. if this is your first launch, it will take a while to set up."

if not exist "%BACKUPDIR%" mkdir "%BACKUPDIR%"

if defined COUNTRYBALLSPACK call :REPLACE_PACK "!COUNTRYBALLSPACK!" "%COUNTRYBALLSDIR%" "%BACKUPDIR%\countryballs"
if defined COLDWARPACK call :REPLACE_PACK "!COLDWARPACK!" "%COLDWAR_DIR%" "%BACKUPDIR%\coldwar"
if defined AGINCOURTPACK call :REPLACE_PACK "!AGINCOURTPACK!" "%AGINCOURT_DIR%" "%BACKUPDIR%\agincourt"

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
if defined COUNTRYBALLSPACK call :RESTORE_PACK "%BACKUPDIR%\countryballs" "%COUNTRYBALLSDIR%"
if defined COLDWARPACK call :RESTORE_PACK "%BACKUPDIR%\coldwar" "%COLDWAR_DIR%"
if defined AGINCOURTPACK call :RESTORE_PACK "%BACKUPDIR%\agincourt" "%AGINCOURT_DIR%"
if exist "%BACKUPDIR%" rmdir /s /q "%BACKUPDIR%"

echo "[info] original files restored, exiting..."
timeout /t 1 /nobreak >nul
exit /b

:REPLACE_PACK
if not exist "%~3" mkdir "%~3"
for %%f in ("%~1\*.png") do (
    set "filename=%%~nxf"

    if exist "%~2\!filename!" (
        copy /y "%~2\!filename!" "%~3\!filename!" >nul
    )

    copy /y "%%f" "%~2\!filename!" >nul
    echo "[info] replaced !filename!"
)
exit /b

:RESTORE_PACK
if exist "%~1" (
    for %%f in ("%~1\*.png") do (
        set "filename=%%~nxf"
        copy /y "%~1\!filename!" "%~2\!filename!" >nul
        echo "[info] restored !filename!"
    )
)
exit /b
