#!/usr/bin/env bash
set -euo pipefail
TASK_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${ANDROID_SDK_ROOT:=${ANDROID_HOME:-}}"
test -n "$ANDROID_SDK_ROOT" || { echo 'Set ANDROID_SDK_ROOT'; exit 1; }
: "${ANDROID_NDK_HOME:=$ANDROID_SDK_ROOT/ndk/28.2.13676358}"
export ANDROID_NDK_HOME
test -d "$ANDROID_NDK_HOME" || { echo 'Install Android NDK 28.2.13676358'; exit 1; }
test "$(cargo ndk --version)" = 'cargo-ndk 4.1.2' || { echo 'Install cargo-ndk: cargo install cargo-ndk --version 4.1.2 --locked'; exit 1; }
cd "$TASK_SCRIPT_DIR"
cargo ndk -t arm64-v8a -o ../android/app/src/main/jniLibs build --release --locked -p dolphinport-core
test -s ../android/app/src/main/jniLibs/arm64-v8a/libdolphinport_core.so
