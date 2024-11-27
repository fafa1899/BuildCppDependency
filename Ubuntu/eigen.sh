#!/bin/bash

# 加载环境变量文件
source /etc/environment

# 解压缩
unzip -q -o "../Source/eigen-3.4.0.zip" -d "../Source"

# 定义变量
SourceLocalPath="../Source/eigen-3.4.0"
BuildDir="./eigen-3.4.0"
Generator="Unix Makefiles"
InstallDir=$GISBasic
CMakeArgs="-DBUILD_TESTING=OFF"

# 调用 build.sh 脚本
chmod +x ./cmake-build.sh
./cmake-build.sh "$SourceLocalPath" "$BuildDir" "$Generator" "$InstallDir" "$CMakeArgs"
