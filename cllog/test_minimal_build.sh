#!/bin/bash
#
# Test script for minimal environment build
# Verifies that the minimal setup works correctly
#

set -e  # Exit on error

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Testing Minimal Environment Build ===${NC}"

# 保存当前环境
OLD_HB_ROOT=$HB_ROOT
OLD_HWGUI_ROOT=$HWGUI_ROOT

# 1. 清理环境
echo -e "${YELLOW}Step 1: Cleaning environment${NC}"
unset HB_ROOT
unset HWGUI_ROOT
unset HWGUI_INC
unset HWGUI_LIB
unset HB_COMOPTS

# 2. 测试自动检测
echo -e "${YELLOW}Step 2: Testing auto-detection${NC}"
source ./minimal_env_setup.sh

# 3. 验证环境变量
echo -e "${YELLOW}Step 3: Verifying environment variables${NC}"
echo "HB_ROOT: $HB_ROOT"
echo "HWGUI_ROOT: $HWGUI_ROOT"
echo "HWGUI_INC: $HWGUI_INC"
echo "HWGUI_LIB: $HWGUI_LIB"

# 检查关键文件是否存在
if [ -z "$HB_ROOT" ]; then
    echo -e "${RED}FAIL: HB_ROOT not set${NC}"
    exit 1
fi

if [ -z "$HWGUI_ROOT" ]; then
    echo -e "${RED}FAIL: HWGUI_ROOT not set${NC}"
    exit 1
fi

if [ ! -f "$HWGUI_ROOT/hwgui.hbc" ]; then
    echo -e "${RED}FAIL: hwgui.hbc not found at $HWGUI_ROOT/hwgui.hbc${NC}"
    exit 1
fi

echo -e "${GREEN}Environment variables OK${NC}"

# 4. 测试简单构建
echo -e "${YELLOW}Step 4: Testing simple build${NC}"
cd ~/demoapp/cllog-code/trunk/src

# 测试hbmk2是否可用
if command -v hbmk2 >/dev/null 2>&1; then
    echo "Testing hbmk2 build..."

    # 清理之前的构建
    rm -f logw.c logw.o logw 2>/dev/null || true

    # 尝试构建（只编译，不链接，以节省时间）
    if hbmk2 logw.hbp -n0 -w0 -c; then
        echo -e "${GREEN}SUCCESS: hbmk2 compilation test passed${NC}"
    else
        echo -e "${RED}FAIL: hbmk2 compilation test failed${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}hbmk2 not available, testing manual build${NC}"

    # 测试手动编译
    if harbour logw.prg -n -w0; then
        echo -e "${GREEN}SUCCESS: harbour compilation test passed${NC}"
    else
        echo -e "${RED}FAIL: harbour compilation test failed${NC}"
        exit 1
    fi
fi

# 5. 测试控制台版本构建
echo -e "${YELLOW}Step 5: Testing console version${NC}"
rm -f log.c log 2>/dev/null || true

if harbour log.prg -n -w0 && gcc log.c -olog; then
    echo -e "${GREEN}SUCCESS: Console version build passed${NC}"
    if [ -f "log" ]; then
        echo "Console executable created successfully"
    fi
else
    echo -e "${RED}FAIL: Console version build failed${NC}"
    exit 1
fi

# 6. 测试清理
echo -e "${YELLOW}Step 6: Testing cleanup${NC}"
rm -f *.c *.o logw log 2>/dev/null || true
echo -e "${GREEN}SUCCESS: Cleanup completed${NC}"

# 7. 恢复原始环境
export HB_ROOT=$OLD_HB_ROOT
export HWGUI_ROOT=$OLD_HWGUI_ROOT

echo ""
echo -e "${GREEN}=== All Tests Passed! ===${NC}"
echo ""
echo "The minimal environment setup is working correctly."
echo "You can now use:"
echo "  ./simple_build.sh logw    # Build GUI version"
echo "  ./simple_build.sh log     # Build console version"
echo "  ./simple_build.sh clean   # Clean build files"