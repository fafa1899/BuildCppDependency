#!/bin/bash

# ===========================================
# gmp.sh - 构建 GMP 库 
# 接收参数：
#   -installdir <dir>    # 安装目录（必须）
#   -force               # 强制重新构建
#   -noclean             # 不清理临时文件
# ===========================================

set -e  # 遇到错误立即退出

# 默认值
InstallDir=""
FORCE=false
NOClean=false

# 解析可选参数（保持原样）
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
    --)
      shift
      break
      ;;
    -*)
      echo "未知参数: $1"
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

# 参数检查
if [[ -z "$InstallDir" ]]; then
  echo "❌ 错误: 必须指定 -installdir <安装目录>"
  exit 1
fi

# === 构建参数（逐行可注释） ===
CONFIGURE_ARGS=(
    "--enable-cxx"   # 开启CPP接口
    "--enable-fat"     # CPU优化
)

# 拼接构建参数
CONFIGURE_JOINED=""
for arg in "${CONFIGURE_ARGS[@]}"; do
    CONFIGURE_JOINED+="$arg "
done

# === 调用公共构建脚本 ===
BASE="$(dirname "$0")"

chmod +x $BASE/autotools-build.sh
"$BASE/autotools-build.sh" \
    -name "gmp-6.3.0" \
    -header "gmp.h" \
    -installdir "$InstallDir" \
    -source-base "../Source" \
    -configure-args "$CONFIGURE_JOINED" \
    $([[ "$FORCE" == true ]] && echo "-force") \
    $([[ "$NOClean" == true ]] && echo "-noclean")