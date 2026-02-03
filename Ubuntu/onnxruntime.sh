#!/bin/bash

# ===========================================
# onnxruntime.sh - 安装预编译的 onnxruntime
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
    --) # 分隔符，后面是项目参数（此处无用，保留一致性）
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

# 检查是否指定了安装目录
if [ -z "$InstallDir" ]; then
  echo "错误: 必须指定 -installdir 参数"
  exit 1
fi

# 项目配置
PackageName="onnxruntime-linux-x64-1.23.2"
TarFileName="${PackageName}.tgz"
SourceDir="../Source"
TargetIncludeDir="${InstallDir}/include/onnxruntime"
TargetLibDir="${InstallDir}/lib"

# 创建临时解压目录
TempExtractDir="./tmp_onnxruntime_extract"

# 如果目标文件已存在且未启用 -force，则跳过
TargetMarker="${InstallDir}/.onnxruntime_installed"
if [ "$FORCE" = false ] && [ -f "$TargetMarker" ]; then
  echo "ONNX Runtime 已安装，跳过（使用 -force 强制重装）"
  exit 0
fi

# 清理旧的临时目录（如果存在）
if [ -d "$TempExtractDir" ]; then
  rm -rf "$TempExtractDir"
fi

# 创建安装目录结构
mkdir -p "$TargetIncludeDir" "$TargetLibDir"

# 检查源压缩包是否存在
if [ ! -f "${SourceDir}/${TarFileName}" ]; then
  echo "错误: 源文件 ${SourceDir}/${TarFileName} 不存在"
  exit 1
fi

# 解压到临时目录
echo "正在解压 ${TarFileName}..."
tar -xzf "${SourceDir}/${TarFileName}" -C ./

# 假设解压后顶层目录就是 PackageName（这是 ONNX Runtime 预编译包的标准结构）
if [ ! -d "${PackageName}" ]; then
  echo "错误: 解压后未找到目录 ${PackageName}"
  exit 1
fi

# 复制 include 和 lib 内容
echo "复制 include 文件..."
cp -r "${PackageName}/include/"* "$TargetIncludeDir/"

echo "复制 lib 文件..."
cp -r "${PackageName}/lib/"* "$TargetLibDir/"

# 创建标记文件表示已安装
touch "$TargetMarker"

# 清理（除非 -noclean）
if [ "$NOClean" = false ]; then
  echo "清理临时文件..."
  rm -rf "${PackageName}"
fi

echo "ONNX Runtime 安装完成：$InstallDir"