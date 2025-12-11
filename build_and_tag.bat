@echo off
echo Building and Tagging Script

REM Build the executable using PyInstaller
pyinstaller launcher.spec

REM Check if build was successful
if %ERRORLEVEL% EQU 0 (
    echo Build successful! Replacing launcher in root folder...

    REM Copy the built executable to root folder
    copy /Y dist\launcher.exe launcher.exe

    echo Launcher replaced successfully!

    REM Ask user for new version
    set /p NEW_VERSION="Enter new version for this build: "

    if "%NEW_VERSION%"=="" (
        echo No version entered. Build completed but not tagged.
        pause
        exit /b 0
    )

    REM Update version.json
    echo Updating version.json to %NEW_VERSION%...
    powershell -Command "(Get-Content assets/version.json) -replace '\"version\": \"[^\"]*\"', '\"version\": \"%NEW_VERSION%\"' | Set-Content assets/version.json"

    echo Version updated to %NEW_VERSION%

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
    echo Build and tagging completed successfully!
    echo Release %NEW_VERSION% has been created and pushed to GitHub!

) else (
    echo Build failed! Please check the errors above.
    pause
    exit /b 1
)

pause
