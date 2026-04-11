@echo off
setlocal enabledelayedexpansion

echo ====================================================
echo    Vencord + Quest Plugin: Auto-Repair ^& Installer
echo ====================================================

:: --- PRE-FLIGHT CHECKS ---

:: 1. Check for Git (CRITICAL)
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Git is NOT installed or not in your PATH.
    echo Please install Git from: https://git-scm.com/
    echo after installing, restart this script.
    pause
    exit /b 1
)

:: 2. Check for Node.js
node -v >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is not installed! 
    echo Please download the LTS version from https://nodejs.org/
    pause
    exit /b 1
)

:: 3. Close Discord PTB to unlock files
echo Closing Discord PTB to prevent file locks...
taskkill /f /im DiscordPTB.exe >nul 2>&1
timeout /t 2 /nobreak >nul

:: --- CONFIGURATION ---
SET "ROOT_DIR=%~dp0"
SET "VENCORD_DIR=%ROOT_DIR%Vencord_Modified"
SET "PLUGIN_DIR=%VENCORD_DIR%\src\userplugins\CompleteDiscordQuest"

echo.
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
:: Using --yes to skip any prompts
call npx pnpm install --yes || (
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
echo  [!] Setup complete. You can now open Discord PTB.
echo.
pause
exit