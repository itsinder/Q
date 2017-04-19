#!/bin/bash
set -e 
rm -f ../gen_src/*
rm -f ../gen_inc/*
lua generator.lua 

cd ../../../UTILS/src/
bash gen_files.sh
cd -

cd ../gen_src/
ls *c > _x
FLAGS=" -std=gnu99 -Wall -fPIC -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic -fopenmp "
while read line; do
  echo $line
  gcc -c $line $FLAGS \
    -I../gen_inc \
    -I../../../UTILS/gen_inc/  \
    -I../../../UTILS/inc/  \
    -std=gnu99
done< _x
echo "Done compiling"
rm -f *.o *.so
rm -f _x
cd -
echo "ALL DONE: $0 in $PWD"
