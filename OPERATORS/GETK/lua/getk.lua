local T = {} 

local function mink(fval, k, fopt,  optargs)
  local expander
  if ( fopt ) then 
    expander = require 'Q/OPERATORS/GETK/lua/expander_getk2'
  else
    expander = require 'Q/OPERATORS/GETK/lua/expander_getk'
  end
  assert(expander)
  local status, col1, col2 = pcall(expander, "mink", fval, k, fopt, optargs) 
  if ( not status ) then print(col1) end
  assert(status, "Could not execute mink")
  return col1, col2
end
T.mink = mink
require('Q/q_export').export('mink', mink)

local function maxk(fval, k, fopt,  optargs)
  local expander
  if ( fopt ) then
    expander = require 'Q/OPERATORS/GETK/lua/expander_getk2'
  else
    expander = require 'Q/OPERATORS/GETK/lua/expander_getk'
  end
  local status, col1, col2 = pcall(expander, "maxk", fval, k, fopt, optargs)
  if ( not status ) then print(col1) end
  assert(status, "Could not execute maxk")
  return col1, col2
end
T.maxk = maxk
require('Q/q_export').export('maxk', maxk)

return T
