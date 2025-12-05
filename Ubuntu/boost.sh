#!/bin/bash

# ===========================================
# boost.sh - 构建 boost 库
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
Name="boost-1.89.0"
ZipFileName="${Name}.zip"
SourceDir="../Source"
BuildDir="./${Name}"

# 仅当目标 zip 不存在时才执行后续操作
if [ ! -f "${SourceDir}/${Name}.zip" ]; then
    # 1. 解压到 SourceDir
    7z x "${SourceDir}/${Name}.7z" -o"${SourceDir}" -y
    # 2. 进入 SourceDir
    cd "${SourceDir}" || exit 1
    # 3. 压缩成 zip（输出到父目录，即原工作目录）
    zip -r "${Name}.zip" "${Name}"
    # 4. 返回原目录
    cd - > /dev/null
    # 5. 删除解压出的文件夹（可选：加 -f 避免报错）
    rm -rf "${SourceDir}/${Name}"
else
    echo "✅ ${Name}.zip already exists, skipping."
fi

CMakeArgs="-DBUILD_SHARED_LIBS=ON"
TargetFile="${InstallDir}/include/boost/version.hpp"

# 组装要传递给 build-common.sh 的参数
common_args=()
common_args+=("-installdir" "$InstallDir")
common_args+=("-requiredlibs" "zlib openssl")
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
  "$Name" "$ZipFileName" "$SourceDir" "$BuildDir" "$CMakeArgs" "$TargetFile" false
