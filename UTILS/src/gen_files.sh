#!/bin/bash
set -e 
UDIR=${Q_SRC_ROOT}/UTILS/lua
test -d $UDIR
rm -f ../gen_inc/*.h
lua $UDIR/extract_func_decl.lua mmap.c ../gen_inc
lua $UDIR/extract_func_decl.lua is_valid_chars_for_num.c ../gen_inc
lua $UDIR/extract_func_decl.lua f_mmap.c ../gen_inc
lua $UDIR/extract_func_decl.lua f_munmap.c ../gen_inc
lua $UDIR/extract_func_decl.lua bytes_to_bits.c ../gen_inc
lua $UDIR/extract_func_decl.lua bits_to_bytes.c ../gen_inc
lua bin_search_generator.lua
#--------
# TODO: Improve below
rm -f _x
echo "mmap.c " >> _x
echo "is_valid_chars_for_num.c " >> _x
echo "f_mmap.c " >> _x
echo "f_munmap.c " >> _x
echo "bytes_to_bits.c " >> _x
echo "bits_to_bytes.c " >> _x
FLAGS="-fPIC -std=gnu99 -Wall -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic -fopenmp"
rm -f *.o
while read line; do
  echo $line
  gcc -c $line $FLAGS -I../gen_inc -I../inc/ 
done< _x
gcc *.o -shared -o _libfoo.so
rm -f *.o *.so
rm -f _x
#-------------------
cd ../gen_src/
rm -f *.o
ls *.c > _x
while read line; do
  echo $line
  gcc -c $line $FLAGS -I../gen_inc -I../inc/ 
done< _x
gcc *.o -shared -o _libfoo.so
rm -f *.o *.so
rm -f _x
cd -
#-------------------
echo "Completed $0 in $PWD"
