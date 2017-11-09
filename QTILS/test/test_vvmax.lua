-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'

local tests = {}

tests.t1 = function ()
  local x = Q.mk_col({1, 2, -3, 4, -5, 6}, "I4")
  local y = Q.mk_col({1, -2, 3, -4, 5, 6}, "I4")
  local z = Q.mk_col({1, 2, 3, 4, 5, 6}, "I4")
  local t1 = Q.vvmax(x,y)
  assert(type(t1) == "lVector")
  assert(Q.sum(Q.vvneq(Q.vvmax(x, y), z)):eval():to_num() == 0 )
  -- t1:eval()
  -- Q.print_csv(t1, nil, "")
  -- Q.print_csv(Q.vvmax(x,y):eval(), nil, "")
  print("Test t1 succeeded")
end
return tests
