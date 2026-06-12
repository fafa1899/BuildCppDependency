#!/bin/bash
set -e

# ============================================================
# 基本路径
# ============================================================

SOURCE_DIR=/home/charlee/work/Github/BuildCppDependency/Source
GMP_VERSION=gmp-6.3.0
GMP_TAR=${GMP_VERSION}.tar.xz

NDK=/home/charlee/work/android-ndk-r23b
API=29

TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64

# ============================================================
# Release 编译 / 链接参数
# ============================================================

# GMP 这里仍然作为静态库构建，因此不需要像 .so 那样强调符号导出控制，
# 但依然统一体积优化策略。
export CFLAGS="-DNDEBUG -Oz -fdata-sections -ffunction-sections"
export CXXFLAGS="-DNDEBUG -Oz -fdata-sections -ffunction-sections"

# 即便当前主要输出静态库，也尽量保持 Android 链接参数一致，
# 便于后续若开启 shared 或测试工具链接时沿用同一套策略。
export LDFLAGS="-Wl,-z,max-page-size=16384,-z,common-page-size=16384,--pack-dyn-relocs=android+relr,--use-android-relr-tags,--gc-sections"

# ============================================================
# 解压源码
# ============================================================

cd "$SOURCE_DIR"

if [ ! -d "$GMP_VERSION" ]; then
    echo "[GMP] extracting source..."
    tar -xf "$GMP_TAR"
fi

cd "$GMP_VERSION"

# ============================================================
# 构建 arm64-v8a
# ============================================================

echo "[GMP] start build for arm64-v8a..."

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

# GMP 特殊：关闭汇编优化，避免 Android / 架构检测导致的不稳定问题
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
echo "[GMP] running configure..."
./configure $CONFIG_FLAGS

# 编译
echo "[GMP] building..."
make -j$(nproc)

# 安装
echo "[GMP] installing..."
make install

# GMP 当前输出为静态库，strip 对 .a 收益有限，先保留注释
# $STRIP --strip-all $PREFIX/lib/libgmp.a || true

# 输出结果确认
ls -lh "$PREFIX/lib" | grep gmp || true

echo "[GMP] build finished for arm64-v8a"
