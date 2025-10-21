#!/bin/bash
set -e
# 颜色定义
GREEN='\033[0;32m'; YELLOW='\033[0;33m'; NC='\033[0m'
log() { echo -e "${GREEN}[$(date '+%H:%M:%S')] $1${NC}"; }

log "===== 0. 清理旧文件 ====="
rm -f dos.img FD14FULL.img FD14-FullUSB.zip djgpp*.zip harbour*.zip

log "===== 1. 创建空白硬盘 ====="
qemu-img create -f raw dos.img 200M
ls -lh dos.img

log "===== 2. 下载 FreeDOS 1.4 FullUSB 包 ====="
wget -q --show-progress -O FD14-FullUSB.zip \
  https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.4/FD14-FullUSB.zip

log "===== 3. 解压得到 FD14FULL.img ====="
unzip -q FD14-FullUSB.zip && log "✔ 解压完成，镜像大小："
ls -lh FD14FULL.img

log "===== 4. 下载 DJGPP 2.05 (gcc 12.1) ====="
wget -q --show-progress -O djgpp-linux64-gcc1210.zip \
  https://github.com/andrewwutw/build-djgpp/releases/download/v3.0/djgpp-linux64-gcc1210.zip
unzip -q djgpp-linux64-gcc1210.zip && log "✔ DJGPP 解压完成"

log "===== 5. 下载 Harbour 3.2 for DJGPP ====="
wget -q --show-progress -O harbour-3.2.0-dos-djgpp.zip \
  https://github.com/harbour/core/releases/download/v3.2.0/harbour-3.2.0-dos-djgpp.zip
unzip -q harbour-3.2.0-dos-djgpp.zip && log "✔ Harbour 解压完成"

log "===== 6. 分区（fdisk 自动交互）====="
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

log "===== 7. 格式化并复制系统文件 ====="
qemu-system-i386 -m 16 -drive file=dos.img,format=raw -drive file=FD14FULL.img,media=disk \
  -boot c -nographic <<EOF
format c: /q /v:FREEDOS
sys c:
xcopy /s /e a:\*.* c:\
EOF

log "===== 8. 拷贝 DJGPP & Harbour 到虚拟盘 ====="
mkdir -p /tmp/mnt
sudo mount -o loop,offset=32256 dos.img /tmp/mnt
sudo cp -r djgpp /tmp/mnt/
sudo cp -r harbour /tmp/mnt/
sudo umount /tmp/mnt

log "===== 9. 写入 autoexec.bat ====="
printf 'SET PATH=C:\\DJGPP\\BIN;C:\\HARBOUR\\BIN;%%PATH%%\nSET DJGPP=C:\\DJGPP\\DJGPP.ENV\n' | \
  dd of=dos.img bs=1 seek=1048576 conv=notrunc

log "===== 10. 清理临时文件 ====="
rm -f FD14-FullUSB.zip FD14FULL.img djgpp*.zip harbour*.zip
rm -rf djgpp harbour

log "🎉 FreeDOS 1.4 Full + DJGPP + Harbour 环境镜像制作完成！"
ls -lh dos.img
