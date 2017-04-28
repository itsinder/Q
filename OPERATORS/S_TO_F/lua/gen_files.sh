#!/bin/bash
set -e 
luajit generator.lua 
cd ../gen_src/
ls *c > _x
while read line; do
  echo $line
  gcc -c $QC_FLAGS $line -I../gen_inc -I../../../UTILS/inc/
done< _x
gcc -shared *.o -o libs_to_f.so
rm -f _x
cd - 1>/dev/null
echo "ALL DONE: $0 in $PWD"
