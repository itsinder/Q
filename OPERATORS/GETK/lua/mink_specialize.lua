local qconsts = require 'Q/UTILS/lua/q_consts'

local function mink_specialize(fldtype)
  local subs = {}

  local qtype = fldtype
  local ctype = qconsts.qtypes[qtype].ctype
  local width = qconsts.qtypes[qtype].width

  subs.qtype = qtype
  subs.ctype = ctype
  subs.width = width

  local tmpl = "merge1.tmpl"
  subs.fn = "merge_min_" .. qtype
  subs.min_or_max = "min"
  subs.comparator = "<"
  subs.sort_fn = "qsort_asc_" .. subs.qtype
  return subs, tmpl
end
return mink_specialize
