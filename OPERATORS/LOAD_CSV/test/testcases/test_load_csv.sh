#!/bin/bash 
set -e 

# get the current directory in $SCRIPT_PATH
SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
echo $SCRIPT_PATH

export Q_SRC_ROOT=../../../../
export LD_LIBRARY_PATH=../../../../Q2/code/:../../obj/:../../../PRINT/obj

cd $SCRIPT_PATH/../
bash test_load.sh

cd $SCRIPT_PATH/../../../PRINT/test
bash test_print.sh

cd $SCRIPT_PATH

#run test_load_csv
luajit test_load_csv.lua $1

