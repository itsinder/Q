#!/bin/bash
set -e 

gcc -fPIC -shared  -xc -std=gnu99 \
  -o ../obj/libload_csv.so \
  ../src/get_cell.c \
  ../src/f_mmap.c \
  ../src/txt_to_SC.c \
  ../gen_src/_txt_to_I1.c \
  ../gen_src/_txt_to_I2.c \
  ../gen_src/_txt_to_I4.c \
  ../gen_src/_txt_to_I8.c \
  ../gen_src/_txt_to_F4.c \
  ../gen_src/_txt_to_F8.c \
  ../../../UTILS/src/is_valid_chars_for_num.c \
  -I../../../UTILS/inc/ \
  -I../../../UTILS/gen_inc/ \
  -I../gen_inc/

cd ../../../Q2/code
make clean
make all
cd -
export LD_LIBRARY_PATH='./;../../../Q2/code' 
# luajit ./load.lua
#luajit ./print_csv.lua

