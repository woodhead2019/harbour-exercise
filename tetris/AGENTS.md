# Tetris 项目文档

## 项目概述

使用 Harbour 语言和 HwGUI 库开发的俄罗斯方块游戏。

### 技术栈

- **编程语言**: Harbour 3.2.0dev
- **GUI 库**: HwGUI 2.23 dev
- **图形系统**: GTK2 (Linux)
- **编译工具**: hbmk2

### 环境要求

- Harbour 编译器: /opt/harbour/bin/
- HwGUI 库: /opt/hwgui/
- Linux 操作系统

## 项目结构

```
tetris/
├── AGENTS.md       # 项目文档
├── tetris          # 可执行文件
├── tetris.hbp      # 构建配置文件
└── tetris.prg      # 源代码
```

## 编译运行

### 编译
```bash
hbmk2 tetris.hbp
```

### 运行
```bash
./tetris
```

## 游戏控制

### 键盘操作
- **← 左箭头**: 向左移动
- **→ 右箭头**: 向右移动
- **↓ 下箭头**: 快速下落（下移一格）
- **↑ 上箭头**: 旋转方块
- **空格键**: 直接落到底部

### 菜单操作
- **游戏 → 新游戏**: 开始新游戏
- **游戏 → 显示模式 - BOARD控件**: 切换到图形模式
- **游戏 → 显示模式 - SAY控件**: 切换到简单模式
- **游戏 → 退出**: 退出游戏
- **帮助 → 操作说明**: 查看帮助信息

## 核心功能

### 1. 游戏逻辑
- **方块类型**: 7种标准俄罗斯方块（I, O, T, L, J, S, Z）
- **碰撞检测**: 边界检测和方块碰撞检测
- **行消除**: 自动检测并清除满行
- **得分系统**: 消除行数越多，得分越高
- **等级提升**: 每1000分升一级，速度加快

### 2. 图形显示

#### 两种显示模式

**BOARD 控件模式**（推荐）:
- 使用 BOARD 控件 + ON PAINT 回调
- 系统自动提供 hDC，无需手动调用 hwg_GetDC
- 可以绘制填充矩形、边框、圆等基本图形
- 图形效果好，有黑色边框
- 性能高，一次绘制整个游戏画面

**SAY 控件模式**（简单）:
- 使用 200 个 SAY 控件组成的网格
- 通过修改控件的背景颜色显示方块
- 控件紧密排列，无间隙，无边框
- 简单稳定，但功能有限

### 3. 输入处理
- **SET KEY**: 使用 HwGUI 的 SET KEY 命令处理键盘输入
- **VK 常量**: 使用 VK_LEFT, VK_RIGHT 等常量而不是数字键码
- **DIALOG 类型**: 必须使用 DIALOG 而不是 WINDOW（SET KEY 只支持 DIALOG）

### 4. 定时器
- **自动下落**: 使用 SET TIMER 实现定时自动下落
- **速度控制**: 根据等级调整下落速度
- **代码块**: ACTION 必须使用代码块 `{ || TimerTick() }`

## 重要技术要点

### 1. BOARD 控件绘图方法（正确方式）

#### 为什么使用 BOARD 控件？

参考了 `/home/woodhead/cchess/xiangqiw.prg`（中国象棋）的正确实现方式：
- BOARD 控件的 ON PAINT 回调会自动提供 hDC
- 使用 hDC 进行绘图，不会导致段错误
- 可以绘制图片、线条、圆、矩形等基本图形
- 符合标准的 Windows/GUI 编程模式

#### 实现方法

