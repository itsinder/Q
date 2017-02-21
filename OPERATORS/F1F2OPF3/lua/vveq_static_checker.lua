
require('is_base_qtype')

function vveq_static_checker(
  f1type, 
  f2type
  )
  local tmpl = 'cmp.tmpl'
  local subs = {}
  subs.fn = "vveq_" .. f1type .. "_" .. f2type 
  assert(is_base_qtype(f1type))
  assert(is_base_qtype(f2type))

  subs.in1type   = g_qtypes[f1type].ctype
  subs.in2type   = g_qtypes[f2type].ctype
  subs.comparison = "(a == b); "
  return subs, tmpl
end
