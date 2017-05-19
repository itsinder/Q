#!/bin/bash
set -e 
test -d $Q_ROOT
rm -r -f ../gen_src/; mkdir -p ../gen_src
rm -r -f ../gen_inc/; mkdir -p ../gen_inc
lua generator.lua operators.lua

cd ../gen_src/
ls *c > _x
while read line; do
  gcc -c $line $QC_FLAGS -I../gen_inc -I../../../UTILS/inc/ 
done< _x
gcc -fPIC -shared *.o -o libf_to_s.so
mv libf_to_s.so $Q_ROOT/lib/
rm -f *.o 
rm -f _x
cd -
echo "ALL DONE: $0 in $PWD"
