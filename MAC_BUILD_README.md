# macOS DMG Build Guide

## The Problem
Building on Windows/Linux creates Windows EXE files that **won't run on macOS**.

## The Solution
You need to build on **macOS** to create a real macOS app and DMG.

## How to Build a Real macOS DMG

### Option 1: Build on a Mac Computer
```bash
# On macOS:
cd your-project-folder
cd scripts
./build_only_macos.sh
```

**Result:** `launcher.dmg` - A native macOS installer that users can open and get a working macOS app.

### Option 2: GitHub Actions (Recommended for CI/CD)
Add macOS runners to your `.github/workflows/release.yml`:

```yaml
jobs:
  build-macos:
    runs-on: macos-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pyinstaller dmgbuild

      - name: Build macOS app
        run: pyinstaller launcher_macos.spec

      - name: Create DMG
        run: |
          hdiutil create -volname "Engineering Club MC Launcher" \
                         -srcfolder dist/launcher.app \
                         -ov -format UDZO launcher.dmg

      - name: Upload DMG
        uses: actions/upload-release-asset@v1
        with:
          upload_url: ${{ github.event.release.upload_url }}
          asset_path: launcher.dmg
          asset_name: launcher.dmg
          asset_content_type: application/x-apple-diskimage
```

## What the Real DMG Contains

- **Native macOS app** (`.app` bundle)
- **Runs Python launcher** natively on macOS
- **Works on Intel & Apple Silicon Macs**
- **Proper macOS integration** (dock, menu bar, etc.)

## Testing

After building, test the DMG by:
1. Opening the DMG file
2. Dragging the app to Applications
3. Running the app - it should launch your Python Minecraft launcher

## Current Windows Build (For Reference)

The Windows build creates `launcher_macos.zip` with a Windows EXE that has macOS metadata but **won't actually run on macOS**. It's only useful for testing the build process.
