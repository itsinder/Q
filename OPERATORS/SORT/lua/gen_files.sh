#!/bin/bash
set -e 
rm -r -f ../gen_src/; mkdir -p ../gen_src
rm -r -f ../gen_inc/; mkdir -p ../gen_inc
lua generator.lua 
cd ../gen_src/
ls *c > _x
while read line; do
  echo $line
  gcc -c $QC_FLAGS $line -I../gen_inc -I../../../UTILS/inc/
done< _x
gcc -shared *.o -o libsort.so
cp libsort.so $Q_ROOT/lib/
rm -f _x
cd -
echo "ALL DONE"
