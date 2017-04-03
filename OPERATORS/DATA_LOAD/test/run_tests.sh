#!/bin/bash
set env -e 
cd ../../../
export Q_SRC_ROOT="`pwd`"
cd UTILS/build/
luajit build.lua
cd ../../OPERATORS/DATA_LOAD/test/
bash test_load_csv.sh
