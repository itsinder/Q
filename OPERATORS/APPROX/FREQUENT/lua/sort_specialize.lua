return function(elem_qtype)
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local subs = {}
  local tmpl = 'approx_frequent.tmpl'
  subs.elem_qtype = elem_qtype
  subs.fn = "approx_frequent_" .. elem_qtype
  subs.elem_ctype = qconsts.qtypes[elem_qtype].ctype
  return subs, tmpl
end
