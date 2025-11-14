#!/bin/bash

# ===========================================
# openssl.sh - 构建 openssl 库
# 接收参数：
#   -installdir <dir>
#   -force
#   -noclean
# ===========================================

# 加载环境变量文件
source /etc/environment

InstallDir=""
FORCE=false
NOClean=false

# 解析参数
while [[ $# -gt 0 ]]; do
  case $1 in
    -force)
      FORCE=true
      shift
      ;;
    -noclean)
      NOClean=true
      shift
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

# 如果没有 -force 且目标文件已存在，跳过构建
TargetFile="${InstallDir}/include/openssl/core.h"
if [[ "$FORCE" == false && -f "$TargetFile" ]]; then
    echo "✅ 库已存在: $TargetFile，跳过构建 (使用 -force 可强制重建)"
    exit 0
fi

if [[ "$FORCE" == true ]]; then
    echo "⚠️  启用 -force 模式，将重新构建项目 $Name"
fi


# === 开始主项目构建 ===
Name="openssl-openssl-3.4.0"
SourceDir="../Source"
ZipFileName="${Name}.zip"
ZipFilePath="${SourceDir}/${ZipFileName}"
BuildDir="./${Name}"

echo "������ 开始构建项目: $Name"
echo "������ 压缩包路径: $ZipFilePath"
echo "������ 源码目录: $SourceDir"
echo "⚙️  构建目录: $BuildDir"

# === 解压源码 ===
chmod +x ./extract-source.sh
source_result=$(./extract-source.sh "$ZipFilePath" "$SourceDir" "$Name")
SourcePath=$(echo "$source_result" | grep "^SOURCE_PATH=" | cut -d= -f2-)

if [[ -z "$SourcePath" ]]; then
    echo "❌ 解压失败，无法获取 SOURCE_PATH" >&2
    exit 1
fi
echo "✅ 源码解压至: $SourcePath"

# 检查构建目录是否存在
if [ -d "$BuildDir" ]; then
    rm -rf "$BuildDir" # 目录存在，删除它
fi
# 创建构建目录
mkdir -p "$BuildDir"

cd $SourcePath

./Configure --openssldir=$BuildDir --prefix=$InstallDir --release

# 使用 CPU 所有核心进行并行编译
make -j$(nproc)

make install -j$(nproc)

# 回到之前的目录
cd -

# === 清理临时文件 ===
if [[ "$NOClean" == false ]]; then
    echo "������ 正在清理临时目录..."
    rm -rf "$SourcePath" && echo "������️ 已删除源码目录: $SourcePath"
    rm -rf "$BuildDir" && echo "������️ 已删除构建目录: $BuildDir"    
else
    echo "������ 已启用 -noclean，保留源码和构建目录"
fi

echo "������ 项目 $Name 构建完成"
