-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local tests = {}

tests.t1 = function()
-- TODO Write one with a much larger A and B vector
  local b = Q.seq({ len = 100000, start = 1, by = 2, qtype = "I4"})
  local a = Q.seq({ len = 100000, start = 1, by = 1, qtype = "I4"})
  print("XX ", Q.min(a):eval():to_num())
  assert(Q.min(a):eval():to_num() == 1 )
  assert(Q.min(b):eval():to_num() == 1 )
  print("Test t1 succeeded")
end
return tests
