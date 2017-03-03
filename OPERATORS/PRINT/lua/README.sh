#!/bin/bash 
set -e 

#Clean all directory first
rm -rf ../gen_inc ../gen_src ../obj

#create all the required directory
mkdir ../gen_src ../gen_inc ../obj


bash gen_files.sh

gcc -std=gnu99 \
  -o ../obj/libq_c_print_functions.so \
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
