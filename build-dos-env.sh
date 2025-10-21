name: DOS-Harbour-CI
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: 安装 QEMU 并准备 DOS 环境
        run: |
          sudo apt-get update && sudo apt-get install -y qemu-system-x86 dosfstools
          bash ./build-dos-env.sh          # 生成 dos.img（已含 DJGPP+Harbour）

      - name: 编译 Harbour 程序
        run: |
          qemu-system-i386 -m 16 -drive file=dos.img,format=raw -boot c \
            -nographic -serial stdio <<EOF
          C:
          CD \\HARBOUR\\BIN
          hbmk2 /ws/src/hello.prg -o/hello.exe
          copy hello.exe /ws/hello.exe
          echo BUILD DONE
          exit
          EOF

      - name: 上传 DOS 可执行文件
        uses: actions/upload-artifact@v4
        with:
          name: dos-exe
          path: hello.exe
