#!/bin/bash
set -e 

cat vvand_specialize.lua | \
  sed s'/vvand/vvor/'g | \
  sed s'/c_code_for_operator = .*;/c_code_for_operator = "c = ( a || b );/'g \
  > vvor_specialize.lua

cat vvand_specialize.lua | \
  sed s'/vvand/vvxor/'g | \
  sed s'/c_code_for_operator = .*;/c_code_for_operator = "c = ( a ^ b );/'g \
  > vvxor_specialize.lua

echo "Completed $0"
