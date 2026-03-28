#!/bin/bash

export NDK=/home/charlee/work/android-ndk-r23b/
export API=21
export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64

SOURCE_DIR=/home/charlee/work/Github/BuildCppDependency/Source/
UTIL_LINUX_SRC=util-linux-2.41.3
PREFIX=/home/charlee/work/Github/AndroidNativeKit/ndk23/arm64-v8a/

ARCH=arm64-v8a
TARGET_HOST=aarch64-linux-android

export CFLAGS="-DNDEBUG -fvisibility=hidden"
export LDFLAGS="-Wl,-z,max-page-size=16384,-z,common-page-size=16384"

export CC=$TOOLCHAIN/bin/$TARGET_HOST$API-clang
export CXX=$TOOLCHAIN/bin/$TARGET_HOST$API-clang++
export AR=$TOOLCHAIN/bin/llvm-ar
export LD=$TOOLCHAIN/bin/ld
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip

cd $SOURCE_DIR

if [ ! -d $UTIL_LINUX_SRC ]; then
    tar -zxvf util-linux-2.41.3.tar.gz
fi

cd $UTIL_LINUX_SRC

# 生成 configure（必需！）
./autogen.sh

# 只编译 libuuid，最小化构建
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

# 编译 + 官方 Release 安装（自动剥离符号）
make -j$(nproc)
make install-strip

echo -e "\n✅ 构建成功！仅 libuuid，纯 Release 版！"