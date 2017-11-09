-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
  tests.t1 = function()
  local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")
  local c3 = c1
  c1 = 10
  local c2 = Q.mk_col( {80,70,60,50,40,30,20,10}, "I8")
  local z = Q.vvadd(c3, c2)
  Q.print_csv(z:eval(), { lb = 1, ub = 4} , "_out1.txt")
  os.execute("diff _out1.txt out1.txt");
  assert(Q.sum(Q.vvneq(z, Q.mk_col({81,72,63,54,45,36,27,18}, "I4"))):eval():to_num() == 0 )
  print("Test t1 succeeded")
end
return tests
