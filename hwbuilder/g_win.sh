#!/bin/bash
export HB_ROOT=$HOME/hb/harbour

export HRB_BIN=$HB_ROOT/bin/linux/gcc
export HRB_INC=$HB_ROOT/include
export HRB_LIB=$HB_ROOT/lib/linux/gcc
export HRB_EXE=$HRB_BIN/harbour

export SYSTEM_LIBS="-lm -lgpm"
export HARBOUR_LIBS="-lhbdebug -lhbvm -lhbrtl -lgtcgi -lgttrm -lhbdebug -lhblang -lhbrdd -lhbmacro -lhbpp -lrddntx -lrddcdx -lrddfpt -lhbsix -lhbcommon -lhbcpage"
export HWGUI_LIBS="-lhwgui -lprocmisc -lhbxml -lhwgdebug"
export HWGUI_ROOT=$HOME/hb/hwgui
export HWGUI_INC=$HWGUI_ROOT/include
export HWGUI_LIB=$HWGUI_ROOT/lib/linux/gcc

# ===== 64位 Windows 交叉编译 =====
# 目标平台
export HB_PLATFORM=win
# 工具链名字
export HB_COMPILER=mingw64
# 交叉前缀
export HB_CCPREFIX=x86_64-w64-mingw32ucrt-

# GUI 版本编译
# $HRB_BIN/hbmk2 -ohwb hwbc.prg -D__GUI -L$HWGUI_ROOT/lib/win/mingw64 -lhwgui -lprocmisc -lhbxml -lhwgdebug -trace
$HRB_BIN/hbmk2 -ohwb hwb.hbp   -D__GUI  -trace

# 命令行版本编译
$HRB_BIN/hbmk2 -ohwbc.exe hwbc.prg
