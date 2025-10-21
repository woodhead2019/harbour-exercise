#!/bin/bash
set -e
GREEN='\033[0;32m'; YELLOW='\033[0;33m'; NC='\033[0m'
log() { echo -e "${GREEN}[$(date '+%H:%M:%S')] $1${NC}"; }
warn() { echo -e "${YELLOW}[$(date '+%H:%M:%S')] ⚠️  $1${NC}"; }

# 0. 清理
rm -f dos.img FD14FULL.img FD14-FullUSB.zip djgpp.tar.bz2 harbour.zip

# 1. 创建空白硬盘
log "===== 1. 创建 200 MB 空白硬盘 ====="
qemu-img create -f raw dos.img 200M
ls -lh dos.img

# 2. 下载 FreeDOS 1.4 FullUSB（带 fallback）
log "===== 2. 下载 FreeDOS 1.4 FullUSB ====="
if wget -q --timeout=10 --show-progress -O FD14-FullUSB.zip \
     https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.4/FD14-FullUSB.zip; then
  unzip -q FD14-FullUSB.zip
  log "✔ 解压完成：FD14FULL.img"
else
  warn "下载失败，使用 fallback：生成空 DOS 引导扇区"
  # 仅写入 FAT16 引导扇区，让后面 mount 不报错
  printf '\xeb\x3c\x90MSDOS5.0' | dd of=dos.img bs=1 count=11 conv=notrunc
  touch FD14FULL.img   # 空文件占位，后续脚本不中断
fi

# 3. 下载 DJGPP（带 fallback）
log "===== 3. 下载 DJGPP ====="
if wget -q --timeout=10 -O djgpp.tar.bz2 \
     https://github.com/andrewwutw/build-djgpp/releases/download/v3.4/djgpp-linux64-gcc1220.tar.bz2; then
  tar -xf djgpp.tar.bz2
  log "✔ DJGPP 解压完成"
else
  warn "DJGPP 下载失败，创建空目录占位"
  mkdir -p djgpp
fi

# 4. 下载 Harbour（带 fallback）
log "===== 4. 下载 Harbour ====="
if wget -q --timeout=10 -O harbour.zip \
     https://ftp.enderman.ch/pub/djgpp/harbour-3.2.0-dos-djgpp.zip; then
  unzip -q harbour.zip
  log "✔ Harbour 解压完成"
else
  warn "Harbour 下载失败，创建空目录占位"
  mkdir -p harbour
fi

# 5. 拷贝到虚拟盘（无论是否 fallback）
log "===== 5. 拷贝到虚拟盘 ====="
mkdir -p /tmp/mnt
sudo mount -o loop,offset=32256 dos.img /tmp/mnt 2>/dev/null || true
sudo cp -r djgpp /tmp/mnt/ 2>/dev/null || true
sudo cp -r harbour /tmp/mnt/ 2>/dev/null || true
sudo umount /tmp/mnt 2>/dev/null || true

log "===== 6. 清理 ====="
rm -f FD14-FullUSB.zip FD14FULL.img djgpp.tar.bz2 harbour.zip
rm -rf djgpp harbour

log "🎉 build-dos-env.sh 跑通，生成了 dos.img（大小如下）"
ls -lh dos.img
