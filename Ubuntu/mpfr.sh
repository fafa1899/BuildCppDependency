#!/bin/bash

# ===========================================
# mpfr.sh - 构建 MPFR 库 
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

# 解析可选参数（保持旧语法完全一致）
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

# 必要参数检查
if [[ -z "$InstallDir" ]]; then
  echo "❌ 错误: 必须指定 -installdir <安装目录>"
  exit 1
fi

# === 依赖库名称（按照顺序构建） ===
DEPENDENCIES=(
    "gmp"  # MPFR 依赖 GMP
)

# === 构建参数（逐行可注释） ===
CONFIGURE_ARGS=(
    "--with-gmp=$InstallDir"   # 指定已安装的 GMP 路径
    "--enable-thread-safe"     # 线程安全
)

# 拼接构建参数
CONFIGURE_JOINED=""
for arg in "${CONFIGURE_ARGS[@]}"; do
    CONFIGURE_JOINED+="$arg "
done

# === 开始处理依赖 ===
BASE="$(dirname "$0")"

for dep in "${DEPENDENCIES[@]}"; do
    echo "������ 正在构建依赖库: $dep"
    DEP_SCRIPT="$BASE/${dep}.sh"

    if [[ ! -f "$DEP_SCRIPT" ]]; then
        echo "❌ 依赖脚本不存在: $DEP_SCRIPT"
        exit 1
    fi

    chmod +x "$DEP_SCRIPT"

    "$DEP_SCRIPT" \
        -installdir "$InstallDir" \
#        $([[ "$FORCE" == true ]] && echo "-force") \
#        $([[ "$NOClean" == true ]] && echo "-noclean")
done

# === 调用公共构建脚本 ===
chmod +x "$BASE/autotools-build.sh"

"$BASE/autotools-build.sh" \
    -name "mpfr-4.2.2" \
    -header "mpfr.h" \
    -installdir "$InstallDir" \
    -source-base "../Source" \
    -configure-args "$CONFIGURE_JOINED" \
    $([[ "$FORCE" == true ]] && echo "-force") \
    $([[ "$NOClean" == true ]] && echo "-noclean")
