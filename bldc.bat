@echo off
set HRB_DIR=%HB_PATH%
set HWGUI_INSTALL=%HRB_DIR%\hwgui
set HWGUI_LIBS=hwgdebug.lib hwgui.lib hbxml.lib procmisc.lib
set HRB_LIBS=hbdebug.lib hbvm.lib hbrtl.lib gtgui.lib gtwin.lib hbcpage.lib hblang.lib hbrdd.lib hbmacro.lib hbpp.lib rddntx.lib rddcdx.lib rddfpt.lib hbsix.lib hbcommon.lib hbct.lib hbcplr.lib hbmemio.lib hbpcre.lib hbzlib.lib

%HRB_DIR%\bin\harbour hwb.prg -n -w -i%HRB_DIR%\include;%HWGUI_INSTALL%\include %1 %2

echo 1 24 "c:\harbour\hwgui\image\WindowsXP.Manifest" > hwgui_xp.rc
brc32 -r hwgui_xp -fohwgui_xp

bcc32 -c -O2 -tW -M -I%HRB_DIR%\include hwb.c
ilink32 -Gn -aa -Tpe -L%HRB_DIR%\lib\win\bcc;%HWGUI_INSTALL%\lib c0w32.obj hwb.obj, hwb.exe, hwb.map, %HWGUI_LIBS% %HRB_LIBS% ws2_32.lib cw32.lib import32.lib iphlpapi.lib,, hwgui_xp.res

%HRB_DIR%\bin\harbour hwb.prg -n -w -D__CONSOLE -i%HRB_DIR%\include;%HWGUI_INSTALL%\include %1 %2

bcc32 -c -O2 -d -M -I%HRB_DIR%\include hwb.c
ilink32 -Gn -L%HRB_DIR%\lib\win\bcc;%HWGUI_INSTALL%\lib c0w32.obj hwb.obj, hwbc.exe, hwb.map, %HWGUI_LIBS% %HRB_LIBS% ws2_32.lib cw32.lib import32.lib,, hwgui_xp.res

del *.obj
del *.c
del *.map
del hwgui_xp.rc
del *.res
del *.tds
