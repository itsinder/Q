#!/bin/bash
set -e 
gcc -c -std=gnu99 txt_to_f.c  -I../../UTILS/inc
gcc -c -std=gnu99 txt_to_d.c  -I../../UTILS/inc
gcc -c -std=gnu99 txt_to_b.c  -I../../UTILS/inc
gcc -c -std=gnu99 txt_to_s.c  -I../../UTILS/inc
gcc -c -std=gnu99 txt_to_i.c  -I../../UTILS/inc
gcc -c -std=gnu99 txt_to_l.c  -I../../UTILS/inc
echo "COMPLETED SUCCESSFULLY"
# Now generate header files using ../../UTILS/src/extract_func_decl.lua
