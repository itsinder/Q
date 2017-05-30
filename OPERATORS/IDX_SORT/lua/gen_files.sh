#!/bin/bash
set -e 
test -d $Q_ROOT
lua generator.lua 
cd ../gen_src/
ls *c > _x
while read line; do
  echo $line
  gcc $QC_FLAGS -c $line -I../gen_inc -I../../../UTILS/inc/
done< _x
gcc $Q_LINK_FLAGS *.o -o libidx_sort.so
cp libidx_sort.so $Q_ROOT/lib/
rm -f *.o
rm -f _x
cd -
echo "ALL DONE"
