#!/bin/bash
set -e 
cd ../lua/
bash gen_files.sh
cd -
pwd
echo "Starting luajit"
luajit test_s_to_f.lua
echo "Completed $0 in $PWD"
