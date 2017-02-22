#!/bin/bash 
set -e 

bash gen_files.sh
#gcc -fPIC -shared -o ../src/QCFunc.so ../src/QCFunc.c

gcc -std=gnu99 \
  -o ../obj/q_c_print_functions.so \
  ../src/SC_to_txt.c \
  ../gen_src/_I1_to_txt.c \
  ../gen_src/_I2_to_txt.c \
  ../gen_src/_I4_to_txt.c \
  ../gen_src/_I8_to_txt.c \
  ../gen_src/_F4_to_txt.c \
  ../gen_src/_F8_to_txt.c \
  ../../../UTILS/src/is_valid_chars_for_num.c \
  -fPIC -shared \
  -I../../../UTILS/inc/ \
  -I../gen_inc/





echo "Completed $0 in $PWD" # TODO
