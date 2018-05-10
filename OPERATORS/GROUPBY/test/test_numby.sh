#!/bin/bash
set -e
cd ../lua/
make clean
make
cd -
gcc test_numby.c ../lua/libsumby.so -I../gen_inc -I../../../UTILS/inc/
./a.out
echo "Success on $0"
rm -f a.out
