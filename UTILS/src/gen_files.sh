#!/bin/bash
set -e 
UDIR=${Q_SRC_ROOT}/UTILS/lua
test -d $UDIR
lua $UDIR/extract_func_decl.lua mmap.c ../gen_inc
lua $UDIR/extract_func_decl.lua is_valid_chars_for_num.c ../gen_inc
echo "Completed $0 in $PWD"
