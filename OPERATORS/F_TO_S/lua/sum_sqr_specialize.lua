require('is_base_qtype')
function sum_sqr_specialize(
  intype
  )
    local tmpl = 'reduce.tmpl'
    local subs = {}
    if ( intype == "B1" ) then
      assert(nil, "TODO")
    else
      assert(is_base_qtype(intype), "intype must be base type")
      subs.fn = "sum_sqr_" .. intype 
      subs.intype = g_qtypes[intype].ctype
      subs.disp_intype = intype
      if ( ( intype == "I1" ) or ( intype == "I2" ) or 
           ( intype == "I4" ) or ( intype == "I8" ) ) then
        subs.reduce_intype = "uint64_t" 
        subs.init_val = g_constants.INIT_VAL_FOR_INT_SUM_SQR
      else
        subs.init_val = g_constants.INIT_VAL_FOR_FLT_SUM_SQR
        subs.reduce_intype = "double" 
      end
      subs.reducer = "mcr_sum_sqr"
      subs.t_reducer = "mcr_sum"
    end
    return subs, tmpl
end
