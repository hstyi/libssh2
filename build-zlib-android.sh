#!/bin/bash

ZLIB_VERSION="zlib"
NDK_ROOT=$ANDROID_NDK_HOME
export ANDROID_NDK_ROOT=$NDK_ROOT
TOOLCHAIN="$NDK_ROOT/toolchains/llvm/prebuilt/darwin-x86_64"
API=21
OUTPUT_DIR="$(pwd)/zlib-android-build"

ARCHS=(
  "armeabi-v7a:android-arm:armv7a-linux-androideabi"
  "arm64-v8a:android-arm64:aarch64-linux-android"
  "x86:android-x86:i686-linux-android"
  "x86_64:android-x86_64:x86_64-linux-android"
)

for entry in "${ARCHS[@]}"; do
  IFS=":" read ABI TARGET HOST <<< "$entry"
  echo "🛠️ Building for $ABI ($TARGET)"

  cd $ZLIB_VERSION
  make clean

  export TARGET_HOST=$HOST
  export ANDROID_ARCH=arm64-v8a
  export PATH=$TOOLCHAIN/bin:$PATH
  export BUILD_DIR=$PWD/build
  export MIN_SDK_VERSION=$API

  export AR=$TOOLCHAIN/bin/llvm-ar
  export CC=$TOOLCHAIN/bin/$TARGET_HOST$MIN_SDK_VERSION-clang
  export AS=$CC
  export CXX=$TOOLCHAIN/bin/$TARGET_HOST$MIN_SDK_VERSION-clang++
  export CHOST=$TARGET_HOST
  export LD=$TOOLCHAIN/bin/ld
  export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
  export STRIP=$TOOLCHAIN/bin/llvm-strip

  CFLAGS="-fPIC" ./configure --prefix=$OUTPUT_DIR/$ABI --static || exit 1

  make -j$(sysctl -n hw.ncpu) || exit 1
  make install || exit 1
  cd ..
done

echo "✅ All zlib builds complete. Output: $OUTPUT_DIR"
