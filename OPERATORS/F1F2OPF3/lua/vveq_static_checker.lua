
function vveq_static_checker(
  f1type, 
  f2type
  )
  returntype = "I1"
  local tmpl = 'f1f2opf3.tmpl'
  local subs = {}
  local incs = {}
  subs.fn = "vveq_" .. f1type .. "_" .. f2type 
  subs.in1type   = assert(g_qtypes[f1type].ctype)
  subs.in2type   = assert(g_qtypes[f2type].ctype)
  subs.returntype = assert(g_qtypes[returntype].ctype)
  subs.argstype = "void *"
  subs.c_code_for_operator = "c = (a == b); "
  return subs, incs, tmpl
end
