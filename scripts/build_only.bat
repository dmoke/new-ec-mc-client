@echo off
echo Building new launcher executable...

REM Build the executable using PyInstaller
pyinstaller ..\launcher.spec

REM Check if build was successful
if %ERRORLEVEL% EQU 0 (
    echo Build successful! Replacing launcher in root folder...

    REM Copy the built executable to root folder
    copy /Y dist\launcher.exe ..\launcher.exe

    echo Launcher replaced successfully!
) else (
    echo Build failed! Please check the errors above.
    pause
    exit /b 1
)

echo.
echo Build completed successfully!
pause
