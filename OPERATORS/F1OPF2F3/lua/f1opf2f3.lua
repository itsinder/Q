local T = {} 
local function split(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2F3/lua/expander_split'
  assert(x)
  assert(y)
  local status, z = pcall(expander, "split", x, y, optargs)
  if ( not status ) then print(z) end
  assert(status, "Could not execute [split]")
  return z
end
T.split = split
require('Q/q_export').export('split', split)
    
