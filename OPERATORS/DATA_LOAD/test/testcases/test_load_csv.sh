#!/bin/bash 
set -e 

export LUA_INIT="@$Q_SRC_ROOT/init.lua"
unset LD_LIBRARY_PATH
`lua | tail -1`
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$Q_ROOT/lib"

luajit -lluacov test_load_csv.lua $1
luacov