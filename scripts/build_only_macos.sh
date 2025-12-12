#!/bin/bash
echo "Building macOS launcher DMG..."

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "Warning: This script is designed for macOS. You're running on $OSTYPE"
    echo "The resulting DMG may not work properly on macOS."
    echo "For best results, run this on macOS."
fi

# Build the app using PyInstaller
cd ..
pyinstaller launcher_macos.spec
cd scripts

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "Build successful! Creating DMG..."

    # Create DMG from the built app
    hdiutil create -volname "Engineering Club MC Launcher" -srcfolder dist/launcher.app -ov -format UDZO ../launcher.dmg

    if [ $? -eq 0 ]; then
        echo "DMG created successfully!"
        echo "DMG saved as: ../launcher.dmg"
    else
        echo "DMG creation failed! hdiutil may not be available on this system."
        echo "Alternative: You can create DMG manually or use a DMG creation tool."
        exit 1
    fi
else
    echo "Build failed! Please check the errors above."
    exit 1
fi

echo ""
echo "macOS DMG build completed successfully!"
