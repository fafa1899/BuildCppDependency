#!/bin/bash

# 加载环境变量文件
source /etc/environment

#
GENERATOR=""
Generator=""

# 解析命令行参数
while [[ $# -gt 0 ]]; do
  case $1 in
    -generator)
      Generator="$2"
      shift 2
      ;;
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

echo $GENERATOR
echo $INSTALL_DIR

# 定义变量
Name="json-3.11.3"
SourceDir="../Source"

# 动态构建路径
ZipFilePath="${SourceDir}/${Name}.zip"
SourcePath="${SourceDir}/${Name}"
BuildDir="./${Name}"

# 检查源码目录是否存在，不存在则解压
if [ ! -d "$SourcePath" ]; then
    echo "源码目录 $SourcePath 不存在，正在从 $ZipFilePath 解压..."

    # 检查 zip 文件是否存在
    if [ ! -f "$ZipFilePath" ]; then
        echo "错误：ZIP 文件不存在：$ZipFilePath"
        exit 1
    fi

    # 使用 unzip 解压
    unzip -q "$ZipFilePath" -d "$SourceDir"

    # 检查是否成功解压出目录
    if [ ! -d "$SourcePath" ]; then
        echo "错误：解压后仍未找到目录 $SourcePath，可能 ZIP 内部结构不同。"
        exit 1
    fi

    echo "✅ 成功解压 $NAME 到 $SourcePath"
else
    echo "源码目录已存在：$SourcePath，跳过解压。"
fi


CMakeArgs="-DJSON_BuildTests=OFF"

# 调用 build.sh 脚本
chmod +x ./cmake-build.sh
./cmake-build.sh "$SourcePath" "$BuildDir" "$Generator" "$InstallDir" "$CMakeArgs"

# 删除源码目录和构建目录
echo "正在清理目录..."
if [ -d "$SourcePath" ]; then
    rm -rf "$SourcePath"
    echo "已删除源码目录: $SourcePath"
fi

if [ -d "$BuildDir" ]; then
    rm -rf "$BuildDir"
    echo "已删除构建目录: $BuildDir"
fi
