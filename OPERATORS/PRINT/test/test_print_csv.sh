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
export LD_LIBRARY_PATH=../../../Q2/code/:../obj/:../../LOAD_CSV/obj
export LUA_INIT="@$Q_SRC_ROOT/init.lua"

cd $SCRIPT_PATH/../../LOAD_CSV/test
bash test_load.sh

cd $SCRIPT_PATH
bash test_print.sh

rm -rf test_print_data

#run test_load_csv
luajit test_print_csv.lua $1

