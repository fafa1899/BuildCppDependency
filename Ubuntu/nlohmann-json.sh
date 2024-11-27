#!/bin/bash

# 加载环境变量文件
source /etc/environment

# 定义变量
SourceLocalPath="../Source/json-3.11.3"
BuildDir="./json-3.11.3"
Generator="Unix Makefiles"
InstallDir=$GISBasic
CMakeArgs="-DJSON_BuildTests=OFF"

# 调用 build.sh 脚本
chmod +x ./cmake-build.sh
./cmake-build.sh "$SourceLocalPath" "$BuildDir" "$Generator" "$InstallDir" "$CMakeArgs"
