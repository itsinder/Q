#!/bibn/bash
set -e 
cd ../lua/
bash gen_files.sh
cd - 
gcc -g -std=gnu99 test_f_to_s.c -I../gen_inc -I../../../UTILS/inc \
  ../gen_src/_sum_F8.c \
  ../gen_src/_min_I4.c \
  ../gen_src/_max_I1.c \
  ../gen_src/_sum_sqr_I8.c \
  -o a.out
valgrind ./a.out 2>_x
set +e
grep 'ERROR SUMMARY' _x | grep ' 0 errors' 1>/dev/null 2>&1
status=$?
if [ $status != 0 ]; then echo FAILURE; else echo SUCCESS; fi 
set -e 
#-------------------
rm _x
rm -f a.out
echo "Completed $0 in $PWD"
