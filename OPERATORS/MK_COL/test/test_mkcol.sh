#!/bin/bash 
set -e 

# get the current directory in $SCRIPT_PATH
SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
# echo $SCRIPT_PATH

cd $SCRIPT_PATH
cd ../../../
export Q_SRC_ROOT="`pwd`"
export LUA_INIT="@$Q_SRC_ROOT/init.lua"

unset LD_LIBRARY_PATH
`lua | tail -1`
# export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$Q_SRC_ROOT/Q2/code"

cd $SCRIPT_PATH/

luajit test_mkcol.lua 

echo "Completed $0 in $PWD"