```harbour
// 1. 创建 BOARD 控件
@ 10, 70 BOARD oGameBoard ;
   SIZE (BOARD_WIDTH * BLOCK_SIZE), (BOARD_HEIGHT * BLOCK_SIZE) ;
   ON PAINT {|o,h|BoardPaint(o,h)}

// 2. 绘图函数接收系统提供的 hDC
STATIC FUNCTION BoardPaint(o, hDC)
   // 3. 使用 hDC 绘图（不需要 hwg_GetDC）
   oBrush := HBrush():Add(nColor)
   hwg_Rectangle_Filled(hDC, x, y, x + BLOCK_SIZE, y + BLOCK_SIZE, .F., oBrush:handle)
   oBrush:Release()
RETURN NIL

// 4. 触发重绘
FUNCTION RefreshBoard()
   UpdateTitle()
   hwg_Invalidaterect(oGameBoard:handle)
RETURN NIL
```

#### 关键要点

- **系统自动提供 hDC**: ON PAINT 回调会自动传入设备上下文
- **不需要 hwg_GetDC**: 系统提供 hDC，无需手动获取
- **使用画刷 handle**: `hwg_Rectangle_Filled` 需要传入画刷的 handle，而不是颜色值
- **释放资源**: 使用完后必须调用 `oBrush:Release()` 和 `oPen:Release()`

### 2. 错误方法的记录

#### PANEL + ON PAINT（失败）
```harbour
// 这种方法会导致段错误
@ 10, 70 PANEL oPanel ;
   SIZE ... ;
   ON PAINT {|o,h|BoardPaint(o,h)}

// 在 BoardPaint 中调用 hwg_GetDC 会导致段错误
hDC := hwg_GetDC(oPanel:handle)
```

**失败原因**: PANEL 控件的 ON PAINT 回调在 Linux/GTK 上不稳定

#### hwg_GetDC 在定时器回调中使用（失败）
```harbour
FUNCTION TimerTick()
   LOCAL hDC
   hDC := hwg_GetDC(oMainWindow:handle)
   // 使用 hDC 绘图...
   hwg_ReleaseDC(oMainWindow:handle, hDC)
RETURN NIL
```

**失败原因**: 在定时器回调中调用 hwg_GetDC 会导致段错误

#### SAY 控件网格（简单但有限）
```harbour
// 创建 200 个 SAY 控件
@ x, y SAY oBlock CAPTION "" ;
   SIZE BLOCK_SIZE, BLOCK_SIZE ;
   BACKCOLOR 0xFFFFFF

// 更新颜色
oBlock:SetColor(, nColor)
```

**特点**: 
- ✅ 简单稳定，不会崩溃
- ✅ HwGUI 自动重绘，无需手动刷新
- ❌ 只能显示颜色，不能绘制线条或图形
- ❌ 性能较低（200个控件）

### 3. SET KEY 用法

**重要**: 在 HwGUI 中，SET KEY 只支持 DIALOG 类型，不支持 WINDOW 类型。

```harbour
// 正确 - 使用 DIALOG
INIT DIALOG oMainWindow ;
   TITLE "俄罗斯方块" ;
   ...

// 错误 - 使用 WINDOW（SET KEY 不生效）
INIT WINDOW oMainWindow ;
   TITLE "俄罗斯方块" ;
   ...
```

**使用 VK 常量**:
```harbour
SET KEY 0, VK_LEFT TO KeyLeft()
SET KEY 0, VK_RIGHT TO KeyRight()
SET KEY 0, VK_DOWN TO KeyDown()
SET KEY 0, VK_UP TO KeyUp()
SET KEY 0, VK_SPACE TO KeySpace()
```

### 4. 定时器用法

**使用代码块**:
```harbour
SET TIMER oTimer OF oMainWindow VALUE nSpeed ACTION { || TimerTick() }
```

**避免频繁重置定时器**:
```harbour
FUNCTION LockTetromino()
   STATIC nLastSpeed := 0
   
   // 只在速度改变时才重新设置定时器
   IF nSpeed != nLastSpeed
      IF oTimer != NIL
         oTimer:End()
      ENDIF
      SET TIMER oTimer OF oMainWindow VALUE nSpeed ACTION { || TimerTick() }
      nLastSpeed := nSpeed
   ENDIF
RETURN NIL
```

