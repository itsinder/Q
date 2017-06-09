#!/bin/bash
set -e 
INCS="-I../gen_inc/ -I../../../UTILS/inc/ "
gcc $QC_FLAGS test_tmpl_rand.c tmpl_rand.c ../gen_src/_rand_I4.c \
    ${INCS} -DDEBUG -lm
./a.out
echo "Successfully completed $0 in $PWD"
