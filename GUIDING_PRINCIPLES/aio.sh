#!/bin/bash
###Install lua , luajit and luarocks
### Install lua ####
# sudo apt-get install lua5.1 -y
# sudo apt-get install liblua5.1-dev -y
# sudo apt-get install unzip -y # for luarocks
# 
# ######## Lua JIT #########
# wget http://luajit.org/download/LuaJIT-2.0.4.tar.gz
# tar -xvf LuaJIT-2.0.4.tar.gz
# cd LuaJIT-2.0.4/
# make
# udo make install
# 
# ######## Luarocks #########
# wget https://luarocks.org/releases/luarocks-2.4.1.tar.gz
# tar zxpf luarocks-2.4.1.tar.gz
# cd luarocks-2.4.1
# ./configure; sudo make bootstrap
# sudo luarocks install penlight
# sudo luarocks install luaposix
# 
#  ######## Build Q #########
source ../setup.sh -f 
cd ../UTILS/build
lua build.lua gen.lua
lua mk_so.lua /tmp/
cd - 
PROG="
q_core = require 'q_core'
q = require 'q'
require 'globals'
load_csv = require 'load_csv'
print_csv = require 'print_csv'
mk_col = require 'mk_col'
save = require 'save'
print('SUCCESS')
"
# load csv
# mk col
# print csv
# save

# number 2
# restore
# print csv

# performance test stretch goal - add 
luajit -e "$PROG" &>/dev/null
RES=$?
if [[ $RES -eq 0 ]] ; then
    echo "SUCCESS"
else
    echo "FAIL"
fi
