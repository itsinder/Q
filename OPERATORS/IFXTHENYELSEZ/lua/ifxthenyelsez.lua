local T = {} 
local function ifxthenyelsez(x, y, z)
  local expander = require 'Q/OPERATORS/IFXTHENYELSEZ/lua/expander_ifxthenyelsez'
  assert(type(x) == "lVector")
  assert(type(y) == "lVector")
  assert(type(z) == "lVector")
  local status, col = pcall(expander, "ifxthenyelsez", x, y, z)
  if ( not status ) then print(col) end
  assert(status, "Could not execute ifxthenyelsez")
  return col
end
T.ifxthenyelsez = ifxthenyelsez
require('Q/q_export').export('ifxthenyelsez', ifxthenyelsez)
    
return T
