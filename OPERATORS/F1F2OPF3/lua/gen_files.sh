#!/bin/bash
set -e
rm -f ../gen_src/_*.c
rm -f ../gen_src/_*.o
rm -f ../gen_inc/_*.h
rm -f _qfns_f1f2opf3.lua
bash cleanup.sh
bash gen_specializers.sh

lua concat_generator.lua concat_operators.lua
lua arith_generator.lua  arith_operators.lua
lua bop_generator.lua    bop_operators.lua
lua cmp_generator.lua    cmp_operators.lua

lua _qfns_f1f2opf3.lua # test syntax of generated lua functions
cd ../gen_src/
ls *c > _x
WARN="-std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic "
while read line; do
  echo $line
  gcc -c $line $FLAGS -I../gen_inc -I../../../UTILS/inc/  -std=gnu99
done< _x
gcc -shared *.o -o _libfoo.so
rm -f *.o *.so
rm -f _x
cd -
echo "ALL DONE; $0 in $PWD"
