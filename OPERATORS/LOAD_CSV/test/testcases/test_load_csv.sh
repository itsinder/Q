#!/bin/bash 
set -e 

# get the current directory in $SCRIPT_PATH
SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
echo $SCRIPT_PATH

cd $SCRIPT_PATH
cd ../../../../
export Q_SRC_ROOT="`pwd`"
export LUA_INIT="@$Q_SRC_ROOT/init.lua"
unset LD_LIBRARY_PATH
`lua | tail -1`
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$Q_SRC_ROOT/OPERATORS/LOAD_CSV/obj:$Q_SRC_ROOT/OPERATORS/PRINT/obj"

cd $SCRIPT_PATH/../
bash test_load.sh

cd $SCRIPT_PATH/../../../PRINT/test
bash test_print.sh

cd $SCRIPT_PATH
#run test_load_csv
luajit test_load_csv.lua $1

