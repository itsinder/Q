#!/bin/bash
set -e 
INCS=" -I./inc/ -I./gen_inc/ -I../../../UTILS/gen_inc/ -I../../../UTILS/inc/ -I../../../OPERATORS/LOAD_CSV/gen_inc/ -I../../../OPERATORS/PRINT/gen_inc/ "
gcc -g $QC_FLAGS $INCS \
  vector.c \
  ../../../UTILS/src/err.c \
  core_vec.c \
  mmap.c \
  txt_to_I4.c \
  is_valid_chars_for_num.c \
  rand_file_name.c \
  get_file_size.c \
  mix_UI8.c \
  mix_UI4.c \
  buf_to_file.c \
  -shared -o libvec.so

gcc -g $QC_FLAGS $INCS \
  cmem.c \
  ../../../OPERATORS/PRINT/gen_src/_I1_to_txt.c \
  ../../../OPERATORS/PRINT/gen_src/_I2_to_txt.c \
  ../../../OPERATORS/PRINT/gen_src/_I4_to_txt.c \
  ../../../OPERATORS/PRINT/gen_src/_I8_to_txt.c \
  ../../../OPERATORS/PRINT/gen_src/_F4_to_txt.c \
  ../../../OPERATORS/PRINT/gen_src/_F8_to_txt.c \
  ../../../UTILS/src/err.c \
  -I./inc/ \
  -I./gen_inc/ \
  -shared -o libcmem.so


rm -f _*.c
lua gen_cmp.lua
lua gen_arith.lua
# gcc -c $QC_FLAGS _eval_cmp.c -I../../../UTILS/inc/

gcc -g $QC_FLAGS $INCS \
  scalar.c \
  ../../../UTILS/src/err.c \
  ../../../OPERATORS/LOAD_CSV/gen_src/_txt_to_I1.c \
  ../../../OPERATORS/LOAD_CSV/gen_src/_txt_to_I2.c \
  ../../../OPERATORS/LOAD_CSV/gen_src/_txt_to_I4.c \
  ../../../OPERATORS/LOAD_CSV/gen_src/_txt_to_I8.c \
  ../../../OPERATORS/LOAD_CSV/gen_src/_txt_to_F4.c \
  ../../../OPERATORS/LOAD_CSV/gen_src/_txt_to_F8.c \
  ../../../UTILS/src/is_valid_chars_for_num.c \
  -I./inc/ \
  -I./gen_inc/ \
  -I../../../OPERATORS/LOAD_CSV/gen_inc/ \
  -shared -o libsclr.so
rm -f _*.c

# ../src/lua x.lua
