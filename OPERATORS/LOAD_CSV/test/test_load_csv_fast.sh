#!/bin/bash
infile=../../../DATA_SETS/MNIST/mnist.tar.gz
test -f $infile
cp $infile .
tar -zxvf $infile
set -e
rm -r -f  _test_files
mkdir     _test_files
make clean
make
./test_load_csv_fast 1048576 1>_out 2>_err
grep SUCCESS _out 1>/dev/null 2>&1
grep "0 errors from 0 contexts" _err 1>/dev/null 2>&1
rm -r -f mnist
rm -r -f _* test_load_csv_fast
echo "Completed $0 in $PWD"

