#!/bibn/bash
set -e 
gcc -g -std=gnu99 concat.c \
  -I../gen_inc -I../../../UTILS/inc \
  ../gen_src/_concat_I1_I2_I4.c
valgrind ./a.out 2>_x1 
#-------------------
gcc -g -std=gnu99 eq.c \
  -I../gen_inc -I../../../UTILS/inc \
  ../gen_src/_vveq_F4_F8.c 
valgrind ./a.out 2>_x1
echo "Completed $0 in $PWD"
