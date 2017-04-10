#!/bin/bash
set -e
export Q_SRC_ROOT=/home/ubuntu/Q
cd $Q_SRC_ROOT
git pull

cd $Q_SRC_ROOT/UTILS/src/
bash gen_files.sh

cd $Q_SRC_ROOT/OPERATORS/LOAD_CSV/lua/
bash gen_files.sh

cd $Q_SRC_ROOT/OPERATORS/LOAD_CSV/src/
bash gen_files.sh

cd $Q_SRC_ROOT/OPERATORS/LOAD_CSV/test/
bash test_get_cell.sh

cd $Q_SRC_ROOT/OPERATORS/LOAD_CSV/test/testcases/
bash test_load_csv.sh

#check whether night build txt file is present in LOAD_CSV/test/testcases folder
nightly_file=$Q_SRC_ROOT/OPERATORS/LOAD_CSV/test/testcases/nightly_build.txt
if [ -f $nightly_file ] 
then
 var1=$(cat $nightly_file)
 #echo "$var1"
else
 var1="Error in Creating LOAD TEST CASES"
fi

echo "$var1" | /usr/bin/mail -s "Q Unit Tests" vijaykumar.patel@gslab.com 


