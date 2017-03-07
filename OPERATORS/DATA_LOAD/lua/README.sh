#!/bin/bash 
set -e 

ld_library_add() {
    if [ -d "$1" ] && [[ ":$LD_LIBRARY_PATH:" != *":$1:"* ]]; then
       LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+"$LD_LIBRARY_PATH:"}$1"	
       export LD_LIBRARY_PATH
    fi
}

# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
SCRIPT_PATH=$(dirname "$SCRIPT")
echo $SCRIPT_PATH


#Clean all directory first
rm -rf ../gen_inc ../gen_src ../obj ./out ./metadata

#create all the required directory
mkdir ../gen_src ../gen_inc ../obj ./out ./metadata

#generate files
bash $SCRIPT_PATH/gen_files.sh

#generate libq_c_functions
gcc -std=gnu99 \
  -o ../obj/libq_c_functions.so \
  ../src/txt_to_SC.c \
  ../gen_src/_txt_to_I1.c \
  ../gen_src/_txt_to_I2.c \
  ../gen_src/_txt_to_I4.c \
  ../gen_src/_txt_to_I8.c \
  ../gen_src/_txt_to_F4.c \
  ../gen_src/_txt_to_F8.c \
  ../../../UTILS/src/is_valid_chars_for_num.c \
  -fPIC -shared \
  -I../../../UTILS/inc/ \
  -I../gen_inc/

#generate libq_c_print_functions
cd ../../PRINT/lua
bash README.sh

cd $SCRIPT_PATH

#generate vector_map.so
cd ../../../Q2/code
make

cd $SCRIPT_PATH

ld_library_add ../../../Q2/code/
ld_library_add ../obj/
ld_library_add ../../PRINT/obj/ 

meta_data_file=../test/meta.txt
data_file=../test/test.csv
luajit main.lua $meta_data_file $data_file

echo "Completed $0 in $PWD" # TODO
