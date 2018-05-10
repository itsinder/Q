local T = {}
local function numby(g, ng, optargs)
  local expander = require 'Q/OPERATORS/SUMBY/lua/expander_numby'
  assert(g, "no arg g to numby")
  local status, col = pcall(expander, "numby", g, ng, optargs)
  if not status then print(col) end
  assert(status, "Could not execute NUMBY")
  return col
end
T.numby = numby
require('Q/q_export').export('numby', numby)

return T

