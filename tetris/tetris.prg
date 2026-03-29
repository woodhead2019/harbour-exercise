/*
 * 俄罗斯方块游戏 - Harbour + HWGUI
 * Tetris Game
 *
 * 功能：
 * - 完整的俄罗斯方块游戏逻辑
 * - 7种标准方块（I, O, T, L, J, S, Z）
 * - 键盘控制（方向键移动、旋转，空格键快速下落）
 * - 行消除和得分系统
 * - 等级提升和速度加快
 * - 图形界面显示（使用 BOARD 控件）
 *
 * 技术要点：
 * - 使用 HwGUI 库实现图形界面
 * - 使用 BOARD 控件 + ON PAINT 回调显示游戏画面
 * - 使用 SET KEY 处理键盘输入（GTK/LINUX 环境）
 * - 使用 SET TIMER 实现自动下落
 * - BGR 颜色格式
 * - 系统自动提供 hDC，无需手动调用 hwg_GetDC
 *
 * 编译：hbmk2 tetris.hbp
 * 运行：./tetris
 */

#include "hwgui.ch"

// ==================== 常量定义 ====================

// BGR 颜色格式宏（HwGUI 使用 BGR 而不是 RGB）
#define BGR(r,g,b)  ((r) + ((g)*256) + ((b)*65536))

// 游戏板尺寸（单位：格）
#define BOARD_WIDTH    10   // 游戏板宽度（10格）
#define BOARD_HEIGHT   20   // 游戏板高度（20格）
#define BLOCK_SIZE     25   // 每个方块的像素大小
#define TIMER_INTERVAL 500  // 定时器间隔（毫秒）

// ==================== 方块定义 ====================

// 7种标准方块类型（4x4 矩阵表示）
STATIC aTetrominoes := { ;
   { {1,1,1,1}, {0,0,0,0}, {0,0,0,0}, {0,0,0,0} }, ;  // I - 青色
   { {1,1,0,0}, {1,1,0,0}, {0,0,0,0}, {0,0,0,0} }, ;  // O - 黄色
   { {0,1,0,0}, {1,1,1,0}, {0,0,0,0}, {0,0,0,0} }, ;  // T - 紫色
   { {1,0,0,0}, {1,1,1,0}, {0,0,0,0}, {0,0,0,0} }, ;  // L - 橙色
   { {0,0,1,0}, {1,1,1,0}, {0,0,0,0}, {0,0,0,0} }, ;  // J - 蓝色
   { {0,1,1,0}, {1,1,0,0}, {0,0,0,0}, {0,0,0,0} }, ;  // S - 绿色
   { {1,1,0,0}, {0,1,1,0}, {0,0,0,0}, {0,0,0,0} }  ;  // Z - 红色
}

// 方块颜色（BGR 格式）
STATIC aColors := { ;
   BGR(0,255,255), ;  // 1: 青色 - I 方块
   BGR(255,255,0), ;  // 2: 黄色 - O 方块
   BGR(255,0,255), ;  // 3: 紫色 - T 方块
   BGR(255,165,0), ;  // 4: 橙色 - L 方块
   BGR(0,0,255), ;    // 5: 蓝色 - J 方块
   BGR(0,255,0), ;    // 6: 绿色 - S 方块
   BGR(255,0,0)  ;    // 7: 红色 - Z 方块
}

// ==================== 全局变量 ====================
STATIC nDisplayMode := 1  // 显示模式：1=BOARD控件，2=SAY控件

STATIC oMainWindow      // 主窗口对象
STATIC oGameBoard       // 游戏棋盘（BOARD 控件）
STATIC oTimer           // 定时器对象
STATIC aBoard := {}     // 游戏板数据（20x10 数组，0=空，非0=方块类型）
STATIC aBlocks := {}    // SAY 控件网格（SAY 控件模式）
STATIC nCurrentX        // 当前方块的 X 坐标（1-10）
STATIC nCurrentY        // 当前方块的 Y 坐标（1-20）
STATIC nCurrentType     // 当前方块类型（1-7）
STATIC nCurrentRotation := 0  // 当前方块旋转角度（保留）
STATIC aCurrentShape    // 当前方块的形状（4x4 矩阵）
STATIC nScore := 0      // 得分
STATIC nLevel := 1      // 等级
STATIC lGameOver := .F. // 游戏结束标志
STATIC nSpeed := TIMER_INTERVAL  // 当前下落速度（毫秒）
STATIC lGameStarted := .F.  // 游戏是否已开始

