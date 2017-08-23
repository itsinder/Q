#!/bin/bash
set -e 
rm -f _*bin
export PATH=$PATH:../../../../UTILS/src
LJ=/home/subramon/LuaJIT-2.1.0-beta3/src/luajit
cd ../../../../UTILS/src/
bash mk_asc2bin.sh
cd -
which asc2bin 1>/dev/null 2>&1
asc2bin _input.csv I1 _in_I1.bin
asc2bin _input.csv I2 _in_I2.bin
asc2bin _input.csv I4 _in_I4.bin
asc2bin _input.csv I8 _in_I8.bin
asc2bin _input.csv F4 _in_F4.bin
asc2bin _input.csv F8 _in_F8.bin

luajit $Q_SRC_ROOT/experimental/lua-515/c_modules/lVector_test/test_l_Vector.lua