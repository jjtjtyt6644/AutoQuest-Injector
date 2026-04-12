@echo off
setlocal enabledelayedexpansion

echo ====================================================
echo           CLEANUP ^& RESTORE ENGINE
echo ====================================================

:: Mode: uninject, shred-ptb, shred-discord, restore-stable
SET "MODE=%~1"
IF "!MODE!"=="" SET "MODE=uninject"
SET "VENCORD_DIR=%~2"

echo Target Mode: !MODE!
echo.

IF "!MODE!"=="uninject" GOTO :UNINJECT_FLOW
IF "!MODE!"=="shred-ptb" GOTO :SHRED_PTB_FLOW
IF "!MODE!"=="shred-discord" GOTO :SHRED_DISCORD_FLOW
IF "!MODE!"=="restore-stable" GOTO :RESTORE_STABLE_FLOW
echo [ERROR] Unknown mode: !MODE!
exit /b 1

:UNINJECT_FLOW
echo [CLEANUP] Starting Surgical Uninject...
IF "!VENCORD_DIR!"=="" SET "VENCORD_DIR=Vencord_Modified"

:: Resolve absolute path
SET "ORIG_DIR=%CD%"
pushd "!VENCORD_DIR!" >nul 2>&1
SET "ABS_VENCORD_DIR=%CD%"
popd >nul 2>&1

:: 1. SURGICAL UNPATCH (Bypass the interactive CLI)
echo [CLEANUP] Detecting Vencord patches in Discord...

:: Check PTB Roaming/Local paths
SET "HAS_PATCHED=0"
FOR %%D in ("%APPDATA%\discordptb" "%LOCALAPPDATA%\DiscordPTB" "%APPDATA%\discord" "%LOCALAPPDATA%\Discord") DO (
    IF EXIST "%%~D" (
        :: Search for any app-*/resources/app.asar folder
        FOR /D %%V in ("%%~D\app-*\resources\app.asar") DO (
            IF EXIST "%%~V\..\_app.asar" (
                echo [CLEANUP] Found patch in: %%~V
                echo [CLEANUP] Restoring original app.asar...
                rd /s /q "%%~V" >nul 2>&1
                ren "%%~V\..\_app.asar" "app.asar" >nul 2>&1
                SET "HAS_PATCHED=1"
            )
        )
    )
)

IF "!HAS_PATCHED!"=="1" (
    echo [SUCCESS] Discord successfully unpatched surgically.
) ELSE (
    echo [INFO] No Vencord patch signatures found in standard paths.
)

:: 2. SOURCE SHREDDING
echo [CLEANUP] Proceeding to source folder removal...
cd /d "!ORIG_DIR!"

:: HARD NAME CHECK
SET "SAFE_PATH=0"
echo "!ABS_VENCORD_DIR!" | findstr /i "Vencord Modified" >nul 2>&1
IF !ERRORLEVEL! EQU 0 SET "SAFE_PATH=1"

IF "!SAFE_PATH!"=="1" (
    echo [CLEANUP] Shredding source: !ABS_VENCORD_DIR!
    SET "RETRY_COUNT=0"
    :RETRY_SHRED_LOOP
    rd /s /q "!ABS_VENCORD_DIR!" >nul 2>&1
    IF NOT EXIST "!ABS_VENCORD_DIR!" GOTO :SHRED_SUCCESS
    SET /A RETRY_COUNT+=1
    IF !RETRY_COUNT! GEQ 5 GOTO :SHRED_ESCALATE
    ping -n 2 127.0.0.1 >nul
    GOTO :RETRY_SHRED_LOOP
) ELSE (
    echo [WARNING] Safety check failed for source: !ABS_VENCORD_DIR!
    GOTO :EOF
)

:SHRED_ESCALATE
powershell -ExecutionPolicy Bypass -Command "Remove-Item -Path '!ABS_VENCORD_DIR!' -Recurse -Force -ErrorAction SilentlyContinue" >nul 2>&1
IF EXIST "!ABS_VENCORD_DIR!" (
    echo [WARNING] Source folder locked. Please delete manually.
) ELSE (
    GOTO :SHRED_SUCCESS
)
GOTO :EOF

:SHRED_SUCCESS
echo [SUCCESS: UNINJECT] Vencord source shredded.
GOTO :EOF

:SHRED_PTB_FLOW
echo [CLEANUP] Phase 2: Shredding Discord PTB Application...
taskkill /f /im DiscordPTB.exe >nul 2>&1
taskkill /f /im Update.exe >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "DiscordPTB" /f >nul 2>&1
if exist "%LOCALAPPDATA%\DiscordPTB" rd /s /q "%LOCALAPPDATA%\DiscordPTB" >nul 2>&1
if exist "%APPDATA%\DiscordPTB" rd /s /q "%APPDATA%\DiscordPTB" >nul 2>&1
echo [SUCCESS: SHRED] Discord PTB app deleted.
GOTO :EOF

:SHRED_DISCORD_FLOW
echo [CLEANUP] Phase 2: Shredding Discord Stable Application...
taskkill /f /im Discord.exe >nul 2>&1
taskkill /f /im Update.exe >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "Discord" /f >nul 2>&1
if exist "%LOCALAPPDATA%\Discord" rd /s /q "%LOCALAPPDATA%\Discord" >nul 2>&1
if exist "%APPDATA%\Discord" rd /s /q "%APPDATA%\Discord" >nul 2>&1
echo [SUCCESS: SHRED] Discord Stable app deleted.
GOTO :EOF

:RESTORE_STABLE_FLOW
echo [CLEANUP] Phase 2: Restoring Discord Stable...
SET "INSTALLER=!TEMP!\DiscordRestore_!RANDOM!.exe"
SET "TRY_COUNT=0"
:RETRY_CURL
SET /A TRY_COUNT+=1
if exist "!INSTALLER!" del /f /q "!INSTALLER!" >nul 2>&1
curl -L "https://discord.com/api/download?platform=win" -k -o "!INSTALLER!"
IF NOT EXIST "!INSTALLER!" GOTO :CURL_FAIL
for %%X in ("!INSTALLER!") do set "SIZE=%%~zX"
IF !SIZE! LSS 1000000 GOTO :CURL_FAIL
SET "DOWNLOAD_OK=1"
GOTO :LAUNCH_RESTORE
:CURL_FAIL
IF !TRY_COUNT! LSS 3 (
    ping -n 2 127.0.0.1 >nul
    GOTO :RETRY_CURL
)
GOTO :RESTORE_FALLBACK2
:RESTORE_FALLBACK2
powershell -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $h = @{'User-Agent'='Mozilla/5.0'; 'Accept'='*/*'}; try { Invoke-WebRequest -Uri 'https://discord.com/api/download?platform=win' -Headers $h -OutFile \"!INSTALLER!\" -MaximumRedirection 5 } catch { exit 1 }" >nul 2>&1
:LAUNCH_RESTORE
start "" "!INSTALLER!"
echo [SUCCESS] Discord Stable restoration initiated.
GOTO :EOF
