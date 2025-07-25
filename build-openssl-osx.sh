#!/bin/bash
set -e

ARCHS=("x86_64" "arm64")

ROOT_DIR=$(pwd)
SRC_DIR="$ROOT_DIR/openssl"
BUILD_ROOT="$ROOT_DIR/openssl-osx-build"

function get_target() {
  case $1 in
    x86_64) echo "darwin64-x86_64-cc" ;;
    arm64) echo "darwin64-arm64-cc" ;;
    *) echo "Unsupported arch"; exit 1 ;;
  esac
}

# 遍历架构并构建
for ARCH in "${ARCHS[@]}"; do
  echo "▶️ Building for $ARCH"

  TARGET=$(get_target $ARCH)
  BUILD_DIR="$BUILD_ROOT/$ARCH"

  cd "$SRC_DIR"
  make clean || true
  CFLAGS="-arch $ARCH" ./Configure $TARGET no-shared no-tests no-module no-ui no-stdio no-dso \
      --prefix=$BUILD_DIR || exit 1
  make -j$(sysctl -n hw.ncpu) > /dev/null 2>&1 || exit 1
  make install_sw > /dev/null 2>&1 || exit 1
done

echo "✅ All OpenSSL builds complete. Output: $OUTPUT_DIR"
