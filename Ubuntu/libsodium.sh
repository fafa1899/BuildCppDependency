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

BuildDir="./libsodium-1.0.20-RELEASE"
SourcePath="../Source/libsodium-1.0.20-RELEASE"

# 解压缩
unzip -q -o "../Source/libsodium-1.0.20-RELEASE.zip" -d "../Source"

# 检查构建目录是否存在
if [ -d "$BuildDir" ]; then
    rm -rf "$BuildDir" # 目录存在，删除它
fi
# 创建构建目录
mkdir -p "$BuildDir"

cd $SourcePath

./configure --prefix=$InstallDir

# 使用 CPU 所有核心进行并行编译
make -j$(nproc)

make install -j$(nproc)

# 安装项目
sudo make install

# 回到之前的目录
cd -

# 清理
echo "正在清理目录..."
rm -rf "$SourcePath" && echo "已删除源码目录: $SourcePath"
rm -rf "$BuildDir" && echo "已删除构建目录: $BuildDir"

