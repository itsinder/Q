#!/bin/bash
set -e
bash cleanup.sh
bash generate_static_checker.sh
bash generate_white_list.sh
lua f1f2opf3_generator.lua
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
