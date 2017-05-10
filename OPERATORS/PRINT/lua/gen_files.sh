#!/bin/bash
set -e 

rm -rf ../gen_inc ../gen_src 
mkdir -p ../gen_inc 
mkdir -p ../gen_src 

test -d $Q_SRC_ROOT
UDIR=$Q_SRC_ROOT/UTILS/lua/
test -d $UDIR
lua $UDIR/cli_extract_func_decl.lua ../src/SC_to_txt.c ../gen_inc/
lua gen_c_code_for_print.lua 
#----------------------
cd ../src/
gcc -c SC_to_txt.c ${QC_FLAGS} -I../gen_inc -I../../../UTILS/inc/ -Wall -std=gnu99
cd ../gen_src/
ls *c > _x
while read line; do
  echo $line
  gcc -c $line ${QC_FLAGS} -I../gen_inc -I../../../UTILS/inc/ -Wall -std=gnu99
done< _x
rm -f *.o
rm -f _x
cd -
#-------------------------
echo "ALL DONE; $0 in $PWD"
