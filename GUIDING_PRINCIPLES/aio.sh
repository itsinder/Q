#!/bin/bash
COLOR_RED='\e[0;91m'
COLOR_GREEN='\e[0;92m'
COLOR_NORMAL='\e[0m'
my_print(){
   if [ -z "$2" ] ; then
      echo -e "$COLOR_GREEN AIO: $1 $COLOR_NORMAL"
   else
      echo -e "$COLOR_RED AIO: $1 $COLOR_NORMAL"
   fi
}

cleanup(){
   if [ -z "$1" ]; then
      my_print "No directory passed to cleanup" 1
      exit 1
   fi
   my_print $1
   find $1 -name "*.o" -o -name "_*" | xargs rm
}

my_print "Stating the all in one script"


###Install lua , luajit and luarocks
### Install lua ####
which lua &> /dev/null
RES=$?
if [[ $RES -ne 0 ]] ; then
   my_print "Installing lua from apt-get"
   sudo apt-get install lua5.1 -y
   sudo apt-get install liblua5.1-dev -y
   sudo apt-get install unzip -y # for luarocks
else
   my_print "Lua is already installed"
fi
# ######## Lua JIT #########

which luajit &> /dev/null
RES=$?
if [[ $RES -ne 0 ]] ; then
   my_print "Installing luajit from source"
   wget http://luajit.org/download/LuaJIT-2.0.4.tar.gz
   tar -xvf LuaJIT-2.0.4.tar.gz
   cd LuaJIT-2.0.4/
   make TARGET_FLAGS=-pthread
   sudo make install
   cd ../
   rm -rf LuaJIT-2.0.4
else
   my_print "luajit is already installed"
fi
# ######## Luarocks #########
which luarocks &> /dev/null
RES=$?
if [[ $RES -ne 0 ]] ; then
   my_print "Installing lua rocks"
   wget https://luarocks.org/releases/luarocks-2.4.1.tar.gz
   tar zxpf luarocks-2.4.1.tar.gz
   cd luarocks-2.4.1
   ./configure; sudo make bootstrap
   cd ../
   rm -rf luarocks-2.4.1
   sudo luarocks install penlight
   sudo luarocks install luaposix
   sudo luarocks install luv
else
   my_print "luarocks is already installed"
fi
#  ######## Build Q #########
my_print "Building Q"
source ../setup.sh -f
cleanup ../ #cleaning up all files

#build files
cd ../UTILS/build
lua build.lua gen.lua
lua mk_so.lua /tmp/
cd -
PROG_START="
q_core = require 'Q/UTILS/lua/q_core'
require 'globals'
load_csv = require 'load_csv'
print_csv = require 'print_csv'
mk_col = require 'Q/OPERATORS/MK_COL/lua/mk_col'
save = require 'Q/UTILS/lua/save'
"
PROG_SAVE="
local q_core = require 'Q/UTILS/lua/q_core'
local mk_col = require 'Q/OPERATORS/MK_COL/lua/mk_col'
local save = require 'Q/UTILS/lua/save'
x = mk_col({10, 20, 30, 40}, 'I4')
print(type(x))
print(x:length())
save('tmp.save')
"
PROG_RESTORE="
dofile(os.getenv('Q_METADATA_DIR') .. '/tmp.save')
print(type(x))
print(x:length())
print_csv = require 'Q/OPERATORS/PRINT/lua/print_csv'
print_csv(x, nil, '')
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
   my_print "SUCCESS in loading all libs"
else
   my_print "FAIL" "error"
fi

luajit -e "$PROG_SAVE"
RES=$?
if [[ $RES -eq 0 ]] ; then
   my_print "SUCCESS in saving"
else
   my_print "FAIL" "error"
fi

luajit -e "$PROG_RESTORE"
RES=$?
if [[ $RES -eq 0 ]] ; then
   my_print "SUCCESS in restoring"
else
   my_print "FAIL" "error"
fi




