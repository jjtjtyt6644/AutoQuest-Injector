# 🚀 AutoQuest Injector GUI

A premium, fully-automated graphical installer for Vencord and the CompleteDiscordQuest plugin. 

Designed to make the installation process seamless, the AutoQuest Injector provides a beautiful glassmorphism-inspired setup wizard that handles everything from environment checks to Discord client management and plugin injection.

---

## ✨ Key Features

* **Premium UI/UX**: A sleek, dark-mode graphical wrapper featuring custom transitions and step-by-step navigation.
* **Smart Discord Detection**: Automatically scans your system for standard Discord, Discord PTB, and Discord Canary.
* **Automated PTB Setup**: AutoQuest requires Discord PTB. The installer can automatically uninstall regular Discord and set up Discord PTB for you in one click.
* **Pre-flight Checks**: Verifies that Git and Node.js are securely installed on your system before beginning.
* **Persistent Configuration**: Remembers your preferred Vencord download and installation directories for future updates.
* **One-Click Uninstallation**: Seamlessly and safely removes Vencord and the plugin from your Discord client.

---

## 📥 How to Use

### Using the Compiled Installer (Recommended)
You do not need to install Node.js globally just to run the GUI if you have the `.exe`.
1. Download `AutoQuest Injector Setup.exe` from the Releases page.
2. Run the executable. It will automatically add a shortcut to your Desktop.
3. Follow the animated setup wizard to install the plugin.
4. **Discord Updated?** Simply open the app from your desktop again and click **Start Injection** to re-apply the patch.

### Running from Source
If you are developing or running the tool directly from the repository:
1. Ensure both **Git** and **Node.js (LTS)** are installed.
2. Double-click `start-gui.bat` to launch the premium UI.
3. To package your own `.exe` file for distribution, run `build-exe.bat`. The built installer will appear in the `ui/dist` folder.

---

## 🛠️ Requirements

The GUI handles most of the complex work, but your system must meet these baseline requirements for the compiling backend to work:
* **Operating System**: Windows 10 / 11
* **Git**: [Download Git](https://git-scm.com/downloads) (Required for pulling the Vencord source).
* **Node.js**: [Download Node.js](https://nodejs.org/) (Required for compiling the Vencord injection layer).

---

## 🏗️ Project Architecture

The app is split into two robust layers:
1. **Frontend (Electron)**: Located in the `/ui/` directory. Provides the multi-step `index.html` interface styled with custom CSS glassmorphism. Communicates via IPC bridges to handle OS-level checks.
2. **Backend Engine (Batch)**: The `injectquest.bat` file acts as the core engine. Driven dynamically by the Electron frontend, it accepts parameterized inputs to handle silent cloning, dependency management, and silent Discord PTB auto-installations.

---

## 📜 Credits
* **GUI & Automation Architecture:** Junyu ([jjtjtyt6644](https://github.com/jjtjtyt6644/AutoQuest-Injector))
* **Core Framework:** Powered by [Vencord](https://vencord.dev/)