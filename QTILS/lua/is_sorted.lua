local Scalar = require 'libsclr'

local T = {}

-- Q.is_sorted(x) : checks the sort order of a given input vector(i.e. x)
            -- Return value:
              -- sort_order: 'asc' or 'desc'
              -- else returns nil (i.e. input vector not sorted)

-- Convention: Q.is_sorted(vector)
-- 1) vector : a vector other than B1 qtype

local function is_sorted(x)
  local Q = require 'Q'
  assert(x and type(x) == "lVector", "input must be of type lVector")
  local is_asc_reducer = Q.is_next(x, "geq") -- asc
  local is_asc = is_asc_reducer:eval()
  assert(type(is_asc) == "boolean")
  local is_desc_reducer = Q.is_next(x, "leq") -- desc
  local is_desc = is_desc_reducer:eval()
  assert(type(is_desc) == "boolean")
  
  local order = nil
  if is_asc == true then
    order = "asc"
  elseif is_desc == true then
    order = "dsc"
  end
  return order
end
T.is_sorted = is_sorted
require('Q/q_export').export('is_sorted', is_sorted)

return T
