#!/bin/bash
rm -f *.o
set -e 
gcc -c -std=gnu99 txt_to_F4.c  -I../../UTILS/inc
gcc -c -std=gnu99 txt_to_F8.c  -I../../UTILS/inc
gcc -c -std=gnu99 txt_to_I1.c  -I../../UTILS/inc
gcc -c -std=gnu99 txt_to_I2.c  -I../../UTILS/inc
gcc -c -std=gnu99 txt_to_I4.c  -I../../UTILS/inc
gcc -c -std=gnu99 txt_to_I8.c  -I../../UTILS/inc

lua extract_func_decl.lua txt_to_I1.c > ../inc/txt_to_I1.h
lua extract_func_decl.lua txt_to_I2.c > ../inc/txt_to_I2.h
lua extract_func_decl.lua txt_to_I4.c > ../inc/txt_to_I4.h
lua extract_func_decl.lua txt_to_I8.c > ../inc/txt_to_I8.h
lua extract_func_decl.lua txt_to_F4.c > ../inc/txt_to_F4.h
lua extract_func_decl.lua txt_to_F8.c > ../inc/txt_to_F8.h

echo "COMPLETED SUCCESSFULLY"
# Now generate header files using ../../UTILS/src/extract_func_decl.lua
