
function vvrem_static_checker(
  f1type, 
  f2type
  )
    local sz1 = assert(g_qtypes[f1type].width)
    local sz2 = assert(g_qtypes[f2type].width)
    local iorf1 = assert(g_iorf[f1type])
    local iorf2 = assert(g_iorf[f2type])
    if ( ( iorf1 == "floating_point" ) or 
         ( iorf2 == "floating_point" ) ) then
         print("remainder operator requires both operands to be integer")
         return nil
    end
    if ( sz1 < sz2 ) then 
         outtype = f1type
    else
         outtype = f2type
    end
    local subs = {}
    local incs = {}
    subs.fn = "vvrem_" .. f1type .. "_" .. f2type .. "_" .. outtype
    subs.in1type = assert(g_qtypes[f1type].ctype)
    subs.in2type = assert(g_qtypes[f2type].ctype)
    subs.returntype = assert(g_qtypes[outtype].ctype)
    subs.scalar_op = " c = a % b "
    return subs, incs
end
