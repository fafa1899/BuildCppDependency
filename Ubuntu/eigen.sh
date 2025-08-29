#!/bin/bash

# 解析可选参数
InstallDir=""
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

# 项目配置
Name="eigen-3.4.0"
ZipFileName="${Name}.zip"
SourceDir="../Source"
BuildDir="./${Name}"
CMakeArgs=""

# 调用通用脚本
chmod +x ./build-common.sh
./build-common.sh \
  -installdir "$InstallDir" \
  -- \
  "$Name" "$ZipFileName" "$SourceDir" "$BuildDir" "$CMakeArgs"
