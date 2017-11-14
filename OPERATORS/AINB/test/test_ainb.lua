-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local diff = require 'Q/UTILS/lua/diff'
local tests = {}
tests.t1 = function() 
  local b = Q.mk_col({-2, 0, 2, 4 }, "I4")
  local a = Q.mk_col({-2, -2, -1, -1, 0, 1, 1, 2, 2, 3, 3}, "I4")
  local c = Q.ainb(a, b)
  local n = Q.sum(c):eval():to_num()
  assert(n == 5)
  Q.print_csv({a, c}, nil, "_out1.txt")
  assert(diff("out1.txt", "_out1.txt"))
  print("Test t1 succeeded")
end

tests.t2 = function()
-- TODO Write one with a much larger A and B vector
  local b = Q.seq({ len = 1000000, start = 1, by = 2, qtype = "I8"})
  b:eval()
  b:set_meta("sort_order", "asc") 
  local a = Q.seq({ len = 1000000, start = 1, by = 1, qtype = "I8"})
  local c = Q.ainb(a, b)
  local n = Q.sum(c):eval():to_num()
  -- print(n)
  a:eval()
  Q.print_csv(a, { lb = 0, ub = 10 }, "")
  Q.print_csv(b, { lb = 0, ub = 10 }, "")
end

return tests
