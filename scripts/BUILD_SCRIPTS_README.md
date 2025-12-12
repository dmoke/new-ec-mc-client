# Build Scripts Guide

This project includes several batch scripts to automate the build and release process for the Minecraft launcher.

## Directory Structure
```
scripts/
├── build_only.bat              # Simple Windows build only
├── build_only_macos.sh         # Simple macOS DMG build only (.sh)
├── build_only_macos.bat        # Simple macOS DMG build only (.bat)
├── build_and_tag.bat           # Build + interactive tagging
├── build_and_release.bat       # Full automation
├── version_and_tag.bat         # Version management only
├── release.bat                 # Official release script
└── BUILD_SCRIPTS_README.md     # This documentation
```

## Available Scripts

### 1. `release.bat [version]`

### 2. `build_only_macos.sh` / `build_only_macos.bat`
**Purpose**: Build macOS launcher
**What it does**:
- `build_only_macos.sh` (macOS only): Creates native macOS DMG file
- `build_only_macos.bat` (Windows): Creates Windows EXE with macOS metadata

**Usage**:
```bash
# On macOS - creates REAL DMG file:
cd scripts
./build_only_macos.sh

# On Windows - creates Windows EXE (NOT DMG):
cd scripts
.\build_only_macos.bat
# Note: Creates launcher.dmg in root (Windows EXE with .dmg extension)
```

### 3. `build_only.bat`
**Purpose**: Build the launcher executable only
**What it does**:
- Builds the executable using PyInstaller
- Replaces `launcher.exe` in the root folder
- No git operations

**Usage**: Run when you just want to test builds locally
```bash
cd scripts
.\build_only.bat
```

### 2. `build_only.bat`
**Purpose**: Build the launcher executable only
**What it does**:
- Builds the executable using PyInstaller
- Replaces `launcher.exe` in the root folder
- No git operations

**Usage**: Run when you just want to test builds locally
```bash
cd scripts
.\build_only.bat
```

### 3. `build_and_tag.bat`
**Purpose**: Build launcher and create a new version/tag
**What it does**:
- Builds the executable using PyInstaller
- Replaces `launcher.exe` in the root folder
- Asks for a new version number
- Updates `assets/version.json`
- Commits all changes
- Creates a git tag
- Pushes to GitHub (triggers release)

**Usage**: When you have code changes and want to create a new release
```bash
cd scripts
.\build_and_tag.bat
```

### 4. `build_and_release.bat`
**Purpose**: Full automation - build, commit, tag, and push
**What it does**:
- Builds the executable using PyInstaller
- Replaces `launcher.exe` in the root folder
- Auto-detects version from `assets/version.json`
- Commits all changes
- Creates a git tag
- Pushes to GitHub (triggers release)

**Usage**: Quick full automation (ensure version.json is updated first)
```bash
cd scripts
.\build_and_release.bat
```

### 5. `version_and_tag.bat`
**Purpose**: Update version and create tag without building
**What it does**:
- Asks for a new version number
- Updates `assets/version.json`
- Commits the version change
- Creates a git tag
- Pushes to GitHub

**Usage**: When you want to update version for existing build
```bash
cd scripts
.\version_and_tag.bat
```

## Recommended Workflow

### For Official Releases (RECOMMENDED):
```bash
cd scripts
.\release.bat 0.1.5.0
```

### For Development/Testing:
1. Make code changes
2. Test locally: `.\build_only.bat`
3. Create release: `.\build_and_release.bat`

### For Version-Only Updates:
```bash
cd scripts
.\version_and_tag.bat
```

## Notes

- All scripts handle errors gracefully and won't push if builds fail
- Tag conflicts are handled automatically (skips if tag exists)
- Make sure to have `python-dotenv` in your requirements if using `.env` files
- Git must be configured and connected to the repository
- Scripts are designed to be run from the `scripts/` directory