// ==================== 主函数 ====================

/*
 * 主函数 - 创建游戏窗口并启动游戏
 */
FUNCTION Main()
   LOCAL nWidth := BOARD_WIDTH * BLOCK_SIZE + 200
   LOCAL nHeight := BOARD_HEIGHT * BLOCK_SIZE + 60

   // 初始化对话框（使用 DIALOG 而不是 WINDOW，因为 SET KEY 只支持 DIALOG）
   INIT DIALOG oMainWindow ;
      TITLE "俄罗斯方块 - Tetris" ;
      AT 100, 100 ;
      SIZE nWidth, nHeight ;
      STYLE WS_VISIBLE + WS_CAPTION + WS_SYSMENU ;
      NOEXIT

   // 初始化游戏板数据
   InitBoard()

   // 添加菜单
   MENU OF oMainWindow
      MENU TITLE "游戏(&G)"
         MENUITEM "新游戏(&N)" ACTION StartGame()
         MENUITEM "显示模式 - BOARD控件(&B)" ACTION SetDisplayMode(1)
         MENUITEM "显示模式 - SAY控件(&S)" ACTION SetDisplayMode(2)
         SEPARATOR
         SEPARATOR
         MENUITEM "退出(&X)" ACTION hwg_EndDialog(oMainWindow:handle)
      ENDMENU
      MENU TITLE "帮助(&H)"
         MENUITEM "操作说明(&C)" ACTION ShowHelp()
      ENDMENU
   ENDMENU

   // 添加提示文字
   @ 10, 10 SAY "俄罗斯方块游戏" SIZE 200, 24
   @ 10, 40 SAY "点击菜单'新游戏'开始" SIZE 200, 24

   // 根据显示模式创建游戏棋盘
   IF nDisplayMode == 1
      // BOARD 控件模式（图形好）
      @ 10, 70 BOARD oGameBoard ;
         SIZE (BOARD_WIDTH * BLOCK_SIZE), (BOARD_HEIGHT * BLOCK_SIZE) ;
         ON PAINT {|o,h|BoardPaint(o,h)}
   ELSE
      // SAY 控件模式（简单稳定）
      InitBlocks()
   ENDIF

   // 初始窗口标题
   oMainWindow:Title := "俄罗斯方块 - 点击'新游戏'开始"

   ACTIVATE DIALOG oMainWindow CENTER

RETURN NIL

// ==================== 游戏控制函数 ====================

/*
 * 开始新游戏
 */
FUNCTION StartGame()
   LOCAL cMsg

   IF oTimer != NIL
      oTimer:End()
      oTimer := NIL
   ENDIF

   InitBoard()
   
   // 如果是 SAY 控件模式，初始化 SAY 控件网格
   IF nDisplayMode == 2
      IF Empty(aBlocks)
         InitBlocks()
      ENDIF
   ENDIF
   
   NewTetromino()

   lGameStarted := .T.

   // 设置键盘控制（使用 SET KEY 而不是 ON OTHER MESSAGES）
   SET KEY 0, VK_LEFT TO KeyLeft()
   SET KEY 0, VK_RIGHT TO KeyRight()
   SET KEY 0, VK_DOWN TO KeyDown()
   SET KEY 0, VK_UP TO KeyUp()
   SET KEY 0, VK_SPACE TO KeySpace()

   // 设置定时器（使用代码块）
   SET TIMER oTimer OF oMainWindow VALUE nSpeed ACTION { || TimerTick() }

   // 更新窗口标题
   UpdateTitle()

   // 显示提示信息
   cMsg := "游戏已启动！" + Chr(13) + Chr(13)
   cMsg += "得分：" + Str(nScore) + Chr(13)
   cMsg += "等级：" + Str(nLevel) + Chr(13) + Chr(13)
   cMsg += "按方向键移动方块"
   hwg_MsgInfo(cMsg, "新游戏开始")

   // 消息框关闭后，再次更新窗口标题确保显示正确
   UpdateTitle()

