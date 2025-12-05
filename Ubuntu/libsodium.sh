#!/bin/bash

# ===========================================
# libsodium.sh - 构建 libsodium 库
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

BuildDir="./libsodium-1.0.20-RELEASE"
SourcePath="../Source/libsodium-1.0.20-RELEASE"
TargetFile="${InstallDir}/lib/libsodium.so"

# 如果没有 -force 且目标文件已存在，跳过构建
if [[ "$FORCE" == false && -f "$TargetFile" ]]; then
    echo "✅ 库已存在: $TargetFile，跳过构建 (使用 -force 可强制重建)"
    exit 0
fi

if [[ "$FORCE" == true ]]; then
    echo "⚠️  启用 -force 模式，将重新构建项目 $Name"
fi

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

# 安装cmake配置文件
cp -r cmake/libsodium "${InstallDir}/lib/cmake/"

# === 清理临时文件 ===
if [[ "$NOClean" == false ]]; then
    echo "������ 正在清理临时目录..."
    rm -rf "$SourcePath" && echo "������️ 已删除源码目录: $SourcePath"
    rm -rf "$BuildDir" && echo "������️ 已删除构建目录: $BuildDir"
else
    echo "������ 已启用 -noclean，保留源码和构建目录"
fi

echo "������ 项目 libsodium 构建完成"
