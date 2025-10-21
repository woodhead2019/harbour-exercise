#!/bin/bash
set -e
[ -f dos.img ] && exit 0            # 缓存：已存在就复用

# 1. 空白硬盘
qemu-img create dos.img 200M

# 2. 下载 FreeDOS 1.3 Live（内置安装器）
wget -q https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.3/official/FD13-LIVE.img

# 3. 下载 DJGPP 2.05 gcc12 一键包
wget -q https://github.com/andrewwutw/build-djgpp/releases/download/v3.0/djgpp-linux64-gcc1210.zip

# 4. 下载 Harbour 3.2 for DJGPP
wget -q https://github.com/harbour/core/releases/download/v3.2.0/harbour-3.2.0-dos-djgpp.zip

# 5. 分区、格式化、装系统（全自动）
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

qemu-system-i386 -m 16 -drive file=dos.img,format=raw -drive file=FD13-LIVE.img,media=disk \
  -boot c -nographic <<EOF
format c: /q /v:FREEDOS
sys c:
xcopy /s /e a:\*.* c:\
EOF

# 6. 把 DJGPP 和 Harbour 拷进 C:\
mkdir -p /tmp/mnt
sudo mount -o loop,offset=32256 dos.img /tmp/mnt
sudo unzip -q djgpp-linux64-gcc1210.zip -d /tmp/mnt/
sudo unzip -q harbour-3.2.0-dos-djgpp.zip -d /tmp/mnt/
sudo umount /tmp/mnt

# 7. 写 autoexec.bat
printf 'SET PATH=C:\\DJGPP\\BIN;C:\\HARBOUR\\BIN;%%PATH%%\nSET DJGPP=C:\\DJGPP\\DJGPP.ENV\n' | \
  dd of=dos.img bs=1 seek=1048576 conv=notrunc
