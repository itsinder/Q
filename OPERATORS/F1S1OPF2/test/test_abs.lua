local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function()
  local c1 = Q.rand({lb = -10, ub = 10, qtype = "I4", len = 10})
  -- c1:eval(); Q.print_csv(c1, nil, "")
  local c1 = Q.abs(c1)
  -- c1:eval() Q.print_csv(c1, nil, "")
  
  local num_lt_0 = Q.sum(Q.vslt(c1, 0)):eval():to_num()
  assert(num_lt_0 == 0, "FAILURE")
end
return tests
