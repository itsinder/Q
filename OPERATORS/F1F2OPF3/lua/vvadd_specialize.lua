
return function (
  f1type, 
  f2type
  )
  local promote = require 'promote'
  out_qtype = promote(f1type, f2type)
  local tmpl = 'base.tmpl'
  local subs = {}; 
  subs.fn = "vvadd_" .. f1type .. "_" .. f2type .. "_" .. out_qtype 
  subs.in1type = g_qtypes[f1type].ctype
  subs.in2type = g_qtypes[f2type].ctype
  subs.out_qtype = out_qtype
  subs.out_ctype = g_qtypes[out_qtype].ctype
  subs.c_code_for_operator = "c = a + b; "
  return subs, tmpl
end
