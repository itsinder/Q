
local common_specialize = require 'common_specialize'

local function mink_specialize(fval, k, optargs)
  local subs = {}
  assert(common_specialize(fval, k, optargs, subs))
  local tmpl = "XXXXXXX"
  subs.comparator = " < " -- will be > for maxby, what for numby???
  subs.sort_fn = "sort_asc_" .. subs.qtype -- will be dsc for maxby
  -- no need to sort for numby
  assert(qc[subs.sort_fn])

  return subs, tmpl
end
return mink_specialize
