/*
 * $Id: sample_multilang.prg $
 * Sample with Menu, Toolbar and Status
 * A sample program demonstrating menu, toolbar and status bar with multi-language support
 *
 * Copyright 2025 Your Name <your.email@example.com>
 * www - http://www.example.com
*/

#include "hwgui.ch"

STATIC oMainWindow, oPanel
STATIC oFont

MEMVAR cCurrentLang, aMenuText

FUNCTION Main()
   // Initialize language settings
   cCurrentLang := "English"
   aMenuText := {}
   InitMenuText()

   // Initialize fonts
   oFont := HFont():Add( "Arial", 0, -13 )

   // Create main window
   INIT WINDOW oMainWindow MAIN TITLE aMenuText[1] SIZE 600, 400 FONT oFont ;
      ON EXIT {||.T.}

   // Create toolbar panel
   @ 0, 0 PANEL oPanel SIZE 600, 50 ;
      ON SIZE ANCHOR_TOPABS + ANCHOR_LEFTABS + ANCHOR_RIGHTABS

   // Create menu
   CreateMenu()

   // Create status bar
   ADD STATUS PANEL TO oMainWindow HEIGHT 24 BACKCOLOR 0xEEEEEE FONT oFont PARTS 150, 300, 0

   // Create toolbar
   CreateToolbar()

   // Set initial status bar text
   hwg_WriteStatus( oMainWindow, 1, "Sample: " + aMenuText[3], .T. )
   hwg_WriteStatus( oMainWindow, 2, aMenuText[3], .T. )
   hwg_WriteStatus( oMainWindow, 3, aMenuText[2], .T. )

   // Activate main window
   oMainWindow:Activate()

   RETURN Nil

STATIC FUNCTION InitMenuText()
   ASize( aMenuText, 20 )

   DO CASE
      CASE cCurrentLang == "Chinese"
         // Window title and status bar texts
         aMenuText[1] := "带菜单、工具栏和状态栏的示例"
         aMenuText[2] := "就绪"
         aMenuText[3] := "示例程序"

         // Menu texts
         aMenuText[4] := "文件(&F)"
         aMenuText[5] := "新建(&N)"
         aMenuText[6] := "打开(&O)"
         aMenuText[7] := "保存(&S)"
         aMenuText[8] := "退出(&X)"
         aMenuText[9] := "语言(&L)"
         aMenuText[10] := "英语"
         aMenuText[11] := "中文"
         aMenuText[12] := "帮助(&H)"
         aMenuText[13] := "关于(&A)"

         // Toolbar tooltips
         aMenuText[14] := "新建 - 创建新文件"
         aMenuText[15] := "打开 - 打开现有文件"
         aMenuText[16] := "保存 - 保存当前文件"

         // Status bar texts
         aMenuText[17] := "新建文件"
         aMenuText[18] := "打开文件"
         aMenuText[19] := "保存文件"
         aMenuText[20] := "更改语言为英语"

      OTHERWISE  // Default to English
         // Window title and status bar texts
         aMenuText[1] := "Sample with Menu, Toolbar and Status"
         aMenuText[2] := "Ready"
         aMenuText[3] := "Sample Program"

         // Menu texts
         aMenuText[4] := "&File"
         aMenuText[5] := "&New"
         aMenuText[6] := "&Open"
         aMenuText[7] := "&Save"
         aMenuText[8] := "E&xit"
         aMenuText[9] := "&Language"
         aMenuText[10] := "English"
         aMenuText[11] := "Chinese"
         aMenuText[12] := "&Help"
         aMenuText[13] := "&About"

         // Toolbar tooltips
         aMenuText[14] := "New - Create a new file"
         aMenuText[15] := "Open - Open an existing file"
         aMenuText[16] := "Save - Save the current file"

         // Status bar texts
         aMenuText[17] := "New file"
         aMenuText[18] := "Open file"
         aMenuText[19] := "Save file"
         aMenuText[20] := "Change language to English"
   ENDCASE

   RETURN Nil

