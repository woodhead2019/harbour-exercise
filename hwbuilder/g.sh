#!/bin/bash
export HB_ROOT=$HOME/hb/harbour

export HRB_BIN=$HB_ROOT/bin
export HRB_INC=$HB_ROOT/include
export HRB_LIB=$HB_ROOT/lib
export HRB_EXE=$HRB_BIN/harbour

export SYSTEM_LIBS="-lm"
export HARBOUR_LIBS="-lhbdebug -lhbvm -lhbrtl -lgtcgi -lgttrm -lhbdebug -lhblang -lhbrdd -lhbmacro -lhbpp -lrddntx -lrddcdx -lrddfpt -lhbsix -lhbcommon -lhbcpage"
export HWGUI_LIBS="-lhwgui -lprocmisc -lhbxml -lhwgdebug"
export HWGUI_ROOT=$HOME/hb/hwgui
export HWGUI_INC=$HWGUI_ROOT/include
export HWGUI_LIB=$HWGUI_ROOT/lib

$HRB_EXE hwbc -n -i$HRB_INC -i$HWGUI_INC -D__GUI -es2
gcc hwbc.c -ohwb -I $HRB_INC -L $HRB_LIB -L $HWGUI_LIB -Wl,--start-group $HWGUI_LIBS $HARBOUR_LIBS -Wl,--end-group `pkg-config --cflags gtk+-2.0` `pkg-config gtk+-2.0 --libs` $SYSTEM_LIBS

rm hwbc.c

$HRB_EXE hwbc -n -i$HRB_INC -i$HWGUI_INC -es2
gcc hwbc.c -ohwbc -I $HRB_INC -L $HRB_LIB -Wl,--start-group $HARBOUR_LIBS -Wl,--end-group $SYSTEM_LIBS

rm hwbc.c
