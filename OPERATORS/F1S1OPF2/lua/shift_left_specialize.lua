return function (
  in_qtype,
  scalar
  )
  local qconsts        = require "Q/UTILS/lua/q_consts"
  local Scalar         = require 'libsclr'
  local to_scalar      = require 'Q/UTILS/lua/to_scalar'
  local chk_shift_args = require 'Q/OPERATORS/F1S1OPF2/lua/chk_shift_args'

  local sval = assert(chk_shift_args(in_qtype, scalar))

  local lscalar = to_scalar(sval, "I4")

  local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/F1S1OPF2/lua/shift.tmpl"
  local subs = {}; 
  subs.fn = "shift_left_" .. in_qtype 
  subs.in_ctype = qconsts.qtypes[in_qtype].ctype
  subs.c_code_for_operator = "c = a << b;"
  subs.args        = lscalar:to_cmem()
  subs.args_ctype  = "int32_t "
  subs.in_qtype = in_qtype
  subs.cast_in_as = subs.in_ctype -- not same for shift righ
  subs.out_qtype    = subs.in_qtype
  subs.out_ctype    = qconsts.qtypes[subs.out_qtype].ctype
  subs.scalar_ctype = "int32_t "
  return subs, tmpl
end
