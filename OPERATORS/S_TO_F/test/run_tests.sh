#!/bin/bash
set -e 
cd ../lua/
bash gen_files.sh
cd -
luajit test_s_to_f.lua
