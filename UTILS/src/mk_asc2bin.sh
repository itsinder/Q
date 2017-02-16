#!/bin/bash
set -e
cd ../../OPERATORS/DATA_LOAD/lua/
bash gen_files.sh
cd -
cd ../../OPERATORS/DATA_LOAD/src/
bash gen_files.sh
cd -

cd ../../OPERATORS/PRINT/lua/
bash gen_files.sh
cd -

cd ../../OPERATORS/PRINT/src/
bash gen_files.sh
cd -

gcc -g -std=gnu99 \
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

gcc -g -std=gnu99 \
  bin2asc.c \
  mmap.c  \
  is_valid_chars_for_num.c \
  ../../OPERATORS/DATA_LOAD/gen_src/_txt_to_I4.c \
  ../../OPERATORS/PRINT/src/SC_to_txt.c \
  ../../OPERATORS/PRINT/gen_src/_I1_to_txt.c \
  ../../OPERATORS/PRINT/gen_src/_I2_to_txt.c \
  ../../OPERATORS/PRINT/gen_src/_I4_to_txt.c \
  ../../OPERATORS/PRINT/gen_src/_I8_to_txt.c \
  ../../OPERATORS/PRINT/gen_src/_F4_to_txt.c \
  ../../OPERATORS/PRINT/gen_src/_F8_to_txt.c \
  -I../inc/ \
  -I../../OPERATORS/DATA_LOAD/gen_inc/  \
  -I../../OPERATORS/PRINT/gen_inc/  \
  -I../../OPERATORS/PRINT/inc/  \
  -o bin2asc
# chmod +x txt_to_bin
# Run some basic tests
./asc2bin inF4.csv F4 _xx
od -f _xx > _yy
diff _yy chk_inF4.txt
#------------
./asc2bin inI4.csv I4 _xx
od -i _xx > _yy
diff _yy chk_inI4.txt
echo PREMATURE; exit;
#------------
./asc2bin inSC.csv SC _xx 16 
od -c --width=16 _xx > _yy
diff _yy chk_inSC.csv
#---------------
rm -f _xx _yy

echo "Completed $0 in $PWD"
