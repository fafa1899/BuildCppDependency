#!/bin/bash

# build-common.sh - 通用构建脚本
# 参数顺序：Name ZipFileName SourceDir BuildDir CMakeArgs [Generator] [InstallDir]

set -euo pipefail  # 严格模式

# 加载环境
source /etc/environment

# 默认值
Generator="Unix Makefiles"
InstallDir=""

# 解析可选参数（只支持 -installdir）
while [[ $# -gt 0 ]]; do
  case $1 in
    -installdir)
      InstallDir="$2"
      shift 2
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

# 读取项目参数
Name="$1"
ZipFileName="$2"
SourceDir="$3"
BuildDir="$4"
CMakeArgs="$5"



ZipFilePath="${SourceDir}/${ZipFileName}"

echo "�� 开始构建项目: $Name"
echo "�� 压缩包路径: $ZipFilePath"
echo "�� 源码目录: $SourceDir"
echo "⚙️  构建目录: $BuildDir"

# === 解压源码 ===
chmod +x ./extract-source.sh
source_result=$(./extract-source.sh "$ZipFilePath" "$SourceDir" "$Name")
SourcePath=$(echo "$source_result" | grep "^SOURCE_PATH=" | cut -d= -f2-)

if [ -z "$SourcePath" ]; then
    echo "❌ 解压失败，无法获取 SourcePath"
    exit 1
fi

echo "✅ 源码解压至: $SourcePath"

# === 执行 CMake 构建 ===
chmod +x ./cmake-build.sh
./cmake-build.sh "$SourcePath" "$BuildDir" "$Generator" "$InstallDir" "$CMakeArgs"

# === 清理工作 ===
echo "�� 正在清理临时目录..."
rm -rf "$SourcePath" && echo "��️ 已删除源码目录: $SourcePath"
rm -rf "$BuildDir" && echo "��️ 已删除构建目录: $BuildDir"

echo "�� 项目 $Name 构建完成"