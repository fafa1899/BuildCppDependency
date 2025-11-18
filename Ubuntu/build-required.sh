#!/bin/bash

# === 默认值设置 ===
INSTALL_DIR=""
LIBRARY_SET=()

# === 帮助信息 ===
usage() {
    echo "用法: $0 [-installdir DIR] [library...]"
    echo "示例:"
    echo "  $0 zlib openssl"
    echo "  $0 -installdir /opt/myapp zlib openssl curl"
    exit 1
}

# === 解析参数 ===
while [[ $# -gt 0 ]]; do
    case "$1" in
        -installdir)
            if [[ -n "$2" ]]; then
                INSTALL_DIR="$2"
                shift 2
            else
                echo "错误: -installdir 缺少参数"
                usage
            fi
            ;;
        -*)
            echo "未知参数: $1"
            usage
            ;;
        *)
            # 所有非选项参数视为库名
            LIBRARY_SET+=("$1")
            shift
            ;;
    esac
done

# === 构造公共参数数组（传递给子脚本） ===
build_args=()
if [ -n "$INSTALL_DIR" ]; then
    build_args+=("-installdir" "$INSTALL_DIR")
fi

echo "即将安装依赖库..."
for item in "${LIBRARY_SET[@]}"; do
    echo "正在查找并安装库: $item"
    BUILD_SCRIPT="./${item}.sh"
    if [ -f "$BUILD_SCRIPT" ]; then
        chmod +x "$BUILD_SCRIPT"
        if "$BUILD_SCRIPT" "${build_args[@]}"; then
            echo "✅ 成功安装: $item"
        else
            echo "❌ 安装失败: $item"
            exit 1
        fi
    else
        echo "错误: 找不到构建脚本 $BUILD_SCRIPT"
        exit 1
    fi
done

echo "所有指定库安装完成。"