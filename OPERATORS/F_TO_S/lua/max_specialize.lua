require('is_base_qtype')
function max_specialize(
  intype
  )
    local tmpl = 'reduce.tmpl'
    local subs = {}
    if ( intype == "B1" ) then
      assert(nil, "TODO")
    else
      assert(is_base_qtype(intype), "intype must be base type")
      subs.fn = "max_" .. intype 
      subs.intype = g_qtypes[intype].ctype
      subs.disp_intype = intype
      subs.reduce_intype = subs.intype
      if ( intype == "I1" ) then subs.init_val = "INT8_MIN" end
      if ( intype == "I2" ) then subs.init_val = "INT16_MIN" end
      if ( intype == "I4" ) then subs.init_val = "INT32_MIN" end
      if ( intype == "I8" ) then subs.init_val = "INT64_MIN" end
      if ( intype == "F4" ) then subs.init_val = "FLT_MIN" end
      if ( intype == "F8" ) then subs.init_val = "DBL_MIN" end
      assert(subs.init_val)
      subs.reducer = "mcr_max"
      subs.t_reducer = subs.reducer
    end
    return subs, tmpl
end
