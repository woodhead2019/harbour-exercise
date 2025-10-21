#!/bin/bash
set -e
# 颜色定义
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; NC='\033[0m'
log()  { echo -e "${GREEN}[$(date '+%H:%M:%S')] $1${NC}"; }
warn() { echo -e "${YELLOW}[$(date '+%H:%M:%S')] ⚠️  $1${NC}"; }
err()  { echo -e "${RED}[$(date '+%H:%M:%S')] ✘  $1${NC}"; }

log "===== 0. 清理旧文件 ====="
rm -f dos.img FD13-LIVE.img djgpp-linux64-gcc1210.zip harbour-3.2.0-dos-djgpp.zip

log "===== 1. 创建空白硬盘 ====="
qemu-img create -f raw dos.img 200M
ls -lh dos.img

log "===== 2. 下载 FreeDOS 1.3 Live（带进度）====="
wget -q --show-progress -O FD13-LIVE.img \
  https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.3/official/FD13-LIVE.img

log "===== 3. 下载 DJGPP 2.05 gcc12 ====="
wget -q --show-progress -O djgpp-linux64-gcc1210.zip \
  https://github.com/andrewwutw/build-djgpp/releases/download/v3.0/djgpp-linux64-gcc1210.zip
unzip -q djgpp-linux64-gcc1210.zip && log "✔ DJGPP 解压完成"

log "===== 4. 下载 Harbour 3.2 for DJGPP ====="
wget -q --show-progress -O harbour-3.2.0-dos-djgpp.zip \
  https://github.com/harbour/core/releases/download/v3.2.0/harbour-3.2.0-dos-djgpp.zip
unzip -q harbour-3.2.0-dos-djgpp.zip && log "✔ Harbour 解压完成"

log "===== 5. 自动分区（fdisk）====="
qemu-system-i386 -m 16 -drive file=dos.img,format=raw -drive file=FD13-LIVE.img,media=disk \
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
log "✔ 分区结束"

log "===== 6. 格式化并复制系统文件 ====="
qemu-system-i386 -m 16 -drive file=dos.img,format=raw -drive file=FD13-LIVE.img,media=disk \
  -boot c -nographic <<EOF
format c: /q /v:FREEDOS
sys c:
xcopy /s /e a:\*.* c:\
EOF
log "✔ 系统复制完成"

log "===== 7. 挂载虚拟盘并拷贝 DJGPP/Harbour ====="
mkdir -p /tmp/mnt
sudo mount -o loop,offset=32256 dos.img /tmp/mnt
sudo cp -r djgpp /tmp/mnt/
sudo cp -r harbour /tmp/mnt/
sudo umount /tmp/mnt
log "✔ 拷贝完成"

log "===== 8. 写入 autoexec.bat ====="
printf 'SET PATH=C:\\DJGPP\\BIN;C:\\HARBOUR\\BIN;%%PATH%%\nSET DJGPP=C:\\DJGPP\\DJGPP.ENV\n' | \
  dd of=dos.img bs=1 seek=1048576 conv=notrunc
log "✔ 环境变量写入完成"

log "===== 9. 校验镜像 ====="
ls -lh dos.img
file dos.img

log "===== 10. 清理临时文件 ====="
rm -f FD13-LIVE.img djgpp-linux64-gcc1210.zip harbour-3.2.0-dos-djgpp.zip
rm -rf djgpp harbour

log "🎉 DOS 编译环境镜像制作完成！"
