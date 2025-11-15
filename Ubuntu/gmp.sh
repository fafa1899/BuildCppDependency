#!/bin/bash


# ===========================================
# gmp.sh - 构建 GMP 库 
# 接收参数：
#   -installdir <dir>    # 安装目录（必须）
#   -force               # 强制重新构建
#   -noclean             # 不清理临时文件
# ===========================================

set -e  # 遇到错误立即退出

# 默认值
InstallDir=""
FORCE=false
NOClean=false

# 解析可选参数
while [[ $# -gt 0 ]]; do
  case $1 in
    -installdir)
      InstallDir="$2"
      shift 2
      ;;
    -force)
      FORCE=true
      shift
      ;;
    -noclean)
      NOClean=true
      shift
      ;;
    --) # 分隔符，后面是项目参数
      shift
      break
      ;;
    -*)
      echo "未知参数: $1"
      exit 1
      ;;
    *)
      break  # 非选项参数开始，停止解析
      ;;
  esac
done

# 检查必要参数
if [[ -z "$InstallDir" ]]; then
  echo "❌ 错误: 必须指定 -installdir <安装目录>"
  exit 1
fi

# 项目配置
InstallDir=$(realpath "$InstallDir")
ScriptDir=$(pwd)
SourceBaseDir=$(realpath "../Source")       # 绝对路径
Name="gmp-6.3.0"
SourceZipFile="${SourceBaseDir}/${Name}.tar.xz"
ExtractedSourceDir="${SourceBaseDir}/${Name}"
BuildDir="${ScriptDir}/build-${Name}"       # 明确区分 build 目录
TargetFile="${InstallDir}/include/gmp.h"

# 检查源码包是否存在
if [[ ! -f "$SourceZipFile" ]]; then
  echo "❌ 源码包未找到: $SourceZipFile"
  exit 1
fi

# 如果没有 -force 且目标文件已存在，跳过构建
if [[ "$FORCE" == false && -f "$TargetFile" ]]; then
    echo "✅ GMP 已安装: $TargetFile，跳过构建（使用 -force 可强制重建）"
    exit 0
fi


if [[ "$FORCE" == true ]]; then
    echo "⚠️  启用 -force 模式，将重新构建 GMP"
    # 清理旧的构建目录（如果存在）
    rm -rf "$BuildDir"
fi


echo "������ 开始构建 GMP: $Name"
echo "������ 源码包: $SourceZipFile"
echo "������ 解压目录: $ExtractedSourceDir"
echo "⚙️  构建目录: $BuildDir"
echo "������ 安装目录: $InstallDir"

# === 1. 解压源码（如果尚未解压）===
if [[ ! -d "$ExtractedSourceDir" ]]; then
    echo "������ 正在解压源码..."
    tar -xf "$SourceZipFile" -C "../Source/"
else
    echo "������ 源码已存在，跳过解压"
fi

# === 2. 创建并进入构建目录（推荐 out-of-source build）===
mkdir -p "$BuildDir"
cd "$BuildDir"

# === 3. 配置 ===
echo "������ 正在运行 configure..."
"$ExtractedSourceDir/configure" \
    --prefix="$InstallDir" \
    --enable-cxx \
    --enable-fat  # CPU优化

# === 4. 编译 ===
echo "������ 正在编译 GMP..."
make -j$(nproc)

# === 5. 安装 ===
echo "������ 正在安装 GMP 到 $InstallDir..."
make install


# === 6. 清理临时文件 ===
if [[ "$NOClean" == false ]]; then
    echo "������ 正在清理临时目录..."
    rm -rf "$ExtractedSourceDir" && echo "������️ 已删除源码目录: $ExtractedSourceDir"
    rm -rf "$BuildDir" && echo "������️ 已删除构建目录: $BuildDir"
else
    echo "������ 已启用 -noclean，保留构建目录: $BuildDir"
fi

echo "������ 项目 $Name 构建完成"
cd -
