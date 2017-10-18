#!/bin/bash
set -e
L=lua
LJ=luajit
echo "Create a small binary file for I4 called _in1_I4.bin"
rm -f _*bin
export PATH=$PATH:../../UTILS/src
cd ../../UTILS/src/
bash mk_asc2bin.sh
cd -
which asc2bin 1>/dev/null 2>&1
asc2bin in1_I4.csv I4 _in1_I4.bin
make -C ../src/

$L test_arith.lua
$L test_cmem.lua
$L test_eq.lua
$L test_sclr.lua
$L test_sclr_I8.lua
asc2bin in1_I4.csv I4 _in1_I4.bin
$LJ test_vec.lua
asc2bin in1_I4.csv I4 _in1_I4.bin
$LJ test_vec_writable.lua
$LJ test_vec_prev_chunk.lua
$LJ test_vec_no_chunk_num.lua
$LJ test_vec_SC.lua
asc2bin in1_I4.csv I4 _in1_I4.bin
$LJ test_gen3.lua
$L test_bvec.lua
$LJ test_gen4.lua
bash test_lVector.sh
echo "SUCCESS for $0 in $PWD"
