local T = {}
local function where(x, y, optargs)
  local expander = require 'Q/OPERATORS/WHERE/lua/expander_where'
  assert(type(x) == "lVector" and type(y) == "lVector", "Input type is not lVector")
  assert(y:qtype() == "B1", "Second vector qtype is not B1")
  local status, col = pcall(expander, "where", x, y, optargs)
  if not status then print(col) end
  assert(status, "Could not execute WHERE")
  return col
end
T.where = where
require('Q/q_export').export('where', where)

return T
