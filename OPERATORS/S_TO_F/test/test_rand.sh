#!/bin/bash
set -e 
INCS="-I../gen_inc/ -I../src/ -I../../../UTILS/inc/ "
gcc $QC_FLAGS test_tmpl_rand.c ../src/tmpl_rand.c ${INCS}  -DDEBUG
./a.out
echo "Successfully completed $0 in $PWD"
