#!/bin/bash
set -e
bash clean.sh
bash gen_specializers.sh
lua arith_generator.lua  arith_operators.lua

lua  _qfns_f1s1opf2.lua # test syntax of generated lua functions
cd ../gen_src/
ls *c > _x
FLAGS="-std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic -fopenmp"
while read line; do
  echo $line
  gcc -c $line $FLAGS -I../gen_inc -I../../../UTILS/inc/ 
done< _x
gcc -shared *.o -o _libfoo.so
rm -f *.o *.so
rm -f _x
cd -
echo "ALL DONE; $0 in $PWD"
