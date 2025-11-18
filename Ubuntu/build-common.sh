#!/bin/bash

# build-common.sh - 通用构建脚本
# 参数顺序：Name ZipFileName SourceDir BuildDir CMakeArgs TargetFile
# 可选参数：
#   -force         强制重新构建，即使已安装
#   -installdir    <path> 指定安装目录
#   -noclean       构建完成后不清理源码和构建目录
#   -requiredlibs  <lib1 lib2 ...> 指定需要提前安装的依赖库（可选）
#
# 用法示例：
#   ./build-common.sh -installdir /opt/3rdparty -force -requiredlibs "zlib openssl" -- \
#       myproject-1.0 myproject.zip ../Source ./build-myproject \
#       "-DCMAKE_POSITION_INDEPENDENT_CODE=ON" /opt/3rdparty/lib/libmyproject.so

set -euo pipefail  # 严格模式：任何错误都将终止脚本

# 加载系统环境变量
source /etc/environment || true

# 默认值
Generator="Unix Makefiles"
InstallDir=""
FORCE=false
NOClean=false
REQUIRED_LIBS=""  # 支持通过 -requiredlibs 传入依赖库列表，允许为空

# 解析可选参数
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
      if [[ -n "${2:-}" ]]; then
        InstallDir="$2"
        shift 2
      else
        echo "错误: -installdir 缺少参数" >&2
        exit 1
      fi
      ;;
    -requiredlibs)
      if [[ -n "${2:-}" ]]; then
        REQUIRED_LIBS="$2"
        shift 2
      else
        echo "错误: -requiredlibs 缺少参数" >&2
        exit 1
      fi
      ;;
    --) # 分隔符，后面是项目参数
      shift
      break
      ;;
    -*)
      echo "未知参数: $1" >&2
      echo "用法: $0 [-force] [-noclean] [-installdir <dir>] [-requiredlibs \"lib1 lib2...\"] -- <Name> <ZipFileName> <SourceDir> <BuildDir> <CMakeArgs> <TargetFile>" >&2
      exit 1
      ;;
    *)
      break  # 非选项参数开始
      ;;
  esac
done

# 检查必需的项目参数个数
if [[ $# -lt 6 ]]; then
  echo "用法: $0 [-force] [-noclean] [-installdir <dir>] [-requiredlibs \"lib1 lib2...\"] -- <Name> <ZipFileName> <SourceDir> <BuildDir> <CMakeArgs> <TargetFile>" >&2
  exit 1
fi

# 读取项目参数
Name="$1"
ZipFileName="$2"
SourceDir="$3"
BuildDir="$4"
CMakeArgs="$5"
TargetFile="$6"
ParallelArg="${7:-true}"  # 默认为 "true"

# 校验第7个参数（ParallelArg）的合法性
case "$ParallelArg" in
    ""|true)
        # 空或 true：启用并行
        parallel_for_cmake="true"
        ;;
    false)
        # 显式禁用
        parallel_for_cmake="false"
        ;;
    *)
        echo "错误：第7个参数非法（只允许空、true 或 false）: '$ParallelArg'" >&2
        exit 1
        ;;
esac


# 如果没有 -force 且目标文件已存在，跳过构建
if [[ "$FORCE" == false && -f "$TargetFile" ]]; then
    echo "✅ 库已存在: $TargetFile，跳过构建 (使用 -force 可强制重建)"
    exit 0
fi

if [[ "$FORCE" == true ]]; then
    echo "⚠️  启用 -force 模式，将重新构建项目 $Name"
fi

# === 调用 build-required.sh 安装依赖库 ===
if [[ -n "${REQUIRED_LIBS}" ]]; then
    echo "������ 正在安装依赖库: $REQUIRED_LIBS"
    
    # 将字符串转为数组
    read -ra LIB_ARRAY <<< "$REQUIRED_LIBS"
    
    # 构建传递给 build-required.sh 的参数
    REQUIRED_ARGS=()
    if [[ -n "$InstallDir" ]]; then
        REQUIRED_ARGS+=("-installdir" "$InstallDir")
    fi

    # 调用依赖安装脚本
    chmod +x ./build-required.sh
    if ./build-required.sh "${REQUIRED_ARGS[@]}" "${LIB_ARRAY[@]}"; then
        echo "✅ 所有依赖库安装完成"
    else
        echo "❌ 依赖库安装失败"
        exit 1
    fi
else
    echo "⏭️ 未指定 -requiredlibs，跳过依赖库安装"
fi

# === 开始主项目构建 ===
ZipFilePath="${SourceDir}/${ZipFileName}"

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


# === 执行 CMake 构建 ===
chmod +x ./cmake-build.sh
./cmake-build.sh "$SourcePath" "$BuildDir" "$Generator" "$InstallDir" "$CMakeArgs" "$parallel_for_cmake"    


# === 清理临时文件 ===
if [[ "$NOClean" == false ]]; then
    echo "������ 正在清理临时目录..."
    rm -rf "$SourcePath" && echo "������️ 已删除源码目录: $SourcePath"
    rm -rf "$BuildDir" && echo "������️ 已删除构建目录: $BuildDir"
else
    echo "������ 已启用 -noclean，保留源码和构建目录"
fi

echo "������ 项目 $Name 构建完成"