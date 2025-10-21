#!/bin/bash
set -e
# 颜色定义
GREEN='\033[0;32m'; YELLOW='\033[0;33m'; NC='\033[0m'
log() { echo -e "${GREEN}[$(date '+%H:%M:%S')] $1${NC}"; }

log "===== 1. 创建空白硬盘 ====="
qemu-img create -f raw dos.img 2000M
ls -lh dos.img

log "===== 2. 下载 FreeDOS 1.4 LiveCD ====="
wget -q --show-progress -O FD14-LiveCD.zip \
  https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.4/FD14-LiveCD.zip
unzip -q FD14-LiveCD.zip   # 得到 FD14BOOT.img
ls -lh FD14BOOT.img

log "===== 3. 从 A: 启动 → 分区 → 格式化 → 写系统 ====="
# FD14BOOT.img 当软盘 A:，dos.img 当硬盘 C:
qemu-system-i386 -m 16 \
  -drive file=dos.img,format=raw,index=0,media=disk \
  -drive file=FD14BOOT.img,format=raw,index=1,media=disk \
  -boot a -nographic <<'EOF'
fdisk 1
n
p
1

t
6
a
1
w
format c: /q /v:FREEDOS
sys c:
xcopy /s /e a:\*.* c:\
EOF

log "===== 4. 首次从硬盘启动 ====="
timeout 15s qemu-system-i386 -m 16 -drive file=dos.img,format=raw -boot c \
  -nographic -serial stdio <<'EOF' || true
ver
echo FreeDOS is alive!
EOF

log "===== 5. 清理 ====="
rm -f FD14-LiveCD.zip FD14BOOT.img
log "🎉 FreeDOS 启动测试完成！"
ls -lh dos.img
