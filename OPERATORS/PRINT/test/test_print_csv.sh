#!/bin/bash 
set -e 

# get the current directory in $SCRIPT_PATH
SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
echo $SCRIPT_PATH


#generate vector_map.so
cd $SCRIPT_PATH/../../../Q2/code
make

export Q_SRC_ROOT=../../../
export LD_LIBRARY_PATH=../../../Q2/code/:../obj/:../../DATA_LOAD/obj

cd $SCRIPT_PATH/../../DATA_LOAD/test
bash test_load.sh

cd $SCRIPT_PATH
bash test_print.sh

rm -rf test_print_data

#run test_load_csv
luajit test_print_csv.lua $1

