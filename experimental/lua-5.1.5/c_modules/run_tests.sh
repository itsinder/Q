#!/bin/bash
set -e
L="../src/lua"
echo "Create a small binary file for I4 called in1.bin"
test -f in1.bin 
$L test_arith.lua
$L test_cmem.lua
$L test_eq.lua
$L test.lua
$L test_sclr.lua
$L test_vec.lua
$L test_bvec.lua
echo "SUCCESS for $0"
