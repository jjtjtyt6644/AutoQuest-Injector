# 🚀 AutoQuest Injector GUI

**A premium, fully-automated graphical installer for Vencord and the CompleteDiscordQuest plugin.**

Designed to make the installation process seamless, the AutoQuest Injector provides a beautiful glassmorphism-inspired setup wizard that handles everything from environment checks to Discord client management and plugin injection.

---

## ✨ Key Features

* **Premium UI/UX**: A sleek, dark-mode graphical wrapper featuring custom transitions and step-by-step navigation.
* **Smart Discord Detection**: Automatically scans your system for standard Discord, Discord PTB, and Discord Canary.
* **Automated PTB Migration**: AutoQuest is optimized for Discord PTB. The installer can automatically uninstall regular Discord and set up Discord PTB for you in one click.
* **Pre-flight Guard**: Verifies that **Git** and **Node.js** are securely installed and configured in your System PATH before beginning.
* **Persistent Configuration**: Smart-save technology remembers your preferred Vencord download and installation directories for future updates.
* **One-Click Uninstallation**: Seamlessly and safely removes Vencord and the plugin from your Discord client to revert to stock.

---

## 📥 How to Use

### Using the Compiled Installer (Recommended)

1.  **Download**: Get the `AutoQuest Injector Setup.exe` from the [Releases page](https://github.com/jjtjtyt6644/AutoQuest-Injector/releases/download/V1.0.0/AutoQuest.Injector.Setup.1.0.0.exe).
2.  **Install**: Run the executable. It will automatically add a shortcut to your Desktop.
3.  **Inject**: Follow the animated setup wizard to clone the source and install the plugin.
4.  **Discord Updated?**: Whenever Discord updates, simply open the app from your desktop and click **Start Injection** to re-patch the new version files.

---

## 🛠️ Requirements

The GUI handles the complex automation, but your system must meet these baseline requirements for the compiling backend to function:

* **Operating System**: Windows 10 / 11 (64-bit)
* **Git**: [Download Git](https://git-scm.com/downloads) (Required for pulling the Vencord source).
* **Node.js**: [Download Node.js](https://nodejs.org/) (Required for compiling the Vencord injection layer).

---

## 🏗️ Project Architecture

The application is split into two robust layers:

1.  **Frontend (Electron)**: Located in the `/ui/` directory. Provides the multi-step `index.html` interface styled with custom CSS glassmorphism. Communicates via IPC bridges to handle OS-level checks and process management.
2.  **Backend Engine (Batch)**: The `injectquest.bat` file acts as the core engine. Driven dynamically by the Electron frontend, it accepts parameterized inputs to handle silent cloning, dependency management (`pnpm`), and automated Discord patching.

---

## 📜 Credits

* **GUI & Automation Architecture**: [Junyu (jjtjtyt6644)](https://github.com/jjtjtyt6644/AutoQuest-Injector)
* **Core Framework**: Powered by [Vencord](https://vencord.dev/)
* **Plugin Logic**: [CompleteDiscordQuest](https://github.com/jjtjtyt6644/AutoQuest-Plugin)