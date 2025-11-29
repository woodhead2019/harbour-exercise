// config.prg - 配置文件处理模块
// 为 HiWin 应用程序提供 INI 配置文件读写功能

#include "hwgui.ch"
#include "hiwin.ch"

// 声明全局内存变量 g_hConfig，实际在主程序中定义为 PUBLIC
MEMVAR g_hConfig
MEMVAR g_oTimer, g_oSayState, g_oEditExpr, g_oBtnExp, g_oMainFont
// =============================================================================
// 函数: ConfigInit
// 描述: 初始化配置系统，读取或创建默认配置文件
// 参数: 无
// 返回: NIL
// =============================================================================
FUNCTION ConfigInit()

   LOCAL cConfigFile := GetConfigFileName()

   HiWinLogWrite( "初始化配置系统，配置文件: " + cConfigFile )

   // 检查配置文件是否存在
   IF !File( cConfigFile )
      // 创建默认配置文件
      CreateDefaultConfig( cConfigFile )
   ENDIF

   // 读取配置文件
   HiWinLogWrite( "尝试读取配置文件: " + cConfigFile )
   g_hConfig := hb_iniRead( cConfigFile, .T., "=", .T. )
   IF g_hConfig == NIL
      HiWinLogWrite( "配置文件读取失败，使用默认配置" )
      g_hConfig := { => }
      SetDefaultConfigValues()
   ELSE
      HiWinLogWrite( "配置文件读取成功" )
      // 调试输出配置内容
      // ConfigDump()
   ENDIF

   // 递增启动计数
   IncrementRunCount()

   HiWinLogWrite( "配置初始化完成" )

   RETURN NIL

// =============================================================================
// 函数: GetConfigFileName
// 描述: 获取配置文件的完整路径
// 参数: 无
// 返回: 配置文件路径字符串
// =============================================================================
STATIC FUNCTION GetConfigFileName()

   LOCAL cExePath := FilePath( hb_argv( 0 ) )
   LOCAL cConfigFile := cExePath + CONFIG_FILE

   // 如果执行路径为空，则使用当前目录
   IF Empty( cExePath )
      cConfigFile := CONFIG_FILE
   ENDIF

   RETURN cConfigFile

// =============================================================================
// 函数: CreateDefaultConfig
// 描述: 创建默认配置文件
// 参数: cConfigFile - 配置文件路径
// 返回: NIL
// =============================================================================
STATIC FUNCTION CreateDefaultConfig( cConfigFile )

   LOCAL hIni := hb_iniNew( .T. )

   HiWinLogWrite( "创建默认配置文件: " + cConfigFile )

   // 设置默认配置值
   hIni[ "General" ] := { ;
      "AppName" => APP_NAME, ;
      "Version" => APP_VERSION, ;
      "DevelopMode" => "true", ;
      "RunCount" => "0" ;
      }

   hIni[ "Window" ] := { ;
      "Width" => LTrim( Str( DEFAULT_WINDOW_WIDTH ) ), ;
      "Height" => LTrim( Str( DEFAULT_WINDOW_HEIGHT ) ), ;
      "BackColor" => LTrim( Str( WINDOW_BACKCOLOR ) ) ;
      }

   hIni[ "Font" ] := { ;
      "Name" => DEFAULT_FONT_NAME, ;
      "Size" => LTrim( Str( DEFAULT_FONT_SIZE ) ), ;
      "Width" => LTrim( Str( DEFAULT_FONT_WIDTH ) ) ;
      }

   hIni[ "Log" ] := { ;
      "Enabled" => "true", ;
      "Level" => LTrim( Str( LOG_LEVEL_INFO ) ) ;
      }

   // 写入配置文件
   IF hb_iniWrite( cConfigFile, hIni, "; HiWin Configuration File", "", .T. )
      HiWinLogWrite( "默认配置文件创建成功" )
   ELSE
      HiWinLogWrite( "默认配置文件创建失败" )
   ENDIF

   RETURN NIL

