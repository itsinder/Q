#!/bin/bash
set -e
cd ../../OPERATORS/DATA_LOAD/lua/
bash gen_files.sh
cd -

gcc -std=gnu99 \
  asc2bin.c \
  is_valid_chars_for_num.c \
  ../../OPERATORS/DATA_LOAD/gen_src/_txt_to_I1.c \
  ../../OPERATORS/DATA_LOAD/gen_src/_txt_to_I2.c \
  ../../OPERATORS/DATA_LOAD/gen_src/_txt_to_I4.c \
  ../../OPERATORS/DATA_LOAD/gen_src/_txt_to_I8.c \
  ../../OPERATORS/DATA_LOAD/gen_src/_txt_to_F4.c \
  ../../OPERATORS/DATA_LOAD/gen_src/_txt_to_F8.c \
  -I../inc/ \
  -I../../OPERATORS/DATA_LOAD/gen_inc/  \
  -o asc2bin
# chmod +x txt_to_bin

echo "Completed $0 in $PWD"
