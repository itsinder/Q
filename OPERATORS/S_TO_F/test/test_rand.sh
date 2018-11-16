#!/bin/bash
set -e 
INCS="-I../gen_inc/ -I../../../UTILS/inc/ -I../inc/ -I../../../UTILS/gen_inc/"
rm -f a.out
gcc -g $QC_FLAGS \
  ../test/test_tmpl_rand.c \
  ../test/tmpl_rand.c \
  ../../../UTILS/src/rdtsc.c \
  ../gen_src/_rand_I4.c \
    ${INCS} -DDEBUG -lm
./a.out
#----------------
gcc -g $QC_FLAGS \
    ../test/test_rand_B1.c \
    ../../../UTILS/src/rdtsc.c \
    ../src/rand_B1.c \
    ${INCS} -DDEBUG -lm
./a.out
echo "Successfully completed $0 in $PWD"
