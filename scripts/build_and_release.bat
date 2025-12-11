@echo off
echo Building new launcher executable...

REM Build the executable using PyInstaller with full path
pyinstaller "%~dp0..\launcher.spec"

REM Check if build was successful
if %ERRORLEVEL% EQU 0 (
    echo Build successful! Launcher executable ready!

    REM Get current version from version.json
    for /f "tokens=2 delims=:," %%a in ('type "%~dp0..\assets\version.json" ^| findstr "version"') do (
        set VERSION=%%~a
        goto :version_found
    )
    :version_found
    set VERSION=%VERSION:"=%
    set VERSION=%VERSION: =%

    echo Current version: %VERSION%

    REM Increment version number (increment the last part by 1)
    for /f "tokens=1,2,3 delims=." %%a in ("%VERSION%") do (
        set MAJOR=%%a
        set MINOR=%%b
        set PATCH=%%c
    )

    REM Increment patch version
    set /a PATCH=%PATCH% + 1
    set NEW_VERSION=%MAJOR%.%MINOR%.%PATCH%

    echo New version: %NEW_VERSION%

    REM Update version.json with new version
    powershell -Command "(Get-Content '%~dp0..\assets\version.json') -replace '\"version\": \"%VERSION%\"', '\"version\": \"%NEW_VERSION%\"' | Set-Content '%~dp0..\assets\version.json'"

    echo Version.json updated to %NEW_VERSION%

    REM Git operations
    echo Adding files to git...
    git add .

    echo Committing changes...
    git commit -m "Build launcher update v%NEW_VERSION%"

    echo Creating tag %NEW_VERSION%...
    git tag %NEW_VERSION% 2>nul || echo Tag %NEW_VERSION% already exists, skipping...

    echo Pushing to GitHub...
    git push origin master
    git push origin %NEW_VERSION% 2>nul || echo Tag %NEW_VERSION% already pushed, skipping...

    echo.
    echo All operations completed successfully!
    echo Release %NEW_VERSION% has been created and pushed to GitHub!

) else (
    echo Build failed! Please check the errors above.
    pause
    exit /b 1
)

echo.
echo Build, commit, tag, and push completed successfully!
pause
