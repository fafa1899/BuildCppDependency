#!/bin/bash

set -e

cd /home/charlee/work/Github/BuildCppDependency/Source/

tar -zxvf libiconv-1.19.tar.gz
cd libiconv-1.19

export NDK=/home/charlee/work/android-ndk-r23b/
# ====================================================================

# Android 目标 API 等级
export API=29

# NDK 工具链（Linux 版本）
export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64

# Android 链接优化：
# 1. 16KB page size 对齐
# 2. 压缩动态重定位，降低 RELRO / 装载压力
# 3. 回收无用 section，减小 so 体积
export LDFLAGS="-Wl,-z,max-page-size=16384,-z,common-page-size=16384,--pack-dyn-relocs=android+relr,--use-android-relr-tags,--gc-sections"

# Release 编译优化：
# 1. -Oz 优先缩小体积
# 2. section 粒度优化，配合 --gc-sections
# 3. hidden 可见性减少导出符号
export CFLAGS="-DNDEBUG -Oz -fdata-sections -ffunction-sections -fvisibility=hidden"
export CXXFLAGS="-DNDEBUG -Oz -fdata-sections -ffunction-sections -fvisibility=hidden -fvisibility-inlines-hidden"

# arm64-v8a
ARCH=arm64-v8a
TARGET_HOST=aarch64-linux-android
PREFIX=/home/charlee/work/Github/AndroidNativeKit/ndk23/arm64-v8a/

export CC=$TOOLCHAIN/bin/$TARGET_HOST$API-clang
export CXX=$TOOLCHAIN/bin/$TARGET_HOST$API-clang++
export AR=$TOOLCHAIN/bin/llvm-ar
export LD=$TOOLCHAIN/bin/ld
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip

make clean || true
./configure \
    --host=$TARGET_HOST \
    --prefix=$PREFIX \
    --enable-static \
    --enable-shared \
    --disable-rpath

make -j$(nproc)
make install

# Release 构建后剥离符号，进一步减小体积
$STRIP --strip-all $PREFIX/lib/libiconv.so
$STRIP --strip-all $PREFIX/lib/libcharset.so

echo "✓ libiconv Android Release 构建完成"
