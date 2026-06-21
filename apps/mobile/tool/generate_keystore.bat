@echo off
REM BabyMon Android Release Keystore Generator
REM ==========================================
REM Run this script to generate a release keystore for Android app signing.
REM Requires Java keytool (included with JDK).
REM
REM Usage: generate_keystore.bat
REM
REM After running, place key.properties in apps/mobile/android/ with:
REM   storePassword=<your-store-password>
REM   keyPassword=<your-key-password>
REM   keyAlias=babymon-release
REM   storeFile=../babymon-release.keystore

setlocal

echo.
echo ========================================
echo   BabyMon Release Keystore Generator
echo ========================================
echo.

set KEYSTORE_FILE=apps\mobile\android\babymon-release.keystore
set KEYSTORE_PASS=
set KEY_ALIAS=babymon-release
set KEY_PASS=
set VALIDITY_DAYS=10000

REM Check for Java keytool
where keytool >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Java keytool not found. Please install JDK and ensure it is in your PATH.
    exit /b 1
)

REM Prompt for passwords
set /p KEYSTORE_PASS="Enter keystore password (min 6 chars): "
set /p KEY_PASS="Enter key password (or press Enter to use keystore password): "
if "%KEY_PASS%"=="" set KEY_PASS=%KEYSTORE_PASS%

echo.
echo Generating keystore at %KEYSTORE_FILE% ...

keytool -genkey -v ^
    -keystore %KEYSTORE_FILE% ^
    -alias %KEY_ALIAS% ^
    -keyalg RSA ^
    -keysize 2048 ^
    -validity %VALIDITY_DAYS% ^
    -storepass %KEYSTORE_PASS% ^
    -keypass %KEY_PASS% ^
    -dname "CN=BabyMon, OU=Development, O=BabyMon, L=City, S=State, C=US"

if %ERRORLEVEL% equ 0 (
    echo.
    echo [SUCCESS] Keystore generated successfully!
    echo.
    echo ----------------------------------------
    echo  NEXT STEPS:
    echo ----------------------------------------
    echo.
    echo 1. Create apps\mobile\android\key.properties with:
    echo    storePassword=%KEYSTORE_PASS%
    echo    keyPassword=%KEY_PASS%
    echo    keyAlias=%KEY_ALIAS%
    echo    storeFile=../babymon-release.keystore
    echo.
    echo 2. Add key.properties to .gitignore (do NOT commit!)
    echo.
    echo 3. Build release APK/AAB:
    echo    cd apps\mobile ^&^& flutter build appbundle --release
    echo.
    echo ----------------------------------------
    echo  SECURITY WARNING:
    echo  Keep your keystore and passwords secure.
    echo  If you lose them, you CANNOT update your
    echo  app on Google Play.
    echo ----------------------------------------
) else (
    echo [ERROR] Keystore generation failed. Check the error above.
)

endlocal
