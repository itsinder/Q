
require('is_base_qtype')

function vveq_static_checker(
  f1type, 
  f2type
  )
  local tmpl = 'f1f2opf3_cmp.tmpl'
  local subs = {}
  subs.fn = "vveq_" .. f1type .. "_" .. f2type 
  assert(is_base_qtype(f1type))
  assert(is_base_qtype(f2type))

  subs.in1type   = f1type
  subs.in2type   = f2type
  subs.comparison = "(a == b); "
  return subs, tmpl
end
