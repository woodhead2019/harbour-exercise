#include "hwgui.ch"

PROCEDURE Main()
    LOCAL oWnd, oMenu, oMenuBar, oStatusBar

    // -- 窗口定义 --
    INIT WINDOW oWnd TITLE "使用 Harbour + HwGUI 构建的跨平台模板" AT 100, 100 SIZE 640 , 480

    // -- 菜单定义 --
    MENU OF oWnd
        MENU TITLE "文件(&F)"
                MENUITEM "退出(&x)" ACTION {|| oWnd:Close() }
    ENDMENU
        MENU TITLE "帮助(&H)"
                MENUITEM "关于(&A)" ACTION About()
    ENDMENU
    ENDMENU

    // -- 状态栏定义 --
    ADD STATUS oStatusBar TO oWnd PARTS 200 , 400
//    oStatusBar:SetParts( { 200, 400 } ) // 分割状态栏为两部分
    oStatusBar:SetText( "准备就绪", 1 )
//    oStatusBar:SetText( "欢迎使用 Harbour + HwGUI", 2 )

    // -- 窗口内容 --
    @ 50, 50 SAY "这是一个跨平台应用程序" //FONT "Arial" SIZE 12

    ACTIVATE WINDOW oWnd

RETURN

// -- “关于”对话框函数 --
STATIC PROCEDURE About()
    LOCAL cStrText

   cStrText =  "运行平台："+ OS() + "(" +  HB_OSCPU() + ")"+hb_Eol()
   cStrText += "开发工具："+ VERSION() + hb_Eol()
   cStrText += "图 形 库：" + hwg_Version() + hb_Eol()
   cStrText += "编 译 器：" + HB_COMPILER() + hb_Eol()
   cStrText += "代 码 页：" + hb_cdpUniID() + "/" + hb_cdpInfo() + hb_Eol() + "Locale :" + hwg_GetLocaleInfo() 

    hwg_MsgInfo( cStrText, "关于本程序" )
RETURN
