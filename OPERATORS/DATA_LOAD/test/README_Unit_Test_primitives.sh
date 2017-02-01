#For unit testing primitives 
#Compile + run instructions:
#1) Change the directory to Q/OPERATORS/DATA_LOAD/test

#2) Compile the C code and create the QFunc.so file, the command is:
gcc -fPIC -shared -o UTCFile.so UTCFile.c

#3) Then run the UTLFile.lua file, the command is:
luajit UTLFile.lua 

#Note: The value of n in UTLFile.lua specifies the length of two arrays which you can change accordingly.
