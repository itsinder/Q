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
      subs.op = "sum"
      subs.fn = subs.op .. "_" .. qtype 
      subs.ctype = g_qtypes[qtype].ctype
      subs.qtype = qtype
      subs.init_val = 0
      if ( ( ctype == "I1" ) or ( ctype == "I2" ) or 
           ( ctype == "I4" ) or ( ctype == "I8" ) ) then
        subs.reduce_ctype = "uint64_t" 
      else
        subs.reduce_ctype = "double" 
      end
      subs.reducer = "mcr_sum"
      subs.t_reducer = subs.reducer
    end
    return subs, tmpl
end
