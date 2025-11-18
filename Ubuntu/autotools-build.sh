#!/bin/bash
# ===========================================
# build_common.sh - 通用构建脚本
# 参数：
#   必须：
#     -name <包名>                  # 如 gmp-6.3.0
#     -header <include 下的头文件>  # 如 gmp.h / mpfr.h
#   可选：
#     -installdir <dir>
#     -source-base <dir>           # 默认 ../Source
#     -force
#     -noclean
#     -configure-args "<args>"     # 传给 configure 的额外参数
# ===========================================

set -e

# 默认参数
InstallDir=""
SourceBaseDir="../Source"
FORCE=false
NOClean=false
Name=""
HeaderFile=""
ConfigureArgs=""

# 解析参数
while [[ $# -gt 0 ]]; do
  case $1 in
    -installdir) InstallDir="$2"; shift 2;;
    -source-base) SourceBaseDir="$2"; shift 2;;
    -name) Name="$2"; shift 2;;
    -header) HeaderFile="$2"; shift 2;;
    -configure-args) ConfigureArgs="$2"; shift 2;;
    -force) FORCE=true; shift;;
    -noclean) NOClean=true; shift;;
    *) echo "❌ 未知参数: $1"; exit 1;;
  esac
done

# 参数检查
[[ -z "$Name" ]] && echo "❌ 必须提供 -name" && exit 1
[[ -z "$HeaderFile" ]] && echo "❌ 必须提供 -header" && exit 1
[[ -z "$InstallDir" ]] && echo "❌ 必须提供 -installdir" && exit 1

InstallDir=$(realpath "$InstallDir")
SourceBaseDir=$(realpath "$SourceBaseDir")
ScriptDir=$(pwd)

SourceZip="${SourceBaseDir}/${Name}.tar.xz"
SourceDir="${SourceBaseDir}/${Name}"
BuildDir="${ScriptDir}/build-${Name}"
TargetFile="${InstallDir}/include/${HeaderFile}"

echo "������ 通用构建脚本"
echo "  ������ 包:          $Name"
echo "  ������ 安装目录:    $InstallDir"
echo "  ������ 头文件检查:  $TargetFile"
echo "  ⚙️ configure 参数: $ConfigureArgs"
echo

# 检查源码
if [[ ! -f "$SourceZip" ]]; then
  echo "❌ 找不到源码包: $SourceZip"
  exit 1
fi

# 跳过构建？
if [[ "$FORCE" == false && -f "$TargetFile" ]]; then
    echo "✅ 已安装: $TargetFile   （使用 -force 可重建）"
    exit 0
fi

if [[ "$FORCE" == true ]]; then
    echo "⚠️ 强制模式：删除旧构建目录"
    rm -rf "$BuildDir"
fi

# 解压
if [[ ! -d "$SourceDir" ]]; then
    echo "������ 解压源码..."
    tar -xf "$SourceZip" -C "$SourceBaseDir"
else
    echo "������ 源码目录已存在，跳过解压"
fi

# 创建构建目录
mkdir -p "$BuildDir"
cd "$BuildDir"

# 配置
echo "������ 运行 configure..."
"$SourceDir/configure" \
    --prefix="$InstallDir" \
    $ConfigureArgs

# 编译
echo "������ 编译中..."
make -j$(nproc)

# 安装
echo "������ 安装中..."
make install

# 清理
if [[ "$NOClean" == false ]]; then
    echo "������ 删除临时目录..."
    rm -rf "$SourceDir"
    rm -rf "$BuildDir"
else
    echo "������ 保留构建目录: $BuildDir"
fi

echo "������ $Name 构建完成"
