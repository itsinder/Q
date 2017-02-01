# ASSIGNMENT:2 CSV_LOAD
#Compile + run instructions:

#1) Change the directory to Q/OPERATORS/DATA_LOAD/lua

#2) Compile the C code and create the QFunc.so file, the command is:
#gcc -fPIC -shared -o ../src/QCFunc.so ../src/QCFunc.c
gcc -std=gnu99 -o ../src/QCFunc.so ../src/QCFunc.c ../src/txt_to_I1.c ../src/txt_to_I2.c ../src/txt_to_I4.c ../src/txt_to_I8.c ../src/txt_to_F4.c ../src/txt_to_F8.c ../src/txt_to_SC.c ../../../UTILS/src/is_valid_chars_for_num.c -fPIC -shared -I../../../UTILS/inc

#3) If out and metadata directory doesnot exists then create the directory ./out and ./metadata .. here the output files (binary files and null files) will be stored.
#If out, metadata directory exists then remove and create new directories:
if [ -d "out" ]; then 
  rm -r out
fi
mkdir out

if [ -d "metadata" ]; then
  rm -r metadata
fi
mkdir metadata

#4) If you want to use your CSV file then In main.lua file set the path of csv file which u will give as the input file:
#e.g.: local csv_file_path_name = "../test/csv_inputfile1.csv"

#5) If you are using your CSV file then adjust the metadata M according to the respective CSV file in main.lua

#6) Then run the main.lua file, the command is:
lua main.lua




############## REMAINING Things ############

# - Dictionary for varchar -- testing remaining
# - NULL value handing -- started working on the same
# - File Name : what pattern to use to make it 16 characters long
# - If output/metadata directory does not exists, then it should throw error
# - Deleting null vector file, if null value is not found in input
# - Integrate this with function created by Ramesh.
# - Fix size string 
# - Custom datatype (ts example given in csv_load.pdf)
