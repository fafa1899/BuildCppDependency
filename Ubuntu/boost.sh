#!/bin/bash

# 后期考虑用分卷压缩包解压

# 加载环境变量文件
source /etc/environment

InstallDir=""

# 解析参数
while [[ $# -gt 0 ]]; do
  case $1 in
    -installdir)
      InstallDir="$2"
      shift 2
      ;;
    -*)
      echo "未知参数: $1"
      exit 1
      ;;
    *)
      echo "无效参数: $1"
      exit 1
      ;;
  esac
done

# 定义变量
SourcePath="../Source/boost-1.86.0"
BuildDir="./boost-1.86.0"
Generator="Unix Makefiles"
CMakeArgs="-DBUILD_SHARED_LIBS=ON"

# 调用 build.sh 脚本
chmod +x ./cmake-build.sh
./cmake-build.sh "$SourcePath" "$BuildDir" "$Generator" "$InstallDir" "$CMakeArgs"

rm -rf "$BuildDir" && echo "已删除构建目录: $BuildDir"
