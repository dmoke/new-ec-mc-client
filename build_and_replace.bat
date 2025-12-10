@echo off
echo Building new launcher executable...

REM Build the executable using PyInstaller
pyinstaller launcher.spec

REM Check if build was successful
if %ERRORLEVEL% EQU 0 (
    echo Build successful! Replacing launcher in root folder...

    REM Copy the built executable to root folder
    copy /Y dist\launcher.exe launcher.exe

    echo Launcher replaced successfully!
    echo.
    echo Now you can:
    echo 1. Update version in assets/version.json
    echo 2. Commit changes: git add . && git commit -m "Update launcher and version"
    echo 3. Create tag: git tag [new-version]
    echo 4. Push: git push origin master && git push origin [tag]
) else (
    echo Build failed! Please check the errors above.
    pause
    exit /b 1
)

echo.
echo Build and replace completed successfully!
pause