RETURN NIL

/*
 * 显示帮助信息
 */
FUNCTION ShowHelp()
   LOCAL cHelp

   cHelp := "操作说明：" + Chr(13) + Chr(13)
   cHelp += "← 方向键左：向左移动" + Chr(13)
   cHelp += "→ 方向键右：向右移动" + Chr(13)
   cHelp += "↓ 方向键下：快速下落" + Chr(13)
   cHelp += "↑ 方向键上：旋转方块" + Chr(13)
   cHelp += "空格键：直接落到底部" + Chr(13) + Chr(13)
   cHelp += "消除行数越多，得分越高！"

   hwg_MsgInfo(cHelp, "游戏帮助")

RETURN NIL

// ==================== 游戏逻辑函数 ====================

/*
 * 初始化游戏板
 */
FUNCTION InitBoard()
   LOCAL i, j

   aBoard := Array(BOARD_HEIGHT)
   FOR i := 1 TO BOARD_HEIGHT
      aBoard[i] := Array(BOARD_WIDTH)
      FOR j := 1 TO BOARD_WIDTH
         aBoard[i][j] := 0
      NEXT
   NEXT

   nScore := 0
   nLevel := 1
   lGameOver := .F.
   nSpeed := TIMER_INTERVAL

RETURN NIL

/*
 * 生成新方块
 */
FUNCTION NewTetromino()
   nCurrentType := hb_RandomInt(1, Len(aTetrominoes))
   nCurrentRotation := 0
   aCurrentShape := aTetrominoes[nCurrentType]
   nCurrentX := Int(BOARD_WIDTH / 2) - 1
   nCurrentY := 1

   // 检查游戏是否结束
   IF CheckCollision(nCurrentX, nCurrentY, aCurrentShape)
      lGameOver := .T.
      IF oTimer != NIL
         oTimer:End()
      ENDIF
      hwg_MsgInfo("游戏结束！" + Chr(13) + "得分：" + AllTrim(Str(nScore)), "游戏结束")
   ENDIF

RETURN NIL

/*
 * 碰撞检测
 */
FUNCTION CheckCollision(nX, nY, aShape)
   LOCAL i, j, nBoardY, nBoardX

   FOR i := 1 TO 4
      FOR j := 1 TO 4
         IF aShape[i][j] == 1
            nBoardY := nY + i - 1
            nBoardX := nX + j - 1

            // 检查左右边界
            IF nBoardX < 1 .OR. nBoardX > BOARD_WIDTH
               RETURN .T.
            ENDIF

            // 检查底部边界
            IF nBoardY > BOARD_HEIGHT
               RETURN .T.
            ENDIF

            // 只检查在游戏板内的方块碰撞
            IF nBoardY >= 1
               IF aBoard[nBoardY][nBoardX] != 0
                  RETURN .T.
               ENDIF
            ENDIF
         ENDIF
      NEXT
   NEXT

RETURN .F.

/*
 * 将方块固定到游戏板
 */
FUNCTION LockTetromino()
   LOCAL i, j, nLines := 0
   STATIC nLastSpeed := 0

   // 将当前方块固定到游戏板
   FOR i := 1 TO 4
      FOR j := 1 TO 4
         IF aCurrentShape[i][j] == 1
            IF nCurrentY + i - 1 >= 1 .AND. nCurrentY + i - 1 <= BOARD_HEIGHT
               IF nCurrentX + j - 1 >= 1 .AND. nCurrentX + j - 1 <= BOARD_WIDTH
                  aBoard[nCurrentY + i - 1][nCurrentX + j - 1] := nCurrentType
               ENDIF
            ENDIF
         ENDIF
      NEXT
   NEXT

   // 检查并清除完整的行
   nLines := ClearLines()

   IF nLines > 0
      nScore += nLines * nLines * 100
      nLevel := Int(nScore / 1000) + 1
      nSpeed := Max(100, TIMER_INTERVAL - (nLevel - 1) * 50)
   ENDIF

   // 只在速度改变时才重新设置定时器
   IF nSpeed != nLastSpeed
      IF oTimer != NIL
         oTimer:End()
      ENDIF
      SET TIMER oTimer OF oMainWindow VALUE nSpeed ACTION { || TimerTick() }
      nLastSpeed := nSpeed
   ENDIF

   // 生成新方块
   NewTetromino()

