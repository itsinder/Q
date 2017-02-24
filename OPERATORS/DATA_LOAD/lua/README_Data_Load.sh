#!/bin/bash 
set -e 
bash gen_files.sh

gcc -std=gnu99 \
  -o ../obj/q_c_functions.so \
  ../src/txt_to_SC.c \
  ../gen_src/_txt_to_I1.c \
  ../gen_src/_txt_to_I2.c \
  ../gen_src/_txt_to_I4.c \
  ../gen_src/_txt_to_I8.c \
  ../gen_src/_txt_to_F4.c \
  ../gen_src/_txt_to_F8.c \
  ../../../UTILS/src/is_valid_chars_for_num.c \
  -fPIC -shared \
  -I../../../UTILS/inc/ \
  -I../gen_inc/
# echo PREMATURE; exit;

#If out, metadata directory exists then remove and create new directories:
if [ -d "out" ]; then 
  rm -r -f out
fi
mkdir out

if [ -d "metadata" ]; then
  rm -r -f metadata
fi
mkdir metadata

meta_data_file=../test/meta.txt
data_file=../test/t1.csv
luajit main.lua $meta_data_file $data_file

echo "Completed $0 in $PWD" # TODO
