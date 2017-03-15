
function vvandnot_specialize(
  f1type, 
  f2type
  )
  assert(f1type == "I8", "f1type must be I8")
  assert(f2type == "I8", "f2type must be I8")
  local outtype = "I8"
  local tmpl = 'bop.tmpl'
  local subs = {} ; 
  subs.fn = "vvand_" .. f1type .. "_" .. f2type 
  subs.c_code_for_operator = " c = ( a & ~b ) ; "
  return subs, tmpl
end
