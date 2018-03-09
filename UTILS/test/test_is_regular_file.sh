#!/bin/bash
set -e
gcc -g test_is_regular_file.c ../src/is_regular_file.c -std=gnu99 -I../inc/ -I../gen_inc/ -lm
./a.out "test_is_regular_file.c"
echo "SUCCESS for $0"
