#!/bin/bash
#
# Minimal environment setup for CLLOG building
# Sets up the absolute minimum required environment variables
#

# Color output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== CLLOG Minimal Environment Setup ===${NC}"

# 函数：自动检测Harbour安装
auto_detect_harbour() {
    if command -v harbour >/dev/null 2>&1; then
        HARBOUR_PATH=$(which harbour)
        HB_ROOT=$(dirname $(dirname $HARBOUR_PATH))
        echo "Found Harbour at: $HARBOUR_PATH"
        echo "HB_ROOT set to: $HB_ROOT"
        return 0
    else
        echo "Harbour not found in PATH"
        return 1
    fi
}

# 函数：自动检测HwGUI安装
auto_detect_hwgui() {
    local search_paths=(
        "$HOME/hwgui"
        "$HOME/hb/hwgui-code/hwgui"
        "$HOME/hb/iflow/hwgui-code/hwgui"
        "/usr/local/share/harbour/addons/hwgui"
        "$HB_ROOT/share/harbour/addons/hwgui"
    )

    for path in "${search_paths[@]}"; do
        if [ -f "$path/hwgui.hbc" ]; then
            HWGUI_ROOT=$path
            echo "Found HwGUI at: $HWGUI_ROOT"
            return 0
        fi
    done

    echo "HwGUI not found in standard locations"
    return 1
}

# 1. 自动检测或手动设置Harbour路径
if [ -z "$HB_ROOT" ]; then
    if auto_detect_harbour; then
        export HB_ROOT
    else
        echo -e "${YELLOW}Please set HB_ROOT to your Harbour installation path${NC}"
        echo "Example: export HB_ROOT=/home/user/harbour"
        return 1
    fi
fi

# 2. 自动检测或手动设置HwGUI路径
if [ -z "$HWGUI_ROOT" ]; then
    if auto_detect_hwgui; then
        export HWGUI_ROOT
    else
        echo -e "${YELLOW}Please set HWGUI_ROOT to your HwGUI installation path${NC}"
        echo "Example: export HWGUI_ROOT=/home/user/hwgui"
        return 1
    fi
fi

# 3. 设置最小必需的环境变量
echo -e "${GREEN}Setting minimal environment variables...${NC}"

# 基本路径（hbmk2会自动推导大部分）
export HWGUI_INC="$HWGUI_ROOT/include"
export HWGUI_LIB="$HWGUI_ROOT/lib"

# 编译选项（最小化）
export HB_COMOPTS="-w0"  # 禁用警告

# 4. 创建简化的构建别名
cat > ~/.cllog_build_aliases << 'EOF'
# CLLOG build aliases
alias cllog-build-gui='cd ~/demoapp/cllog-code/trunk/src && hbmk2 logw.hbp -n0 -w0'
alias cllog-build-console='cd ~/demoapp/cllog-code/trunk/src && harbour log.prg -n -w0 && gcc log.c -olog'
alias cllog-clean='cd ~/demoapp/cllog-code/trunk/src && rm -f *.c *.o logw log'
alias cllog-test='cd ~/demoapp/cllog-code/trunk/src && ./logw 2>/dev/null || echo "Build first with: cllog-build-gui"'
EOF

echo ""
echo -e "${GREEN}Environment setup complete!${NC}"
echo ""
echo "Available commands:"
echo "  cllog-build-gui     - Build GUI version"
echo "  cllog-build-console - Build console version"
echo "  cllog-clean        - Clean build files"
echo "  cllog-test         - Test the application"
echo ""
echo "To load aliases in current session:"
echo "  source ~/.cllog_build_aliases"
echo ""
echo "Environment variables set:"
echo "  HB_ROOT=$HB_ROOT"
echo "  HWGUI_ROOT=$HWGUI_ROOT"
echo "  HWGUI_INC=$HWGUI_INC"
echo "  HWGUI_LIB=$HWGUI_LIB"
echo "  HB_COMOPTS=$HB_COMOPTS"