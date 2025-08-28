#!/bin/bash

# ===========================================
# build.sh - Ubuntu 构建调度脚本
# 功能：安装或列出第三方库
# 用法：
#   ./build.sh -install <libname|all>
#   ./build.sh -list all
# ===========================================

# 默认参数
INSTALL=""
LIST=""

# 解析命令行参数
while [[ $# -gt 0 ]]; do
  case $1 in
    -install)
      INSTALL="$2"
      shift 2
      ;;
    -list)
      LIST="$2"
      shift 2
      ;;
    -installdir)
      INSTALL_DIR="$2"
      shift 2
      ;;
    -symboldir)
      SYMBOL_DIR="$2"
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

# 加载环境变量
source /etc/environment

# 检查关键变量
if [ -z "$eGova3rdParty" ]; then
    echo "错误：环境变量 eGova3rdParty 未设置！"
    echo "请先执行：export eGova3rdParty=/your/path"
    exit 1
fi

# 定义库集合（SortedSet 替代：使用数组 + sort）
declare -a LIBRARY_SET=(
    "nlohmann-json" 
    "cpp-httplib"
    "OpenSSL"
    "sqlite"
)

# 转换为小写比较函数
to_lower() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

# 检查是否提供了 -install 参数
if [ -n "$INSTALL" ]; then
    INSTALL_LOWER=$(to_lower "$INSTALL")

    if [ "$INSTALL_LOWER" = "-all" ] || [ "$INSTALL_LOWER" = "all" ]; then
        echo "即将安装所有库..."
        for item in "${LIBRARY_SET[@]}"; do
            echo "正在查找并安装库: $item"
            BUILD_SCRIPT="./${item}.sh"
            if [ -f "$BUILD_SCRIPT" ]; then
                chmod +x "$BUILD_SCRIPT"  # 确保有执行权限
                "$BUILD_SCRIPT" -generator "$GENERATOR" -installdir "$INSTALL_DIR"       
            else
                echo "错误: 找不到构建脚本 $BUILD_SCRIPT"
                exit 1
            fi
        done
    else
        # 检查是否在库集合中
        FOUND=false
        for lib in "${LIBRARY_SET[@]}"; do
            if [ "$lib" = "$INSTALL" ]; then
                FOUND=true
                echo "正在安装库: $INSTALL"
                BUILD_SCRIPT="./${INSTALL}.sh"
                if [ -f "$BUILD_SCRIPT" ]; then
                    chmod +x "$BUILD_SCRIPT"
                    "$BUILD_SCRIPT" -installdir "$INSTALL_DIR"                                        
                else
                    echo "错误: 找不到构建脚本 $BUILD_SCRIPT"
                    exit 1
                fi
                break
            fi
        done
        if [ "$FOUND" = false ]; then
            echo "错误: 找不到名为 $INSTALL 的库！"
            exit 1
        fi
    fi

# 检查是否提供了 -list 参数
elif [ -n "$LIST" ]; then
    LIST_LOWER=$(to_lower "$LIST")
    if [ "$LIST_LOWER" = "all" ] || [ "$LIST_LOWER" = "-all" ]; then
        echo "当前仓库中所有可安装的库列表如下："
        printf '%s\n' "${LIBRARY_SET[@]}" | sort
    else
        echo "未知的 list 参数: $LIST"
        exit 1
    fi

else
    echo "请提供参数！"
    echo "用法示例："
    echo "  ./build.sh -install all"
    echo "  ./build.sh -install opencv"
    echo "  ./build.sh -list all"
    exit 1
fi