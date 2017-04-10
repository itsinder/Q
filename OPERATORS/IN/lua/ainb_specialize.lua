require('is_base_qtype')
function ainb_specialize(
  atype,
  btype
  )
    local tmpl = 'ainb.tmpl'
    local subs = {}
    assert(is_base_qtype(atype), "type of A must be base type")
    assert(is_base_qtype(btype), "type of B must be base type")
    subs.fn = "ainb_" .. atype .. "_" .. btype
    subs.atype = g_qtypes[atype].ctype
    subs.btype = g_qtypes[btype].ctype
    return subs, tmpl
    end
