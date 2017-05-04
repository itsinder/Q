#!/bin/bash
set +e
export Q_SRC_ROOT="`pwd`"
cd $Q_SRC_ROOT
git pull

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
cd $Q_SRC_ROOT/OPERATORS/MK_COL/test/testcases/
bash test_mkcol.sh
cd $Q_SRC_ROOT/Q2/code/test_cases/
bash test_vector.sh


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

#check whether night build txt file for load is present in DATA_LOAD/test/testcases folder
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

#check whether night build txt file for MK_COL is present in MK_COL/test/testcases folder
nightly_file=$Q_SRC_ROOT/OPERATORS/MK_COL/test/testcases/nightly_build_mkcol.txt
if [ -f $nightly_file ] 
then
 var6=$(cat $nightly_file)
 #echo "$var1"
else
 var6="Error in Creating MK_COL TEST CASES"
fi
rm $nightly_file

#check whether night build txt file for Vector is present in MK_COL/test/testcases folder
nightly_file=$Q_SRC_ROOT/Q2/code/test_cases/nightly_build_vector.txt
if [ -f $nightly_file ] 
then
 var7=$(cat $nightly_file)
 #echo "$var1"
else
 var7="Error in Creating Vector TEST CASES"
fi
rm $nightly_file


var100="${var1}"$'\n\n'"${var2}"$'\n\n'"${var3}"$'\n\n'"${var4}"$'\n\n'"${var5}"$'\n\n'"${var6}"$'\n\n'"${var7}"

cd $Q_SRC_ROOT/UTILS/build
export LUA_INIT="@$Q_SRC_ROOT/init.lua"
unset LD_LIBRARY_PATH
`lua | tail -1`
var80="------------OUTPUT of lua build.lua gen.lua--------------------------------------"
var81=$(lua build.lua gen.lua 2>&1)
var82="------------OUTPUT of lua build.lua tests.lua------------------------------------"
var83=$(lua build.lua tests.lua 2>&1)
var84="------------OUTPUT of lua mk_so.lua /tmp/----------------------------------------"
var85=$(lua mk_so.lua /tmp/ 2>&1)

var100="${var100}"$'\n\n'"${var80}"$'\n\n'"${var81}"$'\n\n'"${var82}"$'\n\n'"${var83}"$'\n\n'"${var84}"$'\n\n'"${var85}"
#echo "$var100" 

attach_file=$Q_SRC_ROOT/Q2/code/test_cases/vector.report.txt
if [ -f $attach_file ] 
then
 varattach="-A "$attach_file
fi


attach_file=$Q_SRC_ROOT/UTILS/test/dictionary.report.txt
if [ -f $attach_file ] 
then
 varattach=$varattach" -A "$attach_file
fi


attach_file=$Q_SRC_ROOT/OPERATORS/LOAD_CSV/test/testcases/load_csv.report.txt
if [ -f $attach_file ] 
then
 varattach=$varattach" -A "$attach_file
fi


attach_file=$Q_SRC_ROOT/OPERATORS/DATA_LOAD/test/testcases/data_load.report.txt
if [ -f $attach_file ] 
then
 varattach=$varattach" -A "$attach_file
fi


attach_file=$Q_SRC_ROOT/OPERATORS/PRINT/test/print_csv.report.txt
if [ -f $attach_file ] 
then
 varattach=$varattach" -A "$attach_file
fi

attach_file=$Q_SRC_ROOT/OPERATORS/MK_COL/test/testcases/mk_col.report.txt
if [ -f $attach_file ] 
then
 varattach=$varattach" -A "$attach_file
fi

# echo $varattach

echo "$var100" | /usr/bin/mail -s "Q Unit Tests" projectq@gslab.com,isingh@nerdwallet.com,rsubramonian@nerdwallet.com $varattach

