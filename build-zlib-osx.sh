#!/bin/bash

set -e

ARCHS=("x86_64" "arm64")
ROOT_DIR=$(pwd)
SRC_DIR="$ROOT_DIR/zlib"
BUILD_ROOT="$ROOT_DIR/zlib-osx-build"

for ARCH in "${ARCHS[@]}"; do
  echo "▶️ Building for $ARCH"

  BUILD_DIR="$BUILD_ROOT/$ARCH"

  cd "$SRC_DIR"
  make distclean || true

  CFLAGS="-arch $ARCH" ./configure --prefix="$BUILD_DIR" --static
  make -j$(sysctl -n hw.ncpu)
  make install
done

echo "✅ All zlib builds complete. Output: $BUILD_DIR"
