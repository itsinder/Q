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
return tests
