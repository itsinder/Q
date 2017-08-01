#!/bin/bash
set -e 
export PATH=$PATH:../../../UTILS/src
LJ=/home/subramon/LuaJIT-2.0.5/src/luajit
which asc2bin
asc2bin in1_I4.csv I4 _in1_I4.bin
asc2bin in1_B1.csv B1 _nn_in1.bin
cp _in1_I4.bin _in2_I4.bin
$LJ test_Vector.lua
# TODO rm -f _*bin


echo "Completed $0 in $PWD"
