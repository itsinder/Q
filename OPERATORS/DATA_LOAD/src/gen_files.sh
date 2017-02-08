#!/bin/bash
set -e 
# TODO. Don't want to have to provide path for Lua utilities
lua ../../../UTILS/lua/extract_func_decl.lua txt_to_SC.c ../gen_inc/
