#!/usr/bin/env bash

# env | grep -i android

# ANDROID_HOME=your_path_to_Android/Sdk
# CAPACITOR_ANDROID_STUDIO_PATH=your_path_to/android-studio/bin/studio.sh

APKSIGNER_DIR=/home/creatxr/Android/Sdk/build-tools/33.0.0
APKSIGNER_DIR=/media/creatxr/WORK/DEV/Android/Sdk/build-tools/30.0.3
APKSIGNER_DIR="$ANDROID_HOME"/build-tools/30.0.3

APK_FILE=./android/app/build/outputs/apk/release/app-release-unsigned.apk

KEY_STORE=../my-release-key.keystore

