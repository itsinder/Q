# ASSIGNMENT:2 CSV_LOAD
#Compile + run instructions:

#1) Change the directory to Q/OPERATORS/DATA_LOAD/lua

#2) Compile the C code and create the QFunc.so file, the command is:
gcc -fPIC -shared -o ../src/QCFunc.so ../src/QCFunc.c

#3) create the directory ./out and ./metadata .. here output file will be stored

#4) In main.lua file set the path of csv file which u will give as the input file:
#e.g.: local csv_file_path_name = "../test/csv_inputfile1.csv"  

#5) Adjust metadata in main.lua according to the csv file you are reading 

#6) Then run the main.lua file, the command is:
lua main.lua






############## REMAINING Things ############
# - fix size string 
# - Dictionary for varchar -- testing remaining
# - NULL value handing -- started working on the same
# - Metadta's ignore column .. i.e. setting the name as "" (empty string) in metadata 
# - Storing generated file in the directory specified by global variable -- testing remaining
# - custom datatype (ts example given in csv_load.pdf)
#
#
#
