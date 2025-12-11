# pyinstaller --onefile --noconsole launcher.py --uac-admin -w
import json
import os
import platform
import shutil
import subprocess
import sys
import time
from dotenv import load_dotenv
import zipfile
from subprocess import call
from sys import argv, exit

import requests
from PyQt5.QtCore import QThread, pyqtSignal, QSize, Qt
from PyQt5.QtGui import QPixmap, QIcon
from PyQt5.QtWidgets import QWidget, QVBoxLayout, QLabel, QLineEdit, QSpacerItem, QSizePolicy, \
    QProgressBar, QPushButton, QApplication, QMainWindow, QCheckBox, QHBoxLayout, QMessageBox, QSlider
from minecraft_launcher_lib import forge
from minecraft_launcher_lib.command import get_minecraft_command
from minecraft_launcher_lib.forge import find_forge_version
from minecraft_launcher_lib.utils import get_minecraft_directory

# TODO: check for specific (8) version of java to download, pass java path to launch command
# TODO: fix --username option on mac
# TODO: Overclocking + better CPU
# TODO: chunks not loading
# TODO: delete griefing mod zombie boss
# TODO: fix corps to break in any claim
# TODO: add nogui option
# TODO: ask admin permission
# TODO: fix crafting table
# TODO: hide ip with noip
# TODO: get mca skins online

load_dotenv()
SERVER_TYPE = 'new'
minecraft_directory = get_minecraft_directory().replace('minecraft', 'EngineeringClubLauncher'+ f'_{SERVER_TYPE}')
TITLE = "Engineering Club MC"
VANILLA_VERSION_ID = '1.12.2'
FORGE_FOLDER = '1.12.2-forge-14.23.5.2859'
FORGE_VERSION_ID = '1.12.2-14.23.5.2859'
GITHUB_REPO = "https://api.github.com/repos/dmoke/new-ec-mc-client/releases/latest"
is_dev_environment = os.getenv('DEV_ENVIRONMENT', False)


def clear_and_move_mods(local_mods_dir):
    # Clear the existing mods directory
    mods_directory = os.path.join(minecraft_directory, 'mods')
    if os.path.exists(mods_directory):
        shutil.rmtree(mods_directory)

    # Create a new mods directory
    os.makedirs(mods_directory)

    # Move mods from the local mods directory to the Minecraft mods directory
    if os.path.exists(local_mods_dir):
        for mod_file in os.listdir(local_mods_dir):
            mod_path = os.path.join(local_mods_dir, mod_file)
            if os.path.isfile(mod_path) and mod_file.endswith('.jar'):
                shutil.copy(mod_path, mods_directory)

    print("Moved modes successfully.")

# def replace_waystones_config_file():
#     # Specify the paths for the source and destination files
#     source_file_path = os.path.join(os.getcwd(), 'assets', 'waystones-common.toml')
#     destination_dirs = [os.path.join(minecraft_directory, 'defaultconfigs'), os.path.join(minecraft_directory, 'config')]
#     destination_file_name = 'waystones-common.toml'

#     try:
#         # Check if the source file exists
#         if os.path.exists(source_file_path):
#             for destination_dir in destination_dirs:
#                 # Check if the destination directory exists, create it if not
#                 if not os.path.exists(destination_dir):
#                     os.makedirs(destination_dir)

#                 # Construct the full path for the destination file
#                 destination_file_path = os.path.join(destination_dir, destination_file_name)

#                 # Replace the destination file with the source file
#                 shutil.copy2(source_file_path, destination_file_path)
#                 print(f"Successfully replaced {destination_file_path} with {source_file_path}")
#         else:
#             print(f"Error: Source file {source_file_path} not found.")
#     except Exception as e:
#         print(f"An error occurred: {e}")


def override_files():
    # Source directory containing files to override
    source_directory = os.path.join(os.getcwd(), 'assets', 'overrides')

    # Destination directory (Minecraft directory)
    destination_directory = minecraft_directory

    try:
        # Copy the entire directory tree from source to destination, overwriting existing files
        shutil.copytree(source_directory, destination_directory, dirs_exist_ok=True)

        print("Files overridden successfully.")
    except Exception as e:
        print(f"Error overriding files: {e}")

def fetch_current_version():
    # Fetch current version from assets/version.json
    try:
        with open('assets/version.json', 'r') as file:
            version_data = json.load(file)
            return version_data.get('version', '')
    except FileNotFoundError:
        return 'None'


def create_minecraft_directory():
    # Create the Minecraft directory if it doesn't exist
    if not os.path.exists(minecraft_directory):
        os.makedirs(minecraft_directory)


