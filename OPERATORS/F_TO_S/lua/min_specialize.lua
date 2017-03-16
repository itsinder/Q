require('is_base_qtype')
function min_specialize(
  intype
  )
    local tmpl = 'reduce.tmpl'
    local subs = {}
    if ( intype == "B1" ) then
      assert(nil, "TODO")
    else
      assert(is_base_qtype(intype), "intype must be base type")
      subs.fn = "min_" .. intype 
      subs.intype = g_qtypes[intype].ctype
      subs.disp_intype = intype
      if ( ( intype == "I1" ) or ( intype == "I2" ) or 
           ( intype == "I4" ) or ( intype == "I8" ) ) then
        subs.reduce_intype = "uint64_t" 
        subs.init_val = g_constants.INIT_VAL_FOR_INT_MIN
      else
        subs.init_val = g_constants.INIT_VAL_FOR_FLT_MIN
        subs.reduce_intype = "double" 
      end
      subs.reducer = "mcr_min"
    end
    return subs, tmpl
end
