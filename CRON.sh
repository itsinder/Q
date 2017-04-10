#!/bin/bash
set +e
export Q_SRC_ROOT=/home/ubuntu/Q
cd $Q_SRC_ROOT
git pull

cd $Q_SRC_ROOT/UTILS/build/
var=$(luajit build.lua)

#check whether night build txt file for metadata is present in LOAD_CSV/test/testcases folder
nightly_file=$Q_SRC_ROOT/OPERATORS/LOAD_CSV/test/testcases/nightly_build_metadata.txt
if [ -f $nightly_file ] 
then
 var1=$(cat $nightly_file)
 #echo "$var1"
else
 var1="Error in Creating METADATA TEST CASES"
fi
rm $nightly_file

#check whether night build txt file for load is present in LOAD_CSV/test/testcases folder
nightly_file=$Q_SRC_ROOT/OPERATORS/LOAD_CSV/test/testcases/nightly_build_load.txt
if [ -f $nightly_file ] 
then
 var2=$(cat $nightly_file)
 #echo "$var1"
else
 var2="Error in Creating LOAD TEST CASES"
fi
rm $nightly_file

#check whether night build txt file for PRINT is present in PRINT/test folder
nightly_file=$Q_SRC_ROOT/OPERATORS/PRINT/test/nightly_build_print.txt
if [ -f $nightly_file ] 
then
 var3=$(cat $nightly_file)
 #echo "$var1"
else
 var3="Error in Creating LOAD TEST CASES"
fi
rm $nightly_file

#concat all the 3 variables
var4="${var1}"$'\n\n'"${var2}"$'\n\n'"${var3}"
echo "$var4" | /usr/bin/mail -s "Q Unit Tests" projectq@gslab.com,isingh@nerdwallet.com,rsubramonian@nerdwallet.com 


