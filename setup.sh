#!/bin/bash
usage(){
	echo "Usage: $0 [-f|-h] -- program to set the env variables for running Q" 1>&2
	echo "where:" 1>&2
	echo "	-h	shows this message" 1>&2
	echo "	-f	sets all the parameters to their default values. Namely Q_SRC_ROOT Q_ROOT LUA_INIT LD_LIBRARY_PATH QC_FLAGS are set to the default values" 1>&2
	echo "Note: To have the changes reflect in your env, use: source $0 [-f]" 1>&2
	exit 1 ;
}

# export Q_SRC_ROOT="$ {Q_SRC_ROOT: = ${BASE_PATH}}"
# export Q_ROOT="$ {Q_ROOT: = ${HOME} / Q}"
# mkdir -p $Q_ROOT/include $Q_ROOT/lib
# export LUA_INIT="$ {LUA_INIT: = @${Q_SRC_ROOT} / init.lua}"
# # Setting ld library path based on lua init
# `lua| tail -1`
# export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$Q_ROOT/lib"
# export QC_FLAGS="$ {QC_FLAGS: = $C_FLAGS}"

while getopts "fh" opt;
do
	case $opt in
		h)
			usage
			;;
		f)
			# echo "-f was triggered, Parameter: $OPTARG" >&2
			unset Q_SRC_ROOT
			unset Q_ROOT
			unset LUA_INIT
			unset LD_LIBRARY_PATH
			unset QC_FLAGS
			echo "Unset all params" 
			;;
		\?)
			echo "Invalid option: -$OPTARG" 1>&2
			exit 1
			;;
		:)
			echo "Option -$OPTARG requires an argument." 1>&2
			exit 1
			;;
	esac
done

# TODO fix bug with ld library path
unset LD_LIBRARY_PATH
		
# Wont work with simlinks
BASE_PATH="$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )"
echo "BASE_PATH: $BASE_PATH"
export Q_ROOT="${Q_ROOT:=${HOME}/Q}"
echo "Q_ROOT: $Q_ROOT"
mkdir -p $Q_ROOT/include 
mkdir -p $Q_ROOT/lib
# export PATH=$PATH:$HOME/TERRA_STUFF/terra-Linux-x86_64-2fa8d0a/bin
export Q_SRC_ROOT="${Q_SRC_ROOT:=$BASE_PATH}"
echo "Q_SRC_ROOT: $Q_SRC_ROOT"
LUA_INIT_PATH="@`echo $Q_SRC_ROOT`/init.lua"
# echo $LUA_INIT_PATH
export LUA_INIT="${LUA_INIT:=$LUA_INIT_PATH}"
echo "LUA_INIT: $LUA_INIT"
# Setting ld library path based on lua init
#export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$Q_ROOT/lib"
set +m
lua -e "print('hey')" &>/dev/null
RET=`echo $?`
if [[ "$RET" -ne "0" ]]; then
    `lua| tail -1`
fi
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
C_FLAGS=' -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic -fopenmp'
export QC_FLAGS="${QC_FLAGS:=$C_FLAGS}"
echo "QC_FLAGS: $QC_FLAGS"