def copy_servers():
    current_directory = os.getcwd()  # Get the current working directory
    local_servers_dat_path = os.path.join(current_directory, 'servers.dat')
    launcher_servers_dat_path = os.path.join(minecraft_directory, 'servers.dat')

    # Check if the file exists in the current directory
    if os.path.exists(local_servers_dat_path):
        shutil.copy(local_servers_dat_path, launcher_servers_dat_path)


def is_forge_installed():
    versions_directory = os.path.join(minecraft_directory, 'versions')
    vanilla_version_folder = os.path.join(versions_directory, VANILLA_VERSION_ID)
    forge_version_folder = os.path.join(versions_directory, FORGE_FOLDER)

    return os.path.exists(vanilla_version_folder) and os.path.exists(forge_version_folder)


def download_to_tmp(assets):
    if not assets or is_dev_environment:
        print("No assets found for the release or in the development environment.")
        return

    asset = assets[0]  # Assuming the first asset is a zip file
    asset_url = asset.get("browser_download_url")
    asset_name = asset.get("name")

    if asset_url:
        print(f"Downloading asset: {asset_name}")

        # Clear the 'tmp' directory if it already exists
        tmp_dir = os.path.join(os.getcwd(), 'tmp')
        if os.path.exists(tmp_dir):
            shutil.rmtree(tmp_dir)

        os.makedirs(tmp_dir, exist_ok=True)

        asset_path = os.path.join(tmp_dir, asset_name)
        with open(asset_path, 'wb') as file:
            response = requests.get(asset_url, stream=True)
            shutil.copyfileobj(response.raw, file)

        print(f"Asset downloaded to: {asset_path}")

        # Extract the downloaded asset directly to the tmp directory
        with zipfile.ZipFile(asset_path, 'r') as zip_ref:
            zip_ref.extractall(tmp_dir)

        # Delete the downloaded ZIP file
        os.remove(asset_path)

        return tmp_dir


class LaunchThread(QThread):
    launch_setup_signal = pyqtSignal(str, str, bool, str, int)
    progress_update_signal = pyqtSignal(int, int, str)

    fetch_progress_signal = pyqtSignal(int, int, str)
    download_progress_signal = pyqtSignal(int, int, str)
    elevator_progress_signal = pyqtSignal(int, int, str)
    state_update_signal = pyqtSignal(bool)
    finished_signal = pyqtSignal(bool)

    version_id = ''
    username = ''
    isReinstallingForge = False

    progress = 0
    progress_max = 0
    progress_label = ''

    def __init__(self):
        super().__init__()
        self.currentLauncherVersion = None
        self.maxHeap = None
        self.latest_version = None
        self.launch_setup_signal.connect(self.launch_setup)

    def install_forge(self, version_id):
        # forge_version = find_forge_version(version_id)
        forge.install_forge_version(version_id, minecraft_directory,
                                    callback={'setStatus': self.update_progress_label,
                                              'setProgress': self.update_progress, 'setMax': self.update_progress_max})

    def elevator_launcher(self, arg_username):
        # Get the absolute path of the currently executing script
        current_script = os.path.abspath(sys.argv[0])

        # Get the script's directory
        client_directory = os.path.dirname(current_script)

        # Run elevator.py in a new console window with the username as an argument
        elevator_script = os.path.join(client_directory, 'tmp', 'assets', 'elevator.py')

        # Check if the platform is Mac
        if platform.system() == 'Darwin':
            subprocess.Popen(['python3', elevator_script, '--username', arg_username])
        else:
            subprocess.Popen(['python', elevator_script, '--username', arg_username],
                             creationflags=subprocess.DETACHED_PROCESS)

        QApplication.instance().quit()
        self.finished_signal.emit(True)
        sys.exit(0)

    def fetch_launcher_version(self):
        try:
            response = requests.get(GITHUB_REPO)
            release_info = response.json()
            version_tag = release_info["tag_name"]
            assets = release_info.get("assets", [])

            self.latest_version = version_tag

            return assets

        except requests.RequestException as e:
            print(f"Error fetching launcher version: {e}")
            return []

    def launch_setup(self, version_id, username, isReinstallingForge, currentLauncherVersion, maxHeap):
        self.version_id = version_id
        self.username = username
        self.isReinstallingForge = isReinstallingForge
        self.currentLauncherVersion = currentLauncherVersion
        self.maxHeap = maxHeap

    def update_progress_label(self, value):
        self.progress_label = value
        self.progress_update_signal.emit(self.progress, self.progress_max, self.progress_label)

    def update_progress(self, value):
        self.progress = value
        self.progress_update_signal.emit(self.progress, self.progress_max, self.progress_label)

    def installation_complete(self):
        self.progress_update_signal.emit(self.progress_max, self.progress_max, "Game is running...")

    def update_progress_max(self, value):
        self.progress_max = value
        self.progress_update_signal.emit(self.progress, self.progress_max, self.progress_label)

    def run(self):
        self.state_update_signal.emit(True)
        time.sleep(1)

        self.progress_update_signal.emit(self.progress_max, self.progress_max, "Checking for updates...")
        assets = self.fetch_launcher_version()
        print(f"dev_env: {is_dev_environment}")

        if self.currentLauncherVersion != self.latest_version and not is_dev_environment:
            # Download and install assets if versions are different
            self.progress_update_signal.emit(self.progress_max, self.progress_max, "Installing Updates...")
            download_to_tmp(assets)
            self.elevator_launcher(self.username)

        create_minecraft_directory()
        if self.isReinstallingForge or not is_forge_installed():
            self.install_forge(self.version_id)

        # install_minecraft_version(versionid=self.version_id, minecraft_directory=minecraft_directory,
        #                           callback={'setStatus': self.update_progress_label,
        #                                     'setProgress': self.update_progress, 'setMax': self.update_progress_max})
        clear_and_move_mods('mods')
        override_files()
        copy_servers()
        # replace_waystones_config_file()
        if self.username == '':
            self.username = 'testUser'

        options = {
            'username': self.username,
            'uuid': '',
            'jvmArguments':  [f"-Xmx{self.maxHeap}G"],
            'token': ''
        }
        self.installation_complete()
        call(get_minecraft_command(version=FORGE_FOLDER, minecraft_directory=minecraft_directory, options=options))

        self.state_update_signal.emit(False)


