#!/bin/bash
set -e
echo "-----------------------------"
echo "Running Dictionary Test Cases"
echo "-----------------------------"
luajit test_dictionary.lua

echo "-----------------------------"
echo "Running Load CSV Test Cases"
echo "-----------------------------"
luajit test_load_csv.lua

echo "----------------------------"
echo "DONE"
