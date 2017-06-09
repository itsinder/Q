local qconsts = require 'Q/UTILS/lua/q_consts'
return function (
  qtype
  )
    local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
    local tmpl = 'reduce.tmpl'
    local subs = {}
    if ( qtype == "B1" ) then
      assert(nil, "TODO")
    else
      assert(is_base_qtype(qtype), "qtype must be base type")
      subs.op = "max"
      subs.fn = subs.op .. "_" .. qtype 
      subs.ctype = qconsts.qtypes[qtype].ctype
      subs.qtype = qtype
      subs.reduce_ctype = subs.ctype
      if ( qtype == "I1" ) then subs.initial_val = "INT8_MIN" end
      if ( qtype == "I2" ) then subs.initial_val = "INT16_MIN" end
      if ( qtype == "I4" ) then subs.initial_val = "INT32_MIN" end
      if ( qtype == "I8" ) then subs.initial_val = "INT64_MIN" end
      if ( qtype == "F4" ) then subs.initial_val = "FLT_MIN" end
      if ( qtype == "F8" ) then subs.initial_val = "DBL_MIN" end
      assert(subs.initial_val)
      subs.reducer = "mcr_max"
      subs.t_reducer = subs.reducer
    end
    return subs, tmpl
end
