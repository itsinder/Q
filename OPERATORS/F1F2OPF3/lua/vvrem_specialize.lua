
return function (
  f1type, 
  f2type
  )
    local sz1 = assert(g_qtypes[f1type].width)
    local sz2 = assert(g_qtypes[f2type].width)
    local iorf1 = assert(g_iorf[f1type])
    local iorf2 = assert(g_iorf[f2type])
    assert(iorf1 == "fixed", "f1type must be integer. Is" .. f1type)
    assert(iorf2 == "fixed", "f2type must be integer. Is" .. f2type)
    local out_qtype = nil
    if ( sz1 < sz2 ) then 
         out_qtype = f1type
    else
         out_qtype = f2type
    end
    local tmpl = 'base.tmpl'
    local subs = {}
    subs.fn = "vvrem_" .. f1type .. "_" .. f2type .. "_" .. out_qtype
    subs.in1_ctype = assert(g_qtypes[f1type].ctype)
    subs.in2_ctype = assert(g_qtypes[f2type].ctype)
    subs.out_qtype = out_qtype
    subs.out_ctype = assert(g_qtypes[out_qtype].ctype)
    subs.c_code_for_operator = " c = a % b ;"
    return subs, tmpl
end
