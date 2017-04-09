#!/bin/bash
set -e 

cat vsadd_specialize.lua | \
  sed s'/vsadd_/vssub_/'g | \
  sed s'/c_code_for_operator = .*;/c_code_for_operator = "c = ( a - b );/'g \
  > vssub_specialize.lua

cat vsadd_specialize.lua | \
  sed s'/vsadd_/vsmul_/'g | \
  sed s'/c_code_for_operator = .*;/c_code_for_operator = "c = ( a * b );/'g \
  > vsmul_specialize.lua

cat vsadd_specialize.lua | \
  sed s'/vsadd_/vsdiv_/'g | \
  sed s'/c_code_for_operator = .*;/c_code_for_operator = "c = ( a \/ b );/'g \
  > vsdiv_specialize.lua

#-----------------------------------------------
cat vsrem_specialize.lua | \
  sed s'/vsrem_/vsand_/'g | \
  sed s'/c_code_for_operator = .*;/c_code_for_operator = "c = ( a \& b );/'g \
  > vsand_specialize.lua

cat vsrem_specialize.lua | \
  sed s'/vsrem_/vsor_/'g | \
  sed s'/c_code_for_operator = .*;/c_code_for_operator = "c = ( a | b );/'g \
  > vsor_specialize.lua

cat vsrem_specialize.lua | \
  sed s'/vsrem_/vsxor_/'g | \
  sed s'/c_code_for_operator = .*;/c_code_for_operator = "c = ( a ^ b );/'g \
  > vsxor_specialize.lua

#-----------------------------------------------
cat vseq_specialize.lua | sed s'/vseq_/vsneq_/'g | \
  sed s"/comparison = .*/comparison = ' != ' /"g > vsneq_specialize.lua

cat vseq_specialize.lua | sed s'/vseq_/vsgt_/'g | \
  sed s"/comparison = .*/comparison = ' > ' /"g > vsgt_specialize.lua

cat vseq_specialize.lua | sed s'/vseq_/vslt_/'g | \
  sed s"/comparison = .*/comparison = ' < ' /"g > vslt_specialize.lua

cat vseq_specialize.lua | sed s'/vseq_/vsgeq_/'g | \
  sed s"/comparison = .*/comparison = ' >= ' /"g > vsgeq_specialize.lua

cat vseq_specialize.lua | sed s'/vseq_/vsleq_/'g | \
  sed s"/comparison = .*/comparison = ' <= ' /"g > vsleq_specialize.lua

#-----------------------------------------------
cat vsltorgt_specialize.lua | \
  sed s'/vsltorgt_/vsleqorgeq_/'g | \
  sed s"/comp1 = .*/comp1 = ' <= ' /"g | \
  sed s"/comp2 = .*/comp2 = ' >= ' /"g \
  > vsleqorgeq_specialize.lua

cat vsltorgt_specialize.lua | \
  sed s'/vsltorgt_/vsgeqandleq_/'g | \
  sed s'/ || / \&\& /'g | \
  sed s"/comp1 = .*/comp1 = ' >= ' /"g | \
  sed s"/comp2 = .*/comp2 = ' <= ' /"g \
  > vsgeqandleq_specialize.lua

cat vsltorgt_specialize.lua | \
  sed s'/vsltorgt_/vsgtandlt_/'g | \
  sed s'/ || / \&\& /'g | \
  sed s"/comp1 = .*/comp1 = ' > ' /"g | \
  sed s"/comp2 = .*/comp2 = ' < ' /"g \
  > vsgtandlt_specialize.lua

