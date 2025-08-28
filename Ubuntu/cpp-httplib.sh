#!/bin/bash

source /etc/environment

# 默认值
Generator="Unix Makefiles"
InstallDir=""

# 解析参数
while [[ $# -gt 0 ]]; do
  case $1 in

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

# 项目配置
Name="cpp-httplib-0.25.0"
SourceDir="../Source"
ZipFilePath="${SourceDir}/${Name}.zip"
BuildDir="./${Name}"
CMakeArgs=""

# 调用通用解压脚本
chmod +x ./extract-source.sh
source_result=$(./extract-source.sh "$ZipFilePath" "$SourceDir" "$Name")
SourcePath=$(echo "$source_result" | grep "SOURCE_PATH=" | cut -d= -f2)

if [ -z "$SourcePath" ]; then
    echo "❌ 解压失败，无法获取 SourcePath"
    exit 1
fi

# 执行构建
chmod +x ./cmake-build.sh
./cmake-build.sh "$SourcePath" "$BuildDir" "$Generator" "$InstallDir" "$CMakeArgs"

# 清理
echo "正在清理目录..."
rm -rf "$SourcePath" && echo "已删除源码目录: $SourcePath"
rm -rf "$BuildDir" && echo "已删除构建目录: $BuildDir"