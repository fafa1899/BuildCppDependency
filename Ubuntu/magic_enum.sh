#!/bin/bash

# 加载环境变量文件
source /etc/environment

# 解压缩
unzip -q -o "../Source/magic_enum-0.9.7.zip" -d "../Source"

# 定义变量
SourceLocalPath="../Source/magic_enum-0.9.7"
BuildDir="./magic_enum-0.9.7"
Generator="Unix Makefiles"
InstallDir=$GISBasic
CMakeArgs="-DMAGIC_ENUM_OPT_BUILD_EXAMPLES=OFF -DMAGIC_ENUM_OPT_BUILD_TESTS=OFF"

# 调用 build.sh 脚本
chmod +x ./cmake-build.sh
./cmake-build.sh "$SourceLocalPath" "$BuildDir" "$Generator" "$InstallDir" "$CMakeArgs"
