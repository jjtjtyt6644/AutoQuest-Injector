@echo off
setlocal enabledelayedexpansion

echo ====================================================
echo   Vencord + Quest Plugin: Auto-Repair ^& Installer
echo ====================================================

:: Kill Discord PTB process if it's running to unlock files for injection
echo Closing Discord PTB to prevent file locks...
taskkill /f /im DiscordPTB.exe >nul 2>&1
timeout /t 2 /nobreak >nul

REM Get the directory where this script is sitting
SET "ROOT_DIR=%~dp0"
SET "VENCORD_DIR=%ROOT_DIR%Vencord"
SET "PLUGIN_DIR=%VENCORD_DIR%\src\userplugins\CompleteDiscordQuest"

:: Check for Node.js
node -v >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is not installed! Please install it from https://nodejs.org/
    pause
    exit /b 1
)

echo.
echo [1/5] Checking Vencord Source...
IF EXIST "%VENCORD_DIR%" (
    IF NOT EXIST "%VENCORD_DIR%\package.json" (
        echo Vencord folder is broken. Repairing...
        rd /s /q "%VENCORD_DIR%"
    )
)

IF NOT EXIST "%VENCORD_DIR%" (
    echo Downloading fresh Vencord...
    git clone https://github.com/Vendicated/Vencord.git "%VENCORD_DIR%"
) else (
    echo Vencord source found.
)

echo.
echo [2/5] Checking Quest Plugin...
IF NOT EXIST "%PLUGIN_DIR%" (
    echo Downloading CompleteDiscordQuest plugin...
    git clone https://github.com/nicola02nb/completeDiscordQuest.git "%PLUGIN_DIR%"
) else (
    echo Updating Quest plugin...
    pushd "%PLUGIN_DIR%"
    git pull
    popd
)

echo.
echo [3/5] Syncing Submodules...
pushd "%VENCORD_DIR%"
git submodule update --init --recursive

echo.
echo [4/5] Installing Dependencies (This may take a minute)...
call npx pnpm install
if %errorlevel% neq 0 (
    echo ERROR: pnpm install failed.
    pause
    exit /b 1
)

echo.
echo [5/5] Building and Injecting...
call npx pnpm build
call npx pnpm inject --branch ptb

popd
echo.
echo ====================================================
echo   SUCCESS: Vencord has been injected into PTB.
echo ====================================================
echo.
echo  [!] Please open Discord PTB manually now.
echo      If it's already open, please restart it.
echo.
pause
exit