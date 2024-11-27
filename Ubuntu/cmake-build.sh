#!/bin/bash

# 获取传入的参数
SourceLocalPath="$1"
BuildDir="$2"
Generator="$3"
InstallDir="$4"
CMakeArgs="$5"

# 检查构建目录是否存在
if [ -d "$BuildDir" ]; then
    rm -rf "$BuildDir" # 目录存在，删除它
fi
# 创建构建目录
mkdir -p "$BuildDir"

# 配置CMake
cmake "$SourceLocalPath" \
    -B"$BuildDir" \
    -G"$Generator" \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_PREFIX_PATH="$InstallDir" \
    -DCMAKE_INSTALL_PREFIX="$InstallDir" \
    $CMakeArgs

# 构建阶段，指定构建类型
cmake --build "$BuildDir" --config RelWithDebInfo --parallel 4

# 安装阶段，指定构建类型和安装目标
cmake --build "$BuildDir" --config RelWithDebInfo --target install
