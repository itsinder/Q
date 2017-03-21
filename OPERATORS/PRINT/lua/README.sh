#!/bin/bash 
set -e 

# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
SCRIPT_PATH=$(dirname "$SCRIPT")
echo $SCRIPT_PATH

export LD_LIBRARY_PATH=../../../Q2/code/:../obj/

cd $SCRIPT_PATH
luajit ../test/test_basic_print.lua

echo "Completed $0 in $PWD" # TODO
