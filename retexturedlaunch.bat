
:: retextured v1.0 by foxware

:: see the readme for info on usage.


@echo off
setlocal enabledelayedexpansion
:: "C:\Program Files (x86)\Steam\steamapps\common\War of Dots\assets\skins\countryballs" ignore this

cd /d "%~dp0"

:: set to true to show developer file checks, or false for normal use
set "DEV_ECHOS=false"



: -------------- boring code stuff below here


:: tries the original Steam install path first for compatibility
set "WODROOT=C:\Program Files (x86)\Steam\steamapps\common\War of Dots"
if exist "!WODROOT!\game.exe" goto WODROOT_FOUND

:: uses a local override next, then checks the registered Steam libraries
set "WODROOT="
if exist "%~dp0wodroot.txt" set /p "WODROOT="<"%~dp0wodroot.txt"
if defined WODROOT if exist "!WODROOT!\game.exe" goto WODROOT_FOUND
if defined WODROOT echo "[warning] configured WODROOT was not found: !WODROOT!"
set "WODROOT="
set "POWERSHELL=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if exist "!POWERSHELL!" for /f "usebackq delims=" %%p in (`"!POWERSHELL!" -NoProfile -ExecutionPolicy Bypass -File "%~dp0helpers\find-wodroot.ps1"`) do if not defined WODROOT set "WODROOT=%%p"
if not defined WODROOT (
    echo "[error] could not find the War of Dots installation automatically."
    echo "[info] create wodroot.txt beside this launcher and put the game folder path on its first line."
    pause
    exit /b 1
)

:WODROOT_FOUND
echo "[info] using War of Dots installation: !WODROOT!"

set "GAME=%WODROOT%\game.exe"
for %%g in ("%GAME%") do set "GAME_NAME=%%~nxg"
set "IMGDIR=pack"
set "BACKUPDIR=backup"
set "COUNTRYBALLSDIR=%WODROOT%\assets\skins\countryballs"
set "COLDWAR_DIR=%WODROOT%\assets\skins\coldwar"
set "AGINCOURT_DIR=%WODROOT%\assets\skins\agincourt"
set "BASE_ASSETS_DIR=%WODROOT%\assets"
if /i "!DEV_ECHOS!"=="true" call :DEV_REPORT

:: ensures the script is running correctly
cd /d "%~dp0"

if not exist "%IMGDIR%" (
    echo "[error] image pack not found: %IMGDIR%"
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
    echo "[error] no pack folders found in %IMGDIR%"
    pause
    exit /b 1
)

echo.
:PACK_SELECTION
echo "[info] available packs:"
for /l %%n in (1,1,%PACKCOUNT%) do echo "%%n. !PACKNAME%%n!"
echo.
set "PACKCHOICE="
set /p "PACKCHOICE=select a pack for countryballs (blank to skip): "
if defined PACKCHOICE call set "COUNTRYBALLSPACK=%%PACK!PACKCHOICE!%%"
if defined PACKCHOICE if not defined COUNTRYBALLSPACK echo "[error] invalid countryballs pack selection: %PACKCHOICE%"
if defined COUNTRYBALLSPACK echo "[info] countryballs pack selected: !PACKNAME%PACKCHOICE%!"
set "PACKCHOICE="
set /p "PACKCHOICE=select a pack for coldwar (blank to skip): "
if defined PACKCHOICE call set "COLDWARPACK=%%PACK!PACKCHOICE!%%"
if defined PACKCHOICE if not defined COLDWARPACK echo "[error] invalid coldwar pack selection: %PACKCHOICE%"
if defined COLDWARPACK echo "[info] coldwar pack selected: !PACKNAME%PACKCHOICE%!"
set "PACKCHOICE="
set /p "PACKCHOICE=select a pack for agincourt (blank to skip): "
if defined PACKCHOICE call set "AGINCOURTPACK=%%PACK!PACKCHOICE!%%"
if defined PACKCHOICE if not defined AGINCOURTPACK echo "[error] invalid agincourt pack selection: %PACKCHOICE%"
if defined AGINCOURTPACK echo "[info] agincourt pack selected: !PACKNAME%PACKCHOICE%!"
set "PACKCHOICE="
set /p "PACKCHOICE=(4 Colors + boats) select a pack for base assets (blank to skip): "
if defined PACKCHOICE call set "BASE_ASSETSPACK=%%PACK!PACKCHOICE!%%"
if defined PACKCHOICE if not defined BASE_ASSETSPACK echo "[error] invalid base assets pack selection: %PACKCHOICE%"
if defined BASE_ASSETSPACK echo "[info] base assets pack selected: !PACKNAME%PACKCHOICE%!"
if not defined COUNTRYBALLSPACK if not defined COLDWARPACK if not defined AGINCOURTPACK if not defined BASE_ASSETSPACK (
    call :ASK_BASE_GAME
    if errorlevel 2 goto PACK_SELECTION
    if errorlevel 1 exit /b 0
)
:: ^^^ dude i have to simplify this shit at some point lmfao
if not exist "!GAME!" (
    echo "[error] game not found: !GAME!"
    pause
    exit /b 1
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
    if defined BASE_ASSETSPACK call :RESTORE_PACK "%BACKUPDIR%\base_assets" "%BASE_ASSETS_DIR%"
    if exist "%BACKUPDIR%" rmdir /s /q "%BACKUPDIR%"
    pause
    exit /b 1
)

