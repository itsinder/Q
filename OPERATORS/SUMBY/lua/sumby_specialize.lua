
return function (
  val_qtype, 
  grpby_qtype
  )
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local val_qtypes = { 'I1', 'I2', 'I4', 'I8', 'F4', 'F8' }
  local grpby_qtypes = { 'I1', 'I2', 'I4', 'I8' }
  assert(val_qtypes[val_qtype])
  assert(grpby_qtypes[grpby_qtype])
  if ( ( val_qtype == "F4" ) or ( val_qtype == "F8" ) ) then 
    out_qtype = "F8"
  else
    out_qtype = "I8"
  end
  local tmpl = 'f1f2opf3.tmpl'
  local subs = {}; 
  subs.fn = "vvadd_" .. val_qtype .. "_" .. grpby_qtype .. "_" .. out_qtype 
  subs.in1_ctype = qconsts.qtypes[val_qtype].ctype
  subs.in2_ctype = qconsts.qtypes[grpby_qtype].ctype
  subs.out_qtype = out_qtype
  subs.out_ctype = qconsts.qtypes[out_qtype].ctype
  subs.c_code_for_operator = "c = a + b; "
  return subs, tmpl
end
