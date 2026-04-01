#!/bin/bash
set -e

# ============================================================
# 基本路径
# ============================================================

SOURCE_DIR=/home/charlee/work/Github/BuildCppDependency/Source
MPFR_VERSION=mpfr-4.2.2
MPFR_TAR=${MPFR_VERSION}.tar.xz

NDK=/home/charlee/work/android-ndk-r23b
API=21

TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64

# GMP 安装路径（⚠️ 必须是你刚刚编译的 Android GMP）
GMP_INSTALL=/home/charlee/work/Github/AndroidNativeKit/ndk23/arm64-v8a

# MPFR 安装路径
PREFIX=/home/charlee/work/Github/AndroidNativeKit/ndk23/arm64-v8a

# ============================================================
# 编译参数（Release）
# ============================================================

export CFLAGS="-DNDEBUG -fvisibility=hidden -Os"
export CXXFLAGS="-DNDEBUG -fvisibility=hidden -Os"

# Android 16KB page size
export LDFLAGS="-Wl,-z,max-page-size=16384,-z,common-page-size=16384"

# ������ 关键：让 MPFR 找到 GMP
export CPPFLAGS="-I${GMP_INSTALL}/include"
export LDFLAGS="$LDFLAGS -L${GMP_INSTALL}/lib"

# ============================================================
# 解压源码
# ============================================================

cd $SOURCE_DIR

if [ ! -d "$MPFR_VERSION" ]; then
    echo "������ 解压 MPFR..."
    tar -xf $MPFR_TAR
fi

cd $MPFR_VERSION

# ============================================================
# 构建 arm64-v8a
# ============================================================

echo "������ 开始构建 MPFR (arm64-v8a)..."

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
echo "⚙️ 运行 configure..."
./configure $CONFIG_FLAGS

# 编译
echo "������ 编译中..."
make -j$(nproc)

# 安装
echo "������ 安装中..."
make install

# strip（可选）
$STRIP $PREFIX/lib/libmpfr.a || true

echo "✅ MPFR (arm64-v8a) 构建完成！"