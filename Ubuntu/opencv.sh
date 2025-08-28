#!/bin/bash

# 加载环境变量文件
source /etc/environment

# 解压缩
unzip -q -o "../Source/opencv-3.4.16.zip" -d "../Source"

BuildDir="./opencv-3.4.16"

# 检查构建目录是否存在
if [ -d "$BuildDir" ]; then
    rm -rf "$BuildDir" # 目录存在，删除它
fi
# 创建构建目录
mkdir -p "$BuildDir"

cd libsodium-1.0.20-RELEASE
../../Source/libsodium-1.0.20-RELEASE/configure --prefix=$GISBasic

# 编译项目
make

# 运行检查
make check

# 安装项目
sudo make install

cd ../

