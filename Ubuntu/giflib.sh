#!/bin/bash

# ===========================================
# giflib.sh - 构建 giflib 库
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

Name="giflib"

# 如果没有 -force 且目标文件已存在，跳过构建
TargetFile="${InstallDir}/lib/libgiflib.so"
if [[ "$FORCE" == false && -f "$TargetFile" ]]; then
    echo "✅ 库已存在: $TargetFile，跳过构建 (使用 -force 可强制重建)"
    exit 0
fi

if [[ "$FORCE" == true ]]; then
    echo "⚠️  启用 -force 模式，将重新构建项目 $Name"
fi

# 定义变量
SourcePath="../Source/giflib-5.2.2"
BuildDir="./giflib-5.2.2"
Generator="Unix Makefiles"
CMakeArgs=""

# 调用 build.sh 脚本
chmod +x ./cmake-build.sh
./cmake-build.sh "$SourcePath" "$BuildDir" "$Generator" "$InstallDir" "$CMakeArgs"


# === 清理临时文件 ===
if [[ "$NOClean" == false ]]; then
    echo "������ 正在清理临时目录..." 
    rm -rf "$BuildDir" && echo "������️ 已删除构建目录: $BuildDir"  
else
    echo "������ 已启用 -noclean，保留源码和构建目录"
fi

echo "������ 项目 $Name 构建完成"
