
function vvand_static_checker(
  f1type, 
  f2type
  )
  if ( ( f1type ~= "I1" ) or ( f2type ~= "I1" ) ) then
    print("and requires both operands to be I1")
    return nil
  end
  local tmpl = 'f1f2opf3.tmpl'
  local subs = {} ; 
  subs.fn = "vvand_" .. f1type .. "_" .. f2type 
  subs.in1type = assert(g_qtypes[f1type].ctype)
  subs.in2type = assert(g_qtypes[f2type].ctype)
  subs.returntype = assert(g_qtypes["I1"].ctype)
  subs.argstype = "void *"
  subs.c_code_for_operator = "c = a && b; "
  return subs, tmpl
end
