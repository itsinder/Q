#!/bin/bash
set -e
LUA_DEBUG=0
LUA_PROD=0
LUA_DEV=0

#---------- Main program starts ----------
# first checking version of system packages required for Q
bash system_requirements.sh

# setting Q source env variables
# TODO: absolute path can be supported
# for now not exiting from setup.sh if any cmd fails i.e. nullifying the set -e effect
# failing cmd: lscpu | grep "Architecture" | grep "arm"
source ../setup.sh -f || true

#Usage: bash q_install.sh "prod|dev|dbg"
#Performs installations of all the required packages, libraries, dependencies required
#for running Q, it works in 3 modes.
#Modes/Options:
#prod : Production mode have just the bare bones of Q to run the Q scripts.
#dev  : Developer mode have everything else: testing, documentation, qli.
#dbg  : Debug mode will be useful for debugging.

# checking mode for q_install.sh
ARG_MODE=$1
case $ARG_MODE in
  help)
    echo "------------------------------"
    echo "Manual/Usage of q_install.sh:"
    echo "bash q_install.sh prod|dev|dbg"
    echo "------------------------------"
    exit 0
    ;;
  prod)
    export QC_FLAGS="$QC_FLAGS -O4"
    ##LUA_PROD=1
    ;;
  dev)
    export QC_FLAGS="$QC_FLAGS -O4"
    LUA_DEV=1
    ;;
  dbg)
    export QC_FLAGS="$QC_FLAGS -g"
    LUA_DEBUG=1
    ;;
  *)
   #default case
   echo "------------------------------"
   echo "Manual/Usage of q_install.sh:"
   echo "bash q_install.sh prod|dev|dbg"
   echo "------------------------------"
   exit 0
   ;;
esac

## Note: Production & Developer mode: building Q with -O4 flag
# TODO: I think, -O4 flag should be there for production mode, else use -g flab
# Discuss: we are using -g flag incase of debugging, and for dev mode we are not doing dbg installations
# installing apt get dependencies
bash apt_get_dependencies.sh

if [[ $LUA_DEBUG -eq 1 ]] ; then
  # installing lua with debug mode(set -g flag) if debug mode
  bash lua_installation.sh LUA_DEBUG
else
  # installing lua and luajit normal mode
  # TODO: can we check existence of lua and luajit before calling the script, same as luarocks
  bash lua_installation.sh
  bash luajit_installation.sh
fi

# This modifies (increases dramatically) the number of files the particular user can have
# open (concurrently). The user for whom we are increasing the limits is the current user.
# The understanding is that Q will be run by this user.
echo "`whoami` hard nofile 102400" | sudo tee --append /etc/security/limits.conf
echo "`whoami` soft nofile 102400" | sudo tee --append /etc/security/limits.conf

#---------- Luarocks ----------
which luarocks &> /dev/null || true
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

# installing luarocks
bash luarocks_installation.sh

# installing basic required packages using luarocks
bash q_required_packages.sh

###if "dbg" mode then
if [[ $LUA_DEBUG -eq 1 ]] ; then
  # TODO: don't we require doc, qli & test packages in debug mode?
  bash q_debug_dependencies.sh
fi

###if "dev" mode then
if [[ $LUA_DEV -eq 1 ]] ; then
  #doc installation
  bash q_doc_dependencies.sh
  #qli installation
  bash q_qli_dependencies.sh
  #test installation
  bash q_test_dependencies.sh
fi


# make
bash build_q.sh

# execute run_q_tests to check whether Q is properly build
luajit -e "require 'run_q_tests'()"

bash my_print.sh "Successfully completed q_install.sh"
