#!/bin/bash

set -e

LIBSSH2_DIR="libssh2"
BUILD_DIR="$(pwd)/libssh2-linux-build"
ZLIB_ROOT="$(pwd)/zlib-linux-build"
OPENSSL_ROOT="$(pwd)/openssl-linux-build"

#ARCHS=("x86_64" "aarch64" "arm" "ppc64le" "riscv64")
ARCHS=("x86_64" "aarch64")

for ARCH in "${ARCHS[@]}"; do
  echo "▶️ Building libssh2 for $ARCH"

  case "$ARCH" in
    x86_64)
      CC=$(which "x86_64-linux-gnu-gcc")
      AR=$(which "x86_64-linux-gnu-ar")
      RANLIB=$(which "x86_64-linux-gnu-ranlib")
      ;;
    aarch64)
      CC=$(which aarch64-linux-gnu-gcc)
      AR=$(which aarch64-linux-gnu-ar)
      RANLIB=$(which aarch64-linux-gnu-ranlib)
      ;;
    arm)
      CC=$(which "arm-linux-gnueabihf-gcc")
      AR=$(which "arm-linux-gnueabihf-ar")
      RANLIB=$(which "arm-linux-gnueabihf-ranlib")
      ;;
    ppc64le)
      CC=$(which "powerpc64le-linux-gnu-gcc")
      AR=$(which "powerpc64le-linux-gnu-ar")
      RANLIB=$(which "powerpc64le-linux-gnu-ranlib")
      ;;
    riscv64)
      CC=$(which "riscv64-linux-gnu-gcc")
      AR=$(which "riscv64-linux-gnu-ar")
      RANLIB=$(which "riscv64-linux-gnu-ranlib")
      ;;
    *)
      echo "Unsupported arch: $ARCH"
      exit 1
      ;;
  esac

  BUILD_ARCH_DIR=$BUILD_DIR/$ARCH
  echo $BUILD_ARCH_DIR
  rm -rf $BUILD_ARCH_DIR
  mkdir -p $BUILD_ARCH_DIR
  pushd $BUILD_ARCH_DIR

  OPENSSL_LIBDIR="$OPENSSL_ROOT/$ARCH/lib"
  if [ ! -f "$OPENSSL_LIBDIR/libssl.a" ]; then
    OPENSSL_LIBDIR="$OPENSSL_ROOT/$ARCH/lib64"
  fi

  ZLIB_LIBDIR="$ZLIB_ROOT/$ARCH/lib"
  if [ ! -f "$ZLIB_LIBDIR/libz.a" ]; then
    ZLIB_LIBDIR="$ZLIB_ROOT/$ARCH/lib64"
  fi


  cmake ../../$LIBSSH2_DIR \
    -DCMAKE_C_COMPILER=$CC \
    -DCMAKE_AR=$AR \
    -DCMAKE_RANLIB=$RANLIB \
    -DBUILD_SHARED_LIBS=ON \
    -DENABLE_ZLIB_COMPRESSION=ON \
    -DCRYPTO_BACKEND=OpenSSL \
    -DENABLE_DEBUG_LOGGING=ON \
    -DOPENSSL_ROOT_DIR=$OPENSSL_ROOT/$ARCH \
    -DOPENSSL_LIBRARIES="$OPENSSL_ROOT/$ARCH/lib/libssl.a;$OPENSSL_ROOT/$ARCH/lib/libcrypto.a" \
    -DOPENSSL_INCLUDE_DIR=$OPENSSL_ROOT/$ARCH/include \
    -DZLIB_LIBRARY=$ZLIB_ROOT/$ARCH/lib/libz.a \
    -DZLIB_INCLUDE_DIR=$ZLIB_ROOT/$ARCH/include \
    -DCMAKE_INSTALL_PREFIX=$BUILD_DIR/$ARCH/

  make -j$(nproc)
  make install
  popd

done

echo "✅ All libssh2 builds complete. Output: $BUILD_DIR"