echo "[info] file verification bypassed! beginning file replacement..."

:: backs up the original files, then injects the new ones over the countryballs folder

echo "[info] backing up original files. if this is your first launch, it will take a while to set up."

if not exist "%BACKUPDIR%" mkdir "%BACKUPDIR%"
if not exist "%BACKUPDIR%" (
    echo "[error] could not create backup directory: %BACKUPDIR%"
    pause
    exit /b 1
)

if defined COUNTRYBALLSPACK call :REPLACE_PACK "!COUNTRYBALLSPACK!" "%COUNTRYBALLSDIR%" "%BACKUPDIR%\countryballs"
if defined COLDWARPACK call :REPLACE_PACK "!COLDWARPACK!" "%COLDWAR_DIR%" "%BACKUPDIR%\coldwar"
if defined AGINCOURTPACK call :REPLACE_PACK "!AGINCOURTPACK!" "%AGINCOURT_DIR%" "%BACKUPDIR%\agincourt"
if defined BASE_ASSETSPACK call :REPLACE_PACK "!BASE_ASSETSPACK!" "%BASE_ASSETS_DIR%" "%BACKUPDIR%\base_assets"

if defined COPY_FAILED (
    echo "[error] one or more texture files could not be replaced."
    echo "[info] attempting to restore the original files..."
    if defined COUNTRYBALLSPACK call :RESTORE_PACK "%BACKUPDIR%\countryballs" "%COUNTRYBALLSDIR%"
    if defined COLDWARPACK call :RESTORE_PACK "%BACKUPDIR%\coldwar" "%COLDWAR_DIR%"
    if defined AGINCOURTPACK call :RESTORE_PACK "%BACKUPDIR%\agincourt" "%AGINCOURT_DIR%"
    if defined BASE_ASSETSPACK call :RESTORE_PACK "%BACKUPDIR%\base_assets" "%BASE_ASSETS_DIR%"
    if exist "%BACKUPDIR%" rmdir /s /q "%BACKUPDIR%"
    pause
    exit /b 1
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
if defined COUNTRYBALLSPACK call :RESTORE_PACK "%BACKUPDIR%\countryballs" "%COUNTRYBALLSDIR%"
if defined COLDWARPACK call :RESTORE_PACK "%BACKUPDIR%\coldwar" "%COLDWAR_DIR%"
if defined AGINCOURTPACK call :RESTORE_PACK "%BACKUPDIR%\agincourt" "%AGINCOURT_DIR%"
if defined BASE_ASSETSPACK call :RESTORE_PACK "%BACKUPDIR%\base_assets" "%BASE_ASSETS_DIR%"
if exist "%BACKUPDIR%" rmdir /s /q "%BACKUPDIR%"

echo "[info] original files restored, exiting..."
timeout /t 1 /nobreak >nul
exit /b

:REPLACE_PACK
set "PACK_FILE_COUNT=0"
set "TARGET_DIR=%~2"
set "BACKUP_PATH=%~3"
if not exist "!TARGET_DIR!" (
    echo "[error] target texture directory not found: !TARGET_DIR!"
    set "COPY_FAILED=1"
    exit /b 1
)
if not exist "!BACKUP_PATH!" mkdir "!BACKUP_PATH!"
if not exist "!BACKUP_PATH!" (
    echo "[error] could not create backup directory: !BACKUP_PATH!"
    set "COPY_FAILED=1"
    exit /b 1
)
for %%f in ("%~1\*.png") do (
    set /a PACK_FILE_COUNT+=1
    set "filename=%%~nxf"

    if exist "!TARGET_DIR!\!filename!" (
        copy /y "!TARGET_DIR!\!filename!" "!BACKUP_PATH!\!filename!" >nul
        if errorlevel 1 (
            echo "[error] could not back up: !TARGET_DIR!\!filename!"
            set "COPY_FAILED=1"
        )
    )

    copy /y "%%f" "!TARGET_DIR!\!filename!" >nul
    if errorlevel 1 (
        echo "[error] could not replace: !TARGET_DIR!\!filename!"
        set "COPY_FAILED=1"
    ) else echo [info] replaced !filename!
)
if "%PACK_FILE_COUNT%"=="0" echo "[error] no PNG files found in pack: %~1"
if "%PACK_FILE_COUNT%"=="0" set "COPY_FAILED=1"
exit /b

:ASK_BASE_GAME
echo.
echo "[info] no texture packs selected."
:: asks whether to launch with the original game textures
:BASE_GAME_PROMPT
set "BASE_GAME_CHOICE="
set /p "BASE_GAME_CHOICE=start with base game textures? y for yes, n to close, or r to pick packs again: "
:: yes no reload options for if you launch without textures selected
if /i "%BASE_GAME_CHOICE%"=="y" (
    echo "[info] continuing with the game's base textures."
    exit /b 0
)
if /i "%BASE_GAME_CHOICE%"=="n" (
    echo "[info] launch cancelled."
    exit /b 1
)
if /i "%BASE_GAME_CHOICE%"=="r" exit /b 2
if not defined BASE_GAME_CHOICE echo "[error] please enter y, n, or r."
if defined BASE_GAME_CHOICE echo "[error] invalid choice: %BASE_GAME_CHOICE%. enter y, n, or r."
goto BASE_GAME_PROMPT

:RESTORE_PACK
set "BACKUP_PATH=%~1"
set "TARGET_DIR=%~2"
if exist "!BACKUP_PATH!" (
    for %%f in ("%~1\*.png") do (
        set "filename=%%~nxf"
        copy /y "!BACKUP_PATH!\!filename!" "!TARGET_DIR!\!filename!" >nul
        if errorlevel 1 (
            echo "[error] could not restore: !TARGET_DIR!\!filename!"
            set "COPY_FAILED=1"
        ) else echo [info] restored !filename!
    )
) else (
    echo "[info] no backup found to restore: !BACKUP_PATH!"
)
exit /b

:DEV_REPORT
:: reports important launcher files and game folders without changing anything
echo "[dev] launcher files:"
call :DEV_CHECK_PATH "%~dp0retexturedlaunch.bat"
call :DEV_CHECK_PATH "%~dp0readme.txt"
call :DEV_CHECK_PATH "%~dp0helpers\find-wodroot.ps1"
call :DEV_CHECK_PATH "%~dp0pack"
call :DEV_CHECK_PATH "%~dp0wodroot.txt"
call :DEV_CHECK_PATH "%~dp0backup"
echo "[dev] game files and folders:"
call :DEV_CHECK_PATH "!GAME!"
call :DEV_CHECK_PATH "!BASE_ASSETS_DIR!"
call :DEV_CHECK_PATH "!COUNTRYBALLSDIR!"
call :DEV_CHECK_PATH "!COLDWAR_DIR!"
call :DEV_CHECK_PATH "!AGINCOURT_DIR!"
exit /b

:DEV_CHECK_PATH
set "DEV_CHECK_PATH=%~1"
if exist "!DEV_CHECK_PATH!" (
    echo "[dev] found: !DEV_CHECK_PATH!"
) else (
    echo "[dev] missing: !DEV_CHECK_PATH!, likely an optional file or a file made on launch"
)
exit /b
