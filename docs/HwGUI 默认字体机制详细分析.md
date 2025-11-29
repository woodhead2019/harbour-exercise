HwGUI 默认字体机制详细分析

  基于我对 HwGUI 源码的深入研究，我可以为您提供 HwGUI 默认字体机制的详细解答：

  1. HFont 类定义

  - 位置: drawwidg.prg 文件中定义了 HFont 类
  - 作用: 管理字体对象，提供字体创建、管理和操作功能

  2. 默认字体设置

  根据源码分析，HwGUI 有以下默认字体设置：

  A. 普通控件默认字体：
  - 在 hhyper.prg 中，当控件没有父窗口字体可用时，默认使用："Serif", 0, 12
  - 这表明 HwGUI 有内部的默认字体机制

  B. 对话框函数默认字体：
  - hwg_MsgGet() 函数使用：HFont():Add( "Sans", 0, 12 )
  - hwg_WChoice() 函数使用：HFont():Add( "Times", 0, 14 )

  3. 字体创建机制

  在 drawwidg.prg 的 Add 方法中：
  nHeight := iif( nHeight == Nil, 13, Abs( nHeight ) )
  - 如果未指定字体高度，默认使用 13（经测试调整后可能是 10，因为 Linux 平台会减 3）

  4. 关键发现：窗口无显式字体时的情况

  您的问题非常准确！当窗口没有显式字体设置时：
  - 窗口的 oFont 属性确实为 NIL
  - 但控件仍然能正常显示，这是因为：
    a. 底层 GTK 系统：GTK 本身会为没有显式字体的控件提供系统默认字体
    b. HwGUI 机制：当控件初始化时（INIT()
  方法），如果控件本身没有字体，会尝试从父窗口继承。如果父窗口也没有字体（oFont 为 NIL），则会使用 GTK 的默认字体

  5. 实际测试结果

  在 hcontrol.prg 的 INIT() 方法中，我们可以看到：
  IF ::oFont != Nil
     hwg_SetCtrlFont( ::handle,, ::oFont:handle )
  ELSEIF ::oParent:oFont != Nil
     ::oFont := ::oParent:oFont
     hwg_SetCtrlFont( ::handle,, ::oParent:oFont:handle )
  ENDIF

  如果以上两个条件都不满足（即控件和父窗口都没有字体），HwGUI 依赖于 GTK
  的默认字体处理机制，这样控件仍能正常显示。

  6. 实际使用的默认字体

  - Linux/GTK: 通常使用系统默认的 sans-serif 字体（如 DejaVu Sans、Liberation Sans 等）
  - 字体大小: 通常为 10-12 点大小
  - 字体族: 通常为 "Sans" 或 "Serif"

  这意味着，当您移除主窗口的 FONT 子句后：
  - 窗口的 oFont 属性为 NIL
  - 但控件仍能正常显示，因为它们使用 GTK 的系统默认字体
  - 这也解释了为什么应用程序界面仍然可读可用


在 drawwidg.prg 文件中，HFont 类的 Add 方法定义如下：

  METHOD Add( fontName, nWidth, nHeight , fnWeight, fdwCharSet, fdwItalic, fdwUnderline, fdwStrikeOut, nHandle,
  lLinux ) CLASS HFont

  完整的10个参数：

  1. fontName (字符型) - 字体名称，如 "Arial", "Times New Roman", "Sans", "Serif" 等
  2. nWidth (数值型) - 字体宽度（通常为 0 表示默认宽度）
  3. nHeight (数值型) - 字体高度（字体大小，如 12, 14 等）
  4. fnWeight (数值型) - 字体粗细（0 或 FW_NORMAL 表示普通，FW_BOLD 表示粗体等）
  5. fdwCharSet (数值型) - 字符集（如 DEFAULT_CHARSET, ANSI_CHARSET 等）
  6. fdwItalic (数值型) - 斜体标志（0 表示非斜体，1 表示斜体）
  7. fdwUnderline (数值型) - 下划线标志（0 表示无下划线，1 表示有下划线）
  8. fdwStrikeOut (数值型) - 删除线标志（0 表示无删除线，1 表示有删除线）
  9. nHandle (句柄型) - 字体句柄（通常为 Nil，让系统创建）
  10. lLinux (逻辑型) - Linux 平台标志（影响字体高度调整，Linux 会减 3）

  实际使用示例：

  - HFont():Add( "Sans", 0, 12 ) - 创建 12 号 Sans 字体（最常用，后面参数使用默认值）
  - HFont():Add( "Arial", 0, 14, 700 ) - 创建 14 号粗体 Arial 字体
  - HFont():Add( "Times", 0, 12, 400, 0, 1, 0, 0, Nil, .T. ) - 创建 12 号斜体 Times 字体

  常用字体常量：

  - FW_NORMAL (400) - 普通字体重量
  - FW_BOLD (700) - 粗体字体重量
  - DEFAULT_CHARSET (1) - 默认字符集
  - ANSI_CHARSET (0) - ANSI 字符集

  这就是在 HwGUI 中定义字体时可用的全部参数。通常情况下，仅需指定前 3
  个参数（字体名、宽度、高度）即可满足大部分需求。

