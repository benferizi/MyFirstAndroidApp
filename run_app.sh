#!/bin/bash
cd "/home/ben/Projects/Android/MyFirstAndroidApp" || exit 1
./gradlew :app:installDebug
adb shell am start -n com.example.myfirstandroidapp/.MainActivity
