#!/bin/bash 
set -e 

# get the current directory in $SCRIPT_PATH
SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
echo $SCRIPT_PATH

#Clean all directory first
rm -rf ../gen_inc ../gen_src ../obj

#create all the required directory
mkdir ../gen_src ../gen_inc ../obj

export Q_SRC_ROOT=../../../
export LD_LIBRARY_PATH=../../../Q2/code/:../obj/

cd $SCRIPT_PATH/../lua
# generate _xxx_to_txt.c files
bash gen_files.sh

cd $SCRIPT_PATH

# simple test to print 5 I4 values = [1,2,3,4,5] from the bin file I4.bin in bin folder.
# output should print the I4 values
luajit test_print.lua

echo "Completed $0 in $PWD"
