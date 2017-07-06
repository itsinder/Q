#!/bin/bash
set -e
if [ ${#} -ne 2 ]
then
  echo "Usage: bash run_performance_test.sh <terra/luajit/luaterra> <input_csv_path>"
  exit 1
fi

export Q_ROOT="."
export LUA_PATH=";./lua/column_lua/?.lua;./lua/utils_lua/?.lua;./lua/?.lua;;"
export LUA_PATH="$LUA_PATH;./lua/load_csv_lua/?.lua"

unset LD_LIBRARY_PATH
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:./lib"

echo "--------------------------------------------"
echo "Running Perfromance Test"
echo "--------------------------------------------"

compiler=$(echo $1 | tr '[:upper:]' '[:lower:]')

if [ ! \( \( $compiler == "terra" \) -o \( $compiler == "luajit" \) -o \( $compiler == "luaterra" \) \) ]
then
  echo "First argument is incorrect, available options are : {terra, luajit, luaterra}"
  exit 1
fi

use_terra=false
if [ $compiler == "luaterra" ]
then
  use_terra=true
  compiler=luajit
fi

$compiler lua/test_performance.lua $2 $use_terra

echo "DONE"


