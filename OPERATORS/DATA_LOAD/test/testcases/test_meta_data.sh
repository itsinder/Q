#!/bin/bash
set -e 

export Q_SRC_ROOT=../../../../

# get the current directory in $SCRIPT_PATH
SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
echo $SCRIPT_PATH

cd $SCRIPT_PATH
cd ../../../../
export Q_SRC_ROOT="`pwd`"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$Q_SRC_ROOT/Q2/code:$Q_SRC_ROOT/OPERATORS/DATA_LOAD/obj
# echo $LD_LIBRARY_PATH
export LUA_INIT="@$Q_SRC_ROOT/init.lua"

cd $SCRIPT_PATH/

rm -rf metadata/
mkdir metadata

luajit test_meta_data.lua $1

echo "Completed $0 in $PWD"
