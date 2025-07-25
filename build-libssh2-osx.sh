#!/bin/bash

set -e

LIBSSH2_DIR="libssh2"
BUILD_DIR="$(pwd)/libssh2-osx-build"
ZLIB_ROOT="$(pwd)/zlib-osx-build"
OPENSSL_ROOT="$(pwd)/openssl-osx-build"

ARCHS=("x86_64" "arm64")


for ARCH in "${ARCHS[@]}"; do
  echo "▶️ Building for $ARCH"


  BUILD_ARCH_DIR=$BUILD_DIR/$ARCH
  echo $BUILD_ARCH_DIR
  rm -rf $BUILD_ARCH_DIR
  mkdir -p $BUILD_ARCH_DIR
  pushd $BUILD_ARCH_DIR

  cmake ../../$LIBSSH2_DIR \
    -DCMAKE_OSX_ARCHITECTURES=$ARCH \
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

  make -j$(sysctl -n hw.ncpu)
  make install
  popd

done

echo "✅ All libssh2 builds complete. Output: $BUILD_DIR"
