#!/bin/bash

set -e

export NDK=/home/charlee/work/android-ndk-r23b/
export API=29
export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64

SOURCE_DIR=/home/charlee/work/Github/BuildCppDependency/Source/
UTIL_LINUX_SRC=util-linux-2.41.3
PREFIX=/home/charlee/work/Github/AndroidNativeKit/ndk23/arm64-v8a/

ARCH=arm64-v8a
TARGET_HOST=aarch64-linux-android

# Release 编译优化：沿用当前 Android 基础依赖统一策略
export CFLAGS="-DNDEBUG -Oz -fdata-sections -ffunction-sections"
export CXXFLAGS="-DNDEBUG -Oz -fdata-sections -ffunction-sections"

# Android 链接优化：16KB page size + relr + gc-sections
export LDFLAGS="-Wl,-z,max-page-size=16384,-z,common-page-size=16384,--pack-dyn-relocs=android+relr,--use-android-relr-tags,--gc-sections"

export CC=$TOOLCHAIN/bin/$TARGET_HOST$API-clang
export CXX=$TOOLCHAIN/bin/$TARGET_HOST$API-clang++
export AR=$TOOLCHAIN/bin/llvm-ar
export LD=$TOOLCHAIN/bin/ld
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip

cd "$SOURCE_DIR"

if [ ! -d "$UTIL_LINUX_SRC" ]; then
    echo "[util-linux] extracting source..."
    tar -zxvf util-linux-2.41.3.tar.gz
fi

cd "$UTIL_LINUX_SRC"

# 生成 configure（必须）
./autogen.sh

# 只构建 libuuid，保持最小化
./configure \
    --host=$TARGET_HOST \
    --prefix=$PREFIX \
    --enable-static \
    --enable-shared \
    --disable-rpath \
    --enable-libuuid \
    --disable-all-programs \
    --disable-nls \
    --disable-manpages \
    --disable-bash-completion \
    --disable-libblkid \
    --disable-libmount \
    --disable-libfdisk \
    --without-python \
    --without-systemd \
    --without-ncurses

# 编译 + 安装
make -j$(nproc)
make install-strip

# 输出结果确认
ls -lh "$PREFIX/lib" | grep uuid || true

echo -e "\n[util-linux] build success -> libuuid only, release profile"
