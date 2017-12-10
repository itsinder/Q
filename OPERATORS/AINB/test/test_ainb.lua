-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local diff = require 'Q/UTILS/lua/diff'
local tests = {}
local script_dir = os.getenv("Q_SRC_ROOT") .. "/OPERATORS/AINB/test/"
tests.t1 = function() 
  local b = Q.mk_col({-2, 0, 2, 4 }, "I4")
  local a = Q.mk_col({-2, -2, -1, -1, 0, 1, 1, 2, 2, 3, 3}, "I4")
  local c = Q.ainb(a, b)
  local n = Q.sum(c):eval():to_num()
  assert(n == 5)
  Q.print_csv({a, c}, nil, "/tmp/_out1.txt")
  -- prepending script_dir so that this test will work from any location
  assert(diff(script_dir .. "out1.txt", "/tmp/_out1.txt"))
  print("Test t1 succeeded")
end

tests.t2 = function()
-- TODO Write one with a much larger A and B vector
  local vec_len = 65536 + 11
  local b = Q.seq({ len = vec_len, start = 1, by = 2, qtype = "I8"})
  b:eval()
  b:set_meta("sort_order", "asc") 
  local a = Q.seq({ len = vec_len, start = 1, by = 1, qtype = "I8"}):set_name("a")
  local c = Q.ainb(a, b):set_name("c")
  -- Q.print_csv({a,b,c}, nil, "_xx.csv")
  local n = Q.sum(c):eval():to_num()
  local expected_n = math.ceil(vec_len / 2)
  print("n, expected_n, len", n, expected_n, vec_len)
  assert(n == expected_n)
end

return tests
