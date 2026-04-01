#!/bin/bash
set -e

# ============================================================
# 基本路径
# ============================================================

SOURCE_DIR=/home/charlee/work/Github/BuildCppDependency/Source
GMP_VERSION=gmp-6.3.0
GMP_TAR=${GMP_VERSION}.tar.xz

NDK=/home/charlee/work/android-ndk-r23b
API=21

TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64

# ============================================================
# 编译参数（Release）
# ============================================================

export CFLAGS="-DNDEBUG -fvisibility=hidden -Os"
export CXXFLAGS="-DNDEBUG -fvisibility=hidden -Os"

# 16KB page size（Android 13+ 必须）
export LDFLAGS="-Wl,-z,max-page-size=16384,-z,common-page-size=16384"

# ============================================================
# 解压源码
# ============================================================

cd $SOURCE_DIR

if [ ! -d "$GMP_VERSION" ]; then
    echo "������ 解压 GMP..."
    tar -xf $GMP_TAR
fi

cd $GMP_VERSION

# ============================================================
# 构建 arm64-v8a
# ============================================================

echo "������ 开始构建 GMP (arm64-v8a)..."

ARCH=arm64-v8a
TARGET_HOST=aarch64-linux-android
PREFIX=/home/charlee/work/Github/AndroidNativeKit/ndk23/$ARCH

# 工具链
export CC=$TOOLCHAIN/bin/${TARGET_HOST}${API}-clang
export CXX=$TOOLCHAIN/bin/${TARGET_HOST}${API}-clang++
export AR=$TOOLCHAIN/bin/llvm-ar
export LD=$TOOLCHAIN/bin/ld
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip

# GMP 特殊：关闭汇编优化（避免架构检测问题）
CONFIG_FLAGS="
--host=$TARGET_HOST
--prefix=$PREFIX
--enable-cxx
--disable-shared
--enable-static
--disable-assembly
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
#$STRIP $PREFIX/lib/libgmp.a || true

echo "✅ GMP (arm64-v8a) 构建完成！"