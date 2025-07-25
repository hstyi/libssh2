@echo off
setlocal enabledelayedexpansion

set LIBSSH2_SRC=%cd%\libssh2
set BUILD_ROOT=%cd%\libssh2-windows-build
set VS_VCVARS="C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat"
set ZLIB_ROOT=%cd%\zlib-windows-build
set OPENSSL_ROOT=%cd%\openssl-windows-build
set CL=/MP

for %%A in (%ARCHS%) do (
    echo Building libssh2 for %%A ...
    call %VS_VCVARS% %%A

    set BUILD_DIR=!BUILD_ROOT!\%%A\build
    if not exist !BUILD_DIR! mkdir !BUILD_DIR!
    cd /d !BUILD_DIR!

    :: Configure
    cmake !LIBSSH2_SRC! -G "NMake Makefiles" ^
        -DBUILD_SHARED_LIBS=ON ^
        -DBUILD_STATIC_LIBS=OFF ^
        -DENABLE_ZLIB_COMPRESSION=ON ^
        -DCRYPTO_BACKEND=OpenSSL ^
        -DENABLE_DEBUG_LOGGING=ON ^
        -DOPENSSL_ROOT_DIR=!OPENSSL_ROOT!\%%A ^
        -DOPENSSL_LIBRARIES="!OPENSSL_ROOT!\%%A\lib\libssl.lib;!OPENSSL_ROOT!\%%A\lib\libcrypto.lib" ^
        -DOPENSSL_INCLUDE_DIR=!OPENSSL_ROOT!\%%A\include ^
        -DZLIB_LIBRARY=!ZLIB_ROOT!\%%A\zlib.lib ^
        -DZLIB_INCLUDE_DIR=!ZLIB_ROOT!\%%A\include ^
        -DCMAKE_INSTALL_PREFIX=!BUILD_ROOT!\%%A

	nmake
	nmake install

	copy !BUILD_ROOT!\%%A\bin\*.dll !BUILD_ROOT!\%%A\lib\

    echo Finished building %%A
)

echo All builds done. Output directory: %BUILD_ROOT%
