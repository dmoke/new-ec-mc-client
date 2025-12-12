@echo off
echo Building macOS launcher DMG...
echo.
echo NOTE: This script creates a Windows executable with macOS-style metadata.
echo For a proper macOS DMG, run build_only_macos.sh on macOS.
echo.

REM Build the app using PyInstaller
echo Running pyinstaller...
pyinstaller launcher_macos.spec

REM Check if build was successful
if %ERRORLEVEL% EQU 0 (
    echo Build successful!

    REM Try to create DMG from the built app using hdiutil (requires macOS or WSL with hdiutil)
    echo Attempting to create DMG...
    hdiutil create -volname "Engineering Club MC Launcher" -srcfolder dist\launcher.app -ov -format UDZO ..\launcher.dmg >nul 2>&1
    if exist ..\launcher.dmg (
        echo DMG created successfully!
        echo DMG saved as: ..\launcher.dmg
    ) else (
        echo DMG creation failed! hdiutil is not available on this system.
        echo.
        echo Creating ZIP archive as alternative...
        powershell -Command "Compress-Archive -Path 'dist\*' -DestinationPath '%~dp0..\launcher_macos.zip' -Force"
        echo PowerShell command completed with exit code: %ERRORLEVEL%
        if exist ..\launcher_macos.zip (
            echo ZIP archive created successfully!
            echo ZIP saved as: ..\launcher_macos.zip
            echo.
            echo Note: For proper DMG, run build_only_macos.sh on macOS
            echo This ZIP contains the Windows executable with macOS metadata.
        ) else (
            echo ZIP creation also failed.
        )
        echo.
        echo The launcher.exe in dist\ contains macOS-style metadata.
    )
) else (
    echo Build failed! Please check the errors above.
    pause
    exit /b 1
)

echo.
echo macOS DMG build completed (with warnings)!
pause
