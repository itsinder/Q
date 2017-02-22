#!/bibn/bash
set -e 
gcc -g -std=gnu99 concat.c \
  -I../gen_inc -I../../../UTILS/inc \
  ../gen_src/_concat_I1_I2_I4.c
valgrind ./a.out
echo "Completed $0 in $PWD"
