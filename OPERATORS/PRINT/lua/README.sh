#!/bin/bash 
set -e 

# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
SCRIPT_PATH=$(dirname "$SCRIPT")
echo $SCRIPT_PATH

#Clean all directory first
rm -rf ../gen_inc ../gen_src ../obj
rm -rf bin

#create all the required directory
mkdir ../gen_src ../gen_inc ../obj
mkdir bin

export Q_SRC_ROOT=../../../

bash gen_files.sh

gcc -std=gnu99 \
  -o ../obj/libq_c_print_functions.so \
  ../src/SC_to_txt.c \
  ../gen_src/_I1_to_txt.c \
  ../gen_src/_I2_to_txt.c \
  ../gen_src/_I4_to_txt.c \
  ../gen_src/_I8_to_txt.c \
  ../gen_src/_F4_to_txt.c \
  ../gen_src/_F8_to_txt.c \
  ../../../UTILS/src/is_valid_chars_for_num.c \
  -fPIC -shared \
  -I../../../UTILS/inc/ \
  -I../gen_inc/

gcc -std=gnu99 -shared \
  -o ../obj/libinitialize_vector.so \
  ../src/initialize_vector.c


#generate vector_map.so
cd ../../../Q2/code
make

export LD_LIBRARY_PATH=../../../Q2/code/:../obj/

cd $SCRIPT_PATH
luajit main.lua

echo "Completed $0 in $PWD" # TODO
