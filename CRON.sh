#!/bin/bash
set +e
export Q_SRC_ROOT=/home/ubuntu/Q
cd $Q_SRC_ROOT
git pull

cd $Q_SRC_ROOT/UTILS/src/
bash gen_files.sh
cd $Q_SRC_ROOT/Q2/code/src/
bash gen_files.sh
cd $Q_SRC_ROOT/OPERATORS/LOAD_CSV/lua/
bash gen_files.sh
cd $Q_SRC_ROOT/OPERATORS/LOAD_CSV/src/
bash gen_files.sh
cd $Q_SRC_ROOT/OPERATORS/LOAD_CSV/test/testcases/
bash test_meta_data.sh
cd $Q_SRC_ROOT/OPERATORS/LOAD_CSV/test/testcases/
bash test_load_csv.sh
cd $Q_SRC_ROOT/OPERATORS/DATA_LOAD/test/testcases/
bash test_load_csv.sh
cd $Q_SRC_ROOT/OPERATORS/PRINT/test/
bash test_print_csv.sh
cd $Q_SRC_ROOT/UTILS/test/
bash test_dictionary.sh


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
 var2="Error in Creating LOAD_CSV TEST CASES"
fi
rm $nightly_file

#check whether night build txt file for load is present in LOAD_CSV/test/testcases folder
nightly_file=$Q_SRC_ROOT/OPERATORS/DATA_LOAD/test/testcases/nightly_build_load.txt
if [ -f $nightly_file ] 
then
 var3=$(cat $nightly_file)
 #echo "$var1"
else
 var3="Error in Creating DATA_LOAD TEST CASES"
fi
rm $nightly_file



#check whether night build txt file for PRINT is present in PRINT/test folder
nightly_file=$Q_SRC_ROOT/OPERATORS/PRINT/test/nightly_build_print.txt
if [ -f $nightly_file ] 
then
 var4=$(cat $nightly_file)
 #echo "$var1"
else
 var4="Error in Creating PRINT TEST CASES"
fi
rm $nightly_file

#check whether night build txt file for PRINT is present in PRINT/test folder
nightly_file=$Q_SRC_ROOT/UTILS/test/nightly_build_dictionary.txt
if [ -f $nightly_file ] 
then
 var5=$(cat $nightly_file)
 #echo "$var5"
else
 var5="Error in Creating DICTIONARY TEST CASES"
fi
rm $nightly_file

#concat all the 4 variables
var100="${var1}"$'\n\n'"${var2}"$'\n\n'"${var3}"$'\n\n'"${var4}"$'\n\n'"${var5}"
# echo "$var100"
echo "$var100" | /usr/bin/mail -s "Q Unit Tests" projectq@gslab.com,isingh@nerdwallet.com,rsubramonian@nerdwallet.com 


