#!/bin/bash
set -e 

rm -rf ../gen_inc ../gen_src 
mkdir -p ../gen_inc 
mkdir -p ../gen_src 

lua print_gen_code.lua 
#----------------------
cd ../gen_src/
ls *c > _x
while read line; do
  echo $line
  gcc -c $line ${QC_FLAGS} -I../gen_inc -I../../../UTILS/inc/ -Wall -std=gnu99
done< _x
rm -f *.o
rm -f _x
cd -
#-------------------------
echo "ALL DONE; $0 in $PWD"
