return function (
  ftype,
  scalar
  )
    assert(( ftype == "I1" ) or ( ftype == "I2") or ( ftype == "I4" ) or 
       ( ftype == "I8" ) or ( ftype == "F4") or ( ftype == "F8" ),
       "type must be I1/I2/I4/I8/F4/F8")
    local tmpl = 'f1s1opf2_cmp.tmpl'
    local subs = {}; 
    subs.fn = "vsltorgt_" .. ftype 
    subs.fldtype = g_qtypes[ftype].ctype
    subs.out_c_type = "uint8_t"
    subs.comparison = ' ==  '
    subs.c_mem = 0 -- TODO 
    return subs, tmpl
end
