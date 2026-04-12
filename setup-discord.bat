@echo off
setlocal enabledelayedexpansion

echo ====================================================
echo           Discord PTB Setup Engine
echo ====================================================

:: Mode: install-ptb, replace-discord, uninstall-ptb, install-stable
SET "MODE=%~1"
IF "!MODE!"=="" SET "MODE=install-ptb"

echo Target Mode: !MODE!
echo.

IF "!MODE!"=="replace-discord" GOTO :REPLACE_FLOW
GOTO :INSTALL_ONLY_FLOW

:REPLACE_FLOW
echo [DISCORD] Preparing for migration...
echo [DISCORD] Closing all Discord processes...
taskkill /f /im Discord.exe >nul 2>&1
taskkill /f /im DiscordCanary.exe >nul 2>&1
ping -n 2 127.0.0.1 >nul

:INSTALL_ONLY_FLOW
echo [DISCORD] Starting Discord PTB acquisition...
SET "PTB_INSTALLER=!TEMP!\DiscordPTBSetup_!RANDOM!.exe"

:: 3-TIER DOWNLOAD FALLBACK
echo [DISCORD] Downloading Discord PTB installer...
SET "TRY_COUNT=0"

:CURL_RETRY
SET /A TRY_COUNT+=1
if exist "!PTB_INSTALLER!" del /f /q "!PTB_INSTALLER!" >nul 2>&1
curl -L "https://discord.com/api/download/ptb?platform=win" -k -o "!PTB_INSTALLER!"

:: Verify the file exists AND is not empty
IF NOT EXIST "!PTB_INSTALLER!" GOTO :CURL_FAIL
for %%X in ("!PTB_INSTALLER!") do set "SIZE=%%~zX"
IF !SIZE! LSS 1000000 GOTO :CURL_FAIL

:: Success
SET "DOWNLOAD_OK=1"
GOTO :CONTINUE_SETUP

:CURL_FAIL
IF !TRY_COUNT! LSS 3 (
    echo [DISCORD] Connection reset or download failed. Retrying (!TRY_COUNT!/3)...
    ping -n 3 127.0.0.1 >nul
    GOTO :CURL_RETRY
)
GOTO :FALLBACK_TIER2

:FALLBACK_TIER2
echo [DISCORD] Curl failed multiple times. Spoofing browser headers (Invoke-WebRequest)...
if exist "!PTB_INSTALLER!" del /f /q "!PTB_INSTALLER!" >nul 2>&1
powershell -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $h = @{'User-Agent'='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'; 'Accept'='text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8'}; try { Invoke-WebRequest -Uri 'https://discord.com/api/download/ptb?platform=win' -Headers $h -OutFile \"!PTB_INSTALLER!\" -MaximumRedirection 5 } catch { exit 1 }" >nul 2>&1

IF NOT EXIST "!PTB_INSTALLER!" GOTO :FALLBACK_TIER3
for %%X in ("!PTB_INSTALLER!") do set "SIZE=%%~zX"
IF !SIZE! LSS 1000000 GOTO :FALLBACK_TIER3
SET "DOWNLOAD_OK=1"
GOTO :CONTINUE_SETUP

:FALLBACK_TIER3
echo [DISCORD] PS WebRequest stuck or failed. Trying Final WebClient Fallback...
if exist "!PTB_INSTALLER!" del /f /q "!PTB_INSTALLER!" >nul 2>&1
powershell -ExecutionPolicy Bypass -Command "$wc = New-Object System.Net.WebClient; $wc.Headers.Add('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'); $wc.Headers.Add('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8'); try { $wc.DownloadFile('https://discord.com/api/download/ptb?platform=win', \"!PTB_INSTALLER!\") } catch { exit 1 }" >nul 2>&1

:CONTINUE_SETUP
IF NOT EXIST "!PTB_INSTALLER!" (
    echo [ERROR] Failed to download Discord PTB installer.
    echo [INFO] This might be due to your network or firewall.
    echo Please download it manually from: https://ptb.discord.com/
    exit /b 1
)

echo [DISCORD] Launching installer window...
start "" "!PTB_INSTALLER!"

echo [DISCORD] Waiting for setup process to initialize...
ping -n 8 127.0.0.1 >nul

echo.
echo ====================================================
echo   SUCCESS: Discord PTB setup was initiated.
echo   Please complete the login in the new window.
echo ====================================================
echo.
exit /b 0
