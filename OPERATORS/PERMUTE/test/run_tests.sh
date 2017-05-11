#!/bin/bash
if [ -z "$TERRA_HOME" ]  
then
  echo "ERR: set TERRA_HOME to point to terra executable"
  exit -1
fi
if [ -z "$Q_SRC_ROOT" ]  
then
  echo "ERR: run setup.sh from Q source root dir"
  exit -1
fi
export LUA_PATH=";$Q_SRC_ROOT/RUNTIME/COLUMN/code/lua/?.lua;$Q_SRC_ROOT/UTILS/lua/?.lua;$Q_SRC_ROOT/OPERATORS/MK_COL/lua/?.lua;;"
export LUA_PATH="$LUA_PATH;$Q_SRC_ROOT/OPERATORS/PERMUTE/test/?.lua"
export LUA_PATH="$LUA_PATH;;"
export TERRA_PATH="$Q_SRC_ROOT/OPERATORS/PERMUTE/terra/?.t;;"
$TERRA_HOME/terra $Q_SRC_ROOT/UTILS/lua/test_runner.lua permute testsuite_permute $1