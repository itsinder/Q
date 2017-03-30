#!/bin/bash
set env -e 
cd ../../
export Q_SRC_ROOT="`pwd`"
cd UTILS/build/
luajit build.lua
cd ../../OPERATORS/PRINT/test/
bash test_print_csv.sh 
