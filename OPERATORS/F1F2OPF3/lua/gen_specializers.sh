#!/bin/bash
set -e 

cat vvadd_specialize.lua | \
  sed s'/vvadd_/vvsub_/'g | \
  sed s'/c_code_for_operator = .*;/c_code_for_operator = "c = ( a - b );/'g \
  > vvsub_specialize.lua

cat vvadd_specialize.lua | \
  sed s'/vvadd_/vvmul_/'g | \
  sed s'/c_code_for_operator = .*;/c_code_for_operator = "c = ( a * b );/'g \
  > vvmul_specialize.lua

cat vvadd_specialize.lua | \
  sed s'/vvadd_/vvdiv_/'g | \
  sed s'/c_code_for_operator = .*;/c_code_for_operator = "c = ( a \/ b );/'g \
  > vvdiv_specialize.lua

cat vvand_specialize.lua | \
  sed s'/vvand_/vvor_/'g | \
  sed s'/c_code_for_operator = .*;/c_code_for_operator = "c = ( a || b );/'g \
  > vvor_specialize.lua

cat vvand_specialize.lua | \
  sed s'/vvand_/vvxor_/'g | \
  sed s'/c_code_for_operator = .*;/c_code_for_operator = "c = ( a ^ b );/'g \
  > vvxor_specialize.lua

cat vveq_specialize.lua | \
  sed s'/vveq_/vvneq_/'g | \
  sed s'/comparison = .*;/comparison = "( a != b );/'g \
  > vvneq_specialize.lua

cat vveq_specialize.lua | \
  sed s'/vveq_/vvgt_/'g | \
  sed s'/comparison = .*;/comparison = "( a > b )/'g \
  > vvgt_specialize.lua

cat vveq_specialize.lua | \
  sed s'/vveq_/vvlt_/'g | \
  sed s'/comparison = .*;/comparison = "( a < b ;/'g \
  > vvlt_specialize.lua

cat vveq_specialize.lua | \
  sed s'/vveq_/vvgeq_/'g | \
  sed s'/comparison = .*;/comparison = "( a >= b )/'g \
  > vvgeq_specialize.lua

cat vveq_specialize.lua | \
  sed s'/vveq_/vvleq_/'g | \
  sed s'/comparison = .*;/comparison = "( a <= b )/'g \
  > vvleq_specialize.lua

cat vveq_specialize.lua | \
  sed s'/vveq_/vvneq_/'g | \
  sed s'/comparison = .*;/c_code_for_operator = "( a != b )/'g \
  > vvneq_specialize.lua

echo "Completed $0"
