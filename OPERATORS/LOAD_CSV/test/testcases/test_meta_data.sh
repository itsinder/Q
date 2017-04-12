#!/bin/bash
set -e 

export Q_SRC_ROOT=../../../../
export LUA_INIT="@$Q_SRC_ROOT/init.lua"

# get the current directory in $SCRIPT_PATH
SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
echo $SCRIPT_PATH


cd $SCRIPT_PATH/

rm -rf metadata/
mkdir metadata

luajit test_meta_data.lua $1

echo "Completed $0 in $PWD"

