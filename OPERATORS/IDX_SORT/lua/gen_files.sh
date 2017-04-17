#!/bin/bash
set -e 
# TODO. Don't want to have to provide path for Lua utilities
test -d "$Q_SRC_ROOT"
UDIR="$Q_SRC_ROOT/UTILS/lua"
test -d $UDIR
unset LUA_INIT
export LUA_INIT="@linit.lua"
lua gen_code.lua 
cd ../gen_src/
ls *c > _x
while read line; do
  echo $line
  gcc -c $line -I../gen_inc -I../../../UTILS/inc/
done< _x
rm -f *.o
rm -f _x
cd -
echo "ALL DONE"
