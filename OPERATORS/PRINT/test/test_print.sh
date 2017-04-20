#!/bin/bash 
set -e 

# get the current directory in $SCRIPT_PATH
SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
echo $SCRIPT_PATH

#Clean all directory first
rm -rf ../gen_inc ../gen_src ../obj
#rm -rf ../obj

#create all the required directory
mkdir ../gen_src ../gen_inc ../obj
#mkdir ../obj

cd $SCRIPT_PATH
cd ../../../
export Q_SRC_ROOT="`pwd`"
export LUA_INIT="@$Q_SRC_ROOT/init.lua"

unset LD_LIBRARY_PATH
`lua | tail -1`

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$Q_SRC_ROOT/Q2/code:$Q_SRC_ROOT/OPERATORS/PRINT/obj

cd $SCRIPT_PATH/../lua
# generate _xxx_to_txt.c files
# it is done in this script, because C files are not getting from build.lua from UTILS now
# will remove this once build.lua is working
bash gen_files.sh

cd $SCRIPT_PATH

# simple test to print 5 I4 values = [1,2,3,4,5] and SV values mapped to I4 values
# from the bin file I4.bin in bin folder.
# output should print the I4 values and the SV values
luajit test_print.lua

echo "Completed $0 in $PWD"
