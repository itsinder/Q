return function (
  ftype,
  scalars
  )
    assert(( ftype == "I1" ) or ( ftype == "I2") or ( ftype == "I4" ) or 
       ( ftype == "I8" ) or ( ftype == "F4") or ( ftype == "F8" ),
       "type must be I1/I2/I4/I8/F4/F8")
    local tmpl = 'f1s1opf2_cmp2.tmpl'
    local subs = {}; 
    if ( scalars ) then 
      assert((type(scalars) == "table"), "Need lb/ub sent as Lua table")
      local lb = assert(scalars.lb, "lb not specified")
      local ub = assert(scalars.ub, "ub not specified")
      assert((type(lb) == "string"), "lb not specified")
      assert((type(ub) == "string"), "lb not specified")
      -- TODO  convert lb/ub to appropriate c_types
    end
    subs.fn = "vsltorgt_" .. ftype 
    subs.fldtype = g_qtypes[ftype].ctype
    subs.comp1 = ' <  '
    subs.comp2 = ' >  '
    subs.combiner = ' ||  '
    subs.c_lb = 0 -- TODO 
    subs.c_ub = 0 -- TODO 
    subs.out_c_type = "uint8_t"
    return subs, tmpl
end
