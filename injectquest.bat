@echo off
setlocal enabledelayedexpansion

echo ====================================================
echo   Vencord + Quest Plugin: Auto-Repair ^& Installer
echo ====================================================

:: [NEW] Kill Discord PTB process if it's running to unlock files
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
echo [1/6] Checking Vencord Source...
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
echo [2/6] Checking Quest Plugin...
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
echo [3/6] Syncing Submodules...
pushd "%VENCORD_DIR%"
git submodule update --init --recursive

echo.
echo [4/6] Installing Dependencies (This may take a minute)...
call npx pnpm install
if %errorlevel% neq 0 (
    echo ERROR: pnpm install failed.
    pause
    exit /b 1
)

echo.
echo [5/6] Building and Injecting...
call npx pnpm build
call npx pnpm inject --branch ptb

echo.
echo [6/6] Launching Discord PTB...
set "PTB_PATH=%LocalAppData%\DiscordPTB"
set "FINAL_EXE="

:: Find the newest version of the PTB executable
for /f "delims=" %%i in ('dir /s /b "%PTB_PATH%\DiscordPTB.exe" 2^>nul') do (
    set "FINAL_EXE=%%i"
)

if defined FINAL_EXE (
    echo Launching Discord PTB and exiting...
    :: Start Discord detached so logs don't show up here
    start "" "%FINAL_EXE%"
) else (
    echo [!] Launch failed: Could not find DiscordPTB.exe automatically.
    echo Please open Discord PTB manually.
    pause
)

popd
echo.
echo ====================================================
echo   DONE! Vencord is ready. Closing in 3 seconds...
echo ====================================================
timeout /t 3 /nobreak >nul
exit