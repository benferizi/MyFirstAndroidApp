#!/bin/bash
set -e
./gradlew clean assembleDebug
echo "APK location:"
ls -lh app/build/outputs/apk/debug/*.apk
