return function (
  atype,
  btype,
  b_sort_order
  )
    local qconsts = require 'Q/UTILS/lua/q_consts'
    local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
    local subs = {}; local tmpl
    assert(is_base_qtype(atype), "type of A must be base type")
    assert(is_base_qtype(btype), "type of B must be base type")
    if ( b_sort_order and b_sort_order == "asc" ) then 
      subs.fn = "bin_search_ainb_" .. atype .. "_" .. btype
      tmpl = 'simple_ainb.tmpl'
    else
      subs.fn = "simple_ainb_" .. atype .. "_" .. btype
      tmpl = 'bin_search_ainb.tmpl'
    end
    subs.atype = qconsts.qtypes[atype].ctype
    subs.btype = qconsts.qtypes[btype].ctype
    return subs, tmpl
    end
