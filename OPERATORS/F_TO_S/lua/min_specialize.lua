return function (
  intype
  )
  local is_base_qtype = require('is_base_qtype')
    local tmpl = 'reduce.tmpl'
    local subs = {}
    if ( intype == "B1" ) then
      assert(nil, "TODO")
    else
      assert(is_base_qtype(intype), "intype must be base type")
      subs.fn = "min_" .. intype 
      subs.intype = g_qtypes[intype].ctype
      subs.disp_intype = intype
      subs.reduce_intype = subs.intype
      if ( intype == "I1" ) then subs.init_val = "INT8_MAX" end
      if ( intype == "I2" ) then subs.init_val = "INT16_MAX" end
      if ( intype == "I4" ) then subs.init_val = "INT32_MAX" end
      if ( intype == "I8" ) then subs.init_val = "INT64_MAX" end
      if ( intype == "F4" ) then subs.init_val = "FLT_MAX" end
      if ( intype == "F8" ) then subs.init_val = "DBL_MAX" end
      assert(subs.init_val)
      subs.reducer = "mcr_min"
      subs.t_reducer = subs.reducer
    end
    return subs, tmpl
end
