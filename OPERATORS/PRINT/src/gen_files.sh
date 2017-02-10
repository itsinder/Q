#!/bin/bash
set -e 
# TODO. Don't want to have to provide path for Lua utilities
lua ../../../UTILS/lua/extract_func_decl.lua SC_to_txt.c ../gen_inc/
