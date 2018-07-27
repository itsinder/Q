#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
W_DIR=`pwd`
cd $SCRIPT_DIR/../../
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:."
cd $W_DIR

gcc -O4 -fopenmp -fPIC -std=gnu99 -shared  logit_I8.c -o liblogit_I8.so -lgomp

luajit $SCRIPT_DIR/test_logit_C.lua

