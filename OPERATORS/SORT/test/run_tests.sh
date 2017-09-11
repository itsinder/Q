#!/bibn/bash
set -e 
cd ../lua/
bash gen_files.sh 
cd - 
gcc -g -std=gnu99  -I../gen_inc -I../../../UTILS/inc tst_sort.c ../gen_src/_qsort_asc_I4.c ../gen_src/_qsort_dsc_F8.c -o a.out
valgrind --leak-check=full ./a.out 2>_x1 
set +e
grep 'ERROR SUMMARY' _x1 | grep ' 0 errors' 1>/dev/null 2>&1
status=$?
if [ $status != 0 ]; then echo FAILURE; else echo SUCCESS; fi 
rm -f _*
echo "Completed $0 in $PWD"
