#!/bin/bash # TODO
set -e 
# ASSIGNMENT:2 CSV_LOAD
#Compile + run instructions:

#1) Change the directory to Q/OPERATORS/DATA_LOAD/lua

# Generate txt_to_*.c and txt_to_*.h files 
bash README.sh
#2) Compile the C code and create the QFunc.so file, the command is:
#gcc -fPIC -shared -o ../src/QCFunc.so ../src/QCFunc.c

gcc -std=gnu99 \
  -o ../obj/QCFunc.o \
  ../src/QCFunc.c \
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
# echo PREMATURE; exit;

#3) If out and metadata directory doesnot exists then create the directory ./out and ./metadata .. here the output files (binary files and null files) will be stored.
#If out, metadata directory exists then remove and create new directories:
if [ -d "out" ]; then 
  rm -r -f out
fi
mkdir out

if [ -d "metadata" ]; then
  rm -r -f metadata
fi
mkdir metadata

#4) If you want to use your CSV file then In main.lua file set the path of csv file which u will give as the input file:
#e.g.: local csv_file_path_name = "../test/csv_inputfile1.csv"

#5) If you are using your CSV file then adjust the metadata M according to the respective CSV file in main.lua

#6) Then run the main.lua file, the command is:
# Following will be in a loop testing several combinations TODO
meta_data_file=meta.lua
data_file=t1.csv
luajit main.lua $meta_data_file $data_file

############## REMAINING Things ############

# - Dictionary for varchar -- testing
# - NULL value handing --testing
# - File Name : what pattern to use to make it 16 characters long
# - Deleting null vector file, if null value is not found in input
# - Fix size string 
# - Custom datatype (ts example given in csv_load.pdf)

echo "Completed $0 in $PWD" # TODO
