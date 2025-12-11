@echo off
echo ========================================
echo    Engineering Club MC Launcher Release
echo ========================================

REM Check if version is provided as parameter
if "%1"=="" (
    echo Usage: release.bat [version]
    echo Example: release.bat 0.1.5.0
    pause
    exit /b 1
)

set RELEASE_VERSION=%1
echo Preparing release version: %RELEASE_VERSION%

REM Update version.json
echo Updating version.json...
powershell -Command "(Get-Content ../assets/version.json) -replace '\"version\": \"[^\"]*\"', '\"version\": \"%RELEASE_VERSION%\"' | Set-Content ../assets/version.json"

REM Build the launcher
echo Building launcher...
call build_and_release.bat

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo    RELEASE %RELEASE_VERSION% COMPLETED!
    echo ========================================
    echo.
    echo - Version updated to %RELEASE_VERSION%
    echo - Launcher built and replaced
    echo - Changes committed and tagged
    echo - Pushed to GitHub
    echo - Release workflow triggered
    echo.
    echo Check GitHub Actions for release status:
    echo https://github.com/dmoke/new-ec-mc-client/actions
    echo.
    echo Release download will be available at:
    echo https://github.com/dmoke/new-ec-mc-client/releases/tag/%RELEASE_VERSION%
) else (
    echo.
    echo RELEASE FAILED! Check errors above.
    pause
    exit /b 1
)

pause
