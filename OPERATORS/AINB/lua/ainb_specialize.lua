return function (
  atype,
  btype
  )
    local qconsts = require 'Q/UTILS/lua/q_consts'
    local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
    local tmpl = 'ainb.tmpl'
    local subs = {}
    assert(is_base_qtype(atype), "type of A must be base type")
    assert(is_base_qtype(btype), "type of B must be base type")
    subs.fn = "ainb_" .. atype .. "_" .. btype
    subs.atype = qconsts.qtypes[atype].ctype
    subs.btype = qconsts.qtypes[btype].ctype
    return subs, tmpl
    end
