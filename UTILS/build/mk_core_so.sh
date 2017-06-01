#!/bin/bash
test -d $Q_SRC_ROOT
test -f core_c_files.txt
INCS="-I../inc/ "
INCS="$INCS -I../gen_inc/"
INCS="$INCS -I${Q_SRC_ROOT}/OPERATORS/PRINT/gen_inc/"
INCS="$INCS -I${Q_SRC_ROOT}/OPERATORS/LOAD_CSV/gen_inc/"
rm -f *.o
while read line 
do
  gcc -c $QC_FLAGS $INCS "${Q_SRC_ROOT}/$line"
done < core_c_files.txt
gcc *.o $Q_LINK_FLAGS -o libq_core.so
rm -f *.o
cp libq_core.so $Q_ROOT/lib/
