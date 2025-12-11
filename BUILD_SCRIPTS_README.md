# Build Scripts Guide

This project includes several batch scripts to automate the build and release process for the Minecraft launcher.

## Available Scripts

### 1. `build_only.bat`
**Purpose**: Build the launcher executable only
**What it does**:
- Builds the executable using PyInstaller
- Replaces `launcher.exe` in the root folder
- No git operations

**Usage**: Run when you just want to test builds locally
```bash
.\build_only.bat
```

### 2. `build_and_tag.bat`
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
.\build_and_tag.bat
```

### 3. `build_and_release.bat`
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
.\build_and_release.bat
```

### 4. `version_and_tag.bat`
**Purpose**: Update version and create tag without building
**What it does**:
- Asks for a new version number
- Updates `assets/version.json`
- Commits the version change
- Creates a git tag
- Pushes to GitHub

**Usage**: When you want to update version for existing build
```bash
.\version_and_tag.bat
```

## Workflow Examples

### New Feature Development:
1. Make code changes
2. Update `assets/version.json` with new version
3. Run `.\build_and_release.bat`

### Quick Testing:
1. Make code changes
2. Run `.\build_only.bat` to test locally

### Version Bump Only:
1. Run `.\version_and_tag.bat` to update version without rebuilding

### Full Manual Control:
1. Run `.\build_and_tag.bat` for interactive version input

## Notes

- All scripts handle errors gracefully and won't push if builds fail
- Tag conflicts are handled automatically (skips if tag exists)
- Make sure to have `python-dotenv` in your requirements if using `.env` files
- Git must be configured and connected to the repository
