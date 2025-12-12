# Engineering Club Minecraft Launcher


## Installation
Download the latest release from [GitHub Releases](https://github.com/dmoke/new-ec-mc-client/releases/latest).

## Prerequisites

### For macOS Users
Before using the macOS launcher, install these dependencies:
```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Java 17
brew install openjdk@17

# Install Python
brew install python
```

## Usage

### Windows
1. Extract the downloaded `launcher_release.zip`
2. Run `launcher.exe`
3. The launcher will start automatically

### macOS
**Option 1: App Bundle (Recommended)**
1. Install prerequisites (see Prerequisites section above)
2. Extract the downloaded `launcher_release.zip`
3. Double-click `MacLauncher`
4. Your Minecraft launcher will start in a terminal window

**Option 2: Manual Setup**
1. Extract the downloaded `launcher_release.zip`
2. Open Terminal and navigate to the extracted folder
3. Run: `java -jar launcher.jar`


### Tested Permission Fix Command
If you can launch the launcher, make sure it's in the launcher_release directory and run this command in terminal:

```bash
if [ -d ~/Desktop/launcher_release ]; then
  sudo chmod +x ~/Desktop/launcher_release/MacLauncher.app/Contents/MacOS/* && echo "Permissions applied successfully in Desktop folder."
elif [ -d ~/Downloads/launcher_release ]; then
  sudo chmod +x ~/Downloads/launcher_release/MacLauncher.app/Contents/MacOS/* && echo "Permissions applied successfully in Downloads folder."
elif [ -d ~/Downloads_launcher_release ]; then
  sudo chmod +x ~/Downloads_launcher_release/MacLauncher.app/Contents/MacOS/* && echo "Permissions applied successfully in Downloads_launcher_release folder."
else
  echo "Neither ~/Desktop/launcher_release/ nor ~/Downloads/launcher_release/ directory exists."
fi
```



## Troubleshooting

### macOS Permission Issues
If the macOS app won't open, fix permissions:
```bash
# For Desktop location:
sudo chmod +x ~/Desktop/launcher_release/MacLauncher/Contents/MacOS/*

# For Downloads location:
sudo chmod +x ~/Downloads/launcher_release/MacLauncher.app/Contents/MacOS/*

# For custom location, replace path accordingly
```

### Manual Java/Python Setup
If you encounter issues with the prerequisites:
- **Java 17**: `brew install openjdk@17`
- **Python**: `brew install python`
