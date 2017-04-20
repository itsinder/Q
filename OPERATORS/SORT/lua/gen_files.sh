#!/bin/bash
set -e 
lua gen_code.lua 
cd ../gen_src/
ls *c > _x
FLAGS="-std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic -fopenmp"
while read line; do
  echo $line
  gcc -c $FLAGS $line -I../gen_inc -I../../../UTILS/inc/
done< _x
rm -f *.o
rm -f _x
cd -
echo "ALL DONE"
