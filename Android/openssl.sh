#!/bin/bash

set -e

InstallDir="/home/charlee/work/Github/AndroidNativeKit/ndk23/arm64-v8a/"
SourceDir="/home/charlee/work/Github/BuildCppDependency/Source/openssl-openssl-3.4.0"

export ANDROID_NDK_ROOT=/home/charlee/work/android-ndk-r23b/
export PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH

cd "$SourceDir"

# 先清理旧构建
make clean || true

# 静态库构建：
# - no-shared: 不生成 libcrypto.so / libssl.so
# - no-module: 避免额外动态模块
# - no-tests / no-unit-test: 精简
./Configure android-arm64 -D__ANDROID_API__=29 --prefix="$InstallDir" no-shared no-module no-tests no-unit-test

# 修正 C / C++ Release 编译参数
sed -i 's/^CFLAGS=.*/CFLAGS=-Wall -DNDEBUG -Oz -fdata-sections -ffunction-sections/' Makefile
sed -i 's/^CXXFLAGS=.*/CXXFLAGS=-Wall -DNDEBUG -Oz -fdata-sections -ffunction-sections/' Makefile

# 对静态库来说，LDFLAGS 基本不关键，但保留不会有太大问题
sed -i 's|^LDFLAGS=.*|LDFLAGS= -Wl,-z,max-page-size=16384 -Wl,-z,common-page-size=16384 -Wl,--gc-sections|' Makefile

echo "===== Patched Makefile summary ====="
grep '^CC=' Makefile || true
grep '^CPPFLAGS=' Makefile || true
grep '^CFLAGS=' Makefile || true
grep '^CXXFLAGS=' Makefile || true
grep '^LDFLAGS=' Makefile || true
echo "===================================="

make -j$(nproc)
make install

echo "===== Installed OpenSSL static libs ====="
ls -l "$InstallDir/lib/libcrypto.a" || true
ls -l "$InstallDir/lib/libssl.a" || true
echo "========================================="

echo "✅ OpenSSL Android static build finished"