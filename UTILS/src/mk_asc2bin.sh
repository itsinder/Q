#!/bin/bash
set -e
cd ../../OPERATORS/DATA_LOAD/lua/
bash gen_files.sh
cd -
cd ../../OPERATORS/DATA_LOAD/src/
bash gen_files.sh
cd -

gcc -std=gnu99 \
  asc2bin.c \
  is_valid_chars_for_num.c \
  ../../OPERATORS/DATA_LOAD/src/txt_to_SC.c \
  ../../OPERATORS/DATA_LOAD/gen_src/_txt_to_I1.c \
  ../../OPERATORS/DATA_LOAD/gen_src/_txt_to_I2.c \
  ../../OPERATORS/DATA_LOAD/gen_src/_txt_to_I4.c \
  ../../OPERATORS/DATA_LOAD/gen_src/_txt_to_I8.c \
  ../../OPERATORS/DATA_LOAD/gen_src/_txt_to_F4.c \
  ../../OPERATORS/DATA_LOAD/gen_src/_txt_to_F8.c \
  -I../inc/ \
  -I../../OPERATORS/DATA_LOAD/gen_inc/  \
  -I../../OPERATORS/DATA_LOAD/inc/  \
  -o asc2bin
# chmod +x txt_to_bin
# Run some basic tests
./asc2bin inF4.csv F4 _xx
od -f _xx > _yy
diff _yy chk_inF4.txt
#------------
./asc2bin inI4.csv I4 _xx
od -i _xx > _yy
diff _yy chk_inI4.txt
#------------
rm -f _xx _yy

echo "Completed $0 in $PWD"
