#!/usr/bin/env bash
# Cross-compiles the DolphinPort native core for Android and places the shared
# object where the Android Gradle build picks it up.
#
# The Flutter release build targets arm64 only, so we build arm64-v8a. Add more
# `-t <abi>` targets here if the application later ships other ABIs.
set -euo pipefail

export ANDROID_HOME=/home/user/flutter_dev/android-sdk
export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/28.2.13676358"
export NDK_HOME="$ANDROID_NDK_HOME"

# shellcheck source=/dev/null
source "$HOME/.cargo/env"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

cargo ndk \
  -t arm64-v8a \
  -o ../android/app/src/main/jniLibs \
  build --release

echo "Native libraries:"
find ../android/app/src/main/jniLibs -name 'libdolphinport_core.so' -print
