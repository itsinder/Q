local T = {} 
local function ifxtthenyelsez(x, y, z, optargs)
  local expander = require 'Q/OPERATORS/IFXTTHENYELSEZ/lua/expander_ifxtthenyelsez'
  assert(type(x) == "lVector")
  assert(type(y) == "lVector")
  assert(type(z) == "lVector")
  local status, col = pcall(expander, "ifxtthenyelsez", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute ifxtthenyelsez")
  return col
end
T.ifxtthenyelsez = ifxtthenyelsez
require('Q/q_export').export('ifxtthenyelsez', ifxtthenyelsez)
    
return T
