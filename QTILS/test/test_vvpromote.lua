-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'

local tests = {}

tests.t1 = function ()
  local x = Q.mk_col({1, 2, -3, 4, -5, 6}, "I4")
  local y = Q.mk_col({1, -2, 3, -4, 5, 6}, "I4")
  local a, b = Q.vvpromote(x,y)
  assert(y == b)
  assert(x == a)
  print("Test t1 succeeded")
end
tests.t2 = function ()
  local x = Q.mk_col({1, 2, -3, 4, -5, 6}, "I1")
  local y = Q.mk_col({1, -2, 3, -4, 5, 6}, "I4")
  local a, b = Q.vvpromote(x,y)
  assert(y == b)
  assert(a:fldtype() == "I4")
  print("Test t2 succeeded")
end
-- TODO Write more tests
tests.t3 = function ()
  local x = Q.rand( { lb = 1000000, ub = 10000000, qtype = "I4", len = 1000000 })
  local y =Q.rand( { lb = 1000000, ub = 10000000, qtype = "I4", len = 1000000 })
  local a, b = Q.vvpromote(x,y)
  assert(y == b)
  assert(x == a)
  print("Test t3 succeeded")
end
tests.t4 = function ()
  local x = Q.rand( { lb = 1000000, ub = 10000000, qtype = "F4", len = 1000000 })
  local y =Q.rand( { lb = 1000000, ub = 10000000, qtype = "F8", len = 1000000 })
  local a, b = Q.vvpromote(x,y)
  assert(y == b)
  assert(a:fldtype() == "F8")
  assert(Q.sum(Q.vveq(a, x)):eval():to_num() == 1000000)
  print("Test t4 succeeded")
end
tests.t5 = function ()
  local x = Q.seq( {start = -1, by = -1, qtype = "I2", len = 100000} )
  local y =Q.seq( {start = 1, by = 1, qtype = "I4", len = 100000} )
  local a, b = Q.vvpromote(x,y)
  assert(a:fldtype() == "I4")
  assert(Q.sum(Q.vveq(a,x)):eval():to_num() == 100000)
  print("Test t5 succeeded")
end
tests.t6 = function ()
  local x = Q.seq( {start = -1, by = -1, qtype = "I1", len = 10} )
  local y =Q.seq( {start = 1, by = 1, qtype = "I4", len = 10} )
  local a, b = Q.vvpromote(x,y)
  assert(a:fldtype() == "I4")
  Q.sort(a:eval(), "asc")
  Q.abs(a) -- ToDo: Check why there is no effect of absolute operation after promote.
  Q.sort(b:eval(), "dsc")
  assert(Q.sum(Q.vvadd(a,b)):eval():to_num() == 0)
  print("Test t6 succeeded")
end
return tests
