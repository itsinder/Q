#!/bin/bash
set -e 

rm -rf ../gen_inc ; mkdir -p ../gen_inc 
mkdir -p ../gen_src ; rm -rf ../gen_src 

INCS="-I../gen_inc -I$Q_SRC_ROOT/UTILS/inc/ "
test -d $Q_SRC_ROOT
UDIR=$Q_SRC_ROOT/UTILS/lua/
test -d $UDIR
lua $UDIR/cli_extract_func_decl.lua ../src/SC_to_txt.c ../gen_inc/
lua generator.lua 
#----------------------
cd ../src/
gcc -c $QC_FLAGS SC_to_txt.c $INCS
#----------------------
cd ../gen_src/
ls *c > _x
while read line; do
  echo $line
  gcc -c $line ${QC_FLAGS} $INCS
done< _x
#----------------------
gcc $Q_LINK_FLAGS ../gen_src/*.o ../src/*.o -o libprint.so
cp libprint.so $Q_ROOT/lib/
rm -f *.o
rm -f _x
cd -
#-------------------------
echo "ALL DONE; $0 in $PWD"
