#!/bin/bash

# 加载环境变量文件
source /etc/environment

# 定义变量
SourceLocalPath="../Source/boost-1.86.0"
BuildDir="./boost-1.86.0"
Generator="Unix Makefiles"
InstallDir=$GISBasic
CMakeArgs="-DBUILD_SHARED_LIBS=ON"

# 调用 build.sh 脚本
chmod +x ./cmake-build.sh
./cmake-build.sh "$SourceLocalPath" "$BuildDir" "$Generator" "$InstallDir" "$CMakeArgs"
