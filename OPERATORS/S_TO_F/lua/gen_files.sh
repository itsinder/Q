#!/bin/bash
set -e 
test -d $Q_ROOT
rm -r -f ../gen_src/; mkdir -p ../gen_src/
rm -r -f ../gen_inc/; mkdir -p ../gen_inc/
luajit generator.lua 
cd ../gen_src/
ls *c > _x
while read line; do
  echo $line
  gcc -c $QC_FLAGS $line -I../gen_inc -I../../../UTILS/inc/
done< _x
gcc $Q_LINK_FLAGS *.o -o libs_to_f.so
cp libs_to_f.so $Q_ROOT/lib
rm -f _x
cd - 1>/dev/null
echo "ALL DONE: $0 in $PWD"
