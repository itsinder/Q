#!/bin/bash 
set -e 

export Q_SRC_ROOT=../../../
export LD_LIBRARY_PATH=../../../Q2/code/:../obj/:../../PRINT/obj/

#run test_load_csv
luajit test_load_csv.lua

