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
./test_load_csv_fast
rm -r -f mnist
rm -r -f _*
echo "Completed $0 in $PWD"

