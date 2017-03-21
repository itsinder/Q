#!/bin/bash
set -e 
UDIR=${Q_SRC_ROOT}/UTILS/lua
test -d $UDIR
rm -f ../gen_inc/*.h
lua $UDIR/extract_func_decl.lua mmap.c ../gen_inc
lua $UDIR/extract_func_decl.lua is_valid_chars_for_num.c ../gen_inc
lua $UDIR/extract_func_decl.lua f_mmap.c ../gen_inc
lua $UDIR/extract_func_decl.lua f_munmap.c ../gen_inc
#--------
# TODO: Improve below
echo "mmap.c is_valid_chars_for_num.c f_mmap.c f_munmap.c " > _x
FLAGS="-fPIC -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic -fPIC"
while read line; do
  echo $line
  gcc -c $line $FLAGS -I../gen_inc -I../inc/ 
done< _x
gcc *.o -shared -o _libfoo.so
rm -f *.o *.so
rm -f _x
echo "Completed $0 in $PWD"
