#!/bin/bash
set -e 
luajit generator.lua 
FLAGS="-std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic -fopenmp"
cd ../gen_src/
ls *c > _x
while read line; do
  echo $line
  gcc -c $FLAGS $line -I../gen_inc -I../../../UTILS/inc/
done< _x
gcc -shared *.o -o libs_to_f.so
rm -f _x
cd -
echo "ALL DONE"
cd -
echo "ALL DONE; $0 in $PWD"
