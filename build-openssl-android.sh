#!/bin/bash

OPENSSL_VERSION="openssl"
NDK_ROOT=$ANDROID_NDK_HOME
export ANDROID_NDK_ROOT=$NDK_ROOT
TOOLCHAIN="$NDK_ROOT/toolchains/llvm/prebuilt/darwin-x86_64"
API=21
OUTPUT_DIR="$(pwd)/openssl-android-build"

ARCHS=(
  "armeabi-v7a:android-arm:armv7a-linux-androideabi"
  "arm64-v8a:android-arm64:aarch64-linux-android"
  "x86:android-x86:i686-linux-android"
  "x86_64:android-x86_64:x86_64-linux-android"
)

for entry in "${ARCHS[@]}"; do
  IFS=":" read ABI TARGET HOST <<< "$entry"
  echo "🛠️ Building for $ABI ($TARGET)"

  cd $OPENSSL_VERSION
  make clean > /dev/null 2>&1

  export ANDROID_NDK_HOME="$NDK_ROOT"
  export ANDROID_NDK_ROOT="$NDK_ROOT"
  export PATH="$TOOLCHAIN/bin:$PATH"
  export AR=llvm-ar
  export AS=llvm-as
  export CC=${HOST}${API}-clang
  export CXX=${HOST}${API}-clang++
  export LD=ld.lld
  export RANLIB=llvm-ranlib
  export STRIP=llvm-strip

  ./Configure $TARGET no-shared no-tests no-module no-ui no-stdio no-dso \
    --prefix=$OUTPUT_DIR/$ABI || exit 1

  make -j$(sysctl -n hw.ncpu) > /dev/null 2>&1 || exit 1
  make install_sw > /dev/null 2>&1 || exit 1
  cd ..
done

echo "✅ All OpenSSL builds complete. Output: $OUTPUT_DIR"
