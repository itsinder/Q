#!/bin/bash
set -e 
lua gen_code.lua 
cd ../gen_src/
ls *c > _x
while read line; do
  echo $line
  gcc -c $line -I../gen_inc -I../../../UTILS/inc/
done< _x
rm -f *.o
rm -f _x
cd -
echo "ALL DONE"
