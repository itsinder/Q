#!/bibn/bash
set -e 
make -C ../lua/
gcc -g -std=gnu99  \
  -I../gen_inc \
  -I../../../UTILS/inc \
  tst_idx_sort.c \
  ../gen_src/_qsort_asc_val_F8_idx_I4.c \
  ../gen_src/_qsort_dsc_val_I8_idx_I2.c \
  -o a.out
VG="valgrind --leak-check=full " 
$VG --leak-check=full ./a.out 2>_x1 
set +e
grep 'ERROR SUMMARY' _x1 | grep ' 0 errors' 1>/dev/null 2>&1
status=$?
if [ $status != 0 ]; then echo FAILURE; else echo SUCCESS; fi 
rm -f _x1
echo "Completed $0 in $PWD"
