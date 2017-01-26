cat vvadd_static_checker.lua | \
  sed s'/vvadd_/vvsub_/'g | \
  sed s'/scalar_op = .*$/scalar_op = "c = ( a - b )" /'g \
  > vvsub_static_checker.lua

cat vvadd_static_checker.lua | \
  sed s'/vvadd_/vvmul_/'g | \
  sed s'/scalar_op = .*$/scalar_op = "c = ( a * b )" /'g \
  > vvmul_static_checker.lua

cat vvadd_static_checker.lua | \
  sed s'/vvadd_/vvdiv_/'g | \
  sed s'/scalar_op = .*$/scalar_op = "c = ( a \/ b )" /'g \
  > vvdiv_static_checker.lua

cat vvand_static_checker.lua | \
  sed s'/vvand_/vvor_/'g | \
  sed s'/scalar_op = .*$/scalar_op = "c = ( a || b )" /'g \
  > vvor_static_checker.lua

cat vvand_static_checker.lua | \
  sed s'/vvand_/vvxor_/'g | \
  sed s'/scalar_op = .*$/scalar_op = "c = ( a ^ b )" /'g \
  > vvxor_static_checker.lua

# why does following not work TODO
# cat vvand_static_checker.lua | \
#   sed s'/vvand_/vvandnot/'g | \
#   sed s'/scalar_op = .*$/scalar_op = "( a && (\~b) )" /'g \
#   > vvandnot_static_checker.lua

cat vveq_static_checker.lua | \
  sed s'/vveq_/vvneq_/'g | \
  sed s'/scalar_op = .*$/scalar_op = "c = ( a != b )" /'g \
  > vvneq_static_checker.lua

cat vveq_static_checker.lua | \
  sed s'/vveq_/vvgt_/'g | \
  sed s'/scalar_op = .*$/scalar_op = "c = ( a > b )" /'g \
  > vvgt_static_checker.lua

cat vveq_static_checker.lua | \
  sed s'/vveq_/vvlt_/'g | \
  sed s'/scalar_op = .*$/scalar_op = "c = ( a < b )" /'g \
  > vvlt_static_checker.lua

cat vveq_static_checker.lua | \
  sed s'/vveq_/vvgeq_/'g | \
  sed s'/scalar_op = .*$/scalar_op = "c = ( a >= b )" /'g \
  > vvgeq_static_checker.lua

cat vveq_static_checker.lua | \
  sed s'/vveq_/vvleq_/'g | \
  sed s'/scalar_op = .*$/scalar_op = "c = ( a <= b )" /'g \
  > vvleq_static_checker.lua

cat vveq_static_checker.lua | \
  sed s'/vveq_/vvneq_/'g | \
  sed s'/scalar_op = .*$/scalar_op = "c = ( a != b )" /'g \
  > vvneq_static_checker.lua

