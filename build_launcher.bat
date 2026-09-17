::builds the game into its release form

@echo off
setlocal
cd /d "%~dp0"

echo Building WoDRetextured...
python -m PyInstaller --clean --noconfirm WoDLauncher.spec
if errorlevel 1 (
    echo Build failed.
    pause
    exit /b 1
)

if exist "dist\WoDRetextured\pack" rmdir /s /q "dist\WoDRetextured\pack"
if exist "dist\WoDRetextured\wallpapers" rmdir /s /q "dist\WoDRetextured\wallpapers"
xcopy "pack" "dist\WoDRetextured\pack" /E /I /Y >nul
xcopy "wallpapers" "dist\WoDRetextured\wallpapers" /E /I /Y >nul
copy /Y "readme.txt" "dist\WoDRetextured\readme.txt" >nul

echo.
echo Build complete: dist\WoDRetextured\WoDRTLauncher.exe
pause