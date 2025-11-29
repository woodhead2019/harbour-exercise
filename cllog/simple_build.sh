#!/bin/bash
#
# Simplified build script for CLLOG
# Minimal environment variables for easy building
#
# This script demonstrates the minimum required setup

# Exit on error
set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== CLLOG Simple Build Script ===${NC}"

# 1. 检查必需的命令
command -v harbour >/dev/null 2>&1 || { echo -e "${RED}Error: harbour not found. Please install Harbour.${NC}" >&2; exit 1; }
command -v hbmk2 >/dev/null 2>&1 || { echo -e "${RED}Error: hbmk2 not found. Please install Harbour.${NC}" >&2; exit 1; }

# 2. 自动检测Harbour安装路径
if [ -z "$HB_ROOT" ]; then
    # 从harbour命令路径推导
    HARBOUR_PATH=$(which harbour)
    HB_ROOT=$(dirname $(dirname $HARBOUR_PATH))
    echo -e "${YELLOW}Auto-detected HB_ROOT: $HB_ROOT${NC}"
fi

# 3. 自动检测HwGUI路径
if [ -z "$HWGUI_ROOT" ]; then
    # 常见HwGUI安装位置
    for path in \
        "$HOME/hwgui" \
        "$HOME/hb/hwgui-code/hwgui" \
        "/usr/local/share/harbour/addons/hwgui" \
        "$HB_ROOT/share/harbour/addons/hwgui"; do
        if [ -f "$path/hwgui.hbc" ]; then
            HWGUI_ROOT=$path
            echo -e "${YELLOW}Auto-detected HWGUI_ROOT: $HWGUI_ROOT${NC}"
            break
        fi
    done
fi

# 4. 验证HwGUI安装
if [ -z "$HWGUI_ROOT" ] || [ ! -f "$HWGUI_ROOT/hwgui.hbc" ]; then
    echo -e "${RED}Error: HwGUI not found. Please install HwGUI or set HWGUI_ROOT.${NC}"
    echo -e "${YELLOW}Expected hwgui.hbc in one of these locations:${NC}"
    echo "  $HOME/hwgui/hwgui.hbc"
    echo "  $HOME/hb/hwgui-code/hwgui/hwgui.hbc"
    echo "  /usr/local/share/harbour/addons/hwgui/hwgui.hbc"
    exit 1
fi

# 5. 设置最小环境变量
echo -e "${GREEN}Setting up minimal environment...${NC}"

# 基本路径
export HB_ROOT
export HWGUI_ROOT

# Harbour编译选项（最小化）
export HB_COMOPTS="-w0"  # 禁用警告

# 库路径（让hbmk2自动处理大部分）
export HWGUI_INC="$HWGUI_ROOT/include"
export HWGUI_LIB="$HWGUI_ROOT/lib"

# 6. 构建选项
BUILD_OPTS="-n0 -w0"

# 7. 选择构建目标
if [ -z "$1" ]; then
    echo -e "${YELLOW}Usage: $0 <target> [options]${NC}"
    echo -e "  ${GREEN}Targets:${NC}"
    echo "    logw    - Build GUI version with HwGUI"
    echo "    log     - Build console version"
    echo "    clean   - Clean build files"
    echo -e "  ${GREEN}Options:${NC}"
    echo "    debug   - Enable debug mode"
    exit 1
fi

TARGET=$1
shift

# 处理额外选项
for arg in "$@"; do
    case $arg in
        debug)
            echo -e "${YELLOW}Debug mode enabled${NC}"
            BUILD_OPTS="$BUILD_OPTS -dDEBUG"
            ;;
    esac
done

# 8. 执行构建
case $TARGET in
    logw)
        echo -e "${GREEN}Building GUI version (logw)...${NC}"
        if command -v hbmk2 >/dev/null 2>&1; then
            # 使用hbmk2（推荐）
            echo "Using hbmk2..."
            hbmk2 logw.hbp $BUILD_OPTS
        else
            # 回退到手动编译
            echo "Using manual build..."
            harbour logw -n -w0
            gcc logw.c -ologw -I$HWGUI_INC -L$HWGUI_LIB -lhwgui $(pkg-config --cflags --libs gtk+-2.0)
        fi
        ;;

    log)
        echo -e "${GREEN}Building console version (log)...${NC}"
        harbour log -n -w0
        gcc log.c -olog
        ;;

    clean)
        echo -e "${GREEN}Cleaning build files...${NC}"
        rm -f *.c *.o logw log
        echo -e "${GREEN}Clean complete${NC}"
        ;;

    *)
        echo -e "${RED}Unknown target: $TARGET${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}Build complete!${NC}"

# 9. 显示结果
if [ -f "logw" ]; then
    echo -e "${GREEN}GUI executable: ./logw${NC}"
fi
if [ -f "log" ]; then
    echo -e "${GREEN}Console executable: ./log${NC}"
fi