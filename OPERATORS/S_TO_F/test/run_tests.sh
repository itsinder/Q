#!/bin/bash
set -e 
cd ../lua/
bash gen_files.sh
echo "XXXXXX"
cd -
echo "Starting LuaJIT"
luajit test_s_to_f.lua
echo "Completed $0 in $PWD"
