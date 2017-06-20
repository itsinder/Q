#!/bin/bash
set -e 
INCS="-I../gen_inc/ -I../../../UTILS/inc/ "
gcc $QC_FLAGS ../test/test_seq.c  \
    ${INCS} -DDEBUG -lm
./a.out
echo "Successfully completed $0 in $PWD"
