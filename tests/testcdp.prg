/*  ************************************************************************
 *  Harbour 代码页功能演示（UTF-8 版源码）
 *  ------------------------------------------------------------------------
 *  1. 本文件须用 UTF-8 无 BOM 保存；
 *  2. 终端编码随意：程序会把外部命令输出自动转码成 UTF-8 再显示；
 *  3. 编译运行：hbmk2 testcdp.prg -run
 *  ************************************************************************ */
#include "hbextcdp.ch"
REQUEST HB_LANG_zh_sim          // 简体中文错误提示
REQUEST HB_CODEPAGE_UTF8        // 预声明 UTF8 别名
REQUEST HB_CODEPAGE_GBK         // 预声明 GBK 别名

PROCEDURE Main()
   LOCAL cUtf8, cGbk, cOut, nRet, aList, i

   /* ---- 1. 内部编码与源文件保持一致（UTF-8） ---- */
   hb_cdpSelect( "UTF8" )        // 必须写 UTF8，不能写 UTF-8
   HB_LANGSELECT( "zh_sim" )
   ? "当前内部编码 Internal codepage : " + hb_cdpSelect()

   /* ---- 2. 打印本机支持的全部代码页，防止拼写错误 ---- */
   ? "=== 本机支持的代码页列表 ===  === Available codepages ==="
   ? ""
   aList := hb_cdpList()
   FOR i := 1 TO Len( aList )
      ?? PadR( aList[ i ], 12 )
      IF i % 6 == 0 ; ? "" ; ENDIF
   NEXT
   ? ""

   /* ---- 3. 演示：内部 UTF-8 字符串直接输出 ---- */
   ? "==== 内部 UTF-8 直接显示 / Display UTF-8 directly ===="
   cUtf8 := "你好，世界"
   ? cUtf8
   ? ""

   /* ---- 4. 演示：UTF-8 → GBK 字节流 + 终端直接显示 ---- */
   ? "==== UTF-8 → GBK 转码 / UTF-8 to GBK ===="
   cGbk := Utf8ToGbk( cUtf8 )
   ? "GBK 字节流 / GBK bytes : "
   ? HexDump( cGbk )
   ? "GBK 直接显示（终端须设为 GBK） / GBK direct show (terminal must be GBK):"
   ShowAsGbk( cGbk )             // 临时切成 GBK 输出，立即恢复
   ? "转码为 UTF-8 / Transcoded to UTF-8:"
   ? GbkToUtf8( cGbk )
   ? ""

   /* ---- 5. 捕获外部命令输出 ---- */
   ? "==== 捕获外部命令 / Capture external command ===="
   ? "命令 Command : ld -lnosuchlib 2>&1"
   nRet := RunAndGrab( "ld -lnosuchlib 2>&1", @cOut )
   ? "返回码 Return code : " + Str( nRet, 3 )
   ? "原始字节流（编码未知，可能乱码） / Raw bytes (encoding unknown, maybe garbled):"
   ? cOut

   ? "==== 测试完成 / Test finished ===="
RETURN

/* ***************** 工具函数 ***************** */
/* 安全转码：失败返回原串 */
STATIC FUNCTION SafeTranslate( cStr, cFrom, cTo )
   LOCAL c := hb_Translate( cStr, cFrom, cTo )
RETURN If( c == NIL, cStr, c )

STATIC FUNCTION Utf8ToGbk( cUtf8 )      // UTF-8 → GBK
RETURN SafeTranslate( cUtf8, "UTF8", "GBK" )

STATIC FUNCTION GbkToUtf8( cGbk )       // GBK → UTF-8
RETURN SafeTranslate( cGbk, "GBK", "UTF8" )

/* 字节流 16 进制打印 */
STATIC FUNCTION HexDump( cStr )
   LOCAL i, n := Len( cStr ), cHex := ""
   FOR i := 1 TO n
      cHex += hb_NumToHex( Asc( SubStr( cStr, i, 1 ) ), 2 ) + " "
   NEXT
RETURN cHex

/* 运行命令并抓回结果 */
STATIC FUNCTION RunAndGrab( cCmd, cOut )
   LOCAL nRet := _RunConsoleApp( cCmd, @cOut )
RETURN nRet

/* 临时切成 GBK 输出，用完立即恢复 */
STATIC FUNCTION ShowAsGbk( cStr )
   LOCAL cOld := hb_cdpSelect()
   hb_cdpSelect( "GBK" )
   ?? cStr
   hb_cdpSelect( cOld )
RETURN

#pragma BEGINDUMP
/*
 *  跨平台 C 代码：统一抓取外部命令输出
 *  用法：在 PRG 里直接调用 _RunConsoleApp( cCmd, @cResult )
 */
#include "hbapi.h"
#include "hbapiitm.h"
#define BUFSIZE 16384

#if defined( HB_OS_UNIX )
   #include <stdio.h>
   HB_FUNC( _RUNCONSOLEAPP )
   {
      FILE *fp = popen( hb_parc(1), "r" );
      if( !fp ){ hb_retni(-1); return; }
      char buf[BUFSIZE], *pOut = NULL; int n, tot = 0;
      while( (n = fread(buf,1,BUFSIZE,fp)) > 0 ){
         pOut = (char*)hb_xrealloc(pOut, tot+n+1);
         memcpy(pOut+tot, buf, n); tot += n;
      }
      pclose(fp);
      hb_storclen_buffer(pOut, tot, 2);   // 参数 2 返回字符串
      hb_retni(0);
   }
#else     /* Windows */
   #include <windows.h>
   HB_FUNC( _RUNCONSOLEAPP )
   {
      SECURITY_ATTRIBUTES sa={sizeof(sa),NULL,TRUE};
      HANDLE hRead, hWrite;
      CreatePipe(&hRead,&hWrite,&sa,0);
      SetHandleInformation(hRead,HANDLE_FLAG_INHERIT,0);
      STARTUPINFO si={0}; si.cb=sizeof(si);
      si.dwFlags=STARTF_USESTDHANDLES|STARTF_USESHOWWINDOW;
      si.wShowWindow=SW_HIDE;
      si.hStdOutput=si.hStdError=hWrite;
      PROCESS_INFORMATION pi={0};
      if(!CreateProcess(NULL,(LPSTR)hb_parc(1),NULL,NULL,TRUE,
                        CREATE_NEW_CONSOLE,NULL,NULL,&si,&pi)){
         CloseHandle(hWrite); CloseHandle(hRead); hb_retni(-1); return;
      }
      CloseHandle(hWrite);
      DWORD n,tot=0; char buf[BUFSIZE],*pOut=NULL;
      while(ReadFile(hRead,buf,BUFSIZE,&n,NULL)&&n){
         pOut=(char*)hb_xrealloc(pOut,tot+n+1); memcpy(pOut+tot,buf,n); tot+=n;
      }
      CloseHandle(hRead); CloseHandle(pi.hProcess); CloseHandle(pi.hThread);
      hb_storclen_buffer(pOut,tot,2);
      hb_retni(0);
   }
#endif
#pragma ENDDUMP
