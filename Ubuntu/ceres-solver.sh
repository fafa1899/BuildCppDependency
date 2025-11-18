#!/bin/bash

# ===========================================
# ceres-solver.sh - 构建 ceres-solver 库
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

# 项目配置
Name="ceres-solver-2.2.0"
ZipFileName="${Name}.zip"
SourceDir="../Source"
BuildDir="./${Name}"

CMakeArgs="-DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF -DBUILD_SHARED_LIBS=OFF -DUSE_CUDA=ON"
TargetFile="${InstallDir}/lib/libceres.so"

# 组装要传递给 build-common.sh 的参数
common_args=()
common_args+=("-installdir" "$InstallDir")
common_args+=("-requiredlibs" "eigen gflags glog OpenBLAS SuiteSparse")
if [ "$FORCE" = true ]; then
  common_args+=("-force")
fi
if [ "$NOClean" = true ]; then
  common_args+=("-noclean")
fi

# 调用通用脚本
chmod +x ./build-common.sh
./build-common.sh \
  "${common_args[@]}" \
  -- \
  "$Name" "$ZipFileName" "$SourceDir" "$BuildDir" "$CMakeArgs" "$TargetFile"