RETURN NIL

/*
 * 清除完整的行
 */
FUNCTION ClearLines()
   LOCAL i, j, lFull, nCleared := 0

   FOR i := BOARD_HEIGHT TO 1 STEP -1
      lFull := .T.
      FOR j := 1 TO BOARD_WIDTH
         IF aBoard[i][j] == 0
            lFull := .F.
            EXIT
         ENDIF
      NEXT

      IF lFull
         nCleared++
         // 删除这一行，上面的行下移
         FOR j := i TO 2 STEP -1
            aBoard[j] := aBoard[j-1]
         NEXT
         // 添加新的空行在顶部
         aBoard[1] := Array(BOARD_WIDTH)
         AFill(aBoard[1], 0)
         i++ // 重新检查当前行
      ENDIF
   NEXT

RETURN nCleared

// ==================== 键盘处理函数 ====================

/*
 * 向左移动
 */
FUNCTION KeyLeft()
   IF lGameOver .OR. !lGameStarted
      RETURN NIL
   ENDIF

   IF !CheckCollision(nCurrentX - 1, nCurrentY, aCurrentShape)
      nCurrentX--
      RefreshBoard()
   ENDIF
RETURN NIL

/*
 * 向右移动
 */
FUNCTION KeyRight()
   IF lGameOver .OR. !lGameStarted
      RETURN NIL
   ENDIF

   IF !CheckCollision(nCurrentX + 1, nCurrentY, aCurrentShape)
      nCurrentX++
      RefreshBoard()
   ENDIF
RETURN NIL

/*
 * 向下移动（手动下落）
 */
FUNCTION KeyDown()
   IF lGameOver .OR. !lGameStarted
      RETURN NIL
   ENDIF

   IF !CheckCollision(nCurrentX, nCurrentY + 1, aCurrentShape)
      nCurrentY++
      nScore++  // 手动下落也加分
      RefreshBoard()
   ELSE
      LockTetromino()
      RefreshBoard()
   ENDIF
RETURN NIL

/*
 * 旋转方块
 */
FUNCTION KeyUp()
   LOCAL aNewShape := Array(4), i, j

   IF lGameOver .OR. !lGameStarted
      RETURN NIL
   ENDIF

   // 创建旋转后的形状（顺时针90度）
   FOR i := 1 TO 4
      aNewShape[i] := Array(4)
      FOR j := 1 TO 4
         aNewShape[i][j] := aCurrentShape[5-j][i]
      NEXT
   NEXT

   IF !CheckCollision(nCurrentX, nCurrentY, aNewShape)
      aCurrentShape := aNewShape
      RefreshBoard()
   ENDIF
RETURN NIL

/*
 * 快速下落（直接落到底部）
 */
FUNCTION KeySpace()
   LOCAL nDropped := 0

   IF lGameOver .OR. !lGameStarted
      RETURN NIL
   ENDIF

   DO WHILE !CheckCollision(nCurrentX, nCurrentY + 1, aCurrentShape)
      nCurrentY++
      nDropped++
   ENDDO

   IF nDropped > 0
      nScore += nDropped
      LockTetromino()
      RefreshBoard()
   ENDIF
RETURN NIL

/*
 * 定时器回调（自动下落）
 */
FUNCTION TimerTick()
   IF lGameOver .OR. !lGameStarted
      RETURN NIL
   ENDIF

   KeyDown()
RETURN NIL

// ==================== 图形显示函数 ====================

/*
 * 更新窗口标题
 */
FUNCTION UpdateTitle()
   LOCAL cTitle := "俄罗斯方块 - 得分:" + Str(nScore) + " 等级:" + Str(nLevel)
   hwg_SetWindowText(oMainWindow:handle, cTitle)
RETURN NIL

/*
 * 刷新游戏画面（触发重绘）
 */
FUNCTION RefreshBoard()
   UpdateTitle()
   IF nDisplayMode == 1
      // BOARD 控件模式：触发重绘
      hwg_Invalidaterect(oGameBoard:handle)
   ELSE
      // SAY 控件模式：直接更新颜色
      DrawGame()
   ENDIF
