#!/bin/bash

# 加载环境变量文件
source /etc/environment

# 定义变量
SourceLocalPath="../Source/sqlite-3.4.6"
BuildDir="./sqlite-3.4.6"
Generator="Unix Makefiles"
InstallDir=$GISBasic
CMakeArgs=""

# 调用 build.sh 脚本
chmod +x ./cmake-build.sh
./cmake-build.sh "$SourceLocalPath" "$BuildDir" "$Generator" "$InstallDir" "$CMakeArgs"
