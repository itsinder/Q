#!/bin/bash
set -e 
export LD_LIBRARY_PATH=$PWD
luajit test_get_cell.lua 2 4 get_cell_input.txt
echo "Completed $0 in $PWD"
