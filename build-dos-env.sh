#!/bin/bash
set -e
GREEN='\033[0;32m'; YELLOW='\033[0;33m'; NC='\033[0m'
log() { echo -e "${GREEN}[$(date '+%H:%M:%S')] $1${NC}"; }

log "===== 0. 清理 ====="
rm -f dos.img FD14FULL.img FD14-FullUSB.zip

log "===== 1. 创建空白硬盘 ====="
qemu-img create -f raw dos.img 200M

log "===== 2. 下载 FreeDOS 1.4 FullUSB ====="
wget -q --show-progress -O FD14-FullUSB.zip \
  https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.4/FD14-FullUSB.zip
unzip -q FD14-FullUSB.zip   # 得到 FD14FULL.img

log "===== 3. 从 A: 启动 → 分区 → 格式化 → 写系统 ====="
# ① 先启动软盘镜像（FD14FULL.img 当 A:）
qemu-system-i386 -m 16 -drive file=dos.img,format=raw -drive file=FD14FULL.img,media=disk,index=1,format=raw \
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
timeout 20s qemu-system-i386 -m 16 -drive file=dos.img,format=raw -boot c \
  -nographic -serial stdio <<'EOF' || true
ver
echo FreeDOS is alive!
EOF

log "===== 5. 清理 ====="
rm -f FD14FULL.img FD14-FullUSB.zip
log "🎉 FreeDOS 启动测试完成！"
