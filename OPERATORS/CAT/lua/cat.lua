local function cat(x, y)
  local Q       = require 'Q/q_export'
  local qc = require 'Q/UTILS/lua/q_core'

  assert(type(x) == "lVector", "x must be a vector")
  assert(type(y) == "lVector", "y must be a vector")
  assert(x:fldtype() == y:fldtype(), "both vectors must have same type")
  assert(x:has_nulls() == y:has_nulls(), "either both have nulls or neither has nulls, we will relax this assumption later")
  -- Krushnakant TODO: Here is the heart of the code
  -- nullify all meta data that might have been rendered invalid
  z:set_meta("sort_order") --  set sort order to null
  -- Krushnakant TODO: What else should we nullify?
  return z

end
return require('Q/q_export').export('cat', cat)