STATIC FUNCTION CreateMenu()
   MENU OF oMainWindow
      MENU TITLE aMenuText[4]  // "&File"
         MENUITEM aMenuText[5] ACTION (hwg_MsgInfo(aMenuText[5]), hwg_WriteStatus(oMainWindow, 2, aMenuText[17], .T.), hwg_WriteStatus(oMainWindow, 3, "Editing", .T.))  // "&New"
         MENUITEM aMenuText[6] ACTION (hwg_MsgInfo(aMenuText[6]), hwg_WriteStatus(oMainWindow, 2, aMenuText[18], .T.), hwg_WriteStatus(oMainWindow, 3, "Editing", .T.))  // "&Open"
         MENUITEM aMenuText[7] ACTION (hwg_MsgInfo(aMenuText[7]), hwg_WriteStatus(oMainWindow, 2, aMenuText[19], .T.), hwg_WriteStatus(oMainWindow, 3, "Editing", .T.))  // "&Save"
         SEPARATOR
         MENUITEM aMenuText[8] ACTION hwg_EndWindow()  // "E&xit"
      ENDMENU  // End File menu

      // Language menu
      MENU TITLE aMenuText[9]  // "&Language"
         MENUITEM aMenuText[10] ACTION (ChangeLanguage("English"), hwg_WriteStatus(oMainWindow, 2, aMenuText[20], .T.), hwg_WriteStatus(oMainWindow, 3, "Editing", .T.))  // "English"
         MENUITEM aMenuText[11] ACTION ChangeLanguage("Chinese")  // "Chinese"
      ENDMENU  // End Language menu

      // Help menu
      MENU TITLE aMenuText[12]  // "&Help"
         MENUITEM aMenuText[13] ACTION (hwg_MsgInfo(aMenuText[3]), hwg_WriteStatus(oMainWindow, 2, "About", .T.), hwg_WriteStatus(oMainWindow, 3, "Ready", .T.))  // "&About" -> "Sample Program"
      ENDMENU  // End Help menu
   ENDMENU  // End main menu

   RETURN Nil

STATIC FUNCTION CreateToolbar()
   LOCAL oBtnNew, oBtnOpen, oBtnSave

   // Create toolbar buttons
   @ 10, 10 OWNERBUTTON oBtnNew OF oPanel ;
      SIZE 32, 32 ;
      TEXT "N" ;
      TOOLTIP aMenuText[14] ;  // "New - Create a new file"
      ON CLICK {|| hwg_MsgInfo("New"), hwg_WriteStatus(oMainWindow, 2, aMenuText[17], .T.), hwg_WriteStatus(oMainWindow, 3, "Editing", .T.) }

   @ 50, 10 OWNERBUTTON oBtnOpen OF oPanel ;
      SIZE 32, 32 ;
      TEXT "O" ;
      TOOLTIP aMenuText[15] ;  // "Open - Open an existing file"
      ON CLICK {|| hwg_MsgInfo("Open"), hwg_WriteStatus(oMainWindow, 2, aMenuText[18], .T.), hwg_WriteStatus(oMainWindow, 3, "Editing", .T.) }

   @ 90, 10 OWNERBUTTON oBtnSave OF oPanel ;
      SIZE 32, 32 ;
      TEXT "S" ;
      TOOLTIP aMenuText[16] ;  // "Save - Save the current file"
      ON CLICK {|| hwg_MsgInfo("Save"), hwg_WriteStatus(oMainWindow, 2, aMenuText[19], .T.), hwg_WriteStatus(oMainWindow, 3, "Editing", .T.) }

   RETURN Nil

STATIC FUNCTION ChangeLanguage(cLang)  // cLang: Target language
   // Check if language is already the same
   IF cCurrentLang == cLang
      hwg_MsgInfo("Current language is already " + cLang + ". No restart needed.")
      RETURN Nil
   ENDIF

   // Save new language setting
   cCurrentLang := cLang

   // Update menu texts
   InitMenuText()

   // Update window title
   oMainWindow:SetTitle( aMenuText[1] )

   // Update status bar
   hwg_WriteStatus(oMainWindow, 1, "Sample: " + aMenuText[3], .T.)
   hwg_WriteStatus(oMainWindow, 2, aMenuText[3], .T.)
   hwg_WriteStatus(oMainWindow, 3, aMenuText[2], .T.)

   // Show message
   hwg_MsgInfo("Language changed to " + cLang + ". Please restart the application for full effect.")

   RETURN Nil