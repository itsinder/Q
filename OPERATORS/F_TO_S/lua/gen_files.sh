#!/bin/bash
set -e 
rm -f ../gen_src/*
rm -f ../gen_inc/*
lua generator.lua operators.lua

lua _qfns_f_to_s.lua # test syntax of generated lua functions
cd ../gen_src/
ls *c > _x
WARN=" -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align
-Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic "
while read line; do
  echo $line
  gcc -c $line $FLAGS -I../gen_inc -I../../../UTILS/inc/  -std=gnu99
done< _x
echo "Done compiling"
exit
gcc -fPIC -shared *.o -o _libfoo.so
rm -f *.o *.so
rm -f _x
cd -
echo "ALL DONE: $0 in $PWD"