// =============================================================================
// 函数: SetDefaultConfigValues
// 描述: 设置默认配置值到全局配置哈希表
// 参数: 无
// 返回: NIL
// =============================================================================
STATIC FUNCTION SetDefaultConfigValues()

   g_hConfig[ "General" ] := { ;
      "AppName" => APP_NAME, ;
      "Version" => APP_VERSION, ;
      "DevelopMode" => "true", ;
      "RunCount" => "0" ;
      }

   g_hConfig[ "Window" ] := { ;
      "Width" => LTrim( Str( DEFAULT_WINDOW_WIDTH ) ), ;
      "Height" => LTrim( Str( DEFAULT_WINDOW_HEIGHT ) ), ;
      "BackColor" => LTrim( Str( WINDOW_BACKCOLOR ) ) ;
      }

   g_hConfig[ "Font" ] := { ;
      "Name" => DEFAULT_FONT_NAME, ;
      "Size" => LTrim( Str( DEFAULT_FONT_SIZE ) ), ;
      "Width" => LTrim( Str( DEFAULT_FONT_WIDTH ) ) ;
      }

   g_hConfig[ "Log" ] := { ;
      "Enabled" => "true", ;
      "Level" => LTrim( Str( LOG_LEVEL_INFO ) ) ;
      }

   RETURN NIL

// =============================================================================
// 函数: ConfigGetStr
// 描述: 获取字符串类型的配置值
// 参数: cSection - 配置节名称
// cKey - 配置键名称
// cDefault - 默认值
// 返回: 配置值字符串
// =============================================================================
FUNCTION ConfigGetStr( cSection, cKey, cDefault )

   LOCAL cValue := cDefault
   LOCAL hSection

   // 检查节和键是否存在
   IF hb_HHasKey( g_hConfig, cSection )
      hSection := g_hConfig[ cSection ]
      IF hb_HHasKey( hSection, cKey )
         cValue := hSection[ cKey ]
      ENDIF
   ENDIF

   RETURN cValue

// =============================================================================
// 函数: ConfigGetNum
// 描述: 获取数值类型的配置值
// 参数: cSection - 配置节名称
// cKey - 配置键名称
// nDefault - 默认值
// 返回: 配置值数值
// =============================================================================
FUNCTION ConfigGetNum( cSection, cKey, nDefault )

   LOCAL nValue := nDefault
   LOCAL cValue := ConfigGetStr( cSection, cKey, "" )

   IF !Empty( cValue )
      nValue := Val( cValue )
   ENDIF

   RETURN nValue

// =============================================================================
// 函数: ConfigGetBool
// 描述: 获取布尔类型的配置值
// 参数: cSection - 配置节名称
// cKey - 配置键名称
// lDefault - 默认值
// 返回: 配置值布尔值
// =============================================================================
FUNCTION ConfigGetBool( cSection, cKey, lDefault )

   LOCAL lValue := lDefault
   LOCAL cValue := ConfigGetStr( cSection, cKey, "" )

   IF !Empty( cValue )
      lValue := Upper( cValue ) $ ".T.TRUE.1.ON.YES."
   ENDIF

   RETURN lValue

// =============================================================================
// 函数: ConfigSetStr
// 描述: 设置字符串类型的配置值
// 参数: cSection - 配置节名称
// cKey - 配置键名称
// cValue - 配置值
// 返回: NIL
// =============================================================================
FUNCTION ConfigSetStr( cSection, cKey, cValue )

   IF !hb_HHasKey( g_hConfig, cSection )
      g_hConfig[ cSection ] := { => }
   ENDIF

   g_hConfig[ cSection ][ cKey ] := cValue

   RETURN NIL

// =============================================================================
// 函数: ConfigSetNum
// 描述: 设置数值类型的配置值
// 参数: cSection - 配置节名称
// cKey - 配置键名称
// nValue - 配置值
// 返回: NIL
// =============================================================================
FUNCTION ConfigSetNum( cSection, cKey, nValue )

   IF !hb_HHasKey( g_hConfig, cSection )
      g_hConfig[ cSection ] := { => }
   ENDIF

   // Convert to numeric first if it's a string, then back to string
   IF ValType( nValue ) $ "C"
      g_hConfig[ cSection ][ cKey ] := LTrim( Str( Val( nValue ) ) )
   ELSE
      g_hConfig[ cSection ][ cKey ] := LTrim( Str( nValue ) )
   ENDIF

   RETURN NIL

// =============================================================================
// 函数: ConfigSetBool
// 描述: 设置布尔类型的配置值
// 参数: cSection - 配置节名称
// cKey - 配置键名称
// lValue - 配置值
// 返回: NIL
// =============================================================================
FUNCTION ConfigSetBool( cSection, cKey, lValue )

   IF !hb_HHasKey( g_hConfig, cSection )
      g_hConfig[ cSection ] := { => }
   ENDIF

   g_hConfig[ cSection ][ cKey ] := iif( lValue, "true", "false" )

   RETURN NIL

