return function (
  in_qtype,
  scalar
  )
  local qconsts       = require "Q/UTILS/lua/q_consts"
  local Scalar        = require 'libsclr'

  assert( ( in_qtype == "I1" ) or ( in_qtype == "I2" ) or 
          ( in_qtype == "I4" ) or ( in_qtype == "I8" ) )
  stype = scalar:fldtype()
  assert( ( stype == "I1" ) or ( stype == "I2" ) or 
          ( stype == "I4" ) or ( stype == "I8" ) )
  sval = scalar:to_num()
  assert(sval >= 0)
  if ( in_qtype == "I1" ) then assert(sval <= 8 ) end 
  if ( in_qtype == "I2" ) then assert(sval <= 16 ) end 
  if ( in_qtype == "I4" ) then assert(sval <= 32 ) end 
  if ( in_qtype == "I8" ) then assert(sval <= 64 ) end 

  assert(nil, "TODO"()
  local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/F1S1OPF2/lua/arith.tmpl"
  local subs = {}; 
  subs.fn = "shift_right_" .. in_qtype 
  subs.in_ctype = qconsts.qtypes[in_qtype].ctype
  subs.c_code_for_operator = "c = a << b;"
  subs.args        = scalar:to_cmem()
  subs.args_ctype  = subs.in_ctype
  subs.in_qtype = in_qtype
  subs.out_qtype    = in_qtype
  subs.out_ctype    = qconsts.qtypes[subs.out_qtype].ctype
  subs.scalar_ctype = subs.out_ctype 
  return subs, tmpl
end