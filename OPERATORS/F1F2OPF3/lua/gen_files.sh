#!/bin/bash
set -e
mkdir -p ../gen_src
mkdir -p ../gen_inc
rm -f ../gen_src/_*.c
rm -f ../gen_src/_*.o
rm -f ../gen_inc/_*.h
bash cleanup.sh
bash gen_specializers.sh

luajit concat_generator.lua concat_operators.lua
luajit arith_generator.lua  arith_operators.lua
luajit bop_generator.lua    bop_operators.lua
luajit cmp_generator.lua    cmp_operators.lua

cd ../gen_src/
ls *c > _x
while read line; do
  gcc -c $line $QC_FLAGS -I../gen_inc -I../../../UTILS/inc/ 
done< _x
gcc -shared *.o -o libf1f2opf3.so
cp libf1f2opf3.so $Q_ROOT/lib/
rm -f *.o
rm -f _x
cd -
echo "ALL DONE: $0 in $PWD"