// =============================================================================
// 函数: ConfigSave
// 描述: 保存配置到文件
// 参数: 无
// 返回: NIL
// =============================================================================
FUNCTION ConfigSave()

   LOCAL cConfigFile := GetConfigFileName()

   HiWinLogWrite( "准备保存配置文件到: " + cConfigFile )

   IF hb_iniWrite( cConfigFile, g_hConfig, "; HiWin Configuration File", "", .T. )
      HiWinLogWrite( "配置文件保存成功: " + cConfigFile )
   ELSE
      HiWinLogWrite( "配置文件保存失败: " + cConfigFile )
   ENDIF

   RETURN NIL

// =============================================================================
// 函数: ShowConfigDialog
// 描述: 显示配置对话框
// 参数: 无
// 返回: NIL
// =============================================================================
FUNCTION ShowConfigDialog()

   LOCAL oDlg, oFont
   LOCAL aConfigData := { => }  // 使用哈希表存储配置数据
   LOCAL nRunCount := GetRunCount()

   // 获取当前配置值
   aConfigData[ "AppName" ] := ConfigGetStr( "General", "AppName", APP_NAME )
   aConfigData[ "Version" ] := ConfigGetStr( "General", "Version", APP_VERSION )
   aConfigData[ "DevelopMode" ] := ConfigGetBool( "General", "DevelopMode", .T. )
   aConfigData[ "RunCount" ] := nRunCount

   aConfigData[ "Width" ] := ConfigGetNum( "Window", "Width", DEFAULT_WINDOW_WIDTH )
   aConfigData[ "Height" ] := ConfigGetNum( "Window", "Height", DEFAULT_WINDOW_HEIGHT )

   aConfigData[ "FontName" ] := ConfigGetStr( "Font", "Name", DEFAULT_FONT_NAME )
   aConfigData[ "FontSize" ] := ConfigGetNum( "Font", "Size", DEFAULT_FONT_SIZE )
   aConfigData[ "FontWidth" ] := ConfigGetNum( "Font", "Width", DEFAULT_FONT_WIDTH )

   aConfigData[ "LogEnabled" ] := ConfigGetBool( "Log", "Enabled", .T. )

   // 使用hiwin.prg定义的字体
   // PREPARE FONT oFont NAME "Sans" WIDTH 0 HEIGHT 10

   INIT DIALOG oDlg TITLE "配置设置" AT 100, 100 SIZE 400, 400 FONT g_oMainFont

   // General 设置
   @ 20, 20 GROUPBOX "常规设置" SIZE 360, 100
   @ 40, 40 SAY "应用程序名称:" SIZE 100, 20
   @ 140, 40 EDITBOX aConfigData[ "AppName" ] SIZE 200, 24

   @ 40, 70 SAY "版本:" SIZE 100, 20
   @ 140, 70 EDITBOX aConfigData[ "Version" ] SIZE 200, 24

   @ 40, 100 SAY "启动次数:" SIZE 100, 20
   @ 140, 100 SAY "第 " + LTrim( Str( nRunCount ) ) + " 次" SIZE 200, 24 STYLE SS_CENTER

   // Window 设置
   @ 20, 130 GROUPBOX "窗口设置" SIZE 360, 80
   @ 40, 150 SAY "宽度:" SIZE 60, 20
   @ 100, 150 EDITBOX aConfigData[ "Width" ] SIZE 80, 24

   @ 200, 150 SAY "高度:" SIZE 60, 20
   @ 260, 150 EDITBOX aConfigData[ "Height" ] SIZE 80, 24

   // Font 设置
   @ 20, 220 GROUPBOX "字体设置" SIZE 360, 100
   @ 40, 240 SAY "字体名称:" SIZE 80, 20
   @ 120, 240 EDITBOX aConfigData[ "FontName" ] SIZE 200, 24

   @ 40, 270 SAY "字体大小:" SIZE 80, 20
   @ 120, 270 EDITBOX aConfigData[ "FontSize" ] SIZE 80, 24

   @ 220, 270 SAY "字体宽度:" SIZE 80, 20
   @ 300, 270 EDITBOX aConfigData[ "FontWidth" ] SIZE 80, 24

   // 按钮
   @ 80, 320 BUTTON "确定" SIZE 80, 30 ON CLICK {|| ;
      SaveConfigValues( aConfigData ), ;
      oDlg:Close() }

   @ 240, 320 BUTTON "取消" SIZE 80, 30 ON CLICK {|| oDlg:Close() }

   ACTIVATE DIALOG oDlg CENTER

   RETURN NIL

