#!/bin/bash

set -e

InstallDir="/home/charlee/work/Github/AndroidNativeKit/ndk23/arm64-v8a/"
SourceDir="/home/charlee/work/Github/BuildCppDependency/Source/openssl-openssl-3.4.0"

export ANDROID_NDK_ROOT=/home/charlee/work/android-ndk-r23b/
export PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH

cd "$SourceDir"

# 先清理旧构建
make clean || true

# 1. 配置，先尽量把 API 指定成 29
./Configure android-arm64 -D__ANDROID_API__=29 --prefix="$InstallDir" shared no-tests no-unit-test

# 2. 关键：直接修正生成后的 Makefile，确保最终构建参数真正生效

# 修正 C / C++ Release 编译参数
sed -i 's/^CFLAGS=.*/CFLAGS=-Wall -DNDEBUG -Oz -fdata-sections -ffunction-sections/' Makefile
sed -i 's/^CXXFLAGS=.*/CXXFLAGS=-Wall -DNDEBUG -Oz -fdata-sections -ffunction-sections/' Makefile

# 修正链接参数：16KB page size + gc-sections
sed -i 's|^LDFLAGS=.*|LDFLAGS= -Wl,-z,max-page-size=16384 -Wl,-z,common-page-size=16384 -Wl,--gc-sections|' Makefile

# 如需更激进，也可以改成下面这版（先注释保留，按需开启）
# sed -i 's|^LDFLAGS=.*|LDFLAGS= -Wl,-z,max-page-size=16384 -Wl,-z,common-page-size=16384 -Wl,--pack-dyn-relocs=android+relr -Wl,--use-android-relr-tags -Wl,--gc-sections|' Makefile

echo "===== Patched Makefile summary ====="
grep '^CC=' Makefile || true
grep '^CPPFLAGS=' Makefile || true
grep '^CFLAGS=' Makefile || true
grep '^CXXFLAGS=' Makefile || true
grep '^LDFLAGS=' Makefile || true
echo "===================================="

# 3. 构建与安装
make -j$(nproc)
make install

# 4. 剥离符号，进一步减小体积
$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip --strip-all "$InstallDir/lib/libcrypto.so" || true
$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip --strip-all "$InstallDir/lib/libssl.so" || true

echo "✓ OpenSSL Android Release 构建完成"
