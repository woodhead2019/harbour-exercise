# CLLOG 简化构建指南

本指南介绍如何用最少的设置构建CLLOG项目。

## 快速开始

### 前提条件

1. **Harbour编译器** - 已安装并可执行
2. **HwGUI库** - 已安装GTK+版本
3. **GTK+ 2.0** - 开发库（Linux系统）
4. **GCC编译器** - 标准C编译器

### 自动检测构建（推荐）

我们创建了自动化脚本来最小化手动配置：

```bash
# 1. 进入源代码目录
cd ~/demoapp/cllog-code/trunk/src

# 2. 运行最小环境设置
./minimal_env_setup.sh

# 3. 使用简单构建脚本
./simple_build.sh logw    # 构建GUI版本
./simple_build.sh log     # 构建控制台版本
./simple_build.sh clean   # 清理构建文件
```

### 手动最小设置

如果自动检测失败，只需设置两个环境变量：

```bash
# 1. 设置Harbour路径（如果不在标准位置）
export HB_ROOT=/path/to/harbour

# 2. 设置HwGUI路径
export HWGUI_ROOT=/path/to/hwgui

# 3. 构建
cd ~/demoapp/cllog-code/trunk/src
hbmk2 logw.hbp
```

## 环境变量说明

### 最小必需变量

| 变量 | 说明 | 示例 |
|------|------|------|
| `HB_ROOT` | Harbour安装根目录 | `/home/user/harbour` |
| `HWGUI_ROOT` | HwGUI安装根目录 | `/home/user/hwgui` |

### 自动推导变量

以下变量可由构建系统自动推导，无需手动设置：

- `HRB_BIN` - Harbour可执行文件目录
- `HRB_INC` - Harbour头文件目录
- `HRB_LIB` - Harbour库文件目录
- `HWGUI_INC` - HwGUI头文件目录
- `HWGUI_LIB` - HwGUI库文件目录

## 构建方法对比

### 方法1：hbmk2（推荐）
```bash
# 最简命令
hbmk2 logw.hbp

# 带选项
hbmk2 logw.hbp -n0 -w0  # 无警告，无行号
```

### 方法2：传统脚本
```bash
./hwmk.sh logw  # 使用项目的完整构建脚本
```

### 方法3：手动编译
```bash
# 编译Harbour代码
harbour logw.prg -n -w0

# 链接C代码
gcc logw.c -ologw $(pkg-config --cflags --libs gtk+-2.0) -lhwgui
```

## 故障排除

### 问题：Harbour未找到
```bash
# 检查Harbour安装
which harbour
harbour -h

# 如果未安装，参考Harbour官方安装指南
```

### 问题：HwGUI未找到
```bash
# 搜索HwGUI位置
find /home -name "hwgui.hbc" 2>/dev/null

# 手动设置路径
export HWGUI_ROOT=/找到的路径
```

### 问题：GTK+未找到
```bash
# 检查GTK+安装
pkg-config --exists gtk+-2.0 && echo "OK" || echo "Missing"

# Ubuntu/Debian安装
sudo apt-get install libgtk2.0-dev

# Fedora/RHEL安装
sudo yum install gtk2-devel
```

### 问题：构建失败
```bash
# 运行测试脚本
./test_minimal_build.sh

# 检查详细错误
hbmk2 logw.hbp -v  # 详细输出
```

## 构建脚本功能

### simple_build.sh
- 自动检测Harbour和HwGUI路径
- 支持GUI和Console版本构建
- 内置清理功能
- 调试模式支持

### minimal_env_setup.sh
- 交互式环境配置
- 创建便捷别名
- 自动路径推导
- 一次性设置

### test_minimal_build.sh
- 验证环境配置
- 测试构建过程
- 检查依赖关系
- 自动化验证

## 性能优化

### 快速构建选项
```bash
# 禁用所有警告和调试
hbmk2 logw.hbp -n0 -w0 -s

# 仅编译修改的文件
hbmk2 logw.hbp -n0 -w0 -a
```

### 并行构建
```bash
# 使用多核编译（如果支持）
export MAKEFLAGS="-j$(nproc)"
hbmk2 logw.hbp
```

## 平台特定说明

### Linux
- 需要GTK+ 2.0开发包
- 标准GCC工具链
- 支持pkg-config

### macOS
- 需要Xcode命令行工具
- GTK+可通过MacPorts或Homebrew安装
- 特殊编译标志已内置

### Windows
- 使用MinGW或MSYS2
- HwGUI提供Windows特定库
- 批处理构建脚本可用

## 下一步

构建成功后，您可以：
1. 运行应用程序：`./logw`
2. 配置个人设置
3. 导入现有日志数据
4. 探索业余无线电日志功能

如需更多帮助，请查看项目文档或运行测试脚本。