#!/bin/bash
set -e

# get the current directory in $SCRIPT_PATH
SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
echo $SCRIPT_PATH

#generate vector_map.so
cd $SCRIPT_PATH/../../../../Q2/code
make

cd $SCRIPT_PATH
cd ../../../../
export Q_SRC_ROOT="`pwd`"
export LD_LIBRARY_PATH=$Q_SRC_ROOT/Q2/code:$Q_SRC_ROOT/OPERATORS/DATA_LOAD/obj
# echo $LD_LIBRARY_PATH

cd $SCRIPT_PATH/../
bash test_load.sh

cd $SCRIPT_PATH
#run test_performance.lua 

echo "-----------------------------"
echo "Running Perfomance Test Cases"
echo "-----------------------------"
luajit test_performance.lua 

echo "DONE"


