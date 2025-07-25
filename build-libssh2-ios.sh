#!/bin/bash

set -e

LIBSSH2_DIR="libssh2"
BUILD_ROOT="$(pwd)/libssh2-ios-build"
ZLIB_ROOT="$(pwd)/zlib-ios-build"
OPENSSL_ROOT="$(pwd)/openssl-ios-build"

MIN_IOS_VERSION="11.0"
ARCHS=("arm64:iphoneos:ios64-xcrun"
       "arm64:iphonesimulator:iossimulator-xcrun"
       "x86_64:iphonesimulator:iossimulator-xcrun")

for ITEM in "${ARCHS[@]}"; do

  IFS=":" read -r ARCH PLATFORM TARGET <<< "$ITEM"
  echo "▶️ Building zlib for $ARCH ($PLATFORM - $TARGET)"

  export SDK_PATH=$(xcrun --sdk "$PLATFORM" --show-sdk-path)
  export CC=$(xcrun -find -sdk $PLATFORM clang)
  export CFLAGS="-arch $ARCH -pipe -Os -gdwarf-2 -isysroot $SDK_PATH -m$PLATFORM-version-min=$MIN_IOS_VERSION"

  BUILD_ARCH_DIR="$BUILD_ROOT/$ARCH-$PLATFORM"
  echo $BUILD_ARCH_DIR
  rm -rf $BUILD_ARCH_DIR
  mkdir -p $BUILD_ARCH_DIR
  pushd $BUILD_ARCH_DIR

  cmake ../../$LIBSSH2_DIR \
    -DCMAKE_SYSTEM_NAME=Darwin \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=$MIN_IOS_VERSION \
    -DCMAKE_OSX_SYSROOT=$SDK_PATH \
    -DCMAKE_OSX_ARCHITECTURES=$ARCH \
    -DBUILD_SHARED_LIBS=OFF \
    -DENABLE_ZLIB_COMPRESSION=ON \
    -DCRYPTO_BACKEND=OpenSSL \
    -DOPENSSL_ROOT_DIR="$OPENSSL_ROOT/$ARCH-$PLATFORM" \
    -DOPENSSL_LIBRARIES="$OPENSSL_ROOT/$ARCH-$PLATFORM/lib/libssl.a;$OPENSSL_ROOT/$ARCH-$PLATFORM/lib/libcrypto.a" \
    -DOPENSSL_INCLUDE_DIR="$OPENSSL_ROOT/$ARCH-$PLATFORM/include" \
    -DZLIB_LIBRARY="$ZLIB_ROOT/$ARCH-$PLATFORM/lib/libz.a" \
    -DZLIB_INCLUDE_DIR="$ZLIB_ROOT/$ARCH-$PLATFORM/include" \
    -DCMAKE_INSTALL_PREFIX="$BUILD_ARCH_DIR"

  make -j$(sysctl -n hw.ncpu)
  make install
  popd
done

echo "✅ All libssh2 iOS builds complete. Output: $BUILD_DIR"
