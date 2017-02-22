
function min_chk(
  intype
  )

    local tmpl = 'reduce.tmpl'
    local subs = {}
    -- This includes is just as a demo. Not really needed
    subs.includes = "#include <math.h>\n#include <curl/curl.h>"
    subs.fn = "min_" .. intype 
    subs.intype = g_qtypes[intype].ctype
    subs.reducer = "mcr_min"
    return subs, tmpl
end
