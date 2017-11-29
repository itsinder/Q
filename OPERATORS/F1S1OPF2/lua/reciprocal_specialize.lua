return function (
  in_qtype
  )
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
  assert(is_base_qtype(in_qtype), "Valid only for base qtypes")
  --preamble
  local tmpl = 'f1opf2.tmpl'
  local subs = {}; 
  subs.fn = "reciprocal_" .. in_qtype 
  subs.in_ctype = qconsts.qtypes[in_qtype].ctype
  subs.c_code_for_operator = "c = 1 / a; "
  subs.out_qtype = "F8"
  subs.out_ctype = qconsts.qtypes[subs.out_qtype].ctype
  subs.c_mem = nil
  return subs, tmpl
end