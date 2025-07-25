#!/bin/bash
set -e

# sudo apt install gcc-x86-64-linux-gnu gcc-i686-linux-gnu gcc-arm-linux-gnueabihf gcc-powerpc64le-linux-gnu gcc-riscv64-linux-gnu gcc-aarch64-linux-gnu

#ARCHS=("x86_64" "aarch64" "arm" "ppc64le" "riscv64")
ARCHS=("x86_64" "aarch64")

BUILD_ROOT="$(pwd)/zlib-linux-build"
SRC_DIR="$(pwd)/zlib"

for ARCH in "${ARCHS[@]}"; do
  echo "▶️ Building zlib for $ARCH"

  BUILD_DIR="$BUILD_ROOT/$ARCH"

  cd "$SRC_DIR"
  make distclean || true

  case "$ARCH" in
    x86_64)
      CC="x86_64-linux-gnu-gcc"
      ;;
    aarch64)
      CC="aarch64-linux-gnu-gcc"
      ;;
    arm)
      CC="arm-linux-gnueabihf-gcc"
      ;;
    ppc64le)
      CC="powerpc64le-linux-gnu-gcc"
      ;;
    riscv64)
      CC="riscv64-linux-gnu-gcc"
      ;;
    *)
      echo "Unsupported arch: $ARCH"
      exit 1
      ;;
  esac

  CC="$CC" CFLAGS="-fPIC" ./configure --prefix="$BUILD_DIR" --static
  make -j$(nproc)
  make install
done

echo "✅ All zlib builds complete. Output: $BUILD_ROOT"
