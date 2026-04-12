@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

echo ====================================================
echo    Vencord + Quest Plugin: Auto-Repair ^& Installer
echo ====================================================

:: --- CONFIGURATION ---
SET "ROOT_DIR=%~dp0"

:: Read from env vars (Unicode-safe) with fallback to cmd args
SET "VENCORD_BASE=%AQ_VPATH%"
IF "!VENCORD_BASE!"=="" SET "VENCORD_BASE=%~1"
IF "!VENCORD_BASE!"=="" SET "VENCORD_BASE=!ROOT_DIR!"

:: Ensure trailing backslash before appending
IF NOT "!VENCORD_BASE:~-1!"=="\" SET "VENCORD_BASE=!VENCORD_BASE!\"
SET "VENCORD_DIR=!VENCORD_BASE!Vencord_Modified"
SET "PLUGIN_DIR=!VENCORD_DIR!\src\userplugins\CompleteDiscordQuest"

:: Mode: install or uninstall
SET "MODE=%AQ_MODE%"
IF "!MODE!"=="" SET "MODE=%~2"
IF "!MODE!"=="" SET "MODE=install"

echo Mode: !MODE!
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

:: Ensure Discord PTB is closed to unlock files
echo [PROCESS] Closing Discord PTB to prevent file locks...
tasklist /FI "IMAGENAME eq DiscordPTB.exe" 2>NUL | find /I /N "DiscordPTB.exe">NUL
if "%ERRORLEVEL%"=="0" (
    taskkill /f /im DiscordPTB.exe >nul 2>&1
    ping -n 3 127.0.0.1 >nul
)

:: --- BRANCH LOGIC ---
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
exit /b 0