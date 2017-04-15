#!/bibn/bash
set -e 
cd ../lua/
bash gen_files.sh
cd - 
gcc -g -std=gnu99 \
  test_ainb.c \
  ../../../UTILS/src/bytes_to_bits.c  \
  ../../../UTILS/src/bits_to_bytes.c \
  -I../gen_inc  \
  -I../../../UTILS/inc \
  -I../../../UTILS/gen_inc \
  ../gen_src/_ainb_I4_I8.c \
  -o a.out
VG=" "
VG=" valgrind "
$VG ./a.out 2>_x
set +e
grep 'ERROR SUMMARY' _x | grep ' 0 errors' 1>/dev/null 2>&1
status=$?
if [ $status != 0 ]; then echo VG: FAILURE; else echo VG: SUCCESS; fi 
set -e 
#-------------------
# rm _x
echo "Completed $0 in $PWD"