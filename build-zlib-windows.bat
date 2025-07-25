@echo off
setlocal enabledelayedexpansion

set ZLIB_SRC=%cd%\zlib
set BUILD_ROOT=%cd%\zlib-windows-build

set VS_VCVARS="C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat"

set ARCHS=arm64 x64 x86

for %%A in (%ARCHS%) do (
    echo Building zlib for %%A ...
    call %VS_VCVARS% %%A

    set BUILD_DIR=%BUILD_ROOT%\%%A
    if not exist "!BUILD_DIR!" mkdir "!BUILD_DIR!"

    cd %ZLIB_SRC%

    nmake -f win32\Makefile.msc DLL=0
	nmake install

    copy zlib.lib "!BUILD_DIR!\"
	xcopy /Y *.h "!BUILD_DIR!\include\"

    nmake -f win32\Makefile.msc clean

    echo Finished building %%A

)

echo All builds done. Output directory: %BUILD_ROOT%

