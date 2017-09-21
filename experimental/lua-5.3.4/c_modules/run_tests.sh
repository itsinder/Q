#!/bin/bash
set -e
L="../src/lua"
$L test_arith.lua
$L test_cmem.lua
$L test_eq.lua
$L test.lua
$L test_sclr.lua
$L test_vec.lua
echo "SUCCESS for $0"
