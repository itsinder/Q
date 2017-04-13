#!/bin/bash 
set -e 

# get the current directory in $SCRIPT_PATH
SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
echo $SCRIPT_PATH

cd $SCRIPT_PATH
cd ../../../
export Q_SRC_ROOT="`pwd`"
export LD_LIBRARY_PATH=$Q_SRC_ROOT/Q2/code:$Q_SRC_ROOT/OPERATORS/DATA_LOAD/obj
# echo $LD_LIBRARY_PATH

cd $SCRIPT_PATH/

rm -rf ../gen_inc ../gen_src ../obj
mkdir ../gen_inc ../gen_src ../obj

cd $SCRIPT_PATH/../lua
bash gen_files.sh

cd $SCRIPT_PATH/../src
bash gen_files.sh

cd $SCRIPT_PATH
luajit test_load.lua meta.lua test.csv

echo "Completed $0 in $PWD"