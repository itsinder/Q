return function (
  in1_qtype
  )
  local promote = require 'Q/UTILS/lua/promote'
  local tmpl = 'lr_util.tmpl'
  local subs = {}; 
  subs.fn = "lr_util_" .. in1_qtype
  subs.in1_ctype = g_qtypes[in1_qtype].ctype
  subs.out1_qtype = in1_qtype
  subs.out2_qtype = in1_qtype
  subs.out1_ctype = g_qtypes[subs.out1_qtype].ctype
  subs.out2_ctype = g_qtypes[subs.out2_qtype].ctype
  return subs, tmpl
end
