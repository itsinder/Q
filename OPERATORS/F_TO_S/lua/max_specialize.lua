return function (
  qtype
  )
    local is_base_qtype = require('is_base_qtype')
    local tmpl = 'reduce.tmpl'
    local subs = {}
    if ( qtype == "B1" ) then
      assert(nil, "TODO")
    else
      assert(is_base_qtype(qtype), "qtype must be base type")
      subs.op = "max"
      subs.fn = subs.op .. "_" .. qtype 
      subs.ctype = g_qtypes[qtype].ctype
      subs.qtype = qtype
      subs.reduce_ctype = subs.ctype
      if ( ctype == "I1" ) then subs.init_val = "INT8_MIN" end
      if ( ctype == "I2" ) then subs.init_val = "INT16_MIN" end
      if ( ctype == "I4" ) then subs.init_val = "INT32_MIN" end
      if ( ctype == "I8" ) then subs.init_val = "INT64_MIN" end
      if ( ctype == "F4" ) then subs.init_val = "FLT_MIN" end
      if ( ctype == "F8" ) then subs.init_val = "DBL_MIN" end
      assert(subs.init_val)
      subs.reducer = "mcr_max"
      subs.t_reducer = subs.reducer
    end
    return subs, tmpl
end
