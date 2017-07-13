#!/bin/bash
set -e 
gcc $QC_FLAGS \
  test_vec.c \
  ../src/vec.c \
  ../src/mmap.c \
  ../src/mix_UI4.c \
  ../src/mix_UI8.c \
  ../src/get_file_size.c \
  ../src/rand_file_name.c \
  -I../inc/ -I../gen_inc/ -o a.out
valgrind  --show-leak-kinds=all --leak-check=full ./a.out
echo SUCCESS for $0
