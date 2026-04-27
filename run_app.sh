#!/bin/bash
set -e
cd "/home/ben/Projects/Android/MyFirstAndroidApp"
./gradlew :app:installDebug
adb shell am start -n com.example.myfirstandroidapp/.MainActivity
