#!/bibn/bash
set -e 
cd ../lua/
bash gen_files.sh
cd - 
gcc -g -std=gnu99 concat.c \
  -I../gen_inc -I../../../UTILS/inc \
  ../gen_src/_concat_I1_I2_I4.c
valgrind ./a.out 2>_x
set +e
grep 'ERROR SUMMARY' _x | grep ' 0 errors' 1>/dev/null 2>&1
status=$?
if [ $status != 0 ]; then echo VG: FAILURE; else echo VG: SUCCESS; fi 
set -e 
#-------------------
gcc -g -std=gnu99 eq.c \
  -I../gen_inc -I../../../UTILS/inc \
  ../gen_src/_vveq_F4_F8.c 
valgrind ./a.out 2>_x
set +e
grep 'ERROR SUMMARY' _x | grep ' 0 errors' 1>/dev/null 2>&1
status=$?
if [ $status != 0 ]; then echo VG: FAILURE; else echo VG: SUCCESS; fi 
set -e 
#-------------------
rm _x
echo "Completed $0 in $PWD"
