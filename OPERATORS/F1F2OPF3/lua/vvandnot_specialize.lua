
function vvandnot_specialize(
  f1type, 
  f2type
  )
  assert(f1type == "B1", "f1type must be B1")
  assert(f2type == "B1", "f2type must be B1")
  local tmpl = 'bop.tmpl'
  local subs = {} ; 
  subs.fn = "vvandnot"
  subs.outtype = "B1"
  subs.out_c_type = "uint64_t"
  subs.c_code_for_operator = " c = ( a & ~b ) ; "
  return subs, tmpl
end
