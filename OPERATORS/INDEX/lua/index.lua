local T = {}
local function index(x, y)
  local expander = require 'Q/OPERATORS/INDEX/lua/expander_index'
  assert(x, "no arg x to index")
  assert(y, "no arg y to index")
  assert(type(x) == "lVector", "x is not lVector")
  assert(type(y) == "number", "y is not of type number")

  local status, col = pcall(expander, "index", x, y)
  if not status then print(col) end
  assert(status, "Could not execute INDEX")
  return col
end
T.where = index
require('Q/q_export').export('index', index)

return T
