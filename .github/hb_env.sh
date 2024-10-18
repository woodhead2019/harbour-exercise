#!/bin/bash

# 设置 Harbour 环境变量
echo "Setting up Harbour environment..."
echo $(pwd)

# 设置环境变量
export HB_INSTALL_PREFIX="$HOME/hb/harbour"

# 设置 PATH 环境变量
#export PATH="$GIT_PATH:$C_COMPILER_PATH:$PATH"
#export HB_BIN_PATH="~/hb/harbour/bin"
#export PATH="$HB_BIN_PATH:$PATH"

# 设置编译器和库路径
#export C_COMPILER_PATH="F:/q/C/TDM-GCC-32/bin"
#export C_INCLUDE_PATH="F:/q/C/BCC582/include:F:/Harbour/include"
#export C_LIB_PATH="F:/Harbour/lib:F:/q/C/BCC582/lib:F:/q/C/BCC582/lib/psdk"

# 设置 Harbour 编译选项
export HB_USER_PRGFLAGS="-l-"
export HB_USER_CFLAGS="-fPIC"

export HB_BUILD_DYN="no"
#export HB_BUILD_IMPLIB="yes"
export HB_BUILD_VERBOSE="yes"
#export HB_BUILD_CONTRIBS="yes"
export HB_BUILD_CONTRIB_DYN="no"
#export HB_BUILD_STRIP="all"
#export HB_BUILD_3RDEXT="yes"
#export HB_BUILD_NOGPLLIB="no"
#export HB_BUILD_POSTRUN="hbtest"

# 设置 Harbour 路径
#export HB_PATH="f:/q/harbour"

# 设置其他依赖路径
#export HB_WITH_ADS="$HOME/hb/3rd_pkg/Advantage 12.0/acesdk"
#export HB_WITH_BLAT="$HOME/hb/3rd_pkg/blat326/full/source"
#export HB_WITH_MYSQL="$HOME/hb/3rd_pkg/mysql-connector-c-6.1.6-win32/include"
#export HB_WITH_OCILIB="$HOME/hb/3rd_pkg/ocilib/include"

#export HB_WITH_OPENSSL="$HOME/hb/3rd_pkg/openssl-3.3.2/include"
#export HB_STATIC_OPENSSL=yes
#export HB_WITH_CURL="$HOME/hb/3rd_pkg/curl-curl-8_10_1/include"
#export HB_STATIC_CURL=yes    

#export HB_WITH_ZLIB="$HOME/hb/3rd_pkg/zlib-1.3.1"
#export HB_WITH_ZLIB=local
#export HB_WITH_PCRE="$HOME/hb/3rd_pkg/pcre-8.45"
export HB_WITH_PCRE=local
#export HB_WITH_PNG=local
#export HB_WITH_JPEG=local

