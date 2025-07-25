#!/bin/bash
set -e

#ARCHS=("x86_64" "aarch64" "arm" "ppc64le" "riscv64")
ARCHS=("x86_64" "aarch64")

ROOT_DIR=$(pwd)
SRC_DIR="$ROOT_DIR/openssl"
BUILD_ROOT="$ROOT_DIR/openssl-linux-build"

function get_target() {
  case $1 in
    x86) echo "linux-x86" ;;
    x86_64) echo "linux-x86_64" ;;
    aarch64) echo "linux-aarch64" ;;
    arm) echo "linux-armv4" ;;
    ppc64le) echo "linux-ppc64le" ;;
    riscv64) echo "linux-riscv64" ;;
    *) echo "Unsupported arch"; exit 1 ;;
  esac
}

# 遍历架构并构建
for ARCH in "${ARCHS[@]}"; do
  echo "▶️ Building openssl for $ARCH"

  TARGET=$(get_target $ARCH)
  BUILD_DIR="$BUILD_ROOT/$ARCH"

  case "$ARCH" in
    x86_64)
      CC="x86_64-linux-gnu-gcc"
      AR="x86_64-linux-gnu-ar"
      RANLIB="x86_64-linux-gnu-ranlib"
      ;;
    aarch64)
      CC="aarch64-linux-gnu-gcc"
      AR="aarch64-linux-gnu-ar"
      RANLIB="aarch64-linux-gnu-ranlib"
      ;;
    arm)
      CC="arm-linux-gnueabihf-gcc"
      AR="arm-linux-gnueabihf-ar"
      RANLIB="arm-linux-gnueabihf-ranlib"
      ;;
    ppc64le)
      CC="powerpc64le-linux-gnu-gcc"
      AR="powerpc64le-linux-gnu-ar"
      RANLIB="powerpc64le-linux-gnu-ranlib"
      ;;
    riscv64)
      CC="riscv64-linux-gnu-gcc"
      AR="riscv64-linux-gnu-ar"
      RANLIB="riscv64-linux-gnu-ranlib"
      ;;
    *)
      echo "Unsupported arch: $ARCH"
      exit 1
      ;;
  esac

  cd "$SRC_DIR"
  make distclean || true
  CC="$CC" AR="$AR" RANLIB="$RANLIB" ./Configure $TARGET no-shared no-tests no-module no-ui no-stdio no-dso \
      --prefix=$BUILD_DIR > /dev/null 2>&1  || exit 1
  make -j$(nproc) > /dev/null 2>&1 || exit 1
  make install_sw > /dev/null 2>&1 || exit 1
done

echo "✅ All OpenSSL builds complete. Output: $BUILD_ROOT"
