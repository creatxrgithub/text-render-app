#!/usr/bin/env bash

set -e

source ./releaseConfig.cmd

cd android && ./gradlew assembleRelease && cd ..
"${APKSIGNER_DIR}"/apksigner sign --ks-key-alias alias_name --ks "${KEY_STORE}" "${APK_FILE}"

mv ./android/app/build/outputs/apk/release/app-release-unsigned.apk ./android/app/build/outputs/apk/release/text-render-app.apk
