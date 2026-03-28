# 🛠️ Vencord + Quest Plugin: Auto-Installer

This repository contains an automated setup and repair script for the **CompleteDiscordQuest** plugin. It handles the entire environment setup, from cloning Vencord to injecting the plugin into your Discord client.

---

## 🚀 One-Click Installation

The `install.bat` script is designed to be the only thing you need to run. It automates the following:

1.  **Environment Check:** Verifies if Node.js is installed.
2.  **Process Management:** Automatically closes Discord PTB to prevent file-lock errors.
3.  **Vencord Setup:** Clones a fresh copy of Vencord (or repairs it if corrupted).
4.  **Plugin Sync:** Downloads the latest version of the Quest Plugin.
5.  **Dependency Management:** Runs `pnpm install` and `git submodule update`.
6.  **Build & Inject:** Compiles the code and injects it specifically into the **Discord PTB** branch.
7.  **Auto-Launch:** Opens Discord PTB for you once the process is finished.

---

## 📥 How to Use

1.  **Download** this repository (or just the `install.bat` file).
2.  **Place** the file in an empty folder where you want your Vencord source to live.
3.  **Right-click `install.bat`** and select **Run as Administrator**.
4.  Wait for the "DONE!" message, and Discord PTB will launch automatically.

---

## ⚠️ Requirements

To use this injector, you must have the following installed on your system:

* **Git:** [Download Git](https://git-scm.com/downloads) (Required for cloning the source).
* **Node.js (LTS):** [Download Node.js](https://nodejs.org/) (Required to build the plugin).
* **Discord PTB:** This script targets the Public Test Build by default.

---

## 🛠️ Troubleshooting

| Issue | Solution |
| :--- | :--- |
| **"Node is not recognized"** | Ensure Node.js is installed and you have restarted your PC. |
| **Injection Failed** | Make sure Discord PTB is completely closed (check system tray). |
| **Git Clone Error** | Check your internet connection or ensure Git is in your System PATH. |

---

## 📜 Credits
* **Script Author:** [Junyu]
* **Framework:** [Vencord](https://vencord.dev/)