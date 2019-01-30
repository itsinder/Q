#!/bin/bash
set -e
LUA_DEBUG=0

#---------- Main program starts ----------
# first checking system package version required for Q
bash system_requirements.sh

# setting Q source env variables
# TODO: absolute path can be supported
# for now not exiting from setup.sh if any cmd fails i.e. nullifying the set -e effect 
source ../setup.sh -f || true

# TODO: aio.sh "dbg|test|doc|qli" all modes
# checking  for aio.lua for -d(debug) mode
while getopts 'hd' opt;
do
  case $opt in
    h)
      exit 0
      ;;
    d)
      export QC_FLAGS="$QC_FLAGS -g"
      LUA_DEBUG=1
  esac
done

# installing apt get dependencies
bash apt_get_dependencies.sh

if [[ $LUA_DEBUG  -eq 1 ]] ; then
  # installing lua with debug mode(set -g flag) if debug mode
  bash lua_installation.sh LUA_DEBUG
else
  # installing lua and luajit normal mode
  bash lua_installation.sh
  bash luajit_installation.sh
fi

# TODO: what's this for?
echo "`whoami` hard nofile 102400" | sudo tee --append /etc/security/limits.conf
echo "`whoami` soft nofile 102400" | sudo tee --append /etc/security/limits.conf

#---------- Luarocks ----------
which luarocks &> /dev/null
RES=$?
if [[ $RES -ne 0 ]] ; then
  bash luarocks_installation.sh
else
  bash my_print.sh "Luarocks is already installed"
fi

# Build Q
bash my_print.sh "Building Q"

# cleaning up all files
bash clean_up.sh ../

# make clean
bash clean_q.sh

# installing luaffi in case of debug mode
if [[ $LUA_DEBUG -eq 1 ]] ; then 
  bash luaffi_installation.sh
fi

# make
bash build_q.sh

# execute run_q_tests to check whether Q is properly build
luajit -e "require 'run_q_tests'()"

bash my_print.sh "Successfully completed aio.lua"
