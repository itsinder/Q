#!/bin/bash 
set -e 

# get the current directory in $SCRIPT_PATH
SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
echo $SCRIPT_PATH

gcc -std=gnu99 -shared \
  -o ../src/libinitialize_vector.so \
  initialize_vector.c

cd $SCRIPT_PATH/../src
make

cd ../../../
export Q_SRC_ROOT="`pwd`"
export LUA_INIT="@$Q_SRC_ROOT/init.lua"

unset LD_LIBRARY_PATH
`lua | tail -1`

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$Q_SRC_ROOT/Q2/code/src:$Q_SRC_ROOT/OPERATORS/PRINT/obj"
echo $LD_LIBRARY_PATH
cd $SCRIPT_PATH
luajit test_vector.lua

echo "Completed $0 in $PWD"
