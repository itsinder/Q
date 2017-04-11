function vsadd_specialize(
  ftype
  )
    assert(( ftype == "I1" ) or ( ftype == "I2") or ( ftype == "I4" ) or 
       ( ftype == "I8" ) or ( ftype == "F4") or ( ftype == "F8" ),
       "type must be I1/I2/I4/I8/F4/F8")
    local tmpl = 'arith.tmpl'
    local subs = {}; 
    subs.fn = "vsadd_" .. ftype 
    subs.fldtype = g_qtypes[ftype].ctype
    subs.c_code_for_operator = "c = a + b; "
    return subs, tmpl
end
