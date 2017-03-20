#!/bin/bash
set -e 
# TODO. Don't want to have to provide path for Lua utilities
test -d "Q_SRC_ROOT"
UDIR="$DIR/UTILS/lua"
test -d $UDIR
lua $UDIRextract_func_decl.lua txt_to_SC.c ../gen_inc/
echo "ALL DONE $0 in $PWD"
