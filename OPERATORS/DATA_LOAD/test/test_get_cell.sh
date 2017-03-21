#!/bin/bash
set -e 
export LD_LIBRARY_PATH=$PWD
luajit test_get_cell.lua 2 4 get_cell_input.txt
luajit test_get_cell.lua 3 2 get_cell_in2.txt
#---- cases that should fail 
set +e
luajit test_get_cell.lua 2 3 get_cell_in2.txt
status=$?; if [ $status == 0 ]; then echo "ERROR: $0: $LINENO"; exit 1; fi 

luajit test_get_cell.lua 3 2 bad_get_cell_in1.txt
if [ $? == 0 ]; then echo "ERROR: $0: $LINENO"; exit 1; fi 

#-- No eoln
luajit test_get_cell.lua 3 2 bad_get_cell_in2.txt
if [ $? == 0 ]; then echo "ERROR: $0: $LINENO"; exit 1; fi 
echo "Completed $0 in $PWD"
