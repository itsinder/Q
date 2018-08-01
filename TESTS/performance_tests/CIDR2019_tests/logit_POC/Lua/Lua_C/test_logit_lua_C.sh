#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
W_DIR=`pwd`
cd $SCRIPT_DIR/../../
echo $SCRIPT_DIR
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:."
cd $W_DIR

gcc -O4 -fopenmp -fPIC -std=gnu99 -shared  $SCRIPT_DIR/logit_I8.c -o $SCRIPT_DIR/liblogit_I8.so -lgomp

luajit $SCRIPT_DIR/test_logit_lua_C.lua

