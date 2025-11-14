#!/bin/bash
# extract-source.sh - 通用解压脚本

# 参数：
#   $1: ZipFilePath (ZIP 文件路径)
#   $2: SourceDir   (解压目标目录)
#   $3: Name        (期望的源码目录名，如 json-3.11.3)

set -e  # 出错时立即退出

ZipFilePath="$1"
SourceDir="$2"
Name="$3"

SourcePath="${SourceDir}/${Name}"

echo "检查源码目录: $SourcePath"

if [ ! -d "$SourcePath" ]; then
    echo "源码目录 $SourcePath 不存在，正在从 $ZipFilePath 解压..."

    # 检查 zip 文件是否存在
    if [ ! -f "$ZipFilePath" ]; then
        echo "错误：ZIP 文件不存在：$ZipFilePath"
        exit 1
    fi

    # 解压到 SourceDir
    unzip -q "$ZipFilePath" -d "$SourceDir"

    # 再次检查是否成功创建了目标目录
    if [ ! -d "$SourcePath" ]; then
        echo "错误：解压后仍未找到目录 $SourcePath"
        echo "可能 ZIP 内部结构不同，请检查 ZIP 内容。"
        exit 1
    fi

    echo "✅ 成功解压 $Name 到 $SourcePath"
else
    echo "源码目录已存在：$SourcePath，跳过解压。"
fi

# 可选：将解压后的路径输出，便于父脚本使用
echo "SOURCE_PATH=$SourcePath"  # 可被 source 或解析使用