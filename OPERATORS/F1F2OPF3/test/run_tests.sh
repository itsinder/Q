#!/bibn/bash
set -e 
INCS=" -I.  -I../../../UTILS/inc/ -I../gen_inc/ "
make -C ../lua/
#---------------
gcc -g ${INCS} ${QC_FLAGS} -Werror concat.c ../lua/libf1f2opf3.so
valgrind ./a.out 2>_x
set +e
grep 'ERROR SUMMARY' _x | grep ' 0 errors' 1>/dev/null 2>&1
status=$?
if [ $status != 0 ]; then echo VG: FAILURE; else echo VG: SUCCESS; fi 
set -e 
#-------------------
gcc -g ${INCS} ${QC_FLAGS} -Werror eq.c \
  ../gen_src/_vveq_F4_F8.c 
valgrind ./a.out 2>_x
set +e
grep 'ERROR SUMMARY' _x | grep ' 0 errors' 1>/dev/null 2>&1
status=$?
if [ $status != 0 ]; then echo VG: FAILURE; else echo VG: SUCCESS; fi 
set -e 
#-------------------
rm -f _*
echo "Completed $0 in $PWD"