RETURN NIL

/*
 * 绘制游戏棋盘（ON PAINT 回调）
 * 
 * 参数：
 *   o - BOARD 控件对象
 *   hDC - 系统提供的设备上下文（无需手动调用 hwg_GetDC）
 * 
 * 说明：
 *   - BOARD 控件的 ON PAINT 回调会自动提供 hDC
 *   - 使用 hDC 进行绘图，不会导致段错误
 *   - 可以绘制矩形、圆、线条等基本图形
 */

/*
 * 设置显示模式
 */
FUNCTION SetDisplayMode(nMode)
   nDisplayMode := nMode
   IF nMode == 1
      hwg_MsgInfo("已切换到 BOARD 控件模式（图形好）", "显示模式")
   ELSE
      hwg_MsgInfo("已切换到 SAY 控件模式（简单稳定）", "显示模式")
      // 立即初始化 SAY 控件网格
      InitBlocks()
   ENDIF
RETURN NIL

/*
 * 初始化 SAY 控件网格（SAY 控件模式）
 * 
 * 说明：
 *   - 创建 200 个 SAY 控件（10x20 网格）
 *   - 控件紧密排列，无间隙，无边框
 *   - 通过修改控件的背景颜色显示方块
 *   - HwGUI 自动重绘，无需手动刷新
 * 
 * 优点：
 *   - 简单稳定，不会崩溃
 *   - HwGUI 自动重绘机制
 *   - 代码简单易懂
 * 
 * 缺点：
 *   - 只能显示颜色，不能绘制线条或图形
 *   - 性能较低（200个控件）
 *   - 功能有限
 * 
 * 对比：
 *   - BOARD 控件模式：图形好、性能高、功能强
 *   - SAY 控件模式：简单稳定、但功能有限
 */
FUNCTION InitBlocks()
   LOCAL i, j, x, y
   LOCAL oBlock

   // 创建 10x20 的 SAY 控件网格（紧密排列，无间隙）
   aBlocks := Array(BOARD_HEIGHT)
   FOR i := 1 TO BOARD_HEIGHT
      aBlocks[i] := Array(BOARD_WIDTH)
      FOR j := 1 TO BOARD_WIDTH
         x := 10 + (j - 1) * BLOCK_SIZE
         y := 70 + (i - 1) * BLOCK_SIZE

         @ x, y SAY oBlock CAPTION "" ;
            OF oMainWindow ;
            SIZE BLOCK_SIZE, BLOCK_SIZE ;
            BACKCOLOR 0xFFFFFF

         aBlocks[i][j] := oBlock
      NEXT
   NEXT
RETURN NIL

/*
 * 绘制游戏画面（SAY 控件模式）
 * 
 * 说明：
 *   - 遍历所有 SAY 控件，更新背景颜色
 *   - 根据游戏板数据显示已固定的方块
 *   - 显示当前移动的方块
 *   - HwGUI 自动重绘，无需手动刷新
 * 
 * 刷新机制：
 *   - 控件属性修改会自动触发重绘
 *   - 不需要调用 hwg_Invalidaterect()
 *   - 不需要调用 hwg_RedrawWindow()
 *   - 不需要调用 hwg_Refresh()
 * 
 * 参数：
 *   无
 * 
 * 返回值：
 *   NIL
 */
FUNCTION DrawGame()
   LOCAL i, j, nColor
   LOCAL oBlock

   // 检查 SAY 控件是否已初始化
   IF Empty(aBlocks)
      RETURN NIL
   ENDIF

   // 更新游戏板显示
   FOR i := 1 TO BOARD_HEIGHT
      FOR j := 1 TO BOARD_WIDTH
         oBlock := aBlocks[i][j]
         IF oBlock != NIL
            IF aBoard[i][j] != 0
               nColor := aColors[aBoard[i][j]]
            ELSE
               nColor := 0xFFFFFF
            ENDIF
            oBlock:SetColor(, nColor)
         ENDIF
      NEXT
   NEXT

   // 如果游戏已开始，绘制当前移动的方块
   IF lGameStarted .AND. !lGameOver .AND. aCurrentShape != NIL
      FOR i := 1 TO 4
         FOR j := 1 TO 4
            IF aCurrentShape[i][j] == 1
               nColor := aColors[nCurrentType]
               IF nCurrentX + j - 1 >= 1 .AND. nCurrentX + j - 1 <= BOARD_WIDTH .AND. ;
                  nCurrentY + i - 1 >= 1 .AND. nCurrentY + i - 1 <= BOARD_HEIGHT
                  oBlock := aBlocks[nCurrentY + i - 1][nCurrentX + j - 1]
                  IF oBlock != NIL
                     oBlock:SetColor(, nColor)
                  ENDIF
               ENDIF
            ENDIF
         NEXT
      NEXT
   ENDIF
