@echo off
setlocal enabledelayedexpansion

echo ====================================================
echo    Vencord + Quest Plugin: Auto-Repair ^& Installer
echo ====================================================

:: --- CONFIGURATION ---
SET "ROOT_DIR=%~dp0"
IF "%~1" NEQ "" (
    SET "VENCORD_BASE=%~1"
) ELSE (
    SET "VENCORD_BASE=%ROOT_DIR%"
)
:: Ensure trailing backslash before appending
IF NOT "!VENCORD_BASE:~-1!"=="\" SET "VENCORD_BASE=!VENCORD_BASE!\"
SET "VENCORD_DIR=!VENCORD_BASE!Vencord_Modified"
SET "PLUGIN_DIR=!VENCORD_DIR!\src\userplugins\CompleteDiscordQuest"

:: Mode: install or uninstall
SET "MODE=%~2"
IF "!MODE!"=="" SET "MODE=install"

:: Discord Setup Mode: skip, install-ptb, replace-discord
SET "DISCORD_MODE=%~3"
IF "!DISCORD_MODE!"=="" SET "DISCORD_MODE=skip"

echo Mode: !MODE!
echo Discord Mode: !DISCORD_MODE!
echo.

:: --- PRE-FLIGHT CHECKS ---
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Git is NOT installed or not in your PATH.
    echo Please install Git from: https://git-scm.com/
    pause
    exit /b 1
)

node -v >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is not installed!
    echo Please download the LTS version from https://nodejs.org/
    pause
    exit /b 1
)

:: --- DISCORD SETUP ---
IF "!DISCORD_MODE!"=="replace-discord" GOTO REPLACE_DISCORD
IF "!DISCORD_MODE!"=="install-ptb" GOTO INSTALL_PTB_ONLY
GOTO AFTER_DISCORD_SETUP

:REPLACE_DISCORD
echo [DISCORD] Removing regular Discord...
taskkill /f /im Discord.exe >nul 2>&1
taskkill /f /im DiscordCanary.exe >nul 2>&1
ping -n 2 127.0.0.1 >nul

:: Try to find and run Discord uninstaller from common path
SET "DISCORD_UNINST=%LOCALAPPDATA%\Discord\Update.exe"
IF EXIST "!DISCORD_UNINST!" (
    echo [DISCORD] Running Discord uninstaller...
    start /wait "" "!DISCORD_UNINST!" --uninstall
    ping -n 3 127.0.0.1 >nul
) ELSE (
    echo [WARNING] Regular Discord uninstaller not found. Skipping removal.
)

:INSTALL_PTB_ONLY
echo [DISCORD] Downloading and installing Discord PTB...
SET "PTB_INSTALLER=%TEMP%\DiscordPTBSetup.exe"
:: Use PowerShell to download PTB installer
powershell -Command "Invoke-WebRequest -Uri 'https://discordapp.com/api/download/ptb?platform=win' -OutFile '!PTB_INSTALLER!'" >nul 2>&1
IF NOT EXIST "!PTB_INSTALLER!" (
    echo [ERROR] Failed to download Discord PTB installer.
    exit /b 1
)
echo [DISCORD] Launching PTB installer...
start /wait "" "!PTB_INSTALLER!"
del "!PTB_INSTALLER!" >nul 2>&1
echo [DISCORD] Discord PTB installed.
ping -n 3 127.0.0.1 >nul

:AFTER_DISCORD_SETUP

:: Close Discord PTB to unlock files
echo Closing Discord PTB to prevent file locks...
taskkill /f /im DiscordPTB.exe >nul 2>&1
ping -n 3 127.0.0.1 >nul

:: --- BRANCH LOGIC ---
IF "!MODE!"=="uninstall" GOTO UNINSTALL_FLOW

:INSTALL_FLOW
echo [1/5] Checking Vencord Source...
IF EXIST "%VENCORD_DIR%" (
    IF NOT EXIST "%VENCORD_DIR%\package.json" (
        echo [!] Vencord folder is corrupted. Re-downloading...
        rd /s /q "%VENCORD_DIR%"
    )
)

IF NOT EXIST "%VENCORD_DIR%" (
    echo Creating "Vencord_Modified" and downloading fresh source...
    git clone https://github.com/Vendicated/Vencord.git "%VENCORD_DIR%" || (
        echo [ERROR] Git clone failed. Check your connection.
        pause
        exit /b 1
    )
)

echo.
echo [2/5] Checking Quest Plugin...
IF NOT EXIST "%PLUGIN_DIR%" (
    git clone https://github.com/jjtjtyt6644/AutoQuest-Plugin.git "%PLUGIN_DIR%"
) else (
    echo Updating Quest plugin...
    pushd "%PLUGIN_DIR%" && (
        git pull
        popd
    )
)

echo.
echo [3/5] Syncing Submodules...
pushd "%VENCORD_DIR%" || exit /b 1
git submodule update --init --recursive

echo.
echo [4/5] Installing Dependencies...
call npx pnpm install || (
    echo [ERROR] pnpm install failed.
    pause
    exit /b 1
)

echo.
echo [5/5] Building and Injecting...
echo This may take a few moments...
call npx pnpm build || (echo [ERROR] Build failed. & pause & exit /b 1)
call npx pnpm inject --branch ptb || (echo [ERROR] Injection failed. Ensure Discord is fully closed. & pause & exit /b 1)

popd
echo.
echo ====================================================
echo   SUCCESS: Injected into Discord PTB.
echo ====================================================
echo.
exit

:UNINSTALL_FLOW
echo [!] Uninstall Mode Selected
IF NOT EXIST "%VENCORD_DIR%" (
    echo [ERROR] Vencord folder not found at "!VENCORD_DIR!"
    echo Cannot uninstall without the source folder.
    pause
    exit /b 1
)

pushd "%VENCORD_DIR%" || exit /b 1
echo.
echo [1/2] Uninstalling from Discord...
call npx pnpm uninject --branch ptb || (
    echo [ERROR] Uninjection failed. Ensure Discord is fully closed.
    pause
    exit /b 1
)

echo.
echo [2/2] Cleanup complete.
popd

echo.
echo ====================================================
echo   SUCCESS: Uninstalled from Discord PTB.
echo ====================================================
echo.
exit