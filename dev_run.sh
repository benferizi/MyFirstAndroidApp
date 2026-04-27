#!/bin/bash
set -e

PROJECT_DIR="/home/ben/Projects/Android/MyFirstAndroidApp"
AVD_NAME="Pixel_3a_API_35"
APP_PACKAGE="com.example.myfirstandroidapp"
MAIN_ACTIVITY=".MainActivity"

cd "$PROJECT_DIR"

echo "== Checking for connected emulator =="

if ! adb devices | awk 'NR > 1 && $2 == "device" { found=1 } END { exit !found }'; then
  echo "No ready emulator found. Starting $AVD_NAME..."
  nohup emulator -avd "$AVD_NAME" -no-snapshot -no-audio -no-boot-anim -gpu swiftshader_indirect > /tmp/android-emulator.log 2>&1 &
else
  echo "Emulator already connected."
fi

echo "== Waiting for emulator boot =="
adb wait-for-device

SECONDS_WAITED=0
until [ "$(adb shell getprop sys.boot_completed | tr -d '\r')" = "1" ] && [ "$(adb shell getprop init.svc.bootanim | tr -d '\r')" = "stopped" ]; do
  if [ "$SECONDS_WAITED" -ge 240 ]; then
    echo "Emulator did not finish booting within 4 minutes."
    echo "Check log: /tmp/android-emulator.log"
    exit 1
  fi
  sleep 3
  SECONDS_WAITED=$((SECONDS_WAITED + 3))
  echo "Waiting... ${SECONDS_WAITED}s"
done

echo "== Emulator ready =="
adb devices
adb shell 'echo shell-ok; getprop sys.boot_completed; getprop dev.bootcomplete; getprop init.svc.bootanim'

echo "== Installing app =="
./gradlew :app:installDebug

echo "== Launching app =="
adb shell am start -n "$APP_PACKAGE/$MAIN_ACTIVITY"

echo "DONE."
