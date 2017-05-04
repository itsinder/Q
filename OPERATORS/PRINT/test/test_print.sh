#!/bin/bash 
set -e 

# get the current directory in $SCRIPT_PATH
SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
echo $SCRIPT_PATH

cd ../../../
export Q_SRC_ROOT="`pwd`"
export LUA_INIT="@$Q_SRC_ROOT/init.lua"
unset LD_LIBRARY_PATH
`lua | tail -1`
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$Q_SRC_ROOT/OPERATORS/PRINT/obj"

# generate vector lib files
cd $SCRIPT_PATH/../../../RUNTIME/COLUMN/code/src
bash gen_files.sh
make

# simple test to print 5 I4 values = [1,2,3,4,5] and SV values mapped to I4 values
# from the bin file I4.bin in bin folder.
# output should print the I4 values and the SV values
cd $SCRIPT_PATH/
luajit test_print.lua

echo "Completed $0 in $PWD"
