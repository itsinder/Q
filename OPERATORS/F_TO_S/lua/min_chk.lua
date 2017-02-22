
function min_chk(
  intype
  )

    local tmpl = 'reduce.tmpl'
    local subs = {}
    subs.fn = "min_" .. intype 
    subs.intype = g_qtypes[intype].ctype
    subs.reducer = "mcr_min"
    return subs, tmpl
end
