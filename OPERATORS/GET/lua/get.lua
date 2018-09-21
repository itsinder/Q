local T = {} 
local function get(x, y, optargs)
  local expander = require 'Q/OPERATORS/GET/lua/expander_get'
  assert(x)
  assert(y)
  local status, z = pcall(expander, "get", x, y, optargs)
  if ( not status ) then print(z) end
  assert(status, "Could not execute [get]")
  return z
end
T.get = get
require('Q/q_export').export('get', get)
    
