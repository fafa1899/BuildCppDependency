#!/bin/bash

InstallDir="/home/charlee/work/Github/AndroidNativeKit/ndk23/arm64-v8a/"
SourceDir="/home/charlee/work/Github/BuildCppDependency/Source/openssl-openssl-3.4.0"

export ANDROID_NDK_ROOT=/home/charlee/work/android-ndk-r23b/
PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH

cd $SourceDir

# 1. 运行配置（生成的 Makefile 此时还没有 16KB 参数）
./Configure android-arm64 -D__ANDROID_API__=21 --prefix=$InstallDir

# 2. 【关键】立刻修改生成的 Makefile
# 这条命令的意思是：找到 LDFLAGS= 开头的行，把整行内容(&)替换为 "原内容 + 参数"
sed -i 's/^LDFLAGS=.*/& -Wl,-z,max-page-size=16384/' Makefile

# 3. 编译
make clean
make
make install