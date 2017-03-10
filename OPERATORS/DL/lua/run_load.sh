#!/bin/bash
set -e 
gcc -fPIC -shared -xc -o libload_csv.so \
   ../src/get_cell.c ./f_mmap.c \
   ../gen_src/_txt_to_I4.c \
   ../gen_src/_txt_to_F4.c \
   ../../PRINT/gen_src/_I4_to_txt.c \
  ../../PRINT/gen_src/_F4_to_txt.c \
   ../../../UTILS/src/is_valid_chars_for_num.c \
   -I../../../UTILS/inc \
   -I../gen_inc \
   -I../../PRINT/gen_inc

cd ../../../Q2/code
make clean
make all
cd -
export LD_LIBRARY_PATH='./;../../../Q2/code' 
# luajit ./load.lua
luajit ./print_csv.lua

