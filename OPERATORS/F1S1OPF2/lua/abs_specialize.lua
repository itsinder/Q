return function (
  in_qtype
  )
local funcs = {I1 = "abs", I2 = "abs", I4 = "abs", I8 = "abs", F4 = "fabsf", F8 = "fabs"}
local code_for_ops = {I1 = "(int8_t)", I2 = "(int16_t)", I4 = "(int32_t)", I8 = "(int64_t)", F4 = "", F8 = ""}

  local qconsts = require 'Q/UTILS/lua/q_consts'
  local tmpl = 'f1opf2.tmpl'
  local subs = {}; 
  subs.fn = "abs_" .. in_qtype 
  subs.in_ctype = qconsts.qtypes[in_qtype].ctype
  subs.c_code_for_operator = "c = ".. code_for_ops[in_qtype] .. funcs[in_qtype] .."(a);"
  subs.out_qtype = in_qtype
  subs.out_ctype = qconsts.qtypes[subs.out_qtype].ctype
  subs.c_mem = nil
  return subs, tmpl
end
