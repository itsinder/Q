
function vvrem_specialize(
  f1type, 
  f2type
  )
    local sz1 = assert(g_qtypes[f1type].width)
    local sz2 = assert(g_qtypes[f2type].width)
    local iorf1 = assert(g_iorf[f1type])
    local iorf2 = assert(g_iorf[f2type])
    assert(iorf1 == "fixed", "f1type must be integer. Is" .. f1type)
    assert(iorf2 == "fixed", "f2type must be integer. Is" .. f2type)
    local outtype = nil
    if ( sz1 < sz2 ) then 
         outtype = f1type
    else
         outtype = f2type
    end
    local tmpl = 'base.tmpl'
    local subs = {}
    subs.fn = "vvrem_" .. f1type .. "_" .. f2type .. "_" .. outtype
    subs.in1type = assert(g_qtypes[f1type].ctype)
    subs.in2type = assert(g_qtypes[f2type].ctype)
    subs.outtype = assert(g_qtypes[outtype].ctype)
    subs.argstype = "void *"
    subs.c_code_for_operator = " c = a % b ;"
    return subs, tmpl
end
