#!/bin/bash
adb devices
adb shell 'echo shell-ok; getprop sys.boot_completed; getprop dev.bootcomplete; getprop init.svc.bootanim'
