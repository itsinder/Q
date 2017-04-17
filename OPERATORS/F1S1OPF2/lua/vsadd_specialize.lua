function vsadd_specialize(
  ftype,
  scalar
  )
    assert(( ftype == "I1" ) or ( ftype == "I2") or ( ftype == "I4" ) or 
       ( ftype == "I8" ) or ( ftype == "F4") or ( ftype == "F8" ),
       "type must be I1/I2/I4/I8/F4/F8")
    local tmpl = 'arith.tmpl'
    local subs = {}; 
    if ( scalar ) then 
      assert(type(scalar) == "string")
      -- TODO convert to 
      
    end
    -- scalar can be undefined while generating code at compile time 
    subs.fn = "vsadd_" .. ftype 
    subs.fldtype = g_qtypes[ftype].ctype
    subs.c_code_for_operator = "c = a + b; "
    subs.c_scalar = 0 -- TODO replace with address
    return subs, tmpl
end
