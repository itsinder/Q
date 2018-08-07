#!/bin/bash
gcc -g -std=gnu99 driver.c qsort2.c -I.

./a.out

rm a.out
