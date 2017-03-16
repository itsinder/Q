
function min_chk(
  intype
  )
    local tmpl = 'reduce.tmpl'
    local subs = {}
    if ( intype == "B1" ) then
      assert(nil, "TODO")
    else
      assert(is_base_qtype(intype), "intype must be base type")
      subs.fn = "min_" .. intype 
      subs.intype = g_qtypes[intype].ctype
      subs.reducer = "mcr_min"
    end
    return subs, tmpl
end
