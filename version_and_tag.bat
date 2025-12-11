@echo off
echo Version and Tag Preparation Script

REM Get current version from version.json
for /f "tokens=2 delims=:," %%a in ('type assets\version.json ^| findstr "version"') do (
    set VERSION=%%~a
    goto :version_found
)
:version_found
set VERSION=%VERSION:"=%
set VERSION=%VERSION: =%

echo Current version: %VERSION%

REM Ask user for new version
set /p NEW_VERSION="Enter new version (current: %VERSION%): "

if "%NEW_VERSION%"=="" (
    echo No version entered. Exiting...
    pause
    exit /b 1
)

REM Update version.json
echo Updating version.json to %NEW_VERSION%...
powershell -Command "(Get-Content assets/version.json) -replace '\"version\": \"%VERSION%\"', '\"version\": \"%NEW_VERSION%\"' | Set-Content assets/version.json"

echo Version updated to %NEW_VERSION%

REM Git operations
echo Adding files to git...
git add .

echo Committing changes...
git commit -m "Update version to %NEW_VERSION%"

echo Creating tag %NEW_VERSION%...
git tag %NEW_VERSION% 2>nul || echo Tag %NEW_VERSION% already exists, skipping...

echo Pushing to GitHub...
git push origin master
git push origin %NEW_VERSION% 2>nul || echo Tag %NEW_VERSION% already pushed, skipping...

echo.
echo Version update and tagging completed successfully!
echo Release %NEW_VERSION% has been created and pushed to GitHub!
pause
