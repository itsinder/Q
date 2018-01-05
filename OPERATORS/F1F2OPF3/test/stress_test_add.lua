-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}

local function foo (x)
  local y = Q.vvadd(x, x)
  return y
end

tests.t1 = function()
  local z = Q.const({val = 10, len = 10, qtype = "F8"})
  for i = 1, 1000000 do 
  --[[
    local z = foo(z) === THIS WORKS 
  --]]
    z = foo(z) -- THIS BLOWS UP
    if ( ( i % 1000) == 0 ) then print("Iteration ", i) end
  end
  print("Test t1 succeeded")
end
return tests
