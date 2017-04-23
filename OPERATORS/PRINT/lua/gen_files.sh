#!/bin/bash
set -e 

rm -rf ../gen_inc ../gen_src 
mkdir ../gen_inc ../gen_src 

lua print_gen_code.lua 
FLAGS=" -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic -fopenmp"
#----------------------
cd ../gen_src/
ls *c > _x
while read line; do
  echo $line
  gcc -c $line ${FLAGS} -I../gen_inc -I../../../UTILS/inc/ -Wall -std=gnu99
done< _x
rm -f *.o
rm -f _x
cd -
#-------------------------
cd ../src/
bash gen_files.sh
ls *c > _x
while read line; do
  echo $line
  gcc -c $line ${FLAGS} -I../gen_inc -I../../../UTILS/inc/ -Wall -std=gnu99
done< _x
rm -f *.o
rm -f _x
cd -
#-------------------------
echo "ALL DONE; $0 in $PWD"
