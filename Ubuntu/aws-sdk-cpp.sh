#!/bin/bash

# ===========================================
# aws-sdk-cpp.sh - 构建 aws-sdk-cpp 库
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
Name="aws-sdk-cpp"
ZipFileName="${Name}.zip"
SourceDir="../Source"
BuildDir="./${Name}"

# 
if [ ! -f "${SourceDir}/${ZipFileName}" ]; then  
    # 解压并压缩
    cd "${SourceDir}"

    NAME_PREFIX="${Name}.7z"
    SOURCE_DIR="${Name}"
    OUTPUT_ZIP="${Name}.zip"

    echo "������ 步骤 1: 检查并解压 7z 分卷..."
    rm -rf "$SOURCE_DIR"

    # 检查 .001 分卷是否存在
    if [ ! -f "${NAME_PREFIX}.001" ]; then
        echo "❌ 错误: 未找到分卷 ${NAME_PREFIX}.001"
        exit 1
    fi

    # 使用 7z 解压（只需指定 .001，它会自动加载 .002, .003...）
    7z x "${NAME_PREFIX}.001"
    
    if [ ! -d "$SOURCE_DIR" ]; then
        echo "❌ 错误: 解压后未找到目录 $SOURCE_DIR"
        exit 1
    fi

    echo "✅ 成功解压出目录: $SOURCE_DIR"


    echo "������ 步骤 2: 打包为单个 ZIP 文件: $OUTPUT_ZIP"
    zip -r "$OUTPUT_ZIP" "$SOURCE_DIR"
    
    echo "������️ 步骤 3: 删除临时文件夹 $SOURCE_DIR"
    rm -rf "$SOURCE_DIR"

    echo "������ 完成！已生成单文件 ZIP: $OUTPUT_ZIP"
    cd -
fi

CMakeArgs="-DBUILD_SHARED_LIBS=on -DBUILD_ONLY=s3 -DENABLE_TESTING=OFF -DENFORCE_SUBMODULE_VERSIONS=OFF"
TargetFile="${InstallDir}/lib/libaws-c-s3.so"

# 组装要传递给 build-common.sh 的参数
common_args=()
common_args+=("-installdir" "$InstallDir")
common_args+=("-requiredlibs" "zlib openssl curl")
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