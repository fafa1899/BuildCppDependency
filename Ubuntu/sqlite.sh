#!/bin/bash

# ===========================================
# sqlite.sh - 构建 sqlite 库
# 接收参数：
#   -installdir <dir>
#   -force
#   -noclean
# ===========================================

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

# 定义变量
SourcePath="../Source/sqlite-3.4.6"
BuildDir="./sqlite-3.4.6"
Generator="Unix Makefiles"
CMakeArgs=""
TargetFile="${InstallDir}/lib/libsqlite3.so"

# 如果没有 -force 且目标文件已存在，跳过构建
if [[ "$FORCE" == false && -f "$TargetFile" ]]; then
    echo "✅ 库已存在: $TargetFile，跳过构建 (使用 -force 可强制重建)"
    exit 0
fi

if [[ "$FORCE" == true ]]; then
    echo "⚠️  启用 -force 模式，将重新构建项目 $Name"
fi

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
