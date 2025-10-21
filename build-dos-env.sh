#!/bin/bash
set -e
GREEN='\033[0;32m'; YELLOW='\033[0;33m'; NC='\033[0m'
log() { echo -e "${GREEN}[$(date '+%H:%M:%S')] $1${NC}"; }

log "===== 0. 清理旧文件 ====="
rm -f dos.img FD14FULL.img FD14-FullUSB.zip

log "===== 1. 创建 200 MB 空白硬盘 ====="
qemu-img create -f raw dos.img 200M
ls -lh dos.img

log "===== 2. 下载 FreeDOS 1.4 FullUSB ====="
if ! wget -q --show-progress -O FD14-FullUSB.zip \
  https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.4/FD14-FullUSB.zip; then
  echo "下载失败，终止测试"; exit 1
fi
unzip -q FD14-FullUSB.zip   # 得到 FD14FULL.img

log "===== 3. 分区（fdisk 自动）====="
qemu-system-i386 -m 16 -drive file=dos.img,format=raw -drive file=FD14FULL.img,media=disk \
  -boot c -nographic <<EOF
fdisk 1
n
p
1

t
6
a
1
w
EOF

log "===== 4. 格式化并复制系统 ====="
qemu-system-i386 -m 16 -drive file=dos.img,format=raw -drive file=FD14FULL.img,media=disk \
  -boot c -nographic <<EOF
format c: /q /v:FREEDOS
sys c:
xcopy /s /e a:\*.* c:\
EOF

log "===== 5. 首次启动 FreeDOS（无头）====="
timeout 30s qemu-system-i386 -m 16 -drive file=dos.img,format=raw -boot c \
  -nographic -serial stdio <<EOF || true
ver
echo FreeDOS is alive!
EOF

log "===== 6. 清理 ====="
rm -f FD14FULL.img FD14-FullUSB.zip

log "🎉 FreeDOS 启动测试完成！"
