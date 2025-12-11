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

    REM Get current version from version.json
    for /f "tokens=2 delims=:," %%a in ('type assets\version.json ^| findstr "version"') do (
        set VERSION=%%~a
        goto :version_found
    )
    :version_found
    set VERSION=%VERSION:"=%
    set VERSION=%VERSION: =%

    echo Current version: %VERSION%

    REM Git operations
    echo Adding files to git...
    git add .

    echo Committing changes...
    git commit -m "Build launcher update v%VERSION%"

    echo Creating tag %VERSION%...
    git tag %VERSION% 2>nul || echo Tag %VERSION% already exists, skipping...

    echo Pushing to GitHub...
    git push origin master
    git push origin %VERSION% 2>nul || echo Tag %VERSION% already pushed, skipping...

    echo.
    echo All operations completed successfully!
    echo Release %VERSION% has been created and pushed to GitHub!

) else (
    echo Build failed! Please check the errors above.
    pause
    exit /b 1
)

echo.
echo Build, commit, tag, and push completed successfully!
pause
