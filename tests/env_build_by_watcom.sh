#!/usr/bin/env bash
# 仅对非交互生效
[[ $- == *i* ]] || set -euo pipefail

[[ ${BASH_SOURCE[0]} == "$0" ]] &&
  { echo "ERROR: 请用 'source ${BASH_SOURCE[0]}' 加载本脚本"; exit 1; }

#-----------------------------------------------------------------------------
# 0. C编译器
#-----------------------------------------------------------------------------
#readonly OWROOT=$HOME/hb/open-watcom-v2
readonly OWROOT=$HOME/hb/watcom
#export WATCOM=$OWROOT/rel
export WATCOM=$OWROOT
export EDPATH=$WATCOM/eddat
#export PATH=$OWROOT/rel/binl64:$PATH   # 64 位 Linux 宿主工具
export PATH=$WATCOM/binl64:$PATH   # 64 位 Linux 宿主工具
export INCLUDE=$WATCOM/lh              # linux 头文件
export LIB=$WATCOM/lib386/liux

export WIPFC=$WATCOM/wipfc
#-----------------------------------------------------------------------------
# 1. harbour
#-----------------------------------------------------------------------------
readonly HB_ROOT="$HOME/hb/hbwatcom"          # Harbour 最终安装目录
readonly HB_3RD="$HOME/hb/3rd_pkg"          # 你自己集中存放第三方库的目录
export HB_INSTALL_PREFIX="$HB_ROOT"         # Harbour Makefile 读取
#export HB_HOST_INC=$HB_ROOT/include
export HB_PLATFORM=linux
export HB_COMPILER=watcom

