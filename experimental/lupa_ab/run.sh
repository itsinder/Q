#!/bin/bash
set -e
gcc -std=gnu99 -shared -fPIC core.c -o lib_ab.so
echo "Created lib_ab.so"
