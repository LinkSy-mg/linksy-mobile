#!/usr/bin/env bash
# Builds the Rust bridge (rust/, wrapping linksy-core) for the three Android
# ABIs into android/app/src/main/jniLibs, where Flutter packs it into the APK.
# Regenerates the Dart bindings first when rust/src/api changed.
#
# Needs: rustup with aarch64/armv7/x86_64-linux-android targets, cargo-ndk,
# flutter_rust_bridge_codegen 2.13.0, the Android NDK, and SSH access to
# LinkSy-mg/linksy-desktop (linksy-core is a git dependency).
set -euo pipefail
cd "$(dirname "$0")/.."

export PATH="/opt/homebrew/opt/rustup/bin:$HOME/.cargo/bin:$PATH"
SDK=${ANDROID_HOME:-/opt/homebrew/share/android-commandlinetools}
export ANDROID_NDK_HOME=${ANDROID_NDK_HOME:-$SDK/ndk/28.2.13676358}

flutter_rust_bridge_codegen generate
(cd rust && cargo ndk -t arm64-v8a -t armeabi-v7a -t x86_64 -P 24 \
  -o ../android/app/src/main/jniLibs build --release)
# Only the bridge belongs here: cargo-ndk also copies the iroh crates' own
# libraries, which the bridge doesn't load, and they'd ship in the APK.
find android/app/src/main/jniLibs -name '*.so' ! -name liblinksy_bridge.so -delete
ls -la android/app/src/main/jniLibs/*/liblinksy_bridge.so
