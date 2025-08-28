#!/bin/bash

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
SourcePath="../Source/sqlite-3.4.6"
BuildDir="./sqlite-3.4.6"
Generator="Unix Makefiles"
CMakeArgs=""

# 调用 build.sh 脚本
chmod +x ./cmake-build.sh
./cmake-build.sh "$SourcePath" "$BuildDir" "$Generator" "$InstallDir" "$CMakeArgs"

rm -rf "$BuildDir" && echo "已删除构建目录: $BuildDir"
