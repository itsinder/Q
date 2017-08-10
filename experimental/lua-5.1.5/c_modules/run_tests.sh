#!/bin/bash
set -e
L="../src/lua"
LJ='/home/subramon//LuaJIT-2.1.0-beta3/src/luajit'
echo "Create a small binary file for I4 called _in1_I4.bin"
rm -f _*bin
export PATH=$PATH:../../../UTILS/src
cd ../../../UTILS/src/
bash mk_asc2bin.sh
cd -
which asc2bin 1>/dev/null 2>&1
asc2bin in1_I4.csv I4 _in1_I4.bin


$L test_arith.lua
$L test_cmem.lua
$L test_eq.lua
$L test_sclr.lua
asc2bin in1_I4.csv I4 _in1_I4.bin
$LJ test_vec.lua
$LJ test_vec_SC.lua
$L test_bvec.lua
echo "SUCCESS for $0 in $PWD"
