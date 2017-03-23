#!/bin/bash 
set -e 

export Q_SRC_ROOT=../../../
export LD_LIBRARY_PATH=../../../Q2/code/:../obj/

luajit test_load.lua meta.lua test.csv

echo "Completed $0 in $PWD"