// =============================================================================
// 函数: SaveConfigValues
// 描述: 保存配置对话框中的值
// 参数: aConfigData - 包含配置数据的哈希表
// 返回: NIL
// =============================================================================
STATIC FUNCTION SaveConfigValues( aConfigData )

   // 保存配置值
   ConfigSetStr( "General", "AppName", aConfigData[ "AppName" ] )
   ConfigSetStr( "General", "Version", aConfigData[ "Version" ] )
   ConfigSetBool( "General", "DevelopMode", aConfigData[ "DevelopMode" ] )

   ConfigSetNum( "Window", "Width", aConfigData[ "Width" ] )
   ConfigSetNum( "Window", "Height", aConfigData[ "Height" ] )

   ConfigSetStr( "Font", "Name", aConfigData[ "FontName" ] )
   ConfigSetNum( "Font", "Size", aConfigData[ "FontSize" ] )
   ConfigSetNum( "Font", "Width", aConfigData[ "FontWidth" ] )

   ConfigSetBool( "Log", "Enabled", aConfigData[ "LogEnabled" ] )

   // 注意：启动计数是只读的，不保存回配置数据

   // 保存到文件
   ConfigSave()

   hwg_MsgInfo( "配置已保存。某些设置需要重启应用程序才能生效。", "信息" )

   RETURN NIL

// =============================================================================
// 函数: ConfigDump
// 描述: 显示当前配置信息（用于调试）
// 参数: 无
// 返回: NIL
// =============================================================================
FUNCTION ConfigDump()

   LOCAL cOutput := "当前配置信息:" + CRLF

   cOutput += "=== General ===" + CRLF
   cOutput += "AppName: " + ConfigGetStr( "General", "AppName", "" ) + CRLF
   cOutput += "Version: " + ConfigGetStr( "General", "Version", "" ) + CRLF
   cOutput += "DevelopMode: " + iif( ConfigGetBool( "General", "DevelopMode", .F. ), "true", "false" ) + CRLF
   cOutput += "RunCount: " + LTrim( Str( ConfigGetNum( "General", "RunCount", 0 ) ) ) + CRLF

   cOutput += CRLF + "=== Window ===" + CRLF
   cOutput += "Width: " + LTrim( Str( ConfigGetNum( "Window", "Width", 0 ) ) ) + CRLF
   cOutput += "Height: " + LTrim( Str( ConfigGetNum( "Window", "Height", 0 ) ) ) + CRLF

   cOutput += CRLF + "=== Font ===" + CRLF
   cOutput += "Name: " + ConfigGetStr( "Font", "Name", "" ) + CRLF
   cOutput += "Size: " + LTrim( Str( ConfigGetNum( "Font", "Size", 0 ) ) ) + CRLF

   cOutput += CRLF + "=== Log ===" + CRLF
   cOutput += "Enabled: " + iif( ConfigGetBool( "Log", "Enabled", .F. ), "true", "false" ) + CRLF

   hwg_MsgInfo( cOutput, "配置信息" )

   RETURN NIL

// =============================================================================
// 函数: IncrementRunCount
// 描述: 递增应用程序启动计数
// 参数: 无
// 返回: NIL
// =============================================================================
FUNCTION IncrementRunCount()

   LOCAL nRunCount := ConfigGetNum( "General", "RunCount", 0 )

   nRunCount++

   ConfigSetNum( "General", "RunCount", nRunCount )

   // 记录到日志
   HiWinLogWrite( "应用程序第 " + LTrim( Str( nRunCount ) ) + " 次启动" )

   // 保存配置
   ConfigSave()

   RETURN NIL

// =============================================================================
// 函数: GetRunCount
// 描述: 获取应用程序启动计数
// 参数: 无
// 返回: 启动计数 (数值)
// =============================================================================
FUNCTION GetRunCount()
   RETURN ConfigGetNum( "General", "RunCount", 0 )
