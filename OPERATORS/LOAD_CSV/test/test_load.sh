#!/bin/bash 
set -e 

# get the current directory in $SCRIPT_PATH
SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
echo $SCRIPT_PATH

#generate vector_map.so
cd $SCRIPT_PATH/../../../Q2/code
make

cd $SCRIPT_PATH/

export Q_SRC_ROOT=../../../
export LD_LIBRARY_PATH=../../../Q2/code/:../obj/

rm -rf ../obj
mkdir ../obj

luajit test_load.lua meta.lua test.csv

echo "Completed $0 in $PWD"