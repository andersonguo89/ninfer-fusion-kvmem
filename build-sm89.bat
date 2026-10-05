@echo off
REM sm_89 build for the fusion-kvmem engine (feat/anti-loop patches)
REM FFMPEG: fake vcpkg triplet from the v1.0.8 vendored SDK
REM CURL:   curl 8.22.0 headers (GitHub) + import lib generated from the shipped libcurl-x64.dll
cd /d C:\ninfer-ada\fusion-kvmem\src-tree\fusion-engine-src
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
if errorlevel 1 exit /b 90
set PATH=C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja;%PATH%
set VCPKG_ROOT=C:\ninfer-ada\ffmpeg-vcpkg-fake
set VCPKG_TARGET_TRIPLET=x64-windows
REM (incremental: keep build-sm89)
cmake -S . -B build-sm89 -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_CUDA_ARCHITECTURES=89 -DNINFER_ENABLE_AVX2=ON -DCMAKE_CUDA_FLAGS="-allow-unsupported-compiler -Xcompiler=/Zc:__cplusplus" -DCURL_ROOT=C:\ninfer-ada\curl-sdk > configure_sm89.log 2>&1
if errorlevel 1 (echo CONFIGURE_FAIL & type configure_sm89.log & exit /b 91)
cmake --build build-sm89 --parallel 2 > build_sm89.log 2>&1
echo BUILD_EXIT=%ERRORLEVEL%
exit /b %ERRORLEVEL%
