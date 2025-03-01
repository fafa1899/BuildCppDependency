@echo off
REM 区域设置
set LC_ALL=C
set LANG=C

REM 配置 Visual Studio 版本
SET VS_VERSION=2019
SET VS_EDITION=Enterprise

REM 配置架构（x64 或 x86）
SET TARGET_ARCH=x64

REM 设置 OpenSSL 源码目录和目标目录
SET OPENSSL_SRC_DIR=../Source/openssl-openssl-3.4.0
SET OPENSSL_INSTALL_DIR=%GISBasic%

REM 启动 Visual Studio 的开发者命令行环境
CALL "C:\Program Files (x86)\Microsoft Visual Studio\%VS_VERSION%\%VS_EDITION%\VC\Auxiliary\Build\vcvarsall.bat" %TARGET_ARCH%

IF ERRORLEVEL 1 (
    echo Failed to configure Visual Studio environment.
    EXIT /B 1
)

REM 进入 OpenSSL 源码目录
CD /D %OPENSSL_SRC_DIR%

REM 配置 OpenSSL
perl Configure VC-WIN64A --prefix=%OPENSSL_INSTALL_DIR% --release
IF ERRORLEVEL 1 (
    echo Configuration failed.
    EXIT /B 1
)

REM 构建 OpenSSL
nmake
IF ERRORLEVEL 1 (
    echo Build failed.
    EXIT /B 1
)

REM 测试构建
REM nmake test
REM IF ERRORLEVEL 1 (
REM    echo Tests failed.
REM    EXIT /B 1
REM )

REM 安装到目标目录
nmake install
IF ERRORLEVEL 1 (
    echo Installation failed.
    EXIT /B 1
)

echo Build and installation successful!
EXIT /B 0