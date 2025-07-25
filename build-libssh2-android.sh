#!/bin/bash

set -e

LIBSSH2_DIR="libssh2"
NDK_ROOT=$ANDROID_NDK_HOME
TOOLCHAIN="$NDK_ROOT/toolchains/llvm/prebuilt/darwin-x86_64"
API=21
BUILD_DIR="$(pwd)/libssh2-android-build"
ZLIB_ROOT="$(pwd)/zlib-android-build"
OPENSSL_ROOT="$(pwd)/openssl-android-build"

ARCHS=(
  "armeabi-v7a:android-arm:armv7a-linux-androideabi:armeabi-v7a"
  "arm64-v8a:android-arm64:aarch64-linux-android:arm64-v8a"
  "x86:android-x86:i686-linux-android:x86"
  "x86_64:android-x86_64:x86_64-linux-android:x86_64"
)

for entry in "${ARCHS[@]}"; do
  IFS=":" read ABI TARGET HOST ARCH_NAME <<< "$entry"
  echo "🛠️ Building libssh2 for $ABI"

  BUILD_ABI_DIR=$BUILD_DIR/$ABI
  rm -rf $BUILD_ABI_DIR
  mkdir -p $BUILD_ABI_DIR
  pushd $BUILD_ABI_DIR

  cmake ../../$LIBSSH2_DIR \
    -DCMAKE_TOOLCHAIN_FILE=$NDK_ROOT/build/cmake/android.toolchain.cmake \
    -DANDROID_ABI=$ABI \
    -DANDROID_PLATFORM=android-$API \
    -DBUILD_SHARED_LIBS=ON \
    -DENABLE_DEBUG_LOGGING=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DENABLE_ZLIB_COMPRESSION=ON \
    -DZLIB_LIBRARY=$ZLIB_ROOT/$ABI/lib/libz.a \
    -DZLIB_INCLUDE_DIR=$ZLIB_ROOT/$ABI/include \
    -DCRYPTO_BACKEND=OpenSSL \
    -DOPENSSL_ROOT_DIR=$OPENSSL_ROOT/$ABI \
    -DOPENSSL_CRYPTO_LIBRARY=$OPENSSL_ROOT/$ABI/lib/libcrypto.a \
    -DOPENSSL_INCLUDE_DIR=$OPENSSL_ROOT/$ABI/include \
    -DCMAKE_INSTALL_PREFIX=$BUILD_DIR/$ABI/

  make -j$(sysctl -n hw.ncpu)
  make install
  popd
done

echo "✅ All libssh2 builds complete. Output: $BUILD_DIR"
