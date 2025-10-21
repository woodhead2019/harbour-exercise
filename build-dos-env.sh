#!/bin/bash
set -e
GREEN='\033[0;32m'; NC='\033[0m'
log() { echo -e "${GREEN}[$(date '+%H:%M:%S')] $1${NC}"; }

log "===== 0. 清理 ====="
rm -f dos.img FD14-LIVE.iso

log "===== 1. 创建 2 GB 空白硬盘 ====="
qemu-img create -f raw dos.img 2000M
ls -lh dos.img

log "===== 2. 下载 FreeDOS 1.4 LiveCD ====="
wget -q --show-progress -O FD14-LiveCD.zip \
  https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.4/FD14-LiveCD.zip
unzip -q FD14-LiveCD.zip   # 得到 FD14BOOT.img + FD14LIVE.iso
ls -lh FD14BOOT.img FD14LIVE.iso

log "===== 3. 从 CD 启动 → 自动分区 → 格式化 → 写系统 ====="
# 用 LiveCD 当 cdrom，从光盘启动；出现 Install 菜单后选 "Install to harddisk"
# 下面自动发送按键序列（↓ 回车，回车，回车，fdisk，回车）
# 生成按键流（ESC + 命令）
cat > keys.txt <<'KEYS'

fdisk
n
1
1
y
$(printf '\033')
$(printf '\033')
$(printf '\033')
sleep 2
format e: /q /v:FREEDOS
sleep 1
sys e:
sleep 1
xcopy /s /e a:\*.* e:\
sleep 2
fdapm /poweroff
KEYS



# 先睡 70 s（≥ 60 s 倒计时 + 缓冲），再一次性灌入按键
timeout 90s bash -c "
  { sleep 70 && cat keys.txt; } | \
  qemu-system-i386 -m 16 -drive file=dos.img,format=raw -cdrom FD14LIVE.iso -boot d -nographic
"
log "===== 4. 首次从硬盘启动 ====="
timeout 15s qemu-system-i386 -m 16 -drive file=dos.img,format=raw -boot c \
  -nographic -serial stdio <<'EOF' || true
ver
echo FreeDOS is alive!
EOF

log "===== 5. 清理 ====="
rm -f FD14-LiveCD.zip FD14BOOT.img FD14LIVE.iso
log "🎉 FreeDOS 启动测试完成！"
ls -lh dos.img
