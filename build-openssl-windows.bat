@echo off
setlocal enabledelayedexpansion

set OPENSSL_SRC=%cd%\openssl
set BUILD_ROOT=%cd%\openssl-windows-build
set OPENSSL_CERT_DIR=%cd%\openssl-windows-build
set VS_VCVARS="C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat"
set CL=/MP

for %%A in (%ARCHS%) do (
    echo Building openssl for %%A ...

    call %VS_VCVARS% %%A

	cd !OPENSSL_SRC!

	if "%%A"=="x86" (
		set TARGET=VC-WIN32
	) else if "%%A"=="x64" (
		set TARGET=VC-WIN64A
	) else if "%%A"=="arm64" (
		set TARGET=VC-WIN64-ARM
	)

	echo !TARGET!

    perl Configure !TARGET! no-shared no-tests no-module no-ui no-stdio no-dso --prefix=!BUILD_ROOT!\%%A --openssldir=!BUILD_ROOT!\%%A\cert

	nmake
	nmake install

    echo Finished building %%A
)

echo All builds done. Output directory: %BUILD_ROOT%