def launch_thread_finished(is_finished):
    if is_finished:
        print("Launch thread has finished.")
        sys.exit()


class MainWindow(QMainWindow):
    def __init__(self, arg_username):
        super().__init__()
        self.setWindowTitle(TITLE + f" Launcher ({SERVER_TYPE})")
        self.resize(300, 283)
        self.centralwidget = QWidget(self)
        self.logo = QLabel(self.centralwidget)
        self.logo.setMaximumSize(QSize(720, 360))
        self.logo.setPixmap(QPixmap('assets/bg.png'))
        self.logo.setScaledContents(True)

        self.ram_slider = QSlider(Qt.Horizontal)
        self.ram_slider.setMinimum(1)
        self.ram_slider.setMaximum(16)  # Adjust maximum RAM as needed
        self.ram_slider.setValue(6)  # Set default RAM value
        self.ram_slider.valueChanged.connect(self.update_ram_label)  # Connect value change signal

        self.titlespacer = QSpacerItem(20, 40, QSizePolicy.Policy.Minimum, QSizePolicy.Policy.Expanding)

        self.username = QLineEdit(self.centralwidget)
        if arg_username:
            self.username.setText(arg_username)
        else:
            self.username.setPlaceholderText('Username')

        self.current_launcher_version = fetch_current_version()

        self.progress_spacer = QSpacerItem(20, 20, QSizePolicy.Policy.Minimum, QSizePolicy.Policy.Minimum)

        self.start_progress_label = QLabel(self.centralwidget)
        self.start_progress_label.setText('')
        self.start_progress_label.setVisible(False)

        self.start_progress = QProgressBar(self.centralwidget)
        self.start_progress.setProperty('value', 24)
        self.start_progress.setVisible(False)

        self.start_button = QPushButton(self.centralwidget)
        self.start_button.setText('Play')
        self.start_button.clicked.connect(self.launch_game)

        self.vertical_layout = QVBoxLayout(self.centralwidget)
        self.vertical_layout.setContentsMargins(15, 15, 15, 15)
        self.vertical_layout.addWidget(self.logo, 0, Qt.AlignmentFlag.AlignHCenter)
        self.vertical_layout.addItem(self.titlespacer)
        self.vertical_layout.addWidget(self.username)
        self.vertical_layout.addItem(self.progress_spacer)
        self.ram_label = QLabel()
        ram_layout = QHBoxLayout()
        ram_layout.addWidget(self.ram_slider)
        ram_layout.addWidget(self.ram_label)
        # Create a horizontal layout for the version label, repo link, and checkbox
        version_checkbox_layout = QHBoxLayout()

        self.launcher_version_label = QLabel()
        self.launcher_version_label.setText(f"Launcher Version: {fetch_current_version()}")
        version_checkbox_layout.addWidget(self.launcher_version_label, 0, Qt.AlignmentFlag.AlignLeft)

        version_checkbox_layout.addWidget(self.ram_slider, 3)
        version_checkbox_layout.addWidget(self.ram_label, 1)
        self.repo_link_label = QLabel()
        self.repo_link_label.setText('<a href="https://github.com/dmoke/BMC-EC-MC-client">GitHub</a>')
        self.repo_link_label.setOpenExternalLinks(True)
        version_checkbox_layout.addWidget(self.repo_link_label, 1)

        self.reinstall_forge_checkbox = QCheckBox("Reinstall Forge")
        self.reinstall_forge_checkbox.setChecked(False)  # Set default value
        version_checkbox_layout.addWidget(self.reinstall_forge_checkbox, 2, Qt.AlignmentFlag.AlignRight)
        # Create a QPushButton for the "Clear all data" option
        self.delete_purge_button = QPushButton("Delete launcher created data")
        self.delete_purge_button.setStyleSheet("color: red;")
        self.delete_purge_button.clicked.connect(self.confirm_purge_button)

        version_checkbox_layout.addWidget(self.delete_purge_button, 1, Qt.AlignmentFlag.AlignRight)

        # Add the combined layout to the main vertical layout
        self.vertical_layout.addLayout(version_checkbox_layout)

        self.update_ram_label()  # Update RAM label with default value
        # Add RAM slider and label to the layout

        self.vertical_layout.addWidget(self.start_progress_label)
        self.vertical_layout.addWidget(self.start_progress)
        self.vertical_layout.addWidget(self.start_button)

        self.setCentralWidget(self.centralwidget)

        self.launch_thread = LaunchThread()
        self.launch_thread.state_update_signal.connect(self.state_update)
        self.launch_thread.progress_update_signal.connect(self.update_progress)
        self.launch_thread.finished_signal.connect(launch_thread_finished)
        icon = QIcon("assets/icon.png")
        self.setWindowIcon(icon)

    def update_ram_label(self):
        ram_amount_gb = self.ram_slider.value()
        self.ram_label.setText(f"RAM: {ram_amount_gb}G")

    def state_update(self, value):
        self.start_button.setDisabled(value)
        self.start_progress_label.setVisible(value)
        self.start_progress.setVisible(value)

    def update_progress(self, progress, max_progress, label):
        self.start_progress.setValue(progress)
        self.start_progress.setMaximum(max_progress)
        self.start_progress_label.setText(label)

    def confirm_purge_button(self):
        # Implement your confirmation logic here
        confirm_dialog = QMessageBox()
        confirm_dialog.setIcon(QMessageBox.Question)
        confirm_dialog.setText("Are you sure you want to purge all data? All local configs will be lost.")
        confirm_dialog.setWindowTitle("Confirmation")
        confirm_dialog.setStandardButtons(QMessageBox.Yes | QMessageBox.No)
        confirm_dialog.setDefaultButton(QMessageBox.No)

        button_pressed = confirm_dialog.exec()

        if button_pressed == QMessageBox.Yes:
            # User clicked Yes, perform the reinstall action
            self.perform_purge_action()

    def launch_game(self):

        self.start_progress_label.setText("Checking for updates...")
        self.start_progress.setValue(100)

        # Start the launch thread after Forge installation
        self.launch_thread.launch_setup_signal.emit(FORGE_VERSION_ID, self.username.text(),
                                                    self.reinstall_forge_checkbox.isChecked(),
                                                    self.current_launcher_version,
                                                    self.ram_slider.value())

        self.launch_thread.start()

    def perform_purge_action(self):
        try:
            # Delete the entire minecraft_directory and recreate it
            shutil.rmtree(minecraft_directory)
            create_minecraft_directory()

            # Display an alert - data deleted successfully
            QMessageBox.information(self, "Purge Successful", "All data has been purged successfully.")

        except Exception as e:
            # Handle any errors that may occur during the purge
            QMessageBox.critical(self, "Error", f"An error occurred during the purge: {str(e)}")


if __name__ == '__main__':
    username = ''

    # Check if there are enough arguments
    if len(sys.argv) > 1:
        # Iterate through arguments in reverse order
        for i in range(len(sys.argv) - 1, 0, -1):
            # Check if the current argument is not "--username"
            if sys.argv[i] != '--username':
                # Set username to the current argument
                username = sys.argv[i]
                break  # Stop iterating after finding the first non "--username" argument

    QApplication.setAttribute(Qt.ApplicationAttribute.AA_EnableHighDpiScaling, True)

    app = QApplication(sys.argv)
    window = MainWindow(username)
    window.resize(640, 480)
    window.show()

    sys.exit(app.exec_())
