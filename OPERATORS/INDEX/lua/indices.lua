local T = {}
local function indices(x)
  local expander = require 'Q/OPERATORS/INDEX/lua/expander_indices'
  assert(x, "no arg x to indices")
  assert(type(x) == "lVector",  "x is not lVector")
  assert(x:qtype() == "B1", "x is not B1")
  local status, col = pcall(expander, "indices", x)
  if not status then print(col) end
  assert(status, "Could not execute INDICES")
  return col
end
T.indices = indices
require('Q/q_export').export('indices', indices)

return T
