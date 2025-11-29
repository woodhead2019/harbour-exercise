/*
 * INI文件操作助手类
 * 提供现代的INI文件读取、写入和更新功能
 */

#include "hbclass.ch"

/*
 * INIHelper 类定义
 */
CLASS INIHelper
   DATA hIni      // 存储INI数据的哈希表
   DATA cFileName // INI文件路径
   DATA lLoaded   // 是否已加载文件

   METHOD New(cFileName) CONSTRUCTOR
   METHOD Load()
   METHOD Save()
   METHOD ReadValue(cSection, cKey, xDefault)
   METHOD WriteValue(cSection, cKey, xValue)
   METHOD GetSections()
   METHOD GetKeys(cSection)
   METHOD SectionExists(cSection)
   METHOD KeyExists(cSection, cKey)
   METHOD DeleteKey(cSection, cKey)
   METHOD DeleteSection(cSection)
ENDCLASS

/*
 * 构造函数
 */
METHOD New(cFileName) CLASS INIHelper
   ::cFileName := cFileName
   ::hIni := hb_iniNew(.T.)  // 创建INI哈希表，自动包含Main节
   ::lLoaded := .F.

   // 如果文件存在，则加载它
   IF hb_fileexists(cFileName)
      ::Load()
   ENDIF

   RETURN Self

/*
 * 加载INI文件
 */
METHOD Load() CLASS INIHelper
   LOCAL hIniData

   IF hb_fileexists(::cFileName)
      hIniData := hb_iniRead(::cFileName)
      IF !EMPTY(hIniData)
         ::hIni := hIniData
         ::lLoaded := .T.
      ENDIF
   ENDIF

   RETURN ::lLoaded

/*
 * 保存INI文件
 */
METHOD Save() CLASS INIHelper
   LOCAL lSuccess

   lSuccess := hb_iniWrite(::cFileName, ::hIni)

   RETURN lSuccess

/*
 * 读取指定节和键的值
 */
METHOD ReadValue(cSection, cKey, xDefault) CLASS INIHelper
   LOCAL xValue := xDefault
   LOCAL hSection, hIni

   hIni := ::hIni

   // 如果没有指定节，则使用Main节
   IF EMPTY(cSection) .OR. cSection == "Main" .OR. cSection == ""
      cSection := "Main"
   ENDIF

   // 检查节是否存在
   IF hb_hHasKey(hIni, cSection)
      hSection := hIni[cSection]
      IF hb_hHasKey(hSection, cKey)
         xValue := hSection[cKey]
      ENDIF
   ENDIF

   RETURN xValue

/*
 * 写入指定节和键的值
 */
METHOD WriteValue(cSection, cKey, xValue) CLASS INIHelper
   LOCAL hSection, hIni

   hIni := ::hIni

   // 如果没有指定节，则使用Main节
   IF EMPTY(cSection) .OR. cSection == "Main" .OR. cSection == ""
      cSection := "Main"
   ENDIF

   // 检查节是否存在，如果不存在则创建
   IF !hb_hHasKey(hIni, cSection)
      hIni[cSection] := {=>}
   ENDIF

   hSection := hIni[cSection]
   hSection[cKey] := xValue

   RETURN .T.

/*
 * 获取所有节名
 */
METHOD GetSections() CLASS INIHelper
   LOCAL aSections := {}
   LOCAL n, nCount
   LOCAL aKeys

   aKeys := hb_hKeys(::hIni)
   nCount := LEN(aKeys)

   FOR n := 1 TO nCount
      AAdd(aSections, aKeys[n])
   NEXT

   RETURN aSections

/*
 * 获取指定节的所有键
 */
METHOD GetKeys(cSection) CLASS INIHelper
   LOCAL aKeys := {}
   LOCAL hSection, hIni

   hIni := ::hIni

   // 如果没有指定节，则使用Main节
   IF EMPTY(cSection) .OR. cSection == "Main" .OR. cSection == ""
      cSection := "Main"
   ENDIF

   // 检查节是否存在
   IF hb_hHasKey(hIni, cSection)
      hSection := hIni[cSection]
      aKeys := hb_hKeys(hSection)
   ENDIF

   RETURN aKeys

/*
 * 检查节是否存在
 */
METHOD SectionExists(cSection) CLASS INIHelper
   LOCAL lExists := .F.
   LOCAL hIni

   hIni := ::hIni

   // 如果没有指定节，则使用Main节
   IF EMPTY(cSection) .OR. cSection == "Main" .OR. cSection == ""
      cSection := "Main"
   ENDIF

   lExists := hb_hHasKey(hIni, cSection)

   RETURN lExists

/*
 * 检查键是否存在
 */
METHOD KeyExists(cSection, cKey) CLASS INIHelper
   LOCAL lExists := .F.
   LOCAL hSection, hIni

   hIni := ::hIni

   // 如果没有指定节，则使用Main节
   IF EMPTY(cSection) .OR. cSection == "Main" .OR. cSection == ""
      cSection := "Main"
   ENDIF

   // 检查节是否存在
   IF hb_hHasKey(hIni, cSection)
      hSection := hIni[cSection]
      lExists := hb_hHasKey(hSection, cKey)
   ENDIF

   RETURN lExists

/*
 * 删除指定键
 */
METHOD DeleteKey(cSection, cKey) CLASS INIHelper
   LOCAL lSuccess := .F.
   LOCAL hSection, hIni

   hIni := ::hIni

   // 如果没有指定节，则使用Main节
   IF EMPTY(cSection) .OR. cSection == "Main" .OR. cSection == ""
      cSection := "Main"
   ENDIF

   // 检查节是否存在
   IF hb_hHasKey(hIni, cSection)
      hSection := hIni[cSection]
      IF hb_hHasKey(hSection, cKey)
         lSuccess := hb_hDel(hSection, cKey)
      ENDIF
   ENDIF

   RETURN lSuccess

/*
 * 删除指定节
 */
METHOD DeleteSection(cSection) CLASS INIHelper
   LOCAL lSuccess := .F.
   LOCAL hIni

   hIni := ::hIni

   // 如果没有指定节，则使用Main节
   IF EMPTY(cSection) .OR. cSection == "Main" .OR. cSection == ""
      cSection := "Main"
   ENDIF

   // 检查节是否存在
   IF hb_hHasKey(hIni, cSection)
      lSuccess := hb_hDel(hIni, cSection)
   ENDIF

   RETURN lSuccess