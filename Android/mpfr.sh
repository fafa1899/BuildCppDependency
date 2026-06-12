#!/bin/bash
set -e

# ============================================================
# 基本路径
# ============================================================

SOURCE_DIR=/home/charlee/work/Github/BuildCppDependency/Source
MPFR_VERSION=mpfr-4.2.2
MPFR_TAR=${MPFR_VERSION}.tar.xz

NDK=/home/charlee/work/android-ndk-r23b
API=29

TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64

# GMP 安装路径（必须是 Android arm64-v8a 版）
GMP_INSTALL=/home/charlee/work/Github/AndroidNativeKit/ndk23/arm64-v8a

# MPFR 安装路径
PREFIX=/home/charlee/work/Github/AndroidNativeKit/ndk23/arm64-v8a

# ============================================================
# Release 编译 / 链接参数
# ============================================================

# MPFR 当前作为静态库构建，沿用和 GMP 一致的轻量化策略。
export CFLAGS="-DNDEBUG -Oz -fdata-sections -ffunction-sections"
export CXXFLAGS="-DNDEBUG -Oz -fdata-sections -ffunction-sections"

# Android 链接优化（即使当前输出主要是静态库，也保持策略一致）
export LDFLAGS="-Wl,-z,max-page-size=16384,-z,common-page-size=16384,--pack-dyn-relocs=android+relr,--use-android-relr-tags,--gc-sections"

# 让 MPFR 正确找到 GMP
export CPPFLAGS="-I${GMP_INSTALL}/include"
export LDFLAGS="$LDFLAGS -L${GMP_INSTALL}/lib"

# ============================================================
# 解压源码
# ============================================================

cd "$SOURCE_DIR"

if [ ! -d "$MPFR_VERSION" ]; then
    echo "[MPFR] extracting source..."
    tar -xf "$MPFR_TAR"
fi

cd "$MPFR_VERSION"

# ============================================================
# 构建 arm64-v8a
# ============================================================

echo "[MPFR] start build for arm64-v8a..."

ARCH=arm64-v8a
TARGET_HOST=aarch64-linux-android

# 工具链
export CC=$TOOLCHAIN/bin/${TARGET_HOST}${API}-clang
export CXX=$TOOLCHAIN/bin/${TARGET_HOST}${API}-clang++
export AR=$TOOLCHAIN/bin/llvm-ar
export LD=$TOOLCHAIN/bin/ld
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip

# ============================================================
# configure 参数
# ============================================================

CONFIG_FLAGS="
--host=$TARGET_HOST
--prefix=$PREFIX
--with-gmp=$GMP_INSTALL
--enable-thread-safe
--disable-shared
--enable-static
"

# 清理
make distclean || true

# 配置
echo "[MPFR] running configure..."
./configure $CONFIG_FLAGS

# 编译
echo "[MPFR] building..."
make -j$(nproc)

# 安装
echo "[MPFR] installing..."
make install

# MPFR 当前输出为静态库，strip 收益有限，按需保留
$STRIP --strip-all $PREFIX/lib/libmpfr.a || true

# 输出结果确认
ls -lh "$PREFIX/lib" | grep mpfr || true

echo "[MPFR] build finished for arm64-v8a"
