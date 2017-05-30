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
      subs.op = "sum_sqr" 
      subs.fn = subs.op .. "_" .. qtype 
      subs.ctype = g_qtypes[qtype].ctype
      subs.qtype = qtype
      subs.init_val = 0
      if ( ( qtype == "I1" ) or ( qtype == "I2" ) or 
           ( qtype == "I4" ) or ( qtype == "I8" ) ) then
        subs.reduce_ctype = "uint64_t" 
      elseif ( ( qtype == "F4" ) or ( qtype == "F8" ) ) then
        subs.reduce_ctype = "double"
      else
        assert(nil, "Invalid qtype " .. qtype)
      end
      subs.reducer = "mcr_sum_sqr"
      subs.t_reducer = "mcr_sum"
    end
    return subs, tmpl
end
