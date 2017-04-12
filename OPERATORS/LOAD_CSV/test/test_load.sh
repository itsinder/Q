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
export LD_LIBRARY_PATH=../../../Q2/code/:../obj/

rm -rf ../gen_inc ../gen_src ../obj
mkdir ../gen_inc ../gen_src ../obj

cd $SCRIPT_PATH/../lua
bash gen_files.sh

cd $SCRIPT_PATH/../src
bash gen_files.sh

cd $SCRIPT_PATH/

luajit test_load.lua meta.lua test.csv

echo "Completed $0 in $PWD"
