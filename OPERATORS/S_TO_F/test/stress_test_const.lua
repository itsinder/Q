-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local function foo (x)
  local xsum = Q.sum(x):eval()
  local y = Q.const({val = 100, len = 10, qtype = "F8"})
  return y
end

z = Q.const({val = 10, len = 10, qtype = "F8"})
for i = 1, 1000000 do 
--[[
  local z = foo(z) === THIS WORKS 
  z = foo(z) === THIS BLOWS UP
--]]
  z = foo(z)
  if ( ( i % 1000) == 0 ) then print("Iteration ", i) end
end

print("SUCCESS for ", arg[0])
require('Q/UTILS/lua/cleanup')()