RETURN NIL
/*
 * 绘制游戏棋盘（BOARD 控件模式 - ON PAINT 回调）
 * 
 * 参数：
 *   o - BOARD 控件对象
 *   hDC - 系统提供的设备上下文（无需手动调用 hwg_GetDC）
 * 
 * 说明：
 *   - BOARD 控件的 ON PAINT 回调会自动提供 hDC
 *   - 使用 hDC 进行绘图，不会导致段错误
 *   - 可以绘制矩形、圆、线条等基本图形
 *   - 必须正确释放画刷和画笔资源
 * 
 * 参考：
 *   - 正确实现：/home/woodhead/cchess/xiangqiw.prg（中国象棋）
 *   - 错误方法：PANEL + ON PAINT + hwg_GetDC（会导致段错误）
 */
STATIC FUNCTION BoardPaint(o, hDC)
   LOCAL i, j, x, y, nColor
   LOCAL oBrush, oPen

   // 绘制游戏板背景（白色）
   oBrush := HBrush():Add(0xFFFFFF)
   hwg_Rectangle_Filled(hDC, 0, 0, BOARD_WIDTH * BLOCK_SIZE, BOARD_HEIGHT * BLOCK_SIZE, .F., oBrush:handle)
   oBrush:Release()

   // 绘制已固定的方块
   FOR i := 1 TO BOARD_HEIGHT
      FOR j := 1 TO BOARD_WIDTH
         IF aBoard[i][j] != 0
            x := (j - 1) * BLOCK_SIZE
            y := (i - 1) * BLOCK_SIZE
            nColor := aColors[aBoard[i][j]]
            
            // 绘制方块（填充矩形）
            oBrush := HBrush():Add(nColor)
            hwg_Rectangle_Filled(hDC, x, y, x + BLOCK_SIZE, y + BLOCK_SIZE, .F., oBrush:handle)
            oBrush:Release()
            
            // 绘制方块边框（黑色）
            oPen := HPen():Add(PS_SOLID, 1, 0x000000)
            hwg_Rectangle(hDC, x, y, x + BLOCK_SIZE, y + BLOCK_SIZE, oPen:handle)
            oPen:Release()
         ENDIF
      NEXT
   NEXT

   // 绘制当前移动的方块
   IF lGameStarted .AND. !lGameOver .AND. aCurrentShape != NIL
      nColor := aColors[nCurrentType]
      FOR i := 1 TO 4
         FOR j := 1 TO 4
            IF aCurrentShape[i][j] == 1
               IF nCurrentX + j - 1 >= 1 .AND. nCurrentX + j - 1 <= BOARD_WIDTH .AND. ;
                  nCurrentY + i - 1 >= 1 .AND. nCurrentY + i - 1 <= BOARD_HEIGHT
                  x := (nCurrentX + j - 2) * BLOCK_SIZE
                  y := (nCurrentY + i - 2) * BLOCK_SIZE
                  
                  // 绘制方块（填充矩形）
                  oBrush := HBrush():Add(nColor)
                  hwg_Rectangle_Filled(hDC, x, y, x + BLOCK_SIZE, y + BLOCK_SIZE, .F., oBrush:handle)
                  oBrush:Release()
                  
                  // 绘制方块边框（黑色）
                  oPen := HPen():Add(PS_SOLID, 1, 0x000000)
                  hwg_Rectangle(hDC, x, y, x + BLOCK_SIZE, y + BLOCK_SIZE, oPen:handle)
                  oPen:Release()
               ENDIF
            ENDIF
         NEXT
      NEXT
   ENDIF

RETURN NIL