#!/bin/bash
set -e

PROJECT_DIR="/home/ben/Projects/Android/MyFirstAndroidApp"
APP_PACKAGE="com.example.myfirstandroidapp"
MAIN_ACTIVITY=".MainActivity"

echo "== Android Master Setup =="
cd "$PROJECT_DIR"

echo "== Setting Git identity =="
git config --global user.name "benferizi"
git config --global user.email "benferizi@hotmail.com"

echo "== Creating safe .gitignore =="
cat > .gitignore <<'GITIGNORE'
# Gradle / Android build files
.gradle/
build/
*/build/
captures/
.externalNativeBuild/
.cxx/

# Local machine files
local.properties
*.iml
.idea/
.DS_Store

# Secrets / signing / environment
.env
.env.*
secrets.properties
keystore.properties
*.jks
*.keystore
*.pem
*.p12
*.key

# Logs
*.log

# OS junk
Thumbs.db
GITIGNORE

echo "== Creating local hidden secrets template =="
cat > secrets.properties.example <<'SECRETEXAMPLE'
# Copy this file to secrets.properties
# NEVER commit secrets.properties

API_KEY=put_your_api_key_here
KEYSTORE_PASSWORD=put_password_here
KEY_ALIAS=put_alias_here
KEY_PASSWORD=put_password_here
SECRETEXAMPLE

if [ ! -f secrets.properties ]; then
  cat > secrets.properties <<'SECRETLOCAL'
# Local secrets file.
# This file is ignored by Git.
# Put real secrets here only if needed.

API_KEY=
KEYSTORE_PASSWORD=
KEY_ALIAS=
KEY_PASSWORD=
SECRETLOCAL
fi

echo "== Creating Android CI workflow =="
mkdir -p .github/workflows

cat > .github/workflows/android-ci.yml <<'CI'
name: Android CI

on:
  push:
    branches: [ "main", "master" ]
  pull_request:
    branches: [ "main", "master" ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout project
        uses: actions/checkout@v4

      - name: Set up JDK
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: 17

      - name: Set up Gradle
        uses: gradle/actions/setup-gradle@v4

      - name: Make Gradle executable
        run: chmod +x ./gradlew

      - name: Run unit tests
        run: ./gradlew testDebugUnitTest

      - name: Build debug APK
        run: ./gradlew assembleDebug

      - name: Upload debug APK
        uses: actions/upload-artifact@v4
        with:
          name: debug-apk
          path: app/build/outputs/apk/debug/*.apk
CI

echo "== Creating run_app.sh =="
cat > run_app.sh <<RUNAPP
#!/bin/bash
set -e
cd "$PROJECT_DIR"
./gradlew :app:installDebug
adb shell am start -n $APP_PACKAGE/$MAIN_ACTIVITY
RUNAPP
chmod +x run_app.sh

echo "== Creating check_emulator.sh =="
cat > check_emulator.sh <<'CHECKEMU'
#!/bin/bash
adb devices
adb shell 'echo shell-ok; getprop sys.boot_completed; getprop dev.bootcomplete; getprop init.svc.bootanim'
CHECKEMU
chmod +x check_emulator.sh

echo "== Creating build_apk.sh =="
cat > build_apk.sh <<'BUILDAPK'
#!/bin/bash
set -e
./gradlew clean assembleDebug
echo "APK location:"
ls -lh app/build/outputs/apk/debug/*.apk
BUILDAPK
chmod +x build_apk.sh

echo "== Checking for possible hardcoded secrets =="
grep -RIn --exclude-dir=.git --exclude=master_setup.sh --exclude=secrets.properties \
  "sk-\|api_key\|apikey\|API_KEY\|secret\|token\|password" \
  app/ build.gradle.kts settings.gradle.kts gradle.properties .github/ 2>/dev/null || true

echo "== Testing local build =="
./gradlew testDebugUnitTest assembleDebug

echo "== Git status =="
git status

echo ""
echo "DONE."
echo ""
echo "Next commands:"
echo "  git add ."
echo "  git commit -m \"Add master Android setup\""
echo "  git status"
echo ""
echo "To run app:"
echo "  ./check_emulator.sh"
echo "  ./run_app.sh"