### 5. BGR 颜色格式

HwGUI 使用 BGR 格式，而不是 RGB：

```harbour
// BGR 宏定义
#define BGR(r,g,b)  ((r) + ((g)*256) + ((b)*65536))

// 方块颜色
STATIC aColors := { ;
   BGR(0,255,255), ;  // 青色 - I
   BGR(255,255,0), ;  // 黄色 - O
   BGR(255,0,255), ;  // 紫色 - T
   BGR(255,165,0), ;  // 橙色 - L
   BGR(0,0,255), ;    // 蓝色 - J
   BGR(0,255,0), ;    // 绿色 - S
   BGR(255,0,0)  ;    // 红色 - Z
}
```

### 6. 刷新机制

#### BOARD 控件模式

```harbour
FUNCTION RefreshBoard()
   UpdateTitle()
   hwg_Invalidaterect(oGameBoard:handle)
RETURN NIL
```

**刷新流程**:
1. 调用 `RefreshBoard()`
2. `hwg_Invalidaterect(oGameBoard:handle)` 标记需要重绘的区域
3. 系统自动触发 ON PAINT 回调
4. 系统自动调用 `BoardPaint(o, hDC)`
5. 在 `BoardPaint` 中使用 hDC 重新绘制整个游戏画面

#### SAY 控件模式

```harbour
FUNCTION RefreshBoard()
   UpdateTitle()
   DrawGame()
RETURN NIL

FUNCTION DrawGame()
   // 更新 SAY 控件的颜色
   oBlock:SetColor(, nColor)
RETURN NIL
```

**刷新流程**:
1. 调用 `RefreshBoard()`
2. 直接调用 `DrawGame()`
3. 遍历所有 SAY 控件，更新背景颜色
4. HwGUI 自动重绘控件

### 7. 两种模式对比

| 特性 | BOARD 控件模式 | SAY 控件模式 |
|------|---------------|--------------|
| **创建方式** | `@ x,y BOARD ... ON PAINT {...}` | `@ x,y SAY ...` (循环创建200个) |
| **刷新方式** | `hwg_Invalidaterect()` | `oBlock:SetColor(, nColor)` |
| **触发机制** | 系统触发 ON PAINT 回调 | 控件自动重绘 |
| **绘图内容** | 可以绘制任何图形 | 只能显示颜色 |
| **获取 hDC** | 系统自动提供 | 不需要 |
| **性能** | 高（一次绘制） | 中（200个控件） |
| **图形效果** | 好（有边框、颜色填充） | 一般（只有颜色） |
| **稳定性** | 标准 GUI 方式 | 简单稳定 |

## 常见问题

### 1. ON OTHER MESSAGES 在 Linux/GTK 上不支持

**问题**: SET KEY 不生效，键盘输入没有反应。

**原因**: ON OTHER MESSAGES 在 Linux/GTK 上不支持（参考 `/home/woodhead/hb/hwgui-code/hwgui/samples/demoonother.prg`）。

**解决**: 使用 SET KEY 命令替代 ON OTHER MESSAGES。

### 2. 窗口标题不更新

**问题**: 点击"新游戏"后，窗口标题没有更新。

**原因**: 使用 `oMainWindow:Title := ...` 在某些情况下不生效。

**解决**: 使用 `hwg_SetWindowText(oMainWindow:handle, cTitle)`。

### 3. 定时器不工作

**问题**: 方块不自动下落。

**原因**: 
- ACTION 没有使用代码块
- 只在消除行时重新设置定时器

**解决**: 
- 使用代码块 `{ || TimerTick() }`
- 在每次方块固定后都重新设置定时器（检查速度是否改变）

### 4. 速度变化导致问题

**问题**: 消除行后速度变快，然后恢复原速。

**原因**: 频繁重新设置定时器导致速度不稳定。

