local T = {}
local function minby(x, g, ng, optargs)
  local expander = require 'Q/OPERATORS/SUMBY/lua/expander_minby'
  assert(x, "no arg x to minby")
  assert(g, "no arg y to minby")
  assert(type(x) == "lVector",  "x is not lVector")
  assert(type(g) == "lVector",  "g is not lVector")
  assert(ng > 0)
  assert(type(ng) == "number")
  local status, col = pcall(expander, "minby", x, g, ng, optargs)
  if not status then print(col) end
  assert(status, "Could not execute MINBY")
  return col
end
T.minby = minby
require('Q/q_export').export('minby', minby)

return T

