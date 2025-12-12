#!/bin/bash
echo "Building macOS launcher DMG..."
echo ""

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ ERROR: This script MUST be run on macOS!"
    echo "You're running on: $OSTYPE"
    echo ""
    echo "To create a proper macOS DMG:"
    echo "1. Run this on a Mac computer"
    echo "2. Or use GitHub Actions with macOS runners"
    echo "3. Or use a macOS virtual machine"
    echo ""
    echo "The current build creates Windows EXE files, not macOS apps."
    exit 1
fi

echo "✅ Running on macOS - proceeding with native DMG creation..."

# Build the app using PyInstaller
cd ..
echo "Building macOS app bundle (.app file)..."
pyinstaller launcher_macos.spec

# Verify the .app was created
if [ -d "dist/launcher.app" ]; then
    echo "✅ macOS app bundle created successfully!"
    echo "📁 App location: $(pwd)/dist/launcher.app"
    ls -la dist/launcher.app
else
    echo "❌ ERROR: macOS app bundle was not created!"
    echo "This usually means PyInstaller failed or the spec file is wrong."
    exit 1
fi

cd scripts

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful! App bundle created at: ../dist/launcher.app"

    echo "Creating DMG package..."
    echo "📦 Packaging app into DMG..."

    # Create DMG from the built app
    hdiutil create -volname "Engineering Club MC Launcher" \
                   -srcfolder ../dist/launcher.app \
                   -ov -format UDZO ../launcher.dmg

    if [ $? -eq 0 ] && [ -f "../launcher.dmg" ]; then
        echo "✅ DMG created successfully!"
        echo "📁 DMG saved as: ../launcher.dmg"
        ls -lh ../launcher.dmg
        echo ""
        echo "🎯 This DMG contains a REAL macOS app that will:"
        echo "   - Run natively on macOS"
        echo "   - Launch your Python Minecraft launcher"
        echo "   - Work on Intel and Apple Silicon Macs"
    else
        echo "❌ DMG creation failed!"
        echo "Check that hdiutil is available and the app bundle exists."
        exit 1
    fi
else
    echo "❌ Build failed! Please check the errors above."
    exit 1
fi

echo ""
echo "🎉 macOS DMG build completed successfully!"
echo "Your macOS users can now download and use the native DMG file."
