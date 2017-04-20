#!/bin/bash
set -e 
FLAGS="-std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic -fopenmp"

cd ../../LOAD_CSV/lua/
bash gen_files.sh
cd -
#--------------------
cd ../../../UTILS/src/
bash gen_files.sh
cd -
#--------------------
cd ../gen_inc/
cp ../../LOAD_CSV/gen_inc/*.h ../gen_inc/
cp ../../../UTILS/gen_inc/*.h ../gen_inc/

cd ../gen_src/
cp ../../LOAD_CSV/gen_src/*.c ../gen_src/
cp ../../../UTILS/src/is_valid*.c ../gen_src/
cp ../../../UTILS/gen_src/*.c ../gen_src/

cd ../lua/
luajit generator.lua 
cd ../gen_src/
ls *c > _x
while read line; do
  echo $line
  gcc -c $FLAGS $line -I../gen_inc -I../../../UTILS/inc/
done< _x
gcc -shared *.o -o libs_to_f.so
rm -f _x
cd - 1>/dev/null
echo "ALL DONE: $0 in $PWD"
