return function (
  f1type, 
  f2type
  )
  local is_base_qtype = require('is_base_qtype')
  local tmpl = 'f1f2opf3_cmp.tmpl'
  local subs = {}
  assert(is_base_qtype(f1type), "f1type must be base type")
  assert(is_base_qtype(f2type), "f2type must be base type")

  subs.fn = "vveq_" .. f1type .. "_" .. f2type 
  subs.in1type   = g_qtypes[f1type].ctype
  subs.in2type   = g_qtypes[f2type].ctype
  subs.out_c_type = "uint64_t"
  subs.comparison = " == "
  return subs, tmpl
end
