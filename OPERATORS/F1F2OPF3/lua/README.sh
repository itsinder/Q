#!/bin/bash
set -e
rm -f ../gen_src/_*.c
rm -f ../gen_src/_*.o
rm -f ../gen_inc/_*.h
bash cleanup.sh
bash generate_static_checker.sh
bash generate_white_list.sh
lua f1f2opf3_generator.lua
lua _qfns_f1f2opf3.lua # test syntax of generated lua functions
cd ../gen_src/
ls *c > _x
while read line; do
  echo $line
  gcc -c $line -I../gen_inc -I../../../UTILS/inc/ --std=gnu99
done< _x
gcc -shared *.o -o _libfoo.so
rm -f *.o *.so
rm -f _x
cd -
echo "ALL DONE"
