/*
 * INI文件操作示例程序
 * 演示如何使用INIHelper类进行INI文件操作
 */

// 包含必要的库
#include "common.ch"
#include "hbclass.ch"

PROCEDURE Main()
   LOCAL oIni
   LOCAL cFileName := "myapp.ini"

   ? "=== INI文件操作示例程序 ==="
   ?

   // 创建INIHelper实例
   oIni := INIHelper():New(cFileName)

   // 写入一些配置值
   ? "写入配置值..."
   oIni:WriteValue("Main", "AppName", "My Application")
   oIni:WriteValue("Main", "Version", "1.0.0")
   oIni:WriteValue("Main", "Debug", .T.)
   oIni:WriteValue("Database", "Server", "localhost")
   oIni:WriteValue("Database", "Port", 3306)
   oIni:WriteValue("Database", "Username", "user")
   oIni:WriteValue("Database", "Password", "password")
   oIni:WriteValue("UI", "Theme", "Dark")
   oIni:WriteValue("UI", "Language", "zh-CN")

   // 保存到文件
   IF oIni:Save()
      ? "配置已保存到文件:", cFileName
   ELSE
      ? "保存配置失败!"
   ENDIF

   ?
   ? "=== 读取配置值 ==="

   // 读取配置值
   ? "应用程序名称:", oIni:ReadValue("Main", "AppName", "Unknown")
   ? "版本:", oIni:ReadValue("Main", "Version", "0.0.0")
   ? "调试模式:", oIni:ReadValue("Main", "Debug", .F.)
   ? "数据库服务器:", oIni:ReadValue("Database", "Server", "127.0.0.1")
   ? "数据库端口:", oIni:ReadValue("Database", "Port", 0)
   ? "主题:", oIni:ReadValue("UI", "Theme", "Light")
   ? "语言:", oIni:ReadValue("UI", "Language", "en-US")

   ?
   ? "=== 检查节和键 ==="

   // 检查节和键是否存在
   ? "Database节是否存在:", oIni:SectionExists("Database")
   ? "UI节是否存在:", oIni:SectionExists("UI")
   ? "Database节中Username键是否存在:", oIni:KeyExists("Database", "Username")
   ? "Database节中Host键是否存在:", oIni:KeyExists("Database", "Host")

   ?
   ? "=== 获取节和键列表 ==="

   // 获取节和键列表
   ? "所有节:", hb_valtoexp(oIni:GetSections())
   ? "Database节中的所有键:", hb_valtoexp(oIni:GetKeys("Database"))

   ?
   ? "=== 更新配置值 ==="

   // 更新配置值
   oIni:WriteValue("Main", "Version", "1.0.1")
   oIni:WriteValue("Database", "Port", 5432)
   ? "更新版本为:", oIni:ReadValue("Main", "Version", "0.0.0")
   ? "更新端口为:", oIni:ReadValue("Database", "Port", 0)

   // 保存更新后的配置
   IF oIni:Save()
      ? "更新后的配置已保存"
   ELSE
      ? "保存更新后的配置失败!"
   ENDIF

   ?
   ? "=== 删除操作 ==="

   // 删除键
   ? "删除Database节中的Password键:", oIni:DeleteKey("Database", "Password")
   ? "Password键是否还存在:", oIni:KeyExists("Database", "Password")

   // 删除节
   ? "删除Test节:", oIni:DeleteSection("Test")  // 不存在的节
   oIni:WriteValue("Test", "Temp", "Temporary") // 先创建一个节
   ? "删除Test节:", oIni:DeleteSection("Test")  // 现在删除它

   // 保存最终配置
   IF oIni:Save()
      ? "最终配置已保存"
   ELSE
      ? "保存最终配置失败!"
   ENDIF

   ?
   ? "=== 程序结束 ==="

   RETURN