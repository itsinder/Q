#!/bin/bash
set -e 
gcc $QC_FLAGS test_tmpl_rand.c ../src/tmpl_rand.c -I../../../UTILS/inc/ -DDEBUG
./a.out
echo "Successfully completed $0 in $PWD"
