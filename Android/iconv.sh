#!/bin/bash

cd /home/charlee/work/Github/BuildCppDependency/Source/

tar -zxvf libiconv-1.19.tar.gz
cd libiconv-1.19

export NDK=/home/charlee/work/android-ndk-r23b/
# ====================================================================

# Android 最低 API 版本（兼容绝大多数设备）
export API=21

# NDK 工具链（Linux 版本，固定写法）
export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64

# ========== 【关键：添加 16KB 页大小链接器参数】 ==========
export LDFLAGS="-Wl,-z,max-page-size=16384,-z,common-page-size=16384"

# ========== Release 版本编译标记（正式上线必备）==========
export CFLAGS="-DNDEBUG -fvisibility=hidden -Os"
export CXXFLAGS="-DNDEBUG -fvisibility=hidden -Os"

# ========== 1. 编译 arm64-v8a（现代手机默认架构，最重要）==========
ARCH=arm64-v8a
TARGET_HOST=aarch64-linux-android
PREFIX=/home/charlee/work/Github/AndroidNativeKit/ndk23/arm64-v8a/

export CC=$TOOLCHAIN/bin/$TARGET_HOST$API-clang
export CXX=$TOOLCHAIN/bin/$TARGET_HOST$API-clang++
export AR=$TOOLCHAIN/bin/llvm-ar
export LD=$TOOLCHAIN/bin/ld
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip

make clean
./configure \
    --host=$TARGET_HOST \
    --prefix=$PREFIX \
    --enable-static \
    --enable-shared \
    --disable-rpath

make -j$(nproc)
make install

# Release 必备：剥离符号（更小、更安全、正式上线版）
$STRIP $PREFIX/lib/libiconv.so
$STRIP $PREFIX/lib/libcharset.so

echo "✅ libiconv Release 版构建完成！"