local T = {}
local function unique(x, optargs)
  local expander = require 'Q/OPERATORS/UNIQUE/lua/expander_unique'
  assert(x, "no arg x to unique")
  assert(type(x) == "lVector", "x is not lVector")
  local status, col = pcall(expander, "unique", x, optargs)
  if not status then print(col) end
  assert(status, "Could not execute UNIQUE")
  return col
end
T.unique = unique
require('Q/q_export').export('unique', unique)

return T
