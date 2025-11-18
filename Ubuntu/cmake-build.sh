#!/bin/bash

# 获取传入的参数
SourceLocalPath="$1"
BuildDir="$2"
Generator="$3"
InstallDir="$4"
CMakeArgs="$5"
ParallelBuild="${6:-true}"  # 默认为 "true"

# 校验 ParallelBuild 的值
case "$ParallelBuild" in
    ""|true)
        use_parallel=1
        ;;
    false)
        use_parallel=0
        ;;
    *)
        echo "错误：ParallelBuild 参数非法（只允许空、true 或 false）: '$ParallelBuild'" >&2
        exit 1
        ;;
esac

# 检查构建目录是否存在
if [ -d "$BuildDir" ]; then
    rm -rf "$BuildDir"
fi
mkdir -p "$BuildDir"

# 配置 CMake
#cmake "$SourceLocalPath" \
#    -B"$BuildDir" \
#    -G"$Generator" \
#    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
#    -DCMAKE_PREFIX_PATH="$InstallDir" \
#    -DCMAKE_INSTALL_PREFIX="$InstallDir" \
#    $CMakeArgs
# 构建命令字符串（注意：CMakeArgs 已含双引号）
CMAKE_CMD="cmake \"$SourceLocalPath\" -B\"$BuildDir\" -G\"$Generator\" -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_PREFIX_PATH=\"$InstallDir\" -DCMAKE_INSTALL_PREFIX=\"$InstallDir\" $CMakeArgs"
echo "Running: $CMAKE_CMD"
eval "$CMAKE_CMD"

# 构建阶段
if [ "$use_parallel" = 1 ]; then
    cmake --build "$BuildDir" --config RelWithDebInfo --parallel
else
    cmake --build "$BuildDir" --config RelWithDebInfo
fi

# 安装阶段
cmake --build "$BuildDir" --config RelWithDebInfo --target install