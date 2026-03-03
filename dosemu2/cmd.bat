@echo off
rem  dosemu -K $(pwd)  -E "cmd.bat"

set CUR_DRV=G:
set include=%CUR_DRV%\clip52e\include
set lib=%CUR_DRV%\clip52e\lib
set obj=%CUR_DRV%\clip52e\obj
set path=%CUR_DRV%\clip52e\bin;%PATH%

CLIPPER.EXE test -n

rtlink fi test

pause
