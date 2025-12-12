@echo off
echo Building macOS launcher (Windows version)...
echo.
echo IMPORTANT: This creates a WINDOWS EXE file, NOT a macOS DMG!
echo.
echo For a REAL macOS DMG file, you MUST run on macOS:
echo     ./build_only_macos.sh (on macOS)
echo.
echo This script only creates a Windows EXE for testing purposes.
echo.

REM Build the app using PyInstaller
echo Running pyinstaller...
pyinstaller launcher_macos.spec

REM Check if build was successful
if %ERRORLEVEL% EQU 0 (
    echo Build successful!

    REM Create launcher.dmg in root folder (Windows EXE with DMG extension)
    echo Creating launcher.dmg in root folder...
    copy dist\launcher.exe "%~dp0..\launcher.dmg"
    if exist ..\launcher.dmg (
        echo launcher.dmg created successfully in root folder!
        echo Note: This is actually a Windows EXE with .dmg extension.
        echo For a REAL macOS DMG, run build_only_macos.sh on macOS.
        echo.
        echo File location: ..\launcher.dmg (same as launcher.exe)
    ) else (
        echo Failed to create launcher.dmg
    )
) else (
    echo Build failed! Please check the errors above.
    pause
    exit /b 1
)

echo.
echo macOS DMG build completed (with warnings)!
pause
