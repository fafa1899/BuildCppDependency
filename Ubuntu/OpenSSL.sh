#!/bin/bash

BuildDir="./openssl-openssl-3.4.0"
InstallDir=$GISBasic

# 加载环境变量文件
source /etc/environment

# 解压缩
unzip -q -o "../Source/openssl-openssl-3.4.0.zip" -d "../Source"

# 检查构建目录是否存在
if [ -d "$BuildDir" ]; then
    rm -rf "$BuildDir" # 目录存在，删除它
fi
# 创建构建目录
mkdir -p "$BuildDir"

cd "../Source/openssl-openssl-3.4.0"

./Configure --openssldir=$BuildDir --prefix=$InstallDir --release

make

make install

