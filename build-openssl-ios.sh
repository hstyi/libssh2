#!/bin/bash
set -e

MIN_IOS_VERSION="11.0"

ROOT_DIR=$(pwd)
SRC_DIR="$ROOT_DIR/openssl"
BUILD_ROOT="$ROOT_DIR/openssl-ios-build"
ARCHS=("arm64:iphoneos:ios64-xcrun"
       "arm64:iphonesimulator:iossimulator-xcrun"
       "x86_64:iphonesimulator:iossimulator-xcrun")

rm -rf "$BUILD_ROOT"
mkdir -p "$BUILD_ROOT"

for ITEM in "${ARCHS[@]}"; do
  IFS=":" read -r ARCH PLATFORM TARGET <<< "$ITEM"
  echo "▶️ Building OpenSSL for $ARCH ($PLATFORM - $TARGET)"

  SDK_PATH=$(xcrun --sdk "$PLATFORM" --show-sdk-path)
  CC=$(xcrun -find -sdk $PLATFORM clang)
  CFLAGS="-arch $ARCH -pipe -Os -gdwarf-2 -isysroot $SDK_PATH -m$PLATFORM-version-min=$MIN_IOS_VERSION"

  BUILD_DIR="$BUILD_ROOT/$ARCH-$PLATFORM"
  mkdir -p "$BUILD_DIR"

  cd "$SRC_DIR"
  make clean || true

  export CC="$CC"
  export CFLAGS=$CFLAGS
  export LDFLAGS="-arch $ARCH -isysroot $SDK_PATH"

  ./Configure no-shared no-tests no-module no-ui no-stdio no-dso \
    --prefix="$BUILD_DIR" $TARGET || exit 1

  make -j$(sysctl -n hw.ncpu) > /dev/null 2>&1 || exit 1
  make install_sw > /dev/null 2>&1 || exit 1
done

echo "✅ All OpenSSL builds complete. Output: $BUILD_DIR"
