#!/bin/bash 
set -e 

# get the current directory in $SCRIPT_PATH
SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
echo $SCRIPT_PATH

gcc -std=gnu99 -shared \
  -o libinitialize_vector.so \
  initialize_vector.c

#echo "$1"
#if [ "$1" = "UNIT_TEST" ] 
#then
#generate vector_map.so
cd $SCRIPT_PATH/../
make


cd $SCRIPT_PATH/../../../OPERATORS/PRINT/test
bash test_print.sh
#fi

export Q_SRC_ROOT=../../../
export LD_LIBRARY_PATH=$Q_SRC_ROOT/Q2/code/:$Q_SRC_ROOT/OPERATORS/PRINT/obj/:.



cd $SCRIPT_PATH
luajit test_vector.lua

echo "Completed $0 in $PWD"
