/*
 * 测试 hb_iniWrite 函数的用法 - 简化版本
 */

FUNCTION Main()
   LOCAL hIni := { "MAIN" => { "key1" => "value1", "key2" => "value2" } }
   LOCAL lResult
   
   ? "当前工作目录: " + CurDir()
   ? "hIni 结构: " + ValType( hIni )
   ? "hIni['MAIN'] 结构: " + ValType( hIni["MAIN"] )
   
   // 尝试保存配置文件
   ? "尝试调用 hb_iniWrite..."
   lResult := hb_iniWrite( "test_simple.ini", hIni )
   
   ? "hb_iniWrite 返回值: " + Iif( lResult, "成功", "失败" )
   
   IF lResult
      ? "配置文件保存成功"
   ELSE
      ? "配置文件保存失败"
   ENDIF
   
   ? "测试完成"
   
   RETURN Nil