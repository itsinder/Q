-- FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local tests = {}
tests.t1 = function() 
  local num = (2048*1048576)-1
  local c1 = Q.const( {val = num, qtype = "I4", len = 8000000 })
  local minval = Q.min(c1):eval():to_num()
  local maxval = Q.max(c1):eval():to_num()
  assert(minval == num)
  assert(maxval == num)
  print("Test t1 succeeded")
end
return tests
