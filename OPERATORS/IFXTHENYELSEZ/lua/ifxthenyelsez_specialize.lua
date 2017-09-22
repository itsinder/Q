return function (
  qtype
  )
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
  local subs = {}; local tmpl
  assert(is_base_qtype(qtype))
  subs.fn = "ifxthenyelsez_" .. qtype 
  tmpl = 'ifxthenyelsez.tmpl'
  subs.ctype = qconsts.qtypes[qtype].ctype
  subs.qtype = qtype
  return subs, tmpl
end