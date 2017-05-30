return function (
  qtype
  )
    local is_base_qtype = require('UTILS/lua/is_base_qtype')
    local tmpl = 'reduce.tmpl'
    local subs = {}
    if ( qtype == "B1" ) then
      assert(nil, "TODO")
    else
      assert(is_base_qtype(qtype), "qtype must be base type")
      subs.op = "min"
      subs.fn = subs.op .. "_" .. qtype 
      subs.ctype = g_qtypes[qtype].ctype
      subs.qtype = qtype
      subs.reduce_ctype = subs.ctype
      if ( qtype == "I1" ) then subs.init_val = "INT8_MAX" end
      if ( qtype == "I2" ) then subs.init_val = "INT16_MAX" end
      if ( qtype == "I4" ) then subs.init_val = "INT32_MAX" end
      if ( qtype == "I8" ) then subs.init_val = "INT64_MAX" end
      if ( qtype == "F4" ) then subs.init_val = "FLT_MAX" end
      if ( qtype == "F8" ) then subs.init_val = "DBL_MAX" end
      assert(subs.init_val)
      subs.reducer = "mcr_min"
      subs.t_reducer = subs.reducer
    end
    return subs, tmpl
end
