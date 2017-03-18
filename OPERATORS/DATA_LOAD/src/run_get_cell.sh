#!/bin/bash
gcc -Wall -g -std=gnu99 \
  -I../../../UTILS/inc \
  get_cell.c \
  test_get_cell.c \
  -o _exec_get_cell
valgrind ./_exec_get_cell
