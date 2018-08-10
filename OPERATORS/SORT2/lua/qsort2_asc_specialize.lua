return function(in_qtype, ordr)
  local qconsts = require 'Q/UTILS/lua/q_consts'
  assert(type(ordr) == "string", "Sort2_asc order should be a string")
  assert( ( ( ordr == "asc") ), 
  "Sort order should be asc")
  local subs = {}
  local tmpl = 'qsort2_asc.tmpl'
  subs.SORT_ORDER = ordr
  subs.QTYPE = in_qtype
  subs.fn = "qsort2_asc_" .. in_qtype
  subs.FLDTYPE = qconsts.qtypes[in_qtype].ctype
  subs.in_qtype = in_qtype
  -- TODO Check below is correct order/comparator combo
  local c = ""
  if ordr == "asc" then c = "<" end
  --if ordr == "dsc" then c = ">" end
  subs.COMPARATOR = c
  return subs, tmpl
end