**解决**: 使用静态变量 `nLastSpeed` 记录上一次速度，只在速度改变时才重新设置定时器。

### 5. 绘图导致段错误

**问题**: 使用 `hwg_GetDC` 导致段错误。

**原因**: 
- PANEL 控件的 ON PAINT 回调不稳定
- 在定时器回调中调用 `hwg_GetDC` 会段错误

**解决**: 使用 BOARD 控件 + ON PAINT，系统自动提供 hDC。

## 代码规范

### 命名规范

- **函数名**: 驼峰命名法（如 `InitBoard`, `KeyLeft`）
- **变量名**: 驼峰命名法（如 `nScore`, `lGameOver`）
- **常量**: 全大写（如 `BOARD_WIDTH`, `BLOCK_SIZE`）
- **全局变量**: 小写字母前缀 + 驼峰命名法（如 `oMainWindow`, `aBoard`）
  - `o` - 对象
  - `a` - 数组
  - `n` - 数字
  - `l` - 逻辑
  - `c` - 字符串

### 编码规范

- **LOCAL 声明**: 必须在函数开头声明，在任何可执行语句之前
- **CASE 语句**: 必须使用多行格式，不能使用单行格式
- **注释**: 每个函数、常量、关键代码都要有注释
- **代码自文档化**: 代码本身应该清晰易懂，注释说明"为什么"而不是"是什么"

## 游戏状态管理

### 游戏状态变量

```harbour
STATIC nScore := 0      // 得分
STATIC nLevel := 1      // 等级
STATIC lGameOver := .F. // 游戏结束标志
STATIC lGameStarted := .F.  // 游戏是否已开始
STATIC nDisplayMode := 1  // 显示模式：1=BOARD控件，2=SAY控件
```

### 游戏板数据

```harbour
STATIC aBoard := {}     // 20x10 数组，0=空，非0=方块类型
```

### 当前方块数据

```harbour
STATIC nCurrentX        // X 坐标（1-10）
STATIC nCurrentY        // Y 坐标（1-20）
STATIC nCurrentType     // 方块类型（1-7）
STATIC aCurrentShape    // 方块形状（4x4 矩阵）
```

## 技术总结

### 正确的绘图方法

**BOARD 控件 + ON PAINT**:
- ✅ 标准 GUI 编程模式
- ✅ 系统自动提供 hDC
- ✅ 可以绘制任何图形
- ✅ 性能高
- ✅ 稳定可靠

**参考实现**: `/home/woodhead/cchess/xiangqiw.prg`（中国象棋）

### 错误的绘图方法

**PANEL + ON PAINT + hwg_GetDC**:
- ❌ 会导致段错误
- ❌ ON PAINT 回调不稳定
- ❌ 不推荐使用

**SAY 控件网格**:
- ⚠️ 简单但有限
- ⚠️ 只能显示颜色
- ⚠️ 性能较低
- ✅ 不会崩溃

### HwGUI 自动重绘机制

**HwGUI 控件属性修改会自动触发重绘**:
```harbour
oBlock:SetColor(, nColor)  // 自动重绘，无需额外调用
```

**不需要手动刷新**:
- ❌ `hwg_InvalidateRect()` - 只用于 BOARD 控件
- ❌ `hwg_RedrawWindow()` - 不稳定
- ❌ `hwg_Refresh()` - 不需要

## 项目完成状态

✅ 游戏逻辑完整  
✅ 两种显示模式（BOARD 控件和 SAY 控件）  
✅ 键盘输入处理  
✅ 自动下落功能  
✅ 行消除和得分系统  
✅ 等级提升和速度控制  
✅ 代码自文档化  
✅ 文档完整  

## 参考资料

- HwGUI 源码: `/home/woodhead/hb/hwgui-code/hwgui/`
- HwGUI 示例: `/home/woodhead/hb/hwgui-code/hwgui/samples/`
- 中国象棋示例: `/home/woodhead/cchess/xiangqiw.prg`
