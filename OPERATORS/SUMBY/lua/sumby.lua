local T = {}
local function sumby(x, g, ng, optargs)
  local expander = require 'Q/OPERATORS/SUMBY/lua/expander_sumby'
  assert(x, "no arg x to sumby")
  assert(g, "no arg g to sumby")
  local status, col = pcall(expander, "sumby", x, g, ng, optargs)
  if not status then print(col) end
  assert(status, "Could not execute SUMBY")
  return col
end
T.sumby = sumby
require('Q/q_export').export('sumby', sumby)

return T

