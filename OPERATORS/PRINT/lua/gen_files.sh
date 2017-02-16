#!/bin/bash
set -e 
rm -r -f ../gen_inc/*.h
rm -r -f ../gen_src/*.h
lua gen_code.lua 
#----------------------
cd ../gen_src/
ls *c > _x
while read line; do
  echo $line
  gcc -c $line -I../gen_inc -I../../../UTILS/inc/ -Wall -std=gnu99
done< _x
rm -f *.o
rm -f _x
cd -
#-------------------------
cd ../src/
ls *c > _x
while read line; do
  echo $line
  gcc -c $line -I../gen_inc -I../../../UTILS/inc/ -Wall -std=gnu99
done< _x
rm -f *.o
rm -f _x
cd -
#-------------------------
echo "ALL DONE"
