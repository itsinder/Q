local T = {}
local function count(x, y)
  assert(type(x) == "lVector", "input must be of type lVector")
  local to_scalar = assert( require 'Q/UTILS/lua/to_scalar' )
  y = assert(to_scalar(y, x:fldtype()), "y should be a Scalar or number")
  local expander = assert(require 'Q/OPERATORS/F_TO_S/lua/expander_count')
  local status, z = pcall(expander, "count", x, y)
  if ( not status ) then print(z) end
  assert(status, "Could not execute count")
  return z
end
T.count = count
require('Q/q_export').export('count', count)
    
return T