#!/bin/bash
set -e
if [ ${#} -eq 2 ]
then

  compiler=$(echo $1 | tr '[:upper:]' '[:lower:]')

  if [ ! \( \( $compiler == "luajit-2.1.0-beta3" \) -o \( $compiler == "luajit-2.0.4" \) \) ]
  then
    echo "First argument is incorrect, available options are : {luajit-2.1.0-beta3, luajit-2.0.4}"
    exit 1
  fi

  use_terra=$2
  #if [ \( $compiler == "luajit-2.1.0-beta3" \) -a \( $use_terra == "true" \) ]
  #then
    #as we are facing issue with luajit-2.1.0-beta3 compiler when introduced the require 'terra' statement
    # Issue is: luajit-2.1.0-beta3: strict.lua: cannot load incompatible bytecode
  #  echo "Running test without terra: As luajit-2.1.0-beta3 version is facing issue with terra"
  #  use_terra=false
  #fi

  $compiler test_logit_terra.lua $use_terra

else
  echo "Usage: bash run_performance_test.sh <luajit-2.1.0-beta3/luajit-2.0.4> <use_terra(true/false)>"
  # Note: q_testrunner currently does not support cmd line argument for .sh scripts
  # Assuming default values for q_testrunner
  echo "Running logit with default value assumed for cmd line arguments<luajit-2.1.0-beta3><false>"
  luajit-2.1.0-beta3 $Q_SRC_ROOT/TESTS/performance_tests/CIDR2019_tests/luajit_vs_terra_logit/test_logit_terra.lua false
fi

echo "DONE"
