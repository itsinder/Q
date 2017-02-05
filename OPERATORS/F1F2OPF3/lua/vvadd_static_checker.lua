
function vvadd_static_checker(
  f1type, 
  f2type, 
  optargs
  )
    local fouttype = optargs[fouttype]
    local l_outtype = nil
    local sz1 = assert(g_qtypes[f1type].width)
    local sz2 = assert(g_qtypes[f2type].width)
    local iorf1 = g_iorf[f1type]
    local iorf2 = g_iorf[f2type]
    if ( ( iorf1 == "fixed" ) and ( iorf2 == "fixed" ) ) then
      iorf_outtype = "fixed" 
    else
      iorf_outtype = "floating_point" 
    end
    local szout = sz1; 
    if ( sz2 > szout )  then szout = sz2 end
    if ( iorf_outtype == "floating_point" ) then 
      l_outtype = g_fsz_to_fld[szout]
    elseif ( iorf_outtype == "fixed" ) then 
      l_outtype = g_isz_to_fld[szout]
    else
      assert(false, "Control should not come here")
    end
    print("l_outtype = ", l_outtype)
    if ( fouttype ~= nil ) then 
      l_outtype = fouttype
      assert(g_qtypes[fouttype]) -- make sure that this is valid outtype
    end
    local tmpl = 'f1f2opf3.tmpl'
    local subs = {}; local incs = {}
    print("f1type = ", f1type)
    print("f2type = ", f1type)
    print("fouttype = ", fouttype)
    subs.fn = "vvadd_" .. f1type .. "_" .. f2type .. "_" .. l_outtype 
    subs.in1type = g_qtypes[f1type].ctype
    subs.in2type = g_qtypes[f2type].ctype
    print("l_outtype = ", l_outtype)
    subs.returntype = g_qtypes[l_outtype].ctype
    subs.argstype = "void *"
    subs.c_code_for_operator = "c = a + b"
    return subs, incs, tmpl
end
