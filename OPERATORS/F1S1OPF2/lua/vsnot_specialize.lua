return function (
  in_qtype
  )
  local qconsts = require 'Q/UTILS/lua/q_consts'
  assert(in_qtype == "B1", "Only B1 is supported")
  --preamble
  local tmpl = 'vsnot.tmpl'
  local subs = {}; 
  subs.fn = "vsnot_" .. in_qtype
  subs.in_ctype = qconsts.qtypes[in_qtype].ctype
  subs.in_qtype = in_qtype
  subs.out_qtype = in_qtype
  subs.out_ctype = qconsts.qtypes[subs.out_qtype].ctype
  subs.c_mem = nil
  return subs, tmpl
end
