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
export TERRA_PATH="$Q_SRC_ROOT/../?.t;;"
$TERRA_HOME/terra $Q_SRC_ROOT/UTILS/lua/test_runner.lua Q/OPERATORS/PERMUTE/terra/permute Q/OPERATORS/PERMUTE/test/testsuite_permute $1