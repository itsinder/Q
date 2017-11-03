-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'

local tests = {}

tests.t1 = function ()
  local x = Q.mk_col({1, 2, 3, 4, 5}, "I4")
  local y = Q.mk_col({1, 2, 3, 4, 5}, "I4")
  local z = Q.vvseq(x, y, 0)
  print(z)
  assert(z == true)
end
--======================================
tests.t2 = function ()
  local x = Q.mk_col({1, 2, 3, 4, 5}, "I4")
  local y = Q.mk_col({2, 3, 4, 5, 6}, "I4")
  local z = Q.vvseq(x, y, 0)
  print(z)
  assert(z == false)
end
--======================================
tests.t3 = function ()
  local x = Q.mk_col({1, 2, 3, 4, 5}, "I4")
  local y = Q.mk_col({2, 3, 4, 5, 6}, "I4")
  local z = Q.vvseq(x, y, 1)
  print(z)
  assert(z == true)
end
--======================================
return tests